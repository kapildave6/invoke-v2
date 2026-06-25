# WM-5 — Respect Stage Manager + Hotkey Presets Design

**Part of the full Window-Management parity effort** (`[[window-management-parity]]`, the LAST chunk). Closes the two remaining Raycast WM items: a **Respect Stage Manager** toggle and **hotkey preset packs**. Both are honest polish — Stage-Manager handling is best-effort (no public API for the reserved strip), and per-command hotkeys already exist, so presets are a bulk-apply convenience.

## Global constraints
- Faithful Raycast parity; world-class UX; commit on `main`.
- **Build/relaunch (MANDATORY):** `INVOKE_SIGN_IDENTITY="Invoke Dev" bash scripts/build-app.sh` → `ditto .build/Invoke.app /Applications/Invoke.app` → `pkill -9 -f "Invoke.app/Contents/MacOS/invoke"` → `open /Applications/Invoke.app`. See [[build-app-and-signing]].
- No Xcode/XCTest → pure logic via `swiftc`; AppKit/AX via build + relaunch + human. Ignore SourceKit false-positives when `swift build` succeeds.
- WM engines stay in `InvokeServices` (no `InvokeShell`/`AppSettings` dep — the flag is set on the engine by the host).

## Item 1 — Respect Stage Manager
**Detection (InvokeServices-safe):** Stage Manager is "enabled" when `UserDefaults(suiteName: "com.apple.WindowManager")?.bool(forKey: "GloballyEnabled") == true`. (No public API tells us the exact reserved-strip width or whether the strip is currently visible, so this is best-effort.)

**Behavior:** when the user opts in (toggle, default **off** — matches Raycast's default), WM positioning should avoid the Stage-Manager strip on the left. Implement a shared **effective visible frame**:
- Add `var respectStageManager: Bool = false` to `WindowManager` (and `WindowEnumerator`), set by the host from `AppSettings`.
- Add `static func effectiveVisibleFrame(_ vf: CGRect, respectStageManager: Bool) -> CGRect`: when `respectStageManager && stageManagerEnabled()`, inset the LEFT by a strip constant (`stageManagerStripWidth = 64`) → `CGRect(x: vf.minX + 64, y: vf.minY, width: vf.width - 64, height: vf.height)`; else `vf`. (Pure given a precomputed `respectStageManager`/enabled bool — unit-test the inset math; `stageManagerEnabled()` reads the default.)
- Replace the `screen.visibleFrame` reads in `WindowManager.apply`/`applyRect`/`applyCycling` (and `WindowEnumerator.visibleAX`) with `effectiveVisibleFrame(screen.visibleFrame, respectStageManager: self.respectStageManager)`.

**Persistence + UI:** `AppSettings.respectWindowStageManager: Bool` (default false) + a Settings toggle ("Respect Stage Manager" — caption: "Leaves room for the Stage Manager strip when positioning windows"). On change (+ at startup) the host sets `windowManager.respectStageManager` / `windowEnumerator.respectStageManager`.

## Item 2 — Hotkey presets
A **preset** is a named map of WM command → `KeyCombo`, applied in bulk (the per-command hotkey mechanism already exists via `AppSettings.setHotkey`). Two presets (faithful, bounded):
- **"Arrows (⌃⌥)"** — the current defaults: Left/Right/Top/Bottom Half ← → ↑ ↓, Maximize ↩, quarters via ⌃⌥U/I/J/K (or omit quarters). (Mirrors macOS-tiling defaults.)
- **"Vim (⌃⌥ HJKL)"** — Left/Right/Top/Bottom Half = H/L/K/J, Maximize = Return.

**UI:** a root command **"Apply Window Hotkey Preset"** (id `window.presets`) → a native chooser (the existing in-palette list/form) of the presets → applying sets each command's hotkey (`AppSettings.setHotkey`) + `reloadCommandHotkeys()` + a confirmation toast. (Define presets as a static `[(name, [(commandId, keyCode, modifiers, display)])]`.)

## Error handling
- SM default unreadable → treat as not-enabled (no inset). 
- Applying a preset overwrites existing WM hotkeys for the covered commands (expected; that's what a preset does) — the toast says which preset was applied.

## Testing strategy
- **Pure (standalone swift):** `effectiveVisibleFrame` (inset when on+enabled; unchanged when off; the 64pt left inset math) + preset maps are well-formed (no dup commandIds within a preset).
- **AppKit/integration (build + relaunch + human):** the Settings toggle flips `respectStageManager` (windows leave the strip when SM on + toggle on); "Apply Window Hotkey Preset" binds the scheme (visible in Settings → Extensions hotkeys). (SM behavior needs SM actually on + eyes.)

## Decomposition (plan)
1. **Stage Manager** — `effectiveVisibleFrame` + `stageManagerEnabled()` + `respectStageManager` flag in both engines + replace visibleFrame reads; `AppSettings.respectWindowStageManager` + host wiring + Settings toggle. Pure inset test.
2. **Presets** — preset definitions + "Apply Window Hotkey Preset" command + apply (setHotkey + reload + toast). Pure preset-wellformed test; build/relaunch/verify.

## Out of scope (note)
- Exact Stage-Manager strip width / live strip-visibility detection (no public API — 64pt heuristic, opt-in).
- Importing third-party (Magnet/Rectangle) configs.
- This completes the user-scoped full WM parity (WM-1..5 + the two-pane designer).
