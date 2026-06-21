# Chunk F — P1 List/Grid Search + Dropdown Controlled Props Design

**Part of the autonomous Raycast-parity push** (`[[autonomous-parity-goal]]`). Closes the P1 controlled-search + dropdown items in `RAYCASTVSINVOKE.md` §1 (rows 31, 35, 38): controlled `searchText`, `throttle`, explicit `filtering` / `filtering={false}`, and `List/Grid.Dropdown` `storeValue` / `filtering` / `isLoading` / `tooltip`.

## Global constraints
- World-class Raycast-quality UX; never ship system-default/janky UI.
- Faithful Raycast parity; don't fabricate third-party brands. Fixture imports `@raycast/api`.
- Commit on `main`. Relaunch `Invoke.app` after build+install.
- No Xcode/XCTest → AppKit verified via `swift build --package-path apps/macos` + `scripts/build-app.sh` + relaunch + `/tmp/invoke-run.log`; pure logic via standalone `swift`/`tsx`.
- `@invoke/api` already passes these as plain data props (they serialize fine) — **no api-shim change expected**; this chunk is Swift-host-side (`AppController` + `PaletteWindow` + `SearchBarDropdown`).

---

## Item 1 — Honor explicit `filtering` / `filtering={false}` (List/Grid)

**Current:** `AppController.surfaceSelfFilters()` returns `true` iff the surface declares `onSearchTextChange`; the host then skips its built-in filter. `activeTree` applies `filterTree` only when `!extSearchFilter.isEmpty && !surfaceSelfFilters()`. The explicit `filtering` prop is never read, so `filtering={false}` (disable the built-in filter even with no handler) and `filtering={true}` (force the built-in filter even *with* a handler — server search + client filter) aren't honored.

**Design:**
- Rename `surfaceSelfFilters()` → `surfaceHasSearchHandler()` (semantics unchanged: top-level list/grid has an `onSearchTextChange` handlerRef).
- Add `hostShouldFilter() -> Bool`: if the surface's `filtering` prop is an explicit bool → return it; else → `!surfaceHasSearchHandler()` (current default).
- `activeTree`: use `hostShouldFilter()` in place of `!surfaceSelfFilters()`.
- `onSearch` extensionView branch, restructured:
  ```swift
  if mode == .extensionView {
      let hasHandler = surfaceHasSearchHandler()
      let hostFilter = hostShouldFilter()
      extSearchFilter = hostFilter ? text : ""
      if hasHandler { extHost?.setSearchText(text) }   // forward to the extension (re-render via onCommit)
      if hostFilter { selectedIndex = 0; renderExtension() }
      return
  }
  ```
  Covers all four combinations: handler-only (forward), host-only (filter), both `filtering={true}`+handler (forward + filter), `filtering={false}`+no handler (static list, no filter).

## Item 2 — Controlled `searchText` (List/Grid)

**Current:** the palette search field is purely user-driven; the surface's `searchText` prop is ignored, so a controlled list (extension owns the search value, e.g. clears or transforms it) can't drive the field.

