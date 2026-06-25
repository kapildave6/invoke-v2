import AppKit
#if canImport(InvokeServices)
import InvokeServices
#endif

// MARK: - Shared Designer Types (Task 1 owns; later tasks import)

public struct DesignerItem {
    public var bundleId: String
    public var appName: String
    public var appPath: String?
    public var placement: WindowPlacement

    public init(bundleId: String, appName: String, appPath: String?, placement: WindowPlacement) {
        self.bundleId = bundleId
        self.appName = appName
        self.appPath = appPath
        self.placement = placement
    }
}

public enum DesignerMode { case layout; case singleWindow }

// MARK: - LayoutPreviewView

/// Live multi-window desktop preview. y-down (isFlipped = true) so AX coords map directly.
public final class LayoutPreviewView: NSView {

    // MARK: Public API
    public var items: [DesignerItem] = [] { didSet { needsDisplay = true } }
    public var selected: Int = 0        { didSet { needsDisplay = true } }
    public var onSelect: ((Int) -> Void)?
    public var onAdd: (() -> Void)?

    // MARK: Init
    public override init(frame: NSRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: Flipped (AX y-down)
    public override var isFlipped: Bool { true }

    // MARK: - Pure static: scaledRect (unit-tested)
    /// Maps an AX rect in `fromVisible` space into `toPreview` space (proportional translation + scale).
    public static func scaledRect(_ ax: CGRect, fromVisible: CGRect, toPreview: CGRect) -> CGRect {
        let x = toPreview.minX + (ax.minX - fromVisible.minX) / fromVisible.width  * toPreview.width
        let y = toPreview.minY + (ax.minY - fromVisible.minY) / fromVisible.height * toPreview.height
        let w = ax.width  / fromVisible.width  * toPreview.width
        let h = ax.height / fromVisible.height * toPreview.height
        return CGRect(x: x, y: y, width: w, height: h)
    }

    // MARK: - Private helpers

    private var addButton: NSButton!

    private func setup() {
        wantsLayer = true
        addButton = NSButton(title: "＋ Add", target: self, action: #selector(addTapped))
        addButton.bezelStyle = .rounded
        addButton.isBordered = true
        addButton.controlSize = .regular
        addSubview(addButton)
    }

    @objc private func addTapped() { onAdd?() }

    // Bezel rect for the desktop chrome, sized to the main screen aspect ratio.
    private func bezelRect(in bounds: NSRect) -> NSRect {
        let screenFrame = NSScreen.main?.frame ?? CGRect(x: 0, y: 0, width: 1440, height: 900)
        let aspectW = screenFrame.width
        let aspectH = screenFrame.height
        let aspect = aspectW / aspectH

        // Leave room for the Add button above and a caption below.
        let topInset: CGFloat = 36
        let bottomInset: CGFloat = 22
        let sideInset: CGFloat = 16
        let availW = bounds.width  - sideInset * 2
        let availH = bounds.height - topInset - bottomInset
        var bW = availW
        var bH = bW / aspect
        if bH > availH { bH = availH; bW = bH * aspect }
        let bX = bounds.midX - bW / 2
        let bY = topInset
        return NSRect(x: bX, y: bY, width: bW, height: bH)
    }

    // The inner rect of the bezel (bezel minus the thin chrome border).
    private func innerRect(of bezel: NSRect) -> NSRect {
        let bezelSize: CGFloat = 3
        return NSRect(
            x: bezel.minX + bezelSize,
            y: bezel.minY + bezelSize,
            width: bezel.width  - bezelSize * 2,
            height: bezel.height - bezelSize * 2
        )
    }

    // Representative size for `.auto` sizing — 55% × 55% of the preview inner rect.
    private func repSize(for inner: NSRect) -> CGSize {
        CGSize(width: inner.width * 0.55, height: inner.height * 0.55)
    }

    // Rect for item i in preview coords.
    private func previewRect(for item: DesignerItem, previewInner: NSRect) -> NSRect {
        let rep = repSize(for: previewInner)
        return WindowEnumerator.placementRect(item.placement, currentSize: rep, visibleAX: previewInner)
    }

    // App icon for a DesignerItem.
    private func icon(for item: DesignerItem) -> NSImage {
        if let path = item.appPath {
            return NSWorkspace.shared.icon(forFile: path)
        }
        return NSImage(named: NSImage.applicationIconName) ?? NSImage()
    }

    // MARK: - Layout (position the Add button)
    public override func layout() {
        super.layout()
        let bezel = bezelRect(in: bounds)
        let btnSize = NSSize(width: 100, height: 26)
        let btnX = bounds.midX - btnSize.width / 2
        let btnY = max(2, bezel.minY - btnSize.height - 6)
        addButton.frame = NSRect(x: btnX, y: btnY, width: btnSize.width, height: btnSize.height)
    }

    // MARK: - Drawing
    public override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }

        // 1. Background
        NSColor.windowBackgroundColor.withAlphaComponent(0.0).setFill()
        dirtyRect.fill()

        let bezel = bezelRect(in: bounds)
        let inner = innerRect(of: bezel)

        // 2. Desktop bezel (rounded chrome border)
        let bezelPath = NSBezierPath(roundedRect: bezel, xRadius: 8, yRadius: 8)
        NSColor(white: 0.22, alpha: 1.0).setFill()
        bezelPath.fill()
        NSColor(white: 0.35, alpha: 1.0).setStroke()
        bezelPath.lineWidth = 1.0
        bezelPath.stroke()

        // 3. Desktop inner fill (subtle gradient, dark desktop-like)
        let innerPath = NSBezierPath(roundedRect: inner, xRadius: 2, yRadius: 2)
        ctx.saveGState()
        innerPath.addClip()

        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                NSColor(white: 0.14, alpha: 1.0).cgColor,
                NSColor(white: 0.10, alpha: 1.0).cgColor
            ] as CFArray,
            locations: [0.0, 1.0]
        )!
        ctx.drawLinearGradient(gradient,
                               start: CGPoint(x: inner.midX, y: inner.minY),
                               end:   CGPoint(x: inner.midX, y: inner.maxY),
                               options: [])
        ctx.restoreGState()

        // 4. Caption below bezel
        let screenFrame = NSScreen.main?.frame ?? CGRect(x: 0, y: 0, width: 1440, height: 900)
        let caption = "Built-in Retina Display · \(Int(screenFrame.width))×\(Int(screenFrame.height))"
        let captionAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: NSColor.secondaryLabelColor
        ]
        let captionStr = NSAttributedString(string: caption, attributes: captionAttrs)
        let captionSize = captionStr.size()
        let captionX = bezel.midX - captionSize.width / 2
        let captionY = bezel.maxY + 4
        captionStr.draw(at: NSPoint(x: captionX, y: captionY))

        // 5. Window rects: draw all non-selected first, selected last (on top)
        let indices = items.indices.filter { $0 != selected } + (items.indices.contains(selected) ? [selected] : [])
        for i in indices {
            drawWindowRect(for: items[i], index: i, previewInner: inner, ctx: ctx)
        }
    }

    private func drawWindowRect(for item: DesignerItem, index i: Int, previewInner: NSRect, ctx: CGContext) {
        let isSelected = (i == selected)
        let rect = previewRect(for: item, previewInner: previewInner)

        // Clamp to inner so items don't overflow the bezel
        let clipped = rect.intersection(previewInner)
        guard !clipped.isNull, clipped.width > 2, clipped.height > 2 else { return }

        ctx.saveGState()
        let clipPath = NSBezierPath(rect: previewInner)
        clipPath.addClip()

        // Window background
        let winPath = NSBezierPath(roundedRect: rect, xRadius: 4, yRadius: 4)
        if isSelected {
            NSColor.controlAccentColor.withAlphaComponent(0.4).setFill()
        } else {
            NSColor(white: 0.55, alpha: 0.50).setFill()
        }
        winPath.fill()

        // Window border
        if isSelected {
            NSColor.controlAccentColor.withAlphaComponent(0.9).setStroke()
            winPath.lineWidth = 1.5
        } else {
            NSColor(white: 0.7, alpha: 0.6).setStroke()
            winPath.lineWidth = 0.75
        }
        winPath.stroke()

        // Title bar area (top strip)
        let titleBarH: CGFloat = min(10, rect.height * 0.18)
        let titleBarRect = NSRect(x: rect.minX, y: rect.minY, width: rect.width, height: titleBarH)
        let titleBarPath = NSBezierPath(rect: titleBarRect)
        NSColor(white: isSelected ? 0.5 : 0.45, alpha: 0.35).setFill()
        titleBarPath.fill()

        // Three dots (•••) near top-left of the title bar
        let dotY = rect.minY + titleBarH / 2
        let dotRadius: CGFloat = min(1.6, titleBarH * 0.28)
        let dotColors: [NSColor] = [
            NSColor(red: 0.99, green: 0.37, blue: 0.33, alpha: 0.85),
            NSColor(red: 0.99, green: 0.73, blue: 0.23, alpha: 0.85),
            NSColor(red: 0.22, green: 0.80, blue: 0.44, alpha: 0.85)
        ]
        let dotSpacing: CGFloat = dotRadius * 2.8
        let dotsStartX = rect.minX + 4 + dotRadius
        for (d, color) in dotColors.enumerated() {
            let dx = dotsStartX + CGFloat(d) * dotSpacing
            if dx + dotRadius > rect.maxX - 2 { break }
            let dotRect = CGRect(x: dx - dotRadius, y: dotY - dotRadius, width: dotRadius * 2, height: dotRadius * 2)
            color.setFill()
            NSBezierPath(ovalIn: dotRect).fill()
        }

        // App icon centered (only if rect is large enough)
        let minSizeForIcon: CGFloat = 16
        if rect.width >= minSizeForIcon && rect.height >= minSizeForIcon {
            let appIcon = icon(for: item)
            let iconSize: CGFloat = min(rect.width * 0.45, rect.height * 0.45, 48)
            if iconSize >= 8 {
                let iconRect = NSRect(
                    x: rect.midX - iconSize / 2,
                    y: rect.midY - iconSize / 2 + titleBarH / 2,
                    width: iconSize,
                    height: iconSize
                )
                appIcon.draw(in: iconRect, from: .zero, operation: .sourceOver, fraction: isSelected ? 1.0 : 0.75)
            }
        }

        ctx.restoreGState()
    }

    // MARK: - Hit Testing
    public override func mouseDown(with event: NSEvent) {
        let localPoint = convert(event.locationInWindow, from: nil)
        let bezel = bezelRect(in: bounds)
        let inner = innerRect(of: bezel)

        // Hit-test in reverse order (top-most / selected-on-top first)
        let indices = (items.indices.contains(selected) ? [selected] : []) +
                      items.indices.filter { $0 != selected }.reversed()
        for i in indices {
            let rect = previewRect(for: items[i], previewInner: inner)
            if rect.contains(localPoint) {
                onSelect?(i)
                return
            }
        }
        super.mouseDown(with: event)
    }
}
