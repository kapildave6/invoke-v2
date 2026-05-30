import Foundation

/// Per-extension persistence (PLAN.md §3.4/§5.5). Production: GRDB + SQLCipher with
/// Keychain-managed keys; clipboard history + OAuth tokens + LocalStorage MUST be
/// encrypted at rest. Stub interface for now.
public protocol EncryptedStore {
    func get(_ key: String) -> Data?
    func set(_ key: String, _ value: Data)
    func remove(_ key: String)
}

public struct Persistence {
    public init() {}
    public static let note = "Encrypted SQLite (SQLCipher) — LocalStorage/Cache/prefs, scoped per extension."
}
