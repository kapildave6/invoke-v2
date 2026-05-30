import Foundation

/// Length-prefixed framing (PLAN.md §4.6): 4-byte big-endian length + UTF-8 JSON.
/// The exact wire format used by @invoke/schema on the TS side.
public enum FrameCodec {
    public static let maxFrameBytes = 16 * 1024 * 1024

    public static func encode(_ body: Data) -> Data {
        precondition(body.count <= maxFrameBytes, "frame too large — move binaries out-of-band")
        let len = UInt32(body.count)
        var out = Data(capacity: 4 + body.count)
        out.append(UInt8((len >> 24) & 0xFF))
        out.append(UInt8((len >> 16) & 0xFF))
        out.append(UInt8((len >> 8) & 0xFF))
        out.append(UInt8(len & 0xFF))
        out.append(body)
        return out
    }
}

/// Stateful decoder: feed it chunks, get back whole message bodies.
public final class FrameDecoder {
    private var buffer = Data()
    public init() {}

    public func push(_ chunk: Data) -> [Data] {
        buffer.append(chunk)
        var frames: [Data] = []
        while buffer.count >= 4 {
            let header = [UInt8](buffer.prefix(4))
            let len = (Int(header[0]) << 24) | (Int(header[1]) << 16) | (Int(header[2]) << 8) | Int(header[3])
            if buffer.count < 4 + len { break }
            let start = buffer.index(buffer.startIndex, offsetBy: 4)
            let end = buffer.index(start, offsetBy: len)
            frames.append(Data(buffer[start..<end]))
            buffer.removeSubrange(buffer.startIndex..<end)
        }
        return frames
    }
}
