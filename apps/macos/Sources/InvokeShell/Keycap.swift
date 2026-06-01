import AppKit

/// A single keyboard-key chip (e.g. "⌘", "↵", "K") rendered like Raycast's shortcut keycaps: a small
/// rounded translucent box with a centered glyph. Draws its background in `updateLayer()` so it tracks
/// Light/Dark appearance changes at runtime (the palette follows the system appearance).
final class KeycapView: NSView {
    private let label = NSTextField(labelWithString: "")
    private let fontSize: CGFloat

    init(glyph: String, fontSize: CGFloat = 11) {
        self.fontSize = fontSize
        super.init(frame: .zero)
        wantsLayer = true
        layer?.cornerRadius = 4
        translatesAutoresizingMaskIntoConstraints = false
        label.stringValue = glyph
        label.font = .systemFont(ofSize: fontSize, weight: .medium)
        label.textColor = .secondaryLabelColor
        label.alignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        // A plain NSView has NO intrinsic size, so content-hugging would be a no-op and an enclosing
        // `.fill` stack would stretch the chip. Provide a real intrinsicContentSize (below) + required
        // hugging so the chip hugs its glyph and the stack can't stretch or spread it.
        setContentHuggingPriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .vertical)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var intrinsicContentSize: NSSize {
        let side = fontSize + 7
        return NSSize(width: max(side, label.intrinsicContentSize.width + 10), height: side)
    }

    override var wantsUpdateLayer: Bool { true }
    override func updateLayer() {
        // Resolve the dynamic color against the current effective appearance → adapts on toggle.
        layer?.backgroundColor = NSColor.quaternaryLabelColor.withAlphaComponent(0.55).cgColor
    }
}

enum Keycap {
    /// Split a shortcut string ("⌘↵", "⇧⌘F") into one chip per glyph, the way Raycast renders keys.
    static func chips(for shortcut: String, fontSize: CGFloat = 11) -> [KeycapView] {
        shortcut.map { KeycapView(glyph: String($0), fontSize: fontSize) }
    }
}
