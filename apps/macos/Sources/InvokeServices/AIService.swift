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

    /// Whether an API key is available (without exposing it). Cached — `buildRoot` checks this per
    /// keystroke, and the Keychain fallback is a synchronous IPC we don't want on every render.
    /// (A key added mid-session is picked up on next launch.)
    private var cachedHasKey: Bool?
    public var hasKey: Bool {
        if let c = cachedHasKey { return c }
        let v = apiKey() != nil
        cachedHasKey = v
        return v
    }

    private func apiKey() -> String? {
        if let env = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"], !env.isEmpty { return env }
        return Self.keychainKey()
    }

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

    private static func keychainKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.invoke.ai",
            kSecAttrAccount as String: "anthropic-api-key",
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
