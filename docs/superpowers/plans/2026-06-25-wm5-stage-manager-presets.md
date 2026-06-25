# WM-5 — Respect Stage Manager + Hotkey Presets Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Add a "Respect Stage Manager" toggle (best-effort left-inset when SM is on) and a "Apply Window Hotkey Preset" command — the last two Raycast WM items.

**Architecture:** A shared `effectiveVisibleFrame` + `stageManagerEnabled()` + a `respectStageManager` flag on the WM engines (`InvokeServices`), synced by the host from `AppSettings` at apply time; a static preset table + an apply flow in `AppController`.

**Tech Stack:** Swift (`InvokeServices` engines + `AppSettings`/`AppController`). Pure logic via `swiftc`; UI/AX via build + relaunch + human.

## Global Constraints
- Faithful parity; commit on `main`. **Build/relaunch (MANDATORY — never ad-hoc):** `INVOKE_SIGN_IDENTITY="Invoke Dev" bash scripts/build-app.sh` → `ditto apps/macos/.build/Invoke.app /Applications/Invoke.app` → `pkill -9 -f "Invoke.app/Contents/MacOS/invoke"` → `open /Applications/Invoke.app` → ONE PID.
- No Xcode/XCTest → pure via `swiftc`; UI/AX via build + relaunch + human. **Ignore SourceKit false-positives when `swift build` prints `Build complete!`**.
- WM engines stay `InvokeServices`-only.

---

### Task 1: Respect Stage Manager

**Files:** Modify `apps/macos/Sources/InvokeServices/WindowManager.swift` + `apps/macos/Sources/InvokeServices/WindowEnumerator.swift` + `apps/macos/Sources/InvokeShell/AppSettings.swift` + `apps/macos/Sources/InvokeShell/AppController.swift` + `apps/macos/Sources/InvokeShell/SettingsView.swift`. Test: `<scratch>/sm-test.swift` (`<scratch>` = `/private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad`).

**Interfaces produced:** `WindowManager.effectiveVisibleFrame(_:respectStageManager:) -> CGRect` (pure), `WindowManager.stageManagerEnabled() -> Bool`, `WindowManager.stageManagerStripWidth: CGFloat`, `var WindowManager.respectStageManager`, `var WindowEnumerator.respectStageManager`; `AppSettings.respectWindowStageManager: Bool`.

- [ ] **Step 1: Failing pure test FIRST.** `<scratch>/sm-test.swift`:
```swift
import AppKit
func eq(_ a: CGRect,_ b: CGRect,_ l: String){ if abs(a.minX-b.minX)>0.5||abs(a.minY-b.minY)>0.5||abs(a.width-b.width)>0.5||abs(a.height-b.height)>0.5 { print("FAIL",l,a,b); exit(1)}; print("ok:",l) }
let vf = CGRect(x: 100, y: 50, width: 1440, height: 900)
eq(WindowManager.effectiveVisibleFrame(vf, respectStageManager: false), vf, "off → unchanged")
// when on AND SM enabled, left inset by 64. On a machine where SM is OFF, stageManagerEnabled()==false so it's unchanged;
// to test the INSET math deterministically, also expose the pure inset:
eq(WindowManager.insetForStageManager(vf), CGRect(x: 164, y: 50, width: 1376, height: 900), "inset 64 left")
print("ALL PASS")
```
(Expose a pure `static func insetForStageManager(_ vf: CGRect) -> CGRect` so the inset math is testable regardless of the live SM state; `effectiveVisibleFrame` = `(respectStageManager && stageManagerEnabled()) ? insetForStageManager(vf) : vf`.)

- [ ] **Step 2: Run to fail.** `cd <scratch> && swiftc /Users/test/Documents/code/invoke-v2/apps/macos/Sources/InvokeServices/WindowPlacement.swift /Users/test/Documents/code/invoke-v2/apps/macos/Sources/InvokeServices/WindowManager.swift sm-test.swift -o smt && ./smt` → FAIL. (Append `-framework AppKit -framework ApplicationServices` if needed.)

