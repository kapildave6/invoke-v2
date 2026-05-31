import Foundation

/// The structured report emitted by `runtime/node-host/src/import.ts --json`.
public struct ImportReport: Codable {
    public struct Command: Codable { public let name: String; public let title: String; public let mode: String; public let entryFound: Bool }
    public let id: String
    public let title: String
    public let commands: [Command]
    public let missingApi: [String]
    public let missingUtils: [String]
    public let deniedBuiltins: [String]
    public let blocking: Bool
    public let verdict: String      // "runnable" | "degraded" | "needs-work"
    public let installed: Bool
    public let dest: String
}

/// Runs the `invoke import` CLI (the same one `npm run import:ext` uses) out of process and parses its
/// `--json` report, so the Settings "Import" pane can check compatibility and install from the source.
public struct ImportError: Error { public let message: String; public init(_ m: String) { message = m } }

public final class ExtensionImporter {
    private let repoRoot: String
    public init(repoRoot: String) { self.repoRoot = repoRoot }

    /// `install: false` runs the compatibility check only; `true` also copies it into imported/.
    public func run(path: String, install: Bool) async -> Result<ImportReport, ImportError> {
        await withCheckedContinuation { cont in
            DispatchQueue.global(qos: .userInitiated).async {
                cont.resume(returning: self.runSync(path: path, install: install))
            }
        }
    }

    private func runSync(path: String, install: Bool) -> Result<ImportReport, ImportError> {
        func shq(_ s: String) -> String { "'" + s.replacingOccurrences(of: "'", with: "'\\''") + "'" }
        let flags = install ? "--json" : "--check --json"
        let script = "cd \(shq(repoRoot)) && exec node --import tsx runtime/node-host/src/import.ts \(shq(path)) \(flags)"

        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/bin/sh")
        proc.arguments = ["-c", script]
        let out = Pipe()
        let err = Pipe()
        proc.standardOutput = out
        proc.standardError = err
        do { try proc.run() } catch { return .failure(ImportError("Couldn't start node — is it on PATH? (\(error.localizedDescription))")) }
        let outData = out.fileHandleForReading.readDataToEndOfFile()
        let errData = err.fileHandleForReading.readDataToEndOfFile()
        proc.waitUntilExit()

        guard proc.terminationStatus == 0 else {
            let msg = (String(data: errData, encoding: .utf8) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            return .failure(ImportError(msg.isEmpty ? "Import failed (exit \(proc.terminationStatus))" : msg))
        }
        // The JSON object is the only/last stdout line.
        let lines = (String(data: outData, encoding: .utf8) ?? "").split(separator: "\n").map(String.init)
        guard let jsonLine = lines.last(where: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("{") }),
              let data = jsonLine.data(using: .utf8),
              let report = try? JSONDecoder().decode(ImportReport.self, from: data) else {
            return .failure(ImportError("Couldn't parse the import report"))
        }
        return .success(report)
    }
}
