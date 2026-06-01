import Foundation

/// A runnable action surfaced for the selected result (PLAN.md §6 Action Panel). The shell builds
/// these from the selected item's `action` nodes; the action bar shows the primary one and ⌘K
/// lists them all. `run` closes over the invoke-over-IPC / native-copy behavior in AppController.
public struct PaletteAction {
    public let title: String
    /// Display-only shortcut hint (e.g. "↵", "⌘↵").
    public let shortcut: String?
    /// Optional SF Symbol name for the ⌘K Action Panel row (inferred from the title when nil).
    public let icon: String?
    public let run: () -> Void

    public init(title: String, shortcut: String?, icon: String? = nil, run: @escaping () -> Void) {
        self.title = title
        self.shortcut = shortcut
        self.icon = icon
        self.run = run
    }
}
