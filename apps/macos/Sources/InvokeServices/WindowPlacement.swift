import CoreGraphics

public enum Sizing: Codable, Equatable { case auto; case points(Double) }
public enum Anchor: Int, Codable, Equatable {
    case topLeft = 0, top, topRight, left, center, right, bottomLeft, bottom, bottomRight
    public var col: Int { rawValue % 3 }   // 0 left, 1 center, 2 right
    public var row: Int { rawValue / 3 }   // 0 top, 1 middle, 2 bottom
}
public struct WindowPlacement: Codable, Equatable {
    public var anchor: Anchor
    public var width: Sizing, height: Sizing
    public var offsetX: Double, offsetY: Double
    public init(anchor: Anchor, width: Sizing, height: Sizing, offsetX: Double, offsetY: Double) {
        self.anchor = anchor; self.width = width; self.height = height; self.offsetX = offsetX; self.offsetY = offsetY
    }
    public static var `default`: WindowPlacement { .init(anchor: .center, width: .auto, height: .auto, offsetX: 0, offsetY: 0) }
}
