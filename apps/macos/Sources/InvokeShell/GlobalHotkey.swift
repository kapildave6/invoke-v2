import AppKit
import Carbon.HIToolbox

/// Global summon hotkey (PLAN.md §3.2). Uses Carbon `RegisterEventHotKey` — the deprecated-but-
/// accepted fast path that, unlike a CGEvent tap, needs NO Accessibility grant, so a dev build
/// summons immediately. The production plan unifies this with a CGEvent-tap subsystem (double-tap
/// modifiers, Hyper key); this is the §3.2 fallback path wired first.
///
/// The Carbon event handler is a C function pointer that can't capture context, so the fire
/// callback is held in a static and dispatched on the main queue (where Carbon delivers it).
public final class GlobalHotkey {
    private var hotKeyRef: EventHotKeyRef?
    private var handlerRef: EventHandlerRef?
    private static var fire: (() -> Void)?

    public init() {}

    /// `keyCode` is a Carbon virtual key (e.g. `kVK_Space`); `modifiers` a Carbon mask (e.g. `optionKey`).
    public func register(keyCode: UInt32, modifiers: UInt32, onFire: @escaping () -> Void) {
        GlobalHotkey.fire = onFire

        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, _ in
                GlobalHotkey.fire?()
                return noErr
            },
            1,
            &spec,
            nil,
            &handlerRef
        )

        let id = EventHotKeyID(signature: OSType(0x494E564B), id: 1) // 'INVK'
        RegisterEventHotKey(keyCode, modifiers, id, GetApplicationEventTarget(), 0, &hotKeyRef)
    }

    public func unregister() {
        if let hotKeyRef { UnregisterEventHotKey(hotKeyRef) }
        if let handlerRef { RemoveEventHandler(handlerRef) }
        hotKeyRef = nil
        handlerRef = nil
    }
}
