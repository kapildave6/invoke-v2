import AppKit
import ApplicationServices

/// Window management (PLAN.md §2) via the Accessibility API — move/resize the focused window of a
/// target app. The tricky part is the coordinate flip: AX positions are top-left origin with Y
/// growing DOWN, measured from the primary display's top; NSScreen is bottom-left origin, Y up.
public final class WindowManager {
    public enum Action: String {
        case maximize, leftHalf, rightHalf, topHalf, bottomHalf, center
        case topLeft, topRight, bottomLeft, bottomRight
    }

    public init() {}

    /// Apply `action` to `pid`'s focused window. Returns false if Accessibility isn't granted or
    /// the app has no focused window.
    @discardableResult
    public func apply(_ action: Action, pid: pid_t) -> Bool {
        guard AXIsProcessTrusted() else { return false }
        let app = AXUIElementCreateApplication(pid)
        var winRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(app, kAXFocusedWindowAttribute as CFString, &winRef) == .success,
              let win = winRef, CFGetTypeID(win) == AXUIElementGetTypeID() else { return false }
        let window = win as! AXUIElement

        guard let primaryHeight = Self.primaryFullHeight() else { return false }
        let current = frame(of: window, primaryHeight: primaryHeight)
        let screen = Self.screen(containing: current) ?? NSScreen.main
        guard let visible = screen?.visibleFrame else { return false }
        set(window: window, cocoaRect: Self.rect(for: action, in: visible), primaryHeight: primaryHeight)
        return true
    }

    // MARK: - AX frame read/write

    private func frame(of window: AXUIElement, primaryHeight: CGFloat) -> CGRect {
        var posRef: CFTypeRef?
        var sizeRef: CFTypeRef?
        AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &posRef)
        AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeRef)
        var pos = CGPoint.zero
        var size = CGSize.zero
        if let posRef { AXValueGetValue(posRef as! AXValue, .cgPoint, &pos) }
        if let sizeRef { AXValueGetValue(sizeRef as! AXValue, .cgSize, &size) }
        // AX (top-left, y-down) → Cocoa (bottom-left, y-up).
        return CGRect(x: pos.x, y: primaryHeight - pos.y - size.height, width: size.width, height: size.height)
    }

    private func set(window: AXUIElement, cocoaRect: CGRect, primaryHeight: CGFloat) {
        var pos = CGPoint(x: cocoaRect.minX, y: primaryHeight - cocoaRect.minY - cocoaRect.height)
        var size = CGSize(width: cocoaRect.width, height: cocoaRect.height)
        // Set size → position → size: some apps clamp size against the old position first.
        if let v = AXValueCreate(.cgSize, &size) { AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, v) }
        if let v = AXValueCreate(.cgPoint, &pos) { AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, v) }
        if let v = AXValueCreate(.cgSize, &size) { AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, v) }
    }

    // MARK: - Geometry

    private static func primaryFullHeight() -> CGFloat? {
        (NSScreen.screens.first { $0.frame.origin == .zero } ?? NSScreen.screens.first)?.frame.height
    }

    private static func screen(containing cocoaRect: CGRect) -> NSScreen? {
        let center = CGPoint(x: cocoaRect.midX, y: cocoaRect.midY)
        return NSScreen.screens.first { $0.frame.contains(center) }
    }

    private static func rect(for action: Action, in vf: CGRect) -> CGRect {
        let (x, y, w, h) = (vf.minX, vf.minY, vf.width, vf.height)
        switch action {
        case .maximize: return vf
        case .leftHalf: return CGRect(x: x, y: y, width: w / 2, height: h)
        case .rightHalf: return CGRect(x: x + w / 2, y: y, width: w / 2, height: h)
        case .topHalf: return CGRect(x: x, y: y + h / 2, width: w, height: h / 2)
        case .bottomHalf: return CGRect(x: x, y: y, width: w, height: h / 2)
        case .center: return CGRect(x: x + w * 0.15, y: y + h * 0.12, width: w * 0.7, height: h * 0.76)
        case .topLeft: return CGRect(x: x, y: y + h / 2, width: w / 2, height: h / 2)
        case .topRight: return CGRect(x: x + w / 2, y: y + h / 2, width: w / 2, height: h / 2)
        case .bottomLeft: return CGRect(x: x, y: y, width: w / 2, height: h / 2)
        case .bottomRight: return CGRect(x: x + w / 2, y: y, width: w / 2, height: h / 2)
        }
    }
}
