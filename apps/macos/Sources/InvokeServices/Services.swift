import Foundation

/// Native services (PLAN.md §4.3/§4.7). Performance-critical built-ins live here in
/// Swift and are surfaced as commands. These are interface stubs for Phase 0/1.

public protocol HotkeyService {
    /// Register the global summon hotkey via the unified CGEvent-tap subsystem (§3.2).
    func registerSummon(_ handler: @escaping () -> Void)
}

public protocol AppIndex {
    /// App launching & search via NSWorkspace/Spotlight (§ Feature Inventory).
    func search(_ query: String) -> [String]
}

public protocol ClipboardMonitor {
    /// Clipboard history via NSPasteboard, encrypted at rest (§3.4).
    func start()
}

public struct Services {
    public init() {}
    public static let summary = "Native services: hotkey, app/file index, clipboard, window/menu AX, calculator, EventKit."
}
