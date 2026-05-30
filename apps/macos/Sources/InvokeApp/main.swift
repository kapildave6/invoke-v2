import AppKit
import Darwin
import InvokeShell

// Entry point for the Invoke macOS shell (PLAN.md §4.3).
// `.accessory` keeps Invoke out of the Dock — it lives behind the global hotkey.

// Stream host logs immediately: stdout is block-buffered when not a TTY (e.g. piped to a file).
setvbuf(stdout, nil, _IONBF, 0)

let app = NSApplication.shared
let controller = AppController()
app.delegate = controller
app.setActivationPolicy(.accessory)
app.run()
