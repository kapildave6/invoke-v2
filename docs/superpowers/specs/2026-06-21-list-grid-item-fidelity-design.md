# List/Grid Item Fidelity — Design (Chunk A of depth/parity polish)

**Date:** 2026-06-21
**Status:** approved (design); spec under review
**Scope owner:** invoke-v2 macOS renderer (`apps/macos/Sources/InvokePalette/PaletteView.swift`)

## Goal

Make imported Raycast extensions' list rows and loading states render faithfully:
the **full `List.Item` accessory surface** (colored text/tags, icon accessories,
relative dates, tooltips, combined entries) and a **thin `isLoading` progress bar**
on the List, Grid, and Detail surfaces. Today accessories collapse to plain
text/tag chips (no color, no icon, no date) and `isLoading` is ignored entirely.

This is Chunk A of the "depth/parity polish" direction. Pagination, ActionPanel
grouping, and Form/Detail field fidelity are **separate chunks**, out of scope here.

## Background — current state

- `Accessory` is an enum with only `.text(String)` / `.tag(String)`
  (`PaletteView.swift:1966`). It structurally cannot represent an accessory that
  carries **both** an icon and a label, which Raycast supports.
- The parser `accessories(_:)` (`:1968`) reads only `o["tag"]?.stringValue` /
  `o["text"]?.stringValue` — no `icon`, `date`, `tooltip`, color, or object forms.
- `chip(_:)` (`:1945`) has a fixed background (white @ 9% alpha) and
  `secondaryLabelColor` text — no color support.
- **No Raycast `Color` → `NSColor` mapping exists.** Only `tileColor(_:)` (`:2032`),
  which hashes a key into a fixed palette for command tiles — unrelated.
- `iconView(for:selected:)` (`:1979`) renders icons from a **node's props**; the
  reusable building blocks are `imageSource(_:)`, `loadLocalImage(_:)`,
  `loadRemoteImage(_:into:)`, `fileIconPath(_:)`, and `sfSymbol(for:)`.
- `isLoading` is never read; there is no progress-bar view.
- Surface props (incl. `isLoading`) are available at the render dispatch
  (`render(_:)`, `PaletteView.swift:296–320`), where surfaces are chosen by type.

## Non-goals / deferred

- **`tag: Date` / `text: Date`** (a Date passed under the `tag`/`text` key). Over the
  wire a JS `Date` becomes an ISO-8601 string (`serializeProps`,
  `runtime/reconciler/src/index.ts:100`, copies the value as-is; the frame's
  `JSON.stringify` calls `Date.toJSON()`), so on the Swift side it is
  indistinguishable from an ordinary string. The idiomatic Raycast form for a date
  accessory is the **`date` key** (which unambiguously declares date intent and
  supports color via `{ value, color }`), so we handle that faithfully and render a
  Date under `tag`/`text` as its string form. Preserving the Date *type* across the
  wire (a sentinel wrapper) is deferred to the Form/Detail chunk that needs
  `DatePicker`/`Metadata` dates.
- Pagination, ActionPanel Section/Submenu grouping, Form/Detail field fidelity.
- Grid accessories: Raycast `Grid.Item` has no accessories array (only
  title/subtitle/content), so there is nothing to add there. `isLoading` **does**
  apply to Grid and is in scope.

## Architecture

Two independent units, both confined to `PaletteView.swift` (+ one new pure helper
file). **No TypeScript / reconciler / `@invoke/api` changes** — `accessories` and
`isLoading` already flow through as props (the renderer already reads
`node.props["accessories"]` and `list.props["showDetail"]`).

### Unit 1 — Accessories

Replace the `Accessory` enum with a struct capturing Raycast's *combined* model
(one accessory entry = optional icon + optional text/tag, rendered together):

