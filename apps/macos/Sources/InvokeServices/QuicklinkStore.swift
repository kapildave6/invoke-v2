import Combine
import Foundation

/// A saved link or search template (PLAN.md §2). `link` may contain a `{query}` (or `{argument}`)
/// placeholder; when present, activating the quicklink prompts for input and substitutes it before
/// opening. A bare host is upgraded to https://.
public struct Quicklink: Codable, Identifiable, Equatable {
    public var id: String
    public var name: String
    public var link: String
    public init(id: String = UUID().uuidString, name: String = "", link: String = "") {
        self.id = id
        self.name = name
        self.link = link
    }

    public var hasArgument: Bool { link.contains("{query}") || link.contains("{argument}") }

    /// Characters safe to leave un-escaped in a substituted query value: alphanumerics + the
    /// RFC-3986 unreserved marks. Everything else (& = + ? / : @ … and space) is escaped, so a typed
    /// argument can't break out of the query component or be mis-decoded (e.g. `+` → space).
    private static let argumentAllowed: CharacterSet = {
        var set = CharacterSet.alphanumerics
        set.insert(charactersIn: "-._~")
        return set
    }()

    /// Resolve to an openable URL, substituting the (escaped) `argument` for the placeholder.
    public func resolvedURL(argument: String = "") -> URL? {
        // Decide the scheme from the TEMPLATE — never the post-substitution string — so an argument
        // containing "://" or ":" can't suppress (or fake) the https upgrade. A bare host → https.
        let template = link.trimmingCharacters(in: .whitespaces)
        let hasScheme = template.contains("://")
            || template.hasPrefix("mailto:")
            || template.hasPrefix("tel:")
            || template.hasPrefix("sms:")
        let base = hasScheme ? template : "https://" + template

        let encoded = argument.addingPercentEncoding(withAllowedCharacters: Self.argumentAllowed) ?? argument
        let s = base
            .replacingOccurrences(of: "{query}", with: encoded)
            .replacingOccurrences(of: "{argument}", with: encoded)
        return URL(string: s)
    }
}

/// Persistent quicklink store (UserDefaults JSON). Shared by Settings CRUD + the palette's
/// "Search Quicklinks" mode.
public final class QuicklinkStore: ObservableObject {
    public static let shared = QuicklinkStore()
    @Published public private(set) var quicklinks: [Quicklink] = []
    private let key = "invoke.quicklinks.v1"

    private init() { load() }

    public func search(_ q: String) -> [Quicklink] {
        let t = q.trimmingCharacters(in: .whitespaces).lowercased()
        guard !t.isEmpty else { return quicklinks }
        return quicklinks.filter { $0.name.lowercased().contains(t) || $0.link.lowercased().contains(t) }
    }

    public func quicklink(id: String) -> Quicklink? { quicklinks.first { $0.id == id } }

    @discardableResult
    public func add(_ quicklink: Quicklink = Quicklink(name: "New Quicklink")) -> Quicklink {
        quicklinks.append(quicklink)
        save()
        return quicklink
    }

    public func update(_ quicklink: Quicklink) {
        guard let i = quicklinks.firstIndex(where: { $0.id == quicklink.id }) else { return }
        quicklinks[i] = quicklink
        save()
    }

    public func delete(id: String) {
        quicklinks.removeAll { $0.id == id }
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Quicklink].self, from: data) else { return }
        quicklinks = decoded
    }

    private func save() {
        if let data = try? JSONEncoder().encode(quicklinks) { UserDefaults.standard.set(data, forKey: key) }
    }
}
