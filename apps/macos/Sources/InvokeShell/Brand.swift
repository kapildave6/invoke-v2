import AppKit

/// Bundled brand assets (app icon + wordmark logo), loaded from the InvokeShell resource bundle.
/// The wide transparent wordmark is used in Settings → About; the .icns is set as the app icon so
/// it appears in system dialogs (e.g. the Accessibility permission prompt) and, once a signed .app
/// bundle ships (PLAN §3.4/§8.5), in the Dock and Finder.
enum Brand {
    static let appIcon: NSImage? = Bundle.module.image(forResource: "AppIcon")
    static let logo: NSImage? = Bundle.module.image(forResource: "InvokeLogo")
}
