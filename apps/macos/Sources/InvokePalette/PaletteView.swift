import AppKit
import InvokeIPC
import InvokeRenderer

/// Flipped so an NSScrollView lays its document out top-down (AppKit default is bottom-up).
private final class FlippedDocView: NSView {
    override var isFlipped: Bool { true }
}

/// The results list (PLAN.md §4.3/§6). Renders the view-model tree into:
///   • section headers,
///   • a rich result **card** (a `list-item` with `display: "card"` — used by the Calculator's
///     conversion result: big left value → arrow → big right value, with name chips), and
///   • polished, selectable item rows (icon · title · subtitle · accessory chips).
/// A virtualized custom list + the full theme-token system are the next visual pass; this
/// establishes the reusable row/card patterns every feature renders through.
public final class PaletteView: NSView {
    private let stack = NSStackView()
    private var itemCounter = 0

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 3
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("not used") }

    /// Height the rendered content wants — drives the window's compact sizing (no empty space).
    public func fittingHeight() -> CGFloat {
        layoutSubtreeIfNeeded()
        return stack.fittingSize.height
    }

    /// Re-render rows from the current view-model tree, highlighting the item at `selectedIndex`
    /// (item indices are assigned in pre-order, matching the host's selection model).
    public func render(_ tree: ViewTree, selectedIndex: Int) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        itemCounter = 0
        if let list = tree.root.children.first(where: { $0.type == "list" }),
           case .bool(true)? = list.props["showDetail"] {
            renderSplit(list: list, selectedIndex: selectedIndex) // master–detail (e.g. Clipboard History)
        } else {
            appendRows(for: tree.root, selectedIndex: selectedIndex)
        }
    }

    // MARK: - Master–detail (list + detail pane)

    private func renderSplit(list: ViewNode, selectedIndex: Int) {
        var rows: [ViewNode] = []
        func collect(_ n: ViewNode) { if n.type == "list-item" { rows.append(n) }; n.children.forEach(collect) }
        collect(list)
        let sel = rows.isEmpty ? -1 : max(0, min(selectedIndex, rows.count - 1))

        // Left: scrollable compact list.
        let leftStack = NSStackView()
        leftStack.orientation = .vertical
        leftStack.alignment = .leading
        leftStack.spacing = 2
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        if let section = list.children.first(where: { $0.type == "list-section" }), let t = section.title, !t.isEmpty {
            leftStack.addArrangedSubview(sectionLabel(t, width: 300))
        }
        var selectedRow: NSView?
        for (i, node) in rows.enumerated() {
            let r = compactRow(node, selected: i == sel, width: 300)
            if i == sel { selectedRow = r }
            leftStack.addArrangedSubview(r)
        }
        let doc = FlippedDocView()
        doc.translatesAutoresizingMaskIntoConstraints = false
        doc.addSubview(leftStack)
        let leftScroll = NSScrollView()
        leftScroll.translatesAutoresizingMaskIntoConstraints = false
        leftScroll.drawsBackground = false
        leftScroll.hasVerticalScroller = true
        leftScroll.scrollerStyle = .overlay
        leftScroll.documentView = doc

        let divider = NSBox()
        divider.boxType = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false

        let detail = detailPane(sel >= 0 ? rows[sel] : nil)
        detail.setContentHuggingPriority(.init(1), for: .horizontal) // fill the remaining width

        let h = NSStackView()
        h.orientation = .horizontal
        h.alignment = .top
        h.distribution = .fill
        h.spacing = 0
        h.translatesAutoresizingMaskIntoConstraints = false
        h.addArrangedSubview(leftScroll)
        h.addArrangedSubview(divider)
        h.addArrangedSubview(detail)

        stack.addArrangedSubview(h)
        NSLayoutConstraint.activate([
            h.widthAnchor.constraint(equalTo: stack.widthAnchor),
            h.heightAnchor.constraint(equalToConstant: 360),
            divider.widthAnchor.constraint(equalToConstant: 1),
            leftScroll.widthAnchor.constraint(equalToConstant: 300),
            leftStack.topAnchor.constraint(equalTo: doc.topAnchor, constant: 2),
            leftStack.leadingAnchor.constraint(equalTo: doc.leadingAnchor),
            leftStack.trailingAnchor.constraint(equalTo: doc.trailingAnchor),
            leftStack.bottomAnchor.constraint(equalTo: doc.bottomAnchor),
            doc.widthAnchor.constraint(equalToConstant: 300),
        ])

        // Keep the selected clip visible as you arrow through a long list.
        if let selectedRow {
            DispatchQueue.main.async {
                self.layoutSubtreeIfNeeded()
                selectedRow.scrollToVisible(selectedRow.bounds)
            }
        }
    }

    private func sectionLabel(_ text: String, width: CGFloat) -> NSView {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        let v = NSView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(label)
        NSLayoutConstraint.activate([
            v.widthAnchor.constraint(equalToConstant: width),
            label.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 8),
            label.topAnchor.constraint(equalTo: v.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -6),
        ])
        return v
    }

    private func compactRow(_ node: ViewNode, selected: Bool, width: CGFloat) -> NSView {
        let row = NSView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.wantsLayer = true
        row.layer?.cornerRadius = 6
        row.layer?.backgroundColor = selected ? NSColor.white.withAlphaComponent(0.13).cgColor : NSColor.clear.cgColor
        let h = NSStackView()
        h.orientation = .horizontal
        h.alignment = .centerY
        h.spacing = 8
        h.translatesAutoresizingMaskIntoConstraints = false
        if let icon = iconView(for: node, selected: selected) { h.addArrangedSubview(icon) }
        let title = NSTextField(labelWithString: node.title ?? "")
        title.font = .systemFont(ofSize: 13)
        title.textColor = .labelColor
        title.lineBreakMode = .byTruncatingTail
        h.addArrangedSubview(title)
        row.addSubview(h)
        NSLayoutConstraint.activate([
            row.widthAnchor.constraint(equalToConstant: width),
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 32),
            h.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 8),
            h.trailingAnchor.constraint(lessThanOrEqualTo: row.trailingAnchor, constant: -8),
            h.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        return row
    }

    private func detailPane(_ node: ViewNode?) -> NSView {
        let pane = NSView()
        pane.translatesAutoresizingMaskIntoConstraints = false
        guard let node else { return pane }

        let contentView: NSView
        if let b64 = node.props["thumb"]?.stringValue,
           let data = Data(base64Encoded: b64), let img = NSImage(data: data) {
            let iv = NSImageView(image: img)
            iv.imageScaling = .scaleProportionallyUpOrDown
            iv.imageAlignment = .alignTopLeft
            iv.heightAnchor.constraint(lessThanOrEqualToConstant: 220).isActive = true
            contentView = iv
        } else {
            let label = NSTextField(wrappingLabelWithString: node.props["detailText"]?.stringValue ?? (node.title ?? ""))
            label.font = .systemFont(ofSize: 13)
            label.textColor = .labelColor
            label.isSelectable = true
            label.maximumNumberOfLines = 12
            contentView = label
        }
        contentView.translatesAutoresizingMaskIntoConstraints = false
        pane.addSubview(contentView)

        let info = NSStackView()
        info.orientation = .vertical
        info.alignment = .width // rows fill the pane width so values right-align
        info.distribution = .fill
        info.spacing = 7
        info.translatesAutoresizingMaskIntoConstraints = false
        let header = NSTextField(labelWithString: "Information")
        header.font = .systemFont(ofSize: 11, weight: .semibold)
        header.textColor = .tertiaryLabelColor
        info.addArrangedSubview(header)
        if let md = node.props["metadata"], case .array(let mdRows) = md {
            for r in mdRows {
                guard case .object(let o) = r, let label = o["label"]?.stringValue, let value = o["value"]?.stringValue else { continue }
                info.addArrangedSubview(metadataRow(label: label, value: value))
            }
        }
        pane.addSubview(info)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: pane.topAnchor, constant: 8),
            contentView.leadingAnchor.constraint(equalTo: pane.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: pane.trailingAnchor, constant: -16),
            info.leadingAnchor.constraint(equalTo: pane.leadingAnchor, constant: 16),
            info.trailingAnchor.constraint(equalTo: pane.trailingAnchor, constant: -16),
            info.bottomAnchor.constraint(equalTo: pane.bottomAnchor, constant: -14),
        ])
        return pane
    }

    private func metadataRow(label: String, value: String) -> NSView {
        let l = NSTextField(labelWithString: label)
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabelColor
        l.translatesAutoresizingMaskIntoConstraints = false
        let v = NSTextField(labelWithString: value)
        v.font = .systemFont(ofSize: 12)
        v.textColor = .labelColor
        v.alignment = .right
        v.lineBreakMode = .byTruncatingTail
        v.translatesAutoresizingMaskIntoConstraints = false
        let row = NSView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(l)
        row.addSubview(v)
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 18),
            l.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            l.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            v.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            v.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            v.leadingAnchor.constraint(greaterThanOrEqualTo: l.trailingAnchor, constant: 12),
        ])
        return row
    }

    private func appendRows(for node: ViewNode, selectedIndex: Int) {
        switch node.type {
        case "list-section":
            if let title = node.title, !title.isEmpty { addSectionHeader(title) }
            for child in node.children { appendRows(for: child, selectedIndex: selectedIndex) }
        case "list-item":
            let selected = (itemCounter == selectedIndex)
            itemCounter += 1
            if let cardVal = node.props["card"], case .object(let card) = cardVal,
               node.props["display"]?.stringValue == "card" {
                addCard(card)
            } else {
                addItemRow(node, selected: selected)
            }
            // an item is a visual leaf — its ActionPanel children are not rows
        default:
            for child in node.children { appendRows(for: child, selectedIndex: selectedIndex) }
        }
    }

    // MARK: - Section header

    private func addSectionHeader(_ title: String) {
        let label = NSTextField(labelWithString: title)
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabelColor
        let row = NSView()
        row.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(label)
        stack.addArrangedSubview(row)
        NSLayoutConstraint.activate([
            row.widthAnchor.constraint(equalTo: stack.widthAnchor),
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 10),
            label.topAnchor.constraint(equalTo: row.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -8), // breathing room before the list
        ])
    }

    // MARK: - Result card

    private func addCard(_ card: [String: JSONValue]) {
        let left = card["left"]?.stringValue ?? ""
        let right = card["right"]?.stringValue ?? ""
        let leftLabel = card["leftLabel"]?.stringValue ?? ""
        let rightLabel = card["rightLabel"]?.stringValue ?? ""
        let note = card["note"]?.stringValue ?? ""

        let cardView = NSView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.wantsLayer = true
        cardView.layer?.cornerRadius = 12
        cardView.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.06).cgColor

        let leftCol = valueColumn(value: left, label: leftLabel)
        let rightCol = valueColumn(value: right, label: rightLabel)
        let centerCol = centerColumn(note: note)

        let h = NSStackView()
        h.orientation = .horizontal
        h.alignment = .centerY
        h.distribution = .fill
        h.spacing = 12
        h.translatesAutoresizingMaskIntoConstraints = false
        h.addArrangedSubview(leftCol)
        h.addArrangedSubview(centerCol)
        h.addArrangedSubview(rightCol)
        cardView.addSubview(h)

        stack.addArrangedSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.widthAnchor.constraint(equalTo: stack.widthAnchor),
            h.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            h.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            h.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            h.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
            leftCol.widthAnchor.constraint(equalTo: rightCol.widthAnchor),
        ])
    }

    private func valueColumn(value: String, label: String) -> NSView {
        let v = NSTextField(labelWithString: value)
        v.font = .systemFont(ofSize: 28, weight: .medium)
        v.alignment = .center
        v.lineBreakMode = .byTruncatingTail
        v.maximumNumberOfLines = 1
        let col = NSStackView()
        col.orientation = .vertical
        col.alignment = .centerX
        col.spacing = 12
        col.translatesAutoresizingMaskIntoConstraints = false
        col.addArrangedSubview(v)
        if !label.isEmpty { col.addArrangedSubview(chip(label)) }
        return col
    }

    private func centerColumn(note: String) -> NSView {
        let arrow = NSTextField(labelWithString: "→")
        arrow.font = .systemFont(ofSize: 20, weight: .regular)
        arrow.textColor = .secondaryLabelColor
        let col = NSStackView()
        col.orientation = .vertical
        col.alignment = .centerX
        col.spacing = 4
        col.translatesAutoresizingMaskIntoConstraints = false
        col.addArrangedSubview(arrow)
        if !note.isEmpty {
            let n = NSTextField(labelWithString: note)
            n.font = .systemFont(ofSize: 10, weight: .regular)
            n.textColor = .tertiaryLabelColor
            col.addArrangedSubview(n)
        }
        col.setContentHuggingPriority(.required, for: .horizontal)
        return col
    }

    // MARK: - Item row

    private func addItemRow(_ node: ViewNode, selected: Bool) {
        let row = NSView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.wantsLayer = true
        row.layer?.cornerRadius = 7
        // Subtle translucent highlight (not saturated accent), text colors unchanged — matches the
        // Raycast row selection.
        row.layer?.backgroundColor = selected ? NSColor.white.withAlphaComponent(0.13).cgColor : NSColor.clear.cgColor

        let h = NSStackView()
        h.orientation = .horizontal
        h.alignment = .centerY
        h.spacing = 8
        h.translatesAutoresizingMaskIntoConstraints = false

        if let icon = iconView(for: node, selected: selected) { h.addArrangedSubview(icon) }

        let title = NSTextField(labelWithString: node.title ?? "")
        title.font = .systemFont(ofSize: 14)
        title.textColor = .labelColor
        title.lineBreakMode = .byTruncatingTail
        title.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        h.addArrangedSubview(title)

        if let sub = node.props["subtitle"]?.stringValue, !sub.isEmpty {
            let s = NSTextField(labelWithString: sub)
            s.font = .systemFont(ofSize: 13)
            s.textColor = .secondaryLabelColor
            s.lineBreakMode = .byTruncatingTail
            h.addArrangedSubview(s)
        }

        let spacer = NSView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.init(1), for: .horizontal)
        h.addArrangedSubview(spacer)

        // Accessories: { text } → plain right-aligned type label (Raycast style); { tag } → chip.
        for acc in accessories(node) {
            switch acc {
            case .text(let t):
                let l = NSTextField(labelWithString: t)
                l.font = .systemFont(ofSize: 13)
                l.textColor = .tertiaryLabelColor
                h.addArrangedSubview(l)
            case .tag(let t):
                h.addArrangedSubview(chip(t))
            }
        }

        row.addSubview(h)
        stack.addArrangedSubview(row)
        NSLayoutConstraint.activate([
            row.widthAnchor.constraint(equalTo: stack.widthAnchor),
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 38),
            h.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 10),
            h.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -10),
            h.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
    }

    // MARK: - Helpers

    private func chip(_ text: String) -> NSView {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = .secondaryLabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        let bg = NSView()
        bg.wantsLayer = true
        bg.layer?.cornerRadius = 6
        bg.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.09).cgColor
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        bg.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: bg.topAnchor, constant: 3),
            label.bottomAnchor.constraint(equalTo: bg.bottomAnchor, constant: -3),
        ])
        return bg
    }

    private enum Accessory { case text(String); case tag(String) }

    private func accessories(_ node: ViewNode) -> [Accessory] {
        guard let acc = node.props["accessories"], case .array(let arr) = acc else { return [] }
        var out: [Accessory] = []
        for item in arr {
            guard case .object(let o) = item else { continue }
            if let tag = o["tag"]?.stringValue { out.append(.tag(tag)) }
            else if let text = o["text"]?.stringValue { out.append(.text(text)) }
        }
        return out
    }

    private func iconView(for node: ViewNode, selected: Bool) -> NSImageView? {
        // Real app/file icon (full color) for application and file rows.
        if let path = node.props["appPath"]?.stringValue ?? node.props["fileIcon"]?.stringValue {
            let iv = NSImageView(image: NSWorkspace.shared.icon(forFile: path))
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.widthAnchor.constraint(equalToConstant: 20).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 20).isActive = true
            return iv
        }
        // Otherwise a tinted SF Symbol: try the name directly (e.g. "house"), else map the Icon enum.
        guard let name = node.props["icon"]?.stringValue,
              let img = NSImage(systemSymbolName: name, accessibilityDescription: nil)
                ?? NSImage(systemSymbolName: sfSymbol(for: name), accessibilityDescription: nil) else { return nil }
        let iv = NSImageView(image: img)
        iv.contentTintColor = selected ? .white : .secondaryLabelColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.widthAnchor.constraint(equalToConstant: 16).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 16).isActive = true
        return iv
    }

    private func sfSymbol(for icon: String) -> String {
        switch icon {
        case "circle": return "circle.fill"
        case "star": return "star.fill"
        case "clipboard": return "doc.on.clipboard"
        case "globe": return "globe"
        case "window": return "macwindow"
        case "calendar": return "calendar"
        case "magnifying-glass": return "magnifyingglass"
        default: return "app"
        }
    }
}
