# Chunk E — P0 Correctness Design

**Part of the Raycast-parity push.** Closes the three remaining **P0 "crash-prevention & correctness"** items in `RAYCASTVSINVOKE.md` §12, so extensions render empty states, controlled checkboxes react, and action panels honor destructive styling + custom keyboard shortcuts.

## Global constraints
- World-class Raycast-quality UX; never ship system-default/janky UI.
- Faithful Raycast parity; do NOT fabricate third-party brands. Fixture imports `@raycast/api` (like `examples/tech-radar`).
- Commit directly on `main`. Relaunch `Invoke.app` after build+install.
- Env has no Xcode → no XCTest. Pure logic verified via standalone `swift`/`tsx` scripts; AppKit paths via `swift build --package-path apps/macos` + `scripts/build-app.sh` + relaunch + `/tmp/invoke-run.log`.

---

## Item 1 — `List.EmptyView` / `Grid.EmptyView` (render the empty state)

**Current:** `List.EmptyView`/`Grid.EmptyView` are exported as `host(T.EmptyView, ["actions"])` → node type `empty-view` (props: `icon`, `title`, `description`; nested `action-panel` via the lifted `actions` prop). The Swift renderer drops it: `renderListVirtualized`'s `walk` hits the `default` branch (walks children, finds no `list-item`), and `renderGrid`'s `collect` only gathers `grid-item`. So every "No results"/first-run screen is blank.

**Design:**
- Add `emptyStateView: NSView?` member to `PaletteView`. New builder `renderEmptyState(_ node: ViewNode)` produces a vertically+horizontally centered stack: icon (≈48pt, `secondaryLabelColor` tint; resolved via the existing `imageSource`/`sfSymbol`/`loadLocalImage`/asset path), title (`systemFont(15, .semibold)`, `labelColor`), description (`systemFont(13)`, `secondaryLabelColor`, wrapped, centered). Title/description optional.
- Show the empty state **only when the active List/Grid surface has zero items AND an `empty-view` node exists** in its subtree (Raycast shows EmptyView when there are no items; if items exist it is ignored). When shown, hide `listScroll`/`gridScroll`; the empty view fills the content area.
- Detection: helper `firstEmptyView(in node: ViewNode) -> ViewNode?` (DFS for `type == "empty-view"`). `renderListVirtualized`: after `walk`, if `itemIdx == 0` and `firstEmptyView(in: root)` ≠ nil → render empty state instead of the table. `renderGrid`: if `items.isEmpty` and `firstEmptyView(in: grid)` ≠ nil → render empty state instead of the collection.
- Teardown: `render()` hides/removes `emptyStateView` at the top alongside the other surface resets, so it never leaks across renders.
- **EmptyView actions:** when the empty state is shown, its nested `action-panel` should populate ⌘K. `currentActionSections()` already falls back to `extensionSurfaceNode()` (the list/grid) when there are no item rows, and `extensionActionSections(under:)` DFS-finds the first `action-panel` — which is the EmptyView's. Verify this picks up automatically; if not, route the empty-view node as the action source. (Verify-point, not a separate task.)

## Item 2 — Checkbox `onChange` (fire a typed boolean)

**Current:** `form-checkbox` (`PaletteView.swift:1650`) builds `NSButton(checkboxWithTitle:…, target: nil, action: nil)` — toggling fires nothing. `form-dropdown` shows the wiring pattern (reads `f.props["onChange"]?.handlerRef`, fires `onFormFieldChange(h, value)` as a **string**).

**Design:** Checkbox must deliver a real **boolean** — a `"false"` string is truthy in JS, so `onChange={(c) => setX(c)}` would break if we sent strings. Add a typed channel rather than overloading the string `onFormFieldChange`:
- `PaletteView`: `public var onFormCheckboxChange: ((String, Bool) -> Void)?`.
- `form-checkbox` case: capture `onChangeRef = f.props["onChange"]?.handlerRef`; if present, store it on the button via `objc_setAssociatedObject`, set `cb.target = self` + `cb.action = #selector(formCheckboxChanged(_:))`. New `@objc func formCheckboxChanged(_ sender: NSButton)` reads the associated handler and fires `onFormCheckboxChange?(handler, sender.state == .on)`.
- `AppController`: `palette.onFormCheckboxChange = { [weak self] h, b in self?.extHost?.invoke(handler: h, args: [.bool(b)]) }`.
- The in-place reconcile (`formApply[id]`) that syncs checkbox state from props is unchanged. The submitted form value getter (`"true"`/`"false"`) is unchanged.
- Date/number typed values stay in the separate P1 "typed field values" item.

