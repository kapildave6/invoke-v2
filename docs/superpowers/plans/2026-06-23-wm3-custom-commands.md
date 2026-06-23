# WM-3 — Create Window Management Command (custom positions) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Let users define a custom window position via a visual grid picker, saved as a bindable root command that positions the focused window.

**Architecture:** (1) `WindowManager.applyRect` applies an arbitrary fractional rect. (2) `AppSettings` persists `CustomWindowCommand`s. (3) A `WindowGridPicker` NSView (drag-select 12×8 grid) is rendered as a new `window-grid-picker` form-field type; its selection flows back via the existing `onFormFieldChange` channel. (4) A "Create Window Management Command" command opens a native form (Name + grid); Save stores it; `makeCommands()` surfaces each stored command (run → `applyRect`), bindable via the existing hotkey UI.

**Tech Stack:** Swift (`InvokeServices` engine + `AppSettings` + `InvokePalette` view + `AppController` flow). Pure logic via standalone `swiftc`; AppKit/AX via build + relaunch + human.

## Global Constraints
- Faithful Raycast parity; **world-class UX** (the grid picker must feel native); commit on `main`.
- **Build/relaunch (MANDATORY — never ad-hoc):** `INVOKE_SIGN_IDENTITY="Invoke Dev" bash scripts/build-app.sh` → `ditto apps/macos/.build/Invoke.app /Applications/Invoke.app` → `pkill -9 -f "Invoke.app/Contents/MacOS/invoke"` → `open /Applications/Invoke.app` → verify ONE PID. (Ad-hoc breaks the Accessibility grant.)
- No Xcode/XCTest → pure logic via standalone `swiftc`; AppKit/AX via build + relaunch + human visual. **Ignore SourceKit false-positives when `swift build` prints `Build complete!`** (BrowserDriver/AppleScriptRunner/'let' binding/etc.).
- `WindowManager` stays `InvokeServices`-only (AppKit + ApplicationServices; no InvokeShell/AppSettings/JSONValue).

## Coordinate note
Grid fractions are **top-left origin, y grows DOWN** (row 0 = top), matching the picker + Raycast. `rectFromFractions` converts to the Cocoa `visibleFrame` (y-up) used by `WindowManager.set` via `y = vf.minY + (1 - fy - fh) * vf.height`.

---

### Task 1: Engine — `applyRect` + pure `rectFromFractions`

**Files:** Modify `apps/macos/Sources/InvokeServices/WindowManager.swift`. Test: `<scratch>/main.swift` (`<scratch>` = `/private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad`).

**Interfaces:**
- Produces: `static func rectFromFractions(fx:fy:fw:fh:in:) -> CGRect` (internal); `@discardableResult func applyRect(fx:fy:fw:fh:pid:) -> Bool`.

- [ ] **Step 1: Write the failing test FIRST.** `<scratch>/main.swift`:
```swift
import AppKit
func eq(_ a: CGRect, _ b: CGRect, _ l: String) {
    if abs(a.minX-b.minX)>0.5 || abs(a.minY-b.minY)>0.5 || abs(a.width-b.width)>0.5 || abs(a.height-b.height)>0.5 { print("FAIL \(l): \(a) != \(b)"); exit(1) }
    print("ok:", l)
}
let vf = CGRect(x: 100, y: 200, width: 1200, height: 800) // origin non-zero to catch offset bugs
eq(WindowManager.rectFromFractions(fx: 0, fy: 0, fw: 1, fh: 1, in: vf), vf, "full")
eq(WindowManager.rectFromFractions(fx: 0, fy: 0, fw: 0.5, fh: 1, in: vf), CGRect(x: 100, y: 200, width: 600, height: 800), "left-half")
// top half: fy=0,fh=0.5 → TOP of screen → Cocoa y = vf.minY + 0.5*h
eq(WindowManager.rectFromFractions(fx: 0, fy: 0, fw: 1, fh: 0.5, in: vf), CGRect(x: 100, y: 600, width: 1200, height: 400), "top-half")
// bottom half: fy=0.5,fh=0.5 → Cocoa y = vf.minY
eq(WindowManager.rectFromFractions(fx: 0, fy: 0.5, fw: 1, fh: 0.5, in: vf), CGRect(x: 100, y: 200, width: 1200, height: 400), "bottom-half")
print("ALL PASS")
```

