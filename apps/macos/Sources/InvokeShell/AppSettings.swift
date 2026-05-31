import Combine
import Foundation
import ServiceManagement

/// User-configurable settings (PLAN.md §6 Preferences), persisted in UserDefaults and shared by the
/// Settings window (SwiftUI) and the AppController. Most are read at use-time by the controller, so
/// changes take effect on the next palette open; launch-at-login applies immediately.
public final class AppSettings: ObservableObject {
    public static let shared = AppSettings()
    private let d = UserDefaults.standard

    @Published public var clipboardLimit: Int { didSet { d.set(clipboardLimit, forKey: "clipboardLimit") } }
    @Published public var emojiSkinTone: Int { didSet { d.set(emojiSkinTone, forKey: "emojiSkinTone") } } // 0 = default
    @Published public var disabledCommands: Set<String> { didSet { d.set(Array(disabledCommands), forKey: "disabledCommands") } }
    @Published public var launchAtLogin: Bool {
        didSet {
            d.set(launchAtLogin, forKey: "launchAtLogin")
            applyLaunchAtLogin()
        }
    }

    private init() {
        clipboardLimit = (d.object(forKey: "clipboardLimit") as? Int) ?? 100
        emojiSkinTone = d.integer(forKey: "emojiSkinTone")
        disabledCommands = Set((d.array(forKey: "disabledCommands") as? [String]) ?? [])
        launchAtLogin = d.bool(forKey: "launchAtLogin")
    }

    public func isEnabled(_ commandID: String) -> Bool { !disabledCommands.contains(commandID) }

    public func setEnabled(_ commandID: String, _ enabled: Bool) {
        if enabled { disabledCommands.remove(commandID) } else { disabledCommands.insert(commandID) }
    }

    /// The Unicode skin-tone modifier for the current setting, or nil for default.
    public var skinToneModifier: String? {
        let tones = ["\u{1F3FB}", "\u{1F3FC}", "\u{1F3FD}", "\u{1F3FE}", "\u{1F3FF}"]
        guard emojiSkinTone >= 1, emojiSkinTone <= tones.count else { return nil }
        return tones[emojiSkinTone - 1]
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
