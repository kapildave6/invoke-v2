import AppKit

/// World-class form dropdown — a full-width styled pill (selected title + chevron, optional leading
/// icon) that opens a translucent, keyboard-navigable popover. Replaces the system `NSPopUpButton` in
/// rendered forms so they match the rest of Invoke (and Raycast). Lives inside the palette window via a
/// host view, so opening it never steals key focus or trips the borderless panel's auto-hide.
///
/// (Mirrors InvokeShell's `SearchBarDropdown` by design language; it can't reuse that type directly
/// because InvokeShell depends on InvokePalette, not the other way round.)
final class FormDropdown: NSView {
    struct Item {
        let title: String
        let value: String
        let iconPath: String?
        let isHeader: Bool
        init(title: String, value: String, iconPath: String? = nil, isHeader: Bool = false) {
            self.title = title; self.value = value; self.iconPath = iconPath; self.isHeader = isHeader
        }
    }

    private let iconView = NSImageView()
    private let titleLabel = NSTextField(labelWithString: "")
    private let chevron = NSImageView()
    private let overlay = FormDropdownOverlay()
    private var iconWidth: NSLayoutConstraint!
    private var titleLeading: NSLayoutConstraint!

    private var items: [Item] = []
    private(set) var selectedValue = ""
    private var onSelect: ((String) -> Void)?
    /// The view the popover is presented inside (the palette's content/blur view) so it floats above the
    /// form's scroll view instead of being clipped by it.
    weak var hostContentView: NSView?

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
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        chevron.image = NSImage(systemSymbolName: "chevron.up.chevron.down", accessibilityDescription: nil)
        chevron.contentTintColor = .secondaryLabelColor
        chevron.translatesAutoresizingMaskIntoConstraints = false

        addSubview(iconView); addSubview(titleLabel); addSubview(chevron)
        iconWidth = iconView.widthAnchor.constraint(equalToConstant: 16)
        titleLeading = titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 7)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 28),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconWidth,
            iconView.heightAnchor.constraint(equalToConstant: 16),
            titleLeading,
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevron.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            chevron.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 11),
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }

    func configure(items: [Item], selected: String, onSelect: @escaping (String) -> Void) {
        self.items = items
        self.onSelect = onSelect
        let initial = items.first(where: { $0.value == selected && !$0.isHeader })
            ?? items.first(where: { !$0.isHeader })
        selectedValue = initial?.value ?? selected
        applyTrigger(initial)
    }

    private func applyTrigger(_ item: Item?) {
        titleLabel.stringValue = item?.title ?? ""
        let hasIcon = FormIcon.load(item?.iconPath, into: iconView)
        iconView.isHidden = !hasIcon
        iconWidth.constant = hasIcon ? 16 : 0
        titleLeading.constant = hasIcon ? 7 : 1
    }

    /// Update the displayed selection WITHOUT firing onChange (used by the form reconcile path when a
    /// controlled re-render changes the value).
    func setSelected(_ value: String) {
        selectedValue = value
        applyTrigger(items.first(where: { $0.value == value }))
    }

    func toggle() { overlay.isShown ? overlay.dismiss() : open() }

    func open() {
        guard let host = hostContentView, items.contains(where: { !$0.isHeader }) else { return }
        overlay.present(in: host, anchor: self, items: items, selected: selectedValue, minWidth: bounds.width) { [weak self] value in
            guard let self else { return }
            self.selectedValue = value
            self.applyTrigger(self.items.first(where: { $0.value == value }))
            self.onSelect?(value)
        }
    }

    func dismiss() { overlay.dismiss() }
    override func mouseDown(with event: NSEvent) { toggle() }
}

/// Popover body for `FormDropdown`: a translucent rounded panel with an inline filter + selectable
/// rows (and non-selectable section headers), anchored under the trigger and left-aligned to it.
/// Keyboard-first (↑/↓ skip headers, ⏎ selects, esc dismisses) like the action panel.
private final class FormDropdownOverlay: NSObject, NSTextFieldDelegate {
    private final class Flipped: NSView { override var isFlipped: Bool { true } }
    private final class Backdrop: NSView { var onClick: (() -> Void)?; override func mouseDown(with e: NSEvent) { onClick?() } }

    private let backdrop = Backdrop()
    private let container = NSVisualEffectView()
    private let searchField = NSTextField()
    private let listStack = NSStackView()
    private let docView = Flipped()
    private let scroll = NSScrollView()
    private var scrollHeight: NSLayoutConstraint!
    private var widthConstraint: NSLayoutConstraint!
    private var anchorConstraints: [NSLayoutConstraint] = []

