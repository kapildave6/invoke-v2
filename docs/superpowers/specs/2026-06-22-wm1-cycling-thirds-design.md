# WM-1 — Window Management engine depth: cycling + thirds Design

**Part of the full Window-Management parity effort** (`[[window-management-parity]]`, chunk 1 of 5: WM-1 → WM-2 extension API → WM-3 custom commands → WM-4 layouts → WM-5 Stage Manager/presets). User-approved scope (2026-06-22): cycling **always-on + a single global toggle**, plus discrete thirds/two-thirds commands. Two YAGNI calls approved-by-default under the standing autonomous-parity authorization: cycling on **Left/Right Half only** (not Top/Bottom) and **horizontal thirds only** (no vertical) — revisit if the user objects.

## Global constraints
- Faithful Raycast parity; world-class UX; commit on `main`; relaunch after build.
- No Xcode/XCTest → pure logic via standalone `swift` scripts; AppKit/AX via `swift build --package-path apps/macos` + `scripts/build-app.sh` + relaunch + human visual. Ignore SourceKit false-positives when `swift build` succeeds.
- Reuse the existing engine: `WindowManager.apply(_:pid:)` + `rect(for:in:)` (`InvokeServices/WindowManager.swift`); `applyWindow(_:pid:)` (`AppController.swift:443`); the `windowCommand(...)` factory + command list (`AppController.swift:4069`/`4111`); `AppSettings` persistence; the existing per-command hotkey UI (already covers binding new commands — nothing to add there).

## Item 1 — New positions (`WindowManager.Action` + pure `rect(for:in:)`)
Add five full-height horizontal cases; each is an exact fraction of the visible frame `vf` (origin `x,y`, size `w,h`):
- `leftThird` → `(x, y, w/3, h)`
- `centerThird` → `(x + w/3, y, w/3, h)`
- `rightThird` → `(x + 2w/3, y, w/3, h)`
- `leftTwoThirds` → `(x, y, 2w/3, h)`
- `rightTwoThirds` → `(x + w/3, y, 2w/3, h)`

Pure math (no AX) → unit-testable against a known `vf`. (Vertical thirds: out of scope — YAGNI.)

## Item 2 — Cycling engine (in `WindowManager`, with a pure decision)
Cycling makes a directional command, pressed repeatedly **on the same window**, step ½ → ⅔ → ⅓ (wrapping). The base `Action` is the cycle key (no command-id needed — `.leftHalf`/`.rightHalf` are distinct).

**Sequences:** `leftHalf → [leftHalf, leftTwoThirds, leftThird]`; `rightHalf → [rightHalf, rightTwoThirds, rightThird]`; any other base → `[base]` (length 1 → single-shot, idempotent). Encapsulated in `WindowManager.cycleSequence(for:) -> [Action]`.

**Pure decision** (unit-testable; takes a precomputed `frameMatches` bool so it has no AX dependency):
```
func cycleStep(base: Action,
               last: (base: Action, pid: pid_t, step: Int)?,
               pid: pid_t,
               frameMatches: Bool,
               enabled: Bool) -> Int
// enabled && last?.base == base && last?.pid == pid && frameMatches
//   → (last!.step + 1) % cycleSequence(for: base).count
// else → 0
```

**Stateful wrapper** `applyCycling(_ base: Action, pid: pid_t, enabled: Bool) -> Bool`:
1. Read the window's current Cocoa frame (existing private `frame(of:)` path; expose what's needed).
2. `frameMatches = |current − expectedRect| < tol` componentwise against the **last commanded** rect (stored — NOT the resulting frame, so an app that clamps its min-size simply fails the match next press and the cycle restarts at ½; acceptable edge case).
3. `step = cycleStep(base:, last:, pid:, frameMatches:, enabled:)`; `concrete = cycleSequence(for: base)[step]`.
4. `apply(concrete, pid:)`; store `last = (base, pid, step)` and `expectedRect =` the rect just commanded (`rect(for: concrete, in: visibleFrame)`).
5. Reset `last = nil` on any `apply` failure.

`tol`: a few points (e.g. 6pt) — far below the ≥ w/6 gap between ½/⅔/⅓, so no cross-position false match.

## Item 3 — Integration (`applyWindow` routes through the engine)
`applyWindow(_:pid:)` (`AppController.swift:443`) calls `windowManager.applyCycling(action, pid:, enabled: AppSettings.shared.windowCyclingEnabled)` instead of `apply(action, pid:)`. Single integration point — both palette-invoked commands (`windowCommand`'s closure) and per-command hotkeys already go through `applyWindow`, so they get cycling for free. Non-cycling actions (`maximize`, quarters, the new discrete thirds) flow through with a length-1 sequence (unchanged behavior).

## Item 4 — New root commands
Append to the `windowCommand(...)` list (`AppController.swift:4111`), faithful Raycast names + SF Symbols + keywords, **no seeded hotkeys** (the user binds them via the existing Settings → Extensions hotkey UI):
- `window.firstThird` "First Third" (`leftThird`) · `window.centerThird` "Center Third" (`centerThird`) · `window.lastThird` "Last Third" (`rightThird`)
- `window.firstTwoThirds` "First Two-Thirds" (`leftTwoThirds`) · `window.lastTwoThirds` "Last Two-Thirds" (`rightTwoThirds`)

(Left/Right Half commands unchanged in the list — cycling is applied in `applyWindow`, not the command definition.)

## Item 5 — Settings
`AppSettings.windowCyclingEnabled: Bool` (persisted, default **true**), with `var`-style getter/setter mirroring existing bool prefs. A single "Enable window cycling" toggle in the Settings window's Window-Management/General area (subtitle: "Repeating a Left/Right Half command cycles ½ → ⅔ → ⅓"). Read in `applyWindow`.

## Error handling
Unchanged: `apply` returns false without Accessibility / a focused window; `applyWindow` already prompts for the grant + shows a toast. Cycle state resets to `nil` on failure, so the next press starts clean at ½.

## Testing strategy
- **Pure (standalone swift):** (a) `rect(for:in:)` for the 5 new cases vs a known `vf` (exact fractions); (b) `cycleStep` truth table — new→0; match→advance (0→1→2); wrap (2→0); `frameMatches=false`→0; different base→0; different pid→0; disabled→0; length-1 base (`maximize`)→stays 0.
- **Integration (build + relaunch + human):** ⌃⌥← (Left Half) pressed repeatedly → left ½ → ⅔ → ⅓ → ½; the 5 discrete commands position correctly; toggle off in Settings → repeats stay at ½. (No fixture extension — this is first-party UI; the AX move/resize needs eyes + a granted Accessibility permission.)

## Out of scope (later WM chunks)
- Extension `WindowManagement` API (WM-2). Custom commands (WM-3). Multi-window layouts (WM-4). Respect Stage Manager + preset packs (WM-5).
- Per-command Raycast-style "Cycling: None / ½⅔⅓" dropdown (we chose a single global toggle); vertical thirds; Top/Bottom-half cycling.
