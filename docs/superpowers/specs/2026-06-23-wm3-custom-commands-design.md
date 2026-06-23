# WM-3 — Create Window Management Command (custom positions) Design

**Part of the full Window-Management parity effort** (`[[window-management-parity]]`, chunk 3 of 5). User-approved (2026-06-23): a **visual grid picker** to define a custom window position, saved as a bindable root command. Builds on WM-1's engine.

## Global constraints
- Faithful Raycast parity; **world-class UX** (the grid picker must feel native, like Raycast's); commit on `main`.
- **Build/relaunch:** `INVOKE_SIGN_IDENTITY="Invoke Dev" bash scripts/build-app.sh` → `ditto .build/Invoke.app /Applications/Invoke.app` → `pkill -9 -f "Invoke.app/Contents/MacOS/invoke"` → `open /Applications/Invoke.app` (NEVER ad-hoc — breaks the Accessibility grant). See [[build-app-and-signing]].
- No Xcode/XCTest → pure logic via standalone `swiftc`; AppKit/AX via build + relaunch + human visual. Ignore SourceKit false-positives when `swift build` succeeds.
- Reuse: `WindowManager` (WM-1) + `applyWindow`; `AppSettings` JSON persistence (mirror `quicklinks`/`snippets` stores); the `makeCommands()` root-command list + `windowCommand` pattern (`AppController.swift:4116`); the existing per-command hotkey UI (custom commands get ids → bindable automatically); the native-form / custom-mode rendering used by Clipboard/Emoji/Quicklink builders.

## Architecture (4 units)

### 1. Engine — arbitrary fractional rect (`WindowManager`)
Add `applyRect(fx:fy:fw:fh:pid:) -> Bool` (fractions 0…1 of the visible frame): target = `CGRect(x: vf.minX + fx*vf.w, y: vf.minY + fy*vf.h, width: fw*vf.w, height: fh*vf.h)`, applied via the existing AX `set(...)` (same screen-resolution + coordinate-flip path as `apply`). A pure `rectFromFractions(fx,fy,fw,fh, in: vf)` helper is unit-tested.

### 2. Model + store (`AppSettings`)
```
struct CustomWindowCommand: Codable, Equatable { id: String; name: String; fx, fy, fw, fh: Double }
```
`AppSettings.customWindowCommands: [CustomWindowCommand]` (persisted as JSON, mirroring `fallbackCommands`/quicklinks) + `addCustomWindowCommand`, `removeCustomWindowCommand(id:)`, `updateCustomWindowCommand`. `id` = `"window.custom.<uuid>"` (namespaced so hotkey binding + matchCommands treat it like any command).

### 3. Visual grid picker (`InvokePalette`, custom NSView)
`WindowGridPicker: NSView` — a **12×8** grid (12 cols, 8 rows → clean halves/thirds/quarters/sixths). Click-drag selects a rectangular cell region; the selection highlights live; a caption shows the resulting fraction (e.g. "Left ½", "⅔ × 100%", or "50% × 75%"). On mouse-up, the selection → fractional bounds via the **pure** mapping `gridSelectionToFractions(c0,r0,c1,r1, cols:12, rows:8)` → `(fx, fy, fw, fh)` snapped to 1/12 × 1/8. The pure mapping is unit-tested (drag corners → exact fractions, normalization of reversed drags, single-cell, full-grid). The NSView interaction is human-verified.

### 4. Builder flow + surfacing (`AppController`)
- **Create entry:** a root command `window.custom.create` "Create Window Management Command" (Window Management subtitle) → enters a builder surface hosting the `WindowGridPicker` + a Name field + Save/Cancel. (Hosted like the existing custom modes — a dedicated mode, NOT the field-only native form, since it needs the grid view.)
- **Save:** validates a non-empty name + a non-empty selection → `AppSettings.addCustomWindowCommand(...)` → rebuilds the command list so the new command appears immediately (the lazy `commands` is rebuilt + `reloadCommandHotkeys()`).
- **Surface:** `makeCommands()` appends one `RootCommand` per stored `CustomWindowCommand` (icon `macwindow`, subtitle "Window Management", keywords from the name), whose run = `applyWindow`-equivalent for the custom rect (`windowManager.applyRect(fx,fy,fw,fh, pid:)` via the same Accessibility-guarded path as `applyWindow`). They're bindable via Settings → Extensions (they're RootCommands with ids) — nothing extra needed.
- **Manage (edit/delete):** the custom command's ⌘K Action Panel offers "Edit…" (reopens the builder pre-filled) + "Delete" (removes from the store + rebuilds). (Minimal; a dedicated Settings list is optional/deferred.)

## Data flow
Create command → builder (grid + name) → Save → store + rebuild → custom RootCommand in root search + bindable hotkey → run → `applyRect` (AX move/resize, Accessibility-guarded with the WM-2 prompt) → window positioned.

## Error handling
- No Accessibility → the existing `applyWindow` prompt path (WM-1/WM-2). 
- Empty name or empty selection → Save disabled / a toast; no command created.
- Stale stored command (none) — custom commands are self-contained fractions, always valid.

## Testing strategy
- **Pure (standalone swift):** `rectFromFractions(...)` (engine) + `gridSelectionToFractions(...)` (picker mapping) — exact-fraction truth tables incl. reversed drags, single cell, full grid, halves/thirds.
- **Store:** `AppSettings` add/remove/update round-trip (can be a pure-ish test or code-inspection + the integration check).
- **AppKit/integration (build + relaunch + human):** the grid picker interaction, the builder flow, the custom command appearing in root + positioning a window, edit/delete, hotkey binding. (Needs eyes + a granted Accessibility permission — now stable via "Invoke Dev".)

## Out of scope (later WM chunks / deferred)
- WM-4 multi-window layouts; WM-5 Stage Manager + presets.
- A dedicated Settings management list for custom commands (⌘K Edit/Delete suffices for v1).
- Non-grid-snapped arbitrary pixel positions (the 12×8 snap covers the common layouts; finer control is a future enhancement).
- Multi-display target selection in the builder (custom rect applies on the window's current display, like the built-ins).
