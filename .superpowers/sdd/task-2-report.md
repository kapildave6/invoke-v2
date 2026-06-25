# Task 2 Report — LayoutInspectorView

## File Created
`apps/macos/Sources/InvokePalette/LayoutInspectorView.swift`

---

## Control Layout (top-to-bottom)

| Section | Controls |
|---|---|
| **Name** | "Name" label (secondary, 11pt medium) then `NSTextField` (rounded bezel, full width) |
| **App row** | `NSPopUpButton` (icons + names) + trash `NSButton` (SF Symbol `trash`, red tint); hidden when `mode == .singleWindow` or `item == nil` |
| **Size** | "SIZE" section header (10pt semibold, tertiary) · W: row (label, field, "pt" label) · H: row |
| **Position** | "POSITION" header · 3x3 grid of 9 `NSButton`s (28x28 pt each, 3 pt gap) |
| **Offset** | "OFFSET" header · X: row · Y: row |

All subviews are stored as instance vars (allocated once in init closures / `setup()`). `layout()` only frames them — no subview creation on layout passes.

---

## load / Seed-without-refire Mechanism

`load(name:item:runningApps:)` sets `isSeeding = true` at entry and `defer { isSeeding = false }` at exit.

Every callback path (NSTextFieldDelegate `controlTextDidChange`/`controlTextDidEndEditing`, `anchorTapped`, `appPopupChanged`, `deleteTapped`) begins with `guard !isSeeding else { return }`. This makes callback suppression unconditional during any seeding call.

---

## Size Parsing — Auto / pt

`parseSizing(_ text: String) -> Sizing`:
- Empty string or case-insensitive "auto" -> `.auto`
- A parseable `Double` -> `.points(Double)`
- Anything else -> `.auto` (safe fallback)

On `controlTextDidEndEditing`, if the parsed result is `.auto` the field is normalised back to `""` (clean display). This fires only when `!isSeeding`.

---

## 9-Anchor Mapping + Highlight

`Anchor.rawValue` = `row * 3 + col` (0 = topLeft … 8 = bottomRight). SF Symbols assigned row-major:

| idx | Anchor | Symbol |
|---|---|---|
| 0 | topLeft | `arrow.up.left` |
| 1 | top | `arrow.up` |
| 2 | topRight | `arrow.up.right` |
| 3 | left | `arrow.left` |
| 4 | center | `smallcircle.filled.circle` |
| 5 | right | `arrow.right` |
| 6 | bottomLeft | `arrow.down.left` |
| 7 | bottom | `arrow.down` |
| 8 | bottomRight | `arrow.down.right` |

`highlightAnchorButton(_ anchor: Anchor)`:
- Selected: `contentTintColor = .controlAccentColor`, `layer.borderWidth = 1.5`, `layer.borderColor = controlAccentColor.cgColor`, `cornerRadius = 4`.
- Others: `contentTintColor = .secondaryLabelColor`, `layer.borderWidth = 0`.
- Default highlight seeded to `.center` at init.
- All anchor buttons have `wantsLayer = true` for layer-property support.

---

## Callbacks

| Callback | Trigger |
|---|---|
| `onNameChange(String)` | `controlTextDidChange` on `nameField` |
| `onAppChange(bundleId: String)` | `appPopupChanged` — emits `currentRunningApps[selectedIndex].bundleId` |
| `onPlacementChange(WindowPlacement)` | Width/height text change (mutates `currentPlacement.width/.height`), anchor tap (sets `.anchor`), offset text change (sets `.offsetX/.offsetY`); always passes the full mutated struct |
| `onDelete()` | Trash button tap |

---

## swift build Result

```
Build complete! (1.59s)
```

No errors. Pre-existing warnings (`@Sendable` captures in AppController) are unrelated.

---

## Commit Hash

(populated after commit)

---

## HUMAN-REQUIRED Visual Items

1. **App row visibility** — verify it hides correctly in `.singleWindow` mode and when `item == nil`; re-appears when an item is loaded in `.layout` mode.
2. **Anchor grid highlight** — selected anchor button shows accent-colored 1.5pt border; deselected buttons are muted (secondaryLabelColor tint).
3. **Size placeholder behaviour** — "Auto" placeholder shows when field is empty; typing a number updates placement in real-time; blurring normalises "auto" text back to empty.
4. **Popup icon size** — 16x16 app icons should render cleanly inside the NSPopUpButton menu items.
5. **Section header spacing** — 16pt gaps between sections should feel spacious but not wasteful at the designed panel width (~340 pt).
6. **Offset negative values** — verify that negative doubles (e.g. `-20`) parse and round-trip correctly through `parseOffset`.
7. **App row y-advance** — confirm the Size section renders immediately below the App row (not leaving a blank gap when app row is hidden).

---

## Concerns / Notes

- `NSButton.contentTintColor` + SF Symbols require macOS 11+ (Big Sur) for full fidelity; macOS 10.14 degrades gracefully to a plain icon.
- `appRowContainer` layout always frames the popup/delete even when hidden; the `y` advance is guarded by `if !appRowContainer.isHidden` so sections stack correctly.
- Offset fields display `""` (not "0") when offset is exactly 0, matching the "Auto" convention for size fields and keeping the form clean. Typing "0" is accepted and round-trips to `0.0`.
- The `currentPlacement` struct is held as mutable internal state. Each callback passes a copy, so callers receive a fully consistent snapshot with no shared-mutable aliasing.
