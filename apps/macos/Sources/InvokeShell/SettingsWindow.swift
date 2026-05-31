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

            tabs.addTabViewItem(tab("General", "gearshape", NSHostingController(rootView: GeneralPane())))
            tabs.addTabViewItem(tab("Commands", "command", NSHostingController(rootView: CommandsPane(commands: commands))))
            tabs.addTabViewItem(tab("Clipboard", "doc.on.clipboard", NSHostingController(rootView: ClipboardPane(onClear: onClearClipboard))))
            tabs.addTabViewItem(tab("Advanced", "wrench.and.screwdriver", NSHostingController(rootView: AdvancedPane())))
            tabs.addTabViewItem(tab("About", "info.circle", NSHostingController(rootView: AboutPane())))

            let w = NSWindow(contentViewController: tabs)
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