- [ ] **Step 2: Run to fail.** `cd <scratch> && swiftc /Users/test/Documents/code/invoke-v2/apps/macos/Sources/InvokeServices/WindowManager.swift main.swift -o wm3test && ./wm3test` → FAIL (symbol absent). (If linking errors: append `-framework AppKit -framework ApplicationServices`.)

- [ ] **Step 3: Implement.** Add to `WindowManager`:
```swift
    /// Arbitrary fractional rect. fx/fy/fw/fh are 0…1 of the visible frame with a TOP-LEFT origin
    /// (y grows DOWN, like the grid picker); converted here to the Cocoa (y-up) visibleFrame space.
    static func rectFromFractions(fx: Double, fy: Double, fw: Double, fh: Double, in vf: CGRect) -> CGRect {
        CGRect(x: vf.minX + CGFloat(fx) * vf.width,
               y: vf.minY + CGFloat(1 - fy - fh) * vf.height,
               width: CGFloat(fw) * vf.width,
               height: CGFloat(fh) * vf.height)
    }
    /// Apply a custom fractional rect to `pid`'s focused window (used by custom window commands, WM-3).
    @discardableResult
    public func applyRect(fx: Double, fy: Double, fw: Double, fh: Double, pid: pid_t) -> Bool {
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
        set(window: window, cocoaRect: Self.rectFromFractions(fx: fx, fy: fy, fw: fw, fh: fh, in: visible), primaryHeight: primaryHeight)
        return true
    }
```

- [ ] **Step 4: Run → ALL PASS.** (same swiftc command)

- [ ] **Step 5: Build + Commit.** `swift build --package-path apps/macos 2>&1 | tail -3` → `Build complete!`. `git add apps/macos/Sources/InvokeServices/WindowManager.swift && git commit -m "feat(wm): applyRect — arbitrary fractional window rect (custom commands)"`

---

### Task 2: Store — `CustomWindowCommand` in `AppSettings`

**Files:** Modify `apps/macos/Sources/InvokeShell/AppSettings.swift`. Test: `<scratch>/store-test.swift` (standalone, defines a tiny mirror — see note) OR rely on the integration check (Task 4). Prefer a pure round-trip test of the Codable model.

**Interfaces:**
- Produces: `struct AppSettings.CustomWindowCommand: Codable, Equatable { let id: String; var name: String; var fx, fy, fw, fh: Double }`; `@Published var customWindowCommands: [CustomWindowCommand]`; `func addCustomWindowCommand(name:fx:fy:fw:fh:) -> CustomWindowCommand`; `func removeCustomWindowCommand(id:)`; `func updateCustomWindowCommand(_:)`.

- [ ] **Step 1: Add the model + persistence.** In `AppSettings.swift`, near the other Codable structs (e.g. `KeyCombo` ~15) add:
```swift
    public struct CustomWindowCommand: Codable, Equatable {
        public let id: String
        public var name: String
        public var fx: Double, fy: Double, fw: Double, fh: Double
        public init(id: String = "window.custom.\(UUID().uuidString)", name: String, fx: Double, fy: Double, fw: Double, fh: Double) {
            self.id = id; self.name = name; self.fx = fx; self.fy = fy; self.fw = fw; self.fh = fh
        }
    }
```
Add the published property (mirror the `fallbackCommands` JSON-encoded pattern):
```swift
    @Published public var customWindowCommands: [CustomWindowCommand] {
        didSet { if let data = try? JSONEncoder().encode(customWindowCommands) { d.set(data, forKey: "customWindowCommands") } }
    }
```
Initialize in `private init()` (mirror how `fallbackCommands`/`hotkeys` decode):
```swift
        customWindowCommands = {
            guard let data = d.data(forKey: "customWindowCommands"),
                  let decoded = try? JSONDecoder().decode([CustomWindowCommand].self, from: data) else { return [] }
            return decoded
        }()
```
Add CRUD helpers (near `addFallback`/`moveFallback`):
```swift
    @discardableResult
    public func addCustomWindowCommand(name: String, fx: Double, fy: Double, fw: Double, fh: Double) -> CustomWindowCommand {
        let c = CustomWindowCommand(name: name, fx: fx, fy: fy, fw: fw, fh: fh)
        customWindowCommands.append(c); return c
    }
    public func removeCustomWindowCommand(id: String) { customWindowCommands.removeAll { $0.id == id } }
    public func updateCustomWindowCommand(_ c: CustomWindowCommand) {
        if let i = customWindowCommands.firstIndex(where: { $0.id == c.id }) { customWindowCommands[i] = c }
    }
```

