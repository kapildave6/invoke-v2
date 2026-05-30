import Foundation
#if canImport(Darwin)
import Darwin
#endif
import InvokeIPC
import InvokeRenderer

/// The Swift host side of the extension runtime (PLAN.md §4.4/§4.6).
///
/// Spawns ONE extension as its own OS process (`node --import tsx child.ts <entry> <command>`),
/// handing it a dedicated UNIX socket on **fd 3** for the length-prefixed framed JSON-RPC the
/// runtime already speaks. We read the render-mutation stream, apply it to a `ViewTree`, and
/// hand commits back on the main queue for AppKit to render — the exact pipeline `npm run demo`
/// proves in pure Node, with the native host now playing the supervisor role.
///
/// Phase-0 dev bridge: a blocking read loop on a background queue. Production swaps this for
/// DispatchIO with backpressure, a warm pool, crash-restart, and the RPC capability allowlist
/// (which today lives in the Node supervisor; here we just unblock the child's awaited calls).
public final class ExtensionHost {
    /// The host-side view-model tree the mutation stream is applied to. Mutated on the main queue.
    public let tree = ViewTree()

    /// Fired on the MAIN queue after each commit is applied (arg: commit sequence number).
    public var onCommit: ((Int) -> Void)?
    /// Diagnostic log sink (main queue).
    public var onLog: ((String) -> Void)?

    private var pid: pid_t = -1
    private var sockFD: Int32 = -1
    private let decoder = FrameDecoder()
    private let readQueue = DispatchQueue(label: "invoke.exthost.read")
    private let writeQueue = DispatchQueue(label: "invoke.exthost.write")
    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()

    public init() {}

    /// Launch `<repoRoot>/<entryRelPath>` as a `view` command and start streaming its mutations.
    public func launch(repoRoot: String, entryRelPath: String, command: String) {
        var fds: [Int32] = [0, 0]
        guard socketpair(AF_UNIX, SOCK_STREAM, 0, &fds) == 0 else {
            log("socketpair failed: \(String(cString: strerror(errno)))")
            return
        }
        let parentFD = fds[0]
        let childFD = fds[1]

        // Child gets the socket on fd 3 and never sees the parent's end.
        var actions: posix_spawn_file_actions_t?
        posix_spawn_file_actions_init(&actions)
        posix_spawn_file_actions_addclose(&actions, parentFD)
        posix_spawn_file_actions_adddup2(&actions, childFD, 3)
        defer { posix_spawn_file_actions_destroy(&actions) }

        // sh -c sets cwd (so `tsx` + workspace packages resolve from node_modules) then execs node,
        // inheriting our stdout/stderr so the extension's logs surface in the host's console.
        let script = "cd '\(repoRoot)' && exec node --import tsx runtime/node-host/src/child.ts '\(entryRelPath)' '\(command)'"
        let argv = ["/bin/sh", "-c", script]
        let envp = ProcessInfo.processInfo.environment.map { "\($0.key)=\($0.value)" }

        var childPid: pid_t = 0
        let rc = withCStringArray(argv) { cArgv in
            withCStringArray(envp) { cEnvp in
                posix_spawn(&childPid, "/bin/sh", &actions, nil, cArgv, cEnvp)
            }
        }
        close(childFD) // parent only keeps its own end

        guard rc == 0 else {
            log("posix_spawn failed: \(String(cString: strerror(rc)))")
            close(parentFD)
            return
        }
        pid = childPid
        sockFD = parentFD
        log("spawned extension pid \(childPid): \(entryRelPath) [\(command)]")
        startReadLoop(fd: parentFD)
    }

    private func startReadLoop(fd: Int32) {
        readQueue.async { [weak self] in
            guard let self else { return }
            var buf = [UInt8](repeating: 0, count: 1 << 16)
            while true {
                let n = read(fd, &buf, buf.count)
                if n <= 0 { break }
                for body in self.decoder.push(Data(buf[0..<n])) { self.handle(body) }
            }
            self.log("extension process ended")
        }
    }

    private func handle(_ body: Data) {
        guard let msg = try? jsonDecoder.decode(HostBound.self, from: body) else {
            log("undecodable frame (\(body.count) bytes)")
            return
        }
        switch msg.kind {
        case "ready":
            log("extension ready: \(msg.command ?? "")")
        case "mutations":
            let ops = msg.ops ?? []
            let commit = msg.commit ?? 0
            DispatchQueue.main.async {
                self.tree.apply(ops)
                self.onCommit?(commit)
            }
        case "log":
            log("[ext log]")
        case "rpc":
            // The capability allowlist is enforced in the Node supervisor; from the native host we
            // just acknowledge so the extension's awaited host call resolves (no capability granted).
            if let id = msg.id { replyRPC(id: id) }
        default:
            break
        }
    }

    /// Host → child: the search text changed (drives the extension's `onSearchTextChange`).
    public func setSearchText(_ text: String) {
        guard let data = try? jsonEncoder.encode(ChildBound.searchText(text)) else { return }
        write(FrameCodec.encode(data))
    }

    private func replyRPC(id: Int) {
        let obj: [String: JSONValue] = ["kind": .string("rpcResult"), "id": .number(Double(id)), "result": .null]
        guard let data = try? jsonEncoder.encode(JSONValue.object(obj)) else { return }
        write(FrameCodec.encode(data))
    }

    private func write(_ frame: Data) {
        let fd = sockFD
        guard fd >= 0 else { return }
        writeQueue.async {
            frame.withUnsafeBytes { (raw: UnsafeRawBufferPointer) in
                guard let base = raw.baseAddress else { return }
                var off = 0
                while off < raw.count {
                    let w = Darwin.write(fd, base.advanced(by: off), raw.count - off)
                    if w <= 0 { break }
                    off += w
                }
            }
        }
    }

    public func terminate() {
        if pid > 0 { kill(pid, SIGTERM) }
        if sockFD >= 0 { close(sockFD); sockFD = -1 }
    }

    private func log(_ message: String) {
        DispatchQueue.main.async { self.onLog?(message) }
    }
}

/// Build a NULL-terminated C string array for posix_spawn argv/envp, freed after `body` returns.
private func withCStringArray<R>(_ strings: [String], _ body: (UnsafePointer<UnsafeMutablePointer<CChar>?>) -> R) -> R {
    var cStrings: [UnsafeMutablePointer<CChar>?] = strings.map { strdup($0) }
    cStrings.append(nil)
    defer { for p in cStrings where p != nil { free(p) } }
    return cStrings.withUnsafeBufferPointer { body($0.baseAddress!) }
}
