import AppKit
import InvokeServices

// MARK: - WindowPreviewView

/// Draws a scale model of the main display's visible frame with a translucent accent
/// rectangle showing where the current placement would position the window.
private final class WindowPreviewView: NSView {
    var placement: WindowPlacement = .default { didSet { needsDisplay = true } }

    // Draw in a TOP-LEFT-origin, y-down coordinate space so it matches placementRect (AX coords).
    // Without this, a top-left placement would render at the bottom of the preview (y-axis inverted).
    override var isFlipped: Bool { true }

    // The representative size used for .auto dimensions (60% of preview bounds).
    private var autoSize: CGSize {
        CGSize(width: bounds.width * 0.6, height: bounds.height * 0.6)
    }

    override var intrinsicContentSize: NSSize { NSSize(width: 256, height: 160) }

    override func draw(_ dirtyRect: NSRect) {
        let b = bounds

        // Outer screen bezel.
        let bezelPath = NSBezierPath(roundedRect: b, xRadius: 6, yRadius: 6)
        NSColor.tertiaryLabelColor.withAlphaComponent(0.15).setFill()
        bezelPath.fill()
        NSColor.separatorColor.setStroke()
        bezelPath.lineWidth = 1
        bezelPath.stroke()

        // Inner "visible area" inset (mimics a menubar/dock).
        let inset: CGFloat = 4
        let inner = b.insetBy(dx: inset, dy: inset)
        let innerPath = NSBezierPath(roundedRect: inner, xRadius: 4, yRadius: 4)
        NSColor.windowBackgroundColor.withAlphaComponent(0.6).setFill()
        innerPath.fill()

        // Placement preview rect. We treat `inner` as the visibleAX rect and
        // use a representative window size so .auto shows something meaningful.
        let repSize: CGSize
        switch (placement.width, placement.height) {
        case (.auto, .auto):
            repSize = autoSize
        case (.points(let w), .auto):
            repSize = CGSize(width: min(CGFloat(w), inner.width * 0.9), height: inner.height * 0.6)
        case (.auto, .points(let h)):
            repSize = CGSize(width: inner.width * 0.6, height: min(CGFloat(h), inner.height * 0.9))
        case (.points(let w), .points(let h)):
            repSize = CGSize(width: min(CGFloat(w), inner.width * 0.95), height: min(CGFloat(h), inner.height * 0.95))
        }

        // placementRect returns AX (top-left, y-down) coordinates. This view is `isFlipped` (also y-down,
        // top-left origin), so the result maps directly — a top-left placement draws at the top.
        let pr = WindowEnumerator.placementRect(placement, currentSize: repSize, visibleAX: inner)

        // Clamp the rect to fit within inner.
        let clampedX = max(inner.minX, min(pr.minX, inner.maxX - pr.width))
        let clampedY = max(inner.minY, min(pr.minY, inner.maxY - pr.height))
        let clampedW = min(pr.width, inner.width)
        let clampedH = min(pr.height, inner.height)
        let previewRect = CGRect(x: clampedX, y: clampedY, width: clampedW, height: clampedH)

        let rectPath = NSBezierPath(roundedRect: previewRect, xRadius: 3, yRadius: 3)
        NSColor.controlAccentColor.withAlphaComponent(0.45).setFill()
        rectPath.fill()
        NSColor.controlAccentColor.withAlphaComponent(0.85).setStroke()
        rectPath.lineWidth = 1.5
        rectPath.stroke()
    }
}

// MARK: - AnchorButton

/// A square toggle-style button that lights up with controlAccentColor when selected.
private final class AnchorButton: NSButton {
    let anchorValue: Anchor
    var onSelect: ((Anchor) -> Void)?

    init(anchor: Anchor) {
        self.anchorValue = anchor
        super.init(frame: .zero)
        tag = anchor.rawValue
        setButtonType(.toggle)
        bezelStyle = .regularSquare
        isBordered = true
        title = ""
        image = Self.image(for: anchor)
        imageScaling = .scaleProportionallyDown
        target = self
        action = #selector(tapped)
    }

    required init?(coder: NSCoder) { fatalError() }

    private static func image(for anchor: Anchor) -> NSImage? {
        // Use SF Symbol variants for each anchor position.
        let symbolName: String
        switch anchor {
        case .topLeft:     symbolName = "arrow.up.left.square"
        case .top:         symbolName = "arrow.up.square"
        case .topRight:    symbolName = "arrow.up.right.square"
        case .left:        symbolName = "arrow.left.square"
        case .center:      symbolName = "square.center.inset.filled"
        case .right:       symbolName = "arrow.right.square"
        case .bottomLeft:  symbolName = "arrow.down.left.square"
        case .bottom:      symbolName = "arrow.down.square"
        case .bottomRight: symbolName = "arrow.down.right.square"
        }
        let cfg = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        return NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?
            .withSymbolConfiguration(cfg)
    }

