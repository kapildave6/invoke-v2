# WM Layout Designer — Raycast two-pane builder Design

**Part of the full Window-Management parity effort** (`[[window-management-parity]]`). The user supplied Raycast's real "Create Window Layout" UX (screenshots, 2026-06-25) and flagged the current native-form builder as **bad UI** (cramped vertical scroll, "Add App" buried below the fold, plain preview box). **Supersedes** the native-form layout builder (`presentWindowLayoutForm`) + the `window-position-editor`-in-a-form approach for layouts. Builds on the existing model/engine (`WindowPlacement`, `placementRect`, `applyPlacement`/`applyLayout`, `AppSettings.WindowLayout`/`CustomWindowCommand`).

## Raycast's design (from the screenshots) — the target
A **two-pane modal**, wider than the command bar:
- **Left preview pane:** a scale mockup of the display (rounded bezel, subtle wallpaper, "Built-in Retina Display · 1512×982" caption). Every app in the layout is drawn as a **translucent window rectangle** (its `placementRect` scaled to the preview), with window chrome (`•••` traffic lights) + the **app icon centered**. The **selected** app's rect is **accent-blue**; others are gray. **Clicking a window rect selects that app.** A prominent **"+ Add"** button sits above the preview.
- **Right inspector pane** (for the SELECTED app): title "Create Window Layout" + icon; **Name & Icon** (name field + icon dropdown); the selected app's **app dropdown** + a **delete (trash)** button; a "URL, Quicklink or File" field; **Size** (W / H — `Auto` or pt + an (i)); **Position** (the 3×3 **9-anchor** grid); **Offset** (X / Y pt). **Cancel / Save** at the bottom-right.
- **No scrolling.** Fixed two-pane.

## Global constraints
- Faithful Raycast parity; **world-class UX** (this is the headline); commit on `main`.
- **Build/relaunch (MANDATORY):** `INVOKE_SIGN_IDENTITY="Invoke Dev" bash scripts/build-app.sh` → `ditto .build/Invoke.app /Applications/Invoke.app` → `pkill -9 -f "Invoke.app/Contents/MacOS/invoke"` → `open /Applications/Invoke.app`. See [[build-app-and-signing]].
- No Xcode/XCTest → pure logic via `swiftc`; AppKit via build + relaunch + human. Ignore SourceKit false-positives when `swift build` succeeds.
- Reuse the built model/engine; do NOT reimplement placement math. `WindowLayoutDesigner` lives in `InvokePalette` (already depends on `InvokeServices`).

## Architecture — a dedicated two-pane designer (NOT the native form)
The native-form (vertical field list) can't express the two-pane preview+inspector, and the palette is too narrow. Build a **dedicated modal `NSWindow`** (`WindowLayoutDesigner`, in `InvokePalette`) — a centered panel (~900×560), Raycast-style:

### Components
1. **`LayoutDesignerWindow: NSWindow`** (or a controller owning a borderless titled panel) — hosts the two panes; key window; Esc = Cancel, ⌘↵ = Save. Centered over the screen, dimmed backdrop.
2. **`LayoutPreviewView: NSView`** (left, `isFlipped` for AX-y-down): draws the display mockup + each item's window rect via `WindowEnumerator.placementRect(item.placement, currentSize: repSize, visibleAX: previewInner)` scaled to the pane; app icon (`NSWorkspace.shared.icon(forFile: appPath)`) centered; selected = accent fill + border, others = gray. `mouseDown` → hit-test which rect → select that item (callback). The "+ Add" button + display caption.
3. **`LayoutInspectorView: NSView`** (right): Name field; the selected item's app `NSPopUpButton` (running regular apps, with icons) + a trash button; Size W/H `NSTextField`s (Auto/pt); a 9-anchor grid (9 `NSButton`s, single-select, SF Symbols matching Raycast); Offset X/Y `NSTextField`s; Cancel/Save buttons. Edits mutate the selected item's `WindowPlacement` → notify → preview redraws.
4. **Model/state (controller):** `name: String`, `items: [(bundleId, appName, appIconPath, placement)]`, `selected: Int`. **+ Add** → append a default app (first running app not already added) at `.center`/`.auto` + select it. **Delete** → remove selected, reselect a neighbor. Inspector change → update `items[selected].placement` → preview redraw.
5. **Save** → build `[AppSettings.WindowLayout.Item]` → `addWindowLayout(name:items:)` (or update when editing) → close → the host rebuilds commands. **Cancel/Esc** → close, no change.

### Single-window "Create Window Command"
Reuse the SAME designer with `mode = .singleWindow`: ONE implicit target (the frontmost window at run), so hide the app list / "+ Add" / app-dropdown; show just the preview (one rect) + Size/Position/Offset inspector + Name. Save → `CustomWindowCommand{name, placement}`. (Keeps both builders visually consistent + ditches the cramped form.)

## Host integration (`AppController`)
- `window.layout.create` / a layout's Edit → present `LayoutDesignerWindow` in `.layout` mode (seeded from the editing layout or empty); on Save callback → `addWindowLayout`/`updateWindowLayout` + rebuild + `reloadCommandHotkeys`.
- `window.custom.create` / a custom command's Edit → present it in `.singleWindow` mode; on Save → `addCustomWindowCommand`/`update`.
- Remove the old `presentWindowLayoutForm` + `presentCustomWindowForm` native-form code + the `window-position-editor` form-field plumbing IF fully replaced (or leave the field type if still used elsewhere — it isn't; remove). The transient `palette.onFormFieldChange` override + `layoutBuilder*` state in `AppController` go away (the designer owns its own state) — simplifies the earlier fix.

## Error handling
No Accessibility (run time) → existing prompt. Empty name / no apps (layout) → Save disabled. Designer window dismiss is self-contained (no shared-callback leak — the override hack is gone).

## Testing strategy
- **Pure (already covered):** `placementRect` (the preview + apply both use it). A new pure helper if any (e.g. preview-rect scaling) gets a standalone test.
- **AppKit/integration (build + relaunch + human):** the two-pane designer — Add/Delete apps, click-to-select, inspector edits live-update the preview, Save persists + the layout runs, single-window mode. (Inherently visual; needs eyes + Accessibility — now stable via "Invoke Dev".)

## Decomposition (plan)
1. **`LayoutPreviewView`** — the live multi-window preview (mockup + per-app rects + icons + selection + click-to-select + "+ Add"). Pure preview-rect scaling tested.
2. **`LayoutInspectorView`** — Name + app dropdown + delete + Size + 9-anchor Position + Offset; emits placement/selection/name changes.
3. **`LayoutDesignerWindow` + controller** — assembles the two panes, owns the `items`/`selected`/`name` state, Add/Delete/select wiring, Save/Cancel; both `.layout` and `.singleWindow` modes.
4. **Host integration** — wire `window.layout.create`/Edit + `window.custom.create`/Edit to the designer; remove the old native-form builders + the `onFormFieldChange` override; build/relaunch/verify.

## Out of scope (defer / note)
- Icon picker for "Name & Icon" (use a default layout icon for v1).
- "URL / Quicklink / File" layout targets (apps only for v1).
- Drag-to-resize windows directly in the preview (Raycast supports anchor+size; direct-drag is a further enhancement).
- WM-5 (Respect Stage Manager + presets) — still the last separate chunk after this.
