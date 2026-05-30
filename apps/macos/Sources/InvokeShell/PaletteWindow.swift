import AppKit
import InvokePalette
import InvokeRenderer

/// Borderless panels return `false` from `canBecomeKey`/`canBecomeMain` by default, which blocks
/// keyboard input — override so the search field can become first responder and receive keystrokes.
final class KeyablePanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

/// The command-palette window (PLAN.md §4.3/§6): a borderless, non-activating NSPanel with
/// NSVisualEffectView vibrancy, rounded corners, centered in the upper third of the active display.
/// Kept warm and pre-rendered for the <150ms summon budget (§1). Search bar on top, results below,
/// (later) an action bar at the bottom.
public final class PaletteWindow: NSObject {
    public let panel: NSPanel
    private let searchField = NSTextField()
    private let paletteView: PaletteView

    /// Fired when the user edits the search field — the shell forwards it to the extension.
    public var onSearchChange: ((String) -> Void)?

    public override init() {
        let width: CGFloat = 750
        let rect = NSRect(x: 0, y: 0, width: width, height: 420)
        panel = KeyablePanel(
            contentRect: rect,
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        paletteView = PaletteView(frame: rect)
        super.init()

        panel.isFloatingPanel = true
        panel.level = .floating
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = false
        panel.backgroundColor = .clear
        panel.hasShadow = true

        let blur = NSVisualEffectView(frame: rect)
        blur.material = .hudWindow
        blur.blendingMode = .behindWindow
        blur.state = .active
        blur.wantsLayer = true
        blur.layer?.cornerRadius = 12
        blur.layer?.masksToBounds = true

        searchField.placeholderString = "Search…"
        searchField.font = NSFont.systemFont(ofSize: 20, weight: .light)
        searchField.isBordered = false
        searchField.drawsBackground = false
        searchField.focusRingType = .none
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.delegate = self

        paletteView.translatesAutoresizingMaskIntoConstraints = false

        blur.addSubview(searchField)
        blur.addSubview(paletteView)
        NSLayoutConstraint.activate([
            searchField.leadingAnchor.constraint(equalTo: blur.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: blur.trailingAnchor, constant: -16),
            searchField.topAnchor.constraint(equalTo: blur.topAnchor, constant: 14),
            paletteView.leadingAnchor.constraint(equalTo: blur.leadingAnchor),
            paletteView.trailingAnchor.constraint(equalTo: blur.trailingAnchor),
            paletteView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 10),
            paletteView.bottomAnchor.constraint(equalTo: blur.bottomAnchor),
        ])
        panel.contentView = blur
    }

    public func render(_ tree: ViewTree) {
        paletteView.render(tree)
    }

    /// Show + focus the palette (centered, key window, search field first responder).
    public func show() {
        NSApp.activate(ignoringOtherApps: true)
        panel.center()
        panel.makeKeyAndOrderFront(nil)
        panel.makeFirstResponder(searchField)
    }

    public func toggle() {
        if panel.isVisible {
            panel.orderOut(nil)
        } else {
            show()
        }
    }
}

extension PaletteWindow: NSTextFieldDelegate {
    public func controlTextDidChange(_ obj: Notification) {
        onSearchChange?(searchField.stringValue)
    }
}
