import AppKit
import ApplicationServices

public struct WindowInfo {
    public let id: String
    public let appName: String?, appPath: String?, bundleId: String?
    public let x: Double, y: Double, width: Double, height: Double
    public let desktopId: String
    public let active: Bool, fullScreen: Bool
}
public struct DesktopInfo {
    public let id: String, screenId: String
    public let width: Double, height: Double
    public let active: Bool, fullScreen: Bool
}

/// Window enumeration + move/resize for the extension `WindowManagement` API (WM-2), via Accessibility.
/// Coordinates are AX-native (global top-left, y-down) — the same space Raycast's Window.bounds uses.
/// Lives in InvokeServices (AppKit + ApplicationServices only); the host maps these structs to JSON.
public final class WindowEnumerator {
    public init() {}
    public var hasAccessibility: Bool { AXIsProcessTrusted() }

    // _AXUIElementGetWindow(element, &cgWindowID) — private but the standard, stable window-id source.
    // Resolved once; nil → fall back to a per-element UUID (ids then stable only within a getWindows call).
    private typealias GetWindowFn = @convention(c) (AXUIElement, UnsafeMutablePointer<CGWindowID>) -> AXError
    private static let getWindowFn: GetWindowFn? = {
        guard let h = dlopen(nil, RTLD_NOW), let sym = dlsym(h, "_AXUIElementGetWindow") else { return nil }
        return unsafeBitCast(sym, to: GetWindowFn.self)
    }()
    private var cache: [String: AXUIElement] = [:]   // id → AX window (repopulated each enumeration)

    // MARK: pure helpers (unit-tested)
    public static func desktopId(forCenter c: CGPoint, screens: [(id: String, frame: CGRect)]) -> String {
        screens.first { $0.frame.contains(c) }?.id ?? screens.first?.id ?? "0"
    }
    public static func merged(current: (x: Double, y: Double, w: Double, h: Double),
                              x: Double?, y: Double?, width: Double?, height: Double?) -> (x: Double, y: Double, w: Double, h: Double) {
        (x ?? current.x, y ?? current.y, width ?? current.w, height ?? current.h)
    }
    /// Cocoa frame (y-up, bottom-left) → AX rect (y-down, top-left from the primary display's top).
    public static func axRect(cocoaFrame f: CGRect, primaryHeight: CGFloat) -> CGRect {
        CGRect(x: f.minX, y: primaryHeight - f.maxY, width: f.width, height: f.height)
    }

    // MARK: Screen helpers (WM-4 spec)

    /// Full pixel height of the primary screen (the one at origin), used for Cocoa↔AX coordinate conversion.
    public func primaryFullHeight() -> CGFloat {
        let primary = NSScreen.screens.first { $0.frame.origin == .zero } ?? NSScreen.main
        return primary?.frame.height ?? NSScreen.screens.first?.frame.height ?? 0
    }

    /// Returns the AX-space visible frame of the screen that contains `center`, or of the primary screen
    /// if none matches. AX-space: global top-left origin, y-down.
    public func visibleAX(forCenter center: CGPoint) -> CGRect? {
        let h = primaryFullHeight()
        let screen = NSScreen.screens.first {
            Self.axRect(cocoaFrame: $0.frame, primaryHeight: h).contains(center)
        } ?? (NSScreen.screens.first { $0.frame.origin == .zero } ?? NSScreen.main)
        guard let s = screen else { return nil }
        return Self.axRect(cocoaFrame: s.visibleFrame, primaryHeight: h)
    }

    // MARK: Placement engine (pure statics + AX apply)

