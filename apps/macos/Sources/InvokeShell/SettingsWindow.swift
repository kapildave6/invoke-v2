import AppKit
import SwiftUI

/// Hosts the Settings panes in a conventional macOS window (PLAN.md §6) using an
/// NSTabViewController with the native `.toolbar` tab style — icon + label tabs like macOS System
/// Settings / Raycast — each tab a SwiftUI pane via NSHostingController.
public final class SettingsWindow {
    private var window: NSWindow?
    private var tabController: NSTabViewController?

    public init() {}

    public func show(groups: [ExtensionGroup], prefGroups: [ExtensionPrefGroup], onClearClipboard: @escaping () -> Void, onBindingsChanged: @escaping () -> Void, repoRoot: String, selectTab: Int? = nil) {
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
                c.preferredContentSize = NSSize(width: 900, height: 600)
                return c
            }

            // Tab order must match AppController.SettingsTab.
            tabs.addTabViewItem(tab("General", "gearshape", hosted(GeneralPane())))
            tabs.addTabViewItem(tab("Commands", "command", hosted(CommandsPane(groups: groups, onBindingsChanged: onBindingsChanged))))
            tabs.addTabViewItem(tab("Snippets", "text.quote", hosted(SnippetsPane())))
            tabs.addTabViewItem(tab("Quicklinks", "link", hosted(QuicklinksPane())))
            tabs.addTabViewItem(tab("Import", "square.and.arrow.down", hosted(ImportPane(repoRoot: repoRoot))))
            tabs.addTabViewItem(tab("Extensions", "puzzlepiece.extension", hosted(ExtensionPrefsPane(groups: prefGroups))))
            tabs.addTabViewItem(tab("Clipboard", "doc.on.clipboard", hosted(ClipboardPane(onClear: onClearClipboard))))
            tabs.addTabViewItem(tab("Advanced", "wrench.and.screwdriver", hosted(AdvancedPane())))
            tabs.addTabViewItem(tab("About", "info.circle", hosted(AboutPane())))
            self.tabController = tabs

            let w = NSWindow(contentViewController: tabs)
            w.styleMask = [.titled, .closable, .miniaturizable]
            w.isReleasedWhenClosed = false
            w.setContentSize(NSSize(width: 900, height: 600))
            w.center()
            window = w
        }
        if let selectTab, let tabs = tabController, selectTab >= 0, selectTab < tabs.tabViewItems.count {
            tabs.selectedTabViewItemIndex = selectTab
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
        // NSTabViewController(.toolbar) resets the title to "Untitled"; force it after it's shown.
        window?.title = "Invoke Settings"
    }
}
