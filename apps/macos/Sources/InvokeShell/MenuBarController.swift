import AppKit
import InvokeIPC
import InvokeRenderer

/// Hosts `menu-bar` command-mode extensions as macOS menu-bar status items (Raycast parity).
///
/// A menu-bar command renders a `MenuBarExtra` tree continuously; the extension process stays alive and
/// streams mutations like a view command, but instead of a palette surface we render the tree into an
/// `NSStatusItem` + `NSMenu`. Item clicks invoke the item's `onAction` handler back in the child; the
/// extension's host capabilities (open, clipboard, fetch in trusted mode, …) route through the same
/// `handleCapability` path the palette uses, via the injected `capability` closures.
final class MenuBarController {
    private final class Entry {
        let host: ExtensionHost
        let statusItem: NSStatusItem
        let extKey: String
        var actions: [MenuItemAction] = [] // retained per render (NSMenuItem.target is weak)
        init(host: ExtensionHost, statusItem: NSStatusItem, extKey: String) {
            self.host = host; self.statusItem = statusItem; self.extKey = extKey
        }
    }

    private var entries: [String: Entry] = [:] // keyed by cmdId
    private let repoRoot: String

    /// Sync capability bridge into AppController (scopes currentExtId to `extKey`, then dispatches).
    var capability: ((_ extKey: String, _ method: String, _ params: JSONValue?) -> JSONValue)?
    /// Async capability bridge (confirmAlert / ai.ask / oauth.authorize).
    var capabilityAsync: ((_ extKey: String, _ method: String, _ params: JSONValue?, _ reply: @escaping (JSONValue) -> Void, _ fail: @escaping (String) -> Void) -> Bool)?
    /// Virtual-fs bridge (fd 4) into AppController, scoped to the menu-bar extension's key + private dirs.
    var fs: ((_ extKey: String, _ op: String, _ params: JSONValue?, _ supportPath: String, _ assetsPath: String) -> JSONValue)?

    init(repoRoot: String) { self.repoRoot = repoRoot }

    func isShowing(_ cmdId: String) -> Bool { entries[cmdId] != nil }

    /// Toggle a menu-bar command: if already shown, remove it; otherwise launch it.
    func toggle(cmdId: String, extKey: String, entryRelPath: String, command: String,
                preferences: String, trusted: Bool, assetsPath: String, supportPath: String) {
        if entries[cmdId] != nil { remove(cmdId); return }
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "…" // placeholder until the first commit
        print("[invoke:menubar] created status item for \(cmdId) (button=\(statusItem.button != nil))")
        let host = ExtensionHost()
        let entry = Entry(host: host, statusItem: statusItem, extKey: extKey)
        entries[cmdId] = entry
        host.onCommit = { [weak self] _ in self?.rebuild(cmdId) }
        host.onCapability = { [weak self] m, p in self?.capability?(extKey, m, p) ?? .null }
        host.onCapabilityAsync = { [weak self] m, p, reply, fail in self?.capabilityAsync?(extKey, m, p, reply, fail) ?? false }
        host.onFS = { [weak self] op, params in
            self?.fs?(extKey, op, params, supportPath, assetsPath)
                ?? .object(["error": .string("[invoke:fs] host unavailable"), "code": .string("EIO")])
        }
        // A menu-bar command renders once and its process EXITS (Raycast model — the menu is then static
        // until refreshed/clicked). Do NOT remove the status item when the child ends; keep showing the
        // rendered menu. The status item is removed only by an explicit toggle-off / "Remove from Menu Bar".
        host.onTerminate = {}
        host.onLog = { msg in print("[invoke:menubar:\(command)] \(msg)") }
        host.launch(repoRoot: repoRoot, entryRelPath: entryRelPath, command: command, preferences: preferences,
                    mode: "menu-bar", trusted: trusted, assetsPath: assetsPath, supportPath: supportPath)
    }

    func remove(_ cmdId: String) {
        guard let e = entries.removeValue(forKey: cmdId) else { return }
        e.host.terminate()
        NSStatusBar.system.removeStatusItem(e.statusItem)
    }

    func removeAll() { for id in Array(entries.keys) { remove(id) } }

    // MARK: - Rendering the tree → NSStatusItem + NSMenu

