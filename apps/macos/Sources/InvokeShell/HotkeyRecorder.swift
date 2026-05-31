import AppKit
import Carbon.HIToolbox
import SwiftUI

/// A click-to-record global-hotkey field, like Raycast's "Record Hotkey".
///
/// Backed by an NSButton subclass because SwiftUI has no key-capture primitive: when focused it
/// intercepts the next key press (via both `keyDown` and `performKeyEquivalent`, so ⌘-combos that
/// would otherwise be swallowed as menu equivalents are caught), requires at least one modifier
/// (a bare key can't be a global hotkey), and emits an `AppSettings.KeyCombo` carrying Carbon
/// modifier bits ready for `RegisterEventHotKey`. Esc cancels; Delete clears.
struct HotkeyRecorder: NSViewRepresentable {
    @Binding var combo: AppSettings.KeyCombo?

    func makeNSView(context: Context) -> HotkeyRecorderButton {
        let b = HotkeyRecorderButton()
        b.combo = combo
        b.onChange = { context.coordinator.parent.combo = $0 }
        return b
    }

    func updateNSView(_ b: HotkeyRecorderButton, context: Context) {
        context.coordinator.parent = self
        if b.combo != combo { b.combo = combo } // reflect external changes (e.g. the ✕ clear button)
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }
    final class Coordinator { var parent: HotkeyRecorder; init(_ p: HotkeyRecorder) { parent = p } }
}

final class HotkeyRecorderButton: NSButton {
    var onChange: ((AppSettings.KeyCombo?) -> Void)?
    var combo: AppSettings.KeyCombo? { didSet { updateTitle() } }
    private var recording = false { didSet { updateTitle() } }

    init() {
        super.init(frame: .zero)
        bezelStyle = .rounded
        setButtonType(.momentaryPushIn)
        controlSize = .small
        font = .systemFont(ofSize: NSFont.smallSystemFontSize)
        target = self
        action = #selector(beginRecording)
        updateTitle()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    @objc private func beginRecording() { window?.makeFirstResponder(self) }

    override var acceptsFirstResponder: Bool { isEnabled }
    override func becomeFirstResponder() -> Bool { recording = true; return super.becomeFirstResponder() }
    override func resignFirstResponder() -> Bool { recording = false; return super.resignFirstResponder() }

    override func keyDown(with event: NSEvent) {
        if recording { _ = capture(event) } else { super.keyDown(with: event) }
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if recording { return capture(event) }
        return super.performKeyEquivalent(with: event)
    }

    /// Returns true when the event was consumed as (the start of) a recording.
    private func capture(_ event: NSEvent) -> Bool {
        guard recording else { return false }
        let key = event.keyCode
        if key == UInt16(kVK_Escape) { endRecording(); return true }                 // cancel
        if key == UInt16(kVK_Delete) || key == UInt16(kVK_ForwardDelete) {            // clear
            combo = nil; onChange?(nil); endRecording(); return true
        }
        let mods = event.modifierFlags.intersection([.command, .option, .control, .shift])
        let carbon = Self.carbonModifiers(mods)
        guard carbon != 0 else { NSSound.beep(); return true }                        // need a modifier
        // Refuse a combo already owned by a fixed system hotkey — Carbon would drop the duplicate.
        if AppSettings.isReserved(keyCode: UInt32(key), modifiers: carbon) { NSSound.beep(); endRecording(); return true }
        let display = Self.modifierGlyphs(mods) + Self.keyGlyph(key, event: event)
        let c = AppSettings.KeyCombo(keyCode: UInt32(key), modifiers: carbon, display: display)
        combo = c; onChange?(c); endRecording()
        return true
    }

    private func endRecording() { window?.makeFirstResponder(nil) }

    private func updateTitle() {
        title = recording ? "Type shortcut…" : (combo?.display ?? "Record Hotkey")
        contentTintColor = (combo == nil && !recording) ? .secondaryLabelColor : .controlAccentColor
    }

    // MARK: - Translation

    static func carbonModifiers(_ f: NSEvent.ModifierFlags) -> UInt32 {
        var m: UInt32 = 0
        if f.contains(.command) { m |= UInt32(cmdKey) }
        if f.contains(.option)  { m |= UInt32(optionKey) }
        if f.contains(.control) { m |= UInt32(controlKey) }
        if f.contains(.shift)   { m |= UInt32(shiftKey) }
        return m
    }

    static func modifierGlyphs(_ f: NSEvent.ModifierFlags) -> String {
        var s = ""
        if f.contains(.control) { s += "⌃" }
        if f.contains(.option)  { s += "⌥" }
        if f.contains(.shift)   { s += "⇧" }
        if f.contains(.command) { s += "⌘" }
        return s
    }

    static func keyGlyph(_ keyCode: UInt16, event: NSEvent) -> String {
        switch Int(keyCode) {
        case kVK_Return, kVK_ANSI_KeypadEnter: return "↩"
        case kVK_Tab: return "⇥"
        case kVK_Space: return "Space"
        case kVK_LeftArrow: return "←"
        case kVK_RightArrow: return "→"
        case kVK_UpArrow: return "↑"
        case kVK_DownArrow: return "↓"
        case kVK_Home: return "↖"
        case kVK_End: return "↘"
        case kVK_PageUp: return "⇞"
        case kVK_PageDown: return "⇟"
        case kVK_F1: return "F1"; case kVK_F2: return "F2"; case kVK_F3: return "F3"
        case kVK_F4: return "F4"; case kVK_F5: return "F5"; case kVK_F6: return "F6"
        case kVK_F7: return "F7"; case kVK_F8: return "F8"; case kVK_F9: return "F9"
        case kVK_F10: return "F10"; case kVK_F11: return "F11"; case kVK_F12: return "F12"
        default:
            let chars = event.charactersIgnoringModifiers ?? ""
            return chars.isEmpty ? "?" : chars.uppercased()
        }
    }
}
