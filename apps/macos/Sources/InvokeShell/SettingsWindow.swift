import AppKit
import SwiftUI

/// Hosts the Settings panes in a conventional macOS window (PLAN.md §6) using an
/// NSTabViewController with the native `.toolbar` tab style — icon + label tabs like macOS System
/// Settings / Raycast — each tab a SwiftUI pane via NSHostingController.
public final class SettingsWindow {
    private var window: NSWindow?

    public init() {}

    public func show(commands: [CommandInfo], onClearClipboard: @escaping () -> Void) {
        if window == nil {
            let tabs = NSTabViewController()
            tabs.tabStyle = .toolbar

            func tab(_ title: String, _ symbol: String, _ controller: NSViewController) -> NSTabViewItem {
                let item = NSTabViewItem(viewController: controller)
                item.label = title
                item.image = NSImage(systemSymbolName: symbol, accessibilityDescription: title)
                return item
            }

            func hosted<V: View>(_ view: V) -> NSHostingController<V> {
                let c = NSHostingController(rootView: view)
                // Drive the window size from the panes so NSTabViewController doesn't size to a
                // narrow fitting width (which clipped the form content on the left edge).
                c.preferredContentSize = NSSize(width: 600, height: 470)
                return c
            }

            tabs.addTabViewItem(tab("General", "gearshape", hosted(GeneralPane())))
            tabs.addTabViewItem(tab("Commands", "command", hosted(CommandsPane(commands: commands))))
            tabs.addTabViewItem(tab("Clipboard", "doc.on.clipboard", hosted(ClipboardPane(onClear: onClearClipboard))))
            tabs.addTabViewItem(tab("Advanced", "wrench.and.screwdriver", hosted(AdvancedPane())))
            tabs.addTabViewItem(tab("About", "info.circle", hosted(AboutPane())))

            let w = NSWindow(contentViewController: tabs)
            w.styleMask = [.titled, .closable, .miniaturizable]
            w.isReleasedWhenClosed = false
            w.setContentSize(NSSize(width: 600, height: 470))
            w.center()
            window = w
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
        // NSTabViewController(.toolbar) resets the title to "Untitled"; force it after it's shown.
        window?.title = "Invoke Settings"
    }
}
