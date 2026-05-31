import AppKit

/// Screenshot search (PLAN.md §2 Screenshots). Finds recent screenshots/recordings in the macOS
/// screenshot folder (honoring a custom `com.apple.screencapture location`, default ~/Desktop).
public final class ScreenshotIndex {
    public struct Shot: Sendable {
        public let path: String
        public let name: String
        public let date: Date
        public let size: Int
    }

    public init() {}

    /// The configured screenshot save location (falls back to ~/Desktop).
    public func location() -> String {
        if let loc = UserDefaults(suiteName: "com.apple.screencapture")?.string(forKey: "location"), !loc.isEmpty {
            return (loc as NSString).expandingTildeInPath
        }
        return (NSHomeDirectory() as NSString).appendingPathComponent("Desktop")
    }

    public func all() -> [Shot] {
        let dir = location()
        let fm = FileManager.default
        guard let items = try? fm.contentsOfDirectory(atPath: dir) else { return [] }
        var out: [Shot] = []
        for item in items {
            // macOS names captures "Screenshot …" / "Screen Recording …"; also accept the word anywhere.
            guard item.hasPrefix("Screenshot") || item.hasPrefix("Screen Recording")
                    || item.lowercased().contains("screenshot") else { continue }
            let path = (dir as NSString).appendingPathComponent(item)
            let attrs = try? fm.attributesOfItem(atPath: path)
            let date = (attrs?[.modificationDate] as? Date) ?? .distantPast
            let size = (attrs?[.size] as? Int) ?? 0
            out.append(Shot(path: path, name: (item as NSString).deletingPathExtension, date: date, size: size))
        }
        return out.sorted { $0.date > $1.date }
    }

    public func search(_ query: String) -> [Shot] {
        let q = query.lowercased().trimmingCharacters(in: .whitespaces)
        let items = all()
        return q.isEmpty ? items : items.filter { $0.name.lowercased().contains(q) }
    }
}