    var isSelected: Bool = false {
        didSet {
            state = isSelected ? .on : .off
            contentTintColor = isSelected ? .controlAccentColor : .secondaryLabelColor
            needsDisplay = true
        }
    }

    @objc private func tapped() {
        onSelect?(anchorValue)
    }
}

// MARK: - WindowPositionEditor

/// A Raycast-style placement editor: live screen preview (top), 3×3 nine-anchor grid,
/// Size W/H (Auto or points), and Offset X/Y (points). Interchanges state as a
/// serialized `"anchor;w;h;offX;offY"` string compatible with `WindowEnumerator`.
public final class WindowPositionEditor: NSView {

    // MARK: Public interface

    /// Called whenever any control changes; provides the new serialized placement string.
    public var onChange: ((String) -> Void)?

    /// Get or set the placement as an `"anchor;w;h;offX;offY"` interchange string.
    public var placementString: String {
        get { WindowEnumerator.serializePlacement(currentPlacement) }
        set {
            let p = WindowEnumerator.parsePlacement(newValue) ?? .default
            applyPlacementToControls(p)
        }
    }

    // MARK: State

    private var anchor: Anchor = .center
    private var widthSizing: Sizing = .auto
    private var heightSizing: Sizing = .auto
    private var offsetX: Double = 0
    private var offsetY: Double = 0

    private var currentPlacement: WindowPlacement {
        WindowPlacement(anchor: anchor, width: widthSizing, height: heightSizing,
                        offsetX: offsetX, offsetY: offsetY)
    }

    // MARK: Subviews

    private let previewView = WindowPreviewView()
    private var anchorButtons: [AnchorButton] = []
    private let widthField = NSTextField()
    private let heightField = NSTextField()
    private let offsetXField = NSTextField()
    private let offsetYField = NSTextField()

    // MARK: Init

    public override init(frame: NSRect) {
        super.init(frame: frame)
        buildUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }

    // MARK: UI Construction

    private func buildUI() {
        translatesAutoresizingMaskIntoConstraints = false

        let outer = NSStackView()
        outer.orientation = .vertical
        outer.alignment = .leading
        outer.spacing = 12
        outer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(outer)
        NSLayoutConstraint.activate([
            outer.topAnchor.constraint(equalTo: topAnchor),
            outer.leadingAnchor.constraint(equalTo: leadingAnchor),
            outer.trailingAnchor.constraint(equalTo: trailingAnchor),
            outer.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        // ── Preview ──────────────────────────────────────────────────────────
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        outer.addArrangedSubview(previewView)
        NSLayoutConstraint.activate([
            previewView.widthAnchor.constraint(equalTo: outer.widthAnchor),
            previewView.heightAnchor.constraint(equalToConstant: 160),
        ])

        // ── Position section label ────────────────────────────────────────────
        outer.addArrangedSubview(makeSectionLabel("Position"))

        // ── 9-anchor grid ────────────────────────────────────────────────────
        let grid = NSStackView()
        grid.orientation = .vertical
        grid.spacing = 3
        grid.translatesAutoresizingMaskIntoConstraints = false

        for row in 0..<3 {
            let rowStack = NSStackView()
            rowStack.orientation = .horizontal
            rowStack.spacing = 3
            for col in 0..<3 {
                let rawValue = row * 3 + col
                guard let anch = Anchor(rawValue: rawValue) else { continue }
                let btn = AnchorButton(anchor: anch)
                btn.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    btn.widthAnchor.constraint(equalToConstant: 34),
                    btn.heightAnchor.constraint(equalToConstant: 34),
                ])
                btn.onSelect = { [weak self] selected in
                    self?.anchor = selected
                    self?.refreshAnchorSelection()
                    self?.notifyChange()
                }
                anchorButtons.append(btn)
                rowStack.addArrangedSubview(btn)
            }
            rowStack.translatesAutoresizingMaskIntoConstraints = false
            grid.addArrangedSubview(rowStack)
        }
        outer.addArrangedSubview(grid)

        // ── Size section ─────────────────────────────────────────────────────
        outer.addArrangedSubview(makeSectionLabel("Size"))
        let sizeRow = NSStackView()
        sizeRow.orientation = .horizontal
        sizeRow.spacing = 8
        sizeRow.translatesAutoresizingMaskIntoConstraints = false

        sizeRow.addArrangedSubview(makeLabel("W:"))
        configureField(widthField, placeholder: "Auto")
        widthField.delegate = self
        sizeRow.addArrangedSubview(widthField)
        sizeRow.addArrangedSubview(makeLabel("pt"))

        sizeRow.addArrangedSubview(makeLabel("H:"))
        configureField(heightField, placeholder: "Auto")
        heightField.delegate = self
        sizeRow.addArrangedSubview(heightField)
        sizeRow.addArrangedSubview(makeLabel("pt"))

        outer.addArrangedSubview(sizeRow)

        // ── Offset section ───────────────────────────────────────────────────
        outer.addArrangedSubview(makeSectionLabel("Offset"))
        let offsetRow = NSStackView()
        offsetRow.orientation = .horizontal
        offsetRow.spacing = 8
        offsetRow.translatesAutoresizingMaskIntoConstraints = false

        offsetRow.addArrangedSubview(makeLabel("X:"))
        configureField(offsetXField, placeholder: "0")
        offsetXField.delegate = self
        offsetRow.addArrangedSubview(offsetXField)
        offsetRow.addArrangedSubview(makeLabel("pt"))

        offsetRow.addArrangedSubview(makeLabel("Y:"))
        configureField(offsetYField, placeholder: "0")
        offsetYField.delegate = self
        offsetRow.addArrangedSubview(offsetYField)
        offsetRow.addArrangedSubview(makeLabel("pt"))

        outer.addArrangedSubview(offsetRow)

        // Seed defaults.
        applyPlacementToControls(.default)
    }