**Design:**
- Add `PaletteWindow.reflectSearchText(_ text: String)`: sets `searchField.stringValue = text` **only if different** (no-op when equal, so the caret/typing isn't disturbed in the common echo case) and moves the insertion point to the end. Setting `.stringValue` programmatically does NOT fire `controlTextDidChange`, so there's no onSearch feedback loop.
- In the extension render/commit path (where `updateExtensionDropdown()` is already called per commit), read the top-level list/grid surface's `searchText` prop; if **present** (controlled), call `palette.reflectSearchText(value)`. If absent (uncontrolled), do nothing.
- This is the controlled pattern: user types → `onSearch` forwards to the extension → extension `setState(searchText)` → re-render with the new `searchText` prop → reflected back to the field (identical in the common case → no-op; transformed → field updates).

## Item 3 — `throttle` (List/Grid)

**Current:** every keystroke forwards to the extension's `onSearchTextChange` immediately (`extHost?.setSearchText(text)`); `throttle` is ignored, so server-side-search extensions get hammered.

**Design:**
- Read the surface's `throttle` (bool). When forwarding to the extension (`hasHandler`) **and** `throttle == true`, debounce the `setSearchText` call by **250ms** via a cancel-and-reschedule `DispatchWorkItem` (`searchThrottleWork`), instead of calling it inline. The built-in host filter (if active) stays instant; only the extension callback is throttled (matches Raycast — throttle gates the async search, not local responsiveness).
- The latest text always wins (each keystroke cancels the prior pending work). Cancel any pending throttle work when the surface changes / extension exits (fold into the existing mode-transition reset).

## Item 4 — `List.Dropdown` / `Grid.Dropdown` `storeValue` (+ `tooltip`)

**Current:** `updateExtensionDropdown()` resolves the selection as `value ?? extDropdownValue (in-memory) ?? defaultValue ?? first`. `storeValue` (persist the selection across launches) and `tooltip` are ignored.

**Design:**
- **storeValue:** when `dd.props["storeValue"] == true`, persist the chosen value in `UserDefaults` under a stable key `"extdd." + <extId> + "." + <dropdownId>` (extId = the current extension's stable identifier — the same id used for extension prefs/grants; dropdownId = `dd.props["id"]`, fall back to `"default"`). Selection precedence becomes: controlled `value` → (`storeValue` ? persisted value) → `extDropdownValue` → `defaultValue` → first. On the user's `onSelect`, if `storeValue`, write the value to `UserDefaults`. (Reuse the `AppSettings`/`UserDefaults` pattern already in the codebase.)
- **tooltip:** set the pill's `toolTip` from `dd.props["tooltip"]` (thread a `tooltip:` param through `setSearchDropdown` → `SearchBarDropdown.configure`, applied to the trigger view's `toolTip`).

## Item 5 — `List.Dropdown` `filtering={false}` + `isLoading`

**Current:** `DropdownOverlay` always shows its inline filter field and filters items by typed text. `filtering` (default `true`) and `isLoading` are ignored.

**Design (thread two flags through `setSearchDropdown` → `SearchBarDropdown.configure` → `DropdownOverlay.present`):**
- **filtering** (default `true`): when `false`, hide the overlay's inline `searchField` (and the separator) and show all items unfiltered (no client filter). When `true`, unchanged.
- **isLoading** (default `false`): when `true`, show a single non-selectable "Loading…" row (with an `NSProgressIndicator` spinner) in place of (or above) the item rows until it clears. Low-risk, popover-local.

## Item 6 — Fixture + verify

- `examples/list-search-demo/` (manifest mirrors `examples/tech-radar`, imports `@raycast/api`), commands:
  - **Controlled + throttled search:** a `List` with controlled `searchText` + `throttle` + `onSearchTextChange` that upper-cases the query into the bar (proves controlled reflection) and renders items containing the (debounced) query; a `searchBarAccessory={<List.Dropdown storeValue tooltip="Category" filtering>…}` whose selection filters the list and persists across launches.
  - **filtering={false}:** a second `List` with `filtering={false}` + no `onSearchTextChange` showing a fixed item set (typing filters nothing — proves the built-in filter is disabled).
- Verify: typecheck clean; `scripts/build-app.sh` succeeds; relaunch; `/tmp/invoke-run.log` shows the fixture's commands loaded with no error. Visual confirm (human): controlled upper-casing in the bar, throttled search not firing per-keystroke, dropdown selection persisting across relaunch, `filtering={false}` showing all items while typing.

## Testing strategy
- **Pure/standalone:** the `hostShouldFilter` decision table (explicit bool vs handler-presence default) as a standalone `swift` predicate test.
- **AppKit/integration:** controlled reflection, throttle debounce, storeValue persistence, dropdown flags — via build + fixture + relaunch + log + human visual confirm.

## Out of scope (tracked elsewhere)
- Fuzzy ranking of the built-in filter (still substring) — separate polish, not in §1's controlled-props scope.
- `selectedItemId` / `onSelectionChange` (report selection back) — separate ⬜ row, not this chunk.
- `Grid.Dropdown` shares the `List.Dropdown` code path; no Grid-specific dropdown work needed beyond what Items 4–5 cover.
