import AppKit
import InvokeShell

// Entry point for the Invoke macOS shell (PLAN.md §4.3).
// `.accessory` keeps Invoke out of the Dock — it lives behind the global hotkey.
let app = NSApplication.shared
let controller = AppController()
app.delegate = controller
app.setActivationPolicy(.accessory)
app.run()
