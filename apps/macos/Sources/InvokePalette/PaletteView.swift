import AppKit
import InvokeIPC
import InvokeRenderer

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

    /// Re-render rows from the current view-model tree, highlighting the item at `selectedIndex`
    /// (item indices are assigned in pre-order, matching the host's selection model).
    public func render(_ tree: ViewTree, selectedIndex: Int) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        itemCounter = 0
        appendRows(for: tree.root, selectedIndex: selectedIndex)
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
        let label = NSTextField(labelWithString: title.uppercased())
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .tertiaryLabelColor
        let row = NSView()
        row.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(label)
        stack.addArrangedSubview(row)
        NSLayoutConstraint.activate([
            row.widthAnchor.constraint(equalTo: stack.widthAnchor),
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 10),
            label.topAnchor.constraint(equalTo: row.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: 4),
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
        row.layer?.backgroundColor = selected ? NSColor.controlAccentColor.withAlphaComponent(0.9).cgColor : NSColor.clear.cgColor

        let h = NSStackView()
        h.orientation = .horizontal
        h.alignment = .centerY
        h.spacing = 8
        h.translatesAutoresizingMaskIntoConstraints = false

        if let icon = iconView(for: node, selected: selected) { h.addArrangedSubview(icon) }

        let title = NSTextField(labelWithString: node.title ?? "")
        title.font = .systemFont(ofSize: 14)
        title.textColor = selected ? .white : .labelColor
        title.lineBreakMode = .byTruncatingTail
        title.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        h.addArrangedSubview(title)

        if let sub = node.props["subtitle"]?.stringValue, !sub.isEmpty {
            let s = NSTextField(labelWithString: sub)
            s.font = .systemFont(ofSize: 13)
            s.textColor = selected ? NSColor.white.withAlphaComponent(0.75) : .secondaryLabelColor
            s.lineBreakMode = .byTruncatingTail
            h.addArrangedSubview(s)
        }

        let spacer = NSView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.init(1), for: .horizontal)
        h.addArrangedSubview(spacer)

        for text in accessoryTexts(node) { h.addArrangedSubview(chip(text)) }

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

    private func accessoryTexts(_ node: ViewNode) -> [String] {
        guard let acc = node.props["accessories"], case .array(let arr) = acc else { return [] }
        var out: [String] = []
        for item in arr {
            guard case .object(let o) = item else { continue }
            if let tag = o["tag"]?.stringValue { out.append(tag) }
            else if let text = o["text"]?.stringValue { out.append(text) }
        }
        return out
    }

    private func iconView(for node: ViewNode, selected: Bool) -> NSImageView? {
        guard let name = node.props["icon"]?.stringValue,
              let img = NSImage(systemSymbolName: sfSymbol(for: name), accessibilityDescription: nil) else { return nil }
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
