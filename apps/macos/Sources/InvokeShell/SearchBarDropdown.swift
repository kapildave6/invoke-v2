import AppKit

/// World-class, Raycast-style search-bar dropdown (e.g. the search-engine picker). A styled pill
/// trigger — [favicon · title · chevron] — that opens a translucent popover with an inline filter
/// field and favicon+label rows, fully keyboard-navigable. Like ActionPanel it lives INSIDE the
/// palette window (not a separate window) so opening it never steals key focus or trips auto-hide.
final class SearchBarDropdown: NSView {
    struct Item { let title: String; let value: String; let iconRef: String? }

    private let iconView = NSImageView()
    private let titleLabel = NSTextField(labelWithString: "")
    private let chevron = NSImageView()
    private let overlay = DropdownOverlay()

    private var items: [Item] = []
    private var selectedValue = ""
    private var onSelect: ((String) -> Void)?
    /// The view the popover is presented inside (the palette's content/blur view).
    weak var hostContentView: NSView?

    var isOpen: Bool { overlay.isShown }

    override init(frame: NSRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer?.cornerRadius = 7
        layer?.backgroundColor = NSColor.controlColor.withAlphaComponent(0.45).cgColor
        layer?.borderWidth = 1
        layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.6).cgColor

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.imageScaling = .scaleProportionallyUpOrDown
        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textColor = .labelColor
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        chevron.image = NSImage(systemSymbolName: "chevron.up.chevron.down", accessibilityDescription: nil)
        chevron.contentTintColor = .secondaryLabelColor
        chevron.translatesAutoresizingMaskIntoConstraints = false

        addSubview(iconView); addSubview(titleLabel); addSubview(chevron)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 28),
            widthAnchor.constraint(lessThanOrEqualToConstant: 240),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 9),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 7),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevron.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -9),
            chevron.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 11),
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Point the cursor finger at the pill.
    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }

    func configure(items: [Item], selected: String, tooltip: String? = nil, onSelect: @escaping (String) -> Void) {
        self.items = items
        self.selectedValue = selected
        self.onSelect = onSelect
        self.toolTip = tooltip
        if let cur = items.first(where: { $0.value == selected }) ?? items.first {
            titleLabel.stringValue = cur.title
            FaviconLoader.load(cur.iconRef, into: iconView)
        }
        isHidden = false
        if overlay.isShown { overlay.dismiss() } // options changed → close any stale popover
    }

    func toggle() { overlay.isShown ? overlay.dismiss() : open() }

    func open() {
        guard let host = hostContentView, !items.isEmpty else { return }
        overlay.present(in: host, anchor: self, items: items, selected: selectedValue) { [weak self] value in
            guard let self else { return }
            self.selectedValue = value
            if let cur = self.items.first(where: { $0.value == value }) {
                self.titleLabel.stringValue = cur.title
                FaviconLoader.load(cur.iconRef, into: self.iconView)
            }
            self.onSelect?(value)
        }
    }

    func dismiss() { overlay.dismiss() }
    func hide() { overlay.dismiss(); isHidden = true }

    override func mouseDown(with event: NSEvent) { toggle() }
}

/// The popover body: a translucent rounded panel with a filter field + favicon rows, anchored under
/// the trigger and growing downward. Mirrors ActionPanel's in-window, keyboard-first approach.
private final class DropdownOverlay: NSObject, NSTextFieldDelegate {
    private final class Flipped: NSView { override var isFlipped: Bool { true } }
    private final class Backdrop: NSView { var onClick: (() -> Void)?; override func mouseDown(with e: NSEvent) { onClick?() } }

    private let backdrop = Backdrop()
    private let container = NSVisualEffectView()
    private let searchField = NSTextField()
    private let listStack = NSStackView()
    private let docView = Flipped()
    private let scroll = NSScrollView()
    private var scrollHeight: NSLayoutConstraint!
    private var anchorConstraints: [NSLayoutConstraint] = []

    private weak var parent: NSView?
    private var allItems: [SearchBarDropdown.Item] = []
    private var filtered: [SearchBarDropdown.Item] = []
    private var rows: [DropdownRow] = []
    private var selected = 0
    private var onSelect: ((String) -> Void)?

    private let rowHeight: CGFloat = 36
    private let maxVisibleRows = 8
    private let panelWidth: CGFloat = 300

    var isShown: Bool { container.superview != nil }

    override init() { super.init(); build() }

