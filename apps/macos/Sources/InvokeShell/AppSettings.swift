import Combine
import Foundation
import Security
import ServiceManagement

/// User-configurable settings (PLAN.md §6 Preferences), persisted in UserDefaults and shared by the
/// Settings window (SwiftUI) and the AppController. Most are read at use-time by the controller, so
/// changes take effect on the next palette open; launch-at-login applies immediately.
public final class AppSettings: ObservableObject {
    public static let shared = AppSettings()
    private let d = UserDefaults.standard

    /// A recorded global hotkey. Modifiers are stored as **Carbon** flag bits (cmdKey/optionKey/…)
    /// so they can be handed straight to RegisterEventHotKey; `display` is the rendered glyph string.
    public struct KeyCombo: Codable, Equatable {
        public var keyCode: UInt32
        public var modifiers: UInt32 // Carbon modifier flags
        public var display: String
        public init(keyCode: UInt32, modifiers: UInt32, display: String) {
            self.keyCode = keyCode; self.modifiers = modifiers; self.display = display
        }
    }

    @Published public var clipboardLimit: Int { didSet { d.set(clipboardLimit, forKey: "clipboardLimit") } }
    @Published public var emojiSkinTone: Int { didSet { d.set(emojiSkinTone, forKey: "emojiSkinTone") } } // 0 = default
    @Published public var disabledCommands: Set<String> { didSet { d.set(Array(disabledCommands), forKey: "disabledCommands") } }
    /// commandId → typed alias (unique across commands). Surfaced first when typed in the root.
    @Published public var aliases: [String: String] { didSet { d.set(aliases, forKey: "commandAliases") } }
    /// commandId → recorded global hotkey.
    @Published public var hotkeys: [String: KeyCombo] { didSet { persistHotkeys() } }
    /// extensionId → { preferenceName: value } for NON-secret extension preferences. Secret
    /// (`password`) preferences are NOT kept here — they go to the Keychain (never plaintext).
    @Published public var extensionPrefs: [String: [String: String]] { didSet { persistExtensionPrefs() } }
    /// Non-secret presence markers ("extID/name") for `password` prefs that have a value in the
    /// Keychain. Lets the Settings pane show "configured" WITHOUT reading the secret — so opening
    /// Settings doesn't trigger a Keychain auth prompt on an unsigned dev build.
    @Published public var extensionSecretKeys: Set<String> { didSet { d.set(Array(extensionSecretKeys), forKey: "extensionSecretKeys") } }
    @Published public var launchAtLogin: Bool {
        didSet {
            d.set(launchAtLogin, forKey: "launchAtLogin")
            applyLaunchAtLogin()
        }
    }
    /// Favorited command ids (Raycast's Favorites) — pinned to the top of the empty root.
    @Published public var favorites: Set<String> { didSet { d.set(Array(favorites), forKey: "favoriteCommands") } }

    private init() {
        clipboardLimit = (d.object(forKey: "clipboardLimit") as? Int) ?? 100
        emojiSkinTone = d.integer(forKey: "emojiSkinTone")
        disabledCommands = Set((d.array(forKey: "disabledCommands") as? [String]) ?? [])
        aliases = (d.dictionary(forKey: "commandAliases") as? [String: String]) ?? [:]
        hotkeys = {
            guard let data = UserDefaults.standard.data(forKey: "commandHotkeys"),
                  let decoded = try? JSONDecoder().decode([String: KeyCombo].self, from: data) else { return [:] }
            return decoded
        }()
        extensionPrefs = {
            guard let data = UserDefaults.standard.data(forKey: "extensionPrefs"),
                  let decoded = try? JSONDecoder().decode([String: [String: String]].self, from: data) else { return [:] }
            return decoded
        }()
        extensionSecretKeys = Set((d.array(forKey: "extensionSecretKeys") as? [String]) ?? [])
        favorites = Set((d.array(forKey: "favoriteCommands") as? [String]) ?? [])
        launchAtLogin = d.bool(forKey: "launchAtLogin")
    }

    private func persistExtensionPrefs() {
        if let data = try? JSONEncoder().encode(extensionPrefs) { d.set(data, forKey: "extensionPrefs") }
    }

    // MARK: - Extension preferences (non-secret in UserDefaults; `password` type in Keychain)

    public func extensionPref(extID: String, name: String, secret: Bool) -> String? {
        secret ? Self.keychainGet(service: "com.invoke.ext.\(extID)", account: name) : extensionPrefs[extID]?[name]
    }

    /// Whether a `password` pref has a stored value — checked from the non-secret marker, NOT the
    /// Keychain, so the Settings pane can show status without an auth prompt.
    public func hasExtensionSecret(extID: String, name: String) -> Bool {
        extensionSecretKeys.contains("\(extID)/\(name)")
    }

