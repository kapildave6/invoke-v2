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

    // MARK: AX plumbing
    private func axId(_ win: AXUIElement) -> String {
        var wid = CGWindowID(0)
        if let fn = Self.getWindowFn, fn(win, &wid) == .success { return String(wid) }
        return UUID().uuidString
    }
    private func axDouble(_ el: AXUIElement, _ attr: String, _ type: AXValueType) -> (CGFloat, CGFloat)? {
        var ref: CFTypeRef?
        guard AXUIElementCopyAttributeValue(el, attr as CFString, &ref) == .success, let ref else { return nil }
        if type == .cgPoint { var p = CGPoint.zero; AXValueGetValue(ref as! AXValue, .cgPoint, &p); return (p.x, p.y) }
        var s = CGSize.zero; AXValueGetValue(ref as! AXValue, .cgSize, &s); return (s.width, s.height)
    }
    private func boolAttr(_ el: AXUIElement, _ attr: String) -> Bool {
        var ref: CFTypeRef?
        guard AXUIElementCopyAttributeValue(el, attr as CFString, &ref) == .success else { return false }
        return (ref as? Bool) ?? false
    }
    private func screenTuples() -> [(id: String, frame: CGRect)] {
        NSScreen.screens.map { s in
            let n = (s.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.stringValue ?? "0"
            return (id: n, frame: s.frame)
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
                        active: s.id == (activeScreenId ?? mainId), fullScreen: false)
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
        let pid = NSWorkspace.shared.runningApplications.first {
            let a = AXUIElementCreateApplication($0.processIdentifier); var f: CFTypeRef?
            return AXUIElementCopyAttributeValue(a, kAXFocusedWindowAttribute as CFString, &f) == .success
        }?.processIdentifier ?? 0
        return info(for: win, pid: pid, app: NSRunningApplication(processIdentifier: pid), frontFocused: nil)
    }
}
