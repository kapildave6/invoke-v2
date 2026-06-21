# ActionPanel Section/Submenu Grouping — Design (Chunk B of depth/parity polish)

**Date:** 2026-06-21
**Status:** approved (design); spec under review
**Scope owner:** the ⌘K Action Panel (`apps/macos/Sources/InvokeShell/ActionPanel.swift`) + action collection (`AppController`) + one `@invoke/api` change.

## Goal

Render an extension's `<ActionPanel>` faithfully in the ⌘K panel: `ActionPanel.Section` as visually grouped actions (separators + optional small-caps titles), and `ActionPanel.Submenu` as a **drill-in nested menu**. Today both are flattened into one undifferentiated list, so grouping and submenus are invisible.

This is Chunk B of the "depth/parity polish" direction. The bottom action bar, pagination (Chunk C), and Form/Detail fidelity (Chunk D) are out of scope.

## Background — current state

- `@invoke/api` (`packages/api/src/index.ts:330-335`): `ActionPanel.Section = host(T.ActionPanelSection)` ("action-panel-section"); **`ActionPanel.Submenu` is ALIASED to the same `T.ActionPanelSection`** — defined only so an undefined `<ActionPanel.Submenu>` doesn't throw while serializing. So a submenu's children currently flatten as if a section.
- `AppController.actions(under:)` (`:1742`) recursively collects every `"action"` node, descending through `action-panel`/`action-panel-section`/(aliased)submenu indiscriminately → a flat `[ViewNode]`.
- `AppController.currentActions()` (`:1265`) returns `[PaletteAction]` for all modes; the extension case is the final fallthrough (`actions(under: node).enumerated().map { … perform(n) }`, ↵ to index 0, ⌘↵ to index 1).
- `PaletteWindow.swift:682` presents the panel: `actionPanel.present(in: content, actions: <provider>, title: …)`, where the provider is `palette.actionsProvider = { currentActions() }` (`AppController:200`). The bottom action bar uses `currentActions().first` (`:1259`).
- `ActionPanel.present(in:actions:title:)` (`:136`) renders a flat `[PaletteAction]` into `listStack` as `ActionRowView`s (icon · title · shortcut chips), with a search field, ↑/↓ nav, Return to run, Esc/backdrop-click to dismiss. No sections, no submenus.

## Non-goals / deferred

- The bottom action bar stays flat (primary = first leaf action, secondary = second) — unchanged.
- Per-action custom keyboard shortcuts beyond the default ↵ / ⌘↵ (a separate parity item).
- Submenu *inline expansion* — we do Raycast's drill-in instead (decision below).

## Architecture — a structured action model

Replace the panel's flat input with a section tree (new file `apps/macos/Sources/InvokeShell/ActionSection.swift`):

```swift
struct ActionSection { let title: String?; let entries: [ActionEntry] }
enum ActionEntry {
    case action(PaletteAction)
    case submenu(title: String, icon: String?, sections: [ActionSection])
}
```

`ActionPanel.present` takes `[ActionSection]`. Built-in modes (chat, clipboard, snippets, …) wrap their existing flat `[PaletteAction]` in one untitled section — zero behavior change. Extension actions build real sections/submenus.

### Unit 1 — `@invoke/api`: un-alias Submenu

In `packages/api/src/index.ts`: add `ActionPanelSubmenu: "action-panel-submenu"` to the `T` type map, and change `ActionPanel.Submenu = host(T.ActionPanelSubmenu)` (was `host(T.ActionPanelSection)`). `ActionPanel.Submenu` carries `title` and `icon` props (Raycast). The new node type flows through the generic reconciler and host `ViewNode` with NO schema/reconciler change. This is the only non-renderer change in the chunk.

### Unit 2 — Collection (`AppController`)

Add `extensionActionSections(under node: ViewNode) -> [ActionSection]`:
- Locate the first `action-panel` descendant of the selected item node (its `actions` prop is lifted to a child by `@invoke/api`); if none, fall back to the existing flat collection wrapped as one untitled section. Then walk that `action-panel` node's **direct** children in document order:
  - `action-panel-section` → an `ActionSection` (`title` from props), whose entries come from walking ITS children.
  - `action-panel-submenu` → an `.submenu(title, icon, sections:)` entry; its children are walked recursively into `[ActionSection]` (a submenu may itself contain sections/actions/submenus).
  - bare `action` (a direct child, not inside a section) → an `.action` entry appended to a leading untitled section.
- Each `action` node → `PaletteAction` via the existing `title(for:)` + `perform(_:)` (the same run path `currentActions()` uses), so behavior matches.
- **Shortcut assignment:** the first leaf `action` in document order (depth-first, NOT descending into submenus) gets ↵, the second gets ⌘↵, matching the flat path so the ⌘K chips agree with the bottom bar.