- [ ] **Step 3: Implement in `WindowManager.swift`:**
```swift
    public var respectStageManager: Bool = false
    public static let stageManagerStripWidth: CGFloat = 64
    /// Best-effort: Stage Manager has no public reserved-strip API; inset the LEFT by a heuristic strip.
    public static func insetForStageManager(_ vf: CGRect) -> CGRect {
        CGRect(x: vf.minX + stageManagerStripWidth, y: vf.minY, width: max(0, vf.width - stageManagerStripWidth), height: vf.height)
    }
    public static func stageManagerEnabled() -> Bool {
        UserDefaults(suiteName: "com.apple.WindowManager")?.bool(forKey: "GloballyEnabled") ?? false
    }
    public static func effectiveVisibleFrame(_ vf: CGRect, respectStageManager: Bool) -> CGRect {
        (respectStageManager && stageManagerEnabled()) ? insetForStageManager(vf) : vf
    }
```
Then in `apply`, `applyRect`, `applyCycling`: after `guard let visible = screen?.visibleFrame else {...}`, use `let visible = Self.effectiveVisibleFrame(rawVisible, respectStageManager: respectStageManager)` (rename the guarded binding to `rawVisible` and compute `visible` from it; keep the rest using `visible`).

- [ ] **Step 4: `WindowEnumerator.swift`:** add `public var respectStageManager: Bool = false`; in `visibleAX(forCenter:)`, wrap the returned frame: `return WindowManager.effectiveVisibleFrame(Self.axRect(cocoaFrame: s.visibleFrame, primaryHeight: h), respectStageManager: respectStageManager)`. (Left inset is the same in AX coords.)

- [ ] **Step 5: `AppSettings.swift`:** add `@Published public var respectWindowStageManager: Bool { didSet { d.set(respectWindowStageManager, forKey: "respectWindowStageManager") } }` + init `respectWindowStageManager = d.object(forKey: "respectWindowStageManager") as? Bool ?? false` (mirror `windowCyclingEnabled`).

- [ ] **Step 6: Host sync (`AppController.swift`):** in `applyWindow(_:pid:)` (before `windowManager.applyCycling(...)`) add `windowManager.respectStageManager = AppSettings.shared.respectWindowStageManager`. In the custom-command + layout run closures (before `windowEnumerator.applyPlacement(...)`/`applyLayout(...)`) add `self.windowEnumerator.respectStageManager = AppSettings.shared.respectWindowStageManager`. (Sync-at-apply — always current, no observation needed.)

- [ ] **Step 7: Settings toggle (`SettingsView.swift` `GeneralPane`):** after the "Enable window cycling" toggle, add:
```swift
            Toggle("Respect Stage Manager", isOn: $settings.respectWindowStageManager)
            Text("Leaves room for the Stage Manager strip when positioning windows (best-effort).")
                .font(.caption).foregroundStyle(.secondary)
```

- [ ] **Step 8: Run test → ALL PASS; build; Commit.** swiftc test passes; `swift build --package-path apps/macos 2>&1 | tail -3` → `Build complete!`. `git add -A apps/macos/Sources && git commit -m "feat(wm): Respect Stage Manager toggle — best-effort visibleFrame inset when SM is on"`

---

### Task 2: Hotkey presets

**Files:** Modify `apps/macos/Sources/InvokeShell/AppController.swift`. Test: `<scratch>/preset-test.swift` (well-formedness — optional/inline).

