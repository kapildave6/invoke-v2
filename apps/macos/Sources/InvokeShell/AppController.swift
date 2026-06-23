import AppKit
import ApplicationServices
import Carbon.HIToolbox
import CoreGraphics
import CryptoKit
import Darwin
import ImageIO
import InvokeIPC
import InvokeRenderer
import InvokeServices
import SQLite3

/// App lifecycle + summon + the root ranker (PLAN.md §4.3). Composes ONE result tree from several
/// sources — Applications (native index), built-in Commands (registry), and the resident Calculator
/// extension's card — ranked by frecency, and rendered through the shared PaletteView. Owns the
/// keyboard selection model and the ⌥Space summon hotkey (§3.2).
public final class AppController: NSObject, NSApplicationDelegate {
    private let palette = PaletteWindow()
    private let host = ExtensionHost()
    private let hotkey = GlobalHotkey()
    private let appIndex = AppIndexService()
    private let hud = HUDOverlay() // standalone HUD for showHUD / headless no-view command feedback
    private let frecency = Frecency()
    private let clipboard = ClipboardHistory()
    private let windowManager = WindowManager()
    private let windowEnumerator = WindowEnumerator()
    private let screenshots = ScreenshotIndex()
    private var screenshotThumbCache: [String: String] = [:] // path → base64 PNG thumb (lazy, async)
    private let snippetStore = SnippetStore.shared
    private let quicklinkStore = QuicklinkStore.shared
    private let ai = AIService()
    private let settingsWindow = SettingsWindow()
    private var menuBar: MenuBarController?  // hosts menu-bar command-mode extensions as NSStatusItems
    // Background `interval` commands (Raycast): run headlessly on a timer with launchType "background".
    private struct IntervalSpec { let cmdId, extKey, rel, cname: String; let seconds: TimeInterval; let prefsSpec: [[String: Any]] }
    private var intervalSpecs: [IntervalSpec] = []
    /// Every discovered extension command by id — everything launchCommand() needs to (re)launch a target.
    private struct ExtLaunchable { let extKey, extTitle, title, rel, command, mode: String; let prefsSpec: [[String: Any]] }
    private var extLaunchables: [String: ExtLaunchable] = [:]
    private var intervalTimers: [Timer] = []
    // AI-extension tools (manifest tools[]): per-extension list, used by the @-mode agent loop.
    private struct AIToolSpec { let name, description, rel: String }
    private var aiExtTools: [String: [AIToolSpec]] = [:]
    // Per-command subtitle overrides set via updateCommandMetadata (keyed by command id).
    private var cmdSubtitleOverride: [String: String] = [:]
    private lazy var commands: [RootCommand] = makeCommands()

    private enum Mode { case root, clipboard, emoji, screenshots, snippets, quicklinks, store, extensionView, aiAnswer, nativeForm, aiChat }
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
    /// When the palette auto-hid (focus stolen by a prompt/another app) while showing an extension view.
    /// A re-summon within a short window restores that view instead of resetting to root (Raycast parity).
    private var suspendedExtAt: Date?
    private var currentExtTitle = ""
    private var extReceivedCommit = false // did the current extension render at least once?
    // Bumped on every extension launch; the onTerminate closure captures its launch's generation so a
    // dead child's termination can't tear down a freshly relaunched one (e.g. after Trust & Relaunch).
    private var extLaunchGen = 0
    private struct LaunchInfo { let id, title, entryRelPath, command, preferences: String; let noView: Bool; var arguments: String = "{}" }
    private var lastLaunch: LaunchInfo? // the most recent launch, replayed by Trust & Relaunch
    private var nativeFormTitle = ""
    private var nativeFormSubmit: (([String: String]) -> Void)? // called with field values on submit
    private var repoRoot = ""
    private var selectedIndex = 0
    private var rootTree: ViewTree?
    private var lastQuery = ""
    /// Navigation (render-on-push): the child mounts each pushed view as its own frame and streams it;
    /// the host displays the active frame's tree. `navDepth` (0 = base) drives the back-chevron + Esc
    /// routing; `activeFrame` is the frame id whose tree is shown. Lower frames stay mounted (state kept).
    private var navDepth = 0
    private var activeFrame = 0
    private var selectionByFrame: [Int: Int] = [:] // remembered selectedIndex per nav frame (restored on pop)

    // Built-in list/grid filtering: when an extension's surface does NOT handle onSearchTextChange,
    // Raycast filters items by the search text against title/subtitle/keywords. This holds that query.
    private var extSearchFilter = ""
    private var searchThrottleWork: DispatchWorkItem?

    private var activeTree: ViewTree {
        if mode == .extensionView, let extHost {
            let raw = extHost.frameTree(activeFrame)
            if !extSearchFilter.isEmpty, hostShouldFilter() {
                return Self.filterTree(raw, query: extSearchFilter)
            }
            return raw
        }
        return rootTree ?? host.tree
    }

    /// The active extension's top-level list/grid node (the search surface), or nil.
    private func searchSurfaceNode() -> ViewNode? {
        extHost?.frameTree(activeFrame).root.children.first { ["list", "grid"].contains($0.type) }
    }

    /// True if the search surface declares its own onSearchTextChange (then the extension filters).
    private func surfaceHasSearchHandler() -> Bool {
        searchSurfaceNode()?.props["onSearchTextChange"]?.handlerRef != nil
    }

    /// Whether the HOST applies its built-in item filter. An explicit `filtering` prop wins; otherwise
    /// the host filters only when the surface has no onSearchTextChange handler (Raycast default).
    private func hostShouldFilter() -> Bool {
        if case .bool(let f)? = searchSurfaceNode()?.props["filtering"] { return f }
        return !surfaceHasSearchHandler()
    }

    private static func itemMatches(_ n: ViewNode, _ q: String) -> Bool {
        for f in [n.props["title"]?.stringValue, n.text, n.props["subtitle"]?.stringValue] {
            if let f, f.lowercased().contains(q) { return true }
        }
        if case .array(let kws)? = n.props["keywords"] { for k in kws { if (k.stringValue ?? "").lowercased().contains(q) { return true } } }
        return false
    }