    private weak var parent: NSView?
    private var allItems: [FormDropdown.Item] = []
    private var filtered: [FormDropdown.Item] = []      // rows shown (may include headers)
    private var rows: [FormDropdownRow] = []
    private var selectable: [Int] = []                  // indexes into `filtered` that are selectable
    private var cursor = 0                               // index into `selectable`
    private var onSelect: ((String) -> Void)?

    private let rowHeight: CGFloat = 30
    private let headerHeight: CGFloat = 24
    private let maxPanelHeight: CGFloat = 264
    private var minWidth: CGFloat = 220

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
        widthConstraint = container.widthAnchor.constraint(equalToConstant: 240)
        NSLayoutConstraint.activate([
            widthConstraint,
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

    func present(in parent: NSView, anchor: NSView, items: [FormDropdown.Item], selected: String, minWidth: CGFloat, onSelect: @escaping (String) -> Void) {
        self.parent = parent
        self.allItems = items
        self.onSelect = onSelect
        self.minWidth = max(220, minWidth)
        widthConstraint.constant = self.minWidth
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
            // Below the trigger, left-aligned to it (forms read left-to-right).
            container.topAnchor.constraint(equalTo: anchor.bottomAnchor, constant: 6),
            container.leadingAnchor.constraint(equalTo: anchor.leadingAnchor),
        ]
        NSLayoutConstraint.activate(anchorConstraints)

        applyFilter("")
        if let idx = filtered.firstIndex(where: { $0.value == selected && !$0.isHeader }),
           let s = selectable.firstIndex(of: idx) { cursor = s; highlight() }
        parent.window?.makeFirstResponder(searchField)
    }

    func dismiss() {
        guard isShown else { return }
        backdrop.removeFromSuperview()
        container.removeFromSuperview()
    }

    private func applyFilter(_ q: String) {
        let query = q.lowercased()
        if query.isEmpty {
            filtered = allItems
        } else {
            // Keep a section header only if it still has a matching item under it.
            var out: [FormDropdown.Item] = []
            for (i, it) in allItems.enumerated() {
                if it.isHeader {
                    let hasMatch = allItems[(i + 1)...].prefix(while: { !$0.isHeader }).contains { $0.title.lowercased().contains(query) }
                    if hasMatch { out.append(it) }
                } else if it.title.lowercased().contains(query) {
                    out.append(it)
                }
            }
            filtered = out
        }
        rows.forEach { $0.removeFromSuperview() }
        rows.removeAll()
        selectable.removeAll()
        var total: CGFloat = 0
        for (i, it) in filtered.enumerated() {
            let row = FormDropdownRow(item: it, height: it.isHeader ? headerHeight : rowHeight)
            if !it.isHeader {
                let idx = i
                row.onClick = { [weak self] in self?.run(filteredIndex: idx) }
                row.onHover = { [weak self] in self?.moveCursor(toFilteredIndex: idx) }
                selectable.append(i)
            }
            listStack.addArrangedSubview(row)
            row.widthAnchor.constraint(equalTo: listStack.widthAnchor).isActive = true
            rows.append(row)
            total += (it.isHeader ? headerHeight : rowHeight)
        }
        total += CGFloat(max(filtered.count - 1, 0)) * listStack.spacing
        scrollHeight.constant = max(rowHeight, min(total, maxPanelHeight))
        cursor = 0
        highlight()
    }

    private func moveCursor(toFilteredIndex idx: Int) {
        guard let s = selectable.firstIndex(of: idx) else { return }
        cursor = s; highlight()
    }
    private func highlight() {
        let active = (cursor >= 0 && cursor < selectable.count) ? selectable[cursor] : -1
        for (i, r) in rows.enumerated() { r.setSelected(i == active) }
        if active >= 0, active < rows.count { rows[active].scrollToVisible(rows[active].bounds) }
    }
    private func move(_ d: Int) {
        guard !selectable.isEmpty else { return }
        cursor = max(0, min(selectable.count - 1, cursor + d)); highlight()
    }
    private func run(filteredIndex idx: Int) {
        guard idx >= 0, idx < filtered.count, !filtered[idx].isHeader else { return }
        let value = filtered[idx].value
        dismiss()
        onSelect?(value)
    }
    private func runCursor() {
        guard cursor >= 0, cursor < selectable.count else { return }
        run(filteredIndex: selectable[cursor])
    }

    func controlTextDidChange(_ obj: Notification) { applyFilter(searchField.stringValue) }
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch commandSelector {
        case #selector(NSResponder.moveDown(_:)): move(1); return true
        case #selector(NSResponder.moveUp(_:)): move(-1); return true
        case #selector(NSResponder.insertNewline(_:)): runCursor(); return true
        case #selector(NSResponder.cancelOperation(_:)): dismiss(); return true
        default: return false
        }
    }
}