- [ ] **Step 1: Define presets + apply.** In `AppController`, add a static table + an apply method:
```swift
    private static let windowHotkeyPresets: [(name: String, bindings: [(id: String, keyCode: UInt32, modifiers: UInt32, display: String)])] = {
        let ctrlOpt = UInt32(controlKey | optionKey)
        return [
            ("Arrows (⌃⌥)", [
                ("window.leftHalf", UInt32(kVK_LeftArrow), ctrlOpt, "⌃⌥←"),
                ("window.rightHalf", UInt32(kVK_RightArrow), ctrlOpt, "⌃⌥→"),
                ("window.topHalf", UInt32(kVK_UpArrow), ctrlOpt, "⌃⌥↑"),
                ("window.bottomHalf", UInt32(kVK_DownArrow), ctrlOpt, "⌃⌥↓"),
                ("window.maximize", UInt32(kVK_Return), ctrlOpt, "⌃⌥↩"),
            ]),
            ("Vim (⌃⌥ HJKL)", [
                ("window.leftHalf", UInt32(kVK_ANSI_H), ctrlOpt, "⌃⌥H"),
                ("window.bottomHalf", UInt32(kVK_ANSI_J), ctrlOpt, "⌃⌥J"),
                ("window.topHalf", UInt32(kVK_ANSI_K), ctrlOpt, "⌃⌥K"),
                ("window.rightHalf", UInt32(kVK_ANSI_L), ctrlOpt, "⌃⌥L"),
                ("window.maximize", UInt32(kVK_Return), ctrlOpt, "⌃⌥↩"),
            ]),
        ]
    }()
    private func applyWindowHotkeyPreset(_ name: String) {
        guard let preset = Self.windowHotkeyPresets.first(where: { $0.name == name }) else { return }
        for b in preset.bindings {
            AppSettings.shared.setHotkey(b.id, AppSettings.KeyCombo(keyCode: b.keyCode, modifiers: b.modifiers, display: b.display))
        }
        reloadCommandHotkeys()
        palette.showToast("Applied “\(name)” window hotkeys")
    }
```

- [ ] **Step 2: Chooser command.** In `makeCommands()` near the window commands, add:
```swift
            RootCommand(id: "window.presets", title: "Apply Window Hotkey Preset", subtitle: "Window Management", runTitle: "Choose", icon: "keyboard", keywords: ["window", "preset", "hotkey", "shortcut", "binding"], closesPalette: false) { [weak self] in self?.presentWindowPresetForm() },
```
Add `presentWindowPresetForm()` (mirror `presentQuicklinkForm`): a native form with a single `form-dropdown` (id "preset") whose items are the preset names (default the first), and on submit → `applyWindowHotkeyPreset(vals["preset"] ?? "")`. (Build the dropdown ViewNode like the existing form-dropdown construction ~line 3696; the submit reads the selected name.)

- [ ] **Step 3: Build, install (stable), relaunch, verify, Commit.** `swift build --package-path apps/macos 2>&1 | tail -3` → `Build complete!`; `INVOKE_SIGN_IDENTITY="Invoke Dev" bash scripts/build-app.sh 2>&1 | tail -4`; `ditto … /Applications/Invoke.app`; `pkill -9 -f "Invoke.app/Contents/MacOS/invoke"; sleep 2; open /Applications/Invoke.app`; ONE PID + `/tmp/invoke-run.log` clean + "Apply Window Hotkey Preset" discoverable. **HUMAN-REQUIRED:** run it → pick "Vim" → the WM commands rebind (visible in Settings → Extensions hotkeys); the Stage Manager toggle in Settings. `git add apps/macos/Sources/InvokeShell/AppController.swift && git commit -m "feat(wm): Apply Window Hotkey Preset (Arrows / Vim) — bulk-bind WM command hotkeys"`

---

## Self-Review
**1. Spec coverage:** Stage Manager (toggle + best-effort inset) → T1; presets → T2. ✅ Completes WM-1..5.
**2. Placeholder scan:** T1 has the pure inset/effective-frame code + test + the per-engine wiring; T2 has the full preset table + apply + the chooser (referencing the established form-dropdown + presentQuicklinkForm patterns). No placeholders.
**3. Type consistency:** `effectiveVisibleFrame(_:respectStageManager:)` / `insetForStageManager` / `respectStageManager` consistent across both engines + host. `respectWindowStageManager` AppSettings↔SettingsView↔host. Preset `(name,bindings[(id,keyCode,modifiers,display)])` consistent T2.
**Known risks (final-review triage):** (a) `stageManagerEnabled()` = "globally enabled," not "strip currently visible" → may inset when the strip isn't shown (best-effort, opt-in, default off — acceptable + documented). (b) the 64pt strip width is a heuristic. (c) sync-at-apply sets the flag before every apply (cheap; always current). (d) presets OVERWRITE existing WM hotkeys for covered commands (expected for a preset; toast confirms). (e) confirm the `screen.visibleFrame`→`effectiveVisibleFrame` swap preserves the existing coordinate handling in each of the 3 WindowManager sites + WindowEnumerator (the inset is a pure left-trim, coord-agnostic).
