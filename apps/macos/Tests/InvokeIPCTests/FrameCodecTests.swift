import XCTest
@testable import InvokeIPC
@testable import InvokeRenderer

final class FrameCodecTests: XCTestCase {
    func testFrameRoundTrip() throws {
        let payload = Data(#"{"kind":"ready","command":"list"}"#.utf8)
        let framed = FrameCodec.encode(payload)
        XCTAssertEqual(framed.count, 4 + payload.count)

        let decoder = FrameDecoder()
        // Split across two chunks to exercise the streaming decoder.
        let mid = framed.count / 2
        var out = decoder.push(framed.prefix(mid))
        XCTAssertTrue(out.isEmpty)
        out += decoder.push(framed.suffix(from: framed.startIndex.advanced(by: mid)))
        XCTAssertEqual(out.count, 1)
        XCTAssertEqual(out.first, payload)
    }

    func testApplyMutationsBuildsTree() throws {
        let json = """
        [
          {"op":"createInstance","id":1,"type":"list-item","props":{"title":"Apple"}},
          {"op":"createInstance","id":2,"type":"list","props":{}},
          {"op":"appendChild","parent":2,"child":1},
          {"op":"clearContainer"},
          {"op":"appendChild","parent":0,"child":2}
        ]
        """
        let ops = try JSONDecoder().decode([Mutation].self, from: Data(json.utf8))
        let tree = ViewTree()
        tree.apply(ops)
        XCTAssertEqual(tree.root.children.count, 1)
        XCTAssertEqual(tree.root.children.first?.type, "list")
        XCTAssertEqual(tree.root.children.first?.children.first?.title, "Apple")
    }
}