    private func build() {
        backdrop.translatesAutoresizingMaskIntoConstraints = false
        backdrop.onClick = { [weak self] in self?.dismiss() }

        container.material = .menu
        container.blendingMode = .withinWindow
        container.state = .active
        container.wantsLayer = true
        container.layer?.cornerRadius = 10
        container.layer?.masksToBounds = true
        container.layer?.borderWidth = 1
        container.layer?.borderColor = NSColor.separatorColor.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false

        searchField.placeholderString = "Search…"
        searchField.font = .systemFont(ofSize: 13)
        searchField.isBordered = false
        searchField.drawsBackground = false
        searchField.focusRingType = .none
        searchField.delegate = self
        searchField.translatesAutoresizingMaskIntoConstraints = false

        let sep = NSBox(); sep.boxType = .separator; sep.translatesAutoresizingMaskIntoConstraints = false

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

        container.addSubview(searchField)
        container.addSubview(sep)
        container.addSubview(scroll)

        scrollHeight = scroll.heightAnchor.constraint(equalToConstant: rowHeight)
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: panelWidth),
            searchField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            searchField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            searchField.topAnchor.constraint(equalTo: container.topAnchor, constant: 11),
            sep.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            sep.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            sep.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 10),
            scroll.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 6),
            scroll.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -6),
            scroll.topAnchor.constraint(equalTo: sep.bottomAnchor, constant: 6),
            scroll.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
            scrollHeight,
            docView.topAnchor.constraint(equalTo: scroll.contentView.topAnchor),
            docView.leadingAnchor.constraint(equalTo: scroll.contentView.leadingAnchor),
            docView.trailingAnchor.constraint(equalTo: scroll.contentView.trailingAnchor),
            listStack.topAnchor.constraint(equalTo: docView.topAnchor),
            listStack.leadingAnchor.constraint(equalTo: docView.leadingAnchor),
            listStack.trailingAnchor.constraint(equalTo: docView.trailingAnchor),
            listStack.bottomAnchor.constraint(equalTo: docView.bottomAnchor),
        ])
    }

    func present(in parent: NSView, anchor: NSView, items: [SearchBarDropdown.Item], selected: String, onSelect: @escaping (String) -> Void) {
        self.parent = parent
        self.allItems = items
        self.onSelect = onSelect
        searchField.stringValue = ""

        backdrop.removeFromSuperview(); container.removeFromSuperview()
        NSLayoutConstraint.deactivate(anchorConstraints)
        parent.addSubview(backdrop)
        parent.addSubview(container)
        anchorConstraints = [
            backdrop.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            backdrop.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            backdrop.topAnchor.constraint(equalTo: parent.topAnchor),
            backdrop.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            // Below the trigger, right-aligned to it (Raycast).
            container.topAnchor.constraint(equalTo: anchor.bottomAnchor, constant: 6),
            container.trailingAnchor.constraint(equalTo: anchor.trailingAnchor),
        ]
        NSLayoutConstraint.activate(anchorConstraints)

        applyFilter("")
        // Preselect the current value.
        if let idx = filtered.firstIndex(where: { $0.value == selected }) { selected2(idx) }
        parent.window?.makeFirstResponder(searchField)
    }

    func dismiss() {
        guard isShown else { return }
        backdrop.removeFromSuperview()
        container.removeFromSuperview()
        // Return key focus to the palette's main search field.
        if let parent, let win = parent.window {
            win.makeFirstResponder(win.contentView?.subviews.compactMap { $0 as? NSTextField }.first)
        }
    }

    private func applyFilter(_ q: String) {
        let query = q.lowercased()
        filtered = query.isEmpty ? allItems : allItems.filter { $0.title.lowercased().contains(query) }
        rows.forEach { $0.removeFromSuperview() }
        rows.removeAll()
        for (i, it) in filtered.enumerated() {
            let row = DropdownRow(item: it, height: rowHeight)
            row.onClick = { [weak self] in self?.run(i) }
            row.onHover = { [weak self] in self?.selected2(i) }
            listStack.addArrangedSubview(row)
            row.widthAnchor.constraint(equalTo: listStack.widthAnchor).isActive = true
            rows.append(row)
        }
        selected = 0
        highlight()
        let visible = min(max(filtered.count, 1), maxVisibleRows)
        scrollHeight.constant = CGFloat(visible) * rowHeight + CGFloat(max(visible - 1, 0)) * listStack.spacing
    }

    private func selected2(_ i: Int) { guard i >= 0, i < filtered.count else { return }; selected = i; highlight() }
    private func highlight() {
        for (i, r) in rows.enumerated() { r.setSelected(i == selected) }
        if selected < rows.count { rows[selected].scrollToVisible(rows[selected].bounds) }
    }
    private func move(_ d: Int) { guard !filtered.isEmpty else { return }; selected = max(0, min(filtered.count - 1, selected + d)); highlight() }
    private func run(_ i: Int) {
        guard i >= 0, i < filtered.count else { return }
        let value = filtered[i].value
        dismiss()
        onSelect?(value)
    }

    func controlTextDidChange(_ obj: Notification) { applyFilter(searchField.stringValue) }
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch commandSelector {
        case #selector(NSResponder.moveDown(_:)): move(1); return true
        case #selector(NSResponder.moveUp(_:)): move(-1); return true
        case #selector(NSResponder.insertNewline(_:)): run(selected); return true
        case #selector(NSResponder.cancelOperation(_:)): dismiss(); return true
        default: return false
        }
    }
}

