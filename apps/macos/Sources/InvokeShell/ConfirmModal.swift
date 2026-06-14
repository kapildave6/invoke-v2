import AppKit

/// A Raycast-style confirmation modal (confirmAlert): a dimmed backdrop + a centered rounded card with
/// title, message, and Cancel / primary buttons. Lives INSIDE the palette window (like ActionPanel) so
/// it doesn't steal key focus or trip auto-hide, and resolves asynchronously on the user's choice.
final class ConfirmModal: NSObject {
    private final class Backdrop: NSView {
        var onClick: (() -> Void)?
        override func mouseDown(with e: NSEvent) { onClick?() }
        override var isFlipped: Bool { true }
    }

    private let backdrop = Backdrop()
    private let card = NSVisualEffectView()
    private let titleLabel = NSTextField(labelWithString: "")
    private let messageLabel = NSTextField(labelWithString: "")
    private let cancelButton = NSButton(title: "Cancel", target: nil, action: nil)
    private let primaryButton = NSButton(title: "OK", target: nil, action: nil)
    private var onResult: ((Bool) -> Void)?

    var isShown: Bool { card.superview != nil }

    override init() {
        super.init()
        build()
    }

    private func build() {
        backdrop.translatesAutoresizingMaskIntoConstraints = false
        backdrop.wantsLayer = true
        backdrop.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.28).cgColor
        backdrop.onClick = { [weak self] in self?.resolve(false) } // click outside = cancel

        card.material = .menu
        card.blendingMode = .withinWindow
        card.state = .active
        card.wantsLayer = true
        card.layer?.cornerRadius = 12
        card.layer?.masksToBounds = true
        card.layer?.borderWidth = 1
        card.layer?.borderColor = NSColor.separatorColor.cgColor
        card.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.alignment = .center
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.font = .systemFont(ofSize: 12)
        messageLabel.textColor = .secondaryLabelColor
        messageLabel.alignment = .center
        messageLabel.maximumNumberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        for b in [cancelButton, primaryButton] {
            b.bezelStyle = .rounded
            b.controlSize = .large
            b.translatesAutoresizingMaskIntoConstraints = false
            b.target = self
        }
        cancelButton.action = #selector(cancelTapped)
        primaryButton.action = #selector(primaryTapped)

        let buttons = NSStackView(views: [cancelButton, primaryButton])
        buttons.orientation = .horizontal
        buttons.distribution = .fillEqually
        buttons.spacing = 12
        buttons.translatesAutoresizingMaskIntoConstraints = false

        let v = NSStackView(views: [titleLabel, messageLabel, buttons])
        v.orientation = .vertical
        v.alignment = .centerX
        v.spacing = 10
        v.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(v)
        NSLayoutConstraint.activate([
            card.widthAnchor.constraint(equalToConstant: 360),
            v.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            v.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),
            v.topAnchor.constraint(equalTo: card.topAnchor, constant: 22),
            v.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
            buttons.widthAnchor.constraint(equalTo: v.widthAnchor),
        ])
    }

    /// Present centered in `parent` (the palette content view); calls `then(true)` on the primary
    /// action, `then(false)` on cancel / click-outside / Esc. The primary button is styled red when
    /// destructive and bound to Return; Esc cancels (routed from the palette key monitor).
    func present(in parent: NSView, title: String, message: String?, primaryTitle: String,
                 destructive: Bool, dismissTitle: String, then: @escaping (Bool) -> Void) {
        onResult = then
        titleLabel.stringValue = title
        messageLabel.stringValue = message ?? ""
        messageLabel.isHidden = (message ?? "").isEmpty
        cancelButton.title = dismissTitle
        primaryButton.title = primaryTitle
        primaryButton.contentTintColor = destructive ? .systemRed : nil
        primaryButton.keyEquivalent = "\r" // default button → Return triggers it

        backdrop.removeFromSuperview(); card.removeFromSuperview()
        parent.addSubview(backdrop)
        parent.addSubview(card)
        NSLayoutConstraint.activate([
            backdrop.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            backdrop.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            backdrop.topAnchor.constraint(equalTo: parent.topAnchor),
            backdrop.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            card.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: parent.centerYAnchor),
        ])
    }

    func cancel() { resolve(false) }
    func confirm() { resolve(true) }

    private func resolve(_ value: Bool) {
        guard isShown else { return }
        backdrop.removeFromSuperview()
        card.removeFromSuperview()
        let cb = onResult
        onResult = nil
        cb?(value)
    }

    @objc private func cancelTapped() { resolve(false) }
    @objc private func primaryTapped() { resolve(true) }
}
