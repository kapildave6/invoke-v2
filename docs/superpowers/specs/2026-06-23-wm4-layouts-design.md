# WM-4 — Create Window Layout Command (multi-window) Design

**Part of the full Window-Management parity effort** (`[[window-management-parity]]`, chunk 4 of 5 — the largest). A **Window Layout** arranges *multiple* apps' windows at once (e.g. "Coding": VS Code left ⅔, Terminal right ⅓). Saved as a bindable command that positions every app in the layout. Builds on WM-1 (`applyRect`) + WM-2 (`WindowEnumerator`) + WM-3 (`WindowGridPicker`, the store/builder pattern).

## Global constraints
- Faithful Raycast parity; **world-class UX**; commit on `main`.
- **Build/relaunch (MANDATORY):** `INVOKE_SIGN_IDENTITY="Invoke Dev" bash scripts/build-app.sh` → `ditto .build/Invoke.app /Applications/Invoke.app` → `pkill -9 -f "Invoke.app/Contents/MacOS/invoke"` → `open /Applications/Invoke.app` (NEVER ad-hoc). See [[build-app-and-signing]].
- No Xcode/XCTest → pure logic via standalone `swiftc`; AppKit/AX via build + relaunch + human. Ignore SourceKit false-positives when `swift build` succeeds.
- Reuse: `WindowManager.applyRect`/`rectFromFractions` (WM-1); `WindowEnumerator` AX enumeration + per-app window resolution (WM-2); `WindowGridPicker` + the `AppSettings` store + `makeCommands` surfacing + ⌘K Edit/Delete patterns (WM-3).

## Settled design (model, engine, surfacing)

### Model + store (`AppSettings`)
```
struct WindowLayout: Codable, Equatable { id: String; name: String; items: [Item] }
struct WindowLayout.Item: Codable, Equatable { bundleId: String; appName: String; fx, fy, fw, fh: Double }
```
`AppSettings.windowLayouts: [WindowLayout]` (JSON-persisted; mirror `customWindowCommands`) + add/remove/update CRUD. `id` = `"window.layout.<uuid>"`.

### Apply engine (`WindowManager` / `WindowEnumerator`)
`func applyLayout(_ items: [(bundleId: String, fx: Double, fy: Double, fw: Double, fh: Double)]) -> Int` (returns #positioned). For each item: find the running app by `bundleId` (`NSRunningApplications`), get its main/frontmost window via AX (`kAXMainWindow` → fallback `kAXWindows.first`), and apply `rectFromFractions` on that window's screen's `visibleFrame` (same AX set path). Apps not running → skipped (counted as skipped). Pure-testable: the per-item resolution decision + the rect math; the AX is human-verified.

### Surfacing (`AppController`)
- `window.layout.create` "Create Window Layout Command" → the builder (below).
- Each stored layout → a `RootCommand` (icon `rectangle.3.group`, subtitle "Window Management", run → `applyLayout(items)` Accessibility-guarded) appended in `makeCommands()`, bindable via Settings.
- ⌘K Edit/Delete on layout commands (mirror WM-3's `window.layout.` branch in `currentActions()`).

## Builder UX — RESOLVED: (A) Capture-current (user choice, 2026-06-23)
Arrange windows by hand → run "Create Window Layout Command" → a **checklist of the current on-screen windows** (each row: app name + a human description of its current position, pre-ticked) + a **Name** field → Save. On save, each ticked window's current bounds → **fractions relative to its screen's `visibleFrame`** (so re-applying via `applyRect` round-trips exactly) → stored as the layout's items. Reuses WM-2's `windowsOnActiveDesktop`. The checklist + name fit the native-form system (`form-checkbox` per window + a `form-textfield` name). (Deferred: (B) per-app grid designer / (C) hybrid tweak — future enhancement.)

**Capture math (pure, testable):** `boundsToFractions(winAX: CGRect, screenVisibleAX: CGRect) -> (fx,fy,fw,fh)` = `((winX - svX)/svW, (winY - svY)/svH, winW/svW, winH/svH)` — all in AX top-left space; the exact inverse of `rectFromFractions` against `visibleFrame`. `screenVisibleAX` = the window's screen `visibleFrame` converted to AX coords via WM-2's `axRect`.

## Error handling
- No Accessibility → the existing prompt path (WM-1/2/3). 
- Empty name / no items → no command created.
- An app in the layout isn't running → skipped (optionally a toast "positioned N of M; X not running"). Layout still applies to the running ones.

## Testing strategy
- **Pure (standalone swift):** layout item→fractions conversion (capture path) / the per-item apply resolution; `WindowLayout` Codable round-trip.
- **AppKit/integration (build + relaunch + human):** the builder, capturing/positioning multiple real windows, the layout command + binding, Edit/Delete. (Needs eyes + Accessibility — now stable via "Invoke Dev".)

## Out of scope (WM-5 / deferred)
- WM-5 Respect Stage Manager + preset packs.
- Cross-display / cross-Space layout placement beyond best-effort (each window positioned on its current display).
- Launching apps that aren't running (v1 positions only running apps; auto-launch is a future enhancement).
