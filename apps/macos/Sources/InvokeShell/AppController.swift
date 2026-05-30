import AppKit
import InvokeIPC
import InvokeRenderer

/// App lifecycle + summon (PLAN.md §4.3). Owns the warm palette window and (Phase 0)
/// the CGEvent-tap hotkey subsystem (§3.2) and the extension supervisor bridge that
/// feeds the render-mutation stream into the view models (§4.6/§4.7).
public final class AppController: NSObject, NSApplicationDelegate {
    private let palette = PaletteWindow()
    private let tree = ViewTree()

    public override init() { super.init() }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Phase 0: register the global summon hotkey here via the CGEvent-tap
        // subsystem (default Option+Space) once Accessibility is granted (§3.2/§9).
        // For now, show the palette so the shell is visible when run under a GUI.
        palette.render(tree)
        palette.toggle()
    }

    /// Apply a render-mutation commit coming from an extension process (§4.7).
    public func applyCommit(_ ops: [Mutation]) {
        tree.apply(ops)
        palette.render(tree)
    }
}
