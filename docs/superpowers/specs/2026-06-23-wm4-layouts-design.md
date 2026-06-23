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

## OPEN DECISION — the builder UX (needs the user's call)
How does the user define a multi-window layout? Three approaches:

**(A) Capture-current (snapshot)** — *recommended for v1.* Arrange your windows however you like, run "Create Window Layout Command", name it → it **snapshots the current on-screen windows' bounds** (via WM-2's `windowsOnActiveDesktop`, converted to fractions) as the layout's items. Simplest UI (just a name + a checklist of which captured windows to include), reuses WM-2, very usable. Deviates from Raycast's grid-designer but is a common, slick pattern.

**(B) Per-app grid designer** — *most Raycast-faithful.* A builder that lists layout items; "Add App" → pick a running app → assign a region with the WM-3 `WindowGridPicker` → repeat. Closest to Raycast's layout designer; the largest UI build (a multi-item editor mode).

**(C) Hybrid** — capture-current to seed the items, then tweak each item's region with the grid picker. Best UX, most effort.

(Settled parts above are identical regardless; only the builder differs. The plan's builder task is written once this is chosen.)

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