/// One row of the form dropdown: optional icon + title, with a rounded accent-blue selection highlight.
/// A header row renders as a small, dimmed, non-interactive caption (Raycast `Form.Dropdown.Section`).
private final class FormDropdownRow: NSView {
    var onClick: (() -> Void)?
    var onHover: (() -> Void)?
    private let isHeader: Bool
    private let highlight = NSView()
    private let iconView = NSImageView()
    private let label = NSTextField(labelWithString: "")
    private var tracking: NSTrackingArea?

    init(item: FormDropdown.Item, height: CGFloat) {
        self.isHeader = item.isHeader
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true

        highlight.wantsLayer = true
        highlight.layer?.cornerRadius = 6
        highlight.layer?.backgroundColor = NSColor.controlAccentColor.cgColor
        highlight.isHidden = true
        highlight.translatesAutoresizingMaskIntoConstraints = false
        addSubview(highlight)

        let hasIcon = !isHeader && FormIcon.load(item.iconPath, into: iconView)
        iconView.imageScaling = .scaleProportionallyUpOrDown
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.isHidden = !hasIcon

        label.stringValue = isHeader ? item.title.uppercased() : item.title
        label.font = isHeader ? .systemFont(ofSize: 10, weight: .semibold) : .systemFont(ofSize: 13)
        label.textColor = isHeader ? .tertiaryLabelColor : .labelColor
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(iconView); addSubview(label)
        let textLeading = hasIcon ? iconView.trailingAnchor : leadingAnchor
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: height),
            highlight.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            highlight.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            highlight.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            highlight.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: hasIcon ? 16 : 0),
            iconView.heightAnchor.constraint(equalToConstant: 16),
            label.leadingAnchor.constraint(equalTo: textLeading, constant: hasIcon ? 9 : 12),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setSelected(_ s: Bool) {
        guard !isHeader else { return }
        highlight.isHidden = !s
        label.textColor = s ? .white : .labelColor
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if isHeader { return }
        if let tracking { removeTrackingArea(tracking) }
        let t = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self)
        addTrackingArea(t); tracking = t
    }
    private static var lastMouse: NSPoint = .zero
    override func mouseEntered(with event: NSEvent) {
        let loc = NSEvent.mouseLocation
        if loc != FormDropdownRow.lastMouse { FormDropdownRow.lastMouse = loc; onHover?() }
    }
    override func mouseMoved(with event: NSEvent) { FormDropdownRow.lastMouse = NSEvent.mouseLocation; onHover?() }
    override func mouseUp(with event: NSEvent) { onClick?() }
    override func resetCursorRects() { if !isHeader { addCursorRect(bounds, cursor: .pointingHand) } }
}

/// Loads a 16px icon for a form dropdown item: a local file path, an SF-symbol name, else nothing
/// (returns false so the trigger/row collapses the icon slot). Cached by path.
enum FormIcon {
    private static var cache: [String: NSImage] = [:]
    @discardableResult
    static func load(_ ref: String?, into view: NSImageView) -> Bool {
        guard let ref, !ref.isEmpty else { return false }
        if let img = cache[ref] { view.image = img; return true }
        if ref.hasPrefix("/"), let img = NSImage(contentsOfFile: ref) {
            img.size = NSSize(width: 16, height: 16); cache[ref] = img; view.image = img; return true
        }
        if let sym = NSImage(systemSymbolName: ref, accessibilityDescription: nil) {
            cache[ref] = sym; view.image = sym; return true
        }
        return false
    }
}

/// An NSTextView that draws placeholder text when empty (NSTextView has no native placeholder, unlike
/// NSTextField) — so a Form.TextArea shows its `placeholder` like Raycast's "Enter your test string…".
final class PlaceholderTextView: NSTextView {
    var placeholderText: String = "" { didSet { needsDisplay = true } }
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard string.isEmpty, !placeholderText.isEmpty else { return }
        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.placeholderTextColor,
            .font: font ?? .systemFont(ofSize: 13),
        ]
        let pad = textContainer?.lineFragmentPadding ?? 0
        placeholderText.draw(at: NSPoint(x: textContainerInset.width + pad, y: textContainerInset.height), withAttributes: attrs)
    }
    override func didChangeText() { super.didChangeText(); needsDisplay = true }
}
