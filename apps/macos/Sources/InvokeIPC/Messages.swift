import Foundation

/// Swift mirror of the @invoke/schema render mutations (PLAN.md §4.5).
/// Decoded leniently from the discriminated-union JSON the runtime emits.
public struct Mutation: Codable {
    public let op: String
    public let id: Int?
    public let type: String?
    public let text: String?
    public let parent: Int?
    public let child: Int?
    public let before: Int?
    public let props: [String: JSONValue]?
}

/// child → host envelope.
public struct HostBound: Codable {
    public let kind: String
    public let command: String?
    public let commit: Int?
    public let ops: [Mutation]?
    public let id: Int?
    public let method: String?
    public let params: JSONValue?
    public let module: String?  // sandboxDenial: the denied Node built-in
}

/// host → child envelope.
public struct ChildBound: Codable {
    public let kind: String
    public var text: String?
    public var handler: String?
    public var args: [JSONValue]?

    public static func searchText(_ t: String) -> ChildBound {
        ChildBound(kind: "searchText", text: t, handler: nil, args: nil)
    }
    /// `args` defaults to `[]` so the child's `fn(...args)` spread never throws on undefined.
    public static func invoke(_ h: String, _ args: [JSONValue] = []) -> ChildBound {
        ChildBound(kind: "invoke", text: nil, handler: h, args: args)
    }
}
