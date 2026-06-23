import AppKit
import ApplicationServices

/// Window management (PLAN.md §2) via the Accessibility API — move/resize the focused window of a
/// target app. The tricky part is the coordinate flip: AX positions are top-left origin with Y
/// growing DOWN, measured from the primary display's top; NSScreen is bottom-left origin, Y up.
public final class WindowManager {
    public enum Action: String {
        case maximize, leftHalf, rightHalf, topHalf, bottomHalf, center
        case topLeft, topRight, bottomLeft, bottomRight
        case leftThird, centerThird, rightThird, leftTwoThirds, rightTwoThirds
    }

    public struct CycleState { let base: Action; let pid: pid_t; let step: Int
        public init(base: Action, pid: pid_t, step: Int) { self.base = base; self.pid = pid; self.step = step } }
    private var cycleState: CycleState?
    private var lastCommandedRect: CGRect?

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

    static func rect(for action: Action, in vf: CGRect) -> CGRect {
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
        case .leftThird: return CGRect(x: x, y: y, width: w / 3, height: h)
        case .centerThird: return CGRect(x: x + w / 3, y: y, width: w / 3, height: h)
        case .rightThird: return CGRect(x: x + 2 * w / 3, y: y, width: w / 3, height: h)
        case .leftTwoThirds: return CGRect(x: x, y: y, width: 2 * w / 3, height: h)
        case .rightTwoThirds: return CGRect(x: x + w / 3, y: y, width: 2 * w / 3, height: h)
        }
    }

    /// The ½→⅔→⅓ sequence a directional command cycles through. Non-cycling actions are single-shot.
    static func cycleSequence(for base: Action) -> [Action] {
        switch base {
        case .leftHalf:  return [.leftHalf,  .leftTwoThirds,  .leftThird]
        case .rightHalf: return [.rightHalf, .rightTwoThirds, .rightThird]
        default:         return [base]
        }
    }
    /// Next cycle index: advance only when cycling is on AND this repeats the same base on the same app
    /// AND the window still sits where we last put it; otherwise restart at 0 (½).
    static func cycleStep(base: Action, last: CycleState?, pid: pid_t, frameMatches: Bool, enabled: Bool) -> Int {
        guard enabled, let last = last, last.base == base, last.pid == pid, frameMatches else { return 0 }
        return (last.step + 1) % cycleSequence(for: base).count
    }
    /// Componentwise frame equality within `tol` points (absorbs AX rounding; far below the ≥w/6 gap between ½/⅔/⅓).
    static func rectsMatch(_ a: CGRect, _ b: CGRect, tol: CGFloat = 6) -> Bool {
        abs(a.minX - b.minX) <= tol && abs(a.minY - b.minY) <= tol && abs(a.width - b.width) <= tol && abs(a.height - b.height) <= tol
    }

    /// Apply `base` to `pid`'s focused window with ½→⅔→⅓ cycling (when `enabled`). Repeating the same
    /// command on the same window advances the cycle; moving the window or switching apps restarts at ½.
    @discardableResult
    public func applyCycling(_ base: Action, pid: pid_t, enabled: Bool) -> Bool {
        guard AXIsProcessTrusted() else { cycleState = nil; lastCommandedRect = nil; return false }
        let app = AXUIElementCreateApplication(pid)
        var winRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(app, kAXFocusedWindowAttribute as CFString, &winRef) == .success,
              let win = winRef, CFGetTypeID(win) == AXUIElementGetTypeID() else { cycleState = nil; lastCommandedRect = nil; return false }
        let window = win as! AXUIElement
        guard let primaryHeight = Self.primaryFullHeight() else { cycleState = nil; lastCommandedRect = nil; return false }
        let current = frame(of: window, primaryHeight: primaryHeight)
        let screen = Self.screen(containing: current) ?? NSScreen.main
        guard let visible = screen?.visibleFrame else { cycleState = nil; lastCommandedRect = nil; return false }

        let matches = lastCommandedRect.map { Self.rectsMatch(current, $0) } ?? false
        let step = Self.cycleStep(base: base, last: cycleState, pid: pid, frameMatches: matches, enabled: enabled)
        let concrete = Self.cycleSequence(for: base)[step]
        let target = Self.rect(for: concrete, in: visible)
        set(window: window, cocoaRect: target, primaryHeight: primaryHeight)
        cycleState = CycleState(base: base, pid: pid, step: step)
        lastCommandedRect = target
        return true
    }
}
