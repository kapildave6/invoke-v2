import AppKit
import SwiftUI

/// Hosts the SwiftUI Settings view in a conventional macOS window (PLAN.md §6 — settings live in a
/// normal window, not the translucent palette).
public final class SettingsWindow {
    private var window: NSWindow?

    public init() {}

    public func show(commands: [CommandInfo], onClearClipboard: @escaping () -> Void) {
        if window == nil {
            let hosting = NSHostingController(rootView: SettingsView(commands: commands, onClearClipboard: onClearClipboard))
            let w = NSWindow(contentViewController: hosting)
            w.title = "Invoke Settings"
            w.styleMask = [.titled, .closable, .miniaturizable]
            w.isReleasedWhenClosed = false
            w.center()
            window = w
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}
