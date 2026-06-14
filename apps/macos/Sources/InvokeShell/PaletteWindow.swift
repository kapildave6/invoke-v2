import AppKit
import InvokePalette
import InvokeRenderer

/// Borderless panels return `false` from `canBecomeKey`/`canBecomeMain` by default, which blocks
/// keyboard input — override so the search field can become first responder and receive keystrokes.
final class KeyablePanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

/// The command-palette window (PLAN.md §4.3/§6): a borderless, non-activating NSPanel with
/// NSVisualEffectView vibrancy, a search bar, a result list, and a persistent bottom action bar.
/// ⌘K opens the Action Panel (all actions for the selected result). Kept warm for the <150ms
/// summon budget (§1).
public final class PaletteWindow: NSObject {
    public let panel: NSPanel
    private let searchField = NSTextField()
    private let paletteView: PaletteView

    // Bottom action bar.
    private let logoButton = NSButton()
    private let commandLabel = NSTextField(labelWithString: "")
    private let primaryActionLabel = NSTextField(labelWithString: "")
    private var primaryGroup: NSStackView!
    private var enterCaps: NSStackView!   // the ↵ / ⌘↵ chip next to the primary action
    private var actionBarDivider: NSView!
    private var isFormSurface = false     // a form submits on ⌘Return (Return is a newline in a textarea)

    private var keyMonitor: Any?
    private let actionPanel = ActionPanel()
    private var gridColumns = 0 // >0 when a grid surface is shown → arrows navigate it in 2D

    // Toast capsule (action feedback, e.g. "Copied to Clipboard").
    private let toastLabel = NSTextField(labelWithString: "")
    private var toastContainer: NSView?
    private var toastHideWork: DispatchWorkItem?

    /// Fired when the user edits the search field — the shell forwards it to the extension.
    public var onSearchChange: ((String) -> Void)?
    /// Move selection by ±1 (arrow keys), with the search field keeping focus.
    public var onMove: ((Int) -> Void)?
    /// Activate the selected row's action (Enter = primary; ⌘Enter = secondary).
    public var onActivate: ((_ secondary: Bool) -> Void)?
    /// Esc pressed.
    public var onCancel: (() -> Void)?
    /// Supplies the actions for the currently-selected result (for the ⌘K Action Panel).
    public var actionsProvider: (() -> [PaletteAction])?
    /// Title shown atop the ⌘K Action Panel (typically the selected result's name).
    public var actionPanelTitleProvider: (() -> String)?
    /// Clicking the bottom-left logo opens Settings (Raycast parity).
    public var onOpenSettings: (() -> Void)?
    /// While true, the palette won't auto-hide on resignKey — set during form editing so Tab moving
    /// focus between fields (which can momentarily resign key on a borderless panel) doesn't close it.
    public var suppressAutoHide = false
    /// Fired when the type-filter dropdown changes (clipboard mode).
    public var onFilterChange: ((String) -> Void)?
    /// Mouse: single-click selects a row (by item index); double-click activates it.
    public var onSelectRow: ((Int) -> Void)?
    public var onActivateRow: ((Int) -> Void)?

    private let filterButton = NSPopUpButton(frame: .zero, pullsDown: false)
    private let searchDropdown = SearchBarDropdown() // world-class engine picker (extension List.Dropdown)
    private var searchTrailingDefault: NSLayoutConstraint!
    private var searchTrailingWithFilter: NSLayoutConstraint!
    private var searchTrailingWithDropdown: NSLayoutConstraint!

    // Inline command-argument chips (Raycast parity): when the highlighted command declares arguments,
    // the search row shows [query] [icon] [field per arg], left-aligned right after the query text.
    private let argBar = NSStackView()
    private let argIcon = NSImageView()
    private var argFields: [NSTextField] = []
    private var argNames: [String] = []
    private var searchWidthConstraint: NSLayoutConstraint! // active only while args are shown (query hugs content)
    /// True while the search row is showing argument chips for the selected command.
    public private(set) var hasArguments = false