- [ ] **Step 2: Pure Codable round-trip test.** `<scratch>/store-test.swift` — copy ONLY the `CustomWindowCommand` struct definition (it's self-contained, Foundation-only) into the test and assert `JSONDecoder().decode(..., JSONEncoder().encode([c])) == [c]` for a sample (id preserved, fractions preserved). Run `swift <scratch>/store-test.swift` → `ALL PASS`. (The `@Published`/`UserDefaults` wiring is verified by the Task 4 integration check — don't unit-test UserDefaults.)

- [ ] **Step 3: Build + Commit.** `swift build --package-path apps/macos 2>&1 | tail -3` → `Build complete!`. `git add apps/macos/Sources/InvokeShell/AppSettings.swift && git commit -m "feat(wm): persist CustomWindowCommand (AppSettings store + CRUD)"`

---

### Task 3: Grid picker — `WindowGridPicker` NSView + form-field rendering

**Files:** Create `apps/macos/Sources/InvokePalette/WindowGridPicker.swift`. Modify `apps/macos/Sources/InvokePalette/PaletteView.swift` (render a `window-grid-picker` field type + its value getter). Test: `<scratch>/grid-test.swift`.

**Interfaces:**
- Produces: `static func WindowGridPicker.gridSelectionToFractions(c0:r0:c1:r1:cols:rows:) -> (fx: Double, fy: Double, fw: Double, fh: Double)`; the `WindowGridPicker` NSView (12×8 drag-select) with `var onChange: ((fx,fy,fw,fh) -> Void)?` and `var fractions: (Double,Double,Double,Double)?` (current selection).

- [ ] **Step 1: Write the failing pure test FIRST.** `<scratch>/grid-test.swift`:
```swift
import AppKit
func ck(_ c: Bool, _ l: String) { if !c { print("FAIL", l); exit(1) }; print("ok:", l) }
typealias F = (fx: Double, fy: Double, fw: Double, fh: Double)
func eqF(_ a: F, _ b: F, _ l: String) { ck(abs(a.fx-b.fx)<1e-9 && abs(a.fy-b.fy)<1e-9 && abs(a.fw-b.fw)<1e-9 && abs(a.fh-b.fh)<1e-9, l) }
// 12 cols × 8 rows
eqF(WindowGridPicker.gridSelectionToFractions(c0: 0, r0: 0, c1: 11, r1: 7, cols: 12, rows: 8), (0, 0, 1, 1), "full")
eqF(WindowGridPicker.gridSelectionToFractions(c0: 0, r0: 0, c1: 5, r1: 7, cols: 12, rows: 8), (0, 0, 0.5, 1), "left-half")
eqF(WindowGridPicker.gridSelectionToFractions(c0: 0, r0: 0, c1: 3, r1: 7, cols: 12, rows: 8), (0, 0, 1.0/3, 1), "left-third")
eqF(WindowGridPicker.gridSelectionToFractions(c0: 5, r0: 0, c1: 0, r1: 3, cols: 12, rows: 8), (0, 0, 0.5, 0.5), "reversed-drag-normalizes")
eqF(WindowGridPicker.gridSelectionToFractions(c0: 4, r0: 4, c1: 4, r1: 4, cols: 12, rows: 8), (4.0/12, 4.0/8, 1.0/12, 1.0/8), "single-cell")
print("ALL PASS")
```

