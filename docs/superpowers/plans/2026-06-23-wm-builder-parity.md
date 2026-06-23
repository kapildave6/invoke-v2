# WM Builder Parity — Raycast position editor (Create Window Command + Layout) Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Match Raycast's window builder — a reusable **9-anchor Position + Size(Auto/pt) + Offset(pt) + live preview** editor — used by **Create Window Command** (revising WM-3) and **Create Window Layout** (WM-4, multi-app).

**Architecture:** Placement model + engine in `InvokeServices` (`WindowPlacement`, pure `placementRect`, `applyPlacement*`, `serialize/parsePlacement`); `WindowPositionEditor` NSView in `InvokePalette` (gains an InvokeServices dep) rendered as a `window-position-editor` form field; `AppController` builders for both commands.

**Tech Stack:** Swift (`InvokeServices` + `InvokePalette` + `AppSettings`/`AppController`). Pure via `swiftc`; AppKit/AX via build + relaunch + human.

## Global Constraints
- Faithful Raycast parity; world-class UX (live preview + 9-anchor); commit on `main`.
- **Build/relaunch (MANDATORY — never ad-hoc):** `INVOKE_SIGN_IDENTITY="Invoke Dev" bash scripts/build-app.sh` → `ditto apps/macos/.build/Invoke.app /Applications/Invoke.app` → `pkill -9 -f "Invoke.app/Contents/MacOS/invoke"` → `open /Applications/Invoke.app` → verify ONE PID.
- No Xcode/XCTest → pure via `swiftc`; AppKit/AX via build + relaunch + human. **Ignore SourceKit false-positives when `swift build` prints `Build complete!`**.
- Engine AX-native (top-left). Built-in halves/thirds/cycling keep their `WindowManager` path (untouched).

---

### Task 1: Placement model + engine + store

**Files:** Create `apps/macos/Sources/InvokeServices/WindowPlacement.swift`; modify `apps/macos/Sources/InvokeServices/WindowEnumerator.swift` (engine) + `apps/macos/Sources/InvokeShell/AppSettings.swift` (store). Test: `<scratch>/placement-test.swift` (`<scratch>` = `/private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad`).

**Interfaces produced:** `Sizing`/`Anchor`/`WindowPlacement`; `WindowEnumerator.placementRect(_:currentSize:visibleAX:)`, `serializePlacement`, `parsePlacement`, `applyPlacement(_:toWindow:)`, `applyPlacementToFocused(_:)`, `applyLayout(_:)`; `AppSettings.CustomWindowCommand{id,name,placement}`, `AppSettings.WindowLayout{id,name,items:[Item{bundleId,appName,placement}]}` + CRUD.

- [ ] **Step 1: Write the failing pure test FIRST.** `<scratch>/placement-test.swift`:
```swift
import AppKit
func ck(_ c: Bool, _ l: String) { if !c { print("FAIL", l); exit(1) }; print("ok:", l) }
func eqR(_ a: CGRect, _ b: CGRect, _ l: String) { ck(abs(a.minX-b.minX)<0.5 && abs(a.minY-b.minY)<0.5 && abs(a.width-b.width)<0.5 && abs(a.height-b.height)<0.5, l) }
let V = CGRect(x: 0, y: 0, width: 1440, height: 900)
let cur = CGSize(width: 700, height: 500)
// center, explicit 800×600 → centered
eqR(WindowEnumerator.placementRect(WindowPlacement(anchor: .center, width: .points(800), height: .points(600), offsetX: 0, offsetY: 0), currentSize: cur, visibleAX: V), CGRect(x: 320, y: 150, width: 800, height: 600), "center 800x600")
// topLeft, Auto size → current size at origin
eqR(WindowEnumerator.placementRect(WindowPlacement(anchor: .topLeft, width: .auto, height: .auto, offsetX: 0, offsetY: 0), currentSize: cur, visibleAX: V), CGRect(x: 0, y: 0, width: 700, height: 500), "topLeft auto")
// bottomRight, 400×300, offset (-10,-20)
eqR(WindowEnumerator.placementRect(WindowPlacement(anchor: .bottomRight, width: .points(400), height: .points(300), offsetX: -10, offsetY: -20), currentSize: cur, visibleAX: V), CGRect(x: 1030, y: 580, width: 400, height: 300), "bottomRight 400x300 offset")
// serialize/parse round-trip
let p = WindowPlacement(anchor: .right, width: .points(640), height: .auto, offsetX: 5, offsetY: -3)
ck(WindowEnumerator.parsePlacement(WindowEnumerator.serializePlacement(p)) == p, "serialize roundtrip")
ck(WindowEnumerator.parsePlacement("4;Auto;Auto;0;0") == WindowPlacement(anchor: .center, width: .auto, height: .auto, offsetX: 0, offsetY: 0), "parse center auto")
ck(WindowEnumerator.parsePlacement("garbage") == nil, "parse bad → nil")
// Codable round-trip
let data = try! JSONEncoder().encode(p); ck((try! JSONDecoder().decode(WindowPlacement.self, from: data)) == p, "codable roundtrip")
print("ALL PASS")
```

