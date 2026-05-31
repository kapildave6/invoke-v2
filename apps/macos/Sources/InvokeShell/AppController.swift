import AppKit
import ApplicationServices
import Carbon.HIToolbox
import CoreGraphics
import InvokeIPC
import InvokeRenderer
import InvokeServices

/// App lifecycle + summon + the root ranker (PLAN.md §4.3). Composes ONE result tree from several
/// sources — Applications (native index), built-in Commands (registry), and the resident Calculator
/// extension's card — ranked by frecency, and rendered through the shared PaletteView. Owns the
/// keyboard selection model and the ⌥Space summon hotkey (§3.2).
public final class AppController: NSObject, NSApplicationDelegate {
    private let palette = PaletteWindow()
    private let host = ExtensionHost()
    private let hotkey = GlobalHotkey()
    private let appIndex = AppIndexService()
    private let frecency = Frecency()
    private let clipboard = ClipboardHistory()
    private let windowManager = WindowManager()
    private let screenshots = ScreenshotIndex()
    private let snippetStore = SnippetStore.shared
    private let quicklinkStore = QuicklinkStore.shared
    private let settingsWindow = SettingsWindow()
    private lazy var commands: [RootCommand] = makeCommands()

    private enum Mode { case root, clipboard, emoji, screenshots, snippets, quicklinks, extensionView }
    private var mode: Mode = .root
    private var clipKind = "All Types" // clipboard type filter
    private var pendingQuicklink: Quicklink? // quicklink awaiting its {query} argument (input sub-mode)
    private var pasteTarget: NSRunningApplication? // app to paste back into
    private static let defaultPlaceholder = "Search for apps and commands…"

    // A third-party extension running as a full palette surface (separate from the resident
    // calculator `host`). Launched on demand from a discovered `ext.*` command; rendered in .extension.
    private var extHost: ExtensionHost?
    private var currentExtId = ""
    private var currentExtTitle = ""
    private var repoRoot = ""
    private var selectedIndex = 0
    private var rootTree: ViewTree?
    private var lastQuery = ""
    private var activeTree: ViewTree {
        if mode == .extensionView, let extHost { return extHost.tree }
        return rootTree ?? host.tree
    }

    /// A built-in command in the root registry.
    private struct RootCommand {
        let id: String
        let title: String
        let subtitle: String
        let runTitle: String
        let icon: String       // SF Symbol
        let keywords: [String]
        let closesPalette: Bool // folder-opens close; "navigating" commands (clipboard) keep it open
        let run: () -> Void
    }

    public override init() { super.init() }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        if let icon = Brand.appIcon { NSApp.applicationIconImage = icon } // shows in system dialogs
        NSApp.mainMenu = makeMainMenu()

        host.onLog = { message in print("[invoke:host] \(message)") }
        host.onCommit = { [weak self] _ in
            // Only the root shows the calculator card — guard the mode so an async FX-rate commit
            // can't clobber a sub-mode list (Snippets/Clipboard/etc.) whose query looks like math.
            guard let self, self.mode == .root, Self.looksLikeCalculation(self.lastQuery) else { return }
            self.renderRoot(calcCard: self.extractCalcCard())
        }
        host.onCapability = { [weak self] method, params in self?.handleCapability(method, params) ?? .null }

        palette.onSearchChange = { [weak self] text in self?.onSearch(text) }
        palette.onMove = { [weak self] delta in self?.moveSelection(delta) }
        palette.onActivate = { [weak self] secondary in self?.activateSelection(secondary: secondary) }
        palette.onCancel = { [weak self] in
            guard let self else { return }
            if self.pendingQuicklink != nil {
                self.cancelQuicklinkInput() // back to the quicklink list, not all the way to root
            } else if self.mode != .root {
                self.exitToRoot()
            } else {
                self.palette.hide()
            }
        }
        palette.actionsProvider = { [weak self] in self?.currentActions() ?? [] }
        palette.onFilterChange = { [weak self] kind in
            guard let self else { return }
            self.clipKind = kind
            self.selectedIndex = 0
            self.renderClipboard(query: self.lastQuery)
        }
        palette.onSelectRow = { [weak self] i in self?.setSelection(i) }
        palette.onActivateRow = { [weak self] i in self?.clickActivate(i) }

        let root = ProcessInfo.processInfo.environment["INVOKE_REPO_ROOT"]
            ?? Self.findRepoRoot()
            ?? FileManager.default.currentDirectoryPath
        repoRoot = root // discovered extensions are resolved relative to this
        print("[invoke:host] repo root: \(root)")

        let entry = ProcessInfo.processInfo.environment["INVOKE_EXT_ENTRY"] ?? "examples/calculator/src/calculate.tsx"
        let command = ProcessInfo.processInfo.environment["INVOKE_EXT_COMMAND"] ?? "calculate"
        host.launch(repoRoot: root, entryRelPath: entry, command: command)

        appIndex.build()
        clipboard.start()
        clipboard.capacity = AppSettings.shared.clipboardLimit
        print("[invoke:host] app index: \(appIndex.count) applications · \(commands.count) commands")

        // ⌥Space summons the root; ⌘⇧V opens Clipboard History directly (Raycast parity).
        hotkey.register(id: 1, keyCode: UInt32(kVK_Space), modifiers: UInt32(optionKey)) { [weak self] in
            self?.summonToggle()
        }
        hotkey.register(id: 2, keyCode: UInt32(kVK_ANSI_V), modifiers: UInt32(cmdKey | shiftKey)) { [weak self] in
            self?.openClipboardHotkey()
        }
        // Window management on the current frontmost app: ⌃⌥← / → / ↑.
        let winMods = UInt32(controlKey | optionKey)
        hotkey.register(id: 3, keyCode: UInt32(kVK_LeftArrow), modifiers: winMods) { [weak self] in
            self?.applyWindow(.leftHalf, pid: NSWorkspace.shared.frontmostApplication?.processIdentifier)
        }
        hotkey.register(id: 4, keyCode: UInt32(kVK_RightArrow), modifiers: winMods) { [weak self] in
            self?.applyWindow(.rightHalf, pid: NSWorkspace.shared.frontmostApplication?.processIdentifier)
        }
        hotkey.register(id: 5, keyCode: UInt32(kVK_UpArrow), modifiers: winMods) { [weak self] in
            self?.applyWindow(.maximize, pid: NSWorkspace.shared.frontmostApplication?.processIdentifier)
        }
        print("[invoke:host] global hotkeys: ⌥Space · ⌘⇧V · ⌃⌥←/→/↑ (windows)")
        // Reserve the fixed combos so the recorder won't let a command shadow them (Carbon would
        // drop the duplicate registration silently).
        AppSettings.reservedCombos = [
            AppSettings.comboKey(keyCode: UInt32(kVK_Space), modifiers: UInt32(optionKey)),
            AppSettings.comboKey(keyCode: UInt32(kVK_ANSI_V), modifiers: UInt32(cmdKey | shiftKey)),
            AppSettings.comboKey(keyCode: UInt32(kVK_LeftArrow), modifiers: winMods),
            AppSettings.comboKey(keyCode: UInt32(kVK_RightArrow), modifiers: winMods),
            AppSettings.comboKey(keyCode: UInt32(kVK_UpArrow), modifiers: winMods),
        ]
        AppSettings.shared.reconcileLaunchAtLogin() // didSet is skipped for the in-init assignment
        reloadCommandHotkeys() // user-assigned per-command hotkeys from Settings

