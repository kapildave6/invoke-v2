import Foundation

/// A minimal JSON value so serialized props (PLAN.md §4.5) round-trip without a
/// concrete schema per component. Mirrors `SerializedProps` on the TS side.
public enum JSONValue: Codable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case null
    case array([JSONValue])
    case object([String: JSONValue])

    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { self = .null; return }
        if let b = try? c.decode(Bool.self) { self = .bool(b); return }
        if let n = try? c.decode(Double.self) { self = .number(n); return }
        if let s = try? c.decode(String.self) { self = .string(s); return }
        if let a = try? c.decode([JSONValue].self) { self = .array(a); return }
        if let o = try? c.decode([String: JSONValue].self) { self = .object(o); return }
        throw DecodingError.dataCorruptedError(in: c, debugDescription: "unsupported JSON value")
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .string(let s): try c.encode(s)
        case .number(let n): try c.encode(n)
        case .bool(let b): try c.encode(b)
        case .null: try c.encodeNil()
        case .array(let a): try c.encode(a)
        case .object(let o): try c.encode(o)
        }
    }

    public var stringValue: String? {
        if case .string(let s) = self { return s }
        return nil
    }

    public var doubleValue: Double? {
        if case .number(let n) = self { return n }
        if case .string(let s) = self { return Double(s) } // token endpoints sometimes return numbers as strings
        return nil
    }

    /// A readable rendering of any JSON value (for logging non-string console args).
    public var debugString: String {
        switch self {
        case .string(let s): return s
        case .number(let n): return n == n.rounded() ? String(Int(n)) : String(n)
        case .bool(let b): return b ? "true" : "false"
        case .null: return "null"
        case .array(let a): return "[" + a.map { $0.debugString }.joined(separator: ", ") + "]"
        case .object(let o): return "{" + o.map { "\($0): \($1.debugString)" }.joined(separator: ", ") + "}"
        }
    }

    /// Resolve a handler reference `{ "__handler": "h3" }` (PLAN.md §4.4).
    public var handlerRef: String? {
        if case .object(let o) = self, case .string(let h)? = o["__handler"] { return h }
        return nil
    }
}
