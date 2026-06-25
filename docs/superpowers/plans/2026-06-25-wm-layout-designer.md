# WM Layout Designer — Raycast two-pane builder Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Replace the cramped native-form window builders with a Raycast-style **two-pane designer** — a live desktop preview (all app windows, click-to-select) on the left + an inspector (Name, app dropdown+delete, Size, 9-anchor Position, Offset) on the right — for both Create Window Layout (multi-app) and Create Window Command (single window).

**Architecture:** A dedicated modal `NSWindow` (`LayoutDesignerWindow`, in `InvokePalette`) hosting `LayoutPreviewView` (left) + `LayoutInspectorView` (right). It owns its `name`/`items`/`selected` state and reuses the existing `WindowPlacement`/`placementRect`/`AppSettings` model+engine. `AppController` presents it for the create/edit commands and persists on Save; the old native-form builders + the `palette.onFormFieldChange` override are removed.

**Tech Stack:** Swift / AppKit (`InvokePalette` + `AppController`). Pure scaling logic via `swiftc`; the UI via build + relaunch + human visual.

## Global Constraints
- Faithful Raycast parity; **world-class UX**; commit on `main`.
- **Build/relaunch (MANDATORY — never ad-hoc):** `INVOKE_SIGN_IDENTITY="Invoke Dev" bash scripts/build-app.sh` → `ditto apps/macos/.build/Invoke.app /Applications/Invoke.app` → `pkill -9 -f "Invoke.app/Contents/MacOS/invoke"` → `open /Applications/Invoke.app` → verify ONE PID.
- No Xcode/XCTest → pure logic via `swiftc`; AppKit via build + relaunch + human. **Ignore SourceKit false-positives when `swift build` prints `Build complete!`**.
- Reuse `WindowEnumerator.placementRect` for BOTH the preview rects and the real apply (one source of truth). `InvokePalette` already depends on `InvokeServices`.

## Shared types (Task 1 defines; all tasks use)
```swift
// One row in the designer (UI-side; maps to AppSettings.WindowLayout.Item on save).
struct DesignerItem { var bundleId: String; var appName: String; var appPath: String?; var placement: WindowPlacement }
enum DesignerMode { case layout; case singleWindow }
```

---

### Task 1: `LayoutPreviewView` — live multi-window preview

**Files:** Create `apps/macos/Sources/InvokePalette/LayoutPreviewView.swift`. Test: `<scratch>/preview-scale-test.swift` (`<scratch>` = `/private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad`).

**Interfaces:** `LayoutPreviewView: NSView` with `var items: [DesignerItem]`, `var selected: Int`, `var onSelect: ((Int) -> Void)?`, `var onAdd: (() -> Void)?`; pure `static func scaledRect(_ ax: CGRect, fromVisible: CGRect, toPreview: CGRect) -> CGRect`.

- [ ] **Step 1: Failing pure test FIRST.** `<scratch>/preview-scale-test.swift`:
```swift
import AppKit
func ck(_ c: Bool, _ l: String){ if !c { print("FAIL",l); exit(1)}; print("ok:",l) }
func eq(_ a: CGRect,_ b: CGRect,_ l: String){ ck(abs(a.minX-b.minX)<0.5 && abs(a.minY-b.minY)<0.5 && abs(a.width-b.width)<0.5 && abs(a.height-b.height)<0.5, l) }
let vis = CGRect(x: 0, y: 0, width: 1440, height: 900)
let pv = CGRect(x: 10, y: 10, width: 720, height: 450) // half-scale, offset origin
// a left-half AX rect → left-half of the preview
eq(LayoutPreviewView.scaledRect(CGRect(x: 0, y: 0, width: 720, height: 900), fromVisible: vis, toPreview: pv), CGRect(x: 10, y: 10, width: 360, height: 450), "left-half scaled")
// a centered 800x600 → scaled+offset
eq(LayoutPreviewView.scaledRect(CGRect(x: 320, y: 150, width: 800, height: 600), fromVisible: vis, toPreview: pv), CGRect(x: 10+160, y: 10+75, width: 400, height: 300), "center scaled")
print("ALL PASS")
```
`scaledRect` maps an AX rect (in `fromVisible` space) into `toPreview`: `x' = toPreview.minX + (ax.minX - fromVisible.minX)/fromVisible.width * toPreview.width` (and y/w/h analogously).

- [ ] **Step 2: Run to fail.** `cd <scratch> && swiftc /Users/test/Documents/code/invoke-v2/apps/macos/Sources/InvokeServices/WindowPlacement.swift /Users/test/Documents/code/invoke-v2/apps/macos/Sources/InvokeServices/WindowEnumerator.swift /Users/test/Documents/code/invoke-v2/apps/macos/Sources/InvokePalette/LayoutPreviewView.swift preview-scale-test.swift -o pvt && ./pvt` → FAIL. (Append `-framework AppKit -framework ApplicationServices` if needed. SourceKit noise on the test file is expected.)

