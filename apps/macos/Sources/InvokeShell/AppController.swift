import AppKit
import InvokeRenderer

/// App lifecycle + summon (PLAN.md §4.3). Owns the warm palette window and the extension host that
/// streams a LIVE extension's render mutations into the view models over framed IPC (§4.6/§4.7).
/// The global CGEvent-tap summon hotkey (§3.2) lands next; for now the palette shows on launch.
public final class AppController: NSObject, NSApplicationDelegate {
    private let palette = PaletteWindow()
    private let host = ExtensionHost()

    public override init() { super.init() }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        host.onLog = { message in print("[invoke:host] \(message)") }
        host.onCommit = { [weak self] commit in
            guard let self else { return }
            self.palette.render(self.host.tree)
            print("[invoke:host] commit \(commit) applied:\n\(self.host.tree.describe())")
        }
        // Typing in the palette drives the extension's onSearchTextChange → re-render → mutations.
        palette.onSearchChange = { [weak self] text in self?.host.setSearchText(text) }

        let root = ProcessInfo.processInfo.environment["INVOKE_REPO_ROOT"]
            ?? Self.findRepoRoot()
            ?? FileManager.default.currentDirectoryPath
        print("[invoke:host] repo root: \(root)")

        // Launch the bundled example as a live `view` command — its UI streams into the palette.
        host.launch(repoRoot: root, entryRelPath: "examples/hello-world/src/list.tsx", command: "list")
        palette.show()
    }

    public func applicationWillTerminate(_ notification: Notification) {
        host.terminate()
    }

    /// Walk up from the cwd to find the invoke-v2 working dir (the one holding the Node runtime).
    private static func findRepoRoot() -> String? {
        let fm = FileManager.default
        var dir = fm.currentDirectoryPath
        for _ in 0..<10 {
            if fm.fileExists(atPath: dir + "/runtime/node-host/src/child.ts") { return dir }
            let parent = (dir as NSString).deletingLastPathComponent
            if parent == dir || parent.isEmpty { break }
            dir = parent
        }
        return nil
    }
}