Add `currentActionSections() -> [ActionSection]` for the panel: for `mode == .extensionView` return `extensionActionSections(under: node)`; otherwise return one untitled section wrapping `currentActions()` (`[ActionSection(title: nil, entries: currentActions().map(ActionEntry.action))]`). `currentActions()` is left untouched (the bottom bar and all built-in modes keep using it verbatim). Expose it via a new `palette.actionSectionsProvider = { currentActionSections() }` alongside the existing `actionsProvider`.

### Unit 3 — Panel: sections (`ActionPanel.swift`)

The panel gains a flattened **row model** built from the current level's sections:
```swift
enum PanelRow { case header(String); case action(PaletteAction); case submenu(title: String, icon: String?, sections: [ActionSection]) }
```
- A non-selectable `.header` row (small-caps `secondaryLabelColor`) is emitted for each section whose `title != nil`; a thin separator (`NSBox`) precedes each section after the first.
- `.action`/`.submenu` rows are selectable. `ActionRowView` gains a submenu style: a trailing "›" chevron (instead of shortcut chips).
- Selection (↑/↓, hover) skips `.header` rows. `move(_:)` and the initial selection land on the nearest selectable row.
- Filtering: the search field filters `.action`/`.submenu` rows by title within the current level; sections with no surviving entries drop their header + separator.

### Unit 4 — Panel: submenu drill-in (`ActionPanel.swift`)

The panel keeps a navigation stack `levels: [[ActionSection]]`. `present` sets `levels = [sections]`. The current level is `levels.last`.
- **Enter a submenu** (Return or → on a `.submenu` row): push `submenu.sections`; the header shows the submenu `title` with a back chevron ("‹ <title>"); search resets; selection resets to the first selectable row.
- **Back** (← or Esc): if `levels.count > 1`, pop one level (restore header/selection); else dismiss (root Esc = dismiss, unchanged).
- Backdrop click always dismisses (collapses all levels).
- Running an action (Return on `.action`) dismisses the whole panel, as today.

## Data flow

`extension <ActionPanel><Section/Submenu><Action> → @invoke/api (action-panel / action-panel-section / action-panel-submenu / action nodes) → reconciler → host ViewNode tree → currentActionSections() → [ActionSection] → ActionPanel.present → level stack → PanelRow rows`.

## Error handling

- A submenu with no children renders as a disabled-looking row that pops back immediately if entered (guard: don't push an empty level). Malformed/empty sections are dropped.
- An `action-panel-submenu` arriving while older `@invoke/api` semantics are cached still works: the walker treats an unknown action container's `action` descendants as a fallback flat section (no crash).
- Panel construction already tolerates an empty action set (`present` guards `actions.isEmpty`); the new guard is `sections` empty (no selectable rows) → don't present.

## Testing (CLT-only — no XCTest/pixels)

- `extensionActionSections` takes a `ViewNode` (project type), so it's verified via `swift build` + the fixture in the running app rather than a standalone script. The selection-skipping logic (compute the next selectable row index skipping headers) is extracted as a pure free function `nextSelectable(rows:from:delta:)` and unit-tested with a standalone `swift` script (header/action/submenu row patterns, wrap-around bounds).
- Extend `examples/accessory-demo` (or its command) with an `<ActionPanel>` containing: a titled section with two actions, a second titled section, and an `ActionPanel.Submenu` ("Open In") with 2–3 actions. Verify in the running app (`scripts/build-app.sh` + relaunch): ⌘K shows the two titled groups with a separator; the submenu row shows "›"; →/Return drills in (header shows back chevron); ←/Esc returns; Esc at root dismisses; ↑/↓ skip headers; the first two actions still show ↵ / ⌘↵ and match the bottom bar.

## Files

- **Create** `apps/macos/Sources/InvokeShell/ActionSection.swift`: `ActionSection`, `ActionEntry`.
- **Modify** `packages/api/src/index.ts`: add `action-panel-submenu` type; un-alias `ActionPanel.Submenu`.
- **Modify** `apps/macos/Sources/InvokeShell/AppController.swift`: `extensionActionSections(under:)`, `currentActionSections()`, `actionSectionsProvider`. (`currentActions()` and the bar untouched.)
- **Modify** `apps/macos/Sources/InvokeShell/PaletteWindow.swift`: present via `actionSectionsProvider`.
- **Modify** `apps/macos/Sources/InvokeShell/ActionPanel.swift`: `[ActionSection]` input, level stack, `PanelRow` model, section separators/headers, submenu rows + drill-in nav, header/back, `nextSelectable` helper.
- **Modify** `examples/accessory-demo`: add the ActionPanel fixture.
