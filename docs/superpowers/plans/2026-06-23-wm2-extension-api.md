# WM-2 — Extension `WindowManagement` API (AX-backed) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Make `@raycast/api` `WindowManagement` (getActiveWindow / getWindowsOnActiveDesktop / setWindowBounds / getDesktops) work via the Accessibility API, so Raycast window-management extensions run.

**Architecture:** A new `WindowEnumerator` in `InvokeServices` does AX enumeration + holds an id→`AXUIElement` cache and returns plain Swift structs (`WindowInfo`/`DesktopInfo`) — no JSONValue/UI deps. `AppController` (InvokeShell) maps those structs to `JSONValue` and serves four async capabilities. The TS side replaces the `unsupported()` stubs with `rpc(...)` calls + faithful Raycast types.

**Tech Stack:** TS (`packages/api`), Swift (`InvokeServices` + `InvokeShell`). Pure logic via standalone `swiftc`; AX via build + relaunch + human visual.

## Global Constraints
- Faithful Raycast shapes (below); commit on `main`; relaunch after build; world-class UX.
- Coordinates: AX-native (global top-left, y-down) — NO Cocoa flip (Raycast `Window.bounds` uses the same space).
- `WindowEnumerator` stays in `InvokeServices`: imports only AppKit + ApplicationServices, NO `InvokeShell`/`AppSettings`/`InvokeIPC`/JSONValue. It returns Swift value structs.
- No Xcode/XCTest → TS via `npx tsc --noEmit` + `tsx`; Swift pure logic via standalone `swiftc`; AX via build + relaunch + human. **Ignore SourceKit false-positives when `swift build` prints `Build complete!`** (e.g. "cannot find BrowserDriver in scope", "'let' binding pattern cannot appear in an expression", stale "has no member" errors).
- AX needs Accessibility: handlers reject (via `fail`) when `!AXIsProcessTrusted()`.

---

### Task 1: TS — real `WindowManagement` API + types

**Files:**
- Modify: `packages/api/src/index.ts` (`WindowManagement` const ~1166; add a namespace merge)
- Test: `<scratch>/wm2-api-test.ts` (`<scratch>` = `/private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad`)

**Interfaces:**
- Consumes: internal `rpc(method, params)`; exported `__setHostBridge`; existing `Application` (`:972`).
- Produces: `WindowManagement.{getActiveWindow,getWindowsOnActiveDesktop,setWindowBounds,getDesktops,DesktopType}` + types `WindowManagement.{Window,Desktop,Bounds,SetWindowBoundsOptions}`.

- [ ] **Step 1: Write the failing tsx test FIRST.** `<scratch>/wm2-api-test.ts` (import from the ABS path):
```ts
import { WindowManagement, __setHostBridge } from "/Users/test/Documents/code/invoke-v2/packages/api/src/index.ts";
const calls: { method: string; params: any }[] = [];
__setHostBridge(async (method: string, params: unknown) => {
  calls.push({ method, params });
  if (method === "windowManagement.getActiveWindow") return { id: "1", bounds: { position: { x: 0, y: 0 }, size: { width: 100, height: 100 } }, desktopId: "d1" };
  if (method === "windowManagement.getWindowsOnActiveDesktop") return [];
  if (method === "windowManagement.getDesktops") return [];
  if (method === "windowManagement.setWindowBounds") return { id: "1", bounds: { position: { x: 20, y: 0 }, size: { width: 100, height: 100 } }, desktopId: "d1" };
  return null;
});
function expect(label: string, cond: boolean) { if (!cond) { console.error("FAIL", label); process.exit(1); } console.log("ok:", label); }
const w = await WindowManagement.getActiveWindow();
expect("getActiveWindow method", calls.at(-1)!.method === "windowManagement.getActiveWindow");
expect("getActiveWindow returns Window", w.id === "1" && w.bounds.size.width === 100);
await WindowManagement.getWindowsOnActiveDesktop();
expect("getWindows method", calls.at(-1)!.method === "windowManagement.getWindowsOnActiveDesktop");
await WindowManagement.getDesktops();
expect("getDesktops method", calls.at(-1)!.method === "windowManagement.getDesktops");
const u = await WindowManagement.setWindowBounds({ id: "1", bounds: { position: { x: 20, y: 0 } } });
expect("setWindowBounds method+params", calls.at(-1)!.method === "windowManagement.setWindowBounds" && calls.at(-1)!.params.id === "1");
expect("setWindowBounds returns updated", u.bounds.position.x === 20);
expect("DesktopType enum", WindowManagement.DesktopType.User === "user" && WindowManagement.DesktopType.FullScreen === "fullScreen");
console.log("ALL PASS");
```