    public func setExtensionPref(extID: String, name: String, secret: Bool, value: String) {
        if secret {
            Self.keychainSet(service: "com.invoke.ext.\(extID)", account: name, value: value)
            let marker = "\(extID)/\(name)"
            if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                extensionSecretKeys.remove(marker)
            } else {
                extensionSecretKeys.insert(marker)
            }
            return
        }
        var byExt = extensionPrefs
        var fields = byExt[extID] ?? [:]
        if value.isEmpty { fields[name] = nil } else { fields[name] = value }
        byExt[extID] = fields
        extensionPrefs = byExt
    }

    private static func keychainGet(service: String, account: String) -> String? {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(q as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data, let s = String(data: data, encoding: .utf8) else { return nil }
        return s
    }

    private static func keychainSet(service: String, account: String, value: String) {
        let base: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(base as CFDictionary)
        guard !value.isEmpty, let data = value.data(using: .utf8) else { return }
        var add = base
        add[kSecValueData as String] = data
        SecItemAdd(add as CFDictionary, nil)
    }

    public func isEnabled(_ commandID: String) -> Bool { !disabledCommands.contains(commandID) }

    public func setEnabled(_ commandID: String, _ enabled: Bool) {
        if enabled { disabledCommands.remove(commandID) } else { disabledCommands.insert(commandID) }
    }

    // MARK: - Favorites

    public func isFavorite(_ commandID: String) -> Bool { favorites.contains(commandID) }

    public func toggleFavorite(_ commandID: String) {
        if favorites.contains(commandID) { favorites.remove(commandID) } else { favorites.insert(commandID) }
    }

    // MARK: - Aliases

    public func alias(for commandID: String) -> String? {
        let a = aliases[commandID]
        return (a?.isEmpty ?? true) ? nil : a
    }

    /// Set (or clear, with nil/empty) a command's alias. Aliases are unique — assigning one that
    /// another command already uses removes it from that command first.
    public func setAlias(_ commandID: String, _ alias: String?) {
        let trimmed = alias?.trimmingCharacters(in: .whitespaces).lowercased()
        var next = aliases
        if let trimmed, !trimmed.isEmpty {
            for (k, v) in next where v == trimmed && k != commandID { next[k] = nil }
            next[commandID] = trimmed
        } else {
            next[commandID] = nil
        }
        aliases = next
    }

    // MARK: - Hotkeys

    public func hotkey(for commandID: String) -> KeyCombo? { hotkeys[commandID] }

    /// Set (or clear, with nil) a command's hotkey. Hotkeys are unique — assigning a combo another
    /// command already uses removes it from that command first (avoids a double Carbon registration).
    public func setHotkey(_ commandID: String, _ combo: KeyCombo?) {
        var next = hotkeys
        if let combo {
            for (k, v) in next where v.keyCode == combo.keyCode && v.modifiers == combo.modifiers && k != commandID { next[k] = nil }
            next[commandID] = combo
        } else {
            next[commandID] = nil
        }
        hotkeys = next
    }

    private func persistHotkeys() {
        if let data = try? JSONEncoder().encode(hotkeys) { d.set(data, forKey: "commandHotkeys") }
    }

    /// Physical combos that are already bound to fixed system hotkeys (⌥Space, ⌘⇧V, the window
    /// ⌃⌥arrows). AppController populates this at launch (it owns the Carbon values). The recorder
    /// refuses them so a user can't shadow a built-in shortcut into a silently-dropped registration.
    public static var reservedCombos: Set<UInt64> = []
    public static func comboKey(keyCode: UInt32, modifiers: UInt32) -> UInt64 {
        (UInt64(modifiers) << 32) | UInt64(keyCode)
    }
    public static func isReserved(keyCode: UInt32, modifiers: UInt32) -> Bool {
        reservedCombos.contains(comboKey(keyCode: keyCode, modifiers: modifiers))
    }

    /// The Unicode skin-tone modifier for the current setting, or nil for default.
    public var skinToneModifier: String? {
        let tones = ["\u{1F3FB}", "\u{1F3FC}", "\u{1F3FD}", "\u{1F3FE}", "\u{1F3FF}"]
        guard emojiSkinTone >= 1, emojiSkinTone <= tones.count else { return nil }
        return tones[emojiSkinTone - 1]
    }

    /// Re-assert the persisted launch-at-login intent against SMAppService. `didSet` does NOT fire for
    /// the in-init assignment, so without this the stored bool and the real login-item state can drift
    /// (e.g. a prior register() failed, or the OS cleared the item). Called once at startup.
    public func reconcileLaunchAtLogin() {
        if launchAtLogin { applyLaunchAtLogin() }
    }

    private func applyLaunchAtLogin() {
        do {
            if launchAtLogin { try SMAppService.mainApp.register() }
            else { try SMAppService.mainApp.unregister() }
        } catch {
            // Unsigned dev binaries can't register a login item — ignore; works once signed.
        }
    }
}
