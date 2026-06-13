import AppKit

/// A standalone, transient HUD (Raycast's `showHUD`): a rounded capsule centered near the bottom of the
/// active screen that auto-dismisses. Independent of the palette window, so a headless `no-view` command
/// can give feedback AFTER the palette has closed (where the in-palette toast can't be seen).
final class HUDOverlay {
    private var panel: NSPanel?
    private var dismissWork: DispatchWorkItem?

    func show(_ text: String) {
        guard !text.isEmpty else { return }

        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .labelColor
        label.alignment = .center
        label.maximumNumberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false

        let blur = NSVisualEffectView()
        blur.material = .hudWindow
        blur.blendingMode = .behindWindow
        blur.state = .active
        blur.wantsLayer = true
        blur.layer?.cornerRadius = 12
        blur.layer?.masksToBounds = true
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: blur.leadingAnchor, constant: 18),
            label.trailingAnchor.constraint(equalTo: blur.trailingAnchor, constant: -18),
            label.topAnchor.constraint(equalTo: blur.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: blur.bottomAnchor, constant: -12),
            label.widthAnchor.constraint(lessThanOrEqualToConstant: 420),
        ])

        let p = panel ?? makePanel()
        panel = p
        p.contentView = blur
        blur.layoutSubtreeIfNeeded()
        let size = blur.fittingSize
        let vf = (NSScreen.main ?? NSScreen.screens.first)?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        p.setFrame(NSRect(x: vf.midX - size.width / 2, y: vf.minY + 120, width: size.width, height: size.height), display: true)
        p.alphaValue = 1
        p.orderFrontRegardless()

        dismissWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let p = self?.panel else { return }
            NSAnimationContext.runAnimationGroup({ ctx in ctx.duration = 0.25; p.animator().alphaValue = 0 },
                                                 completionHandler: { p.orderOut(nil) })
        }
        dismissWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8, execute: work)
    }

    private func makePanel() -> NSPanel {
        let p = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: true)
        p.isOpaque = false
        p.backgroundColor = .clear
        p.level = .statusBar
        p.hasShadow = true
        p.ignoresMouseEvents = true
        p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        return p
    }
}
