# WM Builder Parity — Raycast-faithful position editor (Create Window Command + Layout) Design

**Part of the full Window-Management parity effort** (`[[window-management-parity]]`). The user supplied Raycast's real builder UX (2 screenshots, 2026-06-23) and chose **"match both"**: build ONE reusable position editor and use it in **Create Window Command** (revising the landed WM-3 grid-picker) AND **Create Window Layout** (WM-4, multi-app). **Supersedes** the WM-3 `WindowGridPicker` builder + the `2026-06-23-wm4-layouts.md` capture-current plan.

## Raycast's model (from the screenshots)
Both commands share one editor:
- **Live screen preview** — a scale model of the actual display (e.g. "Built-in Retina Display · 1512×982") with a translucent rectangle showing where each window lands.
- **Position** — a 3×3 grid of **9 anchors** (top-left/top/top-right · left/center/right · bottom-left/bottom/bottom-right).
- **Size** — W and H, each `Auto` (keep the window's current size) or a specific `pt` value.
- **Offset** — X / Y in `pt` (nudge from the anchor).
- **Create Window Command** = Name + one editor.
- **Create Window Layout** = Name & Icon + **"+ Add"** multiple apps (each: app picker + the editor); the preview shows all windows.

## Global constraints
- Faithful Raycast parity; **world-class UX** (the live preview + 9-anchor are the signature); commit on `main`.
- **Build/relaunch (MANDATORY):** `INVOKE_SIGN_IDENTITY="Invoke Dev" bash scripts/build-app.sh` → `ditto .build/Invoke.app /Applications/Invoke.app` → `pkill -9 -f "Invoke.app/Contents/MacOS/invoke"` → `open /Applications/Invoke.app`. See [[build-app-and-signing]].
- No Xcode/XCTest → pure logic via `swiftc`; AppKit/AX via build + relaunch + human. Ignore SourceKit false-positives when `swift build` succeeds.
- Engine is AX-native (top-left coords), in `WindowEnumerator` (`InvokeServices`); built-in halves/thirds/cycling keep their existing `WindowManager` path (unchanged).

## Settled — placement model + engine

### Model (replaces WM-3's fraction `CustomWindowCommand`; migration: old fraction customs are dropped — days-old dev feature, acceptable; note in plan)
```
enum Sizing: Codable { case auto; case points(Double) }
enum Anchor: Int, Codable { case topLeft, top, topRight, left, center, right, bottomLeft, bottom, bottomRight }  // col = raw%3, row = raw/3
struct WindowPlacement: Codable, Equatable { anchor: Anchor; width: Sizing; height: Sizing; offsetX: Double; offsetY: Double }
```
- `CustomWindowCommand { id; name; placement: WindowPlacement }` (Create Window Command).
- `WindowLayout { id; name; items: [Item] }`, `Item { bundleId; appName; placement: WindowPlacement }` (Create Window Layout).

### Engine (`WindowEnumerator`, AX-native, pure core)
```
static func placementRect(anchor: Anchor, width: Sizing, height: Sizing, offsetX: Double, offsetY: Double,
                          currentSize: CGSize, visibleAX: CGRect) -> CGRect
// w = width==.auto ? currentSize.width : pt ; h likewise
// col(left/center/right) → x = V.minX / V.minX+(V.w-w)/2 / V.maxX-w ; row(top/middle/bottom) → y = V.minY / V.minY+(V.h-h)/2 / V.maxY-h
// x += offsetX ; y += offsetY  → CGRect(x,y,w,h)   [AX top-left coords]
```
Pure + unit-tested (9 anchors × auto/pt size × offset). Then:
- `func applyPlacement(_ p: WindowPlacement, toWindow win: AXUIElement) -> Bool` (read current size + the window's screen visibleFrame → `placementRect` → AX set; reuses WM-2 AX helpers).
- `func applyPlacementToFocused(_ p: WindowPlacement) -> Bool` (frontmost focused window — Create Window Command).
- `func applyLayout(_ items: [(bundleId: String, placement: WindowPlacement)]) -> Int` (per app: main window → `applyPlacement`; skip non-running).

## The shared editor — `WindowPositionEditor` (`InvokePalette`)
A custom NSView, rendered as a `window-position-editor` form field (same form-field-type mechanism as WM-3's grid picker — `onFormFieldChange` reports the serialized placement; `formControls` getter returns it):
- **Preview**: a sub-view drawing a scale model of the main display's `visibleFrame` (aspect-correct) with a translucent accent rectangle = the current placement's resulting rect (computed via `placementRect` on a normalized preview frame). Live-updates as anchor/size/offset change.
- **9-anchor grid**: 9 buttons (SF Symbols matching Raycast's), single-select, highlights the chosen anchor.
- **Size**: W and H — each a text field accepting `Auto` (empty/"Auto") or a number (pt).
- **Offset**: X / Y pt text fields.
- Serialized value (for the form channel): a compact string `"anchor;wAuto|w;hAuto|h;offX;offY"` (e.g. `"0;Auto;Auto;0;0"` = top-left, auto size, no offset). Pure `parsePlacement(String) -> WindowPlacement?` / `serializePlacement(WindowPlacement) -> String` (unit-tested round-trip).

## Builders
- **Create Window Command** (revise WM-3): `presentCustomWindowForm` → native form: Name + one `window-position-editor`. Save → `CustomWindowCommand{name, placement}` → store + rebuild. Surfaced + bindable + ⌘K Edit/Delete (as WM-3, but the run uses `applyPlacementToFocused`).
- **Create Window Layout** (WM-4): `presentWindowLayoutForm` → Name + a dynamic list of app rows (each: an app-picker `form-dropdown` over running apps + a `window-position-editor`) + an "Add App" affordance (since the native form is static per render, "Add App" re-renders the form with one more app row — reuse the `enterNativeForm` re-entry, or a dedicated layout-builder mode that appends rows). Save → `WindowLayout{name, items:[{bundleId, placement}]}` → store + rebuild. Surfaced + bindable + ⌘K Edit/Delete; run → `applyLayout`.

## Error handling
No Accessibility → existing prompt path. Empty name / no anchor / (layout) no apps → no command. Layout app not running → skipped (toast "positioned N of M").

## Testing strategy
- **Pure (standalone swift):** `placementRect` (9 anchors, auto vs pt size, offsets, against a non-zero-origin visibleFrame); `serializePlacement`/`parsePlacement` round-trip; `WindowPlacement`/model Codable round-trip.
- **AppKit/integration (build + relaunch + human):** the editor (preview tracks anchor/size/offset), Create Window Command, Create Window Layout (Add apps, multi-window apply), binding, Edit/Delete.

## Decomposition (plan)
1. **Model + engine** — `Sizing`/`Anchor`/`WindowPlacement` (in a shared spot both modules can use) + `placementRect` (pure) + `applyPlacement`/`applyPlacementToFocused`/`applyLayout` (WindowEnumerator) + `serialize/parsePlacement` (pure). Update `AppSettings.CustomWindowCommand` → placement; add `WindowLayout`. (Pure-heavy; standalone tests.)
2. **`WindowPositionEditor`** component + `window-position-editor` form-field render (preview + 9-anchor + size + offset). (Big UI; pure serialize/preview-rect tested.)
3. **Create Window Command** revised to the editor (replace grid picker) + migration note.
4. **Create Window Layout** builder (multi-app) + surfacing + Edit/Delete + build/relaunch/verify.

## Out of scope / deferred
- WM-5 Respect Stage Manager + presets.
- URL/Quicklink/File layout targets (Raycast allows them) — apps only for v1; note.
- Per-display preview selection (preview the main display; apply on each window's current display).
- The landed `WindowGridPicker` is replaced by `WindowPositionEditor` (remove or leave dormant — plan decides).