    public static func placementRect(_ p: WindowPlacement, currentSize cur: CGSize, visibleAX V: CGRect) -> CGRect {
        let w: CGFloat = { if case .points(let v) = p.width { return CGFloat(v) } else { return cur.width } }()
        let h: CGFloat = { if case .points(let v) = p.height { return CGFloat(v) } else { return cur.height } }()
        let xs = [V.minX, V.minX + (V.width - w) / 2, V.maxX - w]
        let ys = [V.minY, V.minY + (V.height - h) / 2, V.maxY - h]
        return CGRect(x: xs[p.anchor.col] + CGFloat(p.offsetX), y: ys[p.anchor.row] + CGFloat(p.offsetY), width: w, height: h)
    }
    public static func serializePlacement(_ p: WindowPlacement) -> String {
        func s(_ z: Sizing) -> String { if case .points(let v) = z { return String(v) } else { return "Auto" } }
        return "\(p.anchor.rawValue);\(s(p.width));\(s(p.height));\(p.offsetX);\(p.offsetY)"
    }
    public static func parsePlacement(_ str: String) -> WindowPlacement? {
        let parts = str.split(separator: ";", omittingEmptySubsequences: false).map(String.init)
        guard parts.count == 5, let a = Int(parts[0]), let anchor = Anchor(rawValue: a) else { return nil }
        func z(_ s: String) -> Sizing { s.lowercased() == "auto" ? .auto : (Double(s).map { Sizing.points($0) } ?? .auto) }
        return WindowPlacement(anchor: anchor, width: z(parts[1]), height: z(parts[2]), offsetX: Double(parts[3]) ?? 0, offsetY: Double(parts[4]) ?? 0)
    }
    private func currentSize(_ win: AXUIElement) -> CGSize {
        if let s = axDouble(win, kAXSizeAttribute as String, .cgSize) { return CGSize(width: s.0, height: s.1) }
        return .zero
    }
    @discardableResult
    public func applyPlacement(_ p: WindowPlacement, toWindow win: AXUIElement) -> Bool {
        guard let pos = axDouble(win, kAXPositionAttribute as String, .cgPoint),
              let sz = axDouble(win, kAXSizeAttribute as String, .cgSize),
              let sv = visibleAX(forCenter: CGPoint(x: pos.0 + sz.0 / 2, y: pos.1 + sz.1 / 2)) else { return false }
        let target = Self.placementRect(p, currentSize: CGSize(width: sz.0, height: sz.1), visibleAX: sv)
        var newSize = CGSize(width: target.width, height: target.height)
        var newPos = CGPoint(x: target.minX, y: target.minY)
        if let v = AXValueCreate(.cgSize, &newSize) { AXUIElementSetAttributeValue(win, kAXSizeAttribute as CFString, v) }
        if let v = AXValueCreate(.cgPoint, &newPos) { AXUIElementSetAttributeValue(win, kAXPositionAttribute as CFString, v) }
        if let v = AXValueCreate(.cgSize, &newSize) { AXUIElementSetAttributeValue(win, kAXSizeAttribute as CFString, v) }
        return true
    }
    @discardableResult
    public func applyPlacementToFocused(_ p: WindowPlacement) -> Bool {
        guard hasAccessibility, let front = NSWorkspace.shared.frontmostApplication, let win = focusedWindow(ofPid: front.processIdentifier) else { return false }
        return applyPlacement(p, toWindow: win)
    }
    @discardableResult
    public func applyLayout(_ items: [(bundleId: String, placement: WindowPlacement)]) -> Int {
        guard hasAccessibility else { return 0 }
        var n = 0
        for item in items {
            guard let app = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == item.bundleId }) else { continue }
            let axApp = AXUIElementCreateApplication(app.processIdentifier)
            var ref: CFTypeRef?
            var win: AXUIElement?
            if AXUIElementCopyAttributeValue(axApp, kAXMainWindowAttribute as CFString, &ref) == .success, let r = ref, CFGetTypeID(r) == AXUIElementGetTypeID() { win = (r as! AXUIElement) }
            else { var ws: CFTypeRef?; if AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &ws) == .success, let arr = ws as? [AXUIElement], let f = arr.first { win = f } }
            if let window = win, applyPlacement(item.placement, toWindow: window) { n += 1 }
        }
        return n
    }

    // MARK: AX plumbing
    private func axId(_ win: AXUIElement) -> String {
        var wid = CGWindowID(0)
        if let fn = Self.getWindowFn, fn(win, &wid) == .success { return String(wid) }
        return UUID().uuidString
    }
    private func axDouble(_ el: AXUIElement, _ attr: String, _ type: AXValueType) -> (CGFloat, CGFloat)? {
        var ref: CFTypeRef?
        guard AXUIElementCopyAttributeValue(el, attr as CFString, &ref) == .success, let ref,
              CFGetTypeID(ref) == AXValueGetTypeID() else { return nil }
        if type == .cgPoint { var p = CGPoint.zero; AXValueGetValue(ref as! AXValue, .cgPoint, &p); return (p.x, p.y) }
        var s = CGSize.zero; AXValueGetValue(ref as! AXValue, .cgSize, &s); return (s.width, s.height)
    }
    private func boolAttr(_ el: AXUIElement, _ attr: String) -> Bool {
        var ref: CFTypeRef?
        guard AXUIElementCopyAttributeValue(el, attr as CFString, &ref) == .success else { return false }
        return (ref as? Bool) ?? false
    }
    private func screenTuples() -> [(id: String, frame: CGRect)] {
        let primary = NSScreen.screens.first { $0.frame.origin == .zero } ?? NSScreen.screens.first
        let primaryHeight = primary.map { $0.frame.height } ?? 0
        return NSScreen.screens.map { s in
            let n = (s.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.stringValue ?? "0"
            return (id: n, frame: Self.axRect(cocoaFrame: s.frame, primaryHeight: primaryHeight))
        }
    }
    private func info(for win: AXUIElement, pid: pid_t, app: NSRunningApplication?, frontFocused: AXUIElement?) -> WindowInfo? {
        guard let pos = axDouble(win, kAXPositionAttribute as String, .cgPoint),
              let sz  = axDouble(win, kAXSizeAttribute as String, .cgSize) else { return nil }
        let id = axId(win); cache[id] = win
        let center = CGPoint(x: pos.0 + sz.0 / 2, y: pos.1 + sz.1 / 2)
        let desktop = Self.desktopId(forCenter: center, screens: screenTuples())
        let isActive = frontFocused != nil && CFEqual(frontFocused!, win)
        return WindowInfo(id: id, appName: app?.localizedName, appPath: app?.bundleURL?.path, bundleId: app?.bundleIdentifier,
                          x: Double(pos.0), y: Double(pos.1), width: Double(sz.0), height: Double(sz.1),
                          desktopId: desktop, active: isActive, fullScreen: boolAttr(win, "AXFullScreen"))
    }
    private func focusedWindow(ofPid pid: pid_t) -> AXUIElement? {
        let app = AXUIElementCreateApplication(pid)
        var ref: CFTypeRef?
        guard AXUIElementCopyAttributeValue(app, kAXFocusedWindowAttribute as CFString, &ref) == .success,
              let ref, CFGetTypeID(ref) == AXUIElementGetTypeID() else { return nil }
        return (ref as! AXUIElement)
    }

    // MARK: API ops
    public func activeWindow() -> WindowInfo? {
        guard hasAccessibility, let front = NSWorkspace.shared.frontmostApplication else { return nil }
        let pid = front.processIdentifier
        guard let win = focusedWindow(ofPid: pid) else { return nil }
        return info(for: win, pid: pid, app: front, frontFocused: win)
    }
    public func windowsOnActiveDesktop() -> [WindowInfo] {
        guard hasAccessibility else { return [] }
        let frontPid = NSWorkspace.shared.frontmostApplication?.processIdentifier
        let frontFocused = frontPid.flatMap { focusedWindow(ofPid: $0) }
        var out: [WindowInfo] = []
        for app in NSWorkspace.shared.runningApplications where app.activationPolicy == .regular {
            let pid = app.processIdentifier
            let axApp = AXUIElementCreateApplication(pid)
            var winsRef: CFTypeRef?
            guard AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &winsRef) == .success,
                  let arr = winsRef as? [AXUIElement] else { continue }
            for win in arr {
                if boolAttr(win, kAXMinimizedAttribute as String) { continue }
                if let i = info(for: win, pid: pid, app: app, frontFocused: frontFocused) { out.append(i) }
            }
        }
        return out
    }
    public func desktops() -> [DesktopInfo] {
        let activeScreenId = (NSWorkspace.shared.frontmostApplication?.processIdentifier)
            .flatMap { focusedWindow(ofPid: $0) }
            .flatMap { w -> String? in
                guard let p = axDouble(w, kAXPositionAttribute as String, .cgPoint),
                      let s = axDouble(w, kAXSizeAttribute as String, .cgSize) else { return nil }
                return Self.desktopId(forCenter: CGPoint(x: p.0 + s.0/2, y: p.1 + s.1/2), screens: screenTuples())
            }
        let mainId = (NSScreen.main?.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.stringValue
        return screenTuples().map { s in
            DesktopInfo(id: s.id, screenId: s.id, width: Double(s.frame.width), height: Double(s.frame.height),
                        active: s.id == (activeScreenId ?? mainId),
                        fullScreen: false) // intentional: no public per-display fullscreen-state API; per-window fullScreen lives on WindowInfo
        }
    }
    public func setBounds(id: String, x: Double?, y: Double?, width: Double?, height: Double?) -> WindowInfo? {
        guard hasAccessibility, let win = cache[id] else { return nil }
        guard let pos = axDouble(win, kAXPositionAttribute as String, .cgPoint),
              let sz  = axDouble(win, kAXSizeAttribute as String, .cgSize) else { return nil }
        let m = Self.merged(current: (Double(pos.0), Double(pos.1), Double(sz.0), Double(sz.1)), x: x, y: y, width: width, height: height)
        var newSize = CGSize(width: m.w, height: m.h)
        var newPos = CGPoint(x: m.x, y: m.y)
        // size → pos → size (apps clamp size against old pos first) — same ordering as WindowManager.set.
        if let v = AXValueCreate(.cgSize, &newSize) { AXUIElementSetAttributeValue(win, kAXSizeAttribute as CFString, v) }
        if let v = AXValueCreate(.cgPoint, &newPos) { AXUIElementSetAttributeValue(win, kAXPositionAttribute as CFString, v) }
        if let v = AXValueCreate(.cgSize, &newSize) { AXUIElementSetAttributeValue(win, kAXSizeAttribute as CFString, v) }
        var pid: pid_t = 0
        AXUIElementGetPid(win, &pid)
        return info(for: win, pid: pid, app: NSRunningApplication(processIdentifier: pid), frontFocused: nil)
    }
}
