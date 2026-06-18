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
    public let frame: Int?      // mutations: the navigation frame the ops belong to (0 = base)
    public let depth: Int?      // nav: active navigation depth (0 = base, N = N pushed views)
    public let level: String?   // log: "info" | "warn" | "error"
    public let args: [JSONValue]? // log: the console args
    public let result: JSONValue? // aiToolResult: the tool's JSON result
    public let error: String?     // aiToolResult: an error message (if the tool threw)
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
    /// Esc on a pushed view — ask the child to pop the top navigation frame.
    public static func navPop() -> ChildBound {
        ChildBound(kind: "navPop", text: nil, handler: nil, args: nil)
    }
}
