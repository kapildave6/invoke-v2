# WM-1 — Window Management cycling + thirds Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add ⅓/⅔ window positions and ½→⅔→⅓ cycling (repeat a Left/Right Half command to cycle) to the first-party Window Management feature.

**Architecture:** Extend the pure `WindowManager.Action` + `rect(for:in:)` math; add a pure cycle-decision (`cycleStep`/`cycleSequence`/`rectsMatch`) plus a stateful `applyCycling` wrapper that reads the focused window's frame via AX; route `applyWindow` through it; add 5 discrete commands + a global Settings toggle. `WindowManager` stays in `InvokeServices` with no `InvokeShell` dependency (the cycling-enabled flag is passed in).

**Tech Stack:** Swift / AppKit / ApplicationServices (AX). Pure logic tested via a standalone `swiftc` co-compile; AX + UI via build + relaunch + human visual.

## Global Constraints
- Faithful Raycast parity; world-class UX; commit on `main`; relaunch after build (durably authorized).
- No Xcode/XCTest → pure logic via standalone `swiftc`; AppKit/AX via `swift build --package-path apps/macos` + `scripts/build-app.sh` + relaunch + human visual. **Ignore SourceKit false-positives when `swift build` prints `Build complete!`** (e.g. "cannot find BrowserDriver/AppleScriptRunner in scope", "'let' binding pattern cannot appear in an expression").
- `WindowManager` (`InvokeServices`) must NOT import/depend on `InvokeShell`/`AppSettings` — pass `enabled` in as a parameter.
- Cycling scope (approved): Left/Right Half only; horizontal thirds only.

---

### Task 1: New positions — `Action` cases + `rect(for:in:)` math

**Files:**
- Modify: `apps/macos/Sources/InvokeServices/WindowManager.swift` (the `Action` enum ~8; `rect(for:in:)` ~69)
- Test: `<scratch>/main.swift` (co-compiled with the real `WindowManager.swift`)

**Interfaces:**
- Produces: `WindowManager.Action` gains `leftThird, centerThird, rightThird, leftTwoThirds, rightTwoThirds`; `static func rect(for:in:) -> CGRect` is now **internal** (was `private`) so it is callable from a co-compiled test.

- [ ] **Step 1: Write the failing test FIRST.** Create `<scratch>/main.swift` (top-level code; `<scratch>` = `/private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad`):
```swift
import AppKit
func eq(_ a: CGRect, _ b: CGRect, _ label: String) {
    if abs(a.minX-b.minX) > 0.5 || abs(a.minY-b.minY) > 0.5 || abs(a.width-b.width) > 0.5 || abs(a.height-b.height) > 0.5 {
        print("FAIL \(label): \(a) != \(b)"); exit(1)
    }
    print("ok: \(label)")
}
let vf = CGRect(x: 0, y: 0, width: 1200, height: 900)
eq(WindowManager.rect(for: .leftThird, in: vf),      CGRect(x: 0,   y: 0, width: 400, height: 900), "leftThird")
eq(WindowManager.rect(for: .centerThird, in: vf),    CGRect(x: 400, y: 0, width: 400, height: 900), "centerThird")
eq(WindowManager.rect(for: .rightThird, in: vf),     CGRect(x: 800, y: 0, width: 400, height: 900), "rightThird")
eq(WindowManager.rect(for: .leftTwoThirds, in: vf),  CGRect(x: 0,   y: 0, width: 800, height: 900), "leftTwoThirds")
eq(WindowManager.rect(for: .rightTwoThirds, in: vf), CGRect(x: 400, y: 0, width: 800, height: 900), "rightTwoThirds")
print("ALL PASS")
```

- [ ] **Step 2: Run it to fail.**
```bash
cd <scratch> && swiftc /Users/test/Documents/code/invoke-v2/apps/macos/Sources/InvokeServices/WindowManager.swift main.swift -o wm1test && ./wm1test
```
Expected: a COMPILE failure (`leftThird` etc. not in `Action`, and `rect` is private). (If linking complains about frameworks, append `-framework AppKit -framework ApplicationServices`.)

