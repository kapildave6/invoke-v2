import Foundation

/// A group of actions in the ⌘K Action Panel (Raycast's `ActionPanel.Section`). `title` renders as a
/// small-caps header; `entries` render in order. Built from an extension's `<ActionPanel>` subtree, or a
/// single untitled section wrapping a built-in mode's flat action list.
struct ActionSection {
    let title: String?
    let entries: [ActionEntry]
}

/// One entry in a section: a runnable action, or a submenu that drills into its own sections.
enum ActionEntry {
    case action(PaletteAction)
    case submenu(title: String, icon: String?, sections: [ActionSection])
}