```swift
private struct Accessory {
    var iconValue: JSONValue?   // an Image.ImageLike, rendered at 15pt
    var iconTint: NSColor?      // tintColor for an SF-symbol icon
    var label: String?          // resolved text/tag/date string
    var isTag: Bool             // true → chip; false → plain right-aligned label
    var color: NSColor?         // text color (label) / chip color (tag)
    var tooltip: String?        // NSView.toolTip on the rendered accessory
}
```

**Parser** `accessories(_:)` reads each array entry (a JSON object) and supports
every Raycast form. For each entry it resolves, in order, an optional icon and an
optional label, then a tooltip:

- **`text`**: `String`, or `{ value: String, color? }` → `isTag=false`, `color` mapped.
- **`tag`**: `String | Number`, or `{ value, color? }` → `isTag=true`, `color` mapped.
  A numeric value is formatted as its string (e.g. `42`).
- **`date`**: ISO-8601 `String`, or `{ value: ISO-8601 String, color? }` →
  `isTag=false`, label = `compactRelative(date)`; on parse failure, the raw string.
- **`icon`**: an `Image.ImageLike`, or `{ value: ImageLike, tooltip? }` → `iconValue`
  (+ per-icon `tooltip`). `iconTint` taken from an `{ source, tintColor }` form.
- **`tooltip`** (entry-level): sets `tooltip` for the whole accessory.

Each entry may set both an icon and a label (combined). `null`/absent fields are skipped.

**Renderer** (in `itemRowContent`, replacing the loop at `:1773`): for each
`Accessory` build a small horizontal substack `[icon?][label?]` (spacing 4), set its
`.toolTip`, and add it to the row's right side. Label rendering:

- `isTag == true` → `chip(label, color: color)`.
- `isTag == false` → `NSTextField` label; `textColor = color ?? .tertiaryLabelColor`,
  font size 13.

Icon rendering: a new `accessoryIcon(_ value: JSONValue, tint: NSColor?) -> NSView?`
at 15pt, reusing `imageSource`/`loadLocalImage`/`loadRemoteImage`/`sfSymbol`
(the same resolution order as `iconView`, minus the node-specific app/file/manifest
branches). SF-symbol icons get `contentTintColor = tint ?? .secondaryLabelColor`.

