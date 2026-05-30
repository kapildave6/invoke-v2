import AppKit
import Carbon.HIToolbox
import InvokeIPC
import InvokeRenderer
import InvokeServices

/// App lifecycle + summon + root search (PLAN.md §4.3). Owns the warm palette window, the keyboard
/// selection model, the ⌥Space summon hotkey (§3.2), and the root ranker that routes a query to
/// either native Applications results or the running Calculator extension's card.
///
/// `rootTree` set → the host is showing a NATIVE result tree (apps / message); nil → it's showing
/// the running extension's tree (the calculator). `activeTree` is whichever is on screen.
public final class AppController: NSObject, NSApplicationDelegate {
    private let palette = PaletteWindow()
    private let host = ExtensionHost()
    private let hotkey = GlobalHotkey()
    private let appIndex = AppIndexService()
    private var selectedIndex = 0
    private var rootTree: ViewTree?

    private var activeTree: ViewTree { rootTree ?? host.tree }

    public override init() { super.init() }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Standard editing shortcuts (⌘A/⌘C/⌘V/⌘X/⌘Z) reach the search field only via the main
        // menu's key-equivalents; a menu-less .accessory app has none, so install a minimal one.
        NSApp.mainMenu = Self.makeMainMenu()

        host.onLog = { message in print("[invoke:host] \(message)") }
        // Only render the calculator's commits while it owns the screen (calc mode).
        host.onCommit = { [weak self] _ in
            guard let self, self.rootTree == nil else { return }
            self.rerender()
        }
        // Extension-initiated feedback (showToast / showHUD via the @invoke/api RPC) → toast capsule.
        host.onRpc = { [weak self] method, params in
            guard let self, method == "toast.show" || method == "hud.show" else { return }
            let title = Self.objString(params, "title") ?? ""
            let message = Self.objString(params, "message")
            let text = message.map { "\(title) — \($0)" } ?? title
            if !text.isEmpty { self.palette.showToast(text) }
        }

        palette.onSearchChange = { [weak self] text in self?.onSearch(text) }
        palette.onMove = { [weak self] delta in self?.moveSelection(delta) }
        palette.onActivate = { [weak self] secondary in self?.activateSelection(secondary: secondary) }
        palette.onCancel = { [weak self] in self?.palette.hide() }
        palette.actionsProvider = { [weak self] in self?.currentActions() ?? [] }

        let root = ProcessInfo.processInfo.environment["INVOKE_REPO_ROOT"]
            ?? Self.findRepoRoot()
            ?? FileManager.default.currentDirectoryPath
        print("[invoke:host] repo root: \(root)")

        // The Calculator runs as a resident extension; root search forwards calc-like queries to it.
        let entry = ProcessInfo.processInfo.environment["INVOKE_EXT_ENTRY"] ?? "examples/calculator/src/calculate.tsx"
        let command = ProcessInfo.processInfo.environment["INVOKE_EXT_COMMAND"] ?? "calculate"
        host.launch(repoRoot: root, entryRelPath: entry, command: command)

        appIndex.build()
        print("[invoke:host] app index: \(appIndex.count) applications")

        hotkey.register(keyCode: UInt32(kVK_Space), modifiers: UInt32(optionKey)) { [weak self] in
            self?.palette.toggle()
        }
        print("[invoke:host] global hotkey registered: ⌥Space")