- [ ] **Step 3: Add the cases + rects + relax access.** In `WindowManager.swift`, extend the enum:
```swift
    public enum Action: String {
        case maximize, leftHalf, rightHalf, topHalf, bottomHalf, center
        case topLeft, topRight, bottomLeft, bottomRight
        case leftThird, centerThird, rightThird, leftTwoThirds, rightTwoThirds
    }
```
Change `private static func rect(` to `static func rect(` (drop `private` — now internal). Add these cases inside the `switch action` in `rect(for:in:)` (alongside the existing ones):
```swift
        case .leftThird:      return CGRect(x: x,            y: y, width: w / 3,     height: h)
        case .centerThird:    return CGRect(x: x + w / 3,    y: y, width: w / 3,     height: h)
        case .rightThird:     return CGRect(x: x + 2 * w / 3, y: y, width: w / 3,     height: h)
        case .leftTwoThirds:  return CGRect(x: x,            y: y, width: 2 * w / 3, height: h)
        case .rightTwoThirds: return CGRect(x: x + w / 3,    y: y, width: 2 * w / 3, height: h)
```

- [ ] **Step 4: Run the test → ALL PASS.**
```bash
cd <scratch> && swiftc /Users/test/Documents/code/invoke-v2/apps/macos/Sources/InvokeServices/WindowManager.swift main.swift -o wm1test && ./wm1test
```

- [ ] **Step 5: Build + Commit.** `swift build --package-path apps/macos 2>&1 | tail -3` → `Build complete!`. Then:
```bash
git add apps/macos/Sources/InvokeServices/WindowManager.swift
git commit -m "feat(wm): add thirds + two-thirds window positions"
```

---

### Task 2: Cycle engine — pure decision + stateful `applyCycling`

**Files:**
- Modify: `apps/macos/Sources/InvokeServices/WindowManager.swift`
- Test: `<scratch>/main.swift` (replace with the cycle test below)

