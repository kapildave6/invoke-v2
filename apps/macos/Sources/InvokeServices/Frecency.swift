import Foundation

/// Frecency ranking (PLAN.md §4.3): "frequency + recency decay". Tracks how often and how recently
/// each item (app or command, keyed by a stable id) was launched, so the most-used float to the top
/// and the empty-root "Suggestions" reflect real usage. Persisted in UserDefaults.
public final class Frecency {
    private struct Entry: Codable { var count: Int; var last: Double }
    private var entries: [String: Entry] = [:]
    private let key = "invoke.frecency.v1"
    private let halfLife: Double = 3 * 24 * 3600 // recency half-life ≈ 3 days

    public init() { load() }

    public var hasData: Bool { !entries.isEmpty }

    /// Record a use of `id` (now).
    public func bump(_ id: String) {
        var e = entries[id] ?? Entry(count: 0, last: 0)
        e.count += 1
        e.last = Date().timeIntervalSince1970
        entries[id] = e
        save()
    }

    /// Frequency × recency-decay. 0 if never used.
    public func score(_ id: String, now: Double = Date().timeIntervalSince1970) -> Double {
        guard let e = entries[id] else { return 0 }
        let recency = exp(-max(0, now - e.last) / halfLife)
        return Double(e.count) * (0.25 + recency)
    }

    /// Highest-scoring ids first.
    public func topIds(limit: Int) -> [String] {
        let now = Date().timeIntervalSince1970
        return entries.keys
            .sorted { score($0, now: now) > score($1, now: now) }
            .prefix(limit)
            .map { $0 }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: Entry].self, from: data) else { return }
        entries = decoded
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