/// One dropdown row: favicon + title, with a rounded accent-blue selection highlight (Raycast).
private final class DropdownRow: NSView {
    var onClick: (() -> Void)?
    var onHover: (() -> Void)?
    private let highlight = NSView()
    private let iconView = NSImageView()
    private let label = NSTextField(labelWithString: "")
    private var tracking: NSTrackingArea?

    init(item: SearchBarDropdown.Item, height: CGFloat) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true

        highlight.wantsLayer = true
        highlight.layer?.cornerRadius = 6
        // Vivid accent fill like Raycast (always on, not the dimmed inactive selection color).
        highlight.layer?.backgroundColor = NSColor.controlAccentColor.cgColor
        highlight.isHidden = true
        highlight.translatesAutoresizingMaskIntoConstraints = false
        addSubview(highlight)

        iconView.imageScaling = .scaleProportionallyUpOrDown
        iconView.translatesAutoresizingMaskIntoConstraints = false
        FaviconLoader.load(item.iconRef, into: iconView)

        label.stringValue = item.title
        label.font = .systemFont(ofSize: 13)
        label.textColor = .labelColor
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(iconView); addSubview(label)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: height),
            highlight.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            highlight.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            highlight.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            highlight.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setSelected(_ s: Bool) {
        highlight.isHidden = !s
        label.textColor = s ? .white : .labelColor // white on the accent fill (Raycast)
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let tracking { removeTrackingArea(tracking) }
        let t = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self)
        addTrackingArea(t); tracking = t
    }
    private static var lastMouse: NSPoint = .zero
    override func mouseEntered(with event: NSEvent) {
        let loc = NSEvent.mouseLocation
        if loc != DropdownRow.lastMouse { DropdownRow.lastMouse = loc; onHover?() }
    }
    override func mouseMoved(with event: NSEvent) { DropdownRow.lastMouse = NSEvent.mouseLocation; onHover?() }
    override func mouseUp(with event: NSEvent) { onClick?() }
}

/// Loads a 16–18px icon into an image view from a local path, file://, or http(s) URL (favicons load
/// async; all cached). Anything else (e.g. an SF-symbol name) yields that symbol if it resolves.
enum FaviconLoader {
    private static var cache: [String: NSImage] = [:]
    static func load(_ ref: String?, into view: NSImageView) {
        guard let ref, !ref.isEmpty else { view.image = NSImage(systemSymbolName: "globe", accessibilityDescription: nil); return }
        if let img = cache[ref] { view.image = img; return }
        if ref.hasPrefix("/"), let img = NSImage(contentsOfFile: ref) { cache[ref] = img; view.image = img; return }
        if ref.hasPrefix("file://"), let u = URL(string: ref), let img = NSImage(contentsOf: u) { cache[ref] = img; view.image = img; return }
        if ref.hasPrefix("http"), let u = URL(string: ref) {
            view.image = NSImage(systemSymbolName: "globe", accessibilityDescription: nil) // placeholder until loaded
            URLSession.shared.dataTask(with: u) { data, _, _ in
                guard let data, let img = NSImage(data: data) else { return }
                DispatchQueue.main.async { cache[ref] = img; view.image = img }
            }.resume()
            return
        }
        view.image = NSImage(systemSymbolName: ref, accessibilityDescription: nil)
            ?? NSImage(systemSymbolName: "globe", accessibilityDescription: nil)
    }
}
