import Foundation
import Security

/// Minimal Anthropic Messages-API client for the AI commands (PLAN.md §2/§7).
///
/// The API key is read from the `ANTHROPIC_API_KEY` environment variable, falling back to a Keychain
/// item (service `com.invoke.ai`, account `anthropic-api-key`). It is NEVER hard-coded, logged, or
/// persisted in plaintext. The model defaults to a current Claude model and can be overridden with
/// `INVOKE_AI_MODEL`.
public final class AIService {
    public enum AIError: Error {
        case noKey
        case network(String)
        case api(String)
        case empty

        public var message: String {
            switch self {
            case .noKey: return "Set ANTHROPIC_API_KEY to use AI"
            case .network(let m): return "Network error: \(m)"
            case .api(let m): return m
            case .empty: return "Empty response"
            }
        }
    }

    private let model = ProcessInfo.processInfo.environment["INVOKE_AI_MODEL"] ?? "claude-sonnet-4-6"

    public init() {}

    private static let service = "com.invoke.ai"
    private static let account = "anthropic-api-key"
    // Non-secret presence marker. Existence is checked from this (not the Keychain), so status checks
    // and the per-keystroke "Ask AI" gating never trigger a Keychain authorization prompt — which an
    // UNSIGNED dev build would otherwise show on every access. The key VALUE is read only on a request.
    private static let presentFlag = "invoke.ai.keyPresent"

    /// Whether a key is configured — WITHOUT reading the Keychain (env var or the presence flag).
    public var hasKey: Bool { AIService.hasStoredKey() }

    private func apiKey() -> String? {
        if let env = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"], !env.isEmpty { return env }
        return Self.keychainKey()
    }

    // MARK: - Key management for the Settings UI (the value is never logged, echoed, or returned)

    /// Whether a key is configured (env var or stored) — no Keychain read, so no auth prompt.
    public static func hasStoredKey() -> Bool {
        usingEnvKey() || UserDefaults.standard.bool(forKey: presentFlag)
    }

    /// True when the env var supplies the key (which takes precedence over the Keychain).
    public static func usingEnvKey() -> Bool {
        !(ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] ?? "").isEmpty
    }

    /// Store (or, with empty, remove) the Anthropic key in the Keychain. Replaces any existing item.
    public static func storeAPIKey(_ key: String) {
        let base: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(base as CFDictionary)
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty, let data = trimmed.data(using: .utf8) {
            var add = base
            add[kSecValueData as String] = data
            SecItemAdd(add as CFDictionary, nil)
        }
        UserDefaults.standard.set(!trimmed.isEmpty, forKey: presentFlag) // presence marker (non-secret)
    }

    public static func clearStoredKey() { storeAPIKey("") }

    /// One-shot completion: `system` instruction + `user` content → assistant text.
    public func complete(system: String, user: String, maxTokens: Int = 1024) async -> Result<String, AIError> {
        guard let key = apiKey() else { return .failure(.noKey) }
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else { return .failure(.network("bad url")) }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.timeoutInterval = 60
        req.setValue(key, forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        req.setValue("application/json", forHTTPHeaderField: "content-type")
        let body: [String: Any] = [
            "model": model,
            "max_tokens": maxTokens,
            "system": system,
            "messages": [["role": "user", "content": user]],
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse else { return .failure(.network("no response")) }
            guard (200..<300).contains(http.statusCode) else {
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                let detail = ((json?["error"] as? [String: Any])?["message"] as? String) ?? "HTTP \(http.statusCode)"
                return .failure(.api(detail))
            }
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let content = json["content"] as? [[String: Any]] else { return .failure(.empty) }
            let text = content.compactMap { $0["text"] as? String }.joined()
            return text.isEmpty ? .failure(.empty) : .success(text)
        } catch {
            return .failure(.network(error.localizedDescription))
        }
    }

    /// Streaming, multi-turn completion (Anthropic SSE). `messages` is the full conversation
    /// ([{role:"user"|"assistant", content:…}]). `onDelta` fires per text chunk and `onComplete` with
    /// the full text (or an error) — both delivered on the MAIN queue, so callers update UI directly.
    public func stream(system: String, messages: [[String: String]], maxTokens: Int = 2000,
                       onDelta: @escaping (String) -> Void,
                       onComplete: @escaping (Result<String, AIError>) -> Void) {
        func finish(_ r: Result<String, AIError>) { DispatchQueue.main.async { onComplete(r) } }
        guard let key = apiKey() else { finish(.failure(.noKey)); return }
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else { finish(.failure(.network("bad url"))); return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.timeoutInterval = 120
        req.setValue(key, forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        req.setValue("application/json", forHTTPHeaderField: "content-type")
        let body: [String: Any] = [
            "model": model, "max_tokens": maxTokens, "system": system,
            "messages": messages, "stream": true,
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        Task {
            do {
                let (bytes, resp) = try await URLSession.shared.bytes(for: req)
                guard let http = resp as? HTTPURLResponse else { finish(.failure(.network("no response"))); return }
                guard (200..<300).contains(http.statusCode) else {
                    var raw = ""
                    for try await line in bytes.lines { raw += line }
                    let json = (try? JSONSerialization.jsonObject(with: Data(raw.utf8))) as? [String: Any]
                    let detail = ((json?["error"] as? [String: Any])?["message"] as? String) ?? "HTTP \(http.statusCode)"
                    finish(.failure(.api(detail)))
                    return
                }
                var full = ""
                for try await line in bytes.lines {
                    guard line.hasPrefix("data:") else { continue }
                    let payload = line.dropFirst(5).trimmingCharacters(in: .whitespaces)
                    guard let obj = (try? JSONSerialization.jsonObject(with: Data(payload.utf8))) as? [String: Any],
                          let type = obj["type"] as? String else { continue }
                    switch type {
                    case "content_block_delta":
                        if let delta = obj["delta"] as? [String: Any], let t = delta["text"] as? String, !t.isEmpty {
                            full += t
                            DispatchQueue.main.async { onDelta(t) }
                        }
                    case "error":
                        let msg = ((obj["error"] as? [String: Any])?["message"] as? String) ?? "stream error"
                        finish(.failure(.api(msg))); return
                    case "message_stop":
                        finish(full.isEmpty ? .failure(.empty) : .success(full)); return
                    default:
                        break
                    }
                }
                finish(full.isEmpty ? .failure(.empty) : .success(full))
            } catch {
                finish(.failure(.network(error.localizedDescription)))
            }
        }
    }

    private static func keychainKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let s = String(data: data, encoding: .utf8), !s.isEmpty else { return nil }
        return s
    }
}
