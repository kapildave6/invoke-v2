import Foundation
#if canImport(Darwin)
import Darwin
#endif
import AppKit
import InvokeIPC
import InvokeRenderer
import InvokeServices

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
    /// The host-side view-model tree for the BASE navigation frame (frame 0). Mutated on the main queue.
    public let tree = ViewTree()
    /// Pushed navigation frames (render-on-push): frame id → its own tree. Lower frames stay mounted in
    /// the child (state preserved); the host stacks their trees and displays the active one.
    private var extraFrames: [Int: ViewTree] = [:]
    /// The tree for a given navigation frame (0 = base `tree`); created on first mutation.
    public func frameTree(_ frame: Int) -> ViewTree {
        if frame == 0 { return tree }
        if let t = extraFrames[frame] { return t }
        let t = ViewTree(); extraFrames[frame] = t; return t
    }
    /// Fired on the MAIN queue when the active navigation frame changes (args: depth, active frame id).
    public var onNav: ((Int, Int) -> Void)?

    /// Fired on the MAIN queue after each commit is applied (arg: commit sequence number).
    public var onCommit: ((Int) -> Void)?
    /// Fired on the MAIN queue when the extension invokes an allowlisted host capability; the returned
    /// JSONValue is sent back to the child as the RPC result (open/clipboard/localStorage/…).
    public var onCapability: ((_ method: String, _ params: JSONValue?) -> JSONValue)?
    /// Like onCapability but may defer the reply (return true to claim the method and call `reply` later
    /// — used for capabilities that await user input, e.g. confirmAlert's in-palette modal). Tried first.
    /// `reply` RESOLVES the child's RPC promise with a value; `fail` REJECTS it with an error message
    /// (so the extension's `await rpc(...)` throws — e.g. Raycast's `runAppleScript` rejects on a script
    /// error, which extensions catch). An async handler calls exactly one of the two.
    public var onCapabilityAsync: ((_ method: String, _ params: JSONValue?, _ reply: @escaping (JSONValue) -> Void, _ fail: @escaping (String) -> Void) -> Bool)?
    /// Diagnostic log sink (main queue).
    public var onLog: ((String) -> Void)?
    /// Fired on the MAIN queue when the child process ends WITHOUT an intentional terminate() — e.g. it
    /// crashed or failed to start (missing dep, denied syscall). Lets the controller recover gracefully.
    public var onTerminate: (() -> Void)?
    /// Fired on the MAIN queue when a SANDBOXED child failed because it imported a denied Node built-in
    /// (arg: the module name, e.g. "fs"). Lets the controller offer "Trust & relaunch".
    public var onSandboxDenial: ((String) -> Void)?
    /// Fired on the MAIN queue when an AI-extension tool (mode "ai-tool") returns its result/error.
    public var onAIToolResult: ((_ result: JSONValue?, _ error: String?) -> Void)?
    /// Fired on the fd-4 RESPONDER thread (NOT main) for each virtual-filesystem op the sandboxed child
    /// makes (remediation 01). The child is blocked awaiting the reply, so this may itself block (e.g. on
    /// a main-queue consent dialog). Returns the op's result/error object, framed straight back to fd 4.
    public var onFS: ((_ op: String, _ params: JSONValue?) -> JSONValue)?

    /// The capability allowlist — mirrors the Node supervisor's ALLOWED_RPC. Denial is enforced HERE
    /// in the host, so even a child crafting a raw RPC frame gets nothing it isn't granted (PLAN §4.4).
    private static let allowedRPC: Set<String> = [
        "clipboard.copy", "clipboard.paste", "clipboard.readText", "clipboard.clear",
        "toast.show", "hud.show", "window.close", "preferences.get",
        "open", "localStorage.getItem", "localStorage.setItem",
        "localStorage.removeItem", "localStorage.clear", "localStorage.allItems",
        "runAppleScript", // gated OS-automation capability (Raycast's @raycast/utils runAppleScript)
        "executeSQL",     // gated read-only SQLite capability (Raycast's @raycast/utils useSQL/executeSQL)
        "confirmAlert",     // modal confirm dialog (Raycast's confirmAlert)
        "preferences.open", // open Settings to this extension (open{Extension,Command}Preferences)
        "captureException", // diagnostic log (Raycast's captureException)
        "cache.set", "cache.remove", "cache.clear", "cache.allItems", // persisted per-extension Cache
        // selection / application / finder / filesystem APIs (remediation 04)
        "selection.read", "app.list", "app.frontmost", "app.default",
        "finder.reveal", "finder.selection", "fs.trash",
        "ai.ask", // Raycast AI.ask / useAI (host Anthropic client)
        "browser.getTabs",   // Raycast BrowserExtension.getTabs (host AppleScript)
        "browser.getContent", // Raycast BrowserExtension.getContent (host AppleScript)
        // OAuth (PKCE): authorize is async; authorizeRequest/{set,get,remove}Tokens are sync.
        "oauth.authorizeRequest", "oauth.authorize", "oauth.setTokens", "oauth.getTokens", "oauth.removeTokens",
        "command.updateMetadata",
        "command.launch", // launchCommand(): launch another command (same or named extension)
        "quicklink.create", "snippet.create", "clipboard.read", "quicklook.preview", "open.with", "date.pick",
    ]

    private var pid: pid_t = -1
    private var sockFD: Int32 = -1
    private var fsSockFD: Int32 = -1 // host end of the fd-4 synchronous filesystem channel
    private var intentionalStop = false // set by terminate() so a clean stop doesn't fire onTerminate
    private let decoder = FrameDecoder()
    private let fsDecoder = FrameDecoder()
    private let readQueue = DispatchQueue(label: "invoke.exthost.read")
    private let fsQueue = DispatchQueue(label: "invoke.exthost.fs") // blocking fd-4 responder
    private let writeQueue = DispatchQueue(label: "invoke.exthost.write")
    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()

    public init() {}

    /// Launch `<repoRoot>/<entryRelPath>`. `mode` is "view" (renders + streams mutations) or "no-view"
    /// (runs the command's default export as a headless action, then the process exits).
    /// `preferences` is the JSON the extension reads via getPreferenceValues() (INVOKE_PREFERENCES).
    public func launch(repoRoot: String, entryRelPath: String, command: String, preferences: String = "{}", mode: String = "view", trusted: Bool = false, assetsPath: String = "", supportPath: String = "", arguments: String = "{}", launchType: String = "userInitiated", toolInput: String = "{}", launchContext: String = "{}") {
        var fds: [Int32] = [0, 0]
        guard socketpair(AF_UNIX, SOCK_STREAM, 0, &fds) == 0 else {
            log("socketpair failed: \(String(cString: strerror(errno)))")
            return
        }
        let parentFD = fds[0]
        let childFD = fds[1]
        intentionalStop = false

        // Second socketpair = the synchronous filesystem channel (fd 4). socketpair() ends are BLOCKING by
        // default, and we never wrap the child's end in a non-blocking reader, so the child's fs.readSync
        // on fd 4 blocks until we reply — exactly the semantics readFileSync needs (remediation 01).
        var fsFds: [Int32] = [0, 0]
        guard socketpair(AF_UNIX, SOCK_STREAM, 0, &fsFds) == 0 else {
            log("fs socketpair failed: \(String(cString: strerror(errno)))")
            close(parentFD); close(childFD)
            return
        }
        let fsParentFD = fsFds[0]
        let fsChildFD = fsFds[1]

        // Belt-and-suspenders to the global SIGPIPE ignore: a write to these sockets after the child dies
        // returns EPIPE instead of raising SIGPIPE.
        var noSigpipe: Int32 = 1
        setsockopt(parentFD, SOL_SOCKET, SO_NOSIGPIPE, &noSigpipe, socklen_t(MemoryLayout<Int32>.size))
        setsockopt(fsParentFD, SOL_SOCKET, SO_NOSIGPIPE, &noSigpipe, socklen_t(MemoryLayout<Int32>.size))

        // Child gets the RPC socket on fd 3 and the fs socket on fd 4; never sees the parent's ends.
        var actions: posix_spawn_file_actions_t?
        posix_spawn_file_actions_init(&actions)
        posix_spawn_file_actions_addclose(&actions, parentFD)
        posix_spawn_file_actions_addclose(&actions, fsParentFD)
        posix_spawn_file_actions_adddup2(&actions, childFD, 3)
        posix_spawn_file_actions_adddup2(&actions, fsChildFD, 4)
        defer { posix_spawn_file_actions_destroy(&actions) }

        // sh -c sets cwd (so `tsx` + workspace packages resolve from node_modules) then execs node,
        // inheriting our stdout/stderr so the extension's logs surface in the host's console. Every
        // interpolated value is shell-quoted — a dir/command with an apostrophe must not inject shell.
        let script = "cd \(Self.shellQuote(repoRoot)) && exec node --import tsx runtime/node-host/src/child.ts \(Self.shellQuote(entryRelPath)) \(Self.shellQuote(command))"
        let argv = ["/bin/sh", "-c", script]
        var env = ProcessInfo.processInfo.environment
        // Security: the host's AI key must never be readable by a (possibly unsandboxed) extension.
        // AI is reached via the gated ai.ask RPC, which runs in the host — the child never needs the key.
        env["ANTHROPIC_API_KEY"] = nil
        env["INVOKE_COMMAND"] = command
        env["INVOKE_PREFERENCES"] = preferences
        env["INVOKE_MODE"] = mode
        env["INVOKE_TRUSTED"] = trusted ? "1" : "0"
        // Raycast's environment.assetsPath (the extension's assets/ dir) and environment.supportPath (a
        // writable per-extension dir). Many extensions read these AT MODULE LOAD (e.g. join(assetsPath,
        // "x.png")) — an undefined value would throw and the process would exit before its first render.
        env["INVOKE_ASSETS_PATH"] = assetsPath
        env["INVOKE_SUPPORT_PATH"] = supportPath
        // Raycast command arguments (the search-bar fields), as {name: value} JSON. The command reads
        // them via props.arguments (LaunchProps); Invoke collects them in a form before launch.
        env["INVOKE_ARGUMENTS"] = arguments
        env["INVOKE_LAUNCH_TYPE"] = launchType // "userInitiated" | "background" (interval-scheduled)
        env["INVOKE_LAUNCH_CONTEXT"] = launchContext // launchCommand({context}) payload for the target
        env["INVOKE_TOOL_INPUT"] = toolInput   // ai-tool mode: the model-provided tool input (JSON)
        // Point tsx at the extension's own tsconfig so its `@/*` → `src/*` path alias resolves (entry is
        // <extDir>/src/<cmd>.<ext>). Without this tsx picks the repo-root tsconfig and `@/x` fails to load.
        let extDir = (((entryRelPath as NSString).deletingLastPathComponent) as NSString).deletingLastPathComponent
        let extTsconfig = repoRoot + "/" + extDir + "/tsconfig.json"
        if FileManager.default.fileExists(atPath: extTsconfig) { env["TSX_TSCONFIG_PATH"] = extTsconfig }
        // Real host-provided environment values (appearance, textSize, AI access).
        // NSApp.effectiveAppearance is an AppKit property that must be read on the main thread.
        // launch() is called from main in most paths, but the ai-tool path runs off-main — so we
        // guard with Thread.isMainThread: already on main → read directly (no deadlock risk);
        // off-main → hop to main synchronously via DispatchQueue.main.sync.
        let appearanceDark: Bool = Thread.isMainThread
            ? (NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua)
            : DispatchQueue.main.sync { NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua }
        env["INVOKE_APPEARANCE"] = appearanceDark ? "dark" : "light"
        env["INVOKE_TEXT_SIZE"] = "medium" // host UI exposes no size setting yet; "medium" is the default
        // Boolean flag only — the key value is NEVER read or echoed (security / GDPR).
        env["INVOKE_CAN_ACCESS_AI"] = AIService.hasStoredKey() ? "1" : "0"
        let envp = env.map { "\($0.key)=\($0.value)" }

        var childPid: pid_t = 0
        let rc = withCStringArray(argv) { cArgv in
            withCStringArray(envp) { cEnvp in
                posix_spawn(&childPid, "/bin/sh", &actions, nil, cArgv, cEnvp)
            }
        }
        close(childFD)   // parent only keeps its own ends of both socketpairs
        close(fsChildFD)

        guard rc == 0 else {
            log("posix_spawn failed: \(String(cString: strerror(rc)))")
            close(parentFD)
            close(fsParentFD)
            return
        }
        pid = childPid
        sockFD = parentFD
        fsSockFD = fsParentFD
        log("spawned extension pid \(childPid): \(entryRelPath) [\(command)]")
        startReadLoop(fd: parentFD)
        startFSResponder(fd: fsParentFD)
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
            if !self.intentionalStop {
                DispatchQueue.main.async { self.onTerminate?() } // crashed / failed to start
            }
        }
    }

    /// The fd-4 blocking responder (remediation 01). A SANDBOXED child sends one framed `{op, ...params}`
    /// per synchronous fs call and BLOCKS on `readSync` until we frame a reply back — so this loop MUST
    /// answer every request, even on error, or the child hangs forever on a file op. Mediation + per-folder
    /// consent live in `onFS` (set by the controller); with no handler installed we deny, so the child gets
    /// a clean error instead of a hang. (Trusted children use the real Node `fs` and never use this fd.)
    private func startFSResponder(fd: Int32) {
        fsQueue.async { [weak self] in
            guard let self else { return }
            var buf = [UInt8](repeating: 0, count: 1 << 16)
            while true {
                let n = read(fd, &buf, buf.count)
                if n <= 0 { break }
                for body in self.fsDecoder.push(Data(buf[0..<n])) {
                    let reply = self.fulfillFS(body)
                    if let data = try? self.jsonEncoder.encode(reply) {
                        self.writeFS(FrameCodec.encode(data), fd: fd)
                    }
                }
            }
            self.log("fs channel closed")
        }
    }

    /// Decode one fd-4 request `{op, ...params}` and hand it to `onFS` for mediation. Always returns a
    /// reply object: `{...result}` on success, or `{error, code?}` which the child's shim re-throws with
    /// `err.code` set (so `existsSync`/`readFileSync` surface ENOENT etc. exactly like real Node fs).
    private func fulfillFS(_ body: Data) -> JSONValue {
        guard let req = try? jsonDecoder.decode(JSONValue.self, from: body),
              case .object(let o) = req, case .string(let op)? = o["op"] else {
            return .object(["error": .string("[invoke:fs] malformed request"), "code": .string("EINVAL")])
        }
        guard let onFS else {
            return .object(["error": .string("[invoke:fs] filesystem is not available"), "code": .string("EACCES")])
        }
        return onFS(op, req)
    }

    /// Blocking framed write straight to fd 4 (NOT the writeQueue, which serializes the fd-3 RPC stream).
    /// We're already on the dedicated responder thread and the child is awaiting exactly this one reply.
    private func writeFS(_ frame: Data, fd: Int32) {
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
            let frame = msg.frame ?? 0
            DispatchQueue.main.async {
                self.frameTree(frame).apply(ops)
                self.onCommit?(commit)
            }
        case "nav":
            let depth = msg.depth ?? 0
            let frame = msg.frame ?? 0
            DispatchQueue.main.async { self.onNav?(depth, frame) }
        case "log":
            // Surface the extension's console output (was dropped) — invaluable for debugging extensions.
            let level = msg.level ?? "info"
            let text = (msg.args ?? []).map { $0.stringValue ?? $0.debugString }.joined(separator: " ")
            log("[ext \(level)] \(text)")
        case "sandboxDenial":
            let module = msg.module ?? "a Node built-in"
            DispatchQueue.main.async { self.onSandboxDenial?(module) }
        case "aiToolResult":
            let result = msg.result; let error = msg.error
            DispatchQueue.main.async { self.onAIToolResult?(result, error) }
        case "rpc":
            guard let id = msg.id, let method = msg.method else { break }
            let params = msg.params
            // Enforce the allowlist in the host (denial by the host, not by SDK convention, §4.4).
            guard Self.allowedRPC.contains(method) else {
                replyRPC(id: id, error: "host method not allowed: \(method)")
                log("[rpc DENIED] \(method)")
                break
            }
            // Fulfil on the main queue (AppKit), then reply with the result to the child. An ASYNC
            // capability (e.g. confirmAlert shows an in-palette modal and resolves on a later click)
            // takes the reply closure and defers replyRPC; if it doesn't handle the method, fall back to
            // the synchronous onCapability.
            DispatchQueue.main.async {
                if let asyncH = self.onCapabilityAsync,
                   asyncH(method, params,
                          { [weak self] result in self?.replyRPC(id: id, result: result) },
                          { [weak self] error in self?.replyRPC(id: id, error: error) }) {
                    return // handled async; the reply is deferred until the modal resolves
                }
                let result = self.onCapability?(method, params) ?? .null
                self.replyRPC(id: id, result: result)
            }
        default:
            break
        }
    }

    /// Host → child: the search text changed (drives the extension's `onSearchTextChange`).
    public func setSearchText(_ text: String) {
        guard let data = try? jsonEncoder.encode(ChildBound.searchText(text)) else { return }
        write(FrameCodec.encode(data))
    }

    /// Host → child: invoke an action handler the child exposed via a serialized `onAction` prop.
    /// `args` carries e.g. the collected Form values to a submit handler.
    public func invoke(handler: String, args: [JSONValue] = []) {
        guard let data = try? jsonEncoder.encode(ChildBound.invoke(handler, args)) else { return }
        write(FrameCodec.encode(data))
    }

    /// Host → child: pop the top navigation frame (Esc on a pushed view). The child unmounts it and
    /// replies with a `nav` message reflecting the new active frame.
    public func navPop() {
        guard let data = try? jsonEncoder.encode(ChildBound.navPop()) else { return }
        write(FrameCodec.encode(data))
    }

    private func replyRPC(id: Int, result: JSONValue) {
        let obj: [String: JSONValue] = ["kind": .string("rpcResult"), "id": .number(Double(id)), "result": result]
        guard let data = try? jsonEncoder.encode(JSONValue.object(obj)) else { return }
        write(FrameCodec.encode(data))
    }

    private func replyRPC(id: Int, error: String) {
        let obj: [String: JSONValue] = ["kind": .string("rpcResult"), "id": .number(Double(id)), "error": .string(error)]
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
        intentionalStop = true // a clean stop must not fire onTerminate
        if pid > 0 { kill(pid, SIGTERM); pid = -1 }
        let fd = sockFD
        sockFD = -1 // new writes see -1 and skip
        if fd >= 0 { writeQueue.async { close(fd) } } // ordered AFTER any pending writes (FIFO)
        // Close the fd-4 channel directly (NOT via fsQueue — the responder is blocked IN read() there, so a
        // queued close would never run). Closing the fd unblocks that read(), ending the responder loop.
        let fsFd = fsSockFD
        fsSockFD = -1
        if fsFd >= 0 { close(fsFd) }
    }

    /// POSIX single-quote a value for safe interpolation into an `sh -c` string.
    private static func shellQuote(_ s: String) -> String {
        "'" + s.replacingOccurrences(of: "'", with: "'\\''") + "'"
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
