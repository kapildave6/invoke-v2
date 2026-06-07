import AppKit
import ApplicationServices
import Carbon.HIToolbox
import CoreGraphics
import ImageIO
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
    private var screenshotThumbCache: [String: String] = [:] // path → base64 PNG thumb (lazy, async)
    private let snippetStore = SnippetStore.shared
    private let quicklinkStore = QuicklinkStore.shared
    private let ai = AIService()
    private let settingsWindow = SettingsWindow()
    private lazy var commands: [RootCommand] = makeCommands()

    private enum Mode { case root, clipboard, emoji, screenshots, snippets, quicklinks, extensionView, aiAnswer, nativeForm, aiChat }
    private var mode: Mode = .root
    private var lastAIAnswer = "" // for the AI-answer surface's Copy/Paste actions
    private var aiAskSeq = 0      // request token so a stale answer can't render over a newer one
    // AI Chat (multi-turn, streaming).
    private var chatMessages: [(role: String, content: String)] = []
    private var chatStreaming = false
    private var chatStreamBuffer = ""
    private var chatSeq = 0
    private var lastChatRender = Date.distantPast
    private var clipKind = "All Types" // clipboard type filter
    private var pendingQuicklink: Quicklink? // quicklink awaiting its {query} argument (input sub-mode)
    private var pasteTarget: NSRunningApplication? // app to paste back into
    private static let defaultPlaceholder = "Search for apps and commands…"

    // A third-party extension running as a full palette surface (separate from the resident
    // calculator `host`). Launched on demand from a discovered `ext.*` command; rendered in .extension.
    private var extHost: ExtensionHost?
    private var currentExtId = ""
    private var currentExtTitle = ""
    private var extReceivedCommit = false // did the current extension render at least once?
    private var nativeFormTitle = ""
    private var nativeFormSubmit: (([String: String]) -> Void)? // called with field values on submit
    private var repoRoot = ""
    private var selectedIndex = 0
    private var rootTree: ViewTree?
    private var lastQuery = ""
    /// Pushed extension surfaces (Action.Push / useNavigation). The base is the extension's root
    /// surface; each push renders the target subtree, Esc pops back.
    private var navStack: [ViewNode] = []

    private var activeTree: ViewTree {
        if mode == .extensionView, let extHost {
            if let top = navStack.last { // render the pushed surface
                let t = ViewTree()
                t.root.children = [top]
                return t
            }
            return extHost.tree
        }
        return rootTree ?? host.tree
    }

    /// A built-in command in the root registry.
    private struct RootCommand {
        let id: String
        let title: String
        let subtitle: String
        let runTitle: String
        let icon: String       // SF Symbol (fallback)
        var iconPath: String? = nil // absolute path to a manifest icon image (extensions), preferred when set
        let keywords: [String]
        let closesPalette: Bool // folder-opens close; "navigating" commands (clipboard) keep it open
        let run: () -> Void
    }

    public override init() { super.init() }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Writing to a socket whose extension child has died raises SIGPIPE, whose default action KILLS
        // the app. Ignore it so a failed/closed extension just yields EPIPE on write (already handled).
        signal(SIGPIPE, SIG_IGN)
        if let icon = Brand.appIcon { NSApp.applicationIconImage = icon } // shows in system dialogs
        NSApp.mainMenu = makeMainMenu()

        // invoke:// deep links (Copy Deeplink). Custom URL schemes arrive as a GetURL Apple event.
        NSAppleEventManager.shared().setEventHandler(
            self, andSelector: #selector(handleGetURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))

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
            } else if !self.navStack.isEmpty {
                self.navStack.removeLast() // pop a pushed view, stay in the extension
                self.selectedIndex = 0
                self.renderExtension()
            } else if self.mode != .root {
                self.exitToRoot()
            } else {
                self.palette.hide()
            }
        }
        palette.actionsProvider = { [weak self] in self?.currentActions() ?? [] }
        palette.actionPanelTitleProvider = { [weak self] in self?.actionPanelTitle() ?? "" }
        palette.onOpenSettings = { [weak self] in self?.openSettings() }
        palette.onFilterChange = { [weak self] kind in
            guard let self else { return }
            self.clipKind = kind
            self.selectedIndex = 0
            self.renderClipboard(query: self.lastQuery)
        }
        palette.onSelectRow = { [weak self] i in self?.setSelection(i) }
        palette.onActivateRow = { [weak self] i in self?.clickActivate(i) }

        // The repo (node_modules, runtime/node-host, examples/, imported/) must be locatable. When run
        // via `swift run` from the repo, cwd-walking finds it. When run as /Applications/Invoke.app, cwd
        // is "/", so build-app.sh bakes the dev repo path into Info.plist (INVOKERepoRoot). Pick the
        // first candidate that is actually a repo; else the last as a best-effort fallback.
        let fm = FileManager.default
        let candidates = [
            ProcessInfo.processInfo.environment["INVOKE_REPO_ROOT"],
            Bundle.main.object(forInfoDictionaryKey: "INVOKERepoRoot") as? String,
            Self.findRepoRoot(),
            fm.currentDirectoryPath,
        ].compactMap { $0 }.filter { !$0.isEmpty }
        repoRoot = candidates.first { fm.fileExists(atPath: $0 + "/runtime/node-host/src/child.ts") } ?? candidates.last ?? ""
        print("[invoke:host] repo root: \(repoRoot)")

        let entry = ProcessInfo.processInfo.environment["INVOKE_EXT_ENTRY"] ?? "examples/calculator/src/calculate.tsx"
        let command = ProcessInfo.processInfo.environment["INVOKE_EXT_COMMAND"] ?? "calculate"
        host.launch(repoRoot: repoRoot, entryRelPath: entry, command: command)

        appIndex.build()
        clipboard.start()
        clipboard.capacity = AppSettings.shared.clipboardLimit
        print("[invoke:host] app index: \(appIndex.count) applications · \(commands.count) commands")

        // ⌥Space summons the root. (Clipboard History's ⌘⇧V is a configurable per-command hotkey now —
        // seeded as a default below and editable in Settings → Extensions → Clipboard History.)
        hotkey.register(id: 1, keyCode: UInt32(kVK_Space), modifiers: UInt32(optionKey)) { [weak self] in
            self?.summonToggle()
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
        print("[invoke:host] global hotkeys: ⌥Space · ⌃⌥←/→/↑ (windows)")
        // Reserve the fixed combos so the recorder won't let a command shadow them (Carbon would
        // drop the duplicate registration silently). ⌘⇧V is NOT reserved — it's the editable default
        // for the Clipboard History command.
        AppSettings.reservedCombos = [
            AppSettings.comboKey(keyCode: UInt32(kVK_Space), modifiers: UInt32(optionKey)),
            AppSettings.comboKey(keyCode: UInt32(kVK_LeftArrow), modifiers: winMods),
            AppSettings.comboKey(keyCode: UInt32(kVK_RightArrow), modifiers: winMods),
            AppSettings.comboKey(keyCode: UInt32(kVK_UpArrow), modifiers: winMods),
        ]
        // Seed ⌘⇧V as the default Clipboard History hotkey ONCE (the user can change/clear it; we don't
        // re-seed after that). Registered via the per-command path below.
        if !UserDefaults.standard.bool(forKey: "hotkeyDefaultsSeeded") {
            if AppSettings.shared.hotkey(for: "clipboard.history") == nil {
                AppSettings.shared.setHotkey("clipboard.history",
                    AppSettings.KeyCombo(keyCode: UInt32(kVK_ANSI_V), modifiers: UInt32(cmdKey | shiftKey), display: "⌘⇧V"))
            }
            UserDefaults.standard.set(true, forKey: "hotkeyDefaultsSeeded")
        }
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
        if mode == .aiAnswer { return } // showing an answer; Esc to go back
        if mode == .nativeForm { return } // a form; typing happens in the form fields, not the search box
        if mode == .aiChat { return } // the search field is the chat composer; Enter sends (lastQuery)
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
        if palette.isVisible { palette.hide(); return }
        // Phase-0 perf gate (PLAN.md §1/§8.2/§8.4): native-summon p95 < 150ms. We time the
        // synchronous build+show cost, then a runloop tick later (when AppKit has committed the
        // panel to the screen) the user-perceived first-frame cost. Logged every summon so a
        // baseline/regression is visible in the host log without a window-server screen grab.
        let t0 = DispatchTime.now()
        captureTarget(); exitToRoot(); palette.show()
        let syncMs = Double(DispatchTime.now().uptimeNanoseconds - t0.uptimeNanoseconds) / 1_000_000
        DispatchQueue.main.async {
            let frameMs = Double(DispatchTime.now().uptimeNanoseconds - t0.uptimeNanoseconds) / 1_000_000
            print(String(format: "[invoke:perf] summon %.1fms (sync %.1fms) · budget 150ms (PLAN §1)", frameMs, syncMs))
        }
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
        palette.suppressAutoHide = false
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
        let shots = screenshots.search(query)
        if shots.isEmpty {
            let list = ViewNode(id: 1, type: "list")
            let msg = query.trimmingCharacters(in: .whitespaces).isEmpty ? "No screenshots found" : "No matching screenshots"
            list.children = [ViewNode(id: 2, type: "list-section", props: ["title": .string(msg)])]
            tree.root.children = [list]
            return tree
        }
        // A grid of thumbnails (Raycast parity) — the file name doesn't matter, only the preview + date.
        let shown = Array(shots.prefix(Self.screenshotGridCap))
        ensureScreenshotThumbs(shown, query: query) // populate the cache off-main, then re-render
        let grid = ViewNode(id: 1, type: "grid", props: ["columns": .number(3), "itemHeight": .number(132)])
        var nid = 10
        for shot in shown {
            nid += 1
            var props: [String: JSONValue] = [
                "title": .string(Self.relativeTime(shot.date)),
                "fileToPaste": .string(shot.path),
                "fileIcon": .string(shot.path),
                "metadata": Self.screenshotMetadata(shot),
                "icon": .string(shot.path.hasSuffix(".mov") ? "video" : "photo"), // fallback until thumb loads
                "copyPrimary": .bool(true), // Enter copies the screenshot (Raycast); ⌘↵ pastes
            ]
            if let thumb = screenshotThumbCache[shot.path] { props["thumb"] = .string(thumb) }
            grid.children.append(ViewNode(id: nid, type: "grid-item", props: props))
        }
        tree.root.children = [grid]
        return tree
    }

    private static let screenshotGridCap = 90

    /// Generate any missing thumbnails for the shown screenshots OFF the main thread (ImageIO, so no
    /// AppKit lockFocus), cache them, then re-render once — so opening Screenshots never freezes.
    private func ensureScreenshotThumbs(_ shots: [ScreenshotIndex.Shot], query: String) {
        let missing = shots.map { $0.path }.filter { screenshotThumbCache[$0] == nil && !$0.hasSuffix(".mov") }
        guard !missing.isEmpty else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var generated: [String: String] = [:]
            for path in missing {
                if let b64 = Self.diskThumb(path: path, maxPixel: 320) { generated[path] = b64 }
            }
            DispatchQueue.main.async {
                guard let self, self.mode == .screenshots, self.lastQuery == query else { return }
                for (k, v) in generated { self.screenshotThumbCache[k] = v }
                self.renderScreenshots(query: query) // now finds the cached thumbs
            }
        }
    }

    /// Thread-safe downscaled PNG thumbnail via ImageIO (no NSImage lockFocus). nil for non-images.
    private static func diskThumb(path: String, maxPixel: Int) -> String? {
        guard let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil) else { return nil }
        let opts: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixel,
            kCGImageSourceCreateThumbnailWithTransform: true,
        ]
        guard let cg = CGImageSourceCreateThumbnailAtIndex(src, 0, opts as CFDictionary) else { return nil }
        let rep = NSBitmapImageRep(cgImage: cg)
        return rep.representation(using: .png, properties: [:])?.base64EncodedString()
    }

    // MARK: - Native in-palette forms (Create/Edit Snippet & Quicklink — Raycast has no Settings tab)

    private func formField(_ id: Int, fieldId: String, type: String, title: String, placeholder: String, value: String = "") -> ViewNode {
        var props: [String: JSONValue] = ["id": .string(fieldId), "title": .string(title), "placeholder": .string(placeholder)]
        if !value.isEmpty { props["value"] = .string(value) }
        return ViewNode(id: id, type: type, props: props)
    }

    /// Open an in-palette form. `submit` receives the field values (by id) when the user presses Enter.
    private func enterNativeForm(title: String, fields: [ViewNode], submit: @escaping ([String: String]) -> Void) {
        mode = .nativeForm
        nativeFormTitle = title
        nativeFormSubmit = submit
        palette.suppressAutoHide = true // Tab between fields must not auto-close the panel
        lastQuery = ""
        let tree = ViewTree()
        let form = ViewNode(id: 1, type: "form")
        form.children = fields
        tree.root.children = [form]
        rootTree = tree
        palette.clearSearch()
        palette.setPlaceholder(title)
        palette.hideFilter()
        selectedIndex = 0
        if !palette.isVisible { palette.show() }
        palette.render(activeTree, selectedIndex: 0)
        updateActionBar()
    }

    private func presentSnippetForm(editing snip: Snippet? = nil) {
        let fields = [
            formField(11, fieldId: "name", type: "form-textfield", title: "Name", placeholder: "Snippet name", value: snip?.name ?? ""),
            formField(12, fieldId: "keyword", type: "form-textfield", title: "Keyword (optional)", placeholder: "Keyword", value: snip?.keyword ?? ""),
            formField(13, fieldId: "content", type: "form-textarea", title: "Snippet", placeholder: "Snippet text…", value: snip?.content ?? ""),
        ]
        enterNativeForm(title: snip == nil ? "Create Snippet" : "Edit Snippet", fields: fields) { [weak self] vals in
            guard let self else { return }
            let name = (vals["name"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let content = vals["content"] ?? ""
            guard !name.isEmpty || !content.isEmpty else { return }
            if var s = snip {
                s.name = name; s.keyword = vals["keyword"] ?? ""; s.content = content
                self.snippetStore.update(s)
            } else {
                _ = self.snippetStore.add(Snippet(name: name, keyword: vals["keyword"] ?? "", content: content))
            }
        }
    }

    private func presentQuicklinkForm(editing ql: Quicklink? = nil) {
        let fields = [
            formField(11, fieldId: "name", type: "form-textfield", title: "Name", placeholder: "Quicklink name", value: ql?.name ?? ""),
            formField(12, fieldId: "link", type: "form-textfield", title: "Link", placeholder: "https://example.com/{query}", value: ql?.link ?? ""),
        ]
        enterNativeForm(title: ql == nil ? "Create Quicklink" : "Edit Quicklink", fields: fields) { [weak self] vals in
            guard let self else { return }
            let name = (vals["name"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let link = (vals["link"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty, !link.isEmpty else { return }
            if var q = ql {
                q.name = name; q.link = link
                self.quicklinkStore.update(q)
            } else {
                _ = self.quicklinkStore.add(Quicklink(name: name, link: link))
            }
        }
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
            // Favorites pinned to the very top (Raycast parity).
            let favCmds = commands.filter { AppSettings.shared.isFavorite($0.id) && AppSettings.shared.isEnabled($0.id) }
            if !favCmds.isEmpty {
                let favItems = favCmds.map {
                    itemNode(id: nextId(), title: $0.title, subtitle: $0.subtitle, kind: "Command", appPath: nil, icon: $0.icon, commandId: $0.id, alias: AppSettings.shared.alias(for: $0.id), iconPath: $0.iconPath)
                }
                sections.append(sectionNode("Favorites", favItems))
            }
            let suggestions = suggestionItems(nextId: nextId)
            if !suggestions.isEmpty { sections.append(sectionNode("Suggestions", suggestions)) }
            // Every enabled command (Raycast-style), scrollable — minus the ones already pinned to
            // Favorites so a favorite isn't shown twice.
            let cmds = commands.filter { AppSettings.shared.isEnabled($0.id) && !AppSettings.shared.isFavorite($0.id) }.map {
                itemNode(id: nextId(), title: $0.title, subtitle: $0.subtitle, kind: "Command", appPath: nil, icon: $0.icon, commandId: $0.id, alias: AppSettings.shared.alias(for: $0.id), iconPath: $0.iconPath)
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
                itemNode(id: nextId(), title: $0.title, subtitle: $0.subtitle, kind: "Command", appPath: nil, icon: $0.icon, commandId: $0.id, alias: AppSettings.shared.alias(for: $0.id), iconPath: $0.iconPath)
            }
            let appsSection = appItems.isEmpty ? nil : sectionNode("Applications", appItems)
            let cmdsSection = cmdItems.isEmpty ? nil : sectionNode("Commands", cmdItems)

            let ordered = aliasFirst ? [cmdsSection, appsSection] : [appsSection, cmdsSection]
            sections.append(contentsOf: ordered.compactMap { $0 })

            // "Ask AI" — answer the typed query (only when a key is configured).
            if ai.hasKey {
                let aiItem = itemNode(id: nextId(), title: "Ask AI", subtitle: q, kind: "AI", appPath: nil, icon: "sparkles", commandId: nil)
                aiItem.props["aiAsk"] = .string(q)
                sections.append(sectionNode("Use AI", [aiItem]))
            }
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
                if AppSettings.shared.isFavorite(c.id) { continue } // already pinned in Favorites — don't duplicate
                out.append(itemNode(id: nextId(), title: c.title, subtitle: c.subtitle, kind: "Command", appPath: nil, icon: c.icon, commandId: c.id, alias: AppSettings.shared.alias(for: c.id), iconPath: c.iconPath))
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

    private func itemNode(id: Int, title: String, subtitle: String?, kind: String, appPath: String?, icon: String?, commandId: String?, alias: String? = nil, iconPath: String? = nil) -> ViewNode {
        var accessories: [JSONValue] = []
        if let alias, !alias.isEmpty { accessories.append(.object(["tag": .string(alias)])) }
        accessories.append(.object(["text": .string(kind)]))
        var props: [String: JSONValue] = [
            "title": .string(title),
            "accessories": .array(accessories),
        ]
        if let subtitle, !subtitle.isEmpty { props["subtitle"] = .string(subtitle) }
        if let appPath { props["appPath"] = .string(appPath) }
        if let iconPath { props["iconImagePath"] = .string(iconPath) } // manifest image icon (extensions)
        if let icon { props["icon"] = .string(icon) }
        // Command/AI SF-symbol icons render as a colored tile (Raycast-style), keyed by group so a whole
        // extension shares a color. Apps/files/extension-image icons keep their native art.
        if (kind == "Command" || kind == "AI"), appPath == nil, iconPath == nil {
            props["iconTileKey"] = .string(subtitle ?? title)
        }
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
        case .snippets: renderSnippets(query: lastQuery)        // rebuild so the detail pane follows
        default:
            // Screenshots (grid) and the rest just re-highlight the existing tree — no rebuild, no
            // thumbnail re-scan — so arrow nav stays snappy.
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
        if mode == .aiChat { sendChatMessage(lastQuery); return } // Enter sends the composed message
        if mode == .nativeForm { // Enter submits the form, then closes
            nativeFormSubmit?(palette.formValues())
            afterLaunch()
            return
        }
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
        case .extensionView:
            // Show the pushed view's title with a back chevron when navigated in.
            if let top = navStack.last {
                label = "‹ " + (top.props["navigationTitle"]?.stringValue ?? currentExtTitle)
            } else {
                label = currentExtTitle
            }
        case .aiAnswer: label = "Ask AI"
        case .aiChat: label = chatStreaming ? "AI Chat — thinking…" : "AI Chat"
        case .nativeForm: label = nativeFormTitle
        case .root: label = "Invoke"
        }
        let primary = mode == .nativeForm ? "Save" : (pendingQuicklink != nil ? "Open" : currentActions().first?.title)
        palette.setActionBar(command: label, primary: primary)
    }

    /// Actions for the selected row: launch an app, run a command (both bump frecency), or the
    /// extension's own actions (the calculator card's Copy).
    private func currentActions() -> [PaletteAction] {
        if mode == .aiChat {
            let lastAnswer = chatMessages.last(where: { $0.role == "assistant" })?.content ?? ""
            var acts = [PaletteAction(title: "Send", shortcut: "↵", icon: "paperplane") { [weak self] in self?.sendChatMessage(self?.lastQuery ?? "") }]
            if !lastAnswer.isEmpty {
                acts.append(PaletteAction(title: "Copy Answer", shortcut: "⌘↵", icon: "doc.on.doc") { [weak self] in self?.copyText(lastAnswer) })
            }
            acts.append(PaletteAction(title: "New Chat", shortcut: nil, icon: "plus.bubble") { [weak self] in self?.enterAIChat(initial: "") })
            return acts
        }
        if mode == .nativeForm {
            // ⌘K → Save (also ⌘↵ submits, since Enter inserts a newline in the textarea).
            return [PaletteAction(title: "Save", shortcut: "⌘↵", icon: "checkmark.circle") { [weak self] in
                guard let self else { return }
                self.nativeFormSubmit?(self.palette.formValues())
                self.afterLaunch()
            }]
        }
        if mode == .extensionView {
            let rows = items()
            // The selected list/grid row if there is one; otherwise the surface itself —
            // Detail/Form have an ActionPanel but no selectable rows.
            guard let node = (selectedIndex < rows.count) ? rows[selectedIndex] : extensionSurfaceNode() else { return [] }
            return extensionActions(under: node)
        }
        if mode == .aiAnswer {
            return [
                PaletteAction(title: pasteTitle(), shortcut: "↵") { [weak self] in guard let a = self?.lastAIAnswer, !a.isEmpty else { return }; self?.pasteText(a) },
                PaletteAction(title: "Copy Answer", shortcut: "⌘↵") { [weak self] in guard let a = self?.lastAIAnswer, !a.isEmpty else { return }; self?.copyText(a) },
            ]
        }

        let rows = items()
        guard selectedIndex < rows.count else { return [] }
        let node = rows[selectedIndex]

        if let q = node.props["aiAsk"]?.stringValue {
            return [PaletteAction(title: "Ask AI", shortcut: "↵") { [weak self] in self?.enterAIChat(initial: q) }]
        }
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
            let copy = PaletteAction(title: "Copy to Clipboard", shortcut: nil, icon: "doc.on.doc") { [weak self] in self?.copyImageFile(path) }
            let paste = PaletteAction(title: pasteTitle(), shortcut: nil, icon: "doc.on.clipboard") { [weak self] in self?.pasteImageFile(path) }
            // Screenshots default to Copy (Raycast); files-to-paste default to Paste.
            let copyFirst = { if case .bool(true)? = node.props["copyPrimary"] { return true }; return false }()
            let ordered = copyFirst ? [copy, paste] : [paste, copy]
            return ordered.enumerated().map { i, a in
                PaletteAction(title: a.title, shortcut: i == 0 ? "↵" : "⌘↵", icon: a.icon, run: a.run)
            }
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
                PaletteAction(title: "Copy", shortcut: "⌘↵", icon: "doc.on.doc") { [weak self] in self?.copyText(snip.content) },
                PaletteAction(title: "Edit Snippet", shortcut: "⌘E", icon: "pencil") { [weak self] in self?.presentSnippetForm(editing: snip) },
                PaletteAction(title: "Delete Snippet", shortcut: "⌃X", icon: "trash") { [weak self] in
                    self?.snippetStore.delete(id: sid); self?.selectedIndex = 0; self?.renderSnippets(query: self?.lastQuery ?? "")
                },
            ]
        }
        if let qid = node.props["quicklinkKey"]?.stringValue, let ql = quicklinkStore.quicklink(id: qid) {
            return [
                PaletteAction(title: ql.hasArgument ? "Open with Input…" : "Open", shortcut: "↵") { [weak self] in
                    if ql.hasArgument { self?.beginQuicklinkInput(ql) } else { self?.openQuicklink(ql, argument: "") }
                },
                PaletteAction(title: "Edit Quicklink", shortcut: "⌘E", icon: "pencil") { [weak self] in self?.presentQuicklinkForm(editing: ql) },
                PaletteAction(title: "Delete Quicklink", shortcut: "⌃X", icon: "trash") { [weak self] in
                    self?.quicklinkStore.delete(id: qid); self?.selectedIndex = 0; self?.renderQuicklinks(query: self?.lastQuery ?? "")
                },
            ]
        }
        if let cid = node.props["commandId"]?.stringValue, let cmd = commands.first(where: { $0.id == cid }) {
            let primary = PaletteAction(title: cmd.runTitle, shortcut: "↵") { [weak self] in
                self?.frecency.bump("cmd:\(cid)")
                cmd.run()
                if cmd.closesPalette { self?.afterLaunch() }
            }
            // Settings-tab launchers are self-referential — the management panel (Disable/Configure/…)
            // is meaningless on them, so only the primary Open action.
            return cid.hasPrefix("settings.") ? [primary] : [primary] + defaultCommandActions(commandId: cid)
        }
        return actions(under: node).enumerated().map { index, n in
            PaletteAction(title: title(for: n), shortcut: index == 0 ? "↵" : (index == 1 ? "⌘↵" : nil)) { [weak self] in self?.perform(n) }
        }
    }

    /// Raycast-style management actions appended to every command/extension's ⌘K panel. (Shortcuts
    /// are display-only for now; the actions run via click or arrow+Return in the panel.)
    private func defaultCommandActions(commandId cid: String) -> [PaletteAction] {
        let s = AppSettings.shared
        let isExtension = cid.hasPrefix("ext.")
        let fav = s.isFavorite(cid)
        var acts: [PaletteAction] = [
            PaletteAction(title: fav ? "Remove from Favorites" : "Add to Favorites", shortcut: "⇧⌘F",
                          icon: fav ? "star.slash" : "star") { [weak self] in
                s.toggleFavorite(cid); self?.selectedIndex = 0; self?.renderRoot(calcCard: nil)
            },
            PaletteAction(title: "Reset Ranking", shortcut: nil, icon: "arrow.counterclockwise") { [weak self] in
                self?.frecency.reset("cmd:\(cid)"); self?.selectedIndex = 0; self?.renderRoot(calcCard: nil)
            },
            PaletteAction(title: "Copy Deeplink", shortcut: "⇧⌘C", icon: "link") { [weak self] in
                self?.copyText("invoke://commands/\(cid)")
            },
            PaletteAction(title: "Configure Command", shortcut: "⇧⌘,", icon: "gearshape") { [weak self] in
                self?.openSettings(tab: .commands)
            },
        ]
        if isExtension {
            acts.append(PaletteAction(title: "Configure Extension", shortcut: "⌥⌘,", icon: "gearshape.2") { [weak self] in
                self?.openSettings(tab: .commands) // prefs live in the Commands detail panel now
            })
        }
        acts.append(PaletteAction(title: "Disable Command", shortcut: "⌃⇧⌘D", icon: "minus.circle") { [weak self] in
            s.setEnabled(cid, false)
            self?.reloadCommandHotkeys() // unregister its global hotkey now, not just at next relaunch
            self?.selectedIndex = 0
            self?.renderRoot(calcCard: nil)
        })
        return acts
    }

    /// Launching/running closes the palette and resets to a clean root for the next summon — from any
    /// mode (so opening a quicklink / running a snippet doesn't leave us stuck in that mode).
    private func afterLaunch() {
        palette.suppressAutoHide = false
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
        afterLaunch() // copying closes the palette (Raycast behavior)
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

    private static var didPromptAccessibility = false
    private static func promptAccessibility() {
        // Prompt at most once per launch — otherwise every paste while untrusted re-opens the system
        // dialog ("asking again and again"). After the first prompt, callers fall back to copy + a toast.
        guard !didPromptAccessibility else { return }
        didPromptAccessibility = true
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(opts)
    }

    private static func synthesizePaste() { synthesizeCmdKey(9) } // ⌘V
    private static func synthesizeCopy() { synthesizeCmdKey(8) }  // ⌘C (kVK_ANSI_C)

    private static func synthesizeCmdKey(_ keyCode: CGKeyCode) {
        let src = CGEventSource(stateID: .combinedSessionState)
        let down = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: true)
        down?.flags = .maskCommand
        let up = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: false)
        up?.flags = .maskCommand
        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }

    // MARK: - AI commands (PLAN.md §2/§7)

    /// Copy the frontmost app's current selection (synthesize ⌘C, then read the pasteboard).
    private func captureSelection(_ completion: @escaping (String?) -> Void) {
        guard AXIsProcessTrusted() else {
            Self.promptAccessibility()
            palette.showToast("Enable Accessibility for Invoke to read the selection")
            completion(nil)
            return
        }
        guard let target = pasteTarget else { // nil → ⌘C would go to an undefined app; bail clearly
            palette.showToast("No app to read a selection from")
            completion(nil)
            return
        }
        let pb = NSPasteboard.general
        let before = pb.changeCount
        palette.hide()
        target.activate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            Self.synthesizeCopy()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                completion(pb.changeCount != before ? pb.string(forType: .string) : nil)
            }
        }
    }

    /// Improve/transform the current selection with AI and paste the result back into the app.
    /// The user's clipboard is snapshotted and restored — the ⌘C/paste-back are an implementation
    /// detail and shouldn't eat what they had copied.
    private func runAITransform(_ system: String) {
        guard ai.hasKey else { palette.showToast("Set ANTHROPIC_API_KEY to use AI"); return }
        let pb = NSPasteboard.general
        let saved = pb.string(forType: .string)
        func restoreClipboard() {
            pb.clearContents()
            if let saved { pb.setString(saved, forType: .string) }
        }
        captureSelection { [weak self] text in
            guard let self else { return }
            guard let text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                restoreClipboard()
                self.palette.show(); self.palette.showToast("Select some text first")
                return
            }
            let target = self.pasteTarget
            Task {
                let result = await self.ai.complete(system: system, user: text)
                await MainActor.run {
                    switch result {
                    case .success(let out):
                        pb.clearContents(); pb.setString(out, forType: .string)
                        target?.activate()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                            Self.synthesizePaste()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { restoreClipboard() } // after ⌘V consumed it
                        }
                    case .failure(let err):
                        restoreClipboard()
                        self.palette.show(); self.palette.showToast("AI — \(err.message)")
                    }
                }
            }
        }
    }

    /// Ask AI a free-form question; render the answer in a Detail surface.
    private func runAIAsk(_ question: String) {
        let q = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }
        guard ai.hasKey else { palette.showToast("Set ANTHROPIC_API_KEY to use AI"); return }
        mode = .aiAnswer
        lastAIAnswer = ""
        aiAskSeq += 1
        let seq = aiAskSeq // correlate this request, so a slow earlier answer can't clobber a newer one
        renderAIAnswer(markdown: "_Thinking…_")
        Task {
            let result = await ai.complete(system: "You are a concise, expert engineering assistant. Answer in Markdown.", user: q, maxTokens: 1500)
            await MainActor.run {
                guard self.mode == .aiAnswer, self.aiAskSeq == seq else { return } // navigated away or superseded
                switch result {
                case .success(let out): self.lastAIAnswer = out; self.renderAIAnswer(markdown: out)
                case .failure(let err): self.renderAIAnswer(markdown: "**AI error**\n\n\(err.message)")
                }
            }
        }
    }

    private func renderAIAnswer(markdown: String) {
        let tree = ViewTree()
        let detail = ViewNode(id: 1, type: "detail", props: ["markdown": .string(markdown)])
        tree.root.children = [detail]
        rootTree = tree
        selectedIndex = 0
        palette.hideFilter()
        palette.render(tree, selectedIndex: 0)
        updateActionBar()
    }

    // MARK: - AI Chat (multi-turn, streaming)

    private static let chatSystemPrompt = "You are a concise, expert assistant inside a macOS command palette. Answer in GitHub-flavored Markdown. Keep answers focused; use code blocks for code."

    /// Enter conversational AI Chat. If `initial` is non-empty, send it as the first turn.
    private func enterAIChat(initial: String) {
        guard ai.hasKey else { palette.showToast("Set your Anthropic API key in Settings → Advanced to use AI"); return }
        mode = .aiChat
        chatMessages = []
        chatStreaming = false
        chatStreamBuffer = ""
        captureTarget()
        lastQuery = ""
        palette.clearSearch()
        palette.setPlaceholder("Message AI…  (↵ to send)")
        palette.hideFilter()
        if !palette.isVisible { palette.show() }
        let q = initial.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty { renderAIChat() } else { sendChatMessage(q) }
    }

    /// Append a user turn and stream the assistant reply.
    private func sendChatMessage(_ text: String) {
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty, !chatStreaming else { return }
        guard ai.hasKey else { palette.showToast("Set your Anthropic API key in Settings → Advanced to use AI"); return }
        chatMessages.append((role: "user", content: q))
        lastQuery = ""
        palette.clearSearch()
        chatStreaming = true
        chatStreamBuffer = ""
        chatSeq += 1
        let seq = chatSeq
        lastChatRender = .distantPast
        renderAIChat()
        ai.stream(
            system: Self.chatSystemPrompt,
            messages: chatMessages.map { ["role": $0.role, "content": $0.content] },
            onDelta: { [weak self] t in
                guard let self, self.mode == .aiChat, self.chatSeq == seq else { return }
                self.chatStreamBuffer += t
                let now = Date()
                if now.timeIntervalSince(self.lastChatRender) > 0.05 { self.lastChatRender = now; self.renderAIChat() }
            },
            onComplete: { [weak self] result in
                guard let self, self.mode == .aiChat, self.chatSeq == seq else { return }
                self.chatStreaming = false
                switch result {
                case .success(let full):
                    self.chatMessages.append((role: "assistant", content: full))
                case .failure(let err):
                    self.chatMessages.append((role: "assistant", content: "**AI error** — \(err.message)"))
                }
                self.chatStreamBuffer = ""
                self.renderAIChat()
            }
        )
    }

    private func renderAIChat() {
        var md = ""
        for m in chatMessages {
            md += m.role == "user" ? "### 🧑 You\n\n\(m.content)\n\n" : "### ✦ AI\n\n\(m.content)\n\n"
        }
        if chatStreaming {
            let partial = chatStreamBuffer.isEmpty ? "_Thinking…_" : chatStreamBuffer
            md += "### ✦ AI\n\n\(partial)\n\n"
        }
        if md.isEmpty { md = "_Ask anything. Type a message and press ↵._" }
        let tree = ViewTree()
        tree.root.children = [ViewNode(id: 1, type: "detail", props: ["markdown": .string(md)])]
        rootTree = tree
        selectedIndex = 0
        palette.render(tree, selectedIndex: 0)
        palette.scrollToBottom() // keep the latest (streaming) turn in view
        updateActionBar()
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
            if n.type == "list-item" || n.type == "grid-item" { out.append(n) }
            for c in n.children { walk(c) }
        }
        walk(activeTree.root)
        return out
    }

    private func actions(under item: ViewNode) -> [ViewNode] {
        var out: [ViewNode] = []
        func walk(_ n: ViewNode) {
            // Don't descend into an action's pushed target — its nested view's actions aren't this row's.
            if n.type == "action" { out.append(n); return }
            for c in n.children { walk(c) }
        }
        walk(item)
        return out
    }

    /// Title for the ⌘K Action Panel header — the selected result's name (falling back to the mode).
    private func actionPanelTitle() -> String {
        let rows = items()
        if selectedIndex < rows.count, let t = rows[selectedIndex].props["title"]?.stringValue, !t.isEmpty {
            return t
        }
        switch mode {
        case .clipboard: return "Clipboard History"
        case .aiAnswer: return "AI Answer"
        case .aiChat: return "AI Chat"
        case .extensionView: return currentExtTitle
        default: return ""
        }
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
    /// Default-deny per-extension consent for the powerful runAppleScript capability. Returns true if
    /// the current extension may run AppleScript (already granted, or the user allows it now). Runs a
    /// blocking dialog on the main thread (handleCapability is invoked on main).
    private func ensureAppleScriptGrant() -> Bool {
        let id = currentExtId
        guard !id.isEmpty else { return false }
        if AppSettings.shared.appleScriptGrants.contains(id) { return true }
        let alert = NSAlert()
        alert.messageText = "Allow “\(currentExtTitle)” to run AppleScript?"
        alert.informativeText = "This lets the extension automate apps on your Mac (for example, Apple Notes). Only allow extensions you trust."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Allow")
        alert.addButton(withTitle: "Don’t Allow")
        let allow = alert.runModal() == .alertFirstButtonReturn
        if allow { AppSettings.shared.appleScriptGrants.insert(id) }
        return allow
    }

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
        case "runAppleScript":
            // Powerful OS-automation capability (Raycast's runAppleScript). Gated several ways because
            // the host runs UNREVIEWED imported extensions and is not itself OS-sandboxed:
            //   • `do shell script` is an arbitrary-command escape (runs /bin/sh in our process) — refuse it.
            //   • default-deny per-extension consent (a blocking dialog naming the extension) before running.
            //   • macOS TCC still prompts for automating another app (e.g. Notes) on first use.
            // The script text isn't logged (may contain user content).
            let source = arg("source")?.stringValue ?? ""
            guard !source.isEmpty else { return .string("") }
            if source.range(of: "do[ \\t]+shell[ \\t]+script", options: .regularExpression) != nil {
                palette.showToast("Blocked: “\(currentExtTitle)” tried to run a shell command via AppleScript")
                print("[invoke:ext] runAppleScript blocked (do shell script) from \(currentExtId)")
                return .string("")
            }
            guard ensureAppleScriptGrant() else { return .string("") }
            var errorDict: NSDictionary?
            let result = NSAppleScript(source: source)?.executeAndReturnError(&errorDict)
            if let errorDict {
                let msg = (errorDict[NSAppleScript.errorMessage] as? String) ?? "AppleScript error"
                palette.showToast("AppleScript: \(msg)")
                return .string("")
            }
            return .string(result?.stringValue ?? "")
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

    /// Scan the bundled `examples/*` and `invoke import`-ed `imported/*` for extension manifests and
    /// surface their `view` commands in the root (the calculator is excluded — it's the resident card
    /// provider). A user-writable install dir + a store come later.
    private func discoverExtensionCommands() -> [RootCommand] {
        let fm = FileManager.default
        var out: [RootCommand] = []
        for root in ["examples", "imported"] {
            let rootDir = repoRoot + "/" + root
            guard let names = try? fm.contentsOfDirectory(atPath: rootDir) else { continue }
            for name in names.sorted() where name != "calculator" {
                let extDir = rootDir + "/" + name
                guard let data = fm.contents(atPath: extDir + "/package.json"),
                      let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                      let title = json["title"] as? String,
                      let cmds = json["commands"] as? [[String: Any]] else { continue }
                let prefsSpec = (json["preferences"] as? [[String: Any]]) ?? []
                // Namespace the extension key by root so an imported ext can't collide ids (frecency/
                // alias/hotkey/grouping) with a bundled example of the same name.
                let extKey = root == "imported" ? "imported-\(name)" : name
                // Manifest icon (Raycast convention: a filename under the extension's assets/, or a
                // path relative to the extension dir). Per-command icon wins over the extension's.
                func resolveIcon(_ named: Any?) -> String? {
                    guard let n = named as? String, !n.isEmpty else { return nil }
                    for candidate in ["\(extDir)/assets/\(n)", "\(extDir)/\(n)"] where fm.fileExists(atPath: candidate) {
                        return candidate
                    }
                    return nil
                }
                let extIconPath = resolveIcon(json["icon"])
                for c in cmds {
                    guard let cname = c["name"] as? String,
                          ((c["mode"] as? String) ?? "view") == "view" else { continue }
                    let ctitle = (c["title"] as? String) ?? cname
                    guard let rel = ["tsx", "ts", "jsx", "js"].lazy
                        .map({ "\(root)/\(name)/src/\(cname).\($0)" })
                        .first(where: { fm.fileExists(atPath: repoRoot + "/" + $0) }) else { continue }
                    let cmdId = "ext.\(extKey).\(cname)"
                    out.append(RootCommand(id: cmdId, title: ctitle, subtitle: title, runTitle: "Open",
                                           icon: "puzzlepiece.extension.fill", iconPath: resolveIcon(c["icon"]) ?? extIconPath,
                                           keywords: [name, cname, title.lowercased()],
                                           closesPalette: false) { [weak self] in
                        guard let self else { return }
                        // Resolve preferences at launch (defaults merged with the user's saved values).
                        let prefs = self.resolvePreferencesJSON(extKey: extKey, spec: prefsSpec)
                        self.launchExtension(id: cmdId, title: ctitle, entryRelPath: rel, command: cname, preferences: prefs)
                    })
                }
            }
        }
        return out
    }

    /// Build INVOKE_PREFERENCES for an extension: each manifest preference's saved value (Keychain for
    /// `password`, UserDefaults otherwise) falling back to its manifest default.
    private func resolvePreferencesJSON(extKey: String, spec: [[String: Any]]) -> String {
        var dict: [String: Any] = [:]
        for p in spec {
            guard let name = p["name"] as? String else { continue }
            let type = (p["type"] as? String) ?? "textfield"
            let override = AppSettings.shared.extensionPref(extID: extKey, name: name, secret: type == "password")
            if type == "checkbox" {
                if let o = override { dict[name] = (o == "true") }
                else if let b = p["default"] as? Bool { dict[name] = b }
                else if let s = p["default"] as? String { dict[name] = (s == "true") }
            } else if let o = override {
                // A saved value (even empty) is an intentional override; only fall back when unset (nil).
                dict[name] = o
            } else if let def = p["default"] {
                dict[name] = def
            }
        }
        guard let data = try? JSONSerialization.data(withJSONObject: dict),
              let s = String(data: data, encoding: .utf8) else { return "{}" }
        return s
    }

    /// Preference groups (manifest `preferences[]`) for the Settings → Extensions pane.
    func extensionPreferenceGroups() -> [ExtensionPrefGroup] {
        let fm = FileManager.default
        var out: [ExtensionPrefGroup] = []

        // Parse a manifest preferences[] array into our model (Raycast schema: name/title/label/
        // description/type/default/data). `title` is a section header; `label` is a checkbox's text.
        func parsePrefs(_ arr: [[String: Any]]) -> [ExtensionPreference] {
            arr.compactMap { p in
                guard let pname = p["name"] as? String else { return nil }
                let def: String
                if let b = p["default"] as? Bool { def = b ? "true" : "false" }
                else if let s = p["default"] as? String { def = s }
                else if let n = p["default"] as? NSNumber { def = n.stringValue }
                else { def = "" }
                let options: [PrefOption] = (p["data"] as? [[String: Any]] ?? []).compactMap { o in
                    (o["value"] as? String).map { PrefOption(value: $0, title: (o["title"] as? String) ?? $0) }
                }
                return ExtensionPreference(name: pname, title: (p["title"] as? String) ?? "",
                                           label: (p["label"] as? String) ?? "",
                                           description: (p["description"] as? String) ?? "",
                                           type: (p["type"] as? String) ?? "textfield",
                                           defaultValue: def, options: options)
            }
        }

        for root in ["examples", "imported"] {
            let rootDir = repoRoot + "/" + root
            guard let names = try? fm.contentsOfDirectory(atPath: rootDir) else { continue }
            for name in names.sorted() where name != "calculator" {
                guard let data = fm.contents(atPath: rootDir + "/" + name + "/package.json"),
                      let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                      let title = json["title"] as? String else { continue }
                let extKey = root == "imported" ? "imported-\(name)" : name
                let fields = parsePrefs((json["preferences"] as? [[String: Any]]) ?? [])
                let commands: [ExtensionCommandDetail] = ((json["commands"] as? [[String: Any]]) ?? []).compactMap { c in
                    guard let cname = c["name"] as? String else { return nil }
                    return ExtensionCommandDetail(name: cname, title: (c["title"] as? String) ?? cname,
                                                  description: (c["description"] as? String) ?? "",
                                                  fields: parsePrefs((c["preferences"] as? [[String: Any]]) ?? []))
                }
                let capabilities: [ExtensionCapability] = ((json["tools"] as? [[String: Any]]) ?? []).compactMap { t in
                    guard let tname = t["name"] as? String else { return nil }
                    return ExtensionCapability(name: tname, title: (t["title"] as? String) ?? tname,
                                               description: (t["description"] as? String) ?? "")
                }
                // Emit a group for EVERY extension (not just those with prefs) so its description,
                // commands, and capabilities all show in the Commands detail panel (Raycast parity).
                out.append(ExtensionPrefGroup(id: extKey, title: title, description: (json["description"] as? String) ?? "",
                                              fields: fields, commands: commands, capabilities: capabilities))
            }
        }
        return out
    }

    /// Launch a discovered extension into a full palette surface (.extension mode), in its own process.
    private func launchExtension(id: String, title: String, entryRelPath: String, command: String, preferences: String) {
        teardownExtension()
        let h = ExtensionHost()
        h.onLog = { msg in print("[invoke:ext] \(msg)") }
        h.onCommit = { [weak self] _ in self?.extReceivedCommit = true; self?.onExtensionCommit() }
        h.onCapability = { [weak self] m, p in self?.handleCapability(m, p) ?? .null }
        h.onTerminate = { [weak self] in self?.onExtensionTerminated(id: id) }
        extHost = h
        currentExtId = id
        currentExtTitle = title
        extReceivedCommit = false
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

    /// The current extension's child process died unexpectedly (crashed / failed to start — e.g. a
    /// missing npm dep or a denied syscall). Return to root with a clear message instead of leaving a
    /// dead view (and never crash: writes to its closed socket are already SIGPIPE-safe).
    private func onExtensionTerminated(id: String) {
        guard mode == .extensionView, currentExtId == id else { return }
        let name = currentExtTitle
        let started = extReceivedCommit
        exitToRoot()
        if !started { palette.showToast("Couldn’t start “\(name)” — it may need an unsupported dependency") }
    }

    private func teardownExtension() {
        extHost?.terminate()
        extHost = nil
        currentExtId = ""
        currentExtTitle = ""
        navStack.removeAll()
    }

    /// Detached deep copy of a view subtree (props/text are value types; children copied recursively),
    /// so a pushed page can't be mutated by subsequent commits to the live extension tree.
    private static func deepCopy(_ n: ViewNode) -> ViewNode {
        let copy = ViewNode(id: n.id, type: n.type, text: n.text, props: n.props)
        copy.children = n.children.map { deepCopy($0) }
        return copy
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

    /// The current extension's top-level surface node (list/grid/detail/form) — used to find the
    /// ActionPanel when the surface has no selectable rows (Detail/Form), and to detect form submits.
    private func extensionSurfaceNode() -> ViewNode? {
        activeTree.root.children.first { ["detail", "form", "grid", "list"].contains($0.type) }
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
            // On a Form, the action is a submit — gather the field values and pass them to the handler.
            if extensionSurfaceNode()?.type == "form" {
                let values = palette.formValues().mapValues { JSONValue.string($0) }
                extHost?.invoke(handler: handler, args: [.object(values)])
            } else {
                extHost?.invoke(handler: handler) // stays open; re-renders on the next commit
            }
            return
        }
        switch n.props["variant"]?.stringValue {
        case "push":
            // The pushed view is the action's lifted child surface. SNAPSHOT it (deep copy) — the live
            // node is a reference into the extension's mutable tree, so a later re-render (search/async
            // commit) would otherwise detach it or silently rewrite the page you navigated into. A
            // pushed page is frozen (Raycast semantics).
            if let target = n.children.first(where: { ["detail", "form", "grid", "list"].contains($0.type) }) {
                navStack.append(Self.deepCopy(target))
                selectedIndex = 0
                renderExtension()
            }
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
            RootCommand(id: "ai.improve", title: "Improve Writing", subtitle: "AI", runTitle: "Run", icon: "wand.and.stars", keywords: ["ai", "improve", "writing", "rewrite", "polish"], closesPalette: false) { [weak self] in self?.runAITransform("Improve the writing of the user's text: fix grammar and spelling and improve clarity and flow while preserving the original meaning, tone, and language. Return ONLY the improved text — no preamble, no quotes.") },
            RootCommand(id: "ai.grammar", title: "Fix Spelling & Grammar", subtitle: "AI", runTitle: "Run", icon: "checkmark.circle", keywords: ["ai", "grammar", "spelling", "fix", "correct"], closesPalette: false) { [weak self] in self?.runAITransform("Fix only the spelling and grammar of the user's text. Do not change wording, meaning, tone, or language beyond necessary corrections. Return ONLY the corrected text.") },
            RootCommand(id: "ai.professional", title: "Make Professional", subtitle: "AI", runTitle: "Run", icon: "briefcase", keywords: ["ai", "professional", "formal", "tone"], closesPalette: false) { [weak self] in self?.runAITransform("Rewrite the user's text in a clear, professional tone suitable for workplace communication, preserving meaning and language. Return ONLY the rewritten text.") },
            RootCommand(id: "ai.concise", title: "Make Concise", subtitle: "AI", runTitle: "Run", icon: "scissors", keywords: ["ai", "concise", "shorter", "trim", "brief"], closesPalette: false) { [weak self] in self?.runAITransform("Rewrite the user's text to be more concise while preserving meaning, key details, tone, and language. Return ONLY the rewritten text.") },
            RootCommand(id: "ai.summarize", title: "Summarize", subtitle: "AI", runTitle: "Run", icon: "list.bullet.rectangle", keywords: ["ai", "summarize", "summary", "tldr"], closesPalette: false) { [weak self] in self?.runAITransform("Summarize the user's text into a few clear bullet points capturing the key information, in the same language. Return ONLY the summary.") },
            RootCommand(id: "snippet.search", title: "Search Snippets", subtitle: "Snippets", runTitle: "Open", icon: "text.quote", keywords: ["snippet", "snippets", "text", "expand", "paste"], closesPalette: false) { [weak self] in self?.enterSnippets() },
            RootCommand(id: "snippet.create", title: "Create Snippet", subtitle: "Snippets", runTitle: "Open", icon: "plus.rectangle.on.rectangle", keywords: ["snippet", "create", "new", "add"], closesPalette: false) { [weak self] in self?.presentSnippetForm() },
            RootCommand(id: "quicklink.search", title: "Search Quicklinks", subtitle: "Quicklinks", runTitle: "Open", icon: "link", keywords: ["quicklink", "quicklinks", "link", "url", "bookmark"], closesPalette: false) { [weak self] in self?.enterQuicklinks() },
            RootCommand(id: "quicklink.create", title: "Create Quicklink", subtitle: "Quicklinks", runTitle: "Open", icon: "link.badge.plus", keywords: ["quicklink", "create", "new", "add", "link"], closesPalette: false) { [weak self] in self?.presentQuicklinkForm() },
            RootCommand(id: "app.settings", title: "Open Settings", subtitle: "Invoke", runTitle: "Open", icon: "gearshape", keywords: ["settings", "preferences", "config", "options"], closesPalette: true) { [weak self] in self?.openSettings() },
            RootCommand(id: "ai.chat", title: "AI Chat", subtitle: "AI", runTitle: "Open", icon: "bubble.left.and.bubble.right", keywords: ["ai", "chat", "ask", "claude", "assistant", "gpt"], closesPalette: false) { [weak self] in self?.enterAIChat(initial: "") },
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
        ] + discoverExtensionCommands() + settingsTabCommands()
    }

    /// One searchable root command per Settings pane (Raycast parity) — "Extensions — Invoke Settings",
    /// "Advanced — Invoke Settings", etc. — opening Settings directly to that tab.
    private func settingsTabCommands() -> [RootCommand] {
        let tabs: [(SettingsTab, String, String)] = [
            (.general, "General", "gearshape"),
            (.commands, "Extensions", "puzzlepiece.extension"),
            (.importExt, "Import Extension", "square.and.arrow.down"),
            (.advanced, "Advanced", "wrench.and.screwdriver"),
            (.about, "About", "info.circle"),
        ]
        return tabs.map { tab, name, icon in
            RootCommand(id: "settings.\(tab.rawValue)", title: name, subtitle: "Invoke Settings", runTitle: "Open",
                        icon: icon, keywords: [name.lowercased(), "settings", "preferences", "config"],
                        closesPalette: true) { [weak self] in self?.openSettings(tab: tab) }
        }
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
    enum SettingsTab: Int { case general, commands, importExt, advanced, about }

    private func openSettings(tab: SettingsTab? = nil) {
        palette.hide()
        settingsWindow.show(
            groups: extensionGroups(),
            prefGroups: extensionPreferenceGroups(),
            onClearClipboard: { [weak self] in self?.clipboard.clear() },
            onBindingsChanged: { [weak self] in self?.reloadCommandHotkeys() },
            repoRoot: repoRoot,
            selectTab: tab?.rawValue
        )
    }

    // MARK: - invoke:// deep links

    @objc private func handleGetURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent: NSAppleEventDescriptor) {
        guard let s = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let url = URL(string: s) else { return }
        openDeeplink(url)
    }

    /// Handle `invoke://commands/<id>` — run that command (the payoff for the Copy Deeplink action).
    private func openDeeplink(_ url: URL) {
        guard url.scheme == "invoke", url.host == "commands" else { return }
        let id = String(url.path.dropFirst()) // "/window.maximize" → "window.maximize"
        guard !id.isEmpty, let cmd = commands.first(where: { $0.id == id }) else {
            palette.showToast("Unknown command in deep link"); return
        }
        frecency.bump("cmd:\(id)")
        cmd.run() // view commands open the palette; action commands run (and reset if they close it)
    }

    /// The extension a command belongs to, for the grouped Commands settings (Raycast parity).
    private struct ExtensionMeta { let id: String; let name: String; let icon: String }
    private static func extensionMeta(for commandId: String) -> ExtensionMeta {
        if commandId.hasPrefix("window.") { return ExtensionMeta(id: "window-management", name: "Window Management", icon: "macwindow") }
        if commandId.hasPrefix("folder.") { return ExtensionMeta(id: "navigation", name: "Navigation", icon: "folder") }
        if commandId.hasPrefix("system.") { return ExtensionMeta(id: "system", name: "System", icon: "gearshape.2") }
        if commandId.hasPrefix("ai.") { return ExtensionMeta(id: "ai", name: "AI", icon: "sparkles") }
        if commandId.hasPrefix("snippet.") { return ExtensionMeta(id: "snippets", name: "Snippets", icon: "text.quote") }
        if commandId.hasPrefix("quicklink.") { return ExtensionMeta(id: "quicklinks", name: "Quicklinks", icon: "link") }
        if commandId.hasPrefix("ext.") { return ExtensionMeta(id: "extensions", name: "Extensions", icon: "puzzlepiece.extension") }
        if commandId.hasPrefix("settings.") { return ExtensionMeta(id: "invoke-settings", name: "Invoke Settings", icon: "gearshape") }
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