        renderApps(query: "") // initial root state
        palette.show()
    }

    public func applicationWillTerminate(_ notification: Notification) {
        hotkey.unregister()
        host.terminate()
    }

    // MARK: - Root routing

    private func onSearch(_ text: String) {
        selectedIndex = 0
        if Self.looksLikeCalculation(text) {
            rootTree = nil               // hand the screen to the calculator extension
            host.setSearchText(text)     // its commit renders via onCommit
        } else {
            renderApps(query: text)      // native, instant
        }
    }

    private func renderApps(query: String) {
        let q = query.trimmingCharacters(in: .whitespaces)
        if q.isEmpty {
            rootTree = ViewTree() // empty → compact window, just the search bar
        } else {
            let entries = appIndex.search(q)
            rootTree = entries.isEmpty ? Self.messageTree("No matching apps") : Self.appsTree(entries)
        }
        selectedIndex = 0
        palette.render(activeTree, selectedIndex: selectedIndex)
        updateActionBar()
    }

    // MARK: - Selection model

    private func rerender() {
        palette.dismissMenu()
        let count = items().count
        if selectedIndex >= count { selectedIndex = max(0, count - 1) }
        palette.render(activeTree, selectedIndex: selectedIndex)
        updateActionBar()
    }

    private func moveSelection(_ delta: Int) {
        let count = items().count
        guard count > 0 else { return }
        selectedIndex = min(max(0, selectedIndex + delta), count - 1)
        palette.render(activeTree, selectedIndex: selectedIndex)
        updateActionBar()
    }

    private func activateSelection(secondary: Bool) {
        let acts = currentActions()
        guard !acts.isEmpty else { return }
        (secondary && acts.count > 1 ? acts[1] : acts[0]).run()
    }

    private func updateActionBar() {
        let title = rootTree == nil ? "Calculator" : "Invoke"
        palette.setActionBar(command: title, primary: currentActions().first?.title)
    }

    /// Actions for the selected result — an "Open" launch for app rows, else the extension's actions.
    private func currentActions() -> [PaletteAction] {
        let rows = items()
        guard selectedIndex < rows.count else { return [] }
        let item = rows[selectedIndex]
        if let path = item.props["appPath"]?.stringValue {
            let name = item.props["title"]?.stringValue ?? "App"
            return [PaletteAction(title: "Open", shortcut: "↵") { [weak self] in self?.launchApp(path, name: name) }]
        }
        return actions(under: item).enumerated().map { index, node in
            PaletteAction(
                title: title(for: node),
                shortcut: index == 0 ? "↵" : (index == 1 ? "⌘↵" : nil)
            ) { [weak self] in self?.perform(node) }
        }
    }

    private func launchApp(_ path: String, name: String) {
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
        palette.hide()           // launching closes the palette (standard launcher behavior)
        palette.clearSearch()
        rootTree = ViewTree()
        selectedIndex = 0
        palette.render(activeTree, selectedIndex: 0)
    }

    /// Run an extension action node: invoke its handler over IPC, or perform a native action (copy).
    private func perform(_ action: ViewNode) {
        if let handler = action.props["onAction"]?.handlerRef {
            host.invoke(handler: handler)
        } else if action.props["variant"]?.stringValue == "copy",
                  let content = action.props["content"]?.stringValue {
            let pb = NSPasteboard.general
            pb.clearContents()
            pb.setString(content, forType: .string)
            palette.showToast("Copied to Clipboard")
        }
    }

    // MARK: - Tree walking / native tree builders

    private func items() -> [ViewNode] {
        var out: [ViewNode] = []
        func walk(_ n: ViewNode) {
            if n.type == "list-item" { out.append(n) }
            for c in n.children { walk(c) }
        }
        walk(activeTree.root)
        return out
    }

    private func actions(under item: ViewNode) -> [ViewNode] {
        var out: [ViewNode] = []
        func walk(_ n: ViewNode) {
            if n.type == "action" { out.append(n) }
            for c in n.children { walk(c) }
        }
        walk(item)
        return out
    }

    private static func appsTree(_ entries: [AppEntry]) -> ViewTree {
        let tree = ViewTree()
        let list = ViewNode(id: 1, type: "list")
        let section = ViewNode(id: 2, type: "list-section", props: ["title": .string("Applications")])
        var id = 100
        for e in entries {
            section.children.append(ViewNode(id: id, type: "list-item", props: [
                "title": .string(e.name),
                "subtitle": .string("Application"),
                "appPath": .string(e.path),
            ]))
            id += 1
        }
        list.children.append(section)
        tree.root.children = [list]
        return tree
    }

    /// A non-selectable message (rendered as a section header).
    private static func messageTree(_ message: String) -> ViewTree {
        let tree = ViewTree()
        tree.root.children = [ViewNode(id: 1, type: "list-section", props: ["title": .string(message)])]
        return tree
    }

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

    // MARK: - Helpers

    /// Heuristic: does the query look like a calculation (→ Calculator) vs an app search?
    private static func looksLikeCalculation(_ q: String) -> Bool {
        let t = q.trimmingCharacters(in: .whitespaces)
        if t.isEmpty { return false }
        if t.contains("(") { return true } // sqrt(16), (3+4)*5
        if t.range(of: "^[-+]?[0-9.,]+$", options: .regularExpression) != nil { return true } // pure number
        let hasDigit = t.range(of: "[0-9]", options: .regularExpression) != nil
        if hasDigit, t.range(of: "[-+*/^%]", options: .regularExpression) != nil { return true } // 2+2, 50% of …
        if t.range(of: "(?i)^[0-9.,]+\\s*[a-z°]+\\s+(in|to|as)\\s+[a-z°]+$", options: .regularExpression) != nil {
            return true // 10 km in mi, 100 usd in eur
        }
        return false
    }

    private static func objString(_ v: JSONValue?, _ key: String) -> String? {
        if case .object(let o)? = v { return o[key]?.stringValue }
        return nil
    }

    private static func makeMainMenu() -> NSMenu {
        let main = NSMenu()

        let appItem = NSMenuItem()
        main.addItem(appItem)
        let appMenu = NSMenu()
        appItem.submenu = appMenu
        appMenu.addItem(withTitle: "Quit Invoke", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        let editItem = NSMenuItem()
        main.addItem(editItem)
        let editMenu = NSMenu(title: "Edit")
        editItem.submenu = editMenu
        editMenu.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        let redo = editMenu.addItem(withTitle: "Redo", action: Selector(("redo:")), keyEquivalent: "z")
        redo.keyEquivalentModifierMask = [.command, .shift]
        editMenu.addItem(.separator())
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        return main
    }

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