    /// Fixed palette width (Raycast-style); clamped to the display on small screens.
    private static let paletteWidth: CGFloat = 750

    public override init() {
        let width = Self.paletteWidth
        let rect = NSRect(x: 0, y: 0, width: width, height: 200) // grows/shrinks to fit content
        panel = KeyablePanel(
            contentRect: rect,
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        paletteView = PaletteView(frame: rect)
        super.init()

        // NSPanel.hidesOnDeactivate defaults to TRUE — so clicking/Tabbing a form field (which causes
        // app-activation churn) would make AppKit auto-order-out the panel, bypassing our own auto-hide
        // guard. We manage dismissal ourselves (Esc / resignKey), so turn it off.
        panel.hidesOnDeactivate = false
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true // drag the palette by its background (rows opt out)
        panel.backgroundColor = .clear
        panel.hasShadow = true
        // Follow the system appearance like Raycast: a frosted-light panel in Light mode, dark in Dark
        // mode. The earlier dullness was the dark `.hudWindow` material under Light mode (near-black text
        // on a dark backdrop). The fix is an APPEARANCE-ADAPTIVE material (.sidebar), not forcing dark —
        // labelColor then tracks the system so text is crisp either way.

        let blur = NSVisualEffectView(frame: rect)
        blur.material = .sidebar // adapts to Light/Dark, translucent like Raycast's palette
        blur.blendingMode = .behindWindow
        blur.state = .active
        blur.wantsLayer = true
        blur.layer?.cornerRadius = 12
        blur.layer?.masksToBounds = true

        searchField.placeholderString = "Search for apps and commands…"
        searchField.font = NSFont.systemFont(ofSize: 20, weight: .light)
        searchField.isBordered = false
        searchField.drawsBackground = false
        searchField.focusRingType = .none
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.delegate = self

        paletteView.translatesAutoresizingMaskIntoConstraints = false
        paletteView.onSelect = { [weak self] i in self?.onSelectRow?(i) }
        paletteView.onActivate = { [weak self] i in self?.onActivateRow?(i) }
        paletteView.onSubmit = { [weak self] in self?.onActivate?(false) } // Return in a Form field → submit

        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.isBordered = false // borderless, subtle — fits the translucent theme
        filterButton.controlSize = .small
        filterButton.font = .systemFont(ofSize: 12)
        filterButton.contentTintColor = .secondaryLabelColor
        (filterButton.cell as? NSPopUpButtonCell)?.arrowPosition = .arrowAtBottom
        filterButton.target = self
        filterButton.action = #selector(filterChanged)
        filterButton.isHidden = true

        let actionBar = makeActionBar()

        // Hairline separator between the search field and the result list (Raycast parity).
        let searchSeparator = NSBox()
        searchSeparator.boxType = .separator
        searchSeparator.translatesAutoresizingMaskIntoConstraints = false

        // Argument chip bar — hidden until a command with arguments is selected (setArguments).
        argIcon.translatesAutoresizingMaskIntoConstraints = false
        argIcon.imageScaling = .scaleProportionallyUpOrDown
        argIcon.setContentHuggingPriority(.required, for: .horizontal)
        argBar.translatesAutoresizingMaskIntoConstraints = false
        argBar.orientation = .horizontal
        argBar.alignment = .centerY
        argBar.spacing = 8
        argBar.setContentHuggingPriority(.required, for: .horizontal)
        argBar.isHidden = true

        searchDropdown.isHidden = true
        searchDropdown.hostContentView = blur // present the popover inside the palette content

        blur.addSubview(searchField)
        blur.addSubview(argBar)
        blur.addSubview(filterButton)
        blur.addSubview(searchDropdown)
        blur.addSubview(searchSeparator)
        blur.addSubview(paletteView)
        blur.addSubview(actionBar)

        searchTrailingDefault = searchField.trailingAnchor.constraint(equalTo: blur.trailingAnchor, constant: -16)
        searchTrailingWithFilter = searchField.trailingAnchor.constraint(equalTo: filterButton.leadingAnchor, constant: -10)
        searchTrailingWithDropdown = searchField.trailingAnchor.constraint(equalTo: searchDropdown.leadingAnchor, constant: -10)
        searchTrailingDefault.isActive = true
        NSLayoutConstraint.activate([
            searchDropdown.trailingAnchor.constraint(equalTo: blur.trailingAnchor, constant: -14),
            searchDropdown.centerYAnchor.constraint(equalTo: searchField.centerYAnchor),
        ])
        // While args are shown, the query field hugs its content (so chips sit right after it). Inactive
        // by default; setArguments activates it and keeps its constant in sync with the typed text.
        searchWidthConstraint = searchField.widthAnchor.constraint(equalToConstant: 80)

        NSLayoutConstraint.activate([
            argBar.leadingAnchor.constraint(equalTo: searchField.trailingAnchor, constant: 10),
            argBar.centerYAnchor.constraint(equalTo: searchField.centerYAnchor),
            argBar.trailingAnchor.constraint(lessThanOrEqualTo: blur.trailingAnchor, constant: -16),
            argIcon.widthAnchor.constraint(equalToConstant: 18),
            argIcon.heightAnchor.constraint(equalToConstant: 18),
            searchField.leadingAnchor.constraint(equalTo: blur.leadingAnchor, constant: 16),
            searchField.topAnchor.constraint(equalTo: blur.topAnchor, constant: 14),

            filterButton.trailingAnchor.constraint(equalTo: blur.trailingAnchor, constant: -14),
            filterButton.centerYAnchor.constraint(equalTo: searchField.centerYAnchor),

            searchSeparator.leadingAnchor.constraint(equalTo: blur.leadingAnchor),
            searchSeparator.trailingAnchor.constraint(equalTo: blur.trailingAnchor),
            searchSeparator.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 12),

            paletteView.leadingAnchor.constraint(equalTo: blur.leadingAnchor),
            paletteView.trailingAnchor.constraint(equalTo: blur.trailingAnchor),
            paletteView.topAnchor.constraint(equalTo: searchSeparator.bottomAnchor, constant: 6),
            paletteView.bottomAnchor.constraint(equalTo: actionBar.topAnchor),

            actionBar.leadingAnchor.constraint(equalTo: blur.leadingAnchor),
            actionBar.trailingAnchor.constraint(equalTo: blur.trailingAnchor),
            actionBar.bottomAnchor.constraint(equalTo: blur.bottomAnchor),
            actionBar.heightAnchor.constraint(equalToConstant: 38),
        ])

        // Toast capsule — hidden until showToast(), floats just above the action bar.
        toastLabel.font = .systemFont(ofSize: 12, weight: .medium)
        toastLabel.textColor = .labelColor
        toastLabel.alignment = .center
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        let toastBg = NSVisualEffectView()
        toastBg.material = .hudWindow
        toastBg.blendingMode = .withinWindow
        toastBg.state = .active
        toastBg.wantsLayer = true
        toastBg.layer?.cornerRadius = 10
        toastBg.layer?.masksToBounds = true
        toastBg.alphaValue = 0
        toastBg.translatesAutoresizingMaskIntoConstraints = false
        toastBg.addSubview(toastLabel)
        blur.addSubview(toastBg)
        toastContainer = toastBg
        NSLayoutConstraint.activate([
            toastLabel.leadingAnchor.constraint(equalTo: toastBg.leadingAnchor, constant: 16),
            toastLabel.trailingAnchor.constraint(equalTo: toastBg.trailingAnchor, constant: -16),
            toastLabel.topAnchor.constraint(equalTo: toastBg.topAnchor, constant: 8),
            toastLabel.bottomAnchor.constraint(equalTo: toastBg.bottomAnchor, constant: -8),
            toastBg.centerXAnchor.constraint(equalTo: blur.centerXAnchor),
            toastBg.bottomAnchor.constraint(equalTo: blur.bottomAnchor, constant: -52),
        ])

        panel.contentView = blur
        panel.delegate = self

        // ⌘K Action Panel: dismiss restores focus to the main search field. The panel runs the
        // selected action's captured closure directly (a re-render dismisses the panel first).
        actionPanel.onDismiss = { [weak self] in
            guard let self else { return }
            self.panel.makeFirstResponder(self.searchField)
        }
    }