- [ ] **Step 2: Run to fail.** `cd <scratch> && swiftc /Users/test/Documents/code/invoke-v2/apps/macos/Sources/InvokePalette/WindowGridPicker.swift grid-test.swift -o gridtest && ./gridtest` → FAIL (file absent). (Append `-framework AppKit` if needed.)

- [ ] **Step 3: Implement `WindowGridPicker.swift`.** Create the file:
```swift
import AppKit

/// A 12×8 drag-select grid for defining a custom window region (WM-3). Reports the selected region as
/// top-left-origin fractions (fx,fy,fw,fh) of the screen. World-class: live highlight while dragging.
public final class WindowGridPicker: NSView {
    public static let cols = 12, rows = 8
    public var onChange: ((Double, Double, Double, Double) -> Void)?
    public private(set) var fractions: (Double, Double, Double, Double)?
    private var anchor: (c: Int, r: Int)?
    private var current: (c: Int, r: Int)?

    /// Pure mapping: a drag from (c0,r0) to (c1,r1) on a cols×rows grid → top-left fractions (normalized, clamped).
    public static func gridSelectionToFractions(c0: Int, r0: Int, c1: Int, r1: Int, cols: Int, rows: Int) -> (fx: Double, fy: Double, fw: Double, fh: Double) {
        let minC = max(0, min(c0, c1)), maxC = min(cols - 1, max(c0, c1))
        let minR = max(0, min(r0, r1)), maxR = min(rows - 1, max(r0, r1))
        return (Double(minC) / Double(cols), Double(minR) / Double(rows),
                Double(maxC - minC + 1) / Double(cols), Double(maxR - minR + 1) / Double(rows))
    }

    public override var intrinsicContentSize: NSSize { NSSize(width: 360, height: 240) }
    public override var acceptsFirstResponder: Bool { true }

    private func cell(at p: NSPoint) -> (c: Int, r: Int) {
        let cw = bounds.width / CGFloat(Self.cols), ch = bounds.height / CGFloat(Self.rows)
        let c = max(0, min(Self.cols - 1, Int(p.x / cw)))
        // view is y-up; row 0 must be the TOP → invert
        let rTop = max(0, min(Self.rows - 1, Int((bounds.height - p.y) / ch)))
        return (c, rTop)
    }
    public override func mouseDown(with e: NSEvent) { anchor = cell(at: convert(e.locationInWindow, from: nil)); current = anchor; commit(); needsDisplay = true }
    public override func mouseDragged(with e: NSEvent) { current = cell(at: convert(e.locationInWindow, from: nil)); commit(); needsDisplay = true }
    public override func mouseUp(with e: NSEvent) { current = cell(at: convert(e.locationInWindow, from: nil)); commit(); needsDisplay = true }

    private func commit() {
        guard let a = anchor, let c = current else { return }
        let f = Self.gridSelectionToFractions(c0: a.c, r0: a.r, c1: c.c, r1: c.r, cols: Self.cols, rows: Self.rows)
        fractions = (f.fx, f.fy, f.fw, f.fh)
        onChange?(f.fx, f.fy, f.fw, f.fh)
    }

    public override func draw(_ dirty: NSRect) {
        let cw = bounds.width / CGFloat(Self.cols), ch = bounds.height / CGFloat(Self.rows)
        NSColor.gridColor.setStroke()
        for c in 0...Self.cols { let x = CGFloat(c) * cw; let p = NSBezierPath(); p.move(to: NSPoint(x: x, y: 0)); p.line(to: NSPoint(x: x, y: bounds.height)); p.lineWidth = 0.5; p.stroke() }
        for r in 0...Self.rows { let y = CGFloat(r) * ch; let p = NSBezierPath(); p.move(to: NSPoint(x: 0, y: y)); p.line(to: NSPoint(x: bounds.width, y: y)); p.lineWidth = 0.5; p.stroke() }
        if let a = anchor, let c = current {
            let minC = min(a.c, c.c), maxC = max(a.c, c.c), minR = min(a.r, c.r), maxR = max(a.r, c.r)
            let x = CGFloat(minC) * cw
            let yTop = bounds.height - CGFloat(maxR + 1) * ch // y-up
            let rect = NSRect(x: x, y: yTop, width: CGFloat(maxC - minC + 1) * cw, height: CGFloat(maxR - minR + 1) * ch)
            NSColor.controlAccentColor.withAlphaComponent(0.35).setFill(); rect.fill()
            NSColor.controlAccentColor.setStroke(); let b = NSBezierPath(rect: rect); b.lineWidth = 1.5; b.stroke()
        }
    }
}
```