**`chip(_:color:)`** gains an optional color:
- `color == nil` → unchanged (white @ 9% alpha bg, `secondaryLabelColor` text).
- `color != nil` → background `color.withAlphaComponent(0.18)`, text `color`
  (Raycast's colored-tag look: tinted fill + colored text).

### Unit 2 — `Color` → `NSColor` (new pure helper)

New file `apps/macos/Sources/InvokePalette/RaycastColor.swift`:

```swift
enum RaycastColor {
    /// Maps a Raycast Color.ColorLike JSONValue to an NSColor, or nil if absent/unparseable.
    static func nsColor(_ value: JSONValue?, appearance: NSAppearance?) -> NSColor?
}
```

Accepts:
- **Named** (string): `"red"→.systemRed`, `"green"→.systemGreen`, `"blue"→.systemBlue`,
  `"yellow"→.systemYellow`, `"orange"→.systemOrange`, `"purple"→.systemPurple`,
  `"magenta"→.systemPink`, `"primary-text"→.labelColor`,
  `"secondary-text"→.secondaryLabelColor`. (System colors adapt to light/dark — the
  macOS-faithful choice; the named set matches `@invoke/api`'s `Color`,
  `packages/api/src/index.ts:425`.)
- **Hex** (string): `#RGB`, `#RRGGBB`, `#RRGGBBAA` (case-insensitive).
- **Dynamic** `{ light, dark }`: resolve the matching branch against `appearance`
  (falls back to `light` when appearance is unknown), recursing into each branch.

Used by colored text/tags **and** accessory icon `tintColor`. Pure and table-driven
→ unit-testable via a standalone `swift` script.

### Unit 3 — relative date (new pure helper)

`compactRelative(_ date: Date, now: Date = Date()) -> String` (in `RaycastColor.swift`
or a sibling pure file): largest-unit compact form matching Raycast — `"now"`,
`"<n>s"`, `"<n>m"`, `"<n>h"`, `"<n>d"`, `"<n>w"`, `"<n>mo"`, `"<n>y"`. Past has no
suffix; future is prefixed `"in "` (e.g. `"in 3d"`). Pure → standalone-`swift`-testable.
ISO parsing via a shared `ISO8601DateFormatter` configured with
`.withInternetDateTime` + `.withFractionalSeconds`, with a fallback formatter
omitting fractional seconds.

### Unit 4 — `isLoading` progress bar

A new small view `LoadingBar: NSView` (`apps/macos/Sources/InvokePalette/LoadingBar.swift`):
a 2px-tall bar hosting a `CAGradientLayer` accent highlight that sweeps left→right on
a repeating animation — Raycast's thin indeterminate sweep, not the system barber-pole
`NSProgressIndicator` (per the project's world-class-UX bar). `start()` adds the
animation + unhides; `stop()` removes it + hides.

Placement: added once to the top of `PaletteView`'s content area, pinned
leading/trailing/top, full width, height 2, above the results (`stack`/`scrollView`/
`listScroll`/`gridScroll`) and under the window's search field. In `render(_:)`, after
the active surface is chosen (`:296–320`), read that surface node's `isLoading` prop
(`Self.isTrue(surface.props["isLoading"])`) and call `loadingBar.start()`/`.stop()`.
Applies to `list`, `grid`, and `detail` surfaces. The bar overlays (zero layout
height impact) so it does not shift the results or change the fixed palette height.

## Data flow

`extension → @invoke/api List.Item(accessories=[…], …) / List(isLoading) → reconciler
serializeProps (values as-is; Dates become ISO strings) → commit frame → host
ViewNode.props → PaletteView.render → accessories(_:) / isLoading read → AppKit views`.

## Error handling

- Malformed accessory entries (non-object, unknown shape, `null` fields) are skipped
  individually; a bad entry never aborts the row. Row construction already runs inside
  the `InvokeCatchException` guard (`render`, `:296`).
- Unparseable color → `nil` (falls back to default text/chip styling).
- Unparseable date → raw string shown.
- Remote accessory icons load async via the existing `loadRemoteImage`; until then the
  icon slot is empty (no layout jump — fixed 15pt frame).

## Testing (CLT-only — no XCTest runtime; see build-run-loop)

- **Standalone `swift` scripts** (pure logic): `RaycastColor.nsColor` (named/hex/dynamic,
  incl. bad input → nil) and `compactRelative` (each unit boundary, past/future,
  ISO parse incl. fractional seconds). Mirror the BrowserDriver pure-helper pattern.
- **Fixture extension** `examples/accessory-demo/` (a runnable example, surfaced and
  launchable in the app like `examples/calculator`): a List whose items exercise every
  accessory form — colored tag, icon-only, icon+text combined, `date`, tooltip — plus a
  command that toggles `isLoading`. Verified in the running app (`scripts/build-app.sh`
  + relaunch), confirming render + no regression on the existing text/tag rows.
- **Compat check** unaffected (no API-surface change); rerun is optional.

## Files

- **Modify** `apps/macos/Sources/InvokePalette/PaletteView.swift`: `Accessory` struct;
  rewrite `accessories(_:)`; `accessoryIcon(_:tint:)`; `chip(_:color:)`; accessory
  render loop in `itemRowContent`; `LoadingBar` wiring in view setup + `render(_:)`.
- **Create** `apps/macos/Sources/InvokePalette/RaycastColor.swift`: `RaycastColor` +
  `compactRelative`.
- **Create** `apps/macos/Sources/InvokePalette/LoadingBar.swift`: the sweep bar.
- **Create** a fixture extension exercising the forms.
- No TypeScript / reconciler / `@invoke/api` changes.