    deinit {
        removeKeyMonitor()
    }

    private func makeActionBar() -> NSView {
        let bar = NSView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.wantsLayer = true

        // Hairline separator across the top of the bar.
        let sep = NSBox()
        sep.boxType = .separator
        sep.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(sep)

        // Left: the Invoke logo (like Raycast's bottom-left mark) → opens Settings, with the current
        // mode/context label to its right (hidden at root so the root view stays clean).
        logoButton.image = Brand.appIcon
        logoButton.imageScaling = .scaleProportionallyDown
        logoButton.isBordered = false
        logoButton.bezelStyle = .regularSquare
        logoButton.title = ""
        logoButton.imagePosition = .imageOnly
        logoButton.toolTip = "Open Settings"
        logoButton.target = self
        logoButton.action = #selector(logoClicked)
        logoButton.translatesAutoresizingMaskIntoConstraints = false

        commandLabel.font = .systemFont(ofSize: 12, weight: .medium)
        commandLabel.textColor = .secondaryLabelColor
        commandLabel.translatesAutoresizingMaskIntoConstraints = false
        let leftGroup = NSStackView(views: [logoButton, commandLabel])
        leftGroup.spacing = 8
        leftGroup.alignment = .centerY
        leftGroup.translatesAutoresizingMaskIntoConstraints = false

        // Right: [primary action][↵]  |  Actions [⌘][K] — keycap chips, properly aligned.
        primaryActionLabel.font = .systemFont(ofSize: 12, weight: .medium)
        primaryActionLabel.textColor = .labelColor
        primaryActionLabel.translatesAutoresizingMaskIntoConstraints = false
        enterCaps = NSStackView(views: Keycap.chips(for: "↵"))
        enterCaps.spacing = 3
        enterCaps.setHuggingPriority(.required, for: .horizontal)
        primaryGroup = NSStackView(views: [primaryActionLabel, enterCaps])
        primaryGroup.spacing = 6
        primaryGroup.alignment = .centerY
        primaryGroup.setHuggingPriority(.required, for: .horizontal)

        actionBarDivider = NSBox()
        let divider = actionBarDivider as! NSBox
        divider.boxType = .custom
        divider.fillColor = .separatorColor
        divider.borderWidth = 0
        divider.translatesAutoresizingMaskIntoConstraints = false

        let actionsLabel = NSTextField(labelWithString: "Actions")
        actionsLabel.font = .systemFont(ofSize: 12, weight: .medium)
        actionsLabel.textColor = .secondaryLabelColor
        actionsLabel.translatesAutoresizingMaskIntoConstraints = false
        let cmdKCaps = NSStackView(views: Keycap.chips(for: "⌘K"))
        cmdKCaps.spacing = 3
        cmdKCaps.setHuggingPriority(.required, for: .horizontal)
        let actionsGroup = NSStackView(views: [actionsLabel, cmdKCaps])
        actionsGroup.spacing = 6
        actionsGroup.alignment = .centerY
        actionsGroup.setHuggingPriority(.required, for: .horizontal)

        let rightGroup = NSStackView(views: [primaryGroup, divider, actionsGroup])
        rightGroup.spacing = 12
        rightGroup.alignment = .centerY
        rightGroup.setHuggingPriority(.required, for: .horizontal)
        rightGroup.translatesAutoresizingMaskIntoConstraints = false

        bar.addSubview(leftGroup)
        bar.addSubview(rightGroup)
        NSLayoutConstraint.activate([
            sep.leadingAnchor.constraint(equalTo: bar.leadingAnchor),
            sep.trailingAnchor.constraint(equalTo: bar.trailingAnchor),
            sep.topAnchor.constraint(equalTo: bar.topAnchor),
            logoButton.widthAnchor.constraint(equalToConstant: 18),
            logoButton.heightAnchor.constraint(equalToConstant: 18),
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.heightAnchor.constraint(equalToConstant: 16),
            leftGroup.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 14),
            leftGroup.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            rightGroup.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -14),
            rightGroup.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            rightGroup.leadingAnchor.constraint(greaterThanOrEqualTo: leftGroup.trailingAnchor, constant: 8),
        ])
        return bar
    }

    // MARK: - Rendering / action bar

    /// Scroll the current surface to the bottom (AI Chat keeps the streaming answer in view).
    public func scrollToBottom() { paletteView.scrollContentToBottom() }

    /// The active extension's assets/ dir, so relative image sources resolve (forwarded to the view).
    public func setAssetsPath(_ path: String) { paletteView.assetsPath = path }

    public func render(_ tree: ViewTree, selectedIndex: Int) {
        // Any re-render (including async extension-commit / AI-answer callbacks) invalidates the tree the
        // ⌘K panel's captured actions point at — close it so it can't act on a stale node. No-op if hidden.
        actionPanel.dismiss()
        // Track grid columns so arrow keys can navigate the grid in 2D (rows = ±columns). Mirror
        // PaletteView.renderGrid's fallback (5) when the grid sets `itemSize` instead of `columns` —
        // otherwise gridColumns stays 0 and Left/Right don't move (e.g. dotween-eases).
        if let grid = tree.root.children.first(where: { $0.type == "grid" }) {
            if case .number(let n)? = grid.props["columns"] { gridColumns = max(1, Int(n)) }
            else { gridColumns = 5 }
        } else {
            gridColumns = 0
        }
        // A form submits on ⌘Return (plain Return is a newline in a multi-line field), so advertise ⌘↵
        // in the bottom bar and route ⌘Return to submit while a form is shown.
        func containsForm(_ n: ViewNode) -> Bool { n.type == "form" || n.children.contains(where: containsForm) }
        let formNow = containsForm(tree.root)
        if formNow != isFormSurface {
            isFormSurface = formNow
            enterCaps.arrangedSubviews.forEach { $0.removeFromSuperview() }
            Keycap.chips(for: formNow ? "⌘↵" : "↵").forEach { enterCaps.addArrangedSubview($0) }
        }
        // Skip the resize (a full layout pass over every cell) when it was only a selection move.
        if paletteView.render(tree, selectedIndex: selectedIndex) { resizeToFit() }
    }

    /// Compact Mode (PLAN.md §4.3): size the window to its content — search bar + results + action
    /// bar — so there's no dead space, growing/shrinking as results change (capped, then it scrolls).
    private func resizeToFit() {
        let vf = activeScreen()?.visibleFrame
        let maxH = min(540, (vf?.height ?? 540) - 40)
        let searchH = searchField.fittingSize.height
        let contentH = paletteView.fittingHeight()
        let targetH = min(max(14 + searchH + 19 + 8 + contentH + 12 + 38, 96), maxH)
        // Width is FIXED (clamped on tiny screens) and re-pinned every render — a long row must
        // truncate within it, never widen the window.
        let targetW = min(Self.paletteWidth, (vf?.width ?? Self.paletteWidth + 40) - 40)
        var frame = panel.frame
        if abs(targetH - frame.height) < 0.5 && abs(targetW - frame.width) < 0.5 { return }
        frame.origin.y -= (targetH - frame.height) // keep the top edge fixed; grow/shrink downward
        frame.size.height = targetH
        frame.size.width = targetW
        // Never let growth push the window off the active display.
        if let vf {
            if frame.maxX > vf.maxX { frame.origin.x = vf.maxX - frame.width }
            if frame.minX < vf.minX { frame.origin.x = vf.minX }
            if frame.maxY > vf.maxY { frame.origin.y = vf.maxY - frame.height }
            if frame.minY < vf.minY { frame.origin.y = vf.minY }
        }
        panel.setFrame(frame, display: true)
    }

    /// Clear the search field (e.g. after launching an app), without firing onSearchChange.
    public func clearSearch() {
        searchField.stringValue = ""
    }

    /// Update the search-field placeholder (per mode — e.g. "Search snippets…", or the quicklink
    /// argument prompt).
    public func setPlaceholder(_ text: String) {
        searchField.placeholderString = text
    }

    /// Current values of a rendered Form's fields, by field id (read when a submit action fires).
    public func formValues() -> [String: String] { paletteView.currentFormValues() }

    // MARK: - Inline command arguments (Raycast parity)

    /// Show argument chips for the selected command, right after the query. No-ops (keeps typed values)
    /// when the same arguments are already shown, so re-filtering the list doesn't clobber input.
    public func setArguments(_ specs: [(name: String, placeholder: String)], iconPath: String?) {
        let names = specs.map(\.name)
        if hasArguments && names == argNames { return }
        argBar.arrangedSubviews.forEach { $0.removeFromSuperview() }
        argFields = []
        argNames = names

        if let iconPath, let img = NSImage(contentsOfFile: iconPath) {
            argIcon.image = img
        } else {
            argIcon.image = NSImage(systemSymbolName: "command", accessibilityDescription: nil)
        }
        argBar.addArrangedSubview(argIcon)
        for s in specs {
            let tf = NSTextField()
            tf.placeholderString = s.placeholder
            tf.font = .systemFont(ofSize: 13)
            tf.isBezeled = true
            tf.bezelStyle = .roundedBezel
            tf.focusRingType = .none
            tf.translatesAutoresizingMaskIntoConstraints = false
            tf.delegate = self
            tf.widthAnchor.constraint(greaterThanOrEqualToConstant: 72).isActive = true
            argFields.append(tf)
            argBar.addArrangedSubview(tf)
        }
        argBar.isHidden = false
        hasArguments = true
        suppressAutoHide = true // Tab between query/chips churns key focus on a borderless panel
        searchTrailingDefault.isActive = false
        searchTrailingWithFilter.isActive = false
        updateSearchWidth()
        searchWidthConstraint.isActive = true
    }

    /// Hide the argument chips (selection moved to a command without arguments, or left root mode).
    public func clearArguments() {
        guard hasArguments else { return }
        hasArguments = false
        suppressAutoHide = false
        argBar.arrangedSubviews.forEach { $0.removeFromSuperview() }
        argFields = []
        argNames = []
        argBar.isHidden = true
        searchWidthConstraint.isActive = false
        searchTrailingDefault.isActive = true
    }

    /// The values currently entered in the argument chips, keyed by argument name.
    public func argumentValues() -> [String: String] {
        var out: [String: String] = [:]
        for (i, name) in argNames.enumerated() where i < argFields.count { out[name] = argFields[i].stringValue }
        return out
    }

    /// Size the query field to its text so the chips sit immediately after it (Raycast layout).
    private func updateSearchWidth() {
        let s = searchField.stringValue
        let w = (s as NSString).size(withAttributes: [.font: searchField.font as Any]).width
        searchWidthConstraint.constant = max(46, min(w + 14, 360))
    }

    /// Show the type-filter dropdown (clipboard mode) with the given options/selection.
    public func setFilter(options: [String], selected: String) {
        searchDropdown.hide(); searchTrailingWithDropdown.isActive = false // not an extension dropdown
        filterButton.removeAllItems()
        filterButton.addItems(withTitles: options)
        filterButton.selectItem(withTitle: selected)
        filterButton.isHidden = false
        searchTrailingDefault.isActive = false
        searchTrailingWithFilter.isActive = true
    }

    /// Hide BOTH search-bar accessories (clipboard filter + extension engine dropdown) — the single
    /// "clear the search-bar trailing control" path used by every mode transition.
    public func hideFilter() {
        filterButton.isHidden = true
        searchDropdown.hide()
        searchTrailingWithFilter.isActive = false
        searchTrailingWithDropdown.isActive = false
        searchTrailingDefault.isActive = true
    }

    /// Show an extension List/Grid's search-bar Dropdown accessory (Raycast's <List.Dropdown>) as the
    /// world-class custom dropdown (SearchBarDropdown): a styled pill + searchable favicon popover.
    public func setSearchDropdown(items: [(title: String, value: String, iconPath: String?)], selected: String, onChange: @escaping (String) -> Void) {
        filterButton.isHidden = true
        searchDropdown.configure(
            items: items.map { SearchBarDropdown.Item(title: $0.title, value: $0.value, iconRef: $0.iconPath) },
            selected: selected, onSelect: onChange)
        searchTrailingDefault.isActive = false
        searchTrailingWithFilter.isActive = false
        searchTrailingWithDropdown.isActive = true
    }

    public func hideSearchDropdown() { hideFilter() } // hideFilter clears both accessories

    @objc private func filterChanged() {
        if let title = filterButton.titleOfSelectedItem {
            onFilterChange?(title)
        }
    }

    /// Briefly show a feedback capsule (e.g. "Copied to Clipboard"), then fade it out.
    public func showToast(_ message: String) {
        guard let container = toastContainer else { return }
        toastLabel.stringValue = message
        toastHideWork?.cancel()
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.12
            container.animator().alphaValue = 1
        }
        let work = DispatchWorkItem { [weak container] in
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.25
                container?.animator().alphaValue = 0
            }
        }
        toastHideWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3, execute: work)
    }

    /// Update the bottom bar: the context label (next to the logo) and the primary action chip. The
    /// context label is hidden at root so the root view stays logo-only like Raycast.
    public func setActionBar(command: String, primary: String?) {
        commandLabel.stringValue = command == "Invoke" ? "" : command
        commandLabel.isHidden = commandLabel.stringValue.isEmpty
        if let primary {
            primaryActionLabel.stringValue = primary
            primaryGroup.isHidden = false
            actionBarDivider.isHidden = false
        } else {
            primaryGroup.isHidden = true
            actionBarDivider.isHidden = true
        }
    }

    @objc private func logoClicked() { onOpenSettings?() }

    // MARK: - Show / hide

    /// Show + focus the palette (centered, key window, search field first responder).
    public func show() {
        installKeyMonitor() // armed only while visible (no global keystroke overhead when hidden)
        NSApp.activate(ignoringOtherApps: true)
        repositionToActiveScreen() // summon on the display under the cursor (multi-monitor correct)
        panel.makeKeyAndOrderFront(nil)
        panel.makeFirstResponder(searchField)
    }

    /// The screen under the mouse cursor (where the user is working), falling back to the main screen.
    private func activeScreen() -> NSScreen? {
        let mouse = NSEvent.mouseLocation
        return NSScreen.screens.first { NSMouseInRect(mouse, $0.frame, false) } ?? NSScreen.main
    }

    /// Spotlight/Raycast-style placement: horizontally centered, anchored in the upper portion of the
    /// active screen, with width/height clamped to the display so it can never run off a monitor.
    private func repositionToActiveScreen() {
        guard let vf = activeScreen()?.visibleFrame else { panel.center(); return }
        let width = min(panel.frame.width, vf.width - 40)
        let height = min(panel.frame.height, vf.height - 40)
        let x = vf.midX - width / 2
        let y = vf.maxY - min(160, (vf.height - height) * 0.22) - height
        panel.setFrame(NSRect(x: x, y: y, width: width, height: height), display: false)
    }

    public func hide() {
        dismissMenu()
        removeKeyMonitor()
        panel.orderOut(nil)
    }

    public var isVisible: Bool { panel.isVisible }

    public func toggle() {
        if panel.isVisible { hide() } else { show() }
    }

    // MARK: - Action Panel (⌘K)

    private func installKeyMonitor() {
        guard keyMonitor == nil else { return }
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, self.panel.isKeyWindow else { return event }
            // Tab cycles form fields ourselves (consume it), so AppKit's key-view machinery can't walk
            // focus out of the borderless panel.
            if event.keyCode == 48 { // Tab
                if self.paletteView.moveFormFocus(reverse: event.modifierFlags.contains(.shift)) { return nil }
                return event
            }
            if event.keyCode == 53 { // Esc — works even when a form field (not the search box) has focus
                if self.actionPanel.isShown { self.actionPanel.dismiss() } else { self.onCancel?() }
                return nil
            }
            guard event.modifierFlags.contains(.command) else { return event }
            if event.charactersIgnoringModifiers?.lowercased() == "k" {
                self.actionPanel.isShown ? self.actionPanel.dismiss() : self.showActionMenu() // ⌘K toggles
                return nil
            }
            if event.keyCode == 36 || event.keyCode == 76 {        // ⌘Return / ⌘keypad-Enter
                if self.actionPanel.isShown { return nil }          // panel owns Return while it's open
                if self.isFormSurface { self.paletteView.onSubmit?(); return nil } // ⌘Return submits a form
                self.onActivate?(true); return nil                 // otherwise → secondary action
            }
            return event
        }
    }

    private func removeKeyMonitor() {
        if let keyMonitor { NSEvent.removeMonitor(keyMonitor); self.keyMonitor = nil }
    }

    /// Dismiss the Action Panel if it's open (called on re-render so it can't act on a stale tree).
    public func dismissMenu() {
        actionPanel.dismiss()
    }

    private func showActionMenu() {
        guard let actions = actionsProvider?(), !actions.isEmpty, let content = panel.contentView else { return }
        actionPanel.present(in: content, actions: actions, title: actionPanelTitleProvider?() ?? "")
    }
}

