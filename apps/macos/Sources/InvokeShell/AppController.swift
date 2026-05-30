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
    private let commandTitle = "Hello World"

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
        palette.actionsProvider = { [weak self] in self?.currentActions() ?? [] }
        palette.setActionBar(command: commandTitle, primary: nil)

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

    /// Re-render, clamping the selection to the current item count, and refresh the action bar.
    private func rerender() {
        palette.dismissMenu() // close any open Action Panel so it can't act on a stale tree
        let count = items().count
        if selectedIndex >= count { selectedIndex = max(0, count - 1) }
        palette.render(host.tree, selectedIndex: selectedIndex)
        updateActionBar()
    }

    private func moveSelection(_ delta: Int) {
        let count = items().count
        guard count > 0 else { return }
        selectedIndex = min(max(0, selectedIndex + delta), count - 1)
        palette.render(host.tree, selectedIndex: selectedIndex)
        updateActionBar()
    }

    /// Enter = primary action, ⌘Enter = secondary.
    private func activateSelection(secondary: Bool) {
        let acts = currentActions()
        guard !acts.isEmpty else { return }
        (secondary && acts.count > 1 ? acts[1] : acts[0]).run()
    }

    private func updateActionBar() {
        palette.setActionBar(command: commandTitle, primary: currentActions().first?.title)
    }

    /// Build the runnable actions for the selected result (primary first).
    private func currentActions() -> [PaletteAction] {
        let rows = items()
        guard selectedIndex < rows.count else { return [] }
        let nodes = actions(under: rows[selectedIndex])
        return nodes.enumerated().map { index, node in
            PaletteAction(
                title: title(for: node),
                shortcut: index == 0 ? "↵" : (index == 1 ? "⌘↵" : nil)
            ) { [weak self] in self?.perform(node) }
        }
    }

    /// Run a single action node: invoke its handler over IPC, or perform a native action (copy).
    private func perform(_ action: ViewNode) {
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

    /// Display title for an action node (explicit title, else a default for the variant).
    private func title(for action: ViewNode) -> String {
        if let explicit = action.props["title"]?.stringValue { return explicit }
        switch action.props["variant"]?.stringValue {
        case "copy": return "Copy to Clipboard"
        case "paste": return "Paste"
        case "open-in-browser": return "Open in Browser"
        case "open", "push": return "Open"
        default: return "Run Action"
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
