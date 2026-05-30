import AppKit
import Carbon.HIToolbox
import InvokeRenderer

/// App lifecycle + summon (PLAN.md §4.3). Owns the warm palette window and the extension host that
/// streams a LIVE extension's render mutations into the view models over framed IPC (§4.6/§4.7),
/// the keyboard selection model, and the global Option-Space summon hotkey (§3.2).
public final class AppController: NSObject, NSApplicationDelegate {
    private let palette = PaletteWindow()
    private let host = ExtensionHost()
    private let hotkey = GlobalHotkey()
    private var selectedIndex = 0

    public override init() { super.init() }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        host.onLog = { message in print("[invoke:host] \(message)") }
        host.onCommit = { [weak self] _ in self?.rerender() }

        palette.onSearchChange = { [weak self] text in
            self?.selectedIndex = 0
            self?.host.setSearchText(text)
        }
        palette.onMove = { [weak self] delta in self?.moveSelection(delta) }
        palette.onActivate = { [weak self] secondary in self?.activateSelection(secondary: secondary) }
        palette.onCancel = { [weak self] in self?.palette.toggle() }

        let root = ProcessInfo.processInfo.environment["INVOKE_REPO_ROOT"]
            ?? Self.findRepoRoot()
            ?? FileManager.default.currentDirectoryPath
        print("[invoke:host] repo root: \(root)")

        host.launch(repoRoot: root, entryRelPath: "examples/hello-world/src/list.tsx", command: "list")

        // Global summon: ⌥Space toggles the palette (§3.2 Carbon fast path — no Accessibility grant).
        hotkey.register(keyCode: UInt32(kVK_Space), modifiers: UInt32(optionKey)) { [weak self] in
            self?.palette.toggle()
        }
        print("[invoke:host] global hotkey registered: ⌥Space")

        palette.show()
    }

    public func applicationWillTerminate(_ notification: Notification) {
        hotkey.unregister()
        host.terminate()
    }

    // MARK: - Selection model

    /// Re-render, clamping the selection to the current item count.
    private func rerender() {
        let count = items().count
        if selectedIndex >= count { selectedIndex = max(0, count - 1) }
        palette.render(host.tree, selectedIndex: selectedIndex)
    }

    private func moveSelection(_ delta: Int) {
        let count = items().count
        guard count > 0 else { return }
        selectedIndex = min(max(0, selectedIndex + delta), count - 1)
        palette.render(host.tree, selectedIndex: selectedIndex)
    }

    private func activateSelection(secondary: Bool) {
        let rows = items()
        guard selectedIndex < rows.count else { return }
        let actions = self.actions(under: rows[selectedIndex])
        guard !actions.isEmpty else { return }
        let action = (secondary && actions.count > 1) ? actions[1] : actions[0]

        if let handler = action.props["onAction"]?.handlerRef {
            host.invoke(handler: handler) // e.g. Pin → setState in the extension → re-render
        } else if action.props["variant"]?.stringValue == "copy",
                  let content = action.props["content"]?.stringValue {
            let pb = NSPasteboard.general
            pb.clearContents()
            pb.setString(content, forType: .string)
            print("[invoke:host] copied to clipboard: \(content)")
        }
    }

    /// List items in pre-order — the same order PaletteView assigns its highlight indices.
    private func items() -> [ViewNode] {
        var out: [ViewNode] = []
        func walk(_ n: ViewNode) {
            if n.type == "list-item" { out.append(n) }
            for c in n.children { walk(c) }
        }
        walk(host.tree.root)
        return out
    }

    /// The `action` nodes under an item's ActionPanel, in declared order (primary first).
    private func actions(under item: ViewNode) -> [ViewNode] {
        var out: [ViewNode] = []
        func walk(_ n: ViewNode) {
            if n.type == "action" { out.append(n) }
            for c in n.children { walk(c) }
        }
        walk(item)
        return out
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