extension PaletteWindow: NSWindowDelegate {
    /// Auto-hide on blur (PLAN.md §4.3) — like Raycast. Skip while the ⌘K Action Panel is tracking
    /// (that briefly takes key focus).
    public func windowDidResignKey(_ notification: Notification) {
        if !actionPanel.isShown && !suppressAutoHide { hide() }
    }
}

extension PaletteWindow: NSTextFieldDelegate {
    public func controlTextDidChange(_ obj: Notification) {
        // Only the query field drives search; the argument chips are read on activation, not as search.
        if (obj.object as? NSTextField) === searchField {
            if hasArguments { updateSearchWidth() }
            onSearchChange?(searchField.stringValue)
        }
    }

    /// Route list-navigation keys while the search field keeps focus (Raycast-style): arrows move
    /// the selection, Enter/⌘Enter activate the primary/secondary action, Esc cancels. When argument
    /// chips are shown, Tab moves focus query→chip→chip→query and Enter from a chip runs the command.
    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        let field = control as? NSTextField
        let inChip = field.map { argFields.contains($0) } ?? false

        // Tab/Backtab cycle focus across the query field and the argument chips.
        if hasArguments, commandSelector == #selector(NSResponder.insertTab(_:)) || commandSelector == #selector(NSResponder.insertBacktab(_:)) {
            let forward = commandSelector == #selector(NSResponder.insertTab(_:))
            let order: [NSTextField] = [searchField] + argFields
            let idx = field.flatMap { order.firstIndex(of: $0) } ?? 0
            let next = order[(idx + (forward ? 1 : order.count - 1)) % order.count]
            panel.makeFirstResponder(next)
            return true
        }

        switch commandSelector {
        case #selector(NSResponder.moveDown(_:)):
            if inChip { return false } // arrows in a chip edit the caret; they must NOT move the selection
            onMove?(gridColumns > 0 ? gridColumns : 1); return true
        case #selector(NSResponder.moveUp(_:)):
            if inChip { return false }
            onMove?(gridColumns > 0 ? -gridColumns : -1); return true
        case #selector(NSResponder.moveRight(_:)):
            if gridColumns > 0, !inChip { onMove?(1); return true }; return false
        case #selector(NSResponder.moveLeft(_:)):
            if gridColumns > 0, !inChip { onMove?(-1); return true }; return false
        case #selector(NSResponder.insertNewline(_:)):
            onActivate?(false); return true // ⌘Return (secondary) is handled by the key monitor
        case #selector(NSResponder.cancelOperation(_:)):
            onCancel?(); return true
        default:
            return false
        }
    }
}