- [ ] **Step 4: Run → ALL PASS.** (same swiftc command)

- [ ] **Step 5: Render it as a form field.** In `PaletteView.swift`, where form fields are built by type (search the `fieldTypes`/`switch` that handles `form-textfield`/`form-datepicker`), add a `case "window-grid-picker"`: instantiate a `WindowGridPicker`, set its `onChange` to call the existing form-field-change handler (the same channel `form-datepicker` uses — report the value as a comma string `"fx,fy,fw,fh"`), and register its value getter in `formControls` returning the current `fractions` as `"fx,fy,fw,fh"` (or "" if none). Mirror the `form-datepicker` block (which appends to `formControls` + sets `formApply`). Add `"window-grid-picker"` to the `fieldTypes` set(s) that gate form-field handling (the two `let fieldTypes: Set<String>` at ~1412/1515).

- [ ] **Step 6: Build + Commit.** `swift build --package-path apps/macos 2>&1 | tail -3` → `Build complete!`. `git add apps/macos/Sources/InvokePalette/WindowGridPicker.swift apps/macos/Sources/InvokePalette/PaletteView.swift && git commit -m "feat(wm): WindowGridPicker drag-select grid + window-grid-picker form field"`

---

### Task 4: Builder flow + surfacing + verify

**Files:** Modify `apps/macos/Sources/InvokeShell/AppController.swift` (a `window.custom.create` command + builder form + `makeCommands()` surfacing + applyRect run + ⌘K Edit/Delete).

**Interfaces:** Consumes `WindowManager.applyRect`, `AppSettings.customWindowCommands`/CRUD, `enterNativeForm`/`formField`, the `window-grid-picker` field type, `windowCommand`/`RootCommand` pattern.

- [ ] **Step 1: Builder form.** Add a `presentCustomWindowForm(editing: AppSettings.CustomWindowCommand? = nil)` (mirror `presentQuicklinkForm`): fields = a Name `form-textfield` + a `formField(..., type: "window-grid-picker", title: "Position", value: editing.map { "\($0.fx),\($0.fy),\($0.fw),\($0.fh)" } ?? "")`. In the `enterNativeForm` submit, parse the grid value (`"fx,fy,fw,fh"` → 4 Doubles), require a non-empty name + a parsed selection with `fw > 0 && fh > 0`, then `AppSettings.shared.addCustomWindowCommand(...)` (or `updateCustomWindowCommand` when editing), then rebuild the command list (re-assign the lazy `commands` via the same mechanism used after enabling/disabling — find how `reloadCommandHotkeys`/command-list refresh is triggered and call it; if `commands` is `lazy`, reset it to `makeCommands()` and refresh the root render) and `reloadCommandHotkeys()`.

