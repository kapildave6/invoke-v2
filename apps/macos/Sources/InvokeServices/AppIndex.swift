import AppKit

/// A launchable application discovered on disk.
public struct AppEntry: Sendable {
    public let name: String
    public let path: String
}

/// Native application index (PLAN.md §2 "App launching & app search"). Scans the standard app
/// directories once and answers fuzzy queries. A production index also watches for changes
/// (FSEvents), uses Spotlight metadata, and ranks by frecency (§4.3); this is the MVP.
public final class AppIndexService {
    private var apps: [AppEntry] = []

    public init() {}

    public var count: Int { apps.count }

    /// All indexed apps, sorted by name (for an appPicker preference dropdown).
    public func allApps() -> [AppEntry] { apps }

    /// Build the index from the conventional app locations.
    public func build() {
        let fm = FileManager.default
        let dirs = [
            "/Applications",
            "/Applications/Utilities",
            "/System/Applications",
            "/System/Applications/Utilities",
            "\(NSHomeDirectory())/Applications",
        ]
        var byName: [String: AppEntry] = [:]
        for dir in dirs {
            guard let items = try? fm.contentsOfDirectory(atPath: dir) else { continue }
            for item in items where item.hasSuffix(".app") {
                let name = String(item.dropLast(4))
                byName[name] = AppEntry(name: name, path: "\(dir)/\(item)")
            }
        }
        apps = byName.values.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    /// Ranked matches for `query`: exact > prefix > word-prefix > substring > subsequence.
    public func search(_ query: String, limit: Int = 8) -> [AppEntry] {
        let q = query.lowercased().trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return [] }
        return apps
            .compactMap { entry -> (AppEntry, Int)? in
                guard let s = Self.score(name: entry.name.lowercased(), query: q) else { return nil }
                return (entry, s)
            }
            .sorted { $0.1 != $1.1 ? $0.1 > $1.1 : $0.0.name.count < $1.0.name.count }
            .prefix(limit)
            .map(\.0)
    }

    private static func score(name: String, query q: String) -> Int? {
        if name == q { return 1000 }
        if name.hasPrefix(q) { return 800 - name.count }
        if name.split(separator: " ").contains(where: { $0.hasPrefix(q) }) { return 600 - name.count }
        if name.contains(q) { return 400 - name.count }
        if isSubsequence(q, name) { return 200 - name.count }
        return nil
    }

    /// True if every char of `q` appears in `s` in order (fuzzy match, e.g. "ggle" → "Google").
    private static func isSubsequence(_ q: String, _ s: String) -> Bool {
        var it = s.makeIterator()
        for ch in q {
            var matched = false
            while let c = it.next() {
                if c == ch { matched = true; break }
            }
            if !matched { return false }
        }
        return true
    }
}