## Item 3 — `Action.style` (destructive red) + `Action.shortcut` display

**Current:** `PaletteAction` carries only a display-string `shortcut`; `paletteAction(for:)` ignores `n.props["style"]` and `n.props["shortcut"]`, assigning shortcuts positionally (`↵` idx 0, `⌘↵` idx 1). `ActionRowView` renders `titleLabel.textColor = .labelColor` always.

**Design:**
- `PaletteAction`: add `isDestructive: Bool` (default `false`).
- `paletteAction(for:)`: set `isDestructive = (n.props["style"]?.stringValue == "destructive")`.
- New `Keyboard.glyphs(modifiers: [String], key: String) -> String` (in a small `Keyboard` enum, AppKit-free, standalone-testable): maps `cmd`→⌘, `shift`→⇧, `opt`/`option`/`alt`→⌥, `ctrl`/`control`→⌃ (in Raycast's render order ⌃⌥⇧⌘), then the key: single chars upper-cased; named keys `return`/`enter`→↵, `delete`/`backspace`→⌫, `arrowUp/Down/Left/Right`→↑↓←→, `escape`→⎋, `tab`→⇥, `space`→␣, else the raw key upper-cased.
- `paletteAction(for:)`: if `n.props["shortcut"]` is `{modifiers, key}`, set the action's display `shortcut` to `Keyboard.glyphs(...)` (overrides the positional default). `Keycap.chips(for:)` already splits a glyph string into chips.
- `ActionRowView`: add `destructive: Bool` init param → `titleLabel.textColor = destructive ? .systemRed : .labelColor`. `rebuildRows()` passes `a.isDestructive`. (The action-bar primary label in `PaletteWindow` similarly reddens when the primary action is destructive.)

## Item 4 — `Action.shortcut` functional key-equivalent binding

**Current:** Custom shortcuts are display-only; pressing ⌘⇧K does nothing. Only positional `↵`/`⌘↵` run (the window's existing Enter handling).

**Design:**
- `PaletteAction`: add parsed `shortcutModifiers: [String]?` + `shortcutKey: String?` (raw, lower-cased key + normalized modifier list), set in `paletteAction(for:)` from `n.props["shortcut"]`.
- `PaletteWindow` `keyMonitor` (`.keyDown`, line ~641): before the existing handling, build the pressed combo from `event.modifierFlags` + `event.charactersIgnoringModifiers`, normalize to the same modifier vocabulary, and match against `actionsProvider()`'s actions that have a `shortcutKey`. On a match: run that action's `run()`, consume the event (return nil). Custom shortcuts thus fire while the list is focused (Raycast behavior), independent of whether ⌘K is open.
- Matching helper is pure (combo vs action shortcut) → standalone-testable. Positional `↵`/`⌘↵` paths are untouched; custom shortcuts are additive.

## Item 5 — Fixture + verify

- `examples/empty-action-demo/` (manifest imports `@raycast/api`):
  - A `List` whose body is `items.length ? items.map(...) : <List.EmptyView icon={Icon.MagnifyingGlass} title="No Matches" description="Try a different search" actions={<ActionPanel><Action title="Reload" shortcut={{ modifiers: ["cmd"], key: "r" }} onAction={…}/></ActionPanel>} />`, toggled by `onSearchTextChange`.
  - An `ActionPanel` (on a populated item) with a destructive `Action` (`style: Action.Style.Destructive`) and a custom-shortcut `Action` (`shortcut={{ modifiers: ["cmd","shift"], key: "k" }}`) whose `onAction` shows a Toast so the binding is observable.
  - A `Form` with a `Checkbox` whose `onChange` pushes/updates a `Detail` showing the received boolean (proves a real bool, not `"false"`).
- Verify: `swift build` clean → `scripts/build-app.sh` → relaunch → `/tmp/invoke-run.log` shows no load error; visual confirm of empty state, red destructive action, custom keycaps, working ⌘⇧K, and checkbox boolean.

## Testing strategy
- **Pure/standalone (runnable now):** `Keyboard.glyphs(...)` mapping table; the keyMonitor combo-vs-shortcut matching predicate. Exercised via a standalone `swift` script (no XCTest).
- **AppKit (build + fixture):** empty-state view, checkbox boolean firing, destructive color, functional shortcut — verified via build + relaunch + log + visual, per project norms.

## Out of scope (tracked elsewhere)
- Typed non-bool field values (Date objects, numbers) → P1 "typed field values" (Chunk H).
- `Toast`/`Alert` action options → P1 (Chunk G).
- Submenu/section-level shortcut semantics beyond display + top-level binding.
