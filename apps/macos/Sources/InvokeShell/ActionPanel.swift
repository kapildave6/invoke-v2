import AppKit

private final class FlippedView: NSView { override var isFlipped: Bool { true } }
private final class BackdropView: NSView {
    var onClick: (() -> Void)?
    override func mouseDown(with event: NSEvent) { onClick?() }
}

/// One displayed row in the panel. Headers/separators are non-selectable.
private enum PanelRow {
    case separator
    case header(String)
    case action(PaletteAction)
    case submenu(title: String, icon: String?, sections: [ActionSection])
    var isSelectable: Bool { if case .action = self { return true }; if case .submenu = self { return true }; return false }
}

/// Raycast-style Action Panel (PLAN.md §6): a floating rounded panel anchored bottom-right inside the
/// palette, listing the selected result's actions grouped into sections, with submenus that drill in.
/// Arrow keys move, Return runs / enters a submenu, →/← drill in/out, Esc pops a level or dismisses.
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
    private var levels: [[ActionSection]] = []   // navigation stack; .last is the current level
    private var levelTitles: [String] = []
    private var rows: [PanelRow] = []            // current filtered display rows
    private var rowViews: [NSView] = []
    private var selectable: [Bool] = []
    private var selected = 0

    var onDismiss: (() -> Void)?
    var isShown: Bool { container.superview != nil }

    private let rowHeight: CGFloat = 34
    private let headerHeight: CGFloat = 22
    private let sepHeight: CGFloat = 9
    private let maxVisibleRows = 8
    private let panelWidth: CGFloat = 340

    override init() { super.init(); buildViews() }

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

    func present(in parent: NSView, sections: [ActionSection], title: String) {
        guard sections.contains(where: { $0.entries.contains(where: { if case .action = $0 { return true }; if case .submenu = $0 { return true }; return false }) }) else { return }
        self.parent = parent
        levels = [sections]
        levelTitles = [title.isEmpty ? "Actions" : title]
        searchField.stringValue = ""

        if backdrop.superview == nil {
            parent.addSubview(backdrop)
            parent.addSubview(container)
            NSLayoutConstraint.activate([
                backdrop.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
                backdrop.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
                backdrop.topAnchor.constraint(equalTo: parent.topAnchor),
                backdrop.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
                container.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -8),
                container.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -44),
            ])
        }
        backdrop.isHidden = false
        container.isHidden = false
        container.layer?.borderColor = NSColor.separatorColor.cgColor

        applyFilter("")
        parent.window?.makeFirstResponder(searchField)
    }

    func dismiss() {
        guard isShown else { return }
        backdrop.removeFromSuperview()
        container.removeFromSuperview()
        levels = []; levelTitles = []
        onDismiss?()
    }

    // MARK: - Build rows from the current level

    private func applyFilter(_ query: String) {
        let q = query.lowercased()
        let sections = levels.last ?? []
        rows = []
        var firstSection = true
        for section in sections {
            let entries = section.entries.filter { entry in
                guard !q.isEmpty else { return true }
                switch entry {
                case .action(let a): return a.title.lowercased().contains(q)
                case .submenu(let t, _, _): return t.lowercased().contains(q)
                }
            }
            guard !entries.isEmpty else { continue }
            if !firstSection { rows.append(.separator) }
            firstSection = false
            if let title = section.title, !title.isEmpty { rows.append(.header(title)) }
            for entry in entries {
                switch entry {
                case .action(let a): rows.append(.action(a))
                case .submenu(let t, let i, let s): rows.append(.submenu(title: t, icon: i, sections: s))
                }
            }
        }
        selectable = rows.map { $0.isSelectable }
        rebuildRows()
        selected = firstSelectable(selectable)
        updateSelectionHighlight()
        updateScrollHeight()
        updateHeader()
    }

    private func rebuildRows() {
        rowViews.forEach { $0.removeFromSuperview() }
        rowViews.removeAll()
        for (i, row) in rows.enumerated() {
            let view: NSView
            switch row {
            case .separator:
                let box = NSBox(); box.boxType = .separator
                box.translatesAutoresizingMaskIntoConstraints = false
                box.heightAnchor.constraint(equalToConstant: 1).isActive = true
                view = box
            case .header(let title):
                let l = NSTextField(labelWithString: title.uppercased())
                l.font = .systemFont(ofSize: 10, weight: .semibold)
                l.textColor = .tertiaryLabelColor
                l.translatesAutoresizingMaskIntoConstraints = false
                let wrap = NSView(); wrap.translatesAutoresizingMaskIntoConstraints = false
                wrap.addSubview(l)
                NSLayoutConstraint.activate([
                    wrap.heightAnchor.constraint(equalToConstant: headerHeight),
                    l.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 12),
                    l.bottomAnchor.constraint(equalTo: wrap.bottomAnchor, constant: -4),
                ])
                view = wrap
            case .action(let a):
                let r = ActionRowView(title: a.title, shortcut: a.shortcut, icon: ActionPanel.inferIcon(a), isSubmenu: false, height: rowHeight)
                r.onClick = { [weak self] in self?.activate(i) }
                r.onHover = { [weak self] in self?.setSelected(i) }
                view = r
            case .submenu(let t, let icon, _):
                let r = ActionRowView(title: t, shortcut: nil, icon: icon ?? "chevron.right.2", isSubmenu: true, height: rowHeight)
                r.onClick = { [weak self] in self?.activate(i) }
                r.onHover = { [weak self] in self?.setSelected(i) }
                view = r
            }
            listStack.addArrangedSubview(view)
            view.widthAnchor.constraint(equalTo: listStack.widthAnchor).isActive = true
            rowViews.append(view)
        }
    }

    private func updateScrollHeight() {
        var h: CGFloat = 0
        for (i, row) in rows.enumerated() {
            switch row {
            case .separator: h += 1
            case .header: h += headerHeight
            default: h += rowHeight
            }
            if i < rows.count - 1 { h += listStack.spacing }
        }
        let maxH = CGFloat(maxVisibleRows) * (rowHeight + listStack.spacing)
        scrollHeight.constant = min(max(h, rowHeight), maxH)
    }

    private func updateHeader() {
        let title = levelTitles.last ?? "Actions"
        headerLabel.stringValue = levels.count > 1 ? "‹  \(title)" : title
    }

    // MARK: - Selection

    private func setSelected(_ i: Int) {
        guard i >= 0, i < rows.count, selectable[i] else { return }
        selected = i
        updateSelectionHighlight()
    }

    private func updateSelectionHighlight() {
        for (i, v) in rowViews.enumerated() { (v as? ActionRowView)?.setSelected(i == selected) }
        if selected < rowViews.count { rowViews[selected].scrollToVisible(rowViews[selected].bounds) }
    }

    private func move(_ delta: Int) {
        guard !rows.isEmpty else { return }
        selected = nextSelectable(selectable, from: selected, delta: delta)
        updateSelectionHighlight()
    }

    // MARK: - Activate / navigate

    private func activate(_ i: Int) {
        guard i >= 0, i < rows.count else { return }
        switch rows[i] {
        case .action(let a): dismiss(); a.run()
        case .submenu(_, _, let sections): drillIn(sections, title: submenuTitle(at: i))
        default: break
        }
    }

    private func submenuTitle(at i: Int) -> String {
        if case .submenu(let t, _, _) = rows[i] { return t }
        return "Submenu"
    }

    private func drillIn(_ sections: [ActionSection], title: String) {
        guard sections.contains(where: { $0.entries.contains(where: { if case .action = $0 { return true }; if case .submenu = $0 { return true }; return false }) }) else { return }
        levels.append(sections)
        levelTitles.append(title)
        searchField.stringValue = ""
        applyFilter("")
    }

    private func popLevel() {
        guard levels.count > 1 else { return }
        levels.removeLast(); levelTitles.removeLast()
        searchField.stringValue = ""
        applyFilter("")
    }

    /// Esc: pop a submenu level, or dismiss at the root.
    private func back() {
        if levels.count > 1 { popLevel() } else { dismiss() }
    }

    // MARK: - NSTextFieldDelegate (the panel's own search field)

    func controlTextDidChange(_ obj: Notification) { applyFilter(searchField.stringValue) }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch commandSelector {
        case #selector(NSResponder.moveDown(_:)): move(1); return true
        case #selector(NSResponder.moveUp(_:)): move(-1); return true
        case #selector(NSResponder.moveRight(_:)):
            if selected < rows.count, case .submenu = rows[selected] { activate(selected); return true }
            return false // let the caret move within the search text
        case #selector(NSResponder.moveLeft(_:)):
            if levels.count > 1 { popLevel(); return true }
            return false
        case #selector(NSResponder.insertNewline(_:)): activate(selected); return true
        case #selector(NSResponder.cancelOperation(_:)): back(); return true
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

/// One action row: icon + title (left), and either shortcut keycaps or a submenu chevron (right),
/// with a rounded selection highlight.
final class ActionRowView: NSView {
    var onClick: (() -> Void)?
    var onHover: (() -> Void)?
    private let highlight = NSView()
    private var tracking: NSTrackingArea?

    init(title: String, shortcut: String?, icon: String, isSubmenu: Bool, height: CGFloat) {
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

        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textColor = .labelColor
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Right side: a submenu chevron, or the shortcut keycaps.
        let trailing: NSView
        if isSubmenu {
            let chev = NSImageView(image: NSImage(systemSymbolName: "chevron.right", accessibilityDescription: nil) ?? NSImage())
            chev.contentTintColor = .tertiaryLabelColor
            chev.translatesAutoresizingMaskIntoConstraints = false
            chev.setContentHuggingPriority(.required, for: .horizontal)
            trailing = chev
        } else {
            let chips = shortcut.map { Keycap.chips(for: $0, fontSize: 10) } ?? []
            let caps = NSStackView(views: chips)
            caps.spacing = 3
            caps.setHuggingPriority(.required, for: .horizontal)
            caps.translatesAutoresizingMaskIntoConstraints = false
            trailing = caps
        }

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(trailing)

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
            trailing.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
            trailing.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            trailing.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setSelected(_ s: Bool) { highlight.isHidden = !s }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let tracking { removeTrackingArea(tracking) }
        let t = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self)
        addTrackingArea(t)
        tracking = t
    }

    private static var lastMouseLocation: NSPoint = .zero
    override func mouseEntered(with event: NSEvent) {
        let loc = NSEvent.mouseLocation
        if loc != ActionRowView.lastMouseLocation { ActionRowView.lastMouseLocation = loc; onHover?() }
    }
    override func mouseMoved(with event: NSEvent) { ActionRowView.lastMouseLocation = NSEvent.mouseLocation; onHover?() }
    override func mouseUp(with event: NSEvent) { onClick?() }
}
