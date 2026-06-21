import AppKit

/// A 2px indeterminate loading bar: a faint track with an accent highlight that sweeps left→right on
/// repeat — Raycast's thin loading affordance, NOT the system barber-pole NSProgressIndicator.
final class LoadingBar: NSView {
    private let highlight = CAGradientLayer()
    private var animating = false

    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        layer?.backgroundColor = NSColor.white.withAlphaComponent(0.06).cgColor
        let accent = NSColor.controlAccentColor
        highlight.colors = [accent.withAlphaComponent(0).cgColor,
                            accent.withAlphaComponent(0.9).cgColor,
                            accent.withAlphaComponent(0).cgColor]
        highlight.startPoint = CGPoint(x: 0, y: 0.5)
        highlight.endPoint = CGPoint(x: 1, y: 0.5)
        layer?.addSublayer(highlight)
        isHidden = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    override func layout() {
        super.layout()
        highlight.frame = CGRect(x: 0, y: 0, width: max(bounds.width / 3, 1), height: bounds.height)
    }

    func start() {
        guard !animating, bounds.width > 0 else { isHidden = false; animating = true; return }
        animating = true
        isHidden = false
        let w = bounds.width
        let anim = CABasicAnimation(keyPath: "position.x")
        anim.fromValue = -w / 3
        anim.toValue = w + w / 3
        anim.duration = 1.1
        anim.repeatCount = .infinity
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        highlight.add(anim, forKey: "sweep")
    }
    func stop() {
        guard animating else { return }
        animating = false
        highlight.removeAnimation(forKey: "sweep")
        isHidden = true
    }
}