    private func rebuild(_ cmdId: String) {
        guard let entry = entries[cmdId] else { print("[invoke:menubar] rebuild: no entry for \(cmdId)"); return }
        // The extension renders a single MenuBarExtra at the surface root.
        guard let mb = firstNode(entry.host.tree.root, type: "menubar-extra") else {
            print("[invoke:menubar] rebuild: no menubar-extra node yet (root has \(entry.host.tree.root.children.count) children: \(entry.host.tree.root.children.map { $0.type }))")
            return
        }
        let fullTitle = mb.props["title"]?.stringValue ?? ""
        let iconStr = mb.props["icon"]?.stringValue

        // Keep the status-bar button COMPACT so it stays visible on a crowded / notched menu bar (a long
        // title gets pushed under the notch and vanishes). Priority: SF-symbol icon → emoji icon → a
        // short title (capped). The full title always appears as a header at the top of the dropdown.
        if let icon = iconStr, let img = NSImage(systemSymbolName: icon, accessibilityDescription: nil) {
            entry.statusItem.button?.title = ""
            entry.statusItem.button?.image = img // an SF symbol
        } else if let icon = iconStr, !icon.isEmpty, icon.unicodeScalars.contains(where: { $0.properties.isEmoji && $0.value > 0x238C }) {
            entry.statusItem.button?.image = nil
            entry.statusItem.button?.title = icon // an emoji — narrow + always visible
        } else if !fullTitle.isEmpty {
            entry.statusItem.button?.image = nil
            entry.statusItem.button?.title = fullTitle.count > 20 ? String(fullTitle.prefix(19)) + "…" : fullTitle
        } else {
            entry.statusItem.button?.title = "●"
        }

        let menu = NSMenu()
        entry.actions = []
        // Full title as a header so the (possibly long) text is readable even when the button is compact.
        if !fullTitle.isEmpty {
            let header = NSMenuItem(title: fullTitle, action: nil, keyEquivalent: ""); header.isEnabled = false
            menu.addItem(header); menu.addItem(.separator())
        }
        appendChildren(of: mb, to: menu, entry: entry)

        // Standard footer: remove this menu-bar command.
        menu.addItem(.separator())
        let quit = MenuItemAction(title: "Remove from Menu Bar") { [weak self] in self?.remove(cmdId) }
        entry.actions.append(quit)
        menu.addItem(quit.menuItem)

        entry.statusItem.menu = menu
    }

    /// Map a node's children to menu items. Handles item / section / submenu / separator.
    private func appendChildren(of node: ViewNode, to menu: NSMenu, entry: Entry) {
        for child in node.children {
            switch child.type {
            case "menubar-item":
                menu.addItem(makeItem(child, entry: entry))
            case "menubar-separator":
                menu.addItem(.separator())
            case "menubar-section":
                // A titled group: a separator, an optional disabled header, then its items.
                if menu.items.last != nil, menu.items.last?.isSeparatorItem == false { menu.addItem(.separator()) }
                if let title = child.props["title"]?.stringValue, !title.isEmpty {
                    let header = NSMenuItem(title: title, action: nil, keyEquivalent: "")
                    header.isEnabled = false
                    menu.addItem(header)
                }
                appendChildren(of: child, to: menu, entry: entry)
            case "menubar-submenu":
                let item = NSMenuItem(title: child.props["title"]?.stringValue ?? child.title ?? "", action: nil, keyEquivalent: "")
                let sub = NSMenu()
                appendChildren(of: child, to: sub, entry: entry)
                item.submenu = sub
                menu.addItem(item)
            default:
                break
            }
        }
    }

    private func makeItem(_ node: ViewNode, entry: Entry) -> NSMenuItem {
        let title = node.props["title"]?.stringValue ?? node.title ?? ""
        if let handler = node.props["onAction"]?.handlerRef {
            let action = MenuItemAction(title: title) { [weak host = entry.host] in host?.invoke(handler: handler) }
            // Subtitle (Raycast shows it dimmed) — append in parens if present.
            if let sub = node.props["subtitle"]?.stringValue, !sub.isEmpty { action.menuItem.title = "\(title)  —  \(sub)" }
            entry.actions.append(action)
            return action.menuItem
        }
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false // a non-actionable item (e.g. a status label)
        return item
    }

    private func firstNode(_ node: ViewNode, type: String) -> ViewNode? {
        if node.type == type { return node }
        for c in node.children { if let r = firstNode(c, type: type) { return r } }
        return nil
    }
}

/// A retained target for an NSMenuItem (NSMenuItem.target is weak, so the closure holder must be kept).
final class MenuItemAction: NSObject {
    let menuItem: NSMenuItem
    private let block: () -> Void
    init(title: String, _ block: @escaping () -> Void) {
        self.block = block
        self.menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        super.init()
        self.menuItem.target = self
        self.menuItem.action = #selector(fire)
    }
    @objc private func fire() { block() }
}