    /// A copy of `tree` with list/grid items not matching `query` removed (sections that lose all their
    /// items are dropped). Non-item nodes (action panels, empty views, dropdowns) are preserved.
    private static func filterTree(_ tree: ViewTree, query: String) -> ViewTree {
        let q = query.lowercased()
        func filter(_ n: ViewNode) -> ViewNode? {
            switch n.type {
            case "list-item", "grid-item":
                return itemMatches(n, q) ? n : nil
            case "list-section", "grid-section":
                let hadItems = n.children.contains { ["list-item", "grid-item"].contains($0.type) }
                let kept = n.children.compactMap(filter)
                let keptItems = kept.contains { ["list-item", "grid-item"].contains($0.type) }
                if hadItems && !keptItems { return nil } // section's items all filtered out → drop it
                let c = ViewNode(id: n.id, type: n.type, text: n.text, props: n.props); c.children = kept; return c
            default:
                let c = ViewNode(id: n.id, type: n.type, text: n.text, props: n.props)
                c.children = n.children.compactMap(filter)
                return c
            }
        }
        let copy = ViewTree()
        copy.root.children = tree.root.children.compactMap(filter)
        return copy
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
        var argSpec: [[String: Any]] = [] // Raycast command arguments → inline search-bar chips
        var disabledByDefault: Bool = false // manifest disabledByDefault: true → hidden until user enables
        var fallbackEligible: Bool = false // true only for query-driven commands (view/no-view/AI-ask); false for menu-bar, interval/background, and system built-ins
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

        palette.onAutoHide = { [weak self] in
            guard let self else { return }
            if self.mode == .extensionView, self.extHost != nil { self.suspendedExtAt = Date() }
        }
        palette.onSearchChange = { [weak self] text in self?.onSearch(text) }
        palette.onMove = { [weak self] delta in self?.moveSelection(delta) }
        palette.onActivate = { [weak self] secondary in self?.activateSelection(secondary: secondary) }
        palette.onCancel = { [weak self] in
            guard let self else { return }
            if self.pendingQuicklink != nil {
                self.cancelQuicklinkInput() // back to the quicklink list, not all the way to root
            } else if self.navDepth > 0 {
                self.extHost?.navPop() // pop a pushed view; the child unmounts it and sends `nav` back
            } else if self.mode != .root {
                self.exitToRoot()
            } else {
                self.palette.hide()
            }
        }
        palette.actionsProvider = { [weak self] in self?.currentActions() ?? [] }
        palette.actionSectionsProvider = { [weak self] in self?.currentActionSections() ?? [] }
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
        palette.onFormFieldChange = { [weak self] handler, value in self?.extHost?.invoke(handler: handler, args: [.string(value)]) }
        palette.onFormCheckboxChange = { [weak self] handler, on in self?.extHost?.invoke(handler: handler, args: [.bool(on)]) }
        palette.onInvokeHandler = { [weak self] handler in self?.extHost?.invoke(handler: handler) }
        palette.onReachedEnd = { [weak self] in self?.handleReachedEnd() }

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

        // Menu-bar command hosting (NSStatusItem). Its extensions' capability calls route through the
        // same handleCapability path, scoped to the menu-bar extension's grant key for the call.
        menuBar = MenuBarController(repoRoot: repoRoot)
        menuBar?.capability = { [weak self] extKey, method, params in
            self?.menuBarCapability(extKey: extKey, method: method, params: params) ?? .null
        }
        menuBar?.capabilityAsync = { [weak self] extKey, method, params, reply, fail in
            self?.menuBarCapabilityAsync(extKey: extKey, method: method, params: params, reply: reply, fail: fail) ?? false
        }
        menuBar?.fs = { [weak self] extKey, op, params, supportPath, assetsPath in
            self?.handleFS(op, params, extKey: extKey, title: extKey, supportPath: supportPath, assetsPath: assetsPath)
                ?? .object(["error": .string("[invoke:fs] host unavailable"), "code": .string("EIO")])
        }

        let entry = ProcessInfo.processInfo.environment["INVOKE_EXT_ENTRY"] ?? "examples/calculator/src/calculate.tsx"
        let command = ProcessInfo.processInfo.environment["INVOKE_EXT_COMMAND"] ?? "calculate"
        host.launch(repoRoot: repoRoot, entryRelPath: entry, command: command)

        appIndex.build()
        clipboard.start()
        clipboard.capacity = AppSettings.shared.clipboardLimit
        print("[invoke:host] app index: \(appIndex.count) applications · \(commands.count) commands")

        // ⌥Space is the one truly-fixed global hotkey (summon the root). Everything else — Clipboard
        // History's ⌘⇧V and Window Management's ⌃⌥arrows — is a configurable per-command hotkey, seeded
        // as a default below and editable in Settings → Extensions.
        hotkey.register(id: 1, keyCode: UInt32(kVK_Space), modifiers: UInt32(optionKey)) { [weak self] in
            self?.summonToggle()
        }
        let winMods = UInt32(controlKey | optionKey) // ⌃⌥ — default modifier for Window Management
        print("[invoke:host] global hotkeys: ⌥Space (summon) · per-command via Settings → Extensions")
        // Reserve only ⌥Space so the recorder won't let a command shadow it (Carbon would drop the
        // duplicate registration silently). ⌘⇧V and the ⌃⌥arrows are NOT reserved — they're editable
        // per-command defaults seeded just below.
        AppSettings.reservedCombos = [
            AppSettings.comboKey(keyCode: UInt32(kVK_Space), modifiers: UInt32(optionKey)),
        ]
        // Seed built-in default hotkeys ONCE per batch (the user can change/clear them afterwards; we
        // don't re-seed once a batch's flag is set). All register via the per-command path below.
        if !UserDefaults.standard.bool(forKey: "hotkeyDefaultsSeeded") {
            if AppSettings.shared.hotkey(for: "clipboard.history") == nil {
                AppSettings.shared.setHotkey("clipboard.history",
                    AppSettings.KeyCombo(keyCode: UInt32(kVK_ANSI_V), modifiers: UInt32(cmdKey | shiftKey), display: "⌘⇧V"))
            }
            UserDefaults.standard.set(true, forKey: "hotkeyDefaultsSeeded")
        }
        // Window Management defaults use a SEPARATE flag: an existing install already has
        // hotkeyDefaultsSeeded set from the clipboard batch, so reusing it would skip these.
        if !UserDefaults.standard.bool(forKey: "windowHotkeyDefaultsSeeded") {
            let winDefaults: [(id: String, keyCode: UInt32, display: String)] = [
                ("window.leftHalf",  UInt32(kVK_LeftArrow),  "⌃⌥←"),
                ("window.rightHalf", UInt32(kVK_RightArrow), "⌃⌥→"),
                ("window.maximize",  UInt32(kVK_UpArrow),    "⌃⌥↑"),
            ]
            for d in winDefaults where AppSettings.shared.hotkey(for: d.id) == nil {
                AppSettings.shared.setHotkey(d.id,
                    AppSettings.KeyCombo(keyCode: d.keyCode, modifiers: winMods, display: d.display))
            }
            UserDefaults.standard.set(true, forKey: "windowHotkeyDefaultsSeeded")
        }
        AppSettings.shared.reconcileLaunchAtLogin() // didSet is skipped for the in-init assignment
        reloadCommandHotkeys() // user-assigned per-command hotkeys from Settings
        scheduleIntervals() // start background interval commands (intervalSpecs populated by discovery above)

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
        if mode == .store { renderStore(query: text); return }
        if mode == .quicklinks {
            if pendingQuicklink != nil { renderQuicklinkPrompt() } else { renderQuicklinks(query: text) }
            return
        }
        if mode == .extensionView {
            let surface = searchSurfaceNode()
            let hasHandler = surface?.props["onSearchTextChange"]?.handlerRef != nil
            let hostFilter: Bool = { if case .bool(let f)? = surface?.props["filtering"] { return f }; return !hasHandler }()
            let throttle: Bool = { if case .bool(let t)? = surface?.props["throttle"] { return t }; return false }()
            extSearchFilter = hostFilter ? text : ""
            searchThrottleWork?.cancel()
            if hasHandler {
                if throttle {
                    let work = DispatchWorkItem { [weak self] in self?.extHost?.setSearchText(text) }
                    searchThrottleWork = work
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: work) // ~250ms debounce
                } else {
                    extHost?.setSearchText(text)
                }
            }
            if hostFilter { selectedIndex = 0; renderExtension() }
            return
        }
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
        // If the palette auto-hid (a prompt/another app stole focus) while showing an extension view,
        // re-summoning RESTORES that live view instead of resetting to root (Raycast parity), within a
        // short window. Keep the original pasteTarget (don't re-capture — the prompt's app may be front).
        if let suspended = suspendedExtAt, Date().timeIntervalSince(suspended) < 120,
           mode == .extensionView, extHost != nil {
            suspendedExtAt = nil
            palette.show()
        } else {
            suspendedExtAt = nil
            captureTarget(); exitToRoot(); palette.show()
        }
        let syncMs = Double(DispatchTime.now().uptimeNanoseconds - t0.uptimeNanoseconds) / 1_000_000
        DispatchQueue.main.async {
            let frameMs = Double(DispatchTime.now().uptimeNanoseconds - t0.uptimeNanoseconds) / 1_000_000
            print(String(format: "[invoke:perf] summon %.1fms (sync %.1fms) · budget 150ms (PLAN §1)", frameMs, syncMs))
        }
    }

    /// Move/resize a window via Accessibility (target = the captured pasteTarget — the app focused
    /// before the palette/hotkey fired). Prompts for the grant if missing.
    private func applyWindow(_ action: WindowManager.Action, pid: pid_t?) {
        guard AXIsProcessTrusted() else {
            Self.promptAccessibility()
            palette.showToast("Enable Accessibility for Invoke to manage windows")
            return
        }
        if let pid { windowManager.applyCycling(action, pid: pid, enabled: AppSettings.shared.windowCyclingEnabled) }
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
        suspendedExtAt = nil
        palette.dismissToast() // clear any persistent actionable toast before the surface changes
        teardownExtension()
        mode = .root
        pendingQuicklink = nil
        palette.hideSearchDropdown() // drop the extension's engine dropdown (also hides the filter)
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

    // MARK: - Store (browse + 1-click install of Raycast extensions)

    private struct StoreExt: Decodable {
        struct Cmd: Decodable { let name, title, mode: String }
        let name, title, description, author, icon: String
        let categories: [String]
        let commands: [Cmd]
    }
    private struct StoreIndexFile: Decodable { let extensions: [StoreExt] }
    /// The browse/search index (tools/store-index/extensions-index.json), parsed once.
    private lazy var storeIndex: [StoreExt] = {
        let p = repoRoot + "/tools/store-index/extensions-index.json"
        guard let data = FileManager.default.contents(atPath: p),
              let idx = try? JSONDecoder().decode(StoreIndexFile.self, from: data) else {
            print("[invoke:store] index unavailable at \(p)")
            return []
        }
        return idx.extensions
    }()

    private static func storeIconURL(_ e: StoreExt) -> String? {
        guard !e.icon.isEmpty else { return nil }
        return "https://raw.githubusercontent.com/raycast/extensions/main/extensions/\(e.name)/assets/\(e.icon)"
    }

    private func storeMatches(_ query: String) -> [StoreExt] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        let pool = storeIndex
        let hits = q.isEmpty ? pool : pool.filter {
            $0.title.lowercased().contains(q) || $0.name.lowercased().contains(q) ||
            $0.author.lowercased().contains(q) || $0.description.lowercased().contains(q)
        }
        return Array(hits.prefix(200)) // cap the rendered tree; the search field narrows it
    }

    private func enterStore() {
        mode = .store
        lastQuery = ""
        palette.clearSearch()
        palette.setPlaceholder("Search extensions to install…")
        selectedIndex = 0
        renderStore(query: "")
    }

    private func renderStore(query: String) {
        let count = storeMatches(query).count
        if selectedIndex >= count { selectedIndex = max(0, count - 1) }
        rootTree = buildStore(query: query, selectedIndex: selectedIndex)
        palette.render(activeTree, selectedIndex: selectedIndex)
        updateActionBar()
    }

    private func buildStore(query: String, selectedIndex: Int) -> ViewTree {
        let tree = ViewTree()
        let list = ViewNode(id: 1, type: "list")
        let matches = storeMatches(query)
        if matches.isEmpty {
            let msg = storeIndex.isEmpty ? "Store index unavailable" : (query.isEmpty ? "No extensions" : "No matching extensions")
            list.children = [ViewNode(id: 2, type: "list-section", props: ["title": .string(msg)])]
        } else {
            list.props["showDetail"] = .bool(true) // master–detail (reuses the virtualized split)
            let section = ViewNode(id: 2, type: "list-section", props: ["title": .string("\(matches.count) Extension\(matches.count == 1 ? "" : "s")")])
            var nid = 10
            for (i, ext) in matches.enumerated() {
                nid += 1
                var props: [String: JSONValue] = [
                    "title": .string(ext.title),
                    "subtitle": .string(ext.author),
                    "extName": .string(ext.name), // the Install action keys on this
                ]
                if let iconURL = Self.storeIconURL(ext) { props["icon"] = .string(iconURL) } // lazy remote load
                let item = ViewNode(id: nid, type: "list-item", props: props)
                if i == selectedIndex { // rich detail only for the selected row (like clipboard's thumb)
                    item.children = [ViewNode(id: nid * 1000, type: "list-item-detail",
                                              props: ["markdown": .string(Self.storeMarkdown(ext))])]
                }
                section.children.append(item)
            }
            list.children = [section]
        }
        tree.root.children = [list]
        return tree
    }

    private static func storeMarkdown(_ e: StoreExt) -> String {
        var md = "## \(e.title)\n\n\(e.description)\n\n**Author:** \(e.author)"
        if !e.categories.isEmpty { md += "  ·  \(e.categories.joined(separator: ", "))" }
        md += "\n"
        if !e.commands.isEmpty {
            md += "\n**Commands**\n"
            for c in e.commands { md += "\n- \(c.title)  _(\(c.mode))_" }
        }
        md += "\n\n_Installs trusted — runs with full access, like Raycast._"
        return md
    }

    /// Fetch + install a Store extension (always trusted, per product decision), then relaunch so the
    /// freshly-imported commands appear (the command list is built at launch).
    private func installStoreExtension(name: String, title: String) {
        hud.show("Installing \(title)…")
        let root = repoRoot
        Task { [weak self] in
            let result = await ExtensionImporter(repoRoot: root).install(name: name, trusted: true)
            await MainActor.run {
                guard let self else { return }
                switch result {
                case .success(let report):
                    // Always-trusted: mark the imported extension trusted → it launches unsandboxed.
                    AppSettings.shared.setTrusted("ext.imported-\(Self.sanitizeKeySegment(report.id))", true)
                    self.hud.show("Installed \(report.title) — relaunching…")
                    relaunchInvoke()
                case .failure(let err):
                    self.hud.show("Install failed: \(err.message)")
                }
            }
        }
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
        palette.clearArguments() // leaving the root command list — drop any inline argument chips
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
        updateRootArguments()
    }

    /// The RootCommand backing the currently-selected row (nil for apps / AI / non-command rows).
    private func selectedRootCommand() -> RootCommand? {
        let rows = items()
        guard selectedIndex >= 0, selectedIndex < rows.count,
              let cid = rows[selectedIndex].props["commandId"]?.stringValue else { return nil }
        return commands.first { $0.id == cid }
    }

    /// Show inline argument chips (Raycast parity) for the selected command, or hide them. Called on
    /// every selection/render change in root mode.
    private func updateRootArguments() {
        guard mode == .root, let cmd = selectedRootCommand(), !cmd.argSpec.isEmpty else {
            palette.clearArguments(); return
        }
        let specs = cmd.argSpec.compactMap { a -> (name: String, placeholder: String)? in
            guard let n = a["name"] as? String else { return nil }
            return (name: n, placeholder: (a["placeholder"] as? String) ?? n)
        }
        palette.setArguments(specs, iconPath: cmd.iconPath)
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

            // Fallback commands — shown at the bottom ONLY when nothing else matched (no commands, no apps).
            // Each id in fallbackCommands is resolved from `commands` regardless of isEnabled (a
            // disabledByDefault command added as a fallback is still eligible to receive the query).
            if cmdItems.isEmpty && appItems.isEmpty && calcCard == nil {
                let settings = AppSettings.shared
                let fbItems: [ViewNode] = settings.fallbackCommands.compactMap { fbId in
                    guard let cmd = commands.first(where: { $0.id == fbId }) else { return nil }
                    let node = itemNode(id: nextId(), title: cmd.title, subtitle: cmd.subtitle,
                                       kind: "Command", appPath: nil, icon: cmd.icon, commandId: nil,
                                       iconPath: cmd.iconPath)
                    // Mark as a fallback row so currentActions() knows to pass fallbackText on activation.
                    node.props["fallbackCommandId"] = .string(fbId)
                    // Echo the query as an accessory tag so the user sees "Fallback" + their query text.
                    node.props["accessories"] = .array([.object(["text": .string("Fallback")]), .object(["tag": .string(q)])])
                    return node
                }
                if !fbItems.isEmpty {
                    sections.append(sectionNode("Fallback Commands", fbItems))
                }
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

    private func itemNode(id: Int, title titleArg: String, subtitle subtitleArg: String?, kind: String, appPath: String?, icon: String?, commandId: String?, alias: String? = nil, iconPath: String? = nil) -> ViewNode {
        let title = titleArg
        // A command can update its own subtitle via updateCommandMetadata (Raycast) — e.g. a "days until"
        // command showing the live count in the launcher. Apply any override.
        let subtitle = (commandId.flatMap { cmdSubtitleOverride[$0] }) ?? subtitleArg
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
        case .store: renderStore(query: lastQuery)              // rebuild so the detail pane follows
        default:
            // Screenshots (grid) and the rest just re-highlight the existing tree — no rebuild, no
            // thumbnail re-scan — so arrow nav stays snappy. selectionOnly enables the virtualized fast path.
            palette.render(activeTree, selectedIndex: selectedIndex, selectionOnly: true)
            updateActionBar()
            updateRootArguments()
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
        case .store: renderStore(query: lastQuery)
        default:
            palette.render(activeTree, selectedIndex: selectedIndex, selectionOnly: true)
            updateActionBar()
            updateRootArguments()
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
        case .store: label = "Store"
        case .extensionView:
            // Show the pushed view's title with a back chevron when navigated in.
            if navDepth > 0 {
                label = "‹ " + (extensionSurfaceNode()?.props["navigationTitle"]?.stringValue ?? currentExtTitle)
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

        if let extName = node.props["extName"]?.stringValue {
            return [PaletteAction(title: "Install Extension", shortcut: "↵", icon: "square.and.arrow.down") { [weak self] in
                self?.installStoreExtension(name: extName, title: node.props["title"]?.stringValue ?? extName)
            }]
        }
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
        // Fallback-command row: launch the command passing the current query as LaunchProps.fallbackText.
        // Does NOT re-filter by isEnabled — a disabledByDefault command added as a fallback still launches.
        if let fbId = node.props["fallbackCommandId"]?.stringValue,
           let cmd = commands.first(where: { $0.id == fbId }) {
            let q = lastQuery // captured at action-build time; safe because currentActions() is called just before activation
            // ai.chat built-in: seed the chat with the query directly.
            if fbId == "ai.chat" {
                return [PaletteAction(title: "Ask AI", shortcut: "↵", icon: cmd.icon) { [weak self] in
                    self?.enterAIChat(initial: q)
                }]
            }
            // Extension commands (view or no-view): resolve via extLaunchables and thread fallbackText.
            if let target = extLaunchables[fbId] {
                return [PaletteAction(title: cmd.runTitle, shortcut: "↵", icon: cmd.icon) { [weak self] in
                    guard let self else { return }
                    self.launchExtensionCommand(extKey: target.extKey, extTitle: target.extTitle,
                                                spec: target.prefsSpec, argSpec: cmd.argSpec,
                                                commandTitle: cmd.title, providedArgs: nil) { prefs, args in
                        if target.mode == "no-view" {
                            // runNoViewExtension bumps frecency internally — do not bump here.
                            self.runNoViewExtension(id: fbId, title: cmd.title, entryRelPath: target.rel,
                                                    command: target.command, preferences: prefs, arguments: args,
                                                    fallbackText: q)
                        } else {
                            // launchExtension does not bump — bump here for the view path.
                            self.frecency.bump("cmd:\(fbId)")
                            self.launchExtension(id: fbId, title: cmd.title, entryRelPath: target.rel,
                                                 command: target.command, preferences: prefs, arguments: args,
                                                 fallbackText: q)
                        }
                    }
                }]
            }
            // Generic built-in fallback (e.g. snippet search, clipboard history): run normally.
            // fallbackText does not apply to these, but they still launch in response to the query.
            return [PaletteAction(title: cmd.runTitle, shortcut: "↵", icon: cmd.icon) { [weak self] in
                self?.frecency.bump("cmd:\(fbId)")
                cmd.run()
                if cmd.closesPalette { self?.afterLaunch() }
            }]
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
        palette.clearArguments() // drop any inline argument chips before hiding
        palette.hide()
        teardownExtension()
        mode = .root
        pendingQuicklink = nil
        palette.hideSearchDropdown() // also hides the filter; clears any extension engine dropdown
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
    /// The trust unit for capability consent / trust is the EXTENSION, not the individual command —
    /// "ext.apple-notes.index" and "ext.apple-notes.add-text" share one key, so the user isn't
    /// re-prompted (or re-trusted) for every command. (Built-in command ids pass through.) This is also
    /// the key used for the trust toggle and the Settings extension-group id.
    static func extGrantKey(forId id: String) -> String {
        let parts = id.split(separator: ".")
        if id.hasPrefix("ext."), parts.count >= 2 { return "ext.\(parts[1])" }
        return id
    }

    /// A directory/manifest name used as the "<key>" segment of an "ext.<key>.<cmd>" command id must not
    /// contain the "." separator: extGrantKey() splits on "." and takes parts[1], so a dotted key would
    /// be truncated mid-key and let two distinct extensions collapse to ONE trust/consent grant key (a
    /// later, untrusted extension could then inherit an earlier one's trust). import.ts already forbids
    /// "." in imported ids; this also guards bundled/manually-added directories. The real on-disk name is
    /// still used for file paths — only the id/key segment is sanitized.
    static func sanitizeKeySegment(_ name: String) -> String {
        name.replacingOccurrences(of: ".", with: "-")
    }
    private var currentExtGrantKey: String { Self.extGrantKey(forId: currentExtId) }

    /// blocking dialog on the main thread (handleCapability is invoked on main).
    private func ensureAppleScriptGrant() -> Bool {
        let id = currentExtGrantKey
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

    /// confirmAlert (async): show the in-palette confirmation modal and reply with the choice. Replaces
    /// the old blocking NSAlert (a separate window that stole focus → the palette auto-hid and the list
    /// vanished). Stays in-palette so the underlying list re-renders after the delete resolves.
    /// Capabilities whose result isn't ready synchronously (a modal click, a network round-trip). Returns
    /// true if this method was taken (the reply is deferred); false to fall back to the sync handler.
    /// Run a menu-bar extension's capability scoped to its grant key, restoring the palette's currentExtId
    /// after (menu-bar hosts run concurrently with the palette; a click must not leave currentExtId changed).
    private func menuBarCapability(extKey: String, method: String, params: JSONValue?) -> JSONValue {
        let saved = currentExtId; currentExtId = extKey
        defer { currentExtId = saved }
        return handleCapability(method, params)
    }
    private func menuBarCapabilityAsync(extKey: String, method: String, params: JSONValue?, reply: @escaping (JSONValue) -> Void, fail: @escaping (String) -> Void) -> Bool {
        let saved = currentExtId; currentExtId = extKey
        defer { currentExtId = saved }
        return handleAsyncCapability(method, params, reply: reply, fail: fail)
    }

    private func handleAsyncCapability(_ method: String, _ params: JSONValue?, reply: @escaping (JSONValue) -> Void, fail: @escaping (String) -> Void) -> Bool {
        func arg(_ key: String) -> JSONValue? { if case .object(let o)? = params { return o[key] }; return nil }
        switch method {
        case "confirmAlert":
            presentConfirmAlert(params, reply: reply)
            return true
        case "ai.ask":
            // Raycast's AI.ask / useAI — a single-prompt completion via the host's Anthropic client.
            let prompt = arg("prompt")?.stringValue ?? ""
            guard !prompt.isEmpty else { reply(.string("")); return true }
            guard ai.hasKey else {
                palette.showToast("Set your Anthropic API key in Settings → Advanced to use AI")
                reply(.string(""))
                return true
            }
            let system = arg("system")?.stringValue ?? "You are a helpful assistant."
            Task { [weak self] in
                guard let self else { return }
                let result = await self.ai.complete(system: system, user: prompt, maxTokens: 2000)
                await MainActor.run {
                    switch result {
                    case .success(let out): reply(.string(out))
                    case .failure(let err):
                        self.palette.showToast("AI: \(err.message)")
                        reply(.string(""))
                    }
                }
            }
            return true
        case "browser.getTabs":
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let result: JSONValue
                do {
                    let tabs = try BrowserDriver.getTabs()
                    result = .array(tabs.map { t in .object([
                        "id": .string(t.id), "url": .string(t.url), "title": .string(t.title), "active": .bool(t.active),
                    ]) })
                } catch {
                    DispatchQueue.main.async { self?.showBrowserError(error) }
                    result = .array([])
                }
                DispatchQueue.main.async { reply(result) }
            }
            return true
        case "browser.getContent":
            let tabId = arg("tabId")?.stringValue
            let format = arg("format")?.stringValue ?? "text"
            let css = arg("cssSelector")?.stringValue
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let result: JSONValue
                do { result = .string(try BrowserDriver.getContent(tabId: tabId, format: format, cssSelector: css)) }
                catch { DispatchQueue.main.async { self?.showBrowserError(error) }; result = .string("") }
                DispatchQueue.main.async { reply(result) }
            }
            return true
        case "runAppleScript":
            // Raycast's runAppleScript. Runs OFF the main thread — NSAppleScript can block a long time
            // (resolving/launching the target app, or waiting on the macOS Automation prompt), which on the
            // main thread froze the whole UI. Gated: `do shell script` refused; default-deny per-extension
            // consent; macOS TCC still prompts on first automation of another app. (Script text not logged.)
            let asSource = arg("source")?.stringValue ?? ""
            guard !asSource.isEmpty else { reply(.string("")); return true }
            if asSource.range(of: "do[ \\t]+shell[ \\t]+script", options: .regularExpression) != nil {
                palette.showToast("Blocked: “\(currentExtTitle)” tried to run a shell command via AppleScript")
                print("[invoke:ext] runAppleScript blocked (do shell script) from \(currentExtId)")
                reply(.string("")); return true
            }
            guard ensureAppleScriptGrant() else { reply(.string("")); return true }
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                // osascript subprocess (NOT NSAppleScript) — reliable off-main; NSAppleScript on a
                // background queue returned empty results + spurious "No error." (no run loop).
                let r = AppleScriptRunner.run(asSource)
                DispatchQueue.main.async {
                    if r.exitCode == 0 {
                        reply(.string(r.output))
                    } else if r.automationDenied {
                        // Host-level permission gate: guide the user, then REJECT (don't resolve "") so
                        // the extension's call throws rather than silently seeing empty output.
                        self?.presentPermissionHelp(.automation)
                        fail("Not authorized to send Apple events. Grant Automation access in System Settings → Privacy & Security → Automation.")
                    } else {
                        // Script/compile/runtime error → REJECT so the extension's `runAppleScript` throws,
                        // matching Raycast (the extension decides whether to surface it). Resolving "" here
                        // masked the error and broke extensions whose own error handling depends on the
                        // throw — e.g. browser-tabs tries a WebKit script, catches its failure, and falls
                        // back to the Chromium script; swallowing the throw made it think WebKit succeeded.
                        // The host must NOT show its own toast: a recovered error would flash spuriously.
                        let msg = r.stderr.trimmingCharacters(in: .whitespacesAndNewlines)
                        fail(msg.isEmpty ? "AppleScript failed" : msg)
                    }
                }
            }
            return true
        case "oauth.authorize":
            // Open the provider's authorize URL in the browser; resolve when the invoke://oauth-callback
            // redirect arrives with a matching state (captured by openDeeplink → resolveOAuthCallback).
            guard case .object(let req)? = arg("request"),
                  let urlStr = req["authorizeURL"]?.stringValue ?? buildOAuthAuthorizeURL(req),
                  let state = req["state"]?.stringValue, !state.isEmpty,
                  let url = URL(string: urlStr) else { reply(.null); return true }
            pendingOAuth[state] = reply
            print("[invoke:oauth] authorize → opening browser (state=\(state.prefix(8))…, redirect=invoke://oauth-callback)")
            NSWorkspace.shared.open(url)
            // Safety timeout so a child RPC never hangs forever if the user abandons the browser flow.
            DispatchQueue.main.asyncAfter(deadline: .now() + 300) { [weak self] in
                if let cb = self?.pendingOAuth.removeValue(forKey: state) { cb(.null) }
            }
            return true
        case "windowManagement.getActiveWindow":
            DispatchQueue.main.async {
                guard self.windowEnumerator.hasAccessibility else { Self.promptAccessibility(); fail("Accessibility permission is required for window management — grant it in the dialog (or System Settings → Privacy & Security → Accessibility), then reopen this command"); return }
                guard let w = self.windowEnumerator.activeWindow() else { fail("No active window"); return }
                reply(Self.windowJSON(w))
            }
            return true
        case "windowManagement.getWindowsOnActiveDesktop":
            DispatchQueue.main.async {
                guard self.windowEnumerator.hasAccessibility else { Self.promptAccessibility(); fail("Accessibility permission is required for window management — grant it in the dialog (or System Settings → Privacy & Security → Accessibility), then reopen this command"); return }
                reply(.array(self.windowEnumerator.windowsOnActiveDesktop().map(Self.windowJSON)))
            }
            return true
        case "windowManagement.getDesktops":
            DispatchQueue.main.async { reply(.array(self.windowEnumerator.desktops().map(Self.desktopJSON))) }
            return true
        case "windowManagement.setWindowBounds":
            DispatchQueue.main.async {
                guard self.windowEnumerator.hasAccessibility else { Self.promptAccessibility(); fail("Accessibility permission is required for window management — grant it in the dialog (or System Settings → Privacy & Security → Accessibility), then reopen this command"); return }
                let id = arg("id")?.stringValue ?? ""
                let b = { (k: String) -> JSONValue? in if case .object(let o)? = arg("bounds") { return o[k] }; return nil }
                let pos = { (k: String) -> Double? in if case .object(let o)? = b("position") { return o[k]?.doubleValue }; return nil }
                let size = { (k: String) -> Double? in if case .object(let o)? = b("size") { return o[k]?.doubleValue }; return nil }
                guard let w = self.windowEnumerator.setBounds(id: id, x: pos("x"), y: pos("y"), width: size("width"), height: size("height")) else {
                    fail("Window not found: \(id)"); return
                }
                reply(Self.windowJSON(w))
            }
            return true
        default:
            return false
        }
    }

    /// Surface a BrowserDriver failure with the specific actionable message (automation TCC, JS toggle,
    /// no browser, or a raw script error).
    private func showBrowserError(_ error: Error) {
        let msg: String
        switch error {
        case BrowserError.noBrowser: msg = "No supported browser is running. Open Chrome, Brave, Arc, Edge, or Safari."
        case BrowserError.automationDenied(let m): msg = m
        case BrowserError.jsDisabled(let m): msg = m
        case BrowserError.script(let m): msg = "Browser: \(m)"
        default: msg = "Browser: \(error.localizedDescription)"
        }
        palette.showToast(msg)
    }

    /// Pending OAuth authorize calls, keyed by `state`; resolved by the invoke://oauth-callback redirect.
    /// The reply returns { authorizationCode } to the child.
    private var pendingOAuth: [String: (JSONValue) -> Void] = [:]

    /// Resolve a captured OAuth redirect (invoke://oauth-callback?code=&state=). Validates `state`.
    func resolveOAuthCallback(_ url: URL) {
        guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        let items = comps.queryItems ?? []
        let state = items.first(where: { $0.name == "state" })?.value ?? ""
        let code = items.first(where: { $0.name == "code" })?.value ?? ""
        print("[invoke:oauth] callback received (state=\(state.prefix(8))…, code=\(code.isEmpty ? "MISSING" : "present"), known-state=\(pendingOAuth[state] != nil))")
        guard let reply = pendingOAuth.removeValue(forKey: state) else { return } // unknown/expired state → ignore
        if code.isEmpty { reply(.null) } else { reply(.object(["authorizationCode": .string(code)])) }
        palette.show() // bring Invoke back to the foreground after the browser hand-off
    }

    private func buildOAuthAuthorizeURL(_ req: [String: JSONValue]) -> String? {
        guard let endpoint = req["authorizationEndpoint"]?.stringValue, var comps = URLComponents(string: endpoint) else { return nil }
        var q = comps.queryItems ?? []
        q.append(.init(name: "client_id", value: req["clientId"]?.stringValue ?? ""))
        q.append(.init(name: "response_type", value: "code"))
        q.append(.init(name: "redirect_uri", value: req["redirectURI"]?.stringValue ?? ""))
        q.append(.init(name: "scope", value: req["scope"]?.stringValue ?? ""))
        q.append(.init(name: "code_challenge", value: req["codeChallenge"]?.stringValue ?? ""))
        q.append(.init(name: "code_challenge_method", value: "S256"))
        q.append(.init(name: "state", value: req["state"]?.stringValue ?? ""))
        comps.queryItems = q
        return comps.url?.absoluteString
    }

    /// Stable per-extension key for an alert's remembered choice (rememberUserChoice). Same content ⇒
    /// same key (Raycast semantics). Used by BOTH the async (in-palette) and sync (NSAlert) handlers.
    private func alertRememberKey(title: String, message: String) -> String {
        "alertRemember.\(currentExtId).\(title)\u{1}\(message)"
    }

    private func presentConfirmAlert(_ params: JSONValue?, reply: @escaping (JSONValue) -> Void) {
        func arg(_ key: String) -> JSONValue? { if case .object(let o)? = params { return o[key] }; return nil }
        let title = arg("title")?.stringValue ?? ""
        let message = arg("message")?.stringValue
        // Decode rememberUserChoice inline (isTrue is private to PaletteView).
        var remember = false
        if case .bool(let b)? = arg("rememberUserChoice") { remember = b }
        // Skip the modal if the user previously ticked "Don't ask again" for this alert.
        let rememberKey = alertRememberKey(title: title, message: message ?? "")
        if remember, UserDefaults.standard.object(forKey: rememberKey) != nil {
            reply(.bool(UserDefaults.standard.bool(forKey: rememberKey))); return
        }
        // Icon: SF-symbol name best-effort (sfSymbol mapper is private to PaletteView; use raw string only).
        var icon: NSImage? = nil
        if let src = arg("icon")?.stringValue, !src.isEmpty {
            icon = NSImage(systemSymbolName: src, accessibilityDescription: nil)
        }
        palette.presentConfirm(
            title: title,
            message: message,
            primaryTitle: arg("primaryTitle")?.stringValue ?? "OK",
            destructive: arg("primaryStyle")?.stringValue == "destructive",
            dismissTitle: arg("dismissTitle")?.stringValue ?? "Cancel",
            icon: icon,
            rememberable: remember,
            dismissDestructive: arg("dismissStyle")?.stringValue == "destructive"
        ) { result, rememberChoice in
            if remember, rememberChoice { UserDefaults.standard.set(result, forKey: rememberKey) }
            reply(.bool(result))
        }
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
            // Toast.ActionOptions → buttons (foreground only; headless HUD has no window for buttons).
            func action(_ key: String) -> (title: String, handler: String)? {
                if case .object(let o)? = arg(key), let t = o["title"]?.stringValue, let h = o["__handler"]?.stringValue {
                    return (t, h)
                }
                return nil
            }
            let acts = [action("primaryAction"), action("secondaryAction")].compactMap { $0 }
            // Explicit dismiss: Toast.hide() / handle.hide() sends title="" message=nil/empty actions=[].
            if method == "toast.show", title.isEmpty, (message ?? "").isEmpty, acts.isEmpty {
                palette.dismissToast()
                return .null
            }
            if method == "toast.show", palette.isVisible, !acts.isEmpty {
                palette.showToast(title, actions: acts.map { a in (a.title, { [weak self] in self?.extHost?.invoke(handler: a.handler) }) })
            } else if !text.isEmpty {
                if method == "hud.show" || !palette.isVisible { hud.show(text) }
                else { palette.showToast(text) }
            }
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
        // NOTE: runAppleScript moved to handleAsyncCapability — NSAppleScript on the MAIN thread froze the
        // whole app whenever a script blocked (e.g. a browser-scripting extension stalling on the macOS
        // Automation prompt / app launch). It now runs off-main and replies async.
        case "executeSQL":
            // Read-only SQLite capability (Raycast's useSQL/executeSQL). The sandboxed child has no fs;
            // the host opens the file and is NOT itself OS-sandboxed, so reading an arbitrary SQLite path
            // is a file-disclosure primitive — gated several ways (PLAN.md §4.4):
            //   • default-deny per-extension consent (a blocking dialog naming the extension + the path).
            //   • opened SQLITE_OPEN_READONLY (no writes, no journal creation).
            //   • an authorizer that allows only SELECT/READ/FUNCTION — so ATTACH (which would reach
            //     other files) and every mutating/PRAGMA statement is denied.
            let raw = ((arg("db")?.stringValue ?? "") as NSString).expandingTildeInPath
            let query = arg("query")?.stringValue ?? ""
            guard !raw.isEmpty, !query.isEmpty else { return .array([]) }
            // Canonicalize (resolve symlinks + . / ..) so the path the user consents to is EXACTLY the
            // file we open — a later call can't smuggle a different file under a string that merely
            // looks like an approved one.
            let dbPath = URL(fileURLWithPath: raw).resolvingSymlinksInPath().path
            guard ensureSQLGrant(dbPath: dbPath) else { return .array([]) }
            switch Self.runReadOnlySQL(path: dbPath, query: query) {
            case .success(let rows):
                return .array(rows.map { JSONValue.object($0) })
            case .failure(let err):
                print("[invoke:ext] executeSQL failed for \(currentExtId): \(err.message)")
                // A failure to OPEN the file is almost always macOS TCC on a protected location (Notes,
                // Messages, …) — offer Full Disk Access. A prepare/step failure is a real SQL error.
                if err.isOpenFailure {
                    presentPermissionHelp(.fullDiskAccess)
                } else {
                    palette.showToast("SQL: \(err.message)")
                }
                return .array([])
            }
        case "confirmAlert":
            // Native confirm for headless/background hosts (no palette window). runModal() blocks on the
            // main queue so the child's await resolves with the choice. Honors Alert.Options icon +
            // rememberUserChoice (suppression checkbox) + dismissStyle, matching the in-palette modal.
            let title = arg("title")?.stringValue ?? ""
            let message = arg("message")?.stringValue ?? ""
            let remember: Bool = { if case .bool(let b)? = arg("rememberUserChoice") { return b }; return false }()
            let key = alertRememberKey(title: title, message: message)
            if remember, UserDefaults.standard.object(forKey: key) != nil {
                return .bool(UserDefaults.standard.bool(forKey: key))
            }
            let alert = NSAlert()
            alert.messageText = title
            if !message.isEmpty { alert.informativeText = message }
            if let src = arg("icon")?.stringValue, let img = NSImage(systemSymbolName: src, accessibilityDescription: nil) {
                alert.icon = img
            }
            let primary = alert.addButton(withTitle: arg("primaryTitle")?.stringValue ?? "OK")
            let dismiss = alert.addButton(withTitle: arg("dismissTitle")?.stringValue ?? "Cancel")
            if arg("primaryStyle")?.stringValue == "destructive" {
                alert.alertStyle = .critical
                if #available(macOS 11.0, *) { primary.hasDestructiveAction = true }
            }
            if arg("dismissStyle")?.stringValue == "destructive", #available(macOS 11.0, *) {
                dismiss.hasDestructiveAction = true
            }
            if remember {
                alert.showsSuppressionButton = true
                alert.suppressionButton?.title = "Don't ask again"
            }
            let confirmed = alert.runModal() == .alertFirstButtonReturn
            if remember, alert.suppressionButton?.state == .on {
                UserDefaults.standard.set(confirmed, forKey: key)
            }
            return .bool(confirmed)
        case "preferences.open":
            // open{Extension,Command}Preferences — summon Settings on this extension. Edited prefs apply on
            // the next command launch (they arrive via INVOKE_PREFERENCES at spawn), matching Raycast.
            openSettings(tab: .commands)
            return .null
        case "captureException":
            // Diagnostic only (no UI). The message body isn't logged — it may carry user content.
            print("[invoke:ext] captureException from \(currentExtId)")
            return .null
        case "command.updateMetadata":
            // updateCommandMetadata({subtitle}): set the command's subtitle in the launcher (currentExtId
            // is the command id). Re-render the root if it's showing so the new subtitle appears.
            if case .string(let sub)? = arg("subtitle") { cmdSubtitleOverride[currentExtId] = sub }
            else { cmdSubtitleOverride[currentExtId] = nil }
            if mode == .root { renderRoot(calcCard: nil) }
            return .null
        case "command.launch":
            // launchCommand({name, type, extensionName?, arguments?, context?}): resolve a target command
            // (a sibling by `name`, or one in `extensionName`) and launch it — foreground for a view command,
            // headless for no-view / type:"background" — passing arguments + launchContext.
            let launchName = arg("name")?.stringValue ?? ""
            guard !launchName.isEmpty else { return .null }
            let launchKind = arg("type")?.stringValue ?? "userInitiated"
            guard let targetId = resolveLaunchTarget(name: launchName, extensionName: arg("extensionName")?.stringValue),
                  let target = extLaunchables[targetId] else {
                palette.showToast("Couldn’t find command “\(launchName)” to launch")
                return .null
            }
            let argsJSON = Self.jsonString(arg("arguments")) ?? "{}"
            let ctxJSON = Self.jsonString(arg("context")) ?? "{}"
            // Defer so this RPC's reply is sent before we (possibly) tear the caller's view down.
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.launchExtensionCommand(extKey: target.extKey, extTitle: target.extTitle, spec: target.prefsSpec,
                                            commandTitle: target.title, providedArgs: argsJSON) { prefs, args in
                    if launchKind == "background" {
                        self.runBackgroundCommand(id: targetId, title: target.title, entryRelPath: target.rel,
                                                  command: target.command, preferences: prefs, arguments: args, launchContext: ctxJSON)
                    } else if target.mode == "no-view" {
                        self.runNoViewExtension(id: targetId, title: target.title, entryRelPath: target.rel,
                                                command: target.command, preferences: prefs, arguments: args, launchContext: ctxJSON)
                    } else if target.mode == "menu-bar" {
                        let paths = self.extensionPaths(id: targetId, entryRelPath: target.rel)
                        if self.menuBar?.isShowing(targetId) != true {
                            self.menuBar?.toggle(cmdId: targetId, extKey: Self.extGrantKey(forId: targetId),
                                                 entryRelPath: target.rel, command: target.command, preferences: prefs,
                                                 trusted: AppSettings.shared.isTrusted(Self.extGrantKey(forId: targetId)),
                                                 assetsPath: paths.assets, supportPath: paths.support)
                        }
                    } else {
                        self.launchExtension(id: targetId, title: target.title, entryRelPath: target.rel,
                                             command: target.command, preferences: prefs, arguments: args, launchContext: ctxJSON)
                    }
                }
            }
            return .null
        case "cache.set":
            cacheStorageSet(arg("key")?.stringValue ?? "", value: arg("value")?.stringValue ?? "")
            return .null
        case "cache.remove":
            cacheStorageRemove(arg("key")?.stringValue ?? "")
            return .null
        case "cache.clear":
            cacheStorageClear(namespace: arg("namespace")?.stringValue ?? "")
            return .null
        case "cache.allItems":
            return .object(cacheStorageAll().mapValues { JSONValue.string($0) })

        // --- selection / application / finder / filesystem (remediation 04) ---
        case "app.frontmost":
            if let t = pasteTarget {
                return Self.applicationJSON(name: t.localizedName ?? "", path: t.bundleURL?.path ?? "", bundleId: t.bundleIdentifier)
            }
            if let f = NSWorkspace.shared.frontmostApplication {
                return Self.applicationJSON(name: f.localizedName ?? "", path: f.bundleURL?.path ?? "", bundleId: f.bundleIdentifier)
            }
            return .null
        case "app.list":
            var urls: [URL] = []
            if let p = arg("path")?.stringValue, !p.isEmpty {
                let u = p.contains("://") ? URL(string: p) : URL(fileURLWithPath: (p as NSString).expandingTildeInPath)
                if let u { urls = NSWorkspace.shared.urlsForApplications(toOpen: u) }
            } else {
                let dirs = ["/Applications", "/System/Applications", "/System/Applications/Utilities",
                            (NSHomeDirectory() as NSString).appendingPathComponent("Applications")]
                var seen = Set<String>()
                for d in dirs {
                    for i in (try? FileManager.default.contentsOfDirectory(atPath: d)) ?? [] where i.hasSuffix(".app") {
                        let path = (d as NSString).appendingPathComponent(i)
                        if seen.insert(path).inserted { urls.append(URL(fileURLWithPath: path)) }
                    }
                }
            }
            return .array(urls.map { Self.applicationJSON(url: $0) })
        case "app.default":
            guard let p = arg("path")?.stringValue, !p.isEmpty else { return .null }
            let url = p.contains("://") ? URL(string: p) : URL(fileURLWithPath: (p as NSString).expandingTildeInPath)
            guard let url, let appURL = NSWorkspace.shared.urlForApplication(toOpen: url) else { return .null }
            return Self.applicationJSON(url: appURL)
        case "finder.reveal":
            let path = ((arg("path")?.stringValue ?? "") as NSString).expandingTildeInPath
            guard !path.isEmpty, FileManager.default.fileExists(atPath: path) else { return .null }
            NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: path)])
            return .null
        case "quicklink.create":
            // Action.CreateQuicklink → add to Invoke's quicklink store (real, persisted).
            let qlLink = arg("link")?.stringValue ?? ""
            let qlName = arg("name")?.stringValue ?? ""
            guard !qlLink.isEmpty else { palette.showToast("Quicklink needs a link"); return .null }
            _ = quicklinkStore.add(Quicklink(name: qlName.isEmpty ? qlLink : qlName, link: qlLink))
            hud.show("Added quicklink “\(qlName.isEmpty ? qlLink : qlName)”")
            return .null
        case "snippet.create":
            // Action.CreateSnippet → add to Invoke's snippet store (real, persisted).
            let snipText = arg("text")?.stringValue ?? ""
            let snipName = arg("name")?.stringValue ?? ""
            guard !snipText.isEmpty else { palette.showToast("Snippet needs text"); return .null }
            _ = snippetStore.add(Snippet(name: snipName.isEmpty ? String(snipText.prefix(40)) : snipName,
                                         keyword: arg("keyword")?.stringValue ?? "", content: snipText))
            hud.show("Added snippet “\(snipName.isEmpty ? String(snipText.prefix(24)) : snipName)”")
            return .null
        case "clipboard.read":
            // Clipboard.read() → { text, file, html }. With offset >= 1, read an OLDER entry from the
            // in-memory clipboard history (offset 0 / absent = the live pasteboard — the richest read).
            // History excludes concealed clips (ClipboardHistory.poll), so password-manager copies never appear.
            // The api guards offset (finite, >= 1, floored), but a raw RPC frame could send NaN/∞/huge —
            // Int(Double) traps on those. Floor + sanity-cap, falling back to the live read (offset 0) on garbage.
            let offsetRaw = arg("offset")?.doubleValue ?? 0
            let offset = (offsetRaw.isFinite && offsetRaw >= 1 && offsetRaw < 1_000_000) ? Int(offsetRaw) : 0
            if offset >= 1 {
                guard let clip = clipboard.entry(at: offset) else { return .object(["text": .string("")]) }
                var cb: [String: JSONValue] = [:]
                switch clip.kind {
                case "File":
                    cb["text"] = .string(clip.filePath ?? clip.text)
                    if let p = clip.filePath { cb["file"] = .string(p) }
                case "Image":
                    cb["text"] = .string("") // image clips carry no text/file path
                default: // "Text" / "Link"
                    cb["text"] = .string(clip.text)
                }
                return .object(cb)
            }
            let pb = NSPasteboard.general
            var cb: [String: JSONValue] = [:]
            if let t = pb.string(forType: .string) { cb["text"] = .string(t) }
            if let urls = pb.readObjects(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) as? [URL],
               let f = urls.first { cb["file"] = .string(f.path) }
            if let html = pb.string(forType: .html) { cb["html"] = .string(html) }
            return .object(cb)
        case "clipboard.clear":
            NSPasteboard.general.clearContents()
            return .null
        case "quicklook.preview":
            // Action.ToggleQuickLook → real macOS Quick Look via qlmanage -p.
            let qlPath = ((arg("path")?.stringValue ?? "") as NSString).expandingTildeInPath
            guard !qlPath.isEmpty, FileManager.default.fileExists(atPath: qlPath) else { return .null }
            let ql = Process()
            ql.executableURL = URL(fileURLWithPath: "/usr/bin/qlmanage")
            ql.arguments = ["-p", qlPath]
            ql.standardOutput = FileHandle.nullDevice
            ql.standardError = FileHandle.nullDevice
            try? ql.run()
            return .null
        case "open.with":
            // Action.OpenWith → choose an application that can open the file, then open with it.
            let owPath = ((arg("path")?.stringValue ?? arg("target")?.stringValue ?? "") as NSString).expandingTildeInPath
            guard !owPath.isEmpty, FileManager.default.fileExists(atPath: owPath) else { return .null }
            openWithChooser(path: owPath)
            return .null
        case "date.pick":
            // Action.PickDate → native date picker; returns the chosen date as an ISO-8601 string (or null).
            let dp = NSDatePicker(frame: NSRect(x: 0, y: 0, width: 220, height: 148))
            dp.datePickerStyle = .clockAndCalendar
            dp.datePickerElements = [.yearMonthDay]
            dp.dateValue = Date()
            let dpAlert = NSAlert()
            dpAlert.messageText = arg("title")?.stringValue ?? "Pick a date"
            dpAlert.accessoryView = dp
            dpAlert.addButton(withTitle: "Select")
            dpAlert.addButton(withTitle: "Cancel")
            guard dpAlert.runModal() == .alertFirstButtonReturn else { return .null }
            return .string(ISO8601DateFormatter().string(from: dp.dateValue))
        case "finder.selection":
            // Reuse the gated AppleScript path: get Finder's selection as POSIX paths (newline-joined).
            guard ensureAppleScriptGrant() else { return .array([]) }
            let script = "tell application \"Finder\" to set _s to selection as alias list\n"
                + "set _o to \"\"\nrepeat with _i in _s\nset _o to _o & POSIX path of _i & linefeed\nend repeat\nreturn _o"
            var fErr: NSDictionary?
            let fResult = NSAppleScript(source: script)?.executeAndReturnError(&fErr)
            if let fErr {
                if ((fErr[NSAppleScript.errorNumber] as? NSNumber)?.intValue ?? 0) == -1743 { presentPermissionHelp(.automation) }
                return .array([])
            }
            let paths = (fResult?.stringValue ?? "").split(separator: "\n").map(String.init).filter { !$0.isEmpty }
            return .array(paths.map { JSONValue.object(["path": .string($0)]) })
        case "selection.read":
            // Read the captured app's focused element's selected text via Accessibility (no clipboard
            // mutation). Invoke is frontmost while the palette is open, so query pasteTarget's pid directly.
            guard AXIsProcessTrusted() else {
                Self.promptAccessibility()
                palette.showToast("Enable Accessibility for Invoke to read the selection")
                return .string("")
            }
            guard let pid = pasteTarget?.processIdentifier else { return .string("") }
            var focused: AnyObject?
            guard AXUIElementCopyAttributeValue(AXUIElementCreateApplication(pid), kAXFocusedUIElementAttribute as CFString, &focused) == .success,
                  let el = focused else { return .string("") }
            var sel: AnyObject?
            // swiftlint:disable:next force_cast
            let ok = AXUIElementCopyAttributeValue(el as! AXUIElement, kAXSelectedTextAttribute as CFString, &sel) == .success
            return .string((ok ? sel as? String : nil) ?? "")
        case "fs.trash":
            var rawPaths: [String] = []
            if case .array(let a)? = arg("paths") { rawPaths = a.compactMap { $0.stringValue } }
            let expanded = rawPaths.map { ($0 as NSString).expandingTildeInPath }.filter { !$0.isEmpty }
            guard !expanded.isEmpty else { return .null }
            // Domain guard: never trash root / system / library / the app bundle, even with consent.
            for path in expanded {
                let p = URL(fileURLWithPath: path).resolvingSymlinksInPath().path
                if p == "/" || p.hasPrefix("/System") || p.hasPrefix("/Library") || p.hasPrefix(Bundle.main.bundlePath) {
                    palette.showToast("Refused to trash a protected path")
                    return .string("refused: protected path")
                }
            }
            guard ensureTrashGrant(paths: expanded) else { return .string("denied") }
            var failures: [String] = []
            for path in expanded {
                do { try FileManager.default.trashItem(at: URL(fileURLWithPath: path), resultingItemURL: nil) }
                catch { failures.append((path as NSString).lastPathComponent) }
            }
            if !failures.isEmpty { presentPermissionHelp(.fullDiskAccess) }
            return failures.isEmpty ? .null : .string("failed to trash: \(failures.joined(separator: ", "))")

        // --- OAuth (PKCE). authorize is async (handleAsyncCapability); these are sync. ---
        case "oauth.authorizeRequest":
            // Generate PKCE verifier/challenge + state host-side; keep the verifier OUT of the child only
            // for the request it needs to exchange — Raycast passes codeVerifier back, so we include it.
            let verifier = Self.randomURLSafe(64)
            let challenge = Self.s256Challenge(verifier)
            let state = Self.randomURLSafe(24)
            let redirectURI = "invoke://oauth-callback"
            return .object([
                "authorizationEndpoint": .string(arg("endpoint")?.stringValue ?? ""),
                "clientId": .string(arg("clientId")?.stringValue ?? ""),
                "scope": .string(arg("scope")?.stringValue ?? ""),
                "redirectURI": .string(redirectURI),
                "codeChallenge": .string(challenge),
                "codeVerifier": .string(verifier),
                "state": .string(state),
            ])
        case "oauth.setTokens":
            guard case .object(let t)? = arg("tokens") else { return .null }
            let provider = arg("provider")?.stringValue ?? "default"
            // Accept both the raw token-endpoint response (access_token/expires_in) and the normalized set.
            let access = t["access_token"]?.stringValue ?? t["accessToken"]?.stringValue ?? ""
            let refresh = t["refresh_token"]?.stringValue ?? t["refreshToken"]?.stringValue
            let idTok = t["id_token"]?.stringValue ?? t["idToken"]?.stringValue
            let scope = t["scope"]?.stringValue
            var stored: [String: JSONValue] = ["accessToken": .string(access)]
            if let refresh { stored["refreshToken"] = .string(refresh) }
            if let idTok { stored["idToken"] = .string(idTok) }
            if let scope { stored["scope"] = .string(scope) }
            if let exp = (t["expires_in"]?.doubleValue ?? t["expiresIn"]?.doubleValue) {
                stored["expiresAt"] = .number(Date().timeIntervalSince1970 * 1000 + exp * 1000)
            }
            if let data = try? JSONEncoder().encode(JSONValue.object(stored)), let json = String(data: data, encoding: .utf8) {
                AppSettings.shared.oauthTokensSet(extID: currentExtGrantKey, provider: provider, json: json)
            }
            return .null
        case "oauth.getTokens":
            let provider = arg("provider")?.stringValue ?? "default"
            guard let json = AppSettings.shared.oauthTokensGet(extID: currentExtGrantKey, provider: provider),
                  let data = json.data(using: .utf8),
                  let val = try? JSONDecoder().decode(JSONValue.self, from: data) else { return .null }
            return val
        case "oauth.removeTokens":
            AppSettings.shared.oauthTokensRemove(extID: currentExtGrantKey, provider: arg("provider")?.stringValue ?? "default")
            return .null
        default:
            return .null
        }
    }

    // PKCE helpers (RFC 7636). Verifier is URL-safe base64 of random bytes; challenge = base64url(SHA256(verifier)).
    private static func randomURLSafe(_ bytes: Int) -> String {
        var data = Data(count: bytes)
        _ = data.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, bytes, $0.baseAddress!) }
        return base64URL(data)
    }
    private static func s256Challenge(_ verifier: String) -> String {
        base64URL(Data(SHA256.hash(data: Data(verifier.utf8))))
    }
    private static func base64URL(_ d: Data) -> String {
        d.base64EncodedString().replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
    }

    private static func windowJSON(_ w: WindowInfo) -> JSONValue {
        var app: [String: JSONValue] = [:]
        if let n = w.appName { app["name"] = .string(n) }
        if let p = w.appPath { app["path"] = .string(p) }
        if let b = w.bundleId { app["bundleId"] = .string(b) }
        var obj: [String: JSONValue] = [
            "id": .string(w.id),
            "bounds": .object(["position": .object(["x": .number(w.x), "y": .number(w.y)]),
                               "size": .object(["width": .number(w.width), "height": .number(w.height)])]),
            "desktopId": .string(w.desktopId),
            "active": .bool(w.active),
            "fullScreen": .bool(w.fullScreen),
        ]
        if !app.isEmpty { obj["application"] = .object(app) }
        return .object(obj)
    }
    private static func desktopJSON(_ d: DesktopInfo) -> JSONValue {
        .object(["id": .string(d.id), "screenId": .string(d.screenId),
                 "size": .object(["width": .number(d.width), "height": .number(d.height)]),
                 "active": .bool(d.active), "type": .string(d.fullScreen ? "fullScreen" : "user")])
    }

    private static func applicationJSON(name: String, path: String, bundleId: String?) -> JSONValue {
        var o: [String: JSONValue] = ["name": .string(name), "path": .string(path), "localizedName": .string(name)]
        if let bundleId { o["bundleId"] = .string(bundleId) }
        return .object(o)
    }
    private static func applicationJSON(url: URL) -> JSONValue {
        let name = (FileManager.default.displayName(atPath: url.path) as NSString).deletingPathExtension
        return applicationJSON(name: name, path: url.path, bundleId: Bundle(url: url)?.bundleIdentifier)
    }

    /// Default-deny per-extension consent for moving files to the Trash (the only destructive API in the
    /// group). Recoverable, so a single per-extension grant is proportionate; the dialog names the items.
    private func ensureTrashGrant(paths: [String]) -> Bool {
        let id = currentExtGrantKey
        guard !id.isEmpty else { return false }
        if AppSettings.shared.trashGrants.contains(id) { return true }
        let alert = NSAlert()
        alert.messageText = "Allow “\(currentExtTitle)” to move files to the Trash?"
        let names = paths.prefix(5).map { ($0 as NSString).lastPathComponent }.joined(separator: ", ")
        alert.informativeText = "It wants to trash: \(names)\(paths.count > 5 ? " …" : "").\nItems go to the Trash (recoverable). Only allow extensions you trust."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Allow")
        alert.addButton(withTitle: "Don’t Allow")
        let allow = alert.runModal() == .alertFirstButtonReturn
        if allow { AppSettings.shared.trashGrants.insert(id) }
        return allow
    }

    /// Default-deny consent for the read-only SQLite capability, scoped to the specific
    /// (extension, canonical file) PAIR — never just the extension. A grant for NoteStore.sqlite must
    /// NOT silently authorize the same extension to later read Messages chat.db, Safari history, etc.
    /// (confused-deputy file disclosure). Blocking dialog on the main thread.
    private func ensureSQLGrant(dbPath: String) -> Bool {
        let id = currentExtGrantKey
        guard !id.isEmpty else { return false }
        let key = id + "\u{0}" + dbPath // NUL separates the parts; a filesystem path can't contain NUL
        if AppSettings.shared.sqlGrants.contains(key) { return true }
        let alert = NSAlert()
        alert.messageText = "Allow “\(currentExtTitle)” to read a local database?"
        alert.informativeText = "It wants read-only access to:\n\(dbPath)\n\nThe query runs read-only (no changes, no access to other files). You’ll be asked again for any other file. Only allow extensions you trust."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Allow")
        alert.addButton(withTitle: "Don’t Allow")
        let allow = alert.runModal() == .alertFirstButtonReturn
        if allow { AppSettings.shared.sqlGrants.insert(key) }
        return allow
    }

    // MARK: - Virtual filesystem (fd-4) mediation — remediation 01

    /// Mediate ONE virtual-`fs` op for a SANDBOXED extension. Called on the host's fd-4 responder thread
    /// (NOT main) — the child is blocked awaiting this reply. We default-deny: every real path is gated by
    /// a per-(extension, folder) consent prompt (shown on main), EXCEPT the extension's own support/assets
    /// dirs and the system temp dir, which are platform-assigned scratch and auto-allowed. On allow we run
    /// the real op and return the wire shape fs-host.ts documents (`{...result}` or `{error, code?}`).
    func handleFS(_ op: String, _ params: JSONValue?, extKey: String, title: String,
                  supportPath: String, assetsPath: String) -> JSONValue {
        func arg(_ k: String) -> JSONValue? { if case .object(let o)? = params { return o[k] }; return nil }
        func str(_ k: String) -> String { arg(k)?.stringValue ?? "" }
        func flag(_ k: String) -> Bool { if case .bool(let b)? = arg(k) { return b }; return false }

        // Which path(s) does this op touch, and is it a mutation? Drives the consent gate below.
        let isWrite: Bool
        let targets: [String]
        switch op {
        case "read", "exists", "stat", "realpath", "readdir": isWrite = false; targets = [str("path")]
        case "write", "mkdir", "rm": isWrite = true; targets = [str("path")]
        case "rename", "copyFile": isWrite = true; targets = [str("from"), str("to")]
        case "mkdtemp": isWrite = true; targets = [str("prefix")]
        default:
            return .object(["error": .string("[invoke:fs] unknown op \"\(op)\""), "code": .string("EINVAL")])
        }

        // Consent, one prompt per distinct folder. `readdir` (listing a folder) and `mkdir` (creating a
        // folder) consent on the TARGET folder itself — so creating ~/Documents/AppData grants only that
        // subtree, NOT all of ~/Documents (least privilege). Every other op consents on the PARENT folder
        // of its target (you're acting on an item inside that folder).
        var prompted = Set<String>()
        for t in targets where !t.isEmpty {
            let dir = (op == "readdir" || op == "mkdir") ? Self.canonicalDir(t)
                                                         : Self.canonicalDir((t as NSString).deletingLastPathComponent)
            if dir.isEmpty || prompted.contains(dir) { continue }
            prompted.insert(dir)
            if isAutoAllowedFSDir(dir, supportPath: supportPath, assetsPath: assetsPath) { continue }
            if !ensureFSGrant(extKey: extKey, title: title, dir: dir, write: isWrite) {
                return .object(["error": .string("EACCES: “\(title)” was not allowed to access \(dir)"),
                                "code": .string("EACCES")])
            }
        }
        return Self.performFS(op, str: str, flag: flag)
    }

    /// Perform one fs op against the real filesystem AFTER consent. Mirrors `fulfillFsOp` in fs-host.ts.
    /// POSIX syscalls are used where the errno matters, so the child's shim re-throws real ENOENT/EACCES/
    /// EISDIR codes (extensions branch on `err.code`).
    private static func performFS(_ op: String, str: (String) -> String, flag: (String) -> Bool) -> JSONValue {
        let fm = FileManager.default
        let p = str("path")
        switch op {
        case "read":
            let fd = open(p, O_RDONLY)
            if fd < 0 { return errnoReply(errno, path: p, syscall: "open") }
            defer { close(fd) }
            var data = Data()
            var buf = [UInt8](repeating: 0, count: 1 << 16)
            while true {
                let n = read(fd, &buf, buf.count)
                if n < 0 { return errnoReply(errno, path: p, syscall: "read") }
                if n == 0 { break }
                data.append(contentsOf: buf[0..<n])
            }
            return .object(["base64": .string(data.base64EncodedString())])
        case "write":
            let bytes = Data(base64Encoded: str("base64")) ?? Data()
            let oflags = O_WRONLY | O_CREAT | (str("flag") == "a" ? O_APPEND : O_TRUNC)
            let fd = open(p, oflags, 0o644)
            if fd < 0 { return errnoReply(errno, path: p, syscall: "open") }
            defer { close(fd) }
            let werr = bytes.withUnsafeBytes { (raw: UnsafeRawBufferPointer) -> Int32 in
                guard let base = raw.baseAddress else { return 0 }
                var off = 0
                while off < raw.count {
                    let w = write(fd, base.advanced(by: off), raw.count - off)
                    if w <= 0 { return errno }
                    off += w
                }
                return 0
            }
            if werr != 0 { return errnoReply(werr, path: p, syscall: "write") }
            return .object(["ok": .bool(true)])
        case "exists":
            return .object(["exists": .bool(fm.fileExists(atPath: p))])
        case "readdir":
            guard let names = try? fm.contentsOfDirectory(atPath: p) else {
                var st = Darwin.stat()
                let code = (stat(p, &st) != 0) ? errnoName(errno) : "ENOTDIR"
                return .object(["error": .string("\(code): readdir '\(p)'"), "code": .string(code)])
            }
            let entries: [JSONValue] = names.map { name in
                let full = (p as NSString).appendingPathComponent(name)
                // attributesOfItem does NOT follow symlinks (like Dirent/lstat), matching Node's withFileTypes.
                let t = (try? fm.attributesOfItem(atPath: full))?[.type] as? FileAttributeType
                return .object([
                    "name": .string(name),
                    "file": .bool(t == .typeRegular),
                    "dir": .bool(t == .typeDirectory),
                    "symlink": .bool(t == .typeSymbolicLink),
                ])
            }
            return .object(["entries": .array(entries)])
        case "stat":
            var st = Darwin.stat()
            let rc = flag("lstat") ? lstat(p, &st) : stat(p, &st)
            if rc != 0 { return errnoReply(errno, path: p, syscall: "stat") }
            let fmt = st.st_mode & S_IFMT
            return .object([
                "size": .number(Double(st.st_size)),
                "mode": .number(Double(st.st_mode)),
                "uid": .number(Double(st.st_uid)),
                "gid": .number(Double(st.st_gid)),
                "blksize": .number(Double(st.st_blksize)),
                "blocks": .number(Double(st.st_blocks)),
                "atimeMs": .number(timespecMs(st.st_atimespec)),
                "mtimeMs": .number(timespecMs(st.st_mtimespec)),
                "ctimeMs": .number(timespecMs(st.st_ctimespec)),
                "birthtimeMs": .number(timespecMs(st.st_birthtimespec)),
                "isFile": .bool(fmt == S_IFREG),
                "isDirectory": .bool(fmt == S_IFDIR),
                "isSymbolicLink": .bool(fmt == S_IFLNK),
            ])
        case "mkdir":
            do { try fm.createDirectory(atPath: p, withIntermediateDirectories: flag("recursive")) }
            catch { return cocoaReply(error, path: p) }
            return .object(["path": .string(p)])
        case "rm":
            if !fm.fileExists(atPath: p) {
                if flag("force") { return .object(["ok": .bool(true)]) } // rmSync({force}) ignores ENOENT
                return .object(["error": .string("ENOENT: no such file or directory, '\(p)'"), "code": .string("ENOENT")])
            }
            do { try fm.removeItem(atPath: p) } catch { return cocoaReply(error, path: p) }
            return .object(["ok": .bool(true)])
        case "realpath":
            var out = [CChar](repeating: 0, count: Int(PATH_MAX))
            if realpath(p, &out) == nil { return errnoReply(errno, path: p, syscall: "realpath") }
            return .object(["path": .string(String(cString: out))])
        case "rename":
            if rename(str("from"), str("to")) != 0 { return errnoReply(errno, path: str("from"), syscall: "rename") }
            return .object(["ok": .bool(true)])
        case "copyFile":
            try? fm.removeItem(atPath: str("to")) // copyFileSync overwrites by default; copyItem won't
            do { try fm.copyItem(atPath: str("from"), toPath: str("to")) } catch { return cocoaReply(error, path: str("from")) }
            return .object(["ok": .bool(true)])
        case "mkdtemp":
            var tmpl = Array((str("prefix") + "XXXXXX").utf8CString)
            guard let res = mkdtemp(&tmpl) else { return errnoReply(errno, path: str("prefix"), syscall: "mkdtemp") }
            return .object(["path": .string(String(cString: res))])
        default:
            return .object(["error": .string("[invoke:fs] unknown op \"\(op)\""), "code": .string("EINVAL")])
        }
    }

    private static func timespecMs(_ ts: timespec) -> Double {
        Double(ts.tv_sec) * 1000 + Double(ts.tv_nsec) / 1_000_000
    }

    /// Map a raw errno to the symbolic code Node surfaces as `err.code` (ENOENT is by far the most checked).
    private static func errnoName(_ e: Int32) -> String {
        switch e {
        case ENOENT: return "ENOENT"
        case EACCES: return "EACCES"
        case EEXIST: return "EEXIST"
        case ENOTDIR: return "ENOTDIR"
        case EISDIR: return "EISDIR"
        case ENOTEMPTY: return "ENOTEMPTY"
        case EPERM: return "EPERM"
        case EINVAL: return "EINVAL"
        case EROFS: return "EROFS"
        case ENOSPC: return "ENOSPC"
        case ELOOP: return "ELOOP"
        case ENAMETOOLONG: return "ENAMETOOLONG"
        case EMFILE: return "EMFILE"
        default: return "EIO"
        }
    }

    private static func errnoReply(_ e: Int32, path: String, syscall: String) -> JSONValue {
        let code = errnoName(e)
        return .object(["error": .string("\(code): \(String(cString: strerror(e))), \(syscall) '\(path)'"),
                        "code": .string(code)])
    }

    /// Best-effort errno for a FileManager/Cocoa error (mkdir/rm/copyFile go through FileManager).
    private static func cocoaReply(_ error: Error, path: String) -> JSONValue {
        let ns = error as NSError
        if let u = ns.userInfo[NSUnderlyingErrorKey] as? NSError, u.domain == NSPOSIXErrorDomain {
            return errnoReply(Int32(u.code), path: path, syscall: "op")
        }
        if ns.domain == NSPOSIXErrorDomain { return errnoReply(Int32(ns.code), path: path, syscall: "op") }
        let code: String
        switch ns.code {
        case NSFileNoSuchFileError, NSFileReadNoSuchFileError: code = "ENOENT"
        case NSFileReadNoPermissionError, NSFileWriteNoPermissionError: code = "EACCES"
        case NSFileWriteFileExistsError: code = "EEXIST"
        default: code = "EIO"
        }
        return .object(["error": .string(ns.localizedDescription), "code": .string(code)])
    }

    /// Canonical absolute directory for consent: `~`-expand + resolve symlinks/`.`/`..` so the folder the
    /// user consents to is EXACTLY the one we act under (a later call can't smuggle a different folder).
    private static func canonicalDir(_ p: String) -> String {
        guard !p.isEmpty else { return "" }
        return URL(fileURLWithPath: (p as NSString).expandingTildeInPath).resolvingSymlinksInPath().path
    }

    /// The extension's own support/assets dirs and the system temp dir are platform-assigned private
    /// scratch — auto-allowed without a prompt (prompting for an extension's own store would be absurd).
    private func isAutoAllowedFSDir(_ dir: String, supportPath: String, assetsPath: String) -> Bool {
        for base in [supportPath, assetsPath, NSTemporaryDirectory()] {
            let b = Self.canonicalDir(base)
            if !b.isEmpty, dir == b || dir.hasPrefix(b + "/") { return true }
        }
        return false
    }

    /// Default-deny per-(extension, folder) consent for virtual-fs access. A grant covers the folder and
    /// its descendants; a WRITE grant also satisfies reads. We're on the fd-4 responder thread, so the
    /// blocking prompt (and the AppSettings read/write) is marshaled to main.
    private func ensureFSGrant(extKey: String, title: String, dir: String, write: Bool) -> Bool {
        guard !extKey.isEmpty, !dir.isEmpty else { return false }
        return DispatchQueue.main.sync {
            if fsGranted(extKey: extKey, dir: dir, write: write) { return true }
            let alert = NSAlert()
            alert.messageText = write
                ? "Allow “\(title)” to modify files in this folder?"
                : "Allow “\(title)” to read files in this folder?"
            alert.informativeText = "\(write ? "Read & write" : "Read") access to:\n\(dir)\n\nThis covers files in that folder and its subfolders. You’ll be asked again for other folders. Only allow extensions you trust."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Allow")
            alert.addButton(withTitle: "Don’t Allow")
            let allow = alert.runModal() == .alertFirstButtonReturn
            if allow {
                let key = extKey + "\u{0}" + dir // NUL separates the parts; a filesystem path can't contain NUL
                if write { AppSettings.shared.fsWriteGrants.insert(key) } else { AppSettings.shared.fsReadGrants.insert(key) }
            }
            return allow
        }
    }

    /// True if `dir` (or an ancestor folder) is already granted for this extension. A read is satisfied by
    /// a read OR write grant; a write needs a write grant. Call on MAIN (reads AppSettings).
    private func fsGranted(extKey: String, dir: String, write: Bool) -> Bool {
        let prefix = extKey + "\u{0}"
        func covered(by grants: Set<String>) -> Bool {
            for g in grants where g.hasPrefix(prefix) {
                let gdir = String(g.dropFirst(prefix.count))
                if dir == gdir || dir.hasPrefix(gdir + "/") { return true }
            }
            return false
        }
        if write { return covered(by: AppSettings.shared.fsWriteGrants) }
        return covered(by: AppSettings.shared.fsReadGrants) || covered(by: AppSettings.shared.fsWriteGrants)
    }

    // MARK: - launchCommand (inter-command launch)

    /// Resolve a launchCommand target to a command id. With `extensionName`, look in that extension
    /// (imported- or bundled key); otherwise a sibling in the CALLER's extension (currentExtGrantKey).
    private func resolveLaunchTarget(name: String, extensionName: String?) -> String? {
        if let ext = extensionName, !ext.isEmpty {
            for key in ["imported-\(Self.sanitizeKeySegment(ext))", Self.sanitizeKeySegment(ext)] {
                let id = "ext.\(key).\(name)"
                if extLaunchables[id] != nil { return id }
            }
            return nil
        }
        let id = "\(currentExtGrantKey).\(name)" // currentExtGrantKey == "ext.<key>"
        return extLaunchables[id] != nil ? id : nil
    }

    /// Serialize a JSONValue arg to a compact JSON string (for INVOKE_ARGUMENTS / INVOKE_LAUNCH_CONTEXT).
    private static func jsonString(_ value: JSONValue?) -> String? {
        guard let value, let data = try? JSONEncoder().encode(value) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Headless background launch of a command (launchCommand type:"background") — NO palette teardown,
    /// launchType "background", with fs + capabilities wired. Mirrors runBackgroundInterval but carries
    /// the caller-supplied arguments + launchContext.
    private func runBackgroundCommand(id: String, title: String, entryRelPath: String, command: String,
                                      preferences: String, arguments: String, launchContext: String) {
        let key = UUID()
        let h = ExtensionHost()
        h.onLog = { msg in print("[invoke:bg:\(command)] \(msg)") }
        let savedId = id
        h.onCapability = { [weak self] m, p in
            let prev = self?.currentExtId; self?.currentExtId = savedId
            defer { self?.currentExtId = prev ?? "" }
            return self?.handleCapability(m, p) ?? .null
        }
        h.onTerminate = { [weak self] in DispatchQueue.main.async { self?.noViewHosts[key] = nil } }
        h.onSandboxDenial = { [weak self] module in self?.handleSandboxDenial(id: id, title: title, module: module) }
        noViewHosts[key] = h
        let paths = extensionPaths(id: id, entryRelPath: entryRelPath)
        let fsKey = Self.extGrantKey(forId: id)
        h.onFS = { [weak self] op, params in
            self?.handleFS(op, params, extKey: fsKey, title: title, supportPath: paths.support, assetsPath: paths.assets)
                ?? .object(["error": .string("[invoke:fs] host unavailable"), "code": .string("EIO")])
        }
        h.launch(repoRoot: repoRoot, entryRelPath: entryRelPath, command: command, preferences: preferences,
                 mode: "no-view", trusted: AppSettings.shared.isTrusted(fsKey),
                 assetsPath: paths.assets, supportPath: paths.support, arguments: arguments,
                 launchType: "background", launchContext: launchContext)
    }

    /// A macOS TCC denial we can't fix in-app (Full Disk Access / Automation) — offer a one-click jump
    /// to the exact System Settings pane instead of a dead-end toast. Throttled so a burst of failures
    /// (e.g. the several useSQL queries one search fires) collapses into a single prompt.
    private enum PermissionHelp { case fullDiskAccess, automation }
    private static var lastPermissionPrompt: [String: Date] = [:]
    private func presentPermissionHelp(_ kind: PermissionHelp) {
        let key: String, title: String, info: String, urlString: String
        switch kind {
        case .fullDiskAccess:
            key = "fullDiskAccess"
            title = "“\(currentExtTitle)” needs Full Disk Access"
            info = "macOS won’t let Invoke read this database until you grant Full Disk Access. Open Settings, turn on Invoke under Full Disk Access, then quit and reopen Invoke."
            urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
        case .automation:
            key = "automation"
            title = "“\(currentExtTitle)” needs permission to control another app"
            info = "macOS blocks sending commands to the target app (for example Notes) until you allow it. Open Settings → Automation and turn on the target app under Invoke."
            urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation"
        }
        if let last = Self.lastPermissionPrompt[key], Date().timeIntervalSince(last) < 10 { return }
        Self.lastPermissionPrompt[key] = Date()
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = info
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn, let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }

    /// SQLite authorizer: permit only the operations a read-only SELECT needs. SQLITE_ATTACH (reaches
    /// other files), writes, and PRAGMAs are denied. A C function pointer — no captured state.
    private static let sqlAuthorizer: @convention(c) (
        UnsafeMutableRawPointer?, Int32,
        UnsafePointer<CChar>?, UnsafePointer<CChar>?, UnsafePointer<CChar>?, UnsafePointer<CChar>?
    ) -> Int32 = { _, action, _, _, _, _ in
        switch action {
        case SQLITE_SELECT, SQLITE_READ, SQLITE_FUNCTION, SQLITE_RECURSIVE:
            return SQLITE_OK
        default:
            return SQLITE_DENY
        }
    }

    private struct SQLError: Error { let message: String; let isOpenFailure: Bool }

    /// Open `path` read-only and run a single SELECT, returning rows as column→value maps. All access is
    /// constrained by sqlAuthorizer. Returns a human-readable message on failure; `isOpenFailure`
    /// distinguishes a file-open denial (usually macOS TCC) from a SQL/query error.
    private static func runReadOnlySQL(path: String, query: String) -> Result<[[String: JSONValue]], SQLError> {
        let fm = FileManager.default
        // NoteStore.sqlite is a WAL-mode database that Notes is actively writing: the live note rows sit
        // in the -wal sidecar, not yet checkpointed into the main file. Reading the original read-only
        // sees only the (often empty) main file. So copy the db + its -wal/-shm sidecars into a private
        // temp dir and query the COPY — SQLite applies the WAL there and sees everything. (This is what
        // Raycast's useSQL does.) Copying needs read access to the original, i.e. Full Disk Access.
        let tmpDir = (NSTemporaryDirectory() as NSString).appendingPathComponent("invoke-sql-\(UUID().uuidString)")
        try? fm.createDirectory(atPath: tmpDir, withIntermediateDirectories: true)
        defer { try? fm.removeItem(atPath: tmpDir) }
        let dest = (tmpDir as NSString).appendingPathComponent((path as NSString).lastPathComponent)
        do {
            try fm.copyItem(atPath: path, toPath: dest)
        } catch {
            return .failure(SQLError(message: error.localizedDescription, isOpenFailure: true))
        }
        for suffix in ["-wal", "-shm"] where fm.fileExists(atPath: path + suffix) {
            try? fm.copyItem(atPath: path + suffix, toPath: dest + suffix)
        }

        var db: OpaquePointer?
        // Read-write open of the THROWAWAY copy so SQLite can apply/checkpoint the copied WAL; the
        // authorizer below still denies every non-SELECT statement, so queries stay read-only.
        let openRC = sqlite3_open_v2(dest, &db, SQLITE_OPEN_READWRITE, nil)
        defer { sqlite3_close(db) }
        guard openRC == SQLITE_OK else {
            let msg = db.map { String(cString: sqlite3_errmsg($0)) } ?? "cannot open database"
            return .failure(SQLError(message: msg, isOpenFailure: true))
        }
        sqlite3_set_authorizer(db, sqlAuthorizer, nil)

        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK else {
            return .failure(SQLError(message: String(cString: sqlite3_errmsg(db)), isOpenFailure: false))
        }
        defer { sqlite3_finalize(stmt) }

        var rows: [[String: JSONValue]] = []
        let maxRows = 50_000 // backstop so a runaway query can't exhaust memory
        while sqlite3_step(stmt) == SQLITE_ROW {
            if rows.count >= maxRows { break }
            let ncol = sqlite3_column_count(stmt)
            var row: [String: JSONValue] = [:]
            for i in 0..<ncol {
                let name = sqlite3_column_name(stmt, i).map { String(cString: $0) } ?? "col\(i)"
                switch sqlite3_column_type(stmt, i) {
                case SQLITE_INTEGER:
                    row[name] = .number(Double(sqlite3_column_int64(stmt, i)))
                case SQLITE_FLOAT:
                    row[name] = .number(sqlite3_column_double(stmt, i))
                case SQLITE_TEXT:
                    row[name] = sqlite3_column_text(stmt, i).map { JSONValue.string(String(cString: $0)) } ?? .null
                case SQLITE_BLOB:
                    if let bytes = sqlite3_column_blob(stmt, i) {
                        let len = Int(sqlite3_column_bytes(stmt, i))
                        let data = Data(bytes: bytes, count: len)
                        row[name] = .string(data.base64EncodedString())
                    } else {
                        row[name] = .null
                    }
                default:
                    row[name] = .null
                }
            }
            rows.append(row)
        }
        return .success(rows)
    }

    private func setStringPasteboard(_ s: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(s, forType: .string)
    }

    /// Action.OpenWith: list the apps that can open `path`, let the user pick one (icons in a popup), and
    /// open the file with it. Falls back to the default app if none are found.
    private func openWithChooser(path: String) {
        let fileURL = URL(fileURLWithPath: path)
        var apps: [URL] = []
        if #available(macOS 12.0, *) { apps = NSWorkspace.shared.urlsForApplications(toOpen: fileURL) }
        guard !apps.isEmpty else { NSWorkspace.shared.open(fileURL); return }
        let alert = NSAlert()
        alert.messageText = "Open “\((path as NSString).lastPathComponent)” with:"
        let popup = NSPopUpButton(frame: NSRect(x: 0, y: 0, width: 300, height: 26))
        for app in apps {
            let item = NSMenuItem(title: app.deletingPathExtension().lastPathComponent, action: nil, keyEquivalent: "")
            let icon = NSWorkspace.shared.icon(forFile: app.path); icon.size = NSSize(width: 16, height: 16)
            item.image = icon
            item.representedObject = app
            popup.menu?.addItem(item)
        }
        alert.accessoryView = popup
        alert.addButton(withTitle: "Open")
        alert.addButton(withTitle: "Cancel")
        guard alert.runModal() == .alertFirstButtonReturn, let app = popup.selectedItem?.representedObject as? URL else { return }
        if #available(macOS 11.0, *) {
            NSWorkspace.shared.open([fileURL], withApplicationAt: app, configuration: NSWorkspace.OpenConfiguration())
        } else {
            NSWorkspace.shared.open(fileURL)
        }
    }

    private func openTarget(_ target: String) {
        if let url = URL(string: target), let scheme = url.scheme {
            // Extensions reopen the launcher after an external auth prompt via open("raycast://") —
            // e.g. 1Password's AuthProvider closes the window for the biometric prompt, then reopens.
            // We're not Raycast, so handing raycast:// to the OS is a no-op (the palette stays hidden);
            // re-summon our own palette instead (the extension is still alive, so its current view shows).
            if scheme == "raycast" { palette.show(); return }
            NSWorkspace.shared.open(url)
        } else {
            NSWorkspace.shared.open(URL(fileURLWithPath: (target as NSString).expandingTildeInPath))
        }
    }

    private static func jsonScalarString(_ v: JSONValue) -> String {
        switch v {
        case .string(let s): return s
        case .number(let n): return n == n.rounded() ? String(Int(n)) : String(n)
        case .bool(let b): return b ? "true" : "false"
        default: return ""
        }
    }

    // Per-EXTENSION LocalStorage (shared across all of an extension's commands, Raycast semantics),
    // keyed by the extension grant key — NOT currentExtId (the command id), which would isolate each
    // command's storage and break cross-command data sharing (e.g. Perry's manage-databases ↔ search).
    private func extStorageDefaultsKey() -> String { "invoke.ext.ls.\(currentExtGrantKey)" }
    private func extStorageAll() -> [String: String] { (UserDefaults.standard.dictionary(forKey: extStorageDefaultsKey()) as? [String: String]) ?? [:] }
    private func extStorageGet(_ key: String) -> String? { extStorageAll()[key] }
    private func extStorageSet(_ key: String, value: String) { var d = extStorageAll(); d[key] = value; UserDefaults.standard.set(d, forKey: extStorageDefaultsKey()) }
    private func extStorageRemove(_ key: String) { var d = extStorageAll(); d[key] = nil; UserDefaults.standard.set(d, forKey: extStorageDefaultsKey()) }
    private func extStorageClear() { UserDefaults.standard.removeObject(forKey: extStorageDefaultsKey()) }

    // Per-EXTENSION Cache (shared across an extension's commands, like LocalStorage above). Keys arrive
    // already prefixed with the Cache instance's namespace ("<namespace>\0<key>"); cache.clear removes one.
    private func cacheStorageDefaultsKey() -> String { "invoke.ext.cache.\(currentExtGrantKey)" }
    private func cacheStorageAll() -> [String: String] { (UserDefaults.standard.dictionary(forKey: cacheStorageDefaultsKey()) as? [String: String]) ?? [:] }
    private func cacheStorageSet(_ key: String, value: String) { var d = cacheStorageAll(); d[key] = value; UserDefaults.standard.set(d, forKey: cacheStorageDefaultsKey()) }
    private func cacheStorageRemove(_ key: String) { var d = cacheStorageAll(); d[key] = nil; UserDefaults.standard.set(d, forKey: cacheStorageDefaultsKey()) }
    private func cacheStorageClear(namespace: String) {
        let prefix = namespace + "\u{0}"
        var d = cacheStorageAll()
        for k in d.keys where k.hasPrefix(prefix) { d[k] = nil }
        UserDefaults.standard.set(d, forKey: cacheStorageDefaultsKey())
    }

    /// Scan the bundled `examples/*` and `invoke import`-ed `imported/*` for extension manifests and
    /// surface their `view` commands in the root (the calculator is excluded — it's the resident card
    /// provider). A user-writable install dir + a store come later.
    private func discoverExtensionCommands() -> [RootCommand] {
        let fm = FileManager.default
        var out: [RootCommand] = []
        extLaunchables.removeAll() // rebuilt below so launchCommand() resolves only currently-present commands
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
                // alias/hotkey/grouping) with a bundled example of the same name. The KEY uses a
                // dot-sanitized name (the "." separator must not appear mid-key, see sanitizeKeySegment);
                // file paths below still use the real on-disk `name`.
                let keyName = Self.sanitizeKeySegment(name)
                let extKey = root == "imported" ? "imported-\(keyName)" : keyName
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
                // AI extension tools[] (Raycast): each tool is a file (src/tools/<name> or src/<name>)
                // exporting a default async fn. Collect them + register an "Ask <ext>" AI command.
                let toolDefs = (json["tools"] as? [[String: Any]]) ?? []
                if !toolDefs.isEmpty {
                    var specs: [AIToolSpec] = []
                    for t in toolDefs {
                        guard let tname = t["name"] as? String else { continue }
                        guard let trel = ["tsx", "ts", "jsx", "js"].flatMap({ ext in ["src/tools/\(tname).\(ext)", "src/\(tname).\(ext)"] })
                            .map({ "\(root)/\(name)/\($0)" })
                            .first(where: { fm.fileExists(atPath: repoRoot + "/" + $0) }) else { continue }
                        specs.append(AIToolSpec(name: tname, description: (t["description"] as? String) ?? (t["title"] as? String) ?? tname, rel: trel))
                    }
                    if !specs.isEmpty {
                        aiExtTools[extKey] = specs
                        let aiInstructions = (json["ai"] as? [String: Any])?["instructions"] as? String ?? ""
                        let askId = "ext.\(extKey).__ask"
                        out.append(RootCommand(id: askId, title: "Ask \(title)", subtitle: "\(title) · AI", runTitle: "Ask",
                                               icon: "sparkles", iconPath: extIconPath,
                                               keywords: [name, title.lowercased(), "ai", "ask", "@"],
                                               closesPalette: false, argSpec: [], fallbackEligible: true) { [weak self] in
                            self?.promptAIExtension(extKey: extKey, title: title, instructions: aiInstructions)
                        })
                    }
                }
                for c in cmds {
                    guard let cname = c["name"] as? String else { continue }
                    let cmode = (c["mode"] as? String) ?? "view"
                    // `view` renders a UI surface; `no-view` runs an action headlessly; `menu-bar` renders
                    // a MenuBarExtra into an NSStatusItem (toggled on/off from the palette).
                    guard cmode == "view" || cmode == "no-view" || cmode == "menu-bar" else { continue }
                    let ctitle = (c["title"] as? String) ?? cname
                    guard let rel = ["tsx", "ts", "jsx", "js"].lazy
                        .map({ "\(root)/\(name)/src/\(cname).\($0)" })
                        .first(where: { fm.fileExists(atPath: repoRoot + "/" + $0) }) else { continue }
                    let cmdId = "ext.\(extKey).\(cname)"
                    let iconPath = resolveIcon(c["icon"]) ?? extIconPath
                    // Raycast command arguments (collected before the command runs; distinct from prefs).
                    let argSpec = (c["arguments"] as? [[String: Any]]) ?? []
                    let cmdDisabledByDefault = (c["disabledByDefault"] as? Bool) ?? false
                    // Record every command so launchCommand() can resolve + (re)launch it later.
                    extLaunchables[cmdId] = ExtLaunchable(extKey: extKey, extTitle: title, title: ctitle,
                                                          rel: rel, command: cname, mode: cmode, prefsSpec: prefsSpec)
                    // Background `interval` (e.g. "10m"): schedule a headless run on a timer — ONLY for
                    // no-view commands. A menu-bar/view command run as no-view would call its React
                    // component as a plain function → "useState of null". (Menu-bar refresh, when toggled
                    // on, is handled by the live menu-bar host, not the interval scheduler.)
                    var isIntervalNoView = false
                    if cmode == "no-view", let iv = c["interval"] as? String, let secs = Self.parseInterval(iv) {
                        intervalSpecs.append(IntervalSpec(cmdId: cmdId, extKey: extKey, rel: rel, cname: cname, seconds: secs, prefsSpec: prefsSpec))
                        isIntervalNoView = true
                    }
                    if cmode == "menu-bar" {
                        // Many extensions title their menu-bar command identically to a sibling command;
                        // mark it so the two are distinguishable in the list.
                        // fallbackEligible stays false (default): menu-bar commands are toggle-driven, not query-driven.
                        out.append(RootCommand(id: cmdId, title: ctitle, subtitle: "\(title) · Menu Bar", runTitle: "Toggle in Menu Bar",
                                               icon: "menubar.rectangle", iconPath: iconPath,
                                               keywords: [name, cname, title.lowercased(), "menu bar"],
                                               closesPalette: true, argSpec: argSpec,
                                               disabledByDefault: cmdDisabledByDefault) { [weak self] in
                            guard let self else { return }
                            let prefs = self.resolvePreferencesJSON(extKey: extKey, spec: prefsSpec)
                            let paths = self.extensionPaths(id: cmdId, entryRelPath: rel)
                            self.menuBar?.toggle(cmdId: cmdId, extKey: extKey, entryRelPath: rel, command: cname,
                                                 preferences: prefs,
                                                 trusted: AppSettings.shared.isTrusted(Self.extGrantKey(forId: cmdId)),
                                                 assetsPath: paths.assets, supportPath: paths.support)
                        })
                    } else if cmode == "no-view" {
                        // fallbackEligible: true for user-invoked no-view commands; false for interval/background ones.
                        out.append(RootCommand(id: cmdId, title: ctitle, subtitle: title, runTitle: "Run",
                                               icon: "bolt.fill", iconPath: iconPath,
                                               keywords: [name, cname, title.lowercased()],
                                               closesPalette: false, argSpec: argSpec,
                                               disabledByDefault: cmdDisabledByDefault,
                                               fallbackEligible: !isIntervalNoView) { [weak self] in
                            // closesPalette:false so a first-run prefs-onboarding form can open in the
                            // palette; the no-view action itself tears the palette down when it runs.
                            guard let self else { return }
                            self.launchExtensionCommand(extKey: extKey, extTitle: title, spec: prefsSpec,
                                                        argSpec: argSpec, commandTitle: ctitle,
                                                        providedArgs: self.chipArgs(argSpec)) { prefs, args in
                                self.runNoViewExtension(id: cmdId, title: ctitle, entryRelPath: rel, command: cname, preferences: prefs, arguments: args)
                            }
                        })
                    } else {
                        // view commands: always fallback-eligible (query-driven UI surface).
                        out.append(RootCommand(id: cmdId, title: ctitle, subtitle: title, runTitle: "Open",
                                               icon: "puzzlepiece.extension.fill", iconPath: iconPath,
                                               keywords: [name, cname, title.lowercased()],
                                               closesPalette: false, argSpec: argSpec,
                                               disabledByDefault: cmdDisabledByDefault,
                                               fallbackEligible: true) { [weak self] in
                            guard let self else { return }
                            self.launchExtensionCommand(extKey: extKey, extTitle: title, spec: prefsSpec,
                                                        argSpec: argSpec, commandTitle: ctitle,
                                                        providedArgs: self.chipArgs(argSpec)) { prefs, args in
                                self.launchExtension(id: cmdId, title: ctitle, entryRelPath: rel, command: cname, preferences: prefs, arguments: args)
                            }
                        })
                    }
                }
            }
        }
        // Register the disabledByDefault ids so isEnabled() can hide these commands until the user
        // explicitly enables them. This runs synchronously inside makeCommands() (via discoverExtensionCommands),
        // which is called by the `commands` lazy var — so the registry is populated before the first
        // matchCommands() call consults isEnabled().
        AppSettings.shared.disabledByDefaultIds = Set(out.filter { $0.disabledByDefault }.map { $0.id })
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
            } else if type == "appPicker" {
                // Raycast's appPicker yields an Application object {name, path, bundleId}; our stored
                // value / manifest default is the app NAME. Resolve it to an object so extensions that
                // read e.g. `preferences.browser.name` work (a bare string makes `.name` undefined).
                let appName = override ?? (p["default"] as? String) ?? ""
                if !appName.isEmpty {
                    var appObj: [String: Any] = ["name": appName]
                    if let entry = appIndex.search(appName, limit: 5)
                        .first(where: { $0.name.caseInsensitiveCompare(appName) == .orderedSame }) {
                        appObj["path"] = entry.path
                        if let bid = Bundle(path: entry.path)?.bundleIdentifier { appObj["bundleId"] = bid }
                    }
                    dict[name] = appObj
                }
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
                let ptype = (p["type"] as? String) ?? "textfield"
                var options: [PrefOption] = (p["data"] as? [[String: Any]] ?? []).compactMap { o in
                    (o["value"] as? String).map { PrefOption(value: $0, title: (o["title"] as? String) ?? $0) }
                }
                // An appPicker is a dropdown of installed apps (Raycast parity), not a text field.
                if ptype == "appPicker" { options = appIndex.allApps().map { PrefOption(value: $0.name, title: $0.name) } }
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
                // Same dot-sanitized key as the command discovery above, so the prefs group id matches
                // the launcher's grant key / the Settings group id (see sanitizeKeySegment).
                let extKey = root == "imported" ? "imported-\(Self.sanitizeKeySegment(name))" : Self.sanitizeKeySegment(name)
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
    /// Raycast's environment.assetsPath (the extension's assets/ dir, where manifest images live) and
    /// environment.supportPath (a writable per-extension dir). entryRelPath is "<root>/<ext>/src/<cmd>.ext",
    /// so the extension dir is everything before "/src/". supportPath is created if missing.
    private func extensionPaths(id: String, entryRelPath: String) -> (assets: String, support: String) {
        let extDirRel = entryRelPath.components(separatedBy: "/src/").first ?? entryRelPath
        let assets = repoRoot + "/" + extDirRel + "/assets"
        let key = Self.extGrantKey(forId: id)
        let fm = FileManager.default
        let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let support = base?.appendingPathComponent("com.invoke.app/extensions/\(key)", isDirectory: true).path
            ?? (NSTemporaryDirectory() + "invoke-ext/\(key)")
        try? fm.createDirectory(atPath: support, withIntermediateDirectories: true)
        return (assets, support)
    }

    private func launchExtension(id: String, title: String, entryRelPath: String, command: String, preferences: String, arguments: String = "{}", launchContext: String = "{}", fallbackText: String = "") {
        teardownExtension()
        palette.clearArguments() // leaving the root list for the extension view — drop argument chips
        extDropdownMountSig = ""; extDropdownValue = nil // re-fire engine dropdown onChange-on-mount; forget last pick
        let h = ExtensionHost()
        h.onLog = { msg in print("[invoke:ext] \(msg)") }
        h.onCommit = { [weak self] _ in self?.extReceivedCommit = true; self?.onExtensionCommit() }
        h.onCapability = { [weak self] m, p in self?.handleCapability(m, p) ?? .null }
        h.onCapabilityAsync = { [weak self] method, params, reply, fail in
            self?.handleAsyncCapability(method, params, reply: reply, fail: fail) ?? false
        }
        extLaunchGen += 1
        let gen = extLaunchGen
        lastLaunch = LaunchInfo(id: id, title: title, entryRelPath: entryRelPath, command: command, preferences: preferences, noView: false, arguments: arguments)
        h.onTerminate = { [weak self] in self?.onExtensionTerminated(id: id, gen: gen) }
        h.onSandboxDenial = { [weak self] module in self?.handleSandboxDenial(id: id, title: title, module: module) }
        h.onNav = { [weak self] depth, frame in self?.onExtNav(depth: depth, frame: frame) }
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
        let paths = extensionPaths(id: id, entryRelPath: entryRelPath)
        let fsKey = Self.extGrantKey(forId: id)
        h.onFS = { [weak self] op, params in
            self?.handleFS(op, params, extKey: fsKey, title: title, supportPath: paths.support, assetsPath: paths.assets)
                ?? .object(["error": .string("[invoke:fs] host unavailable"), "code": .string("EIO")])
        }
        palette.setAssetsPath(paths.assets) // resolve the extension's relative image sources (icons, grid thumbs)
        h.launch(repoRoot: repoRoot, entryRelPath: entryRelPath, command: command, preferences: preferences,
                 trusted: AppSettings.shared.isTrusted(Self.extGrantKey(forId: id)),
                 assetsPath: paths.assets, supportPath: paths.support, arguments: arguments, launchContext: launchContext,
                 fallbackText: fallbackText)
    }

    /// Running no-view extension processes, keyed so each can remove itself on exit (no retain cycle:
    /// the onTerminate closure captures the key, not the host).
    private var noViewHosts: [UUID: ExtensionHost] = [:]

    /// Run a `no-view` command: a headless action (no UI surface). The child runs the command's default
    /// export as a function; its host capabilities (runAppleScript, showHUD, clipboard, …) are fulfilled
    /// over RPC, and the process exits when the action finishes. captureTarget() first so AppleScript /
    /// paste hit the app that was frontmost before Invoke was summoned.
    private func runNoViewExtension(id: String, title: String, entryRelPath: String, command: String, preferences: String, arguments: String = "{}", launchContext: String = "{}", fallbackText: String = "") {
        frecency.bump("cmd:\(id)")
        captureTarget()
        afterLaunch() // an action command: tear the palette down first; the action runs in the background.
        // Set the ext identity AFTER afterLaunch — it tears down the extension and clears currentExtId,
        // which the headless action's capabilities (consent grants for runAppleScript, etc.) key on.
        currentExtId = id
        currentExtTitle = title
        let key = UUID()
        let h = ExtensionHost()
        h.onLog = { msg in print("[invoke:ext] \(msg)") }
        h.onCapability = { [weak self] m, p in self?.handleCapability(m, p) ?? .null }
        h.onCapabilityAsync = { [weak self] method, params, reply, fail in
            self?.handleAsyncCapability(method, params, reply: reply, fail: fail) ?? false
        }
        h.onTerminate = { [weak self] in DispatchQueue.main.async { self?.noViewHosts[key] = nil } }
        lastLaunch = LaunchInfo(id: id, title: title, entryRelPath: entryRelPath, command: command, preferences: preferences, noView: true, arguments: arguments)
        h.onSandboxDenial = { [weak self] module in self?.handleSandboxDenial(id: id, title: title, module: module) }
        noViewHosts[key] = h
        let paths = extensionPaths(id: id, entryRelPath: entryRelPath)
        let fsKey = Self.extGrantKey(forId: id)
        h.onFS = { [weak self] op, params in
            self?.handleFS(op, params, extKey: fsKey, title: title, supportPath: paths.support, assetsPath: paths.assets)
                ?? .object(["error": .string("[invoke:fs] host unavailable"), "code": .string("EIO")])
        }
        h.launch(repoRoot: repoRoot, entryRelPath: entryRelPath, command: command, preferences: preferences,
                 mode: "no-view", trusted: AppSettings.shared.isTrusted(Self.extGrantKey(forId: id)),
                 assetsPath: paths.assets, supportPath: paths.support, arguments: arguments, launchContext: launchContext,
                 fallbackText: fallbackText)
    }

    // MARK: - Background interval commands

    /// Parse a Raycast interval string ("30s", "10m", "1h", "1d") into seconds. nil if unrecognized.
    private static func parseInterval(_ s: String) -> TimeInterval? {
        let t = s.trimmingCharacters(in: .whitespaces).lowercased()
        guard let unit = t.last, let n = Double(t.dropLast()) else { return Double(t) }
        switch unit {
        case "s": return n
        case "m": return n * 60
        case "h": return n * 3600
        case "d": return n * 86400
        default: return Double(t) // bare number → seconds
        }
    }

    /// Start repeating timers for every discovered `interval` command. Enforce a sane floor so a tiny
    /// interval can't hammer the machine. Called once after commands are built.
    private func scheduleIntervals() {
        intervalTimers.forEach { $0.invalidate() }
        intervalTimers = []
        for spec in intervalSpecs {
            let period = max(60, spec.seconds) // floor at 60s regardless of manifest (battery/CPU)
            let t = Timer.scheduledTimer(withTimeInterval: period, repeats: true) { [weak self] _ in
                self?.runBackgroundInterval(spec)
            }
            intervalTimers.append(t)
            print("[invoke:interval] scheduled \(spec.cmdId) every \(Int(period))s")
        }
    }

    /// Run an interval command headlessly in the background (launchType "background"), no palette.
    private func runBackgroundInterval(_ spec: IntervalSpec) {
        let prefs = resolvePreferencesJSON(extKey: spec.extKey, spec: spec.prefsSpec)
        let key = UUID()
        let h = ExtensionHost()
        h.onLog = { msg in print("[invoke:interval:\(spec.cname)] \(msg)") }
        let savedExtId = spec.cmdId
        h.onCapability = { [weak self] m, p in
            let prev = self?.currentExtId; self?.currentExtId = savedExtId
            defer { self?.currentExtId = prev ?? "" }
            return self?.handleCapability(m, p) ?? .null
        }
        h.onTerminate = { [weak self] in DispatchQueue.main.async { self?.noViewHosts[key] = nil } }
        noViewHosts[key] = h
        let paths = extensionPaths(id: spec.cmdId, entryRelPath: spec.rel)
        h.launch(repoRoot: repoRoot, entryRelPath: spec.rel, command: spec.cname, preferences: prefs,
                 mode: "no-view", trusted: AppSettings.shared.isTrusted(Self.extGrantKey(forId: spec.cmdId)),
                 assetsPath: paths.assets, supportPath: paths.support, launchType: "background")
    }

    // MARK: - AI extensions (manifest tools[] + the @-mode agent loop)

    /// Prompt for a question, then run the extension's AI agent loop (model + its tools) and show the
    /// answer. Uses the typed query if present; otherwise enters AI Chat scoped to the extension.
    private func promptAIExtension(extKey: String, title: String, instructions: String) {
        guard ai.hasKey else { palette.showToast("Set your Anthropic API key in Settings → Advanced to use AI"); return }
        let q = lastQuery.trimmingCharacters(in: .whitespaces)
        let ask = { [weak self] (question: String) in self?.runAIExtension(extKey: extKey, title: title, instructions: instructions, prompt: question) }
        if !q.isEmpty { ask(q); return }
        // No query typed → collect one in a native form.
        enterNativeForm(title: "Ask \(title)", fields: [
            ViewNode(id: 1, type: "form-textarea", props: ["id": .string("q"), "title": .string("Question"), "placeholder": .string("Ask \(title)…")]),
        ]) { vals in ask(vals["q"] ?? "") }
    }

    private func runAIExtension(extKey: String, title: String, instructions: String, prompt: String) {
        let q = prompt.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return }
        guard let specs = aiExtTools[extKey], !specs.isEmpty else { palette.showToast("No AI tools for \(title)"); return }
        mode = .aiAnswer
        aiAskSeq += 1
        let seq = aiAskSeq
        renderAIAnswer(markdown: "_Asking \(title)…_")
        let tools: [AIService.AgentTool] = specs.map { spec in
            AIService.AgentTool(name: spec.name, description: spec.description) { [weak self] input in
                await self?.runAITool(extKey: extKey, entryRel: spec.rel, toolName: spec.name, input: input) ?? ["error": "host gone"]
            }
        }
        let system = instructions.isEmpty
            ? "You are \(title), a helpful assistant. Use the provided tools to answer. Reply in Markdown."
            : instructions
        Task {
            let result = await ai.runAgent(system: system, prompt: q, tools: tools) { status in
                DispatchQueue.main.async { if self.mode == .aiAnswer, self.aiAskSeq == seq { self.renderAIAnswer(markdown: "_\(status)_") } }
            }
            await MainActor.run {
                guard self.mode == .aiAnswer, self.aiAskSeq == seq else { return }
                switch result {
                case .success(let out): self.lastAIAnswer = out; self.renderAIAnswer(markdown: out)
                case .failure(let err): self.renderAIAnswer(markdown: "**AI error**\n\n\(err.message)")
                }
            }
        }
    }

    /// Spawn an extension's tool (mode "ai-tool") with the model-provided input; await its JSON result.
    private func runAITool(extKey: String, entryRel: String, toolName: String, input: [String: Any]) async -> Any {
        let inputJSON = (try? JSONSerialization.data(withJSONObject: input)).flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        let prefs = resolvePreferencesJSON(extKey: extKey, spec: [])
        let paths = extensionPaths(id: "ext.\(extKey).\(toolName)", entryRelPath: entryRel)
        let trusted = AppSettings.shared.isTrusted(extKey)
        return await withCheckedContinuation { (cont: CheckedContinuation<Any, Never>) in
            let h = ExtensionHost()
            var done = false
            let finish: (Any) -> Void = { v in if !done { done = true; cont.resume(returning: v); h.terminate() } }
            h.onAIToolResult = { result, error in finish(error != nil ? ["error": error!] : (result?.toAny ?? [:])) }
            h.onTerminate = { if !done { done = true; cont.resume(returning: ["error": "tool process ended"]) } }
            h.onCapability = { [weak self] m, p in
                let prev = self?.currentExtId; self?.currentExtId = extKey
                defer { self?.currentExtId = prev ?? "" }
                return self?.handleCapability(m, p) ?? .null
            }
            h.launch(repoRoot: repoRoot, entryRelPath: entryRel, command: toolName, preferences: prefs,
                     mode: "ai-tool", trusted: trusted, assetsPath: paths.assets, supportPath: paths.support,
                     toolInput: inputJSON)
        }
    }

    // MARK: - Required-preferences onboarding (Raycast parity)

    /// True if the extension has a `required` preference the user hasn't set yet. Raycast shows a
    /// "Welcome to <ext>" config screen on first run in this case; we do the same (presentPrefsOnboarding)
    /// before launching, so e.g. YouTube Music's Browser is actually chosen rather than silently
    /// defaulting. Once the user saves them, the overrides exist and onboarding no longer appears.
    private func needsPrefsOnboarding(extKey: String, spec: [[String: Any]]) -> Bool {
        for p in spec where (p["required"] as? Bool) ?? false {
            guard let name = p["name"] as? String else { continue }
            let secret = (p["type"] as? String) == "password"
            if AppSettings.shared.extensionPref(extID: extKey, name: name, secret: secret) == nil { return true }
        }
        return false
    }

    /// In-palette form that collects an extension's required preferences (dropdowns render as real
    /// dropdowns), saves them, then runs `then` (the actual command launch).
    private func presentPrefsOnboarding(extKey: String, extTitle: String, spec: [[String: Any]],
                                        then: @escaping () -> Void) {
        var fields: [ViewNode] = []
        var fid = 100
        for p in spec where (p["required"] as? Bool) ?? false {
            guard let name = p["name"] as? String else { continue }
            let ptype = (p["type"] as? String) ?? "textfield"
            let ptitle = (p["title"] as? String) ?? name
            let saved = AppSettings.shared.extensionPref(extID: extKey, name: name, secret: ptype == "password")
            let current = saved ?? (p["default"] as? String)
                ?? ((p["default"] as? Bool).map { $0 ? "true" : "false" }) ?? ""
            fid += 1
            switch ptype {
            case "dropdown":
                let node = ViewNode(id: fid, type: "form-dropdown",
                                    props: ["id": .string(name), "title": .string(ptitle), "value": .string(current)])
                var itemId = fid * 1000
                node.children = ((p["data"] as? [[String: Any]]) ?? []).compactMap { o in
                    guard let v = o["value"] as? String else { return nil }
                    itemId += 1
                    return ViewNode(id: itemId, type: "form-dropdown-item",
                                    props: ["title": .string((o["title"] as? String) ?? v), "value": .string(v)])
                }
                fields.append(node)
            case "checkbox":
                fields.append(ViewNode(id: fid, type: "form-checkbox",
                                       props: ["id": .string(name), "label": .string(ptitle), "value": .bool(current == "true")]))
            case "appPicker":
                // Like Raycast: a dropdown of installed apps (with icons), value = app name.
                let node = ViewNode(id: fid, type: "form-dropdown",
                                    props: ["id": .string(name), "title": .string(ptitle), "value": .string(current)])
                var itemId = fid * 1000
                node.children = appIndex.allApps().map { app in
                    itemId += 1
                    return ViewNode(id: itemId, type: "form-dropdown-item",
                                    props: ["title": .string(app.name), "value": .string(app.name), "iconPath": .string(app.path)])
                }
                fields.append(node)
            default: // textfield, password → a text field
                fields.append(formField(fid, fieldId: name, type: "form-textfield", title: ptitle,
                                        placeholder: (p["description"] as? String) ?? "", value: current))
            }
        }
        enterNativeForm(title: "Set up \(extTitle)", fields: fields) { [weak self] vals in
            guard let self else { return }
            for p in spec where (p["required"] as? Bool) ?? false {
                guard let name = p["name"] as? String, let v = vals[name] else { continue }
                let secret = (p["type"] as? String) == "password"
                AppSettings.shared.setExtensionPref(extID: extKey, name: name, secret: secret, value: v)
            }
            then()
        }
    }

    /// Collect a command's Raycast `arguments` (the fields Raycast shows in the search bar) via an
    /// in-palette form, then run `then` with them serialized as JSON ({name: value}). Empty optional
    /// args are passed as "" (matching Raycast); required args are validated by the form.
    private func presentArgumentsForm(title: String, argSpec: [[String: Any]], then: @escaping (String) -> Void) {
        var fields: [ViewNode] = []
        var fid = 200
        for a in argSpec {
            guard let name = a["name"] as? String else { continue }
            let atype = (a["type"] as? String) ?? "text"
            let placeholder = (a["placeholder"] as? String) ?? name
            let required = (a["required"] as? Bool) ?? false
            fid += 1
            if atype == "dropdown" {
                let node = ViewNode(id: fid, type: "form-dropdown",
                                    props: ["id": .string(name), "title": .string(placeholder), "value": .string("")])
                var itemId = fid * 1000
                node.children = ((a["data"] as? [[String: Any]]) ?? []).compactMap { o in
                    guard let v = o["value"] as? String else { return nil }
                    itemId += 1
                    return ViewNode(id: itemId, type: "form-dropdown-item",
                                    props: ["title": .string((o["title"] as? String) ?? v), "value": .string(v)])
                }
                fields.append(node)
            } else { // text, password → a text field; mark required so the form validates it
                let node = formField(fid, fieldId: name, type: "form-textfield",
                                     title: placeholder, placeholder: placeholder, value: "")
                if required { node.props["required"] = .bool(true) }
                fields.append(node)
            }
        }
        enterNativeForm(title: title, fields: fields) { vals in
            var obj: [String: Any] = [:]
            for a in argSpec { if let name = a["name"] as? String { obj[name] = vals[name] ?? "" } }
            let data = (try? JSONSerialization.data(withJSONObject: obj)) ?? Data("{}".utf8)
            then(String(decoding: data, as: UTF8.self))
        }
    }

    /// Launch an extension command, first showing the required-preferences onboarding if it isn't
    /// configured yet, then (if the command declares `arguments`) the arguments form. `launch` performs
    /// the actual view/no-view launch with the resolved prefs JSON and the collected arguments JSON.
    /// Build the arguments JSON from the inline search-bar chips, if they're currently shown for a
    /// command with arguments. Returns nil when there are no chips (e.g. launched via hotkey/alias) so
    /// the caller falls back to the arguments form.
    private func chipArgs(_ argSpec: [[String: Any]]) -> String? {
        guard !argSpec.isEmpty, palette.hasArguments else { return nil }
        let vals = palette.argumentValues()
        var obj: [String: Any] = [:]
        for a in argSpec { if let name = a["name"] as? String { obj[name] = vals[name] ?? "" } }
        let data = (try? JSONSerialization.data(withJSONObject: obj)) ?? Data("{}".utf8)
        return String(decoding: data, as: UTF8.self)
    }

    private func launchExtensionCommand(extKey: String, extTitle: String, spec: [[String: Any]],
                                        argSpec: [[String: Any]] = [], commandTitle: String = "",
                                        providedArgs: String? = nil,
                                        launch: @escaping (_ prefs: String, _ argsJSON: String) -> Void) {
        let withArgs: (String) -> Void = { [weak self] prefs in
            guard let self else { return }
            if let provided = providedArgs {
                launch(prefs, provided)            // values came from the inline chips
            } else if argSpec.isEmpty {
                launch(prefs, "{}")
            } else {
                self.presentArgumentsForm(title: commandTitle.isEmpty ? extTitle : commandTitle,
                                          argSpec: argSpec) { argsJSON in launch(prefs, argsJSON) }
            }
        }
        if needsPrefsOnboarding(extKey: extKey, spec: spec) {
            presentPrefsOnboarding(extKey: extKey, extTitle: extTitle, spec: spec) { [weak self] in
                guard let self else { return }
                withArgs(self.resolvePreferencesJSON(extKey: extKey, spec: spec))
            }
        } else {
            withArgs(resolvePreferencesJSON(extKey: extKey, spec: spec))
        }
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
    private func onExtensionTerminated(id: String, gen: Int) {
        // Ignore a stale termination from a prior launch (e.g. the dead child whose Trust & Relaunch
        // already started a fresh one) — only the current generation may tear the view down.
        guard mode == .extensionView, currentExtId == id, gen == extLaunchGen else { return }
        let name = currentExtTitle
        let started = extReceivedCommit
        exitToRoot()
        if !started { palette.showToast("Couldn’t start “\(name)” — it may need an unsupported dependency") }
    }

    /// A sandboxed extension died because it imported a denied Node built-in. Offer to trust it (run
    /// unsandboxed, full Node like Raycast) and relaunch — the one-click M2 flow. Runs on the main queue;
    /// the modal blocks here, and the dead child's onTerminate is gen-guarded so it can't nuke the relaunch.
    private func handleSandboxDenial(id: String, title: String, module: String) {
        let key = Self.extGrantKey(forId: id)
        // Already trusted → this is a genuine failure, not a sandbox block; let onTerminate report it.
        if AppSettings.shared.isTrusted(key) { return }
        let alert = NSAlert()
        alert.messageText = "“\(title)” needs full system access"
        alert.informativeText = "It tried to use Node’s “\(module)”, which the sandbox blocks. Trusted extensions run without the sandbox — full filesystem, subprocess, and network access. Only trust extensions whose code you trust."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Trust & Relaunch")
        alert.addButton(withTitle: "Cancel")
        let trust = alert.runModal() == .alertFirstButtonReturn
        guard trust else {
            if mode == .extensionView { exitToRoot() } // clear the dead view; user declined
            return
        }
        AppSettings.shared.setTrusted(key, true)
        guard let info = lastLaunch, info.id == id else {
            if mode == .extensionView { exitToRoot() }
            return
        }
        if info.noView {
            runNoViewExtension(id: info.id, title: info.title, entryRelPath: info.entryRelPath, command: info.command, preferences: info.preferences, arguments: info.arguments)
        } else {
            launchExtension(id: info.id, title: info.title, entryRelPath: info.entryRelPath, command: info.command, preferences: info.preferences, arguments: info.arguments)
        }
    }

    private func teardownExtension() {
        palette.dismissToast() // clear any persistent actionable toast; its handlers reference extHost which is about to be nil'd
        extHost?.terminate()
        extHost = nil
        currentExtId = ""
        currentExtTitle = ""
        navDepth = 0
        activeFrame = 0
        extSearchFilter = ""
        searchThrottleWork?.cancel(); searchThrottleWork = nil
        selectionByFrame.removeAll()
        palette.setAssetsPath("")
    }

    /// The child changed the active navigation frame (push/pop). Display that frame's tree, restoring
    /// the selection it had — so popping back to a list/grid lands on the row you pushed from (Raycast
    /// semantics). The extension's React state is preserved by the child (the lower frame stays mounted);
    /// the *selected index* is host state, so we remember it per frame here.
    private func onExtNav(depth: Int, frame: Int) {
        guard mode == .extensionView else { return }
        selectionByFrame[activeFrame] = selectedIndex // remember the frame we're leaving
        navDepth = depth
        activeFrame = frame
        extSearchFilter = ""
        searchThrottleWork?.cancel(); searchThrottleWork = nil
        selectedIndex = selectionByFrame[frame] ?? 0  // restore (a brand-new pushed frame starts at 0)
        renderExtension()
        reflectControlledSearchText()
    }

    private func onExtensionCommit() {
        // Clear the in-flight guard only when the page has actually landed (item count grew or
        // pagination ended), not on every commit — the extension's isLoading=true commit fires
        // immediately mid-fetch and must NOT release the guard prematurely.
        if loadMoreInFlight, let surface = extensionSurfaceNode(), surface.type == "list" || surface.type == "grid" {
            let hasMore = { if case .bool(true)? = surface.props["paginationHasMore"] { return true }; return false }()
            if surfaceItemCount(surface) > loadMoreItemCount || !hasMore { loadMoreInFlight = false }
        } else {
            loadMoreInFlight = false   // not an extension list/grid surface anymore → release
        }
        guard mode == .extensionView else { return }
        renderExtension()
        reflectControlledSearchText()
    }

    private func renderExtension() {
        let count = items().count
        if selectedIndex >= count { selectedIndex = max(0, count - 1) }
        palette.render(activeTree, selectedIndex: selectedIndex)
        updateActionBar()
        updateExtensionDropdown()
        // Honor the active surface's own searchBarPlaceholder (Raycast) — for the base AND pushed views —
        // instead of the generic "Search <title>…" (which doubled to "Search Search Websites…").
        if let surface = extensionSurfaceNode(),
           let ph = surface.props["searchBarPlaceholder"]?.stringValue, !ph.isEmpty {
            palette.setPlaceholder(ph)
        }
    }

    /// If the search surface has a controlled `searchText` prop, mirror it into the search field.
    private func reflectControlledSearchText() {
        guard mode == .extensionView, let st = searchSurfaceNode()?.props["searchText"]?.stringValue else { return }
        palette.reflectSearchText(st)
    }

    /// Surface an extension List/Grid's search-bar Dropdown accessory (<List.Dropdown>) as the search-bar
    /// dropdown, wiring its selection to the extension's onChange handler (which re-renders the list).
    private func updateExtensionDropdown() {
        guard mode == .extensionView, let surface = extensionSurfaceNode() else { palette.hideSearchDropdown(); return }
        func findDropdown(_ n: ViewNode) -> ViewNode? {
            if n.type == "list-dropdown" { return n }
            for c in n.children { if let d = findDropdown(c) { return d } }
            return nil
        }
        guard let dd = findDropdown(surface) else { palette.hideSearchDropdown(); return }
        var items: [(title: String, value: String, iconPath: String?)] = []
        // An item's icon can be a resolved local path (iconPath), a getFavicon descriptor ({source: url}),
        // or a plain string (SF-symbol name or url). Return a path/url the dropdown can load.
        func iconRef(_ n: ViewNode) -> String? {
            if let p = n.props["iconPath"]?.stringValue, !p.isEmpty { return p }
            if case .object(let icon)? = n.props["icon"], case .string(let src)? = icon["source"], !src.isEmpty { return src }
            if let s = n.props["icon"]?.stringValue, !s.isEmpty { return s }
            return nil
        }
        func collect(_ n: ViewNode) {
            for c in n.children {
                if c.type == "list-dropdown-item" {
                    let title = c.props["title"]?.stringValue ?? c.props["value"]?.stringValue ?? ""
                    let value = c.props["value"]?.stringValue ?? title
                    items.append((title, value, iconRef(c)))
                } else { collect(c) } // descend into list-dropdown-section
            }
        }
        collect(dd)
        guard !items.isEmpty else { palette.hideSearchDropdown(); return }
        let storeValue: Bool = { if case .bool(let s)? = dd.props["storeValue"] { return s }; return false }()
        let ddId = dd.props["id"]?.stringValue ?? "default"
        let storeKey = "extdd.\(currentExtId).\(lastLaunch?.command ?? "").\(ddId)"
        let stored = storeValue ? UserDefaults.standard.string(forKey: storeKey) : nil
        // Precedence: controlled `value` → persisted (storeValue) → the user's last in-memory pick → defaultValue → first.
        // extDropdownValue beats defaultValue because an UNCONTROLLED dropdown tracks its selection in the
        // extension's own state (not the value prop): re-asserting defaultValue every re-render would revert
        // the user's pick and they could never change it.
        let current = dd.props["value"]?.stringValue ?? stored ?? extDropdownValue
            ?? dd.props["defaultValue"]?.stringValue ?? items.first?.value ?? ""
        let handler = dd.props["onChange"]?.handlerRef
        let tooltip = dd.props["tooltip"]?.stringValue
        let filtering: Bool = { if case .bool(let f)? = dd.props["filtering"] { return f }; return true }()
        let isLoading: Bool = { if case .bool(let l)? = dd.props["isLoading"] { return l }; return false }()
        palette.setSearchDropdown(items: items, selected: current, tooltip: tooltip, filtering: filtering, isLoading: isLoading) { [weak self] value in
            guard let self, let handler else { return }
            self.extDropdownValue = value
            if storeValue { UserDefaults.standard.set(value, forKey: storeKey) }
            self.extHost?.invoke(handler: handler, args: [.string(value)]) // re-renders via the next commit
        }
        // Fire onChange ONCE when the dropdown first appears, to initialize the extension's selection
        // state (Raycast fires onChange with defaultValue on mount; otherwise the default engine's URL
        // stays empty and search is broken until the user re-picks). The signature is the option VALUES
        // only — selecting an engine changes state, not the options, so this never re-fires in a loop.
        let mountSig = items.map(\.value).joined(separator: "\u{1}")
        if mountSig != extDropdownMountSig {
            extDropdownMountSig = mountSig
            if let handler { extHost?.invoke(handler: handler, args: [.string(current)]) }
        }
    }
    private var extDropdownMountSig = ""
    private var extDropdownValue: String?  // the user's last engine pick (uncontrolled dropdown)

    /// The current extension's top-level surface node (list/grid/detail/form) — used to find the
    /// ActionPanel when the surface has no selectable rows (Detail/Form), and to detect form submits.
    private func extensionSurfaceNode() -> ViewNode? {
        activeTree.root.children.first { ["detail", "form", "grid", "list"].contains($0.type) }
    }

    private var loadMoreInFlight = false
    private var loadMoreItemCount = 0

    /// Count list/grid items under a surface node (mirrors the item-walk pattern).
    private func surfaceItemCount(_ surface: ViewNode) -> Int {
        var n = 0
        func walk(_ node: ViewNode) { if node.type == "list-item" || node.type == "grid-item" { n += 1 }; node.children.forEach(walk) }
        walk(surface)
        return n
    }

    /// The renderer reports the user scrolled near the end; if the active list/grid declares more pages and
    /// none is loading, invoke its onLoadMore handler on the extension. Re-armed on the next commit.
    private func handleReachedEnd() {
        guard mode == .extensionView, !loadMoreInFlight,
              let surface = extensionSurfaceNode(),
              surface.type == "list" || surface.type == "grid",
              { if case .bool(true)? = surface.props["paginationHasMore"] { return true }; return false }(),
              let handler = surface.props["onLoadMore"]?.handlerRef else { return }
        loadMoreItemCount = surfaceItemCount(surface)
        loadMoreInFlight = true
        extHost?.invoke(handler: handler)
    }

    /// Actions for the selected extension row. Extension-driven actions (onAction) re-enter the child;
    /// declarative ones (open-in-browser/copy/paste) are fulfilled natively.
    private func extensionActions(under node: ViewNode) -> [PaletteAction] {
        actions(under: node).enumerated().map { i, n in
            paletteAction(for: n, shortcut: i == 0 ? "↵" : (i == 1 ? "⌘↵" : nil))
        }
    }

    /// One extension action node → a PaletteAction that runs via extHost (all variants + form submit).
    /// Reads Action.style (destructive) and a custom Action.shortcut ({ modifiers, key }) — the custom
    /// shortcut overrides the positional ↵/⌘↵ display and is bound functionally by the window keyMonitor.
    private func paletteAction(for n: ViewNode, shortcut: String? = nil) -> PaletteAction {
        let destructive = (n.props["style"]?.stringValue == "destructive")
        var display = shortcut
        var mods: [String]? = nil
        var key: String? = nil
        if case .object(let sc)? = n.props["shortcut"], let k = sc["key"]?.stringValue, !k.isEmpty {
            var ml: [String] = []
            if case .array(let arr)? = sc["modifiers"] { ml = arr.compactMap { $0.stringValue } }
            mods = Array(Keyboard.normalize(ml))
            key = k.lowercased()
            display = Keyboard.glyphs(modifiers: ml, key: k)
        }
        return PaletteAction(title: title(for: n), shortcut: display, icon: n.props["icon"]?.stringValue,
                             isDestructive: destructive, shortcutModifiers: mods, shortcutKey: key) { [weak self] in
            self?.runExtensionAction(n)
        }
    }

    /// Build the structured ⌘K model from the selected item's `<ActionPanel>` subtree (Raycast sections
    /// + submenus). No action-panel node → one untitled section over the flat actions (back-compat).
    private func extensionActionSections(under node: ViewNode) -> [ActionSection] {
        func firstActionPanel(_ n: ViewNode) -> ViewNode? {
            if n.type == "action-panel" { return n }
            for c in n.children { if let p = firstActionPanel(c) { return p } }
            return nil
        }
        guard let panel = firstActionPanel(node) else {
            return [ActionSection(title: nil, entries: actions(under: node).map { .action(paletteAction(for: $0)) })]
        }
        func makeSections(_ container: ViewNode) -> [ActionSection] {
            var leafIndex = 0 // per-level: ↵/⌘↵ count does NOT descend into submenus
            func makeEntry(_ n: ViewNode) -> ActionEntry? {
                switch n.type {
                case "action":
                    let sc = leafIndex == 0 ? "↵" : (leafIndex == 1 ? "⌘↵" : nil)
                    leafIndex += 1
                    return .action(paletteAction(for: n, shortcut: sc))
                case "action-panel-submenu":
                    return .submenu(title: n.props["title"]?.stringValue ?? "Submenu",
                                    icon: n.props["icon"]?.stringValue,
                                    sections: makeSections(n)) // fresh counter for the submenu's own level
                default:
                    return nil
                }
            }
            var out: [ActionSection] = []
            var loose: [ActionEntry] = []
            func flushLoose() { if !loose.isEmpty { out.append(ActionSection(title: nil, entries: loose)); loose = [] } }
            for child in container.children {
                if child.type == "action-panel-section" {
                    flushLoose()
                    out.append(ActionSection(title: child.props["title"]?.stringValue,
                                             entries: child.children.compactMap(makeEntry)))
                } else if let e = makeEntry(child) {
                    loose.append(e)
                }
            }
            flushLoose()
            return out
        }
        return makeSections(panel)
    }

    /// Sections for the ⌘K panel: real sections for an extension view, else one untitled section over
    /// the existing flat `currentActions()` (built-in modes unchanged).
    private func currentActionSections() -> [ActionSection] {
        if mode == .extensionView {
            let rows = items()
            guard let node = (selectedIndex < rows.count) ? rows[selectedIndex] : extensionSurfaceNode() else { return [] }
            return extensionActionSections(under: node)
        }
        return [ActionSection(title: nil, entries: currentActions().map { ActionEntry.action($0) })]
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
        // Note: Action.Push now carries an onAction handler (handled above) that drives render-on-push
        // navigation in the child; there is no host-side snapshot branch anymore.
        case "open":
            // Action.Open: open a file/URL/app target (e.g. apple-notes' "Open in Notes" →
            // applenotes://showNote?…). Falls back to its onOpen handler if no target.
            if let target = n.props["target"]?.stringValue, !target.isEmpty {
                openTarget(target)
            } else if let handler = n.props["onAction"]?.stringValue {
                extHost?.invoke(handler: handler)
            }
            afterLaunch()
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
            RootCommand(id: "store.browse", title: "Browse Extensions", subtitle: "Store", runTitle: "Open", icon: "puzzlepiece.extension", keywords: ["store", "browse", "install", "extension", "extensions", "marketplace", "discover"], closesPalette: false) { [weak self] in self?.enterStore() },
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
            RootCommand(id: "ai.chat", title: "AI Chat", subtitle: "AI", runTitle: "Open", icon: "bubble.left.and.bubble.right", keywords: ["ai", "chat", "ask", "claude", "assistant", "gpt"], closesPalette: false, fallbackEligible: true) { [weak self] in self?.enterAIChat(initial: "") },
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
            windowCommand("window.firstThird", "First Third", "rectangle.lefthalf.inset.filled", ["first", "third", "left"], .leftThird),
            windowCommand("window.centerThird", "Center Third", "rectangle.center.inset.filled", ["center", "centre", "third", "middle"], .centerThird),
            windowCommand("window.lastThird", "Last Third", "rectangle.righthalf.inset.filled", ["last", "third", "right"], .rightThird),
            windowCommand("window.firstTwoThirds", "First Two-Thirds", "rectangle.lefthalf.filled", ["first", "two", "thirds", "left"], .leftTwoThirds),
            windowCommand("window.lastTwoThirds", "Last Two-Thirds", "rectangle.righthalf.filled", ["last", "two", "thirds", "right"], .rightTwoThirds),
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
        guard url.scheme == "invoke" else { return }
        // OAuth redirect (invoke://oauth-callback?code=&state=) → resolve the pending authorize RPC.
        if url.host == "oauth-callback" { resolveOAuthCallback(url); return }
        guard url.host == "commands" else { return }
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
            kids[m.id, default: []].append(CommandInfo(id: c.id, title: c.title, subtitle: "", icon: c.icon, iconPath: c.iconPath, fallbackEligible: c.fallbackEligible))
        }
        var groups = order.map { id -> ExtensionGroup in
            // The group's icon image is the extension's manifest icon (commands of an extension share it).
            let groupIcon = kids[id]?.compactMap(\.iconPath).first
            return ExtensionGroup(id: id, name: metas[id]!.name, icon: metas[id]!.icon, iconPath: groupIcon, commands: kids[id] ?? [])
        }
        groups.append(ExtensionGroup(id: "calculator", name: "Calculator", icon: "function",
            commands: [CommandInfo(id: "calculator", title: "Calculate", subtitle: "", icon: "function", supportsBinding: false)]))
        return groups.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    // MARK: - Per-command global hotkeys (PLAN.md §3.2, §6)

    /// (Re)register the user-assigned per-command hotkeys. Ids 100+ are reserved for these (only id 1,
    /// ⌥Space, is a fixed binding now). Called at launch and whenever the Settings window mutates a
    /// binding or an enable toggle — a disabled command's hotkey is removed.
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
