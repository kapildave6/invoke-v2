import AppKit

/// A view that runs a closure on click (used to make a Detail.Metadata tag chip actionable).
final class ClickableContainer: NSView {
    var onClick: (() -> Void)?
    override func mouseUp(with event: NSEvent) { onClick?() }
    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
}

/// A simple wrapping flow layout (Raycast TagList wraps tags to multiple rows on overflow). Children are
/// frame-laid (not autolayout) inside this view; height is reported via intrinsicContentSize so the
/// enclosing autolayout row sizes to the wrapped content. The view itself must be given a definite width.
final class FlowStackView: NSView {
    var hSpacing: CGFloat = 4
    var vSpacing: CGFloat = 4
    private var chips: [NSView] = []
    private var computedHeight: CGFloat = 0

    override var isFlipped: Bool { true }

    func setChips(_ views: [NSView]) {
        chips.forEach { $0.removeFromSuperview() }
        chips = views
        for v in views { v.translatesAutoresizingMaskIntoConstraints = true; addSubview(v) }
        needsLayout = true
        invalidateIntrinsicContentSize()
    }

    override func layout() {
        super.layout()
        let maxW = bounds.width
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0
        for v in chips {
            let s = v.fittingSize
            if x > 0 && x + s.width > maxW { x = 0; y += rowH + vSpacing; rowH = 0 }
            v.frame = NSRect(x: x, y: y, width: s.width, height: s.height)
            x += s.width + hSpacing
            rowH = max(rowH, s.height)
        }
        let h = y + rowH
        if abs(h - computedHeight) > 0.5 { computedHeight = h; invalidateIntrinsicContentSize() }
    }

    override var intrinsicContentSize: NSSize { NSSize(width: NSView.noIntrinsicMetric, height: computedHeight) }
}
