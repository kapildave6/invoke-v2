import Combine
import Foundation

/// A saved text snippet (PLAN.md §2 first-party features). `keyword` is an optional short trigger
/// shown as a chip and matched in search; `content` is the text pasted on activation.
public struct Snippet: Codable, Identifiable, Equatable {
    public var id: String
    public var name: String
    public var keyword: String
    public var content: String
    public init(id: String = UUID().uuidString, name: String = "", keyword: String = "", content: String = "") {
        self.id = id
        self.name = name
        self.keyword = keyword
        self.content = content
    }
}

/// Persistent snippet store (UserDefaults JSON for now; the encrypted store is PLAN §3.4). Shared by
/// the Settings CRUD UI and the palette's "Search Snippets" mode. ObservableObject so SwiftUI reacts.
public final class SnippetStore: ObservableObject {
    public static let shared = SnippetStore()
    @Published public private(set) var snippets: [Snippet] = []
    private let key = "invoke.snippets.v1"

    private init() { load() }

    public func search(_ q: String) -> [Snippet] {
        let t = q.trimmingCharacters(in: .whitespaces).lowercased()
        guard !t.isEmpty else { return snippets }
        return snippets.filter {
            $0.name.lowercased().contains(t) || $0.keyword.lowercased().contains(t) || $0.content.lowercased().contains(t)
        }
    }

    public func snippet(id: String) -> Snippet? { snippets.first { $0.id == id } }

    @discardableResult
    public func add(_ snippet: Snippet = Snippet(name: "New Snippet")) -> Snippet {
        snippets.append(snippet)
        save()
        return snippet
    }

    public func update(_ snippet: Snippet) {
        guard let i = snippets.firstIndex(where: { $0.id == snippet.id }) else { return }
        snippets[i] = snippet
        save()
    }

    public func delete(id: String) {
        snippets.removeAll { $0.id == id }
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Snippet].self, from: data) else { return }
        snippets = decoded
    }

    private func save() {
        if let data = try? JSONEncoder().encode(snippets) { UserDefaults.standard.set(data, forKey: key) }
    }
}
