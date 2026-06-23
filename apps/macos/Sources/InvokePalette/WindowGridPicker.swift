import AppKit

/// A 12×8 drag-select grid for defining a custom window region (WM-3). Reports the selected region as
/// top-left-origin fractions (fx,fy,fw,fh) of the screen. World-class: live highlight while dragging.
public final class WindowGridPicker: NSView {
    public static let cols = 12, rows = 8
    public var onChange: ((Double, Double, Double, Double) -> Void)?
    public private(set) var fractions: (Double, Double, Double, Double)?
    private var anchor: (c: Int, r: Int)?
    private var current: (c: Int, r: Int)?

    /// Pure mapping: a drag from (c0,r0) to (c1,r1) on a cols×rows grid → top-left fractions (normalized, clamped).
    public static func gridSelectionToFractions(c0: Int, r0: Int, c1: Int, r1: Int, cols: Int, rows: Int) -> (fx: Double, fy: Double, fw: Double, fh: Double) {
        let minC = max(0, min(c0, c1)), maxC = min(cols - 1, max(c0, c1))
        let minR = max(0, min(r0, r1)), maxR = min(rows - 1, max(r0, r1))
        return (Double(minC) / Double(cols), Double(minR) / Double(rows),
                Double(maxC - minC + 1) / Double(cols), Double(maxR - minR + 1) / Double(rows))
    }

    public override var intrinsicContentSize: NSSize { NSSize(width: 360, height: 240) }
    public override var acceptsFirstResponder: Bool { true }

    private func cell(at p: NSPoint) -> (c: Int, r: Int) {
        let cw = bounds.width / CGFloat(Self.cols), ch = bounds.height / CGFloat(Self.rows)
        let c = max(0, min(Self.cols - 1, Int(p.x / cw)))
        // view is y-up; row 0 must be the TOP → invert
        let rTop = max(0, min(Self.rows - 1, Int((bounds.height - p.y) / ch)))
        return (c, rTop)
    }
    public override func mouseDown(with e: NSEvent) { anchor = cell(at: convert(e.locationInWindow, from: nil)); current = anchor; commit(); needsDisplay = true }
    public override func mouseDragged(with e: NSEvent) { current = cell(at: convert(e.locationInWindow, from: nil)); commit(); needsDisplay = true }
    public override func mouseUp(with e: NSEvent) { current = cell(at: convert(e.locationInWindow, from: nil)); commit(); needsDisplay = true }

    private func commit() {
        guard let a = anchor, let c = current else { return }
        let f = Self.gridSelectionToFractions(c0: a.c, r0: a.r, c1: c.c, r1: c.r, cols: Self.cols, rows: Self.rows)
        fractions = (f.fx, f.fy, f.fw, f.fh)
        onChange?(f.fx, f.fy, f.fw, f.fh)
    }

    /// Pre-select a region from cell coordinates (used by formApply to seed the picker from a saved value).
    public func setSelection(c0: Int, r0: Int, c1: Int, r1: Int) {
        anchor = (min(c0, c1), min(r0, r1))
        current = (max(c0, c1), max(r0, r1))
        commit()
        needsDisplay = true
    }

    public override func draw(_ dirty: NSRect) {
        let cw = bounds.width / CGFloat(Self.cols), ch = bounds.height / CGFloat(Self.rows)
        NSColor.gridColor.setStroke()
        for c in 0...Self.cols { let x = CGFloat(c) * cw; let p = NSBezierPath(); p.move(to: NSPoint(x: x, y: 0)); p.line(to: NSPoint(x: x, y: bounds.height)); p.lineWidth = 0.5; p.stroke() }
        for r in 0...Self.rows { let y = CGFloat(r) * ch; let p = NSBezierPath(); p.move(to: NSPoint(x: 0, y: y)); p.line(to: NSPoint(x: bounds.width, y: y)); p.lineWidth = 0.5; p.stroke() }
        if let a = anchor, let c = current {
            let minC = min(a.c, c.c), maxC = max(a.c, c.c), minR = min(a.r, c.r), maxR = max(a.r, c.r)
            let x = CGFloat(minC) * cw
            let yTop = bounds.height - CGFloat(maxR + 1) * ch // y-up
            let rect = NSRect(x: x, y: yTop, width: CGFloat(maxC - minC + 1) * cw, height: CGFloat(maxR - minR + 1) * ch)
            NSColor.controlAccentColor.withAlphaComponent(0.35).setFill(); rect.fill()
            NSColor.controlAccentColor.setStroke(); let b = NSBezierPath(rect: rect); b.lineWidth = 1.5; b.stroke()
        }
    }
}
