import AppKit
import InvokeRenderer

/// The results list (PLAN.md §4.3/§6). A real implementation binds view models to a
/// virtualized custom AppKit list with sections, icons, accessories, and the bottom
/// action bar. This Phase 0 version renders the view-model tree into a stack of rows
/// so the mutation pipeline is visibly wired to AppKit.
public final class PaletteView: NSView {
    private let stack = NSStackView()

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 2
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

    /// Re-render rows from the current view-model tree.
    public func render(_ tree: ViewTree) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        appendRows(for: tree.root, depth: 0)
    }

    private func appendRows(for node: ViewNode, depth: Int) {
        if node.type == "list-item" || node.type == "list-section" {
            let label = NSTextField(labelWithString: String(repeating: "  ", count: depth) + (node.title ?? node.type))
            label.font = node.type == "list-section"
                ? NSFont.systemFont(ofSize: 11, weight: .semibold)
                : NSFont.systemFont(ofSize: 14)
            label.textColor = node.type == "list-section" ? .secondaryLabelColor : .labelColor
            stack.addArrangedSubview(label)
        }
        for child in node.children { appendRows(for: child, depth: depth + 1) }
    }
}