    // MARK: Helpers

    private func makeSectionLabel(_ text: String) -> NSTextField {
        let lbl = NSTextField(labelWithString: text)
        lbl.font = .systemFont(ofSize: 11, weight: .semibold)
        lbl.textColor = .secondaryLabelColor
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }

    private func makeLabel(_ text: String) -> NSTextField {
        let lbl = NSTextField(labelWithString: text)
        lbl.font = .systemFont(ofSize: 13)
        lbl.textColor = .labelColor
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }

    private func configureField(_ field: NSTextField, placeholder: String) {
        field.placeholderString = placeholder
        field.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        field.bezelStyle = .roundedBezel
        field.isBordered = true
        field.isEditable = true
        field.isSelectable = true
        field.translatesAutoresizingMaskIntoConstraints = false
        field.widthAnchor.constraint(equalToConstant: 72).isActive = true
    }

    // MARK: State ↔ Controls

    private func applyPlacementToControls(_ p: WindowPlacement) {
        anchor = p.anchor
        widthSizing = p.width
        heightSizing = p.height
        offsetX = p.offsetX
        offsetY = p.offsetY

        refreshAnchorSelection()

        widthField.stringValue = sizingText(p.width)
        heightField.stringValue = sizingText(p.height)
        offsetXField.stringValue = p.offsetX == 0 ? "" : String(p.offsetX)
        offsetYField.stringValue = p.offsetY == 0 ? "" : String(p.offsetY)

        previewView.placement = p
    }

    private func sizingText(_ s: Sizing) -> String {
        if case .points(let v) = s { return String(v) }
        return ""  // empty shows the "Auto" placeholder
    }

    private func refreshAnchorSelection() {
        for btn in anchorButtons {
            btn.isSelected = (btn.anchorValue == anchor)
        }
    }

    private func notifyChange() {
        let p = currentPlacement
        previewView.placement = p
        onChange?(WindowEnumerator.serializePlacement(p))
    }

    private func parseSizing(_ text: String) -> Sizing {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty || trimmed.lowercased() == "auto" { return .auto }
        if let v = Double(trimmed) { return .points(v) }
        return .auto
    }
}

// MARK: - NSTextFieldDelegate

extension WindowPositionEditor: NSTextFieldDelegate {
    public func controlTextDidChange(_ obj: Notification) {
        guard let tf = obj.object as? NSTextField else { return }
        readFieldChanges(from: tf)
        notifyChange()
    }

    public func controlTextDidEndEditing(_ obj: Notification) {
        guard let tf = obj.object as? NSTextField else { return }
        readFieldChanges(from: tf)
        notifyChange()
    }

    private func readFieldChanges(from tf: NSTextField) {
        switch tf {
        case widthField:  widthSizing  = parseSizing(tf.stringValue)
        case heightField: heightSizing = parseSizing(tf.stringValue)
        case offsetXField: offsetX = Double(tf.stringValue.trimmingCharacters(in: .whitespaces)) ?? 0
        case offsetYField: offsetY = Double(tf.stringValue.trimmingCharacters(in: .whitespaces)) ?? 0
        default: break
        }
    }
}