- [ ] **Step 3: Implement `LayoutPreviewView.swift`** (`import AppKit` + `import InvokeServices`; `override var isFlipped: Bool { true }` so AX y-down maps directly). 
  - `scaledRect(...)` static (the pure mapping above).
  - `draw`: a desktop bezel (rounded rect, `windowBackgroundColor`/a subtle gradient) sized to the display aspect (use `NSScreen.main.frame` ratio); a caption "Built-in Retina Display · WxH" below (or as a sublabel). For each item (skip the selected so it draws last/on-top): compute `ax = WindowEnumerator.placementRect(item.placement, currentSize: repSize, visibleAX: previewInner)` where `previewInner` is the bezel's inner rect (AX space == this flipped view), then the rect is already in preview coords (placementRect against previewInner) — draw a rounded translucent window (gray for unselected, `controlAccentColor` ~0.4 for selected) with three `•••` dots top-left + the app icon (`NSWorkspace.shared.icon(forFile: appPath)` if set, else a generic) centered. (For `.auto` size use a representative repSize, e.g. 55%×55% of previewInner.)
  - `mouseDown(with:)`: hit-test items top-most-first; if a window rect contains the point → `onSelect?(i)`. 
  - An "+ Add" `NSButton` (title "＋ Add", bordered, centered above the bezel) → `onAdd?()`.
  - `needsDisplay = true` on `items`/`selected` didSet.

- [ ] **Step 4: Run → ALL PASS.** (same swiftc command)

- [ ] **Step 5: Build + Commit.** `swift build --package-path apps/macos 2>&1 | tail -3` → `Build complete!`. `git add apps/macos/Sources/InvokePalette/LayoutPreviewView.swift && git commit -m "feat(wm): LayoutPreviewView — live multi-window desktop preview (click-to-select + Add)"`

---

### Task 2: `LayoutInspectorView` — the right-pane controls

**Files:** Create `apps/macos/Sources/InvokePalette/LayoutInspectorView.swift`.

**Interfaces:** `LayoutInspectorView: NSView` with `var mode: DesignerMode`, `var name: String`, `var item: DesignerItem?` (the selected one; nil hides the app section), `var runningApps: [(bundleId,name,iconPath)]`, callbacks `onNameChange: ((String)->Void)?`, `onAppChange: ((String)->Void)?` (new bundleId for the selected row), `onPlacementChange: ((WindowPlacement)->Void)?`, `onDelete: (()->Void)?`.

- [ ] **Step 1: Implement** (`import AppKit` + `import InvokeServices`). A vertical stack:
  - **Name** `NSTextField` (→ `onNameChange`).
  - **App row** (hidden in `.singleWindow`): an `NSPopUpButton` of `runningApps` (icon + name; pre-selects `item.bundleId`) → `onAppChange`; a trash `NSButton` → `onDelete`.
  - **Size:** `W:` `NSTextField` + "pt", `H:` + "pt" — empty/"Auto" → `.auto`, number → `.points`. → rebuild placement → `onPlacementChange`.
  - **Position:** a 3×3 grid of 9 `NSButton`s (SF Symbols `arrow.up.left`/`arrow.up`/… per anchor; selected highlighted) → set `placement.anchor` → `onPlacementChange`.
  - **Offset:** `X:`/`Y:` `NSTextField`s (pt) → `onPlacementChange`.
  - Seeds all controls from `item.placement` + `name` on assignment (programmatic set must NOT re-fire callbacks → guard with an `isSeeding` flag).
  - Reuse `WindowEnumerator.serializePlacement`/`parsePlacement` only if convenient; internal state can hold `WindowPlacement` directly.

- [ ] **Step 2: Build + Commit.** `swift build --package-path apps/macos 2>&1 | tail -3` → `Build complete!`. `git add apps/macos/Sources/InvokePalette/LayoutInspectorView.swift && git commit -m "feat(wm): LayoutInspectorView — name + app + Size/Position(9-anchor)/Offset controls"`

---

### Task 3: `LayoutDesignerWindow` + controller — assemble the two panes

**Files:** Create `apps/macos/Sources/InvokePalette/LayoutDesignerWindow.swift`.

**Interfaces:** `final class LayoutDesignerWindow` with `static func present(mode: DesignerMode, name: String, items: [DesignerItem], runningApps: [(String,String,String?)], onSave: @escaping (String, [DesignerItem]) -> Void, onCancel: @escaping () -> Void)`.

- [ ] **Step 1: Implement.** A centered borderless/titled `NSPanel` (~900×560, `.titled`/`.fullSizeContentView`, dimmed). Left = `LayoutPreviewView`, right = `LayoutInspectorView` (fixed ~340pt), a thin divider; Cancel/Save buttons bottom-right; title "Create Window Layout"/"Create Window Command" + icon top-right.
  - Owns `name`, `items: [DesignerItem]`, `selected: Int`.
  - Wires: preview `onSelect` → set `selected` → refresh inspector + preview highlight; preview `onAdd` (layout mode) → append the first running app not already in `items` (placement `.default`) → select it; inspector `onAppChange`/`onPlacementChange` → mutate `items[selected]` → preview redraw; `onDelete` → remove selected, reselect; `onNameChange` → `name`.
  - **Save** (`⌘↵`/button): validate (layout: name non-empty + ≥1 item; single: name non-empty) → `onSave(name, items)` → close. **Cancel/Esc** → `onCancel()` → close.
  - `.singleWindow` mode: one item (no Add/app-dropdown/delete; the preview shows one rect; the run targets the focused window).