- [ ] **Step 2: Run it to fail.** `cd packages/api && npx tsx <scratch>/wm2-api-test.ts` → FAIL (methods throw `unsupported`; `DesktopType` undefined).

- [ ] **Step 3: Implement.** Replace the `WindowManagement` const (~1166) with:
```ts
// Window management (Raycast's WindowManagement) — AX-backed via the host.
export const WindowManagement = {
  DesktopType: { User: "user", FullScreen: "fullScreen" } as const,
  getActiveWindow: (): Promise<WindowManagement.Window> =>
    rpc("windowManagement.getActiveWindow", {}) as Promise<WindowManagement.Window>,
  getWindowsOnActiveDesktop: (): Promise<WindowManagement.Window[]> =>
    rpc("windowManagement.getWindowsOnActiveDesktop", {}) as Promise<WindowManagement.Window[]>,
  setWindowBounds: (options: WindowManagement.SetWindowBoundsOptions): Promise<WindowManagement.Window> =>
    rpc("windowManagement.setWindowBounds", options) as Promise<WindowManagement.Window>,
  getDesktops: (): Promise<WindowManagement.Desktop[]> =>
    rpc("windowManagement.getDesktops", {}) as Promise<WindowManagement.Desktop[]>,
};
// Namespace merge adds the canonical Raycast types (mirror the Form/Image `export declare namespace` pattern).
export declare namespace WindowManagement {
  export type Bounds = { position: { x: number; y: number }; size: { width: number; height: number } };
  export type DesktopType = "user" | "fullScreen";
  export type Desktop = { id: string; screenId: string; size: { width: number; height: number }; active: boolean; type: DesktopType };
  export type Window = { id: string; application?: Application; bounds: Bounds; desktopId: string; active?: boolean; fullScreen?: boolean };
  export type SetWindowBoundsOptions = { id: string; bounds: Partial<Bounds>; desktopId?: string };
}
```
(`Application` is already imported/defined in this file at `:972`. Keep the `unsupported` helper — it's still used by other stubs. Confirm no OTHER code referenced the old `WindowManagement` shape.)

- [ ] **Step 4: Run the test → ALL PASS.** `cd packages/api && npx tsx <scratch>/wm2-api-test.ts`.

- [ ] **Step 5: typecheck + Commit.** `cd packages/api && npx tsc --noEmit 2>&1 | tail -8` (pre-existing `accessory-demo` error OK; no NEW errors). Then:
```bash
git add packages/api/src/index.ts
git commit -m "feat(wm): real WindowManagement API (rpc-backed) + canonical Window/Desktop/DesktopType types"
```

---

### Task 2: Swift — `WindowEnumerator` (AX enumeration + id cache + pure helpers)

**Files:**
- Create: `apps/macos/Sources/InvokeServices/WindowEnumerator.swift`
- Test: `<scratch>/main.swift` (co-compiled with `WindowEnumerator.swift`)

**Interfaces:**
- Produces:
  - `struct WindowInfo { let id: String; let appName: String?; let appPath: String?; let bundleId: String?; let x: Double; let y: Double; let width: Double; let height: Double; let desktopId: String; let active: Bool; let fullScreen: Bool }`
  - `struct DesktopInfo { let id: String; let screenId: String; let width: Double; let height: Double; let active: Bool; let fullScreen: Bool }`
  - `class WindowEnumerator` with `init()`, `var hasAccessibility: Bool`, `func activeWindow() -> WindowInfo?`, `func windowsOnActiveDesktop() -> [WindowInfo]`, `func desktops() -> [DesktopInfo]`, `func setBounds(id: String, x: Double?, y: Double?, width: Double?, height: Double?) -> WindowInfo?`
  - pure statics: `static func desktopId(forCenter: CGPoint, screens: [(id: String, frame: CGRect)]) -> String`, `static func merged(current: (x: Double, y: Double, w: Double, h: Double), x: Double?, y: Double?, width: Double?, height: Double?) -> (x: Double, y: Double, w: Double, h: Double)`

- [ ] **Step 1: Write the failing test FIRST (pure helpers).** `<scratch>/main.swift`:
```swift
import AppKit
func ck(_ c: Bool, _ l: String) { if !c { print("FAIL", l); exit(1) }; print("ok:", l) }
let screens: [(id: String, frame: CGRect)] = [("A", CGRect(x: 0, y: 0, width: 1000, height: 800)), ("B", CGRect(x: 1000, y: 0, width: 1000, height: 800))]
ck(WindowEnumerator.desktopId(forCenter: CGPoint(x: 500, y: 400), screens: screens) == "A", "center-in-A")
ck(WindowEnumerator.desktopId(forCenter: CGPoint(x: 1500, y: 400), screens: screens) == "B", "center-in-B")
ck(WindowEnumerator.desktopId(forCenter: CGPoint(x: 9999, y: 9999), screens: screens) == "A", "offscreen→first")
let m1 = WindowEnumerator.merged(current: (10, 20, 300, 400), x: 50, y: nil, width: nil, height: nil)
ck(m1.x == 50 && m1.y == 20 && m1.w == 300 && m1.h == 400, "merge-x-only")
let m2 = WindowEnumerator.merged(current: (10, 20, 300, 400), x: nil, y: nil, width: 800, height: 600)
ck(m2.x == 10 && m2.y == 20 && m2.w == 800 && m2.h == 600, "merge-size-only")
print("ALL PASS")
```

- [ ] **Step 2: Run it to fail.** `cd <scratch> && swiftc /Users/test/Documents/code/invoke-v2/apps/macos/Sources/InvokeServices/WindowEnumerator.swift main.swift -o wm2test && ./wm2test` → FAIL (file/symbols absent). (If linking complains, append `-framework AppKit -framework ApplicationServices`.)

- [ ] **Step 3: Implement `WindowEnumerator.swift`.** Create the file:
```swift
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
```

- [ ] **Step 4: Run the test → ALL PASS.** `cd <scratch> && swiftc /Users/test/Documents/code/invoke-v2/apps/macos/Sources/InvokeServices/WindowEnumerator.swift main.swift -o wm2test && ./wm2test`.

- [ ] **Step 5: Build + Commit.** `swift build --package-path apps/macos 2>&1 | tail -3` → `Build complete!`. Then:
```bash
git add apps/macos/Sources/InvokeServices/WindowEnumerator.swift
git commit -m "feat(wm): WindowEnumerator — AX window enumeration + id cache + bounds set (InvokeServices)"
```

---

### Task 3: Host capability wiring + fixture + verify

**Files:**
- Modify: `apps/macos/Sources/InvokeShell/AppController.swift` (a `windowEnumerator` instance near `windowManager` ~25; four cases in `handleAsyncCapability` ~1936)
- Modify: `runtime/node-host/src/supervisor.ts` (ALLOWED set ~78)
- Modify: `apps/macos/Sources/InvokeShell/ExtensionHost.swift` (allow-list ~85)
- Modify: `runtime/node-host/src/run.ts` (dev stub — benign empties)
- Create: `examples/window-management-demo/{package.json,windows.tsx}`

**Interfaces:**
- Consumes: `WindowEnumerator` + `WindowInfo`/`DesktopInfo` (Task 2); `handleAsyncCapability(_:_:reply:fail:)` signature (`AppController.swift:1936`); `JSONValue`.

- [ ] **Step 1: Add the enumerator instance + a struct→JSON mapper.** In `AppController.swift`, near `private let windowManager = WindowManager()` (~25):
```swift
    private let windowEnumerator = WindowEnumerator()
```
Add a private mapper (near the other `Self.` JSON helpers):
```swift
    private static func windowJSON(_ w: WindowInfo) -> JSONValue {
        var app: [String: JSONValue] = [:]
        if let n = w.appName { app["name"] = .string(n) }
        if let p = w.appPath { app["path"] = .string(p) }
        if let b = w.bundleId { app["bundleId"] = .string(b) }
        var obj: [String: JSONValue] = [
            "id": .string(w.id),
            "bounds": .object(["position": .object(["x": .number(w.x), "y": .number(w.y)]),
                               "size": .object(["width": .number(w.width), "height": .number(w.height)])]),
            "desktopId": .string(w.desktopId),
            "active": .bool(w.active),
            "fullScreen": .bool(w.fullScreen),
        ]
        if !app.isEmpty { obj["application"] = .object(app) }
        return .object(obj)
    }
    private static func desktopJSON(_ d: DesktopInfo) -> JSONValue {
        .object(["id": .string(d.id), "screenId": .string(d.screenId),
                 "size": .object(["width": .number(d.width), "height": .number(d.height)]),
                 "active": .bool(d.active), "type": .string(d.fullScreen ? "fullScreen" : "user")])
    }
```
(Confirm `JSONValue` has a `.bool` case — it does, alongside `.number`/`.string`/`.object`/`.array`/`.null`. If the case is named differently, match the enum.)

- [ ] **Step 2: Serve the four capabilities.** In `handleAsyncCapability` (~1936), add cases (work on the main thread — AX + NSScreen require it — then `reply`/`fail`). Follow the threading style of the nearby `runAppleScript`/`date.pick` cases:
```swift
        case "windowManagement.getActiveWindow":
            DispatchQueue.main.async {
                guard self.windowEnumerator.hasAccessibility else { fail("Accessibility permission is required for window management"); return }
                guard let w = self.windowEnumerator.activeWindow() else { fail("No active window"); return }
                reply(Self.windowJSON(w))
            }
            return true
        case "windowManagement.getWindowsOnActiveDesktop":
            DispatchQueue.main.async {
                guard self.windowEnumerator.hasAccessibility else { fail("Accessibility permission is required for window management"); return }
                reply(.array(self.windowEnumerator.windowsOnActiveDesktop().map(Self.windowJSON)))
            }
            return true
        case "windowManagement.getDesktops":
            DispatchQueue.main.async { reply(.array(self.windowEnumerator.desktops().map(Self.desktopJSON))) }
            return true
        case "windowManagement.setWindowBounds":
            DispatchQueue.main.async {
                guard self.windowEnumerator.hasAccessibility else { fail("Accessibility permission is required for window management"); return }
                let id = arg("id")?.stringValue ?? ""
                let b = { (k: String) -> JSONValue? in if case .object(let o)? = arg("bounds") { return o[k] }; return nil }
                let pos = { (k: String) -> Double? in if case .object(let o)? = b("position") { return o[k]?.doubleValue }; return nil }
                let size = { (k: String) -> Double? in if case .object(let o)? = b("size") { return o[k]?.doubleValue }; return nil }
                guard let w = self.windowEnumerator.setBounds(id: id, x: pos("x"), y: pos("y"), width: size("width"), height: size("height")) else {
                    fail("Window not found: \(id)"); return
                }
                reply(Self.windowJSON(w))
            }
            return true
```
(If `AXIsProcessTrusted()` is false, this also prompts elsewhere; here we just reject. If the codebase prefers `presentAccessibility`-style prompting, leave prompting to the existing `applyWindow` path — these handlers only reject.)

- [ ] **Step 3: Allow-list the methods.** In `runtime/node-host/src/supervisor.ts`, add to the ALLOWED set (before the closing `]);` ~78):
```ts
  "windowManagement.getActiveWindow",
  "windowManagement.getWindowsOnActiveDesktop",
  "windowManagement.setWindowBounds",
  "windowManagement.getDesktops",
```
In `apps/macos/Sources/InvokeShell/ExtensionHost.swift`, add the same four strings to the allow-list array (~85, the line with `clipboard.read`, `date.pick`).

- [ ] **Step 4: Dev stub.** In `runtime/node-host/src/run.ts`, add benign cases (near `clipboard.read` ~196):
```ts
      case "windowManagement.getActiveWindow": return { id: "dev", bounds: { position: { x: 0, y: 0 }, size: { width: 0, height: 0 } }, desktopId: "0" };
      case "windowManagement.getWindowsOnActiveDesktop": return [];
      case "windowManagement.getDesktops": return [];
      case "windowManagement.setWindowBounds": return { id: "dev", bounds: { position: { x: 0, y: 0 }, size: { width: 0, height: 0 } }, desktopId: "0" };
```

- [ ] **Step 5: Fixture.** `examples/window-management-demo/package.json` (mirror `examples/empty-action-demo/package.json` shape — same `$schema`/`icon`/`engines`/deps; one `view` command named `windows`, title "Window Management Demo"). `examples/window-management-demo/windows.tsx`:
```tsx
import { Detail, ActionPanel, Action, WindowManagement } from "@raycast/api";
import { useEffect, useState } from "react";

export default function Command() {
  const [md, setMd] = useState("Reading windows…");
  const refresh = async () => {
    try {
      const active = await WindowManagement.getActiveWindow();
      const all = await WindowManagement.getWindowsOnActiveDesktop();
      const desks = await WindowManagement.getDesktops();
      setMd(
        `# Window Management\n\n` +
          `**Active:** ${active.application?.name ?? "?"} — ${JSON.stringify(active.bounds)}\n\n` +
          `**Windows on desktop:** ${all.length}\n\n` +
          all.slice(0, 8).map((w) => `- ${w.application?.name ?? "?"} (${w.id})`).join("\n") +
          `\n\n**Desktops:** ${desks.map((d) => `${d.id}${d.active ? " (active)" : ""}`).join(", ")}`,
      );
    } catch (e) {
      setMd(`# Window Management\n\nError: ${String(e)}\n\n(Grant Accessibility to Invoke.)`);
    }
  };
  useEffect(() => { void refresh(); }, []);
  const nudge = async () => {
    const w = await WindowManagement.getActiveWindow();
    await WindowManagement.setWindowBounds({ id: w.id, bounds: { position: { x: w.bounds.position.x + 20, y: w.bounds.position.y } } });
    await refresh();
  };
  return <Detail markdown={md} actions={<ActionPanel><Action title="Nudge Active Window +20" onAction={nudge} /><Action title="Refresh" onAction={refresh} /></ActionPanel>} />;
}
```

- [ ] **Step 6: Build, relaunch, verify.** `swift build --package-path apps/macos 2>&1 | tail -3` → `Build complete!`; `cd runtime/node-host && npx tsc --noEmit 2>&1 | tail -5` clean; `bash scripts/build-app.sh 2>&1 | tail -5`; relaunch Invoke.app (durably authorized); confirm `/tmp/invoke-run.log` clean + the `windows` command discovered. **HUMAN-REQUIRED (mark in report):** with Accessibility granted, open "Window Management Demo" → real active window + window list + desktops render; "Nudge" shifts the active window +20pt. (No automation can grant AX + observe.)

- [ ] **Step 7: Commit.**
```bash
git add apps/macos/Sources/InvokeShell/AppController.swift runtime/node-host/src/supervisor.ts apps/macos/Sources/InvokeShell/ExtensionHost.swift runtime/node-host/src/run.ts examples/window-management-demo/
git commit -m "feat(wm): host WindowManagement capabilities (AX) + allow-list + dev stub + fixture"
```

---

## Self-Review

**1. Spec coverage:** TS API + types → Task 1; AX enumeration/id-cache/bounds → Task 2 (`WindowEnumerator`); host wiring + allow-lists + dev stub + fixture → Task 3. getActiveWindow/getWindowsOnActiveDesktop/setWindowBounds/getDesktops + Window/Desktop/DesktopType/Bounds all covered. ✅ Honest `getDesktops` (one per display) per spec.

**2. Placeholder scan:** Full code for every step (TS API, the whole `WindowEnumerator`, the host cases + JSON mappers, allow-lists, dev stub, fixture). The two "confirm the JSONValue case / match the prompting style" notes are read-the-code checks, not placeholders.

**3. Type consistency:** `WindowInfo`/`DesktopInfo` field names match between Task 2's structs, Task 3's `windowJSON`/`desktopJSON` mappers, and the TS `Window`/`Desktop` shapes (id, application{name,path,bundleId}, bounds{position{x,y},size{width,height}}, desktopId, active, fullScreen / id, screenId, size, active, type). `setBounds(id:x:y:width:height:)` matches between Task 2 and the Task 3 caller. `windowManagement.*` method names match across Task 1 (rpc), Task 3 (handler + allow-list + dev stub).

**Known risks (final-review triage):**
- (a) **Private `_AXUIElementGetWindow`** — resolved via `dlsym` with a UUID fallback. If the symbol ever disappears, ids degrade to per-call UUIDs (getActiveWindow→setWindowBounds in one extension flow still works via the cache within a session; cross-call stability is lost). Documented; acceptable.
- (b) `cache` grows across calls — bounded by re-population each enumeration but never pruned; for a launcher's usage (small, session-scoped) this is fine. A future cleanup could clear it on teardown.
- (c) AX/NSScreen on the **main thread** (handlers `DispatchQueue.main.async`) — correct (NSScreen requires main); enumeration of a handful of regular apps is fast. If an app is unresponsive, AX calls have a default timeout (acceptable).
- (d) `setBounds` re-reads via `info(for:pid:…)` with a best-effort pid — the returned Window's `application` may be sparse; the bounds (the part that matters for the round-trip) are accurate. Acceptable.
- (e) Module purity: `WindowEnumerator` must import ONLY AppKit + ApplicationServices (no JSONValue/InvokeShell) — the host owns JSON mapping. Verify no stray import.
