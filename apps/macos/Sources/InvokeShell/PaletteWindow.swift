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
/// NSVisualEffectView vibrancy, a search bar, a result list, and a persistent bottom action bar.
/// ⌘K opens the Action Panel (all actions for the selected result). Kept warm for the <150ms
/// summon budget (§1).
public final class PaletteWindow: NSObject {
    public let panel: NSPanel
    private let searchField = NSTextField()
    private let paletteView: PaletteView

    // Bottom action bar.
    private let commandLabel = NSTextField(labelWithString: "")
    private let actionHintLabel = NSTextField(labelWithString: "")

    private var keyMonitor: Any?
    private var actionMenu: NSMenu?

    // Toast capsule (action feedback, e.g. "Copied to Clipboard").
    private let toastLabel = NSTextField(labelWithString: "")
    private var toastContainer: NSView?
    private var toastHideWork: DispatchWorkItem?

    /// Fired when the user edits the search field — the shell forwards it to the extension.
    public var onSearchChange: ((String) -> Void)?
    /// Move selection by ±1 (arrow keys), with the search field keeping focus.
    public var onMove: ((Int) -> Void)?
    /// Activate the selected row's action (Enter = primary; ⌘Enter = secondary).
    public var onActivate: ((_ secondary: Bool) -> Void)?
    /// Esc pressed.
    public var onCancel: (() -> Void)?
    /// Supplies the actions for the currently-selected result (for the ⌘K Action Panel).
    public var actionsProvider: (() -> [PaletteAction])?

    public override init() {
        let width: CGFloat = 750
        let rect = NSRect(x: 0, y: 0, width: width, height: 200) // grows/shrinks to fit content
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

        searchField.placeholderString = "Search for apps and commands…"
        searchField.font = NSFont.systemFont(ofSize: 20, weight: .light)
        searchField.isBordered = false
        searchField.drawsBackground = false
        searchField.focusRingType = .none
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.delegate = self

        paletteView.translatesAutoresizingMaskIntoConstraints = false

        let actionBar = makeActionBar()

        blur.addSubview(searchField)
        blur.addSubview(paletteView)
        blur.addSubview(actionBar)
        NSLayoutConstraint.activate([
            searchField.leadingAnchor.constraint(equalTo: blur.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: blur.trailingAnchor, constant: -16),
            searchField.topAnchor.constraint(equalTo: blur.topAnchor, constant: 14),

            paletteView.leadingAnchor.constraint(equalTo: blur.leadingAnchor),
            paletteView.trailingAnchor.constraint(equalTo: blur.trailingAnchor),
            paletteView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 10),
            paletteView.bottomAnchor.constraint(equalTo: actionBar.topAnchor),

            actionBar.leadingAnchor.constraint(equalTo: blur.leadingAnchor),
            actionBar.trailingAnchor.constraint(equalTo: blur.trailingAnchor),
            actionBar.bottomAnchor.constraint(equalTo: blur.bottomAnchor),
            actionBar.heightAnchor.constraint(equalToConstant: 38),
        ])

        // Toast capsule — hidden until showToast(), floats just above the action bar.
        toastLabel.font = .systemFont(ofSize: 12, weight: .medium)
        toastLabel.textColor = .labelColor
        toastLabel.alignment = .center
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        let toastBg = NSVisualEffectView()
        toastBg.material = .hudWindow
        toastBg.blendingMode = .withinWindow
        toastBg.state = .active
        toastBg.wantsLayer = true
        toastBg.layer?.cornerRadius = 10
        toastBg.layer?.masksToBounds = true
        toastBg.alphaValue = 0
        toastBg.translatesAutoresizingMaskIntoConstraints = false
        toastBg.addSubview(toastLabel)
        blur.addSubview(toastBg)
        toastContainer = toastBg
        NSLayoutConstraint.activate([
            toastLabel.leadingAnchor.constraint(equalTo: toastBg.leadingAnchor, constant: 16),
            toastLabel.trailingAnchor.constraint(equalTo: toastBg.trailingAnchor, constant: -16),
            toastLabel.topAnchor.constraint(equalTo: toastBg.topAnchor, constant: 8),
            toastLabel.bottomAnchor.constraint(equalTo: toastBg.bottomAnchor, constant: -8),
            toastBg.centerXAnchor.constraint(equalTo: blur.centerXAnchor),
            toastBg.bottomAnchor.constraint(equalTo: blur.bottomAnchor, constant: -52),
        ])