**Interfaces:**
- Consumes: `Action` (incl. Task 1's new cases); the existing private `frame(of:primaryHeight:)`, `set(window:cocoaRect:primaryHeight:)`, `Self.primaryFullHeight()`, `Self.screen(containing:)`.
- Produces:
  - `struct WindowManager.CycleState { let base: Action; let pid: pid_t; let step: Int }` (internal)
  - `static func cycleSequence(for: Action) -> [Action]`
  - `static func cycleStep(base: Action, last: CycleState?, pid: pid_t, frameMatches: Bool, enabled: Bool) -> Int`
  - `static func rectsMatch(_ a: CGRect, _ b: CGRect, tol: CGFloat = 6) -> Bool`
  - `@discardableResult func applyCycling(_ base: Action, pid: pid_t, enabled: Bool) -> Bool`

- [ ] **Step 1: Write the failing test FIRST.** Replace `<scratch>/main.swift` with:
```swift
import AppKit
typealias CS = WindowManager.CycleState
let pidA: pid_t = 100, pidB: pid_t = 200
func step(_ label: String, _ base: WindowManager.Action, _ last: CS?, _ pid: pid_t, _ matches: Bool, _ enabled: Bool, _ expect: Int) {
    let got = WindowManager.cycleStep(base: base, last: last, pid: pid, frameMatches: matches, enabled: enabled)
    if got != expect { print("FAIL \(label): got \(got) expected \(expect)"); exit(1) }
    print("ok: \(label)")
}
step("new-no-last",       .leftHalf, nil,                                  pidA, false, true, 0)
step("advance-0to1",      .leftHalf, CS(base: .leftHalf,  pid: pidA, step: 0), pidA, true,  true, 1)
step("advance-1to2",      .leftHalf, CS(base: .leftHalf,  pid: pidA, step: 1), pidA, true,  true, 2)
step("wrap-2to0",         .leftHalf, CS(base: .leftHalf,  pid: pidA, step: 2), pidA, true,  true, 0)
step("moved-resets",      .leftHalf, CS(base: .leftHalf,  pid: pidA, step: 1), pidA, false, true, 0)
step("diff-base-resets",  .leftHalf, CS(base: .rightHalf, pid: pidA, step: 1), pidA, true,  true, 0)
step("diff-pid-resets",   .leftHalf, CS(base: .leftHalf,  pid: pidB, step: 1), pidA, true,  true, 0)
step("disabled",          .leftHalf, CS(base: .leftHalf,  pid: pidA, step: 1), pidA, true,  false, 0)
step("maximize-len1",     .maximize, CS(base: .maximize,  pid: pidA, step: 0), pidA, true,  true, 0)
func seq(_ label: String, _ base: WindowManager.Action, _ expect: [WindowManager.Action]) {
    if WindowManager.cycleSequence(for: base) != expect { print("FAIL \(label): \(WindowManager.cycleSequence(for: base))"); exit(1) }
    print("ok: \(label)")
}
seq("seq-left",     .leftHalf,  [.leftHalf, .leftTwoThirds, .leftThird])
seq("seq-right",    .rightHalf, [.rightHalf, .rightTwoThirds, .rightThird])
seq("seq-maximize", .maximize,  [.maximize])
func matchT(_ label: String, _ a: CGRect, _ b: CGRect, _ expect: Bool) {
    if WindowManager.rectsMatch(a, b) != expect { print("FAIL \(label)"); exit(1) }
    print("ok: \(label)")
}
matchT("match-exact",  CGRect(x: 0, y: 0, width: 600, height: 900), CGRect(x: 0, y: 0, width: 600, height: 900), true)
matchT("match-within", CGRect(x: 2, y: 1, width: 603, height: 898), CGRect(x: 0, y: 0, width: 600, height: 900), true)
matchT("match-far",    CGRect(x: 0, y: 0, width: 800, height: 900), CGRect(x: 0, y: 0, width: 600, height: 900), false)
print("ALL PASS")
```

- [ ] **Step 2: Run it to fail.**
```bash
cd <scratch> && swiftc /Users/test/Documents/code/invoke-v2/apps/macos/Sources/InvokeServices/WindowManager.swift main.swift -o wm1test && ./wm1test
```
Expected: COMPILE failure (`CycleState`, `cycleStep`, `cycleSequence`, `rectsMatch` undefined).

- [ ] **Step 3: Implement the engine.** In `WindowManager`, add the state vars (near `public init()`):
```swift
    public struct CycleState { let base: Action; let pid: pid_t; let step: Int
        public init(base: Action, pid: pid_t, step: Int) { self.base = base; self.pid = pid; self.step = step } }
    private var cycleState: CycleState?
    private var lastCommandedRect: CGRect?
```
Add the pure helpers (e.g. just after `rect(for:in:)`):
```swift
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
```
Add the stateful wrapper (next to `apply`):
```swift
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
```

- [ ] **Step 4: Run the test → ALL PASS.**
```bash
cd <scratch> && swiftc /Users/test/Documents/code/invoke-v2/apps/macos/Sources/InvokeServices/WindowManager.swift main.swift -o wm1test && ./wm1test
```

- [ ] **Step 5: Build + Commit.** `swift build --package-path apps/macos 2>&1 | tail -3` → `Build complete!`. Then:
```bash
git add apps/macos/Sources/InvokeServices/WindowManager.swift
git commit -m "feat(wm): ½→⅔→⅓ cycling engine (pure cycleStep + stateful applyCycling)"
```

---

### Task 3: Settings toggle + discrete commands + `applyWindow` integration

**Files:**
- Modify: `apps/macos/Sources/InvokeShell/AppSettings.swift` (declaration ~26; init ~85)
- Modify: `apps/macos/Sources/InvokeShell/SettingsView.swift` (`GeneralPane` ~76)
- Modify: `apps/macos/Sources/InvokeShell/AppController.swift` (`applyWindow` ~443; the `windowCommand(...)` list ~4111)

**Interfaces:**
- Consumes: `WindowManager.applyCycling(_:pid:enabled:)`, `Action.leftThird/centerThird/rightThird/leftTwoThirds/rightTwoThirds`, the `windowCommand(_:_:_:_:_:)` factory (`AppController.swift:4069`), `AppSettings.shared`.

- [ ] **Step 1: Add the persisted setting.** In `AppSettings.swift`, add the declaration alongside the other `@Published` bools (e.g. after `launchAtLogin`, ~line 50):
```swift
    @Published public var windowCyclingEnabled: Bool { didSet { d.set(windowCyclingEnabled, forKey: "windowCyclingEnabled") } }
```
In `private init()` (~85), initialize it defaulting to **true** (mirror the `clipboardLimit` object-cast pattern so a never-set key is `true`):
```swift
        windowCyclingEnabled = (d.object(forKey: "windowCyclingEnabled") as? Bool) ?? true
```

- [ ] **Step 2: Route `applyWindow` through the cycle engine.** In `AppController.swift`, change `applyWindow` (~449) from `windowManager.apply(action, pid: pid)` to:
```swift
        if let pid { windowManager.applyCycling(action, pid: pid, enabled: AppSettings.shared.windowCyclingEnabled) }
```
(Leave the `AXIsProcessTrusted` guard + toast above it unchanged. `apply` stays on `WindowManager` — `applyCycling` calls it indirectly via the length-1 sequence for non-cycling actions, so all positions still work.)

- [ ] **Step 3: Add the 5 discrete commands.** In the `windowCommand(...)` list (after `window.bottomRight`, ~line 4120), add:
```swift
            windowCommand("window.firstThird", "First Third", "rectangle.lefthalf.inset.filled", ["first", "third", "left"], .leftThird),
            windowCommand("window.centerThird", "Center Third", "rectangle.center.inset.filled", ["center", "centre", "third", "middle"], .centerThird),
            windowCommand("window.lastThird", "Last Third", "rectangle.righthalf.inset.filled", ["last", "third", "right"], .rightThird),
            windowCommand("window.firstTwoThirds", "First Two-Thirds", "rectangle.lefthalf.filled", ["first", "two", "thirds", "left"], .leftTwoThirds),
            windowCommand("window.lastTwoThirds", "Last Two-Thirds", "rectangle.righthalf.filled", ["last", "two", "thirds", "right"], .rightTwoThirds),
```

- [ ] **Step 4: Add the Settings toggle.** In `SettingsView.swift` `GeneralPane` (~80), add after the `launchAtLogin` toggle:
```swift
            Toggle("Enable window cycling", isOn: $settings.windowCyclingEnabled)
            Text("Repeating a Left/Right Half command cycles the window through ½ → ⅔ → ⅓.")
                .font(.caption).foregroundStyle(.secondary)
```
(If `GeneralPane` already wraps controls in a `Form`/`VStack`/`Section`, place these inside the same container as `launchAtLogin`; match its surrounding style.)

- [ ] **Step 5: Build, relaunch, verify.** `swift build --package-path apps/macos 2>&1 | tail -3` → `Build complete!`; then `bash scripts/build-app.sh 2>&1 | tail -5` and relaunch Invoke.app (durably authorized). Confirm `/tmp/invoke-run.log` shows a clean launch + the new commands discoverable. **Mark as HUMAN-REQUIRED in the report (needs a granted Accessibility permission + eyes):** with a window focused, ⌃⌥← (Left Half) pressed repeatedly cycles left ½ → ⅔ → ⅓ → ½; "First Third"/"Last Two-Thirds" etc. position correctly; toggling "Enable window cycling" off makes repeats stay at ½.

- [ ] **Step 6: Commit.**
```bash
git add apps/macos/Sources/InvokeShell/AppSettings.swift apps/macos/Sources/InvokeShell/SettingsView.swift apps/macos/Sources/InvokeShell/AppController.swift
git commit -m "feat(wm): wire cycling into applyWindow + 5 discrete third/two-third commands + global toggle"
```

---

## Self-Review

**1. Spec coverage:** new positions → Task 1; cycling engine (pure `cycleStep`/`cycleSequence`/`rectsMatch` + stateful `applyCycling`) → Task 2; integration + discrete commands + Settings toggle → Task 3. ✅ All spec items covered. (No fixture extension — first-party AX/UI, per the spec's testing strategy.)

**2. Placeholder scan:** Every step has concrete code + exact commands. The "match `GeneralPane`'s container" note in Task 3 Step 4 is a read-the-surrounding-code instruction, not a placeholder (the toggle code itself is complete).

**3. Type consistency:** `Action` cases (`leftThird`/`centerThird`/`rightThird`/`leftTwoThirds`/`rightTwoThirds`) are identical across Tasks 1–3. `CycleState(base:pid:step:)`, `cycleStep(base:last:pid:frameMatches:enabled:)`, `cycleSequence(for:)`, `rectsMatch(_:_:tol:)`, `applyCycling(_:pid:enabled:)` signatures match between Task 2's definition and the Task 2 test + Task 3 caller. `windowCyclingEnabled` matches between AppSettings (Task 3 Step 1) and its uses (Steps 2, 4).

**Known risks (final-review triage):**
- (a) An app that clamps its min-size won't reach the commanded ⅓ rect → `rectsMatch` fails next press → cycle restarts at ½ (acceptable; documented).
- (b) `rect(for:in:)` access relaxed `private`→internal solely to enable the co-compiled pure test — harmless within `InvokeServices`.
- (c) `applyCycling` must keep `WindowManager` free of any `InvokeShell`/`AppSettings` import — the enabled flag is passed in (verify no stray import was added).
- (d) Standalone `swiftc` must link AppKit/ApplicationServices; if auto-linking fails, append `-framework AppKit -framework ApplicationServices`.
