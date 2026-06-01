import AppKit

/// A flipped container so a stack of rows lays out top-to-bottom inside an NSScrollView.
private final class FlippedView: NSView { override var isFlipped: Bool { true } }

/// Full-parent backdrop behind the panel: a click anywhere outside the panel dismisses it.
private final class BackdropView: NSView {
    var onClick: (() -> Void)?
    override func mouseDown(with event: NSEvent) { onClick?() }
}

/// Raycast-style Action Panel (PLAN.md §6): a floating rounded panel, anchored bottom-right inside the
/// palette and growing upward, listing every action for the selected result. Each row shows an icon,
/// the action title, and its shortcut as keycap chips; a search field at the bottom filters. Arrow
/// keys move the selection, Return runs it, Esc / clicking outside dismisses. It lives INSIDE the
/// palette window (not a separate window) so opening it doesn't steal key focus and trip auto-hide.
final class ActionPanel: NSObject, NSTextFieldDelegate {
    private let backdrop = BackdropView()
    private let container = NSVisualEffectView()
    private let headerLabel = NSTextField(labelWithString: "")
    private let listStack = NSStackView()
    private let docView = FlippedView()
    private let scroll = NSScrollView()
    private let searchField = NSTextField()
    private var scrollHeight: NSLayoutConstraint!

    private weak var parent: NSView?
    private var allActions: [PaletteAction] = []
    private var filtered: [PaletteAction] = []
    private var rows: [ActionRowView] = []
    private var selected = 0

    /// Called after the panel closes so the host can restore focus to the main search field.
    var onDismiss: (() -> Void)?

    var isShown: Bool { container.superview != nil }

    private let rowHeight: CGFloat = 34
    private let maxVisibleRows = 7
    private let panelWidth: CGFloat = 340

    override init() {
        super.init()
        buildViews()
    }

    private func buildViews() {
        backdrop.translatesAutoresizingMaskIntoConstraints = false
        backdrop.onClick = { [weak self] in self?.dismiss() }

        container.material = .menu
        container.blendingMode = .withinWindow
        container.state = .active
        container.wantsLayer = true
        container.layer?.cornerRadius = 10
        container.layer?.masksToBounds = true
        container.layer?.borderWidth = 1
        container.translatesAutoresizingMaskIntoConstraints = false

        headerLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        headerLabel.textColor = .secondaryLabelColor
        headerLabel.translatesAutoresizingMaskIntoConstraints = false

        let headerSep = NSBox(); headerSep.boxType = .separator
        headerSep.translatesAutoresizingMaskIntoConstraints = false

        listStack.orientation = .vertical
        listStack.spacing = 2
        listStack.alignment = .leading
        listStack.translatesAutoresizingMaskIntoConstraints = false

        docView.translatesAutoresizingMaskIntoConstraints = false
        docView.addSubview(listStack)

        scroll.drawsBackground = false
        scroll.hasVerticalScroller = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.documentView = docView

        let searchSep = NSBox(); searchSep.boxType = .separator
        searchSep.translatesAutoresizingMaskIntoConstraints = false

        searchField.placeholderString = "Search for actions…"
        searchField.font = .systemFont(ofSize: 13)
        searchField.isBordered = false
        searchField.drawsBackground = false
        searchField.focusRingType = .none
        searchField.delegate = self
        searchField.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(headerLabel)
        container.addSubview(headerSep)
        container.addSubview(scroll)
        container.addSubview(searchSep)
        container.addSubview(searchField)

        scrollHeight = scroll.heightAnchor.constraint(equalToConstant: rowHeight)
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: panelWidth),

            headerLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            headerLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            headerLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),

            headerSep.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            headerSep.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            headerSep.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),

            scroll.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 6),
            scroll.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -6),
            scroll.topAnchor.constraint(equalTo: headerSep.bottomAnchor, constant: 6),
            scrollHeight,

            docView.topAnchor.constraint(equalTo: scroll.contentView.topAnchor),
            docView.leadingAnchor.constraint(equalTo: scroll.contentView.leadingAnchor),
            docView.trailingAnchor.constraint(equalTo: scroll.contentView.trailingAnchor),

            listStack.topAnchor.constraint(equalTo: docView.topAnchor),
            listStack.leadingAnchor.constraint(equalTo: docView.leadingAnchor),
            listStack.trailingAnchor.constraint(equalTo: docView.trailingAnchor),
            listStack.bottomAnchor.constraint(equalTo: docView.bottomAnchor),

            searchSep.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            searchSep.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            searchSep.topAnchor.constraint(equalTo: scroll.bottomAnchor, constant: 6),

            searchField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            searchField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            searchField.topAnchor.constraint(equalTo: searchSep.bottomAnchor, constant: 10),
            searchField.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),
        ])
    }

    // MARK: - Present / dismiss

    func present(in parent: NSView, actions: [PaletteAction], title: String) {
        guard !actions.isEmpty else { return }
        self.parent = parent
        allActions = actions
        searchField.stringValue = ""
        headerLabel.stringValue = title.isEmpty ? "Actions" : title

        if backdrop.superview == nil {
            parent.addSubview(backdrop)
            parent.addSubview(container)
            NSLayoutConstraint.activate([
                backdrop.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
                backdrop.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
                backdrop.topAnchor.constraint(equalTo: parent.topAnchor),
                backdrop.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
                // Anchored bottom-right, just above the action bar; content grows upward.
                container.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -8),
                container.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -44),
            ])
        }
        backdrop.isHidden = false
        container.isHidden = false
        container.layer?.borderColor = NSColor.separatorColor.cgColor

        applyFilter("")
        selected = 0
        parent.window?.makeFirstResponder(searchField)
    }

    func dismiss() {
        guard isShown else { return }
        backdrop.removeFromSuperview()
        container.removeFromSuperview()
        onDismiss?()
    }

    // MARK: - Filtering / selection

    private func applyFilter(_ query: String) {
        let q = query.lowercased()
        filtered = q.isEmpty ? allActions : allActions.filter { $0.title.lowercased().contains(q) }
        rebuildRows()
        selected = 0
        updateSelectionHighlight()
        updateScrollHeight()
    }

    private func rebuildRows() {
        rows.forEach { $0.removeFromSuperview() }
        rows.removeAll()
        for (i, action) in filtered.enumerated() {
            let row = ActionRowView(action: action, icon: Self.inferIcon(action), height: rowHeight)
            row.onClick = { [weak self] in self?.runRow(i) }
            row.onHover = { [weak self] in self?.setSelected(i) }
            listStack.addArrangedSubview(row)
            row.widthAnchor.constraint(equalTo: listStack.widthAnchor).isActive = true
            rows.append(row)
        }
    }

    private func updateScrollHeight() {
        let visible = min(filtered.count, maxVisibleRows)
        let h = CGFloat(max(visible, 1)) * rowHeight + CGFloat(max(visible - 1, 0)) * listStack.spacing
        scrollHeight.constant = h
    }

    private func setSelected(_ i: Int) {
        guard i >= 0, i < filtered.count else { return }
        selected = i
        updateSelectionHighlight()
    }

    private func updateSelectionHighlight() {
        for (i, row) in rows.enumerated() { row.setSelected(i == selected) }
        if selected < rows.count { rows[selected].scrollToVisible(rows[selected].bounds) }
    }

    private func move(_ delta: Int) {
        guard !filtered.isEmpty else { return }
        selected = max(0, min(filtered.count - 1, selected + delta))
        updateSelectionHighlight()
    }

    private func runRow(_ i: Int) {
        guard i >= 0, i < filtered.count else { return }
        // The actions were captured at present() time; a re-render dismisses this panel, so the
        // captured closure can't be stale when a click reaches us. Call it directly — no index round-trip.
        let action = filtered[i]
        dismiss()
        action.run()
    }

    // MARK: - NSTextFieldDelegate (the panel's own search field)

    func controlTextDidChange(_ obj: Notification) {
        applyFilter(searchField.stringValue)
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch commandSelector {
        case #selector(NSResponder.moveDown(_:)): move(1); return true
        case #selector(NSResponder.moveUp(_:)): move(-1); return true
        case #selector(NSResponder.insertNewline(_:)): runRow(selected); return true
        case #selector(NSResponder.cancelOperation(_:)): dismiss(); return true
        default: return false
        }
    }

    /// Map common action titles to an SF Symbol when the action didn't supply one.
    static func inferIcon(_ a: PaletteAction) -> String {
        if let i = a.icon { return i }
        let t = a.title.lowercased()
        if t.hasPrefix("paste") { return "doc.on.clipboard" }
        if t.hasPrefix("copy") { return "doc.on.doc" }
        if t.hasPrefix("open") { return "arrow.up.forward.app" }
        if t.contains("ai") { return "sparkles" }
        return "return"
    }
}

/// One action row: icon + title (left), shortcut keycaps (right), with a rounded selection highlight.
final class ActionRowView: NSView {
    var onClick: (() -> Void)?
    var onHover: (() -> Void)?
    private let highlight = NSView()
    private var tracking: NSTrackingArea?

    init(action: PaletteAction, icon: String, height: CGFloat) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true

        highlight.wantsLayer = true
        highlight.layer?.cornerRadius = 6
        highlight.layer?.backgroundColor = NSColor.selectedContentBackgroundColor.withAlphaComponent(0.85).cgColor
        highlight.isHidden = true
        highlight.translatesAutoresizingMaskIntoConstraints = false
        addSubview(highlight)

        let iconView = NSImageView()
        iconView.image = NSImage(systemSymbolName: icon, accessibilityDescription: nil)
        iconView.contentTintColor = .secondaryLabelColor
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = NSTextField(labelWithString: action.title)
        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textColor = .labelColor
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let chips = action.shortcut.map { Keycap.chips(for: $0, fontSize: 10) } ?? []
        let caps = NSStackView(views: chips)
        caps.spacing = 3
        caps.setHuggingPriority(.required, for: .horizontal) // hug the chips at the right; don't stretch
        caps.translatesAutoresizingMaskIntoConstraints = false

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(caps)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: height),
            highlight.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            highlight.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            highlight.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            highlight.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),

            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            // No chip-gap when the row has no shortcut, so the title can use the full width to the edge.
            caps.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: chips.isEmpty ? 0 : 8),
            caps.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            caps.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setSelected(_ s: Bool) {
        highlight.isHidden = !s
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let tracking { removeTrackingArea(tracking) }
        let t = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self)
        addTrackingArea(t)
        tracking = t
    }

    // .inVisibleRect tracking areas synthesize mouseEntered when content scrolls under a stationary
    // cursor (e.g. keyboard nav scrolling a row into view) — that must NOT hijack the keyboard
    // selection. Only treat it as a hover if the pointer actually moved since the last entry.
    private static var lastMouseLocation: NSPoint = .zero
    override func mouseEntered(with event: NSEvent) {
        let loc = NSEvent.mouseLocation
        if loc != ActionRowView.lastMouseLocation {
            ActionRowView.lastMouseLocation = loc
            onHover?()
        }
    }
    override func mouseMoved(with event: NSEvent) { ActionRowView.lastMouseLocation = NSEvent.mouseLocation; onHover?() }
    override func mouseUp(with event: NSEvent) { onClick?() }
}