        renderRoot(calcCard: nil) // initial: Suggestions
        palette.show()
    }

    public func applicationWillTerminate(_ notification: Notification) {
        hotkey.unregister()
        host.terminate()
        extHost?.terminate()
    }

    // MARK: - Root routing / composition

    private func onSearch(_ text: String) {
        lastQuery = text
        selectedIndex = 0
        if mode == .clipboard { renderClipboard(query: text); return }
        if mode == .emoji { renderEmoji(query: text); return }
        if mode == .screenshots { renderScreenshots(query: text); return }
        if mode == .snippets { renderSnippets(query: text); return }
        if mode == .quicklinks {
            if pendingQuicklink != nil { renderQuicklinkPrompt() } else { renderQuicklinks(query: text) }
            return
        }
        if mode == .extensionView { extHost?.setSearchText(text); return } // re-render arrives via onCommit
        if Self.looksLikeCalculation(text) { host.setSearchText(text) } // card arrives via onCommit
        renderRoot(calcCard: nil)
    }

    private func enterEmoji() {
        mode = .emoji
        lastQuery = ""
        palette.clearSearch()
        palette.setPlaceholder("Search emoji & symbols…")
        selectedIndex = 0
        renderEmoji(query: "")
    }

    private func renderEmoji(query: String) {
        rootTree = buildEmoji(query: query)
        let count = items().count
        if selectedIndex >= count { selectedIndex = max(0, count - 1) }
        palette.hideFilter()
        palette.render(activeTree, selectedIndex: selectedIndex)
        updateActionBar()
    }

    private func buildEmoji(query: String) -> ViewTree {
        let tree = ViewTree()
        let list = ViewNode(id: 1, type: "list")
        var nid = 10
        func item(_ em: EmojiData.Emoji) -> ViewNode {
            nid += 1
            let display = Self.applySkinTone(em.char)
            return ViewNode(id: nid, type: "list-item", props: [
                "title": .string(em.name.capitalized),
                "glyph": .string(display),
                "insertText": .string(display),
                "frecencyKey": .string("emoji:\(em.char)"), // keyed on the base char so recents are tone-stable
            ])
        }
        func section(_ title: String, _ children: [ViewNode]) -> ViewNode {
            nid += 1
            let s = ViewNode(id: nid, type: "list-section", props: ["title": .string(title)])
            s.children = children
            return s
        }
        let q = query.trimmingCharacters(in: .whitespaces)
        var sections: [ViewNode] = []
        if q.isEmpty {
            let recents = frecency.topIds(limit: 8)
                .filter { $0.hasPrefix("emoji:") }
                .compactMap { EmojiData.emoji(forChar: String($0.dropFirst(6))) }
            if !recents.isEmpty { sections.append(section("Recently Used", recents.map(item))) }
            sections.append(section("Emoji", EmojiData.all.map(item)))
        } else {
            let results = EmojiData.search(q)
            sections = results.isEmpty
                ? [section("No emoji found", [])]
                : [section("Emoji", results.map(item))]
        }
        list.children = sections
        tree.root.children = [list]
        return tree
    }

    /// ⌥Space: toggle the palette, always resetting to the root when summoning.
    private func summonToggle() {
        if palette.isVisible { palette.hide() } else { captureTarget(); exitToRoot(); palette.show() }
    }

    /// ⌘⇧V: summon straight into Clipboard History.
    private func openClipboardHotkey() {
        captureTarget()
        palette.show()
        enterClipboard()
    }

    /// Move/resize a window via Accessibility (target = palette's previous app, or the frontmost
    /// app for the global hotkeys). Prompts for the grant if missing.
    private func applyWindow(_ action: WindowManager.Action, pid: pid_t?) {
        guard AXIsProcessTrusted() else {
            Self.promptAccessibility()
            palette.showToast("Enable Accessibility for Invoke to manage windows")
            return
        }
        if let pid { windowManager.apply(action, pid: pid) }
    }

    /// Remember the app that had focus when summoned, so we can paste back into it.
    private func captureTarget() {
        let front = NSWorkspace.shared.frontmostApplication
        if front?.processIdentifier != ProcessInfo.processInfo.processIdentifier { pasteTarget = front }
    }

    private func enterClipboard() {
        mode = .clipboard
        clipboard.capacity = AppSettings.shared.clipboardLimit
        clipKind = "All Types"
        lastQuery = ""
        palette.clearSearch()
        palette.setPlaceholder("Search clipboard history…")
        selectedIndex = 0
        renderClipboard(query: "")
    }

    private func exitToRoot() {
        teardownExtension()
        mode = .root
        pendingQuicklink = nil
        palette.hideFilter()
        palette.setPlaceholder(Self.defaultPlaceholder)
        lastQuery = ""
        palette.clearSearch()
        selectedIndex = 0
        renderRoot(calcCard: nil)
    }

    private func renderClipboard(query: String) {
        let count = clipboard.entries(matching: query, kind: clipKind).count
        if selectedIndex >= count { selectedIndex = max(0, count - 1) }
        rootTree = buildClipboard(query: query, selectedIndex: selectedIndex)
        palette.render(activeTree, selectedIndex: selectedIndex)
        palette.setFilter(options: clipboard.availableKinds(), selected: clipKind)
        updateActionBar()
    }

    private func buildClipboard(query: String, selectedIndex: Int) -> ViewTree {
        let tree = ViewTree()
        let list = ViewNode(id: 1, type: "list")
        let entries = clipboard.entries(matching: query, kind: clipKind)
        if entries.isEmpty {
            let msg = query.trimmingCharacters(in: .whitespaces).isEmpty
                ? "Clipboard history is empty — copy something"
                : "No matching clips"
            list.children = [ViewNode(id: 2, type: "list-section", props: ["title": .string(msg)])]
        } else {
            list.props["showDetail"] = .bool(true) // master–detail layout
            let section = ViewNode(id: 2, type: "list-section", props: ["title": .string("Today")])
            var nid = 10
            for (i, clip) in entries.enumerated() {
                nid += 1
                var props: [String: JSONValue] = [
                    "clipKey": .string(clip.key), // actions look the real clip up by key
                    "metadata": Self.clipMetadata(clip),
                ]
                switch clip.kind {
                case "File":
                    props["title"] = .string((clip.filePath.map { ($0 as NSString).lastPathComponent }) ?? "File")
                    if let p = clip.filePath { props["fileIcon"] = .string(p) }
                    // Image files show a preview (not just the path) in the detail pane.
                    if i == selectedIndex, let p = clip.filePath, Self.isImagePath(p),
                       let data = try? Data(contentsOf: URL(fileURLWithPath: p)) {
                        props["thumb"] = .string(Self.thumbBase64(data, maxDim: 480))
                    } else {
                        props["detailText"] = .string(clip.text)
                    }
                case "Image":
                    let dims = clip.imageW.map { "\($0)×\(clip.imageH ?? 0)" } ?? ""
                    props["title"] = .string("Image \(dims)")
                    props["icon"] = .string("photo")
                    if i == selectedIndex, let data = clip.imageData { // thumbnail only for the shown item
                        props["thumb"] = .string(Self.thumbBase64(data))
                    }
                default: // Text / Link
                    props["title"] = .string(Self.preview(clip.text))
                    props["icon"] = .string(clip.kind == "Link" ? "link" : "doc.on.clipboard")
                    props["detailText"] = .string(clip.text)
                }
                section.children.append(ViewNode(id: nid, type: "list-item", props: props))
            }
            list.children = [section]
        }
        tree.root.children = [list]
        return tree
    }

    /// Emojis that accept a skin-tone modifier (the hand/gesture set we ship).
    private static let skinnable: Set<String> = ["👍", "👎", "👌", "✌️", "🤞", "🙏", "👏", "🙌", "💪", "👋", "🤝"]
    private static func applySkinTone(_ char: String) -> String {
        guard let mod = AppSettings.shared.skinToneModifier, skinnable.contains(char) else { return char }
        return char + mod
    }

    private static func isImagePath(_ path: String) -> Bool {
        ["png", "jpg", "jpeg", "gif", "heic", "heif", "tiff", "bmp", "webp"].contains((path as NSString).pathExtension.lowercased())
    }

    /// Downscaled base64 PNG thumbnail for the detail pane (the full image stays in ClipboardHistory).
    private static func thumbBase64(_ data: Data, maxDim: CGFloat = 360) -> String {
        guard let img = NSImage(data: data) else { return data.base64EncodedString() }
        let size = img.size
        let scale = min(1, maxDim / max(size.width, size.height))
        guard scale < 1 else { return data.base64EncodedString() }
        let target = NSSize(width: size.width * scale, height: size.height * scale)
        let thumb = NSImage(size: target)
        thumb.lockFocus()
        img.draw(in: NSRect(origin: .zero, size: target))
        thumb.unlockFocus()
        guard let tiff = thumb.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff),
              let png = rep.representation(using: .png, properties: [:]) else { return data.base64EncodedString() }
        return png.base64EncodedString()
    }

    /// "Information" rows for a clip's detail pane.
    private static func clipMetadata(_ clip: ClipboardHistory.Clip) -> JSONValue {
        var rows: [JSONValue] = [.object(["label": .string("Content type"), "value": .string(clip.kind)])]
        switch clip.kind {
        case "File":
            if let p = clip.filePath {
                rows.append(.object(["label": .string("Path"), "value": .string((p as NSString).abbreviatingWithTildeInPath)]))
            }
            if let sz = clip.fileSize {
                rows.append(.object(["label": .string("File size"), "value": .string(ByteCountFormatter.string(fromByteCount: Int64(sz), countStyle: .file))]))
            }
        case "Image":
            if let w = clip.imageW, let h = clip.imageH {
                rows.append(.object(["label": .string("Dimensions"), "value": .string("\(w) × \(h)")]))
            }
            if let sz = clip.fileSize {
                rows.append(.object(["label": .string("Size"), "value": .string(ByteCountFormatter.string(fromByteCount: Int64(sz), countStyle: .file))]))
            }
        default:
            let chars = clip.text.count
            let words = clip.text.split(whereSeparator: { $0 == " " || $0.isNewline }).filter { !$0.isEmpty }.count
            rows.append(.object(["label": .string("Characters"), "value": .string("\(chars)")]))
            rows.append(.object(["label": .string("Words"), "value": .string("\(words)")]))
        }
        rows.append(.object(["label": .string("Times copied"), "value": .string("\(clip.timesCopied)")]))
        if let src = clip.source { rows.append(.object(["label": .string("Source"), "value": .string(src)])) }
        rows.append(.object(["label": .string("Last copied"), "value": .string(relativeTime(clip.date))]))
        return .array(rows)
    }

    // MARK: - Screenshots

    private func enterScreenshots() {
        mode = .screenshots
        lastQuery = ""
        palette.clearSearch()
        palette.setPlaceholder("Search screenshots…")
        selectedIndex = 0
        renderScreenshots(query: "")
    }

    private func renderScreenshots(query: String) {
        let count = screenshots.search(query).count
        if selectedIndex >= count { selectedIndex = max(0, count - 1) }
        rootTree = buildScreenshots(query: query, selectedIndex: selectedIndex)
        palette.hideFilter()
        palette.render(activeTree, selectedIndex: selectedIndex)
        updateActionBar()
    }

    private func buildScreenshots(query: String, selectedIndex: Int) -> ViewTree {
        let tree = ViewTree()
        let list = ViewNode(id: 1, type: "list")
        let shots = screenshots.search(query)
        if shots.isEmpty {
            let msg = query.trimmingCharacters(in: .whitespaces).isEmpty ? "No screenshots found" : "No matching screenshots"
            list.children = [ViewNode(id: 2, type: "list-section", props: ["title": .string(msg)])]
        } else {
            list.props["showDetail"] = .bool(true)
            let section = ViewNode(id: 2, type: "list-section", props: ["title": .string("Screenshots & Recordings  \(shots.count)")])
            var nid = 10
            for (i, shot) in shots.enumerated() {
                nid += 1
                var props: [String: JSONValue] = [
                    "title": .string(Self.relativeTime(shot.date)),
                    "subtitle": .string(shot.name),
                    "fileIcon": .string(shot.path),
                    "fileToPaste": .string(shot.path),
                    "metadata": Self.screenshotMetadata(shot),
                ]
                if i == selectedIndex, let data = try? Data(contentsOf: URL(fileURLWithPath: shot.path)) {
                    props["thumb"] = .string(Self.thumbBase64(data, maxDim: 480))
                }
                section.children.append(ViewNode(id: nid, type: "list-item", props: props))
            }
            list.children = [section]
        }
        tree.root.children = [list]
        return tree
    }

    private static func screenshotMetadata(_ shot: ScreenshotIndex.Shot) -> JSONValue {
        var rows: [JSONValue] = [
            .object(["label": .string("Content type"), "value": .string(shot.path.hasSuffix(".mov") ? "Recording" : "Image")]),
            .object(["label": .string("Size"), "value": .string(ByteCountFormatter.string(fromByteCount: Int64(shot.size), countStyle: .file))]),
            .object(["label": .string("Path"), "value": .string((shot.path as NSString).abbreviatingWithTildeInPath)]),
        ]
        rows.append(.object(["label": .string("Created"), "value": .string(relativeTime(shot.date))]))
        return .array(rows)
    }

    // MARK: - Snippets

    private func enterSnippets() {
        mode = .snippets
        lastQuery = ""
        palette.clearSearch()
        palette.setPlaceholder("Search snippets…")
        selectedIndex = 0
        renderSnippets(query: "")
    }

    private func renderSnippets(query: String) {
        let count = snippetStore.search(query).count
        if selectedIndex >= count { selectedIndex = max(0, count - 1) }
        rootTree = buildSnippets(query: query)
        palette.hideFilter()
        palette.render(activeTree, selectedIndex: selectedIndex)
        updateActionBar()
    }

    private func buildSnippets(query: String) -> ViewTree {
        let tree = ViewTree()
        let list = ViewNode(id: 1, type: "list")
        let items = snippetStore.search(query)
        if items.isEmpty {
            let msg = query.trimmingCharacters(in: .whitespaces).isEmpty
                ? "No snippets yet — create one in Settings (⌘,)"
                : "No matching snippets"
            list.children = [ViewNode(id: 2, type: "list-section", props: ["title": .string(msg)])]
        } else {
            list.props["showDetail"] = .bool(true) // master–detail: content preview on the right
            let section = ViewNode(id: 2, type: "list-section", props: ["title": .string("Snippets  \(items.count)")])
            var nid = 10
            for s in items {
                nid += 1
                var props: [String: JSONValue] = [
                    "title": .string(s.name.isEmpty ? "Untitled Snippet" : s.name),
                    "icon": .string("text.quote"),
                    "snippetKey": .string(s.id),
                    "detailText": .string(s.content),
                    "metadata": Self.snippetMetadata(s),
                ]
                if !s.keyword.isEmpty { props["accessories"] = .array([.object(["tag": .string(s.keyword)])]) }
                section.children.append(ViewNode(id: nid, type: "list-item", props: props))
            }
            list.children = [section]
        }
        tree.root.children = [list]
        return tree
    }

    private static func snippetMetadata(_ s: Snippet) -> JSONValue {
        var rows: [JSONValue] = []
        if !s.keyword.isEmpty { rows.append(.object(["label": .string("Keyword"), "value": .string(s.keyword)])) }
        let words = s.content.split(whereSeparator: { $0 == " " || $0.isNewline }).filter { !$0.isEmpty }.count
        rows.append(.object(["label": .string("Characters"), "value": .string("\(s.content.count)")]))
        rows.append(.object(["label": .string("Words"), "value": .string("\(words)")]))
        return .array(rows)
    }

    // MARK: - Quicklinks

    private func enterQuicklinks() {
        mode = .quicklinks
        pendingQuicklink = nil
        lastQuery = ""
        palette.clearSearch()
        palette.setPlaceholder("Search quicklinks…")
        selectedIndex = 0
        renderQuicklinks(query: "")
    }

    private func renderQuicklinks(query: String) {
        let count = quicklinkStore.search(query).count
        if selectedIndex >= count { selectedIndex = max(0, count - 1) }
        rootTree = buildQuicklinks(query: query)
        palette.hideFilter()
        palette.render(activeTree, selectedIndex: selectedIndex)
        updateActionBar()
    }

    private func buildQuicklinks(query: String) -> ViewTree {
        let tree = ViewTree()
        let list = ViewNode(id: 1, type: "list")
        let items = quicklinkStore.search(query)
        if items.isEmpty {
            let msg = query.trimmingCharacters(in: .whitespaces).isEmpty
                ? "No quicklinks yet — create one in Settings (⌘,)"
                : "No matching quicklinks"
            list.children = [ViewNode(id: 2, type: "list-section", props: ["title": .string(msg)])]
        } else {
            let section = ViewNode(id: 2, type: "list-section", props: ["title": .string("Quicklinks")])
            var nid = 10
            for q in items {
                nid += 1
                section.children.append(ViewNode(id: nid, type: "list-item", props: [
                    "title": .string(q.name.isEmpty ? q.link : q.name),
                    "subtitle": .string(q.link),
                    "icon": .string("link"),
                    "quicklinkKey": .string(q.id),
                    "accessories": .array([.object(["text": .string(q.hasArgument ? "Quicklink · input" : "Quicklink")])]),
                ]))
            }
            list.children = [section]
        }
        tree.root.children = [list]
        return tree
    }

    /// A quicklink with a {query} placeholder: enter an input sub-mode where the search field becomes
    /// the argument and Enter opens the substituted URL.
    private func beginQuicklinkInput(_ ql: Quicklink) {
        pendingQuicklink = ql
        lastQuery = ""
        palette.clearSearch()
        palette.setPlaceholder("Enter input for \(ql.name)…")
        selectedIndex = 0
        renderQuicklinkPrompt()
    }

    private func cancelQuicklinkInput() {
        pendingQuicklink = nil
        lastQuery = ""
        palette.clearSearch()
        palette.setPlaceholder("Search quicklinks…")
        selectedIndex = 0
        renderQuicklinks(query: "")
    }

    private func renderQuicklinkPrompt() {
        rootTree = buildQuicklinkPrompt()
        selectedIndex = 0
        palette.hideFilter()
        palette.render(activeTree, selectedIndex: 0)
        updateActionBar()
    }

    private func buildQuicklinkPrompt() -> ViewTree {
        let tree = ViewTree()
        let list = ViewNode(id: 1, type: "list")
        if let ql = pendingQuicklink {
            let preview = ql.resolvedURL(argument: lastQuery)?.absoluteString ?? ql.link
            let section = ViewNode(id: 2, type: "list-section", props: ["title": .string("Open \(ql.name)")])
            section.children = [ViewNode(id: 10, type: "list-item", props: [
                "title": .string(lastQuery.isEmpty ? "Type your input, then press ↵" : lastQuery),
                "subtitle": .string(preview),
                "icon": .string("link"),
            ])]
            list.children = [section]
        }
        tree.root.children = [list]
        return tree
    }

    private func openQuicklink(_ ql: Quicklink, argument: String) {
        guard let url = ql.resolvedURL(argument: argument) else {
            palette.showToast("Invalid link")
            return
        }
        NSWorkspace.shared.open(url)
        afterLaunch()
    }

    private func renderRoot(calcCard: ViewNode?) {
        rootTree = buildRoot(query: lastQuery, calcCard: calcCard)
        let count = items().count
        if selectedIndex >= count { selectedIndex = max(0, count - 1) }
        palette.render(activeTree, selectedIndex: selectedIndex)
        updateActionBar()
    }

    /// Compose one tree: [Calculator card] + (empty query → Suggestions; else Applications + Commands).
    private func buildRoot(query: String, calcCard: ViewNode?) -> ViewTree {
        let tree = ViewTree()
        let list = ViewNode(id: 1, type: "list")
        var nid = 10
        let nextId: () -> Int = { nid += 1; return nid }
        func sectionNode(_ title: String, _ children: [ViewNode]) -> ViewNode {
            let s = ViewNode(id: nextId(), type: "list-section", props: ["title": .string(title)])
            s.children = children
            return s
        }

        var sections: [ViewNode] = []
        let q = query.trimmingCharacters(in: .whitespaces)

        if let calcCard, AppSettings.shared.isEnabled("calculator") { sections.append(sectionNode("Calculator", [calcCard])) }

        if q.isEmpty {
            let suggestions = suggestionItems(nextId: nextId)
            if !suggestions.isEmpty { sections.append(sectionNode("Suggestions", suggestions)) }
            // Always list every enabled command (Raycast-style), scrollable.
            let cmds = commands.filter { AppSettings.shared.isEnabled($0.id) }.map {
                itemNode(id: nextId(), title: $0.title, subtitle: $0.subtitle, kind: "Command", appPath: nil, icon: $0.icon, commandId: $0.id, alias: AppSettings.shared.alias(for: $0.id))
            }
            sections.append(sectionNode("Commands", cmds))
        } else {
            let matched = matchCommands(q) // exact-alias matches sorted first
            // If the query exactly matches a configured alias, that command must be the FIRST result
            // overall — so put Commands above Applications (otherwise apps lead, as usual).
            let aliasFirst = matched.first.flatMap { AppSettings.shared.alias(for: $0.id) } == q.lowercased()

            let appItems = appIndex.search(q).map {
                itemNode(id: nextId(), title: $0.name, subtitle: nil, kind: "Application", appPath: $0.path, icon: nil, commandId: nil)
            }
            let cmdItems = matched.map {
                itemNode(id: nextId(), title: $0.title, subtitle: $0.subtitle, kind: "Command", appPath: nil, icon: $0.icon, commandId: $0.id, alias: AppSettings.shared.alias(for: $0.id))
            }
            let appsSection = appItems.isEmpty ? nil : sectionNode("Applications", appItems)
            let cmdsSection = cmdItems.isEmpty ? nil : sectionNode("Commands", cmdItems)

            let ordered = aliasFirst ? [cmdsSection, appsSection] : [appsSection, cmdsSection]
            sections.append(contentsOf: ordered.compactMap { $0 })
        }

        list.children = sections
        tree.root.children = [list]
        return tree
    }

    /// Empty-root suggestions: top-frecency items, or the command registry before any usage data.
    private func suggestionItems(nextId: () -> Int) -> [ViewNode] {
        let ids = frecency.hasData ? frecency.topIds(limit: 7) : commands.filter { AppSettings.shared.isEnabled($0.id) }.map { "cmd:\($0.id)" }
        var out: [ViewNode] = []
        for id in ids {
            if id.hasPrefix("cmd:"), let c = commands.first(where: { "cmd:\($0.id)" == id }) {
                out.append(itemNode(id: nextId(), title: c.title, subtitle: c.subtitle, kind: "Command", appPath: nil, icon: c.icon, commandId: c.id, alias: AppSettings.shared.alias(for: c.id)))
            } else if id.hasPrefix("app:") {
                let path = String(id.dropFirst(4))
                guard FileManager.default.fileExists(atPath: path) else { continue }
                let name = ((path as NSString).lastPathComponent as NSString).deletingPathExtension
                out.append(itemNode(id: nextId(), title: name, subtitle: nil, kind: "Application", appPath: path, icon: nil, commandId: nil))
            }
        }
        return out
    }

    private func matchCommands(_ q: String) -> [RootCommand] {
        let ql = q.lowercased()
        let settings = AppSettings.shared
        let enabled = commands.filter { settings.isEnabled($0.id) }
        func aliasOf(_ c: RootCommand) -> String? { settings.alias(for: c.id) }
        // An exact alias match wins outright (typing "wm" jumps straight to that command).
        let exact = enabled.filter { aliasOf($0) == ql }
        let rest = enabled
            .filter { c in
                aliasOf(c) != ql &&
                (c.title.lowercased().contains(ql)
                    || c.keywords.contains { $0.contains(ql) }
                    || (aliasOf(c).map { $0.contains(ql) } ?? false))
            }
            .sorted { frecency.score("cmd:\($0.id)") > frecency.score("cmd:\($1.id)") }
        return exact + rest
    }

    private func itemNode(id: Int, title: String, subtitle: String?, kind: String, appPath: String?, icon: String?, commandId: String?, alias: String? = nil) -> ViewNode {
        var accessories: [JSONValue] = []
        if let alias, !alias.isEmpty { accessories.append(.object(["tag": .string(alias)])) }
        accessories.append(.object(["text": .string(kind)]))
        var props: [String: JSONValue] = [
            "title": .string(title),
            "accessories": .array(accessories),
        ]
        if let subtitle, !subtitle.isEmpty { props["subtitle"] = .string(subtitle) }
        if let appPath { props["appPath"] = .string(appPath) }
        if let icon { props["icon"] = .string(icon) }
        if let commandId { props["commandId"] = .string(commandId) }
        return ViewNode(id: id, type: "list-item", props: props)
    }

    // MARK: - Selection / activation

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
        switch mode {
        case .clipboard: renderClipboard(query: lastQuery)      // rebuild so detail thumbnail follows
        case .screenshots: renderScreenshots(query: lastQuery)  // ditto
        case .snippets: renderSnippets(query: lastQuery)        // rebuild so the detail pane follows
        default:
            palette.render(activeTree, selectedIndex: selectedIndex)
            updateActionBar()
        }
    }

    /// Mouse single-click: select the clicked item index, re-rendering per mode (like arrow keys).
    private func setSelection(_ i: Int) {
        let count = items().count
        guard count > 0 else { return }
        selectedIndex = min(max(0, i), count - 1)
        switch mode {
        case .clipboard: renderClipboard(query: lastQuery)
        case .screenshots: renderScreenshots(query: lastQuery)
        case .snippets: renderSnippets(query: lastQuery)
        default:
            palette.render(activeTree, selectedIndex: selectedIndex)
            updateActionBar()
        }
    }

    /// Mouse double-click: select then run the primary action.
    private func clickActivate(_ i: Int) {
        setSelection(i)
        activateSelection(secondary: false)
    }

    private func activateSelection(secondary: Bool) {
        if let ql = pendingQuicklink { openQuicklink(ql, argument: lastQuery); return } // confirm input
        let acts = currentActions()
        guard !acts.isEmpty else { return }
        (secondary && acts.count > 1 ? acts[1] : acts[0]).run()
    }

    private func updateActionBar() {
        let label: String
        switch mode {
        case .clipboard: label = "Clipboard History"
        case .emoji: label = "Emoji & Symbols"
        case .screenshots: label = "Screenshots"
        case .snippets: label = "Snippets"
        case .quicklinks: label = pendingQuicklink?.name ?? "Quicklinks"
        case .extensionView: label = currentExtTitle
        case .root: label = "Invoke"
        }
        let primary = pendingQuicklink != nil ? "Open" : currentActions().first?.title
        palette.setActionBar(command: label, primary: primary)
    }

    /// Actions for the selected row: launch an app, run a command (both bump frecency), or the
    /// extension's own actions (the calculator card's Copy).
    private func currentActions() -> [PaletteAction] {
        let rows = items()
        guard selectedIndex < rows.count else { return [] }
        let node = rows[selectedIndex]

        if mode == .extensionView { return extensionActions(under: node) }

        if let path = node.props["appPath"]?.stringValue {
            return [PaletteAction(title: "Open", shortcut: "↵") { [weak self] in
                self?.frecency.bump("app:\(path)")
                NSWorkspace.shared.open(URL(fileURLWithPath: path))
                self?.afterLaunch()
            }]
        }
        if let text = node.props["insertText"]?.stringValue {
            let key = node.props["frecencyKey"]?.stringValue
            return [
                PaletteAction(title: pasteTitle(), shortcut: "↵") { [weak self] in
                    if let key { self?.frecency.bump(key) }
                    self?.pasteText(text)
                },
                PaletteAction(title: "Copy", shortcut: "⌘↵") { [weak self] in
                    if let key { self?.frecency.bump(key) }
                    self?.copyText(text)
                },
            ]
        }
        if let path = node.props["fileToPaste"]?.stringValue {
            return [
                PaletteAction(title: pasteTitle(), shortcut: "↵") { [weak self] in self?.pasteImageFile(path) },
                PaletteAction(title: "Copy to Clipboard", shortcut: "⌘↵") { [weak self] in self?.copyImageFile(path) },
            ]
        }
        if let key = node.props["clipKey"]?.stringValue, let clip = clipboard.clip(forKey: key) {
            let copyTitle = clip.kind == "File" ? "Copy File" : (clip.kind == "Image" ? "Copy Image" : "Copy to Clipboard")
            return [
                PaletteAction(title: pasteTitle(), shortcut: "↵") { [weak self] in self?.pasteOrCopyClip(clip) },
                PaletteAction(title: copyTitle, shortcut: "⌘↵") { [weak self] in self?.copyClip(clip) },
            ]
        }
        if let sid = node.props["snippetKey"]?.stringValue, let snip = snippetStore.snippet(id: sid) {
            return [
                PaletteAction(title: pasteTitle(), shortcut: "↵") { [weak self] in self?.pasteText(snip.content) },
                PaletteAction(title: "Copy", shortcut: "⌘↵") { [weak self] in self?.copyText(snip.content) },
            ]
        }
        if let qid = node.props["quicklinkKey"]?.stringValue, let ql = quicklinkStore.quicklink(id: qid) {
            return [PaletteAction(title: ql.hasArgument ? "Open with Input…" : "Open", shortcut: "↵") { [weak self] in
                if ql.hasArgument { self?.beginQuicklinkInput(ql) } else { self?.openQuicklink(ql, argument: "") }
            }]
        }
        if let cid = node.props["commandId"]?.stringValue, let cmd = commands.first(where: { $0.id == cid }) {
            return [PaletteAction(title: cmd.runTitle, shortcut: "↵") { [weak self] in
                self?.frecency.bump("cmd:\(cid)")
                cmd.run()
                if cmd.closesPalette { self?.afterLaunch() }
            }]
        }
        return actions(under: node).enumerated().map { index, n in
            PaletteAction(title: title(for: n), shortcut: index == 0 ? "↵" : (index == 1 ? "⌘↵" : nil)) { [weak self] in self?.perform(n) }
        }
    }

    /// Launching/running closes the palette and resets to a clean root for the next summon — from any
    /// mode (so opening a quicklink / running a snippet doesn't leave us stuck in that mode).
    private func afterLaunch() {
        palette.hide()
        teardownExtension()
        mode = .root
        pendingQuicklink = nil
        palette.hideFilter()
        palette.setPlaceholder(Self.defaultPlaceholder)
        palette.clearSearch()
        lastQuery = ""
        selectedIndex = 0
        renderRoot(calcCard: nil)
    }

    private func pasteTitle() -> String {
        pasteTarget?.localizedName.map { "Paste to \($0)" } ?? "Paste"
    }

    private func setPasteboard(_ clip: ClipboardHistory.Clip) {
        let pb = NSPasteboard.general
        pb.clearContents()
        switch clip.kind {
        case "File": if let p = clip.filePath { pb.writeObjects([URL(fileURLWithPath: p) as NSURL]) }
        case "Image": if let d = clip.imageData, let img = NSImage(data: d) { pb.writeObjects([img]) }
        default: pb.setString(clip.text, forType: .string)
        }
    }

    private func copyClip(_ clip: ClipboardHistory.Clip) {
        setPasteboard(clip)
        palette.showToast(clip.kind == "Image" ? "Copied Image" : (clip.kind == "File" ? "Copied File" : "Copied to Clipboard"))
    }

    private func pasteText(_ text: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(text, forType: .string)
        guard AXIsProcessTrusted() else {
            Self.promptAccessibility()
            palette.showToast("Enable Accessibility for Invoke to paste — copied instead")
            return
        }
        let target = pasteTarget
        palette.hide()
        target?.activate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { Self.synthesizePaste() }
        exitToRoot() // reset mode/selection so the next summon is clean
    }

    private func copyText(_ text: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(text, forType: .string)
        palette.showToast("Copied")
    }

    private func setPasteboardImageFile(_ path: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        if let img = NSImage(contentsOfFile: path) { pb.writeObjects([img]) }
        else { pb.writeObjects([URL(fileURLWithPath: path) as NSURL]) }
    }

    private func copyImageFile(_ path: String) {
        setPasteboardImageFile(path)
        palette.showToast("Copied to Clipboard")
    }

    private func pasteImageFile(_ path: String) {
        setPasteboardImageFile(path)
        guard AXIsProcessTrusted() else {
            Self.promptAccessibility()
            palette.showToast("Enable Accessibility for Invoke to paste — copied instead")
            return
        }
        let target = pasteTarget
        palette.hide()
        target?.activate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { Self.synthesizePaste() }
        exitToRoot()
    }

    /// Set the clipboard, then (if Accessibility is granted) close the palette, refocus the target
    /// app, and synthesize ⌘V — otherwise fall back to copy-only and prompt for the grant.
    private func pasteOrCopyClip(_ clip: ClipboardHistory.Clip) {
        setPasteboard(clip)
        guard AXIsProcessTrusted() else {
            Self.promptAccessibility()
            palette.showToast("Enable Accessibility for Invoke to paste — copied instead")
            return
        }
        let target = pasteTarget
        palette.hide()
        target?.activate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { Self.synthesizePaste() }
        exitToRoot() // reset mode/selection so the next summon is clean
    }

    private static func promptAccessibility() {
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(opts)
    }

    private static func synthesizePaste() {
        let src = CGEventSource(stateID: .combinedSessionState)
        let v: CGKeyCode = 9 // kVK_ANSI_V
        let down = CGEvent(keyboardEventSource: src, virtualKey: v, keyDown: true)
        down?.flags = .maskCommand
        let up = CGEvent(keyboardEventSource: src, virtualKey: v, keyDown: false)
        up?.flags = .maskCommand
        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }

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

    // MARK: - Tree walking

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

    private func extractCalcCard() -> ViewNode? {
        func find(_ n: ViewNode) -> ViewNode? {
            if n.type == "list-item", n.props["display"]?.stringValue == "card" { return n }
            for c in n.children { if let f = find(c) { return f } }
            return nil
        }
        return find(host.tree.root)
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

    // MARK: - Extensions (third-party surfaces, PLAN §5)

    /// Native fulfilment of the allowlisted host capabilities — the Swift counterpart of the dev
    /// runner's Node `devCapabilities`. Shared by the resident calculator and any running extension.
    private func handleCapability(_ method: String, _ params: JSONValue?) -> JSONValue {
        func arg(_ key: String) -> JSONValue? {
            if case .object(let o)? = params { return o[key] }
            return nil
        }
        switch method {
        case "toast.show", "hud.show":
            let title = arg("title")?.stringValue ?? ""
            let message = arg("message")?.stringValue
            let text = message.map { "\(title) — \($0)" } ?? title
            if !text.isEmpty { palette.showToast(text) }
            return .null
        case "open":
            if let target = arg("target")?.stringValue { openTarget(target) }
            return .null
        case "clipboard.copy":
            setStringPasteboard(arg("content")?.stringValue ?? "")
            return .null
        case "clipboard.paste":
            setStringPasteboard(arg("content")?.stringValue ?? "")
            if AXIsProcessTrusted() {
                pasteTarget?.activate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { Self.synthesizePaste() }
            }
            return .null
        case "clipboard.readText":
            return .string(NSPasteboard.general.string(forType: .string) ?? "")
        case "window.close":
            palette.hide()
            return .null
        case "preferences.get":
            return .object([:]) // preferences are delivered via INVOKE_PREFERENCES (env), read synchronously
        case "localStorage.getItem":
            return extStorageGet(arg("key")?.stringValue ?? "").map { JSONValue.string($0) } ?? .null
        case "localStorage.setItem":
            extStorageSet(arg("key")?.stringValue ?? "", value: arg("value").map(Self.jsonScalarString) ?? "")
            return .null
        case "localStorage.removeItem":
            extStorageRemove(arg("key")?.stringValue ?? "")
            return .null
        case "localStorage.clear":
            extStorageClear()
            return .null
        case "localStorage.allItems":
            return .object(extStorageAll().mapValues { JSONValue.string($0) })
        default:
            return .null
        }
    }

    private func setStringPasteboard(_ s: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(s, forType: .string)
    }

    private func openTarget(_ target: String) {
        if let url = URL(string: target), url.scheme != nil { NSWorkspace.shared.open(url) }
        else { NSWorkspace.shared.open(URL(fileURLWithPath: (target as NSString).expandingTildeInPath)) }
    }

    private static func jsonScalarString(_ v: JSONValue) -> String {
        switch v {
        case .string(let s): return s
        case .number(let n): return n == n.rounded() ? String(Int(n)) : String(n)
        case .bool(let b): return b ? "true" : "false"
        default: return ""
        }
    }

    // Per-extension LocalStorage, namespaced by extension id in UserDefaults.
    private func extStorageDefaultsKey() -> String { "invoke.ext.ls.\(currentExtId)" }
    private func extStorageAll() -> [String: String] { (UserDefaults.standard.dictionary(forKey: extStorageDefaultsKey()) as? [String: String]) ?? [:] }
    private func extStorageGet(_ key: String) -> String? { extStorageAll()[key] }
    private func extStorageSet(_ key: String, value: String) { var d = extStorageAll(); d[key] = value; UserDefaults.standard.set(d, forKey: extStorageDefaultsKey()) }
    private func extStorageRemove(_ key: String) { var d = extStorageAll(); d[key] = nil; UserDefaults.standard.set(d, forKey: extStorageDefaultsKey()) }
    private func extStorageClear() { UserDefaults.standard.removeObject(forKey: extStorageDefaultsKey()) }

    /// Scan `examples/*` for extension manifests and surface their `view` commands in the root
    /// (the calculator is excluded — it's the resident card provider). Dev discovery; a real install
    /// dir + the store come later.
    private func discoverExtensionCommands() -> [RootCommand] {
        let fm = FileManager.default
        let examplesDir = repoRoot + "/examples"
        guard let names = try? fm.contentsOfDirectory(atPath: examplesDir) else { return [] }
        var out: [RootCommand] = []
        for name in names.sorted() where name != "calculator" {
            let extDir = examplesDir + "/" + name
            guard let data = fm.contents(atPath: extDir + "/package.json"),
                  let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                  let title = json["title"] as? String,
                  let cmds = json["commands"] as? [[String: Any]] else { continue }
            let prefsJSON = Self.manifestPreferencesJSON(json)
            for c in cmds {
                guard let cname = c["name"] as? String,
                      ((c["mode"] as? String) ?? "view") == "view" else { continue }
                let ctitle = (c["title"] as? String) ?? cname
                guard let rel = ["tsx", "ts", "jsx", "js"].lazy
                    .map({ "examples/\(name)/src/\(cname).\($0)" })
                    .first(where: { fm.fileExists(atPath: repoRoot + "/" + $0) }) else { continue }
                let cmdId = "ext.\(name).\(cname)"
                out.append(RootCommand(id: cmdId, title: ctitle, subtitle: title, runTitle: "Open",
                                       icon: "puzzlepiece.extension.fill", keywords: [name, cname, title.lowercased()],
                                       closesPalette: false) { [weak self] in
                    self?.launchExtension(id: cmdId, title: ctitle, entryRelPath: rel, command: cname, preferences: prefsJSON)
                })
            }
        }
        return out
    }

    private static func manifestPreferencesJSON(_ json: [String: Any]) -> String {
        guard let prefs = json["preferences"] as? [[String: Any]] else { return "{}" }
        var dict: [String: Any] = [:]
        for p in prefs { if let n = p["name"] as? String, let def = p["default"] { dict[n] = def } }
        guard let data = try? JSONSerialization.data(withJSONObject: dict),
              let s = String(data: data, encoding: .utf8) else { return "{}" }
        return s
    }

    /// Launch a discovered extension into a full palette surface (.extension mode), in its own process.
    private func launchExtension(id: String, title: String, entryRelPath: String, command: String, preferences: String) {
        teardownExtension()
        let h = ExtensionHost()
        h.onLog = { msg in print("[invoke:ext] \(msg)") }
        h.onCommit = { [weak self] _ in self?.onExtensionCommit() }
        h.onCapability = { [weak self] m, p in self?.handleCapability(m, p) ?? .null }
        extHost = h
        currentExtId = id
        currentExtTitle = title
        captureTarget()
        mode = .extensionView
        lastQuery = ""
        palette.clearSearch()
        palette.setPlaceholder("Search \(title)…")
        selectedIndex = 0
        if !palette.isVisible { palette.show() } // launched from an open palette → don't re-center it
        renderExtensionLoading() // placeholder until the first commit (avoids an empty collapse-flash)
        h.launch(repoRoot: repoRoot, entryRelPath: entryRelPath, command: command, preferences: preferences)
    }

    /// A one-row "Loading…" surface shown between launch and the extension's first render commit.
    private func renderExtensionLoading() {
        let tree = ViewTree()
        let list = ViewNode(id: 1, type: "list")
        list.children = [ViewNode(id: 2, type: "list-section", props: ["title": .string("Loading \(currentExtTitle)…")])]
        tree.root.children = [list]
        palette.render(tree, selectedIndex: 0)
        updateActionBar()
    }

    private func teardownExtension() {
        extHost?.terminate()
        extHost = nil
        currentExtId = ""
        currentExtTitle = ""
    }

    private func onExtensionCommit() {
        guard mode == .extensionView else { return }
        renderExtension()
    }

    private func renderExtension() {
        let count = items().count
        if selectedIndex >= count { selectedIndex = max(0, count - 1) }
        palette.render(activeTree, selectedIndex: selectedIndex)
        updateActionBar()
    }

    /// Actions for the selected extension row. Extension-driven actions (onAction) re-enter the child;
    /// declarative ones (open-in-browser/copy/paste) are fulfilled natively.
    private func extensionActions(under node: ViewNode) -> [PaletteAction] {
        actions(under: node).enumerated().map { i, n in
            PaletteAction(title: title(for: n), shortcut: i == 0 ? "↵" : (i == 1 ? "⌘↵" : nil)) { [weak self] in
                self?.runExtensionAction(n)
            }
        }
    }

    private func runExtensionAction(_ n: ViewNode) {
        if let handler = n.props["onAction"]?.handlerRef {
            extHost?.invoke(handler: handler) // stays open; re-renders on the next commit
            return
        }
        switch n.props["variant"]?.stringValue {
        case "open-in-browser":
            if let url = n.props["url"]?.stringValue { openTarget(url) }
            afterLaunch()
        case "copy":
            setStringPasteboard(n.props["content"]?.stringValue ?? "")
            palette.showToast("Copied to Clipboard")
            afterLaunch()
        case "paste":
            setStringPasteboard(n.props["content"]?.stringValue ?? "")
            if AXIsProcessTrusted() {
                let target = pasteTarget
                target?.activate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { Self.synthesizePaste() }
            } else {
                Self.promptAccessibility()
                palette.showToast("Enable Accessibility to paste — copied instead")
            }
            afterLaunch() // tear down on BOTH paths (unlike pasteText's no-AX early return)
        default:
            afterLaunch()
        }
    }

    // MARK: - Commands

    private func makeCommands() -> [RootCommand] {
        func openPath(_ p: String) -> () -> Void {
            let url = URL(fileURLWithPath: (p as NSString).expandingTildeInPath)
            return { NSWorkspace.shared.open(url) }
        }
        func windowCommand(_ id: String, _ title: String, _ icon: String, _ kw: [String], _ action: WindowManager.Action) -> RootCommand {
            RootCommand(id: id, title: title, subtitle: "Window Management", runTitle: title, icon: icon, keywords: ["window"] + kw, closesPalette: true) { [weak self] in
                self?.applyWindow(action, pid: self?.pasteTarget?.processIdentifier)
            }
        }
        func shell(_ tool: String, _ args: [String]) -> () -> Void {
            return { [weak self] in
                DispatchQueue.global(qos: .userInitiated).async { // never block the UI
                    guard FileManager.default.isExecutableFile(atPath: tool) else {
                        DispatchQueue.main.async { self?.palette.showToast("Command unavailable") }
                        return
                    }
                    let p = Process()
                    p.executableURL = URL(fileURLWithPath: tool)
                    p.arguments = args
                    do { try p.run() } catch {
                        DispatchQueue.main.async { self?.palette.showToast("Command failed") }
                    }
                }
            }
        }
        return [
            RootCommand(id: "clipboard.history", title: "Clipboard History", subtitle: "Clipboard History", runTitle: "Open", icon: "doc.on.clipboard", keywords: ["clipboard", "history", "paste", "copy"], closesPalette: false) { [weak self] in self?.enterClipboard() },
            RootCommand(id: "emoji.picker", title: "Search Emoji & Symbols", subtitle: "Emoji & Symbols", runTitle: "Open", icon: "face.smiling", keywords: ["emoji", "symbol", "face", "smiley"], closesPalette: false) { [weak self] in self?.enterEmoji() },
            RootCommand(id: "screenshots.search", title: "Search Screenshots", subtitle: "Screenshots", runTitle: "Open", icon: "camera.viewfinder", keywords: ["screenshot", "screen", "capture", "recording", "image"], closesPalette: false) { [weak self] in self?.enterScreenshots() },
            RootCommand(id: "system.sleep", title: "Sleep", subtitle: "System", runTitle: "Sleep", icon: "moon.fill", keywords: ["sleep", "suspend"], closesPalette: true, run: shell("/usr/bin/pmset", ["sleepnow"])),
            RootCommand(id: "system.volumeUp", title: "Turn Volume Up", subtitle: "System", runTitle: "Run", icon: "speaker.wave.3.fill", keywords: ["volume", "up", "sound", "louder"], closesPalette: true, run: shell("/usr/bin/osascript", ["-e", "set volume output volume (output volume of (get volume settings) + 10)"])),
            RootCommand(id: "system.volumeDown", title: "Turn Volume Down", subtitle: "System", runTitle: "Run", icon: "speaker.wave.1.fill", keywords: ["volume", "down", "sound", "quieter"], closesPalette: true, run: shell("/usr/bin/osascript", ["-e", "set volume output volume (output volume of (get volume settings) - 10)"])),
            RootCommand(id: "system.mute", title: "Mute Volume", subtitle: "System", runTitle: "Run", icon: "speaker.slash.fill", keywords: ["mute", "silence", "volume"], closesPalette: true, run: shell("/usr/bin/osascript", ["-e", "set volume output muted true"])),
            RootCommand(id: "system.quitFront", title: "Quit Frontmost App", subtitle: "System", runTitle: "Quit", icon: "xmark.circle.fill", keywords: ["quit", "close", "app"], closesPalette: true) { [weak self] in self?.pasteTarget?.terminate() },
            RootCommand(id: "snippet.search", title: "Search Snippets", subtitle: "Snippets", runTitle: "Open", icon: "text.quote", keywords: ["snippet", "snippets", "text", "expand", "paste"], closesPalette: false) { [weak self] in self?.enterSnippets() },
            RootCommand(id: "snippet.create", title: "Create Snippet", subtitle: "Snippets", runTitle: "Open", icon: "plus.rectangle.on.rectangle", keywords: ["snippet", "create", "new", "add"], closesPalette: true) { [weak self] in self?.openSettings(tab: .snippets) },
            RootCommand(id: "quicklink.search", title: "Search Quicklinks", subtitle: "Quicklinks", runTitle: "Open", icon: "link", keywords: ["quicklink", "quicklinks", "link", "url", "bookmark"], closesPalette: false) { [weak self] in self?.enterQuicklinks() },
            RootCommand(id: "quicklink.create", title: "Create Quicklink", subtitle: "Quicklinks", runTitle: "Open", icon: "link.badge.plus", keywords: ["quicklink", "create", "new", "add", "link"], closesPalette: true) { [weak self] in self?.openSettings(tab: .quicklinks) },
            RootCommand(id: "app.settings", title: "Open Settings", subtitle: "Invoke", runTitle: "Open", icon: "gearshape", keywords: ["settings", "preferences", "config", "options"], closesPalette: true) { [weak self] in self?.openSettings() },
            windowCommand("window.maximize", "Maximize", "macwindow", ["maximize", "full", "fill"], .maximize),
            windowCommand("window.leftHalf", "Left Half", "rectangle.lefthalf.filled", ["left", "half"], .leftHalf),
            windowCommand("window.rightHalf", "Right Half", "rectangle.righthalf.filled", ["right", "half"], .rightHalf),
            windowCommand("window.topHalf", "Top Half", "rectangle.tophalf.filled", ["top", "half"], .topHalf),
            windowCommand("window.bottomHalf", "Bottom Half", "rectangle.bottomhalf.filled", ["bottom", "half"], .bottomHalf),
            windowCommand("window.center", "Center", "rectangle.center.inset.filled", ["center", "centre"], .center),
            windowCommand("window.topLeft", "Top Left Quarter", "rectangle.inset.filled", ["top", "left", "quarter"], .topLeft),
            windowCommand("window.topRight", "Top Right Quarter", "rectangle.inset.filled", ["top", "right", "quarter"], .topRight),
            windowCommand("window.bottomLeft", "Bottom Left Quarter", "rectangle.inset.filled", ["bottom", "left", "quarter"], .bottomLeft),
            windowCommand("window.bottomRight", "Bottom Right Quarter", "rectangle.inset.filled", ["bottom", "right", "quarter"], .bottomRight),
            RootCommand(id: "folder.home", title: "Open Home Folder", subtitle: "Navigation", runTitle: "Open", icon: "house", keywords: ["home", "folder", "finder"], closesPalette: true, run: openPath("~")),
            RootCommand(id: "folder.downloads", title: "Open Downloads", subtitle: "Navigation", runTitle: "Open", icon: "arrow.down.circle", keywords: ["downloads", "folder", "finder"], closesPalette: true, run: openPath("~/Downloads")),
            RootCommand(id: "folder.documents", title: "Open Documents", subtitle: "Navigation", runTitle: "Open", icon: "doc", keywords: ["documents", "docs", "folder"], closesPalette: true, run: openPath("~/Documents")),
            RootCommand(id: "folder.desktop", title: "Open Desktop", subtitle: "Navigation", runTitle: "Open", icon: "menubar.dock.rectangle", keywords: ["desktop", "folder"], closesPalette: true, run: openPath("~/Desktop")),
            RootCommand(id: "folder.applications", title: "Open Applications", subtitle: "Navigation", runTitle: "Open", icon: "square.grid.2x2", keywords: ["applications", "apps", "folder"], closesPalette: true, run: openPath("/Applications")),
        ] + discoverExtensionCommands()
    }

    // MARK: - Helpers

    private static func looksLikeCalculation(_ q: String) -> Bool {
        let t = q.trimmingCharacters(in: .whitespaces)
        if t.isEmpty { return false }
        if t.contains("(") { return true }
        if t.range(of: "^[-+]?[0-9.,]+$", options: .regularExpression) != nil { return true }
        let hasDigit = t.range(of: "[0-9]", options: .regularExpression) != nil
        if hasDigit, t.range(of: "[-+*/^%]", options: .regularExpression) != nil { return true }
        if t.range(of: "(?i)^[0-9.,]+\\s*[a-z°]+\\s+(in|to|as)\\s+[a-z°]+$", options: .regularExpression) != nil { return true }
        return false
    }

    /// First line of a clip, trimmed and truncated for the row title.
    private static func preview(_ s: String) -> String {
        let line = s.split(whereSeparator: \.isNewline).first.map(String.init) ?? s
        let t = line.trimmingCharacters(in: .whitespaces)
        return t.count > 80 ? String(t.prefix(80)) + "…" : t
    }

    private static func relativeTime(_ d: Date) -> String {
        let s = Int(Date().timeIntervalSince(d))
        if s < 5 { return "just now" }
        if s < 60 { return "\(s)s ago" }
        if s < 3600 { return "\(s / 60)m ago" }
        return "\(s / 3600)h ago"
    }

    @objc private func openSettingsMenu() { openSettings() }

    /// Settings tab indices (must match the order SettingsWindow adds its tabs).
    enum SettingsTab: Int { case general, commands, snippets, quicklinks, clipboard, advanced, about }

    private func openSettings(tab: SettingsTab? = nil) {
        palette.hide()
        settingsWindow.show(
            groups: extensionGroups(),
            onClearClipboard: { [weak self] in self?.clipboard.clear() },
            onBindingsChanged: { [weak self] in self?.reloadCommandHotkeys() },
            selectTab: tab?.rawValue
        )
    }

    /// The extension a command belongs to, for the grouped Commands settings (Raycast parity).
    private struct ExtensionMeta { let id: String; let name: String; let icon: String }
    private static func extensionMeta(for commandId: String) -> ExtensionMeta {
        if commandId.hasPrefix("window.") { return ExtensionMeta(id: "window-management", name: "Window Management", icon: "macwindow") }
        if commandId.hasPrefix("folder.") { return ExtensionMeta(id: "navigation", name: "Navigation", icon: "folder") }
        if commandId.hasPrefix("system.") { return ExtensionMeta(id: "system", name: "System", icon: "gearshape.2") }
        if commandId.hasPrefix("snippet.") { return ExtensionMeta(id: "snippets", name: "Snippets", icon: "text.quote") }
        if commandId.hasPrefix("quicklink.") { return ExtensionMeta(id: "quicklinks", name: "Quicklinks", icon: "link") }
        if commandId.hasPrefix("ext.") { return ExtensionMeta(id: "extensions", name: "Extensions", icon: "puzzlepiece.extension") }
        switch commandId {
        case "clipboard.history": return ExtensionMeta(id: "clipboard-history", name: "Clipboard History", icon: "doc.on.clipboard")
        case "emoji.picker": return ExtensionMeta(id: "emoji", name: "Emoji & Symbols", icon: "face.smiling")
        case "screenshots.search": return ExtensionMeta(id: "screenshots", name: "Screenshots", icon: "camera.viewfinder")
        case "app.settings": return ExtensionMeta(id: "invoke", name: "Invoke", icon: "command.square")
        default: return ExtensionMeta(id: "other", name: "Other", icon: "command")
        }
    }

    /// Group the built-in commands by parent extension (preserving each command's natural order),
    /// plus the resident Calculator (a typed fallback — enable-only). Groups are listed alphabetically.
    private func extensionGroups() -> [ExtensionGroup] {
        var order: [String] = []
        var metas: [String: ExtensionMeta] = [:]
        var kids: [String: [CommandInfo]] = [:]
        for c in commands {
            // Each installed extension is its OWN group in Settings (named by its title, like Raycast),
            // rather than lumping every third-party command under one generic "Extensions" group.
            let m: ExtensionMeta
            if c.id.hasPrefix("ext.") {
                let parts = c.id.split(separator: ".")
                let key = parts.count >= 2 ? "ext.\(parts[1])" : "extensions"
                m = ExtensionMeta(id: key, name: c.subtitle.isEmpty ? "Extension" : c.subtitle, icon: "puzzlepiece.extension.fill")
            } else {
                m = Self.extensionMeta(for: c.id)
            }
            if metas[m.id] == nil { metas[m.id] = m; order.append(m.id) }
            kids[m.id, default: []].append(CommandInfo(id: c.id, title: c.title, subtitle: "", icon: c.icon))
        }
        var groups = order.map { id in
            ExtensionGroup(id: id, name: metas[id]!.name, icon: metas[id]!.icon, commands: kids[id] ?? [])
        }
        groups.append(ExtensionGroup(id: "calculator", name: "Calculator", icon: "function",
            commands: [CommandInfo(id: "calculator", title: "Calculate", subtitle: "", icon: "function", supportsBinding: false)]))
        return groups.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    // MARK: - Per-command global hotkeys (PLAN.md §3.2, §6)

    /// (Re)register the user-assigned per-command hotkeys. Ids 100+ are reserved for these (1–5 are
    /// the fixed bindings). Called at launch and whenever the Settings window mutates a binding or
    /// an enable toggle — a disabled command's hotkey is removed.
    private func reloadCommandHotkeys() {
        let settings = AppSettings.shared
        for (i, cmd) in commands.enumerated() {
            let hid = UInt32(100 + i)
            if settings.isEnabled(cmd.id), let combo = settings.hotkey(for: cmd.id) {
                hotkey.register(id: hid, keyCode: combo.keyCode, modifiers: combo.modifiers) { [weak self] in
                    self?.runCommandFromHotkey(cmd)
                }
            } else {
                hotkey.unregister(id: hid)
            }
        }
    }

    /// A command fired by its global hotkey: action commands run directly (no palette); navigating
    /// commands (clipboard/emoji/screenshots) summon the palette into their mode. captureTarget()
    /// runs first for ALL commands so window/quit actions hit the *current* frontmost app, not a
    /// stale `pasteTarget` from an earlier summon (and not a nil one on a cold fire).
    private func runCommandFromHotkey(_ cmd: RootCommand) {
        frecency.bump("cmd:\(cmd.id)")
        captureTarget()
        if cmd.closesPalette {
            cmd.run()
            if palette.isVisible { afterLaunch() } // keep an open root in sync (frecency changed)
        } else {
            palette.show()
            cmd.run()
        }
    }

    private func makeMainMenu() -> NSMenu {
        let main = NSMenu()
        let appItem = NSMenuItem()
        main.addItem(appItem)
        let appMenu = NSMenu()
        appItem.submenu = appMenu
        let settingsItem = appMenu.addItem(withTitle: "Settings…", action: #selector(openSettingsMenu), keyEquivalent: ",")
        settingsItem.target = self
        appMenu.addItem(.separator())
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
