# Task 3 Report: LayoutDesignerWindow

## Status: COMPLETE (swift build clean; visual flow HUMAN-REQUIRED)

---

## 1. Window Structure + present() Signature

`LayoutDesignerWindow` is a `final class` (not a window subclass) that owns an `NSPanel`. The static `present(...)` method creates a new instance, stores it in `static var current` for strong-ref lifetime management, and calls `show()`:

```swift
public static func present(
    mode:        DesignerMode,
    title:       String,
    name:        String,
    items:       [DesignerItem],
    runningApps: [(bundleId: String, name: String, iconPath: String?)],
    onSave:      @escaping (String, [DesignerItem]) -> Void,
    onCancel:    @escaping () -> Void
)
```

The `NSPanel` is 900×560, `styleMask: [.titled, .fullSizeContentView, .nonactivatingPanel]`, `level = .modalPanel`, `isMovableByWindowBackground = true`, centered on screen via `panel.center()`.

## 2. Layout

- Left: `LayoutPreviewView` — fills remaining width via Auto Layout.
- Right: `LayoutInspectorView` — fixed 340pt wide.
- 1pt `NSBox(.separator)` divider between them.
- Bottom bar (48pt): Cancel (Esc) + Save (⌘↵) buttons aligned bottom-right.
- All layout done with Auto Layout constraints anchored to `contentView`.

## 3. State

- `var name: String` — seeded from arg.
- `var items: [DesignerItem]` — seeded from arg; `.singleWindow` enforces exactly one item (seeds a placeholder with `bundleId:""` if empty).
- `var selected: Int` — `-1` if items empty, else `0` initially.

## 4. All Wiring

| Event | Handler |
|-------|---------|
| `preview.onSelect(idx)` | `selected = idx` → `preview.selected = idx` → `refreshInspector()` |
| `preview.onAdd()` | `addNextApp()` — appends first runningApp not already in `items` (placement `.default`), selects it, `refreshAll()` |
| `inspector.onNameChange(s)` | `name = s`, `updateSaveButtonState()` |
| `inspector.onAppChange(bundleId)` | look up in `runningApps` → mutate `items[selected].(bundleId/appName/appPath)` → `preview.items = items` |
| `inspector.onPlacementChange(p)` | `items[selected].placement = p` → `preview.items = items` |
| `inspector.onDelete()` | remove `items[selected]`, reselect neighbor or -1, `refreshAll()` |

`refreshAll()` pushes `items`/`selected` to the preview and calls `refreshInspector()` which calls `inspector.load(name:item:runningApps:)`.

## 5. Save/Cancel Validation + Key Equivalents

- **Save** button: `keyEquivalent = "\r"`, `keyEquivalentModifierMask = .command` (⌘↵). On tap: `isValid()` → if false, `NSSound.beep()` + return. Else `dismiss(save: true)` → `onSave(name, items)` + release `current`.
- **Cancel** button: `keyEquivalent = "\u{1b}"` (Esc). On tap: `dismiss(save: false)` → `onCancel()` + release `current`.
- `isValid()`: `.layout` → trimmed name non-empty AND `!items.isEmpty`; `.singleWindow` → trimmed name non-empty.
- Save button `alphaValue` dims to `0.45` when invalid, `1.0` when valid (visual feedback; beep still fires on invalid press).

## 6. Strong-Ref / Lifecycle

`static var current: LayoutDesignerWindow?` holds the controller alive. `present(...)` dismisses any existing designer first (calling `onCancel` for it), then sets `current = designer`. `dismiss(save:)` calls `LayoutDesignerWindow.current = nil` which releases it after the panel is ordered out.

## 7. .singleWindow Handling

- If `items` is empty on entry, a placeholder `DesignerItem(bundleId:"", appName:"", appPath:nil, placement:.default)` is seeded so there is always exactly one item.
- `preview.onAdd = nil` and `preview.showsAddButton = false` (hides the "+ Add" button).
- `inspector.mode = .singleWindow` is set — inspector already hides the app row for this mode.
- Only the first item of a non-empty `items` array is used (clamped to 1 element).

## 8. Tweak to LayoutPreviewView

Added `public var showsAddButton: Bool = true { didSet { addButton.isHidden = !showsAddButton; needsLayout = true } }` to `LayoutPreviewView.swift`. Minimal — no other changes to that file.

**File:** `apps/macos/Sources/InvokePalette/LayoutPreviewView.swift`

## 9. swift build Result

```
Build complete! (12.73s)
```
Only pre-existing warnings (Sendable, unused `self`); zero errors.

## 10. Commit Hash

(see git log — committed as "feat(wm): LayoutDesignerWindow — two-pane modal assembling preview + inspector")

## 11. HUMAN-REQUIRED Items

1. **Visual verification** — open "Create Window Layout" → confirm two-pane designer appears (preview left, inspector right), "+ Add" appends apps, clicking a window rect selects it with highlight, inspector controls update the preview live.
2. **Single-window mode** — open "Create Window Command" → confirm one window rect, no "+ Add" button, no app-row in inspector, name field works, Save returns the single item.
3. **Key equivalents** — verify ⌘↵ saves and Esc cancels without clicking buttons.
4. **Task 4 (host wiring)** is NOT done here — `AppController.presentWindowLayoutForm` and `presentCustomWindowForm` still use the old native-form builders. Task 4 must replace those call sites with `LayoutDesignerWindow.present(...)`.

## 12. Concerns

- `NSPanel` with `.nonactivatingPanel` means the panel does not steal focus from the palette. If key events (Esc/⌘↵) are not received, Task 4's host integration may need to call `panel.makeKey()` explicitly or remove `.nonactivatingPanel`.
- `dismiss(save:)` releases `current` synchronously after `panel.orderOut`. If AppKit retains the panel during animation there could be a brief window where `current == nil` but the panel is still visible — unlikely in practice.
- `addNextApp()` beeps if all `runningApps` are already in `items`. The UX could instead disable "+ Add" entirely; beep is consistent with Raycast's approach for now.