- [ ] **Step 2: Build + Commit.** `swift build --package-path apps/macos 2>&1 | tail -3` → `Build complete!`. `git add apps/macos/Sources/InvokePalette/LayoutDesignerWindow.swift && git commit -m "feat(wm): LayoutDesignerWindow — two-pane modal assembling preview + inspector"`

---

### Task 4: Host integration — wire commands + remove the old form builders

**Files:** Modify `apps/macos/Sources/InvokeShell/AppController.swift`.

- [ ] **Step 1: Present the designer.** Replace `presentWindowLayoutForm(editing:)` body: gather `runningApps` (regular, with icon paths); seed `items` from `editing?.items` (map `Item`→`DesignerItem`, look up appName/iconPath) or `[]`; `LayoutDesignerWindow.present(mode: .layout, name: editing?.name ?? "", items:, runningApps:, onSave: { name, items in /* build [WindowLayout.Item], add/update, rebuild commands + reloadCommandHotkeys */ }, onCancel: {})`. Replace `presentCustomWindowForm(editing:)` similarly with `mode: .singleWindow` (one item; on save → `CustomWindowCommand{name, placement: items[0].placement}`).
- [ ] **Step 2: Remove the dead native-form layout/custom plumbing.** Delete the old field-list bodies, the `layoutBuilderItems`/`layoutBuilderName`/`layoutBuilderAddAppHandlerId` state, the `palette.onFormFieldChange` override + the `exitToRoot` restore of it (keep `defaultFormFieldChange` assignment harmless OR remove if now unused), and — if `window-position-editor` is no longer used anywhere — remove that field type + `WindowPositionEditor.swift` (grep `window-position-editor`/`WindowPositionEditor` → should be empty after). (If the single-window designer reuses the same preview/inspector, `WindowPositionEditor` is fully replaced.)
- [ ] **Step 3: Build, install (stable), relaunch, verify.** `swift build --package-path apps/macos 2>&1 | tail -3` → `Build complete!`; `INVOKE_SIGN_IDENTITY="Invoke Dev" bash scripts/build-app.sh 2>&1 | tail -4`; `ditto apps/macos/.build/Invoke.app /Applications/Invoke.app`; `pkill -9 -f "Invoke.app/Contents/MacOS/invoke"; sleep 2; open /Applications/Invoke.app`; single PID + `/tmp/invoke-run.log` clean + "Create Window Layout Command"/"Create Window Management Command" discoverable. **HUMAN-REQUIRED:** open Create Window Layout → two-pane designer, "+ Add" apps, click a window to select, set Position/Size/Offset → preview live-updates → Save → run repositions all; Create Window Command → single-window designer; no scroll; matches the Raycast screenshots.
- [ ] **Step 4: Commit.** `git add apps/macos/Sources/InvokeShell/AppController.swift && git commit -m "feat(wm): wire Create Window Layout/Command to the two-pane designer; remove the native-form builders"` (+ `git rm` WindowPositionEditor.swift if removed).

---

## Self-Review
**1. Spec coverage:** preview → T1; inspector → T2; the two-pane window+controller → T3; host wiring + old-builder removal → T4. ✅ Two-pane, live preview, click-to-select, prominent Add, no scroll — matches the screenshots. Single-window mode reuses the designer.
**2. Placeholder scan:** T1 has the pure `scaledRect` + test + concrete draw/hit-test/Add structure. T2/T3 are concrete AppKit component structures + data flow + the reuse of `placementRect`/the model; exact pixel layout is the implementer's craft (visual = human-verified), but every control, callback, and state transition is specified.
**3. Type consistency:** `DesignerItem`/`DesignerMode` (T1) used across T2/T3/T4; `placementRect` reused for preview + apply; `LayoutDesignerWindow.present(...)` signature consistent T3↔T4; `WindowLayout.Item`/`CustomWindowCommand` mapping in T4.
**Known risks (final-review triage):** (a) modal `NSWindow` over the palette (LSUIElement app) — ensure it becomes key + Esc/⌘↵ work + dismiss is clean (no leaked state — the old onFormFieldChange override is removed, simplifying this). (b) preview `isFlipped` + `scaledRect`/`placementRect` y-consistency (pure-tested + the WindowPositionEditor isFlipped precedent). (c) icon load by path may be slow — cache per item. (d) removing `WindowPositionEditor`/`window-position-editor` must be complete (grep) or leave dormant. (e) `.auto`-size preview is representative, not exact (acceptable).
