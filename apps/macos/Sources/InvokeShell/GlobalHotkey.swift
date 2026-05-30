import AppKit
import Carbon.HIToolbox

/// Global hotkeys (PLAN.md §3.2) via Carbon RegisterEventHotKey — the deprecated-but-accepted fast
/// path that needs NO Accessibility grant. Supports multiple bindings (e.g. ⌥Space to summon,
/// ⌘⇧V for Clipboard History), dispatched by hotkey id from a single installed event handler.
/// Carbon's handler is a C function pointer that can't capture, so callbacks live in a static map.
public final class GlobalHotkey {
    private static var handlers: [UInt32: () -> Void] = [:]
    private static var eventHandlerInstalled = false
    private static var eventHandlerRef: EventHandlerRef?

    private var refs: [EventHotKeyRef?] = []

    public init() {}

    /// Bind `keyCode` + Carbon `modifiers` to `onFire`. `id` distinguishes bindings in the handler.
    public func register(id: UInt32, keyCode: UInt32, modifiers: UInt32, onFire: @escaping () -> Void) {
        GlobalHotkey.handlers[id] = onFire
        GlobalHotkey.installHandlerIfNeeded()
        var ref: EventHotKeyRef?
        let hotKeyID = EventHotKeyID(signature: OSType(0x494E564B), id: id) // 'INVK'
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &ref)
        refs.append(ref)
    }

    private static func installHandlerIfNeeded() {
        guard !eventHandlerInstalled else { return }
        eventHandlerInstalled = true
        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, _ -> OSStatus in
                var hkID = EventHotKeyID()
                let status = GetEventParameter(
                    event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID),
                    nil, MemoryLayout<EventHotKeyID>.size, nil, &hkID
                )
                if status == noErr { GlobalHotkey.handlers[hkID.id]?() }
                return noErr
            },
            1, &spec, nil, &eventHandlerRef
        )
    }

    public func unregister() {
        for ref in refs where ref != nil { UnregisterEventHotKey(ref) }
        refs.removeAll()
    }
}
