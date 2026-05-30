import Foundation
import InvokeIPC

/// The native side of the render-mutation stream (PLAN.md §4.5/§4.7). Applies the
/// same mutations the Node demo applies, but here these view models bind to AppKit
/// widgets (InvokePalette). Decoupling view models from concrete widgets lets the
/// wire format evolve without rewriting view code.
public final class ViewNode {
    public let id: Int
    public var type: String
    public var text: String?
    public var props: [String: JSONValue]
    public var children: [ViewNode] = []

    public init(id: Int, type: String, text: String? = nil, props: [String: JSONValue] = [:]) {
        self.id = id
        self.type = type
        self.text = text
        self.props = props
    }

    public var title: String? { props["title"]?.stringValue ?? text }
}

public final class ViewTree {
    public let root = ViewNode(id: 0, type: "#root")
    private var index: [Int: ViewNode] = [:]

    public init() { index[0] = root }

    public func apply(_ ops: [Mutation]) {
        for op in ops {
            switch op.op {
            case "clearContainer":
                root.children = []
            case "createInstance":
                if let id = op.id, let type = op.type {
                    index[id] = ViewNode(id: id, type: type, props: op.props ?? [:])
                }
            case "createText":
                if let id = op.id {
                    index[id] = ViewNode(id: id, type: "", text: op.text)
                }
            case "appendChild":
                if let p = index[op.parent ?? -1], let c = index[op.child ?? -1] { p.children.append(c) }
            case "insertBefore":
                if let p = index[op.parent ?? -1], let c = index[op.child ?? -1] {
                    if let b = index[op.before ?? -1], let at = p.children.firstIndex(where: { $0 === b }) {
                        p.children.insert(c, at: at)
                    } else {
                        p.children.append(c)
                    }
                }
            case "removeChild":
                if let p = index[op.parent ?? -1] { p.children.removeAll { $0 === index[op.child ?? -1] } }
            case "updateProps":
                if let id = op.id, let n = index[id] { n.props = op.props ?? [:] }
            case "updateText":
                if let id = op.id, let n = index[id] { n.text = op.text }
            default:
                break
            }
        }
    }

    public func describe() -> String {
        func walk(_ n: ViewNode, _ depth: Int) -> String {
            let pad = String(repeating: "  ", count: depth)
            let label = n.type.isEmpty ? "\"\(n.text ?? "")\"" : "\(n.type)\(n.title.map { " \"\($0)\"" } ?? "")"
            return ([pad + label] + n.children.map { walk($0, depth + 1) }).joined(separator: "\n")
        }
        return walk(root, 0)
    }
}
