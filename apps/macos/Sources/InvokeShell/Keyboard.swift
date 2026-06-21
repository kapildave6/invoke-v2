import AppKit

/// Pure keyboard-shortcut mappings for Raycast's `Keyboard.Shortcut` ({ modifiers, key }). AppKit/
/// Foundation only (no project types) so it compiles in a standalone `swift` script for unit testing.
/// Used to render a shortcut as glyph chips (via Keycap.chips) and to match a pressed combo against a
/// bound action shortcut (PaletteWindow.keyMonitor).
enum Keyboard {
    /// Normalize a Raycast modifier list to our canonical lowercase vocabulary: cmd / shift / opt / ctrl.
    static func normalize(_ modifiers: [String]) -> Set<String> {
        var out = Set<String>()
        for m in modifiers {
            switch m.lowercased() {
            case "cmd", "command": out.insert("cmd")
            case "shift": out.insert("shift")
            case "opt", "option", "alt": out.insert("opt")
            case "ctrl", "control": out.insert("ctrl")
            default: break
            }
        }
        return out
    }

    /// One key token → its display glyph (named keys) or upper-cased character(s).
    static func keyGlyph(_ key: String) -> String {
        switch key.lowercased() {
        case "enter", "return": return "↵"
        case "delete", "backspace": return "⌫"
        case "deleteforward": return "⌦"
        case "arrowup": return "↑"
        case "arrowdown": return "↓"
        case "arrowleft": return "←"
        case "arrowright": return "→"
        case "escape", "esc": return "⎋"
        case "tab": return "⇥"
        case "space": return "␣"
        case "pageup": return "⇞"
        case "pagedown": return "⇟"
        case "home": return "↖"
        case "end": return "↘"
        default: return key.uppercased()
        }
    }

    /// Render modifiers + key as a contiguous glyph string in Raycast's render order (⌃⌥⇧⌘ then key),
    /// e.g. ["cmd","shift"]+"k" → "⇧⌘K". Keycap.chips(for:) splits this into one chip per glyph.
    static func glyphs(modifiers: [String], key: String) -> String {
        let m = normalize(modifiers)
        var s = ""
        if m.contains("ctrl") { s += "⌃" }
        if m.contains("opt") { s += "⌥" }
        if m.contains("shift") { s += "⇧" }
        if m.contains("cmd") { s += "⌘" }
        return s + keyGlyph(key)
    }
}