- [ ] **Step 2: Create entry + surfacing in `makeCommands()`.** In the returned array (`AppController.swift:4116`), add a create command and the stored customs (place near the `windowCommand(...)` block):
```swift
            RootCommand(id: "window.custom.create", title: "Create Window Management Command", subtitle: "Window Management", runTitle: "Create", icon: "plus.rectangle", keywords: ["window", "create", "custom", "position", "layout"], closesPalette: false) { [weak self] in self?.presentCustomWindowForm() },
```
and append the stored customs (after the built-in window commands):
```swift
        ] + AppSettings.shared.customWindowCommands.map { c in
            RootCommand(id: c.id, title: c.name, subtitle: "Window Management", runTitle: c.name, icon: "macwindow", keywords: ["window"] + c.name.lowercased().split(separator: " ").map(String.init), closesPalette: true) { [weak self] in
                guard let self else { return }
                guard AXIsProcessTrusted() else { Self.promptAccessibility(); self.palette.showToast("Enable Accessibility for Invoke to manage windows"); return }
                if let pid = self.pasteTarget?.processIdentifier { self.windowManager.applyRect(fx: c.fx, fy: c.fy, fw: c.fw, fh: c.fh, pid: pid) }
            }
        } + discoverExtensionCommands() + settingsTabCommands()
```
(Adjust to the exact existing `] + discoverExtensionCommands() + settingsTabCommands()` tail at `:4183` — insert the `+ customWindowCommands.map {…}` before it.)

- [ ] **Step 3: ⌘K Edit/Delete (minimal).** For custom commands, expose Action-Panel actions to edit (`presentCustomWindowForm(editing:)`) and delete (`AppSettings.shared.removeCustomWindowCommand(id:)` + rebuild). If wiring per-command Action sections is heavy, a `window.custom.manage` is an acceptable alternative — but prefer ⌘K actions on the command. (If the root Action-Panel for built-in commands isn't easily extensible per-command, defer Edit/Delete to a follow-up and note it; Create + run + bind is the must-have.)

- [ ] **Step 4: Build, install (stable signed), relaunch, verify.** `swift build --package-path apps/macos 2>&1 | tail -3` → `Build complete!`; then `INVOKE_SIGN_IDENTITY="Invoke Dev" bash scripts/build-app.sh 2>&1 | tail -4`; `ditto apps/macos/.build/Invoke.app /Applications/Invoke.app`; `pkill -9 -f "Invoke.app/Contents/MacOS/invoke"; sleep 2; open /Applications/Invoke.app`; confirm `/tmp/invoke-run.log` clean + a single PID + "Create Window Management Command" discoverable. **HUMAN-REQUIRED (mark in report):** run "Create Window Management Command" → drag a region on the grid → name it → Save → the new command appears in root → running it positions the focused window → it's bindable in Settings → Extensions → Edit/Delete work.

- [ ] **Step 5: Commit.** `git add apps/macos/Sources/InvokeShell/AppController.swift && git commit -m "feat(wm): Create Window Management Command — builder + custom commands surfaced + bindable"`

---

## Self-Review
**1. Spec coverage:** engine `applyRect` → T1; store → T2; grid picker (NSView + pure mapping + form-field render) → T3; builder + surfacing + Edit/Delete → T4. ✅
**2. Placeholder scan:** Full code for the engine, store, the whole `WindowGridPicker`, and the surfacing. T3 Step 5 + T4 Steps 1/3 reference "the existing form-datepicker block / command-list refresh / Action-Panel" as read-the-code anchors (the surrounding mechanism is established; exact line adjacency is found at implementation) — these are integration points, not missing logic.
**3. Type consistency:** `CustomWindowCommand{id,name,fx,fy,fw,fh}` consistent T2↔T4. `gridSelectionToFractions(c0:r0:c1:r1:cols:rows:)` + `rectFromFractions(fx:fy:fw:fh:in:)` consistent across tests + callers. Grid value serialization `"fx,fy,fw,fh"` consistent T3↔T4. `applyRect(fx:fy:fw:fh:pid:)` consistent T1↔T4.
**Known risks (final-review triage):** (a) grid y-inversion appears twice (cell hit-test + draw + rectFromFractions) — the pure tests pin `gridSelectionToFractions` + `rectFromFractions`; the NSView hit-test/draw is human-verified. (b) command-list rebuild after Save must actually re-render root (else the new command won't show until relaunch) — verify the refresh path. (c) per-command ⌘K Edit/Delete may be non-trivial; Create+run+bind is the must-have, Edit/Delete may defer. (d) custom commands run via `applyRect` (NOT cycling) — correct (no cycle state).