- [ ] **Step 2: Run to fail.** `cd <scratch> && swiftc /Users/test/Documents/code/invoke-v2/apps/macos/Sources/InvokeServices/WindowPlacement.swift /Users/test/Documents/code/invoke-v2/apps/macos/Sources/InvokeServices/WindowEnumerator.swift placement-test.swift -o pt && ./pt` → FAIL (symbols absent). (Append `-framework AppKit -framework ApplicationServices` if linking errors.)

- [ ] **Step 3: Create `WindowPlacement.swift`.**
```swift
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
```

- [ ] **Step 4: Add the engine to `WindowEnumerator.swift`.** (statics are pure; the apply methods reuse WM-2 AX helpers `axDouble`, `visibleAX(forCenter:)` from WM-4 — if WM-4's `visibleAX`/`primaryFullHeight` aren't present yet because WM-4 was superseded, add `visibleAX(forCenter:)` per the WM-4 spec.)
```swift
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
```
(`focusedWindow(ofPid:)` exists from WM-2. Confirm `visibleAX(forCenter:)` + `primaryFullHeight()` exist; if not — they were specced for the superseded WM-4 — add them here per that spec: `axRect`-convert the screen's `visibleFrame` containing the center.)

- [ ] **Step 5: Update `AppSettings`.** Replace `CustomWindowCommand`'s `fx,fy,fw,fh` with `placement: WindowPlacement` (keep `id`, `name`; update its `init`, the `addCustomWindowCommand(name:placement:)` signature, and `updateCustomWindowCommand`). Add `WindowLayout` (per the design) + `windowLayouts` (JSON, mirror) + `addWindowLayout(name:items:)`/`removeWindowLayout(id:)`/`updateWindowLayout`. **Migration:** old stored fraction `customWindowCommands` will fail to decode → the existing `?? []` fallback drops them (acceptable; days-old dev feature — note it). `import InvokeServices` at the top of AppSettings if not already (it's an InvokeShell file; InvokeShell depends on InvokeServices).

- [ ] **Step 6: Run the pure test → ALL PASS** (the swiftc command from Step 2). Then `swift build --package-path apps/macos 2>&1 | tail -3` → `Build complete!`.

- [ ] **Step 7: Commit.** `git add apps/macos/Sources/InvokeServices/WindowPlacement.swift apps/macos/Sources/InvokeServices/WindowEnumerator.swift apps/macos/Sources/InvokeShell/AppSettings.swift && git commit -m "feat(wm): WindowPlacement model + placementRect/applyPlacement engine + store (9-anchor+size+offset)"`

---

### Task 2: `WindowPositionEditor` component + form-field render

**Files:** Create `apps/macos/Sources/InvokePalette/WindowPositionEditor.swift`; modify `apps/macos/Package.swift` (add `InvokeServices` to `InvokePalette` deps) + `apps/macos/Sources/InvokePalette/PaletteView.swift` (render `window-position-editor`). Test: covered by Task 1's pure `placementRect`/`serialize` (the editor reuses them) + human visual.

**Interfaces produced:** `WindowPositionEditor: NSView` with `var onChange: ((String) -> Void)?` and `var placementString: String` (get/set the `"anchor;w;h;offX;offY"` value).

- [ ] **Step 1: Add the module dependency.** In `apps/macos/Package.swift`, change `InvokePalette`'s deps to `["InvokeRenderer", "InvokeIPC", "InvokeObjC", "InvokeServices"]`. Run `swift build --package-path apps/macos 2>&1 | tail -3` → still `Build complete!` (no cycle: InvokeServices has no deps).