        panel.contentView = blur
    }

    deinit {
        removeKeyMonitor()
    }

    private func makeActionBar() -> NSView {
        let bar = NSView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.wantsLayer = true

        // Hairline separator across the top of the bar.
        let sep = NSBox()
        sep.boxType = .separator
        sep.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(sep)

        commandLabel.font = .systemFont(ofSize: 12, weight: .medium)
        commandLabel.textColor = .secondaryLabelColor
        commandLabel.translatesAutoresizingMaskIntoConstraints = false

        actionHintLabel.font = .systemFont(ofSize: 12)
        actionHintLabel.textColor = .secondaryLabelColor
        actionHintLabel.alignment = .right
        actionHintLabel.translatesAutoresizingMaskIntoConstraints = false

        bar.addSubview(commandLabel)
        bar.addSubview(actionHintLabel)
        NSLayoutConstraint.activate([
            sep.leadingAnchor.constraint(equalTo: bar.leadingAnchor),
            sep.trailingAnchor.constraint(equalTo: bar.trailingAnchor),
            sep.topAnchor.constraint(equalTo: bar.topAnchor),
            commandLabel.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 16),
            commandLabel.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            actionHintLabel.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -16),
            actionHintLabel.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            actionHintLabel.leadingAnchor.constraint(greaterThanOrEqualTo: commandLabel.trailingAnchor, constant: 8),
        ])
        return bar
    }

    // MARK: - Rendering / action bar

    public func render(_ tree: ViewTree, selectedIndex: Int) {
        paletteView.render(tree, selectedIndex: selectedIndex)
        resizeToFit()
    }

    /// Compact Mode (PLAN.md §4.3): size the window to its content — search bar + results + action
    /// bar — so there's no dead space, growing/shrinking as results change (capped, then it scrolls).
    private func resizeToFit() {
        let searchH = searchField.fittingSize.height
        let contentH = paletteView.fittingHeight()
        let target = min(max(14 + searchH + 10 + 8 + contentH + 12 + 38, 96), 540)
        var frame = panel.frame
        let dy = target - frame.height
        if abs(dy) < 0.5 { return }
        frame.origin.y -= dy // keep the top edge fixed; grow/shrink downward
        frame.size.height = target
        panel.setFrame(frame, display: true)
    }

    /// Clear the search field (e.g. after launching an app), without firing onSearchChange.
    public func clearSearch() {
        searchField.stringValue = ""
    }

    /// Briefly show a feedback capsule (e.g. "Copied to Clipboard"), then fade it out.
    public func showToast(_ message: String) {
        guard let container = toastContainer else { return }
        toastLabel.stringValue = message
        toastHideWork?.cancel()
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.12
            container.animator().alphaValue = 1
        }
        let work = DispatchWorkItem { [weak container] in
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.25
                container?.animator().alphaValue = 0
            }
        }
        toastHideWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3, execute: work)
    }

    /// Update the bottom bar: the command name (left) and the primary action + ⌘K hint (right).
    public func setActionBar(command: String, primary: String?) {
        commandLabel.stringValue = command
        if let primary {
            actionHintLabel.stringValue = "\(primary)   ↵        |        Actions   ⌘K"
        } else {
            actionHintLabel.stringValue = "Actions   ⌘K"
        }
    }

    // MARK: - Show / hide

    /// Show + focus the palette (centered, key window, search field first responder).
    public func show() {
        installKeyMonitor() // armed only while visible (no global keystroke overhead when hidden)
        NSApp.activate(ignoringOtherApps: true)
        panel.center()
        panel.makeKeyAndOrderFront(nil)
        panel.makeFirstResponder(searchField)
    }

    public func hide() {
        dismissMenu()
        removeKeyMonitor()
        panel.orderOut(nil)
    }

    public func toggle() {
        if panel.isVisible { hide() } else { show() }
    }

    // MARK: - Action Panel (⌘K)

    private func installKeyMonitor() {
        guard keyMonitor == nil else { return }
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, self.panel.isKeyWindow,
                  event.modifierFlags.contains(.command) else { return event }
            if event.charactersIgnoringModifiers?.lowercased() == "k" {
                self.showActionMenu(); return nil                 // ⌘K → Action Panel
            }
            if event.keyCode == 36 || event.keyCode == 76 {        // ⌘Return / ⌘keypad-Enter → secondary
                self.onActivate?(true); return nil                 // (doCommandBy doesn't deliver ⌘Return reliably)
            }
            return event
        }
    }

    private func removeKeyMonitor() {
        if let keyMonitor { NSEvent.removeMonitor(keyMonitor); self.keyMonitor = nil }
    }

    /// Dismiss the Action Panel if it's open (called on re-render so it can't act on a stale tree).
    public func dismissMenu() {
        actionMenu?.cancelTracking()
    }

    private func showActionMenu() {
        guard let actions = actionsProvider?(), !actions.isEmpty, let content = panel.contentView else { return }

        let menu = NSMenu()
        menu.autoenablesItems = false
        for (i, action) in actions.enumerated() {
            let item = NSMenuItem(title: action.title, action: #selector(runMenuAction(_:)), keyEquivalent: "")
            item.target = self
            item.tag = i
            if let shortcut = action.shortcut { item.toolTip = shortcut }
            menu.addItem(item)
        }
        actionMenu = menu
        // Anchor near the top-right; the menu grows downward and AppKit keeps it on-screen.
        // (A styled, bottom-right, searchable Action Panel is a fidelity follow-up.)
        let anchor = NSPoint(x: max(0, content.bounds.maxX - 240), y: content.bounds.maxY - 48)
        menu.popUp(positioning: menu.items.first, at: anchor, in: content) // modal: returns when tracking ends
        actionMenu = nil
    }

    /// Re-fetch the CURRENT actions at click time so a re-render during menu tracking can't run a
    /// stale action (or index out of bounds).
    @objc private func runMenuAction(_ sender: NSMenuItem) {
        guard let actions = actionsProvider?(), sender.tag >= 0, sender.tag < actions.count else { return }
        actions[sender.tag].run()
    }
}

extension PaletteWindow: NSTextFieldDelegate {
    public func controlTextDidChange(_ obj: Notification) {
        onSearchChange?(searchField.stringValue)
    }

    /// Route list-navigation keys while the search field keeps focus (Raycast-style): arrows move
    /// the selection, Enter/⌘Enter activate the primary/secondary action, Esc cancels.
    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch commandSelector {
        case #selector(NSResponder.moveDown(_:)):
            onMove?(1); return true
        case #selector(NSResponder.moveUp(_:)):
            onMove?(-1); return true
        case #selector(NSResponder.insertNewline(_:)):
            onActivate?(false); return true // ⌘Return (secondary) is handled by the key monitor
        case #selector(NSResponder.cancelOperation(_:)):
            onCancel?(); return true
        default:
            return false
        }
    }
}
