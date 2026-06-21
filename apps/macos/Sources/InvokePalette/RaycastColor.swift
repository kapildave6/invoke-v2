import AppKit

/// Pure mappings for the accessory renderer. Imports ONLY AppKit/Foundation (no project types) so it
/// compiles in a standalone `swift` script for unit testing. The JSONValue dispatch (named/hex/dynamic
/// {light,dark}) lives in PaletteView and calls these.
enum RaycastColor {
    /// Raycast's named Color set (packages/api `Color`) → an adaptive NSColor. nil if unknown.
    static func colorFromNamed(_ name: String) -> NSColor? {
        switch name {
        case "red": return .systemRed
        case "green": return .systemGreen
        case "blue": return .systemBlue
        case "yellow": return .systemYellow
        case "orange": return .systemOrange
        case "purple": return .systemPurple
        case "magenta": return .systemPink
        case "primary-text": return .labelColor
        case "secondary-text": return .secondaryLabelColor
        default: return nil
        }
    }

    /// #RGB / #RRGGBB / #RRGGBBAA (case-insensitive, leading # optional). nil if malformed.
    static func colorFromHex(_ hex: String) -> NSColor? {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard !s.isEmpty, s.allSatisfy({ $0.isHexDigit }) else { return nil }
        if s.count == 3 { s = s.map { "\($0)\($0)" }.joined() } // #RGB → #RRGGBB
        guard s.count == 6 || s.count == 8, let v = UInt64(s, radix: 16) else { return nil }
        let r, g, b, a: CGFloat
        if s.count == 8 {
            r = CGFloat((v >> 24) & 0xFF) / 255; g = CGFloat((v >> 16) & 0xFF) / 255
            b = CGFloat((v >> 8) & 0xFF) / 255;  a = CGFloat(v & 0xFF) / 255
        } else {
            r = CGFloat((v >> 16) & 0xFF) / 255; g = CGFloat((v >> 8) & 0xFF) / 255
            b = CGFloat(v & 0xFF) / 255;         a = 1
        }
        return NSColor(srgbRed: r, green: g, blue: b, alpha: a)
    }

    /// Compact relative date matching Raycast's accessory style: "now", "<n>m/h/d/w/mo/y";
    /// future is prefixed "in ". Past has no suffix.
    static func compactRelative(_ date: Date, now: Date = Date()) -> String {
        let secs = date.timeIntervalSince(now)
        let past = secs <= 0
        let a = abs(secs)
        let n: Int; let unit: String
        switch a {
        case ..<45:          n = max(Int(a), 0);     unit = "s"
        case ..<3600:        n = Int(a / 60);        unit = "m"
        case ..<86_400:      n = Int(a / 3600);      unit = "h"
        case ..<604_800:     n = Int(a / 86_400);    unit = "d"
        case ..<2_592_000:   n = Int(a / 604_800);   unit = "w"
        case ..<31_536_000:  n = Int(a / 2_592_000); unit = "mo"
        default:             n = Int(a / 31_536_000); unit = "y"
        }
        if unit == "s" && n < 5 { return "now" }
        let body = "\(n)\(unit)"
        return past ? body : "in \(body)"
    }

    private static let isoFrac: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]; return f
    }()
    private static let isoPlain: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime]; return f
    }()
    /// Parse a JS Date's wire form (ISO-8601, usually with fractional seconds + Z). nil if unparseable.
    static func parseISODate(_ s: String) -> Date? { isoFrac.date(from: s) ?? isoPlain.date(from: s) }
}