- [ ] **Step 2: Build `WindowPositionEditor.swift`** (`import AppKit` + `import InvokeServices`). Structure:
  - A vertical stack: **preview** (a `WindowPreviewView` sub-NSView, ~16:10, drawing the main display's `visibleFrame` scaled + a translucent accent rect = `WindowEnumerator.placementRect(current, currentSize: previewWindowSize, visibleAX: previewBounds)` where `current` is parsed from state) ; **9-anchor grid** (a 3×3 `NSGridView`/stack of 9 square `NSButton`s, SF Symbols `rectangle.inset.topleft.filled` etc. or a drawn dot; single-select, selected highlighted with `controlAccentColor`); **Size** row (`W:` `NSTextField` + "pt", `H:` field + "pt"; empty or "Auto" → `.auto`); **Offset** row (`X:`/`Y:` fields + "pt").
  - State: `anchor: Anchor`, `width/height: Sizing`, `offsetX/offsetY: Double`, seeded from `placementString` (via `WindowEnumerator.parsePlacement`, default `.default`).
  - Any control change → recompute → `placementString = WindowEnumerator.serializePlacement(current)`, redraw the preview, and call `onChange?(placementString)`.
  - The preview rect uses `placementRect` against the PREVIEW frame (a normalized `visibleAX` = the preview bounds) with a representative `previewWindowSize` (for `.auto`, use a default like 60%×60% of the preview so Auto shows *something*); this reuses the engine so the preview matches the real apply.

- [ ] **Step 3: Render as a form field in `PaletteView.swift`.** Add `"window-position-editor"` to BOTH `fieldTypes` sets (~1412/1515). In the field-building switch, add a branch (mirror the WM-3 `window-grid-picker` branch the implementer added — read it): instantiate `WindowPositionEditor`, seed `placementString` from the node's value, set `onChange = { onFormFieldChange?(<handlerId>, $0) }`, append a `formControls` getter returning `editor.placementString`, and a `formApply` that sets `placementString` from an incoming value. (The `window-grid-picker` field/its handler-id rotation is the exact template.)

- [ ] **Step 4: Build + Commit.** `swift build --package-path apps/macos 2>&1 | tail -3` → `Build complete!`. `git add apps/macos/Package.swift apps/macos/Sources/InvokePalette/WindowPositionEditor.swift apps/macos/Sources/InvokePalette/PaletteView.swift && git commit -m "feat(wm): WindowPositionEditor (live preview + 9-anchor + size + offset) as a form field"`

---

### Task 3: Create Window Command — revised to the editor

**Files:** Modify `apps/macos/Sources/InvokeShell/AppController.swift`.

- [ ] **Step 1: Rewrite `presentCustomWindowForm(editing:)`** (it currently uses the WM-3 grid field): fields = Name `form-textfield` + `formField(..., type: "window-position-editor", title: "Position", value: editing.map { WindowEnumerator.serializePlacement($0.placement) } ?? WindowEnumerator.serializePlacement(.default))`. Submit: parse the editor value via `WindowEnumerator.parsePlacement(...)` (bail if nil), require a non-empty name, then `addCustomWindowCommand(name:placement:)` (or update with same id), then `self.commands = self.makeCommands()` + `self.reloadCommandHotkeys()`.

- [ ] **Step 2: Update the custom-command run + Edit/Delete.** In `makeCommands()` the `customWindowCommands.map` RootCommand run becomes: AX-guard → `self.windowEnumerator.applyPlacementToFocused(c.placement)`. The `currentActions()` `window.custom.` branch's Edit reopens `presentCustomWindowForm(editing:)`; Delete unchanged. (Remove references to the old `applyRect`/`fx,fy,fw,fh`.)

- [ ] **Step 3: Build + relaunch (stable) + Commit.** `swift build --package-path apps/macos 2>&1 | tail -3`; `INVOKE_SIGN_IDENTITY="Invoke Dev" bash scripts/build-app.sh 2>&1 | tail -4`; `ditto apps/macos/.build/Invoke.app /Applications/Invoke.app`; `pkill -9 -f "Invoke.app/Contents/MacOS/invoke"; sleep 2; open /Applications/Invoke.app`; verify single PID + `/tmp/invoke-run.log` clean. **HUMAN-REQUIRED:** Create Window Command → the editor (preview + 9-anchor + size + offset) → Save → run positions the focused window per the placement. `git add apps/macos/Sources/InvokeShell/AppController.swift && git commit -m "feat(wm): Create Window Command uses the Raycast-style position editor (9-anchor+size+offset)"`

---

### Task 4: Create Window Layout — multi-app

**Files:** Modify `apps/macos/Sources/InvokeShell/AppController.swift`.

- [ ] **Step 1: `presentWindowLayoutForm(editing:)`.** A layout-builder form: a Name `form-textfield`, then per layout item a pair (app picker `form-dropdown` over `NSWorkspace.shared.runningApplications` regular apps [title=localizedName, value=bundleId] + a `window-position-editor`), plus an **"Add App"** affordance. Since native forms are static per render, model "Add App" by keeping a working `[(@bundleId, placementString)]` list on the controller and RE-PRESENTING the form (re-enter `enterNativeForm`) with one more item row when "Add App" is chosen (an explicit `form-dropdown` whose selection appends + re-renders), and a Save action. (If re-rendering the native form per add is awkward, a dedicated layout-builder mode that appends rows is acceptable — but prefer reusing `enterNativeForm`.) Save: name + the item list → `WindowLayout.Item(bundleId, appName, placement)` each → `addWindowLayout(name:items:)` → rebuild.

- [ ] **Step 2: Surfacing + Edit/Delete in `makeCommands()`/`currentActions()`.** Add `window.layout.create` "Create Window Layout Command" (icon `rectangle.3.group`) → `presentWindowLayoutForm()`. Append stored layouts as RootCommands (run → AX-guard → `windowEnumerator.applyLayout(layout.items.map { (bundleId: $0.bundleId, placement: $0.placement) })`; toast "positioned N of M" if `n < count`). A `currentActions()` `window.layout.` branch → run + Edit (`presentWindowLayoutForm(editing:)`) + Delete (`removeWindowLayout(id:)` + rebuild + renderRoot).

- [ ] **Step 3: Build + relaunch (stable) + verify + Commit.** Same build/install/relaunch as Task 3. Verify single PID + "Create Window Layout Command" discoverable. **HUMAN-REQUIRED:** Create Window Layout → Add VS Code + Terminal, set each via the editor → Save → run repositions both; non-running app skipped with the toast; bindable; Edit/Delete. `git add apps/macos/Sources/InvokeShell/AppController.swift && git commit -m "feat(wm): Create Window Layout Command — multi-app placement (Raycast-style editor per app)"`

---

## Self-Review
**1. Spec coverage:** model+engine+store → T1; editor+form-field → T2; Create Window Command (revised) → T3; Create Window Layout → T4. ✅ Matches Raycast (9-anchor+size+offset+preview; layout=multi-app).
**2. Placeholder scan:** T1 has full code (model, engine, tests). T2/T3/T4 reference established templates (the WM-3 `window-grid-picker` field branch, `presentCustomWindowForm`, `currentActions` branch, `enterNativeForm`) as concrete anchors; the editor's AppKit layout detail is the implementer's craft (visual = human-verified), but the data flow (parse/serialize/onChange/formControls + placementRect preview) is concrete.
**3. Type consistency:** `WindowPlacement`/`Sizing`/`Anchor` + `placementRect`/`serialize`/`parsePlacement` consistent T1↔T2↔T3↔T4. The form value string `"anchor;w;h;offX;offY"` is the single interchange format (editor ↔ AppController via `serialize`/`parsePlacement`). `addCustomWindowCommand(name:placement:)` / `addWindowLayout(name:items:)` / `applyPlacementToFocused` / `applyLayout([(bundleId,placement)])` consistent across tasks.
**Known risks (final-review triage):** (a) Migration: old fraction `customWindowCommands` drop on decode (note; dev-only). (b) The native-form "Add App" re-render for layouts is the trickiest UX — if `enterNativeForm` re-entry is clumsy, a dedicated builder mode is the fallback (flag in the task report). (c) `.auto` size preview uses a representative size (real apply uses the live window size) — preview is indicative, not exact, for Auto (acceptable). (d) `InvokePalette → InvokeServices` new dep — verify no build cycle (InvokeServices has no deps, so safe). (e) WM-3's now-unused `WindowGridPicker` + `window-grid-picker` field can be removed in T2/T3 or left dormant — prefer removing to avoid dead code; note which.
