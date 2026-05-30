import AppKit
import InvokeRenderer

/// The results list (PLAN.md §4.3/§6). A real implementation binds view models to a virtualized
/// custom AppKit list with icons, accessories, and the bottom action bar. This Phase-0 version
/// renders the view-model tree into a stack of rows — section headers + selectable item rows —
/// so the mutation pipeline and keyboard selection are visibly wired to AppKit.
public final class PaletteView: NSView {
    private let stack = NSStackView()
    private var itemCounter = 0

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
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
        appendRows(for: tree.root, depth: 0, selectedIndex: selectedIndex)
    }

    private func appendRows(for node: ViewNode, depth: Int, selectedIndex: Int) {
        switch node.type {
        case "list-section":
            let label = makeLabel((node.title ?? "").uppercased(),
                                  font: .systemFont(ofSize: 11, weight: .semibold),
                                  color: .secondaryLabelColor)
            addRow(label, selected: false)
        case "list-item":
            let selected = (itemCounter == selectedIndex)
            itemCounter += 1
            let title = node.title ?? ""
            let subtitle = node.props["subtitle"]?.stringValue
            let text = subtitle.map { "\(title)    \($0)" } ?? title
            let label = makeLabel(text,
                                  font: .systemFont(ofSize: 14),
                                  color: selected ? .white : .labelColor)
            addRow(label, selected: selected)
        default:
            break
        }
        for child in node.children { appendRows(for: child, depth: depth + 1, selectedIndex: selectedIndex) }
    }

    private func makeLabel(_ text: String, font: NSFont, color: NSColor) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = font
        label.textColor = color
        label.lineBreakMode = .byTruncatingTail
        return label
    }

    /// Wrap a label in a full-width, padded, optionally-highlighted row.
    private func addRow(_ label: NSTextField, selected: Bool) {
        let row = NSView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.wantsLayer = true
        row.layer?.cornerRadius = 6
        row.layer?.backgroundColor = selected ? NSColor.controlAccentColor.cgColor : NSColor.clear.cgColor

        label.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(label)
        stack.addArrangedSubview(row)
        NSLayoutConstraint.activate([
            row.widthAnchor.constraint(equalTo: stack.widthAnchor),
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(lessThanOrEqualTo: row.trailingAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: row.topAnchor, constant: 5),
            label.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -5),
        ])
    }
}
