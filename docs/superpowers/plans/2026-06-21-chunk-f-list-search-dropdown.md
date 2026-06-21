# Chunk F — P1 List/Grid Search + Dropdown Controlled Props Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Honor List/Grid controlled `searchText`, `throttle`, and explicit `filtering`/`filtering={false}`, plus `List/Grid.Dropdown` `storeValue`/`filtering`/`isLoading`/`tooltip`.

**Architecture:** All host-side. Search-bar behavior in `AppController` (`hostShouldFilter`, `onSearch`, controlled-text reflection, throttle) + a `reflectSearchText` API on `PaletteWindow`. Dropdown props in `AppController.updateExtensionDropdown` + threaded through `PaletteWindow.setSearchDropdown` → `SearchBarDropdown.configure` → `DropdownOverlay`. `@invoke/api` passes these as plain data props — no shim change.

**Tech Stack:** Swift 6 / AppKit (`apps/macos`), TS fixture importing `@raycast/api`.

## Global Constraints
- World-class Raycast-quality UX; never ship system-default/janky UI.
- Faithful parity; do NOT fabricate third-party brands. Fixture imports `@raycast/api`.
- Commit on `main`. Relaunch `Invoke.app` after build+install.
- No Xcode/XCTest: AppKit verified by `swift build --package-path apps/macos` + fixture build/relaunch/log; pure logic by standalone `swift`.
- Build: `swift build --package-path apps/macos` (cwd resets between Bash calls — always `--package-path`).
- Ignore SourceKit "Cannot find X in scope" / "let binding pattern" false-positives when `swift build` succeeds.

---

### Task 1: Honor explicit `filtering` / `filtering={false}`

**Files:** Modify `apps/macos/Sources/InvokeShell/AppController.swift` (`surfaceSelfFilters` ~106, `activeTree` ~96, `onSearch` ~318-328).

**Interfaces:**
- Produces: `surfaceHasSearchHandler() -> Bool` (renamed from `surfaceSelfFilters`), `hostShouldFilter() -> Bool`, `searchSurfaceNode() -> ViewNode?` — consumed by Tasks 2 & 3.

- [ ] **Step 1: Add a shared surface accessor + the two predicates.** Replace `surfaceSelfFilters()` (lines ~104-109) with:

```swift
    /// The active extension's top-level list/grid node (the search surface), or nil.
    private func searchSurfaceNode() -> ViewNode? {
        extHost?.frameTree(activeFrame).root.children.first { ["list", "grid"].contains($0.type) }
    }

    /// True if the search surface declares its own onSearchTextChange (then the extension filters).
    private func surfaceHasSearchHandler() -> Bool {
        searchSurfaceNode()?.props["onSearchTextChange"]?.handlerRef != nil
    }

    /// Whether the HOST applies its built-in item filter. An explicit `filtering` prop wins; otherwise
    /// the host filters only when the surface has no onSearchTextChange handler (Raycast default).
    private func hostShouldFilter() -> Bool {
        if case .bool(let f)? = searchSurfaceNode()?.props["filtering"] { return f }
        return !surfaceHasSearchHandler()
    }
```

- [ ] **Step 2: Use `hostShouldFilter()` in `activeTree`.** In `activeTree` (~96), change:
```swift
            if !extSearchFilter.isEmpty, !surfaceSelfFilters() {
```
to:
```swift
            if !extSearchFilter.isEmpty, hostShouldFilter() {
```

- [ ] **Step 3: Restructure the `onSearch` extensionView branch.** Replace (lines ~318-328):
```swift
        if mode == .extensionView {
            // If the surface handles search itself, forward it; otherwise apply built-in item filtering.
            if surfaceSelfFilters() {
                extSearchFilter = ""
                extHost?.setSearchText(text) // re-render arrives via onCommit
            } else {
                extSearchFilter = text
                selectedIndex = 0
                renderExtension()
            }
            return
        }
```
with:
```swift
        if mode == .extensionView {
            let hasHandler = surfaceHasSearchHandler()
            let hostFilter = hostShouldFilter()
            // Host built-in filter uses extSearchFilter; the extension's own search uses onSearchTextChange.
            // Both can be active (filtering={true} + a handler): forward AND filter.
            extSearchFilter = hostFilter ? text : ""
            if hasHandler { extHost?.setSearchText(text) } // re-render arrives via onCommit (throttle: Task 3)
            if hostFilter { selectedIndex = 0; renderExtension() }
            return
        }
```

- [ ] **Step 4: Build.** `swift build --package-path apps/macos 2>&1 | tail -20` → `Build complete!`.

- [ ] **Step 5: Commit.**
```bash
git add apps/macos/Sources/InvokeShell/AppController.swift
git commit -m "feat(list): honor explicit filtering / filtering={false} (override handler-presence default)"
```

---

### Task 2: Controlled `searchText`

**Files:** Modify `apps/macos/Sources/InvokeShell/PaletteWindow.swift` (add `reflectSearchText`), `apps/macos/Sources/InvokeShell/AppController.swift` (`renderExtension` ~3623-3628).

**Interfaces:**
- Consumes: `searchSurfaceNode()` (Task 1).
- Produces: `PaletteWindow.reflectSearchText(_:)`.

- [ ] **Step 1: Add `reflectSearchText` to PaletteWindow.** Near `clearSearch()` / the search-field helpers, add:

```swift
    /// Reflect an extension-controlled List/Grid `searchText` into the search field. No-op when already
    /// equal (so the caret isn't disturbed in the common echo case); otherwise sets the value + caret to
    /// end. Setting `.stringValue` programmatically does not fire `controlTextDidChange`, so no onSearch loop.
    public func reflectSearchText(_ text: String) {
        guard searchField.stringValue != text else { return }
        searchField.stringValue = text
        if let editor = searchField.currentEditor() {
            editor.selectedRange = NSRange(location: (text as NSString).length, length: 0)
        }
    }
```

- [ ] **Step 2: Reflect the controlled value on each extension render.** In `AppController`, add a helper and call it in `renderExtension()` right after `updateExtensionDropdown()` (~3628):

```swift
    /// If the search surface has a controlled `searchText` prop, mirror it into the search field.
    private func reflectControlledSearchText() {
        guard mode == .extensionView, let st = searchSurfaceNode()?.props["searchText"]?.stringValue else { return }
        palette.reflectSearchText(st)
    }
```
and in `renderExtension()`:
```swift
        updateExtensionDropdown()
        reflectControlledSearchText()
```

- [ ] **Step 3: Build.** `swift build --package-path apps/macos 2>&1 | tail -20` → `Build complete!`.

- [ ] **Step 4: Commit.**
```bash
git add apps/macos/Sources/InvokeShell/PaletteWindow.swift apps/macos/Sources/InvokeShell/AppController.swift
git commit -m "feat(list): controlled searchText — reflect extension value into the search field"
```

---

### Task 3: `throttle` (debounce the onSearchTextChange forward)

**Files:** Modify `apps/macos/Sources/InvokeShell/AppController.swift` (`onSearch` extensionView branch from Task 1; `teardownExtension`; add a member).

**Interfaces:**
- Consumes: `searchSurfaceNode()`, `surfaceHasSearchHandler()`, `hostShouldFilter()` (Task 1).

- [ ] **Step 1: Add the throttle work member.** Near the other extension state (e.g. by `extDropdownValue` ~3689 or the search state ~91), add:
```swift
    private var searchThrottleWork: DispatchWorkItem?
```

- [ ] **Step 2: Debounce the forward in `onSearch`.** Replace the Task-1 extensionView branch with the throttled version:
```swift
        if mode == .extensionView {
            let surface = searchSurfaceNode()
            let hasHandler = surface?.props["onSearchTextChange"]?.handlerRef != nil
            let hostFilter: Bool = { if case .bool(let f)? = surface?.props["filtering"] { return f }; return !hasHandler }()
            let throttle: Bool = { if case .bool(let t)? = surface?.props["throttle"] { return t }; return false }()
            extSearchFilter = hostFilter ? text : ""
            searchThrottleWork?.cancel()
            if hasHandler {
                if throttle {
                    let work = DispatchWorkItem { [weak self] in self?.extHost?.setSearchText(text) }
                    searchThrottleWork = work
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: work) // ~250ms debounce
                } else {
                    extHost?.setSearchText(text)
                }
            }
            if hostFilter { selectedIndex = 0; renderExtension() }
            return
        }
```
(This supersedes Task 1's simpler branch; it reads the surface once and folds in `throttle`. `hostFilter`/`hasHandler` logic is identical to Task 1's predicates, inlined here to read the surface a single time.)

- [ ] **Step 3: Cancel pending throttle on teardown.** In `teardownExtension()`, add:
```swift
        searchThrottleWork?.cancel(); searchThrottleWork = nil
```

- [ ] **Step 4: Build.** `swift build --package-path apps/macos 2>&1 | tail -20` → `Build complete!`.

- [ ] **Step 5: Commit.**
```bash
git add apps/macos/Sources/InvokeShell/AppController.swift
git commit -m "feat(list): throttle — debounce onSearchTextChange forward (~250ms)"
```

---

### Task 4: Dropdown `storeValue` (+ `tooltip`)

**Files:** Modify `apps/macos/Sources/InvokeShell/AppController.swift` (`updateExtensionDropdown` ~3666-3677), `apps/macos/Sources/InvokeShell/PaletteWindow.swift` (`setSearchDropdown` ~529), `apps/macos/Sources/InvokeShell/SearchBarDropdown.swift` (`configure` ~64).

**Interfaces:**
- Consumes: `currentExtId` (member, ~line 65), `lastLaunch?.command`.
- Produces: extended `setSearchDropdown(items:selected:tooltip:filtering:isLoading:onChange:)` and `SearchBarDropdown.configure(items:selected:filtering:isLoading:tooltip:onSelect:)` (Task 5 adds filtering/isLoading; here add the params with defaults).

- [ ] **Step 1: storeValue persistence + tooltip in `updateExtensionDropdown`.** Replace the selection/handler block (lines ~3671-3677, from `let current = ...` through the `palette.setSearchDropdown(...) { ... }` closure) with:

```swift
        let storeValue: Bool = { if case .bool(let s)? = dd.props["storeValue"] { return s }; return false }()
        let ddId = dd.props["id"]?.stringValue ?? "default"
        let storeKey = "extdd.\(currentExtId).\(lastLaunch?.command ?? "").\(ddId)"
        let stored = storeValue ? UserDefaults.standard.string(forKey: storeKey) : nil
        // Precedence: controlled value → persisted (storeValue) → user's last pick → defaultValue → first.
        let current = dd.props["value"]?.stringValue ?? stored ?? extDropdownValue
            ?? dd.props["defaultValue"]?.stringValue ?? items.first?.value ?? ""
        let handler = dd.props["onChange"]?.handlerRef
        let tooltip = dd.props["tooltip"]?.stringValue
        palette.setSearchDropdown(items: items, selected: current, tooltip: tooltip) { [weak self] value in
            guard let self, let handler else { return }
            self.extDropdownValue = value
            if storeValue { UserDefaults.standard.set(value, forKey: storeKey) }
            self.extHost?.invoke(handler: handler, args: [.string(value)]) // re-renders via the next commit
        }
```
(The mount-onChange block below it is unchanged.)

- [ ] **Step 2: Add `tooltip` to `setSearchDropdown`.** In `PaletteWindow.setSearchDropdown` (~529), add a `tooltip: String? = nil` parameter and pass it through to `configure`:
```swift
    public func setSearchDropdown(items: [(title: String, value: String, iconPath: String?)], selected: String,
                                  tooltip: String? = nil, onChange: @escaping (String) -> Void) {
        filterButton.isHidden = true
        searchDropdown.configure(
            items: items.map { SearchBarDropdown.Item(title: $0.title, value: $0.value, iconRef: $0.iconPath) },
            selected: selected, tooltip: tooltip, onSelect: onChange)
        searchTrailingDefault.isActive = false
        searchTrailingWithFilter.isActive = false
        searchTrailingWithDropdown.isActive = true
    }
```

- [ ] **Step 3: Apply `tooltip` in `SearchBarDropdown.configure`.** Add a `tooltip: String? = nil` param (defaults keep callers compiling) and set the pill's tooltip:
```swift
    func configure(items: [Item], selected: String, tooltip: String? = nil, onSelect: @escaping (String) -> Void) {
        self.items = items
        self.selectedValue = selected
        self.onSelect = onSelect
        self.toolTip = tooltip
        if let cur = items.first(where: { $0.value == selected }) ?? items.first {
            titleLabel.stringValue = cur.title
            FaviconLoader.load(cur.iconRef, into: iconView)
        }
        isHidden = false
        if overlay.isShown { overlay.dismiss() }
    }
```

- [ ] **Step 4: Build.** `swift build --package-path apps/macos 2>&1 | tail -20` → `Build complete!`.

- [ ] **Step 5: Commit.**
```bash
git add apps/macos/Sources/InvokeShell/AppController.swift apps/macos/Sources/InvokeShell/PaletteWindow.swift apps/macos/Sources/InvokeShell/SearchBarDropdown.swift
git commit -m "feat(dropdown): storeValue (persist selection across launches) + tooltip"
```

---

### Task 5: Dropdown `filtering={false}` + `isLoading`

**Files:** Modify `apps/macos/Sources/InvokeShell/AppController.swift` (`updateExtensionDropdown` — pass the two flags), `apps/macos/Sources/InvokeShell/PaletteWindow.swift` (`setSearchDropdown`), `apps/macos/Sources/InvokeShell/SearchBarDropdown.swift` (`configure` + `open` + `DropdownOverlay.present`/`applyFilter`/`build`).

**Interfaces:**
- Consumes: `setSearchDropdown` / `configure` from Task 4 (add `filtering`/`isLoading` params).

- [ ] **Step 1: Read the two flags in `updateExtensionDropdown` and pass them.** Where Task 4 reads `tooltip`, also add:
```swift
        let filtering: Bool = { if case .bool(let f)? = dd.props["filtering"] { return f }; return true }()
        let isLoading: Bool = { if case .bool(let l)? = dd.props["isLoading"] { return l }; return false }()
```
and extend the `setSearchDropdown(...)` call to pass `filtering: filtering, isLoading: isLoading` (alongside `tooltip:`).

- [ ] **Step 2: Thread the flags through `PaletteWindow.setSearchDropdown`.** Add `filtering: Bool = true, isLoading: Bool = false` params and pass to `configure(... filtering: filtering, isLoading: isLoading ...)`.

- [ ] **Step 3: Store + forward the flags in `SearchBarDropdown`.** Add `filtering`/`isLoading` stored properties (default `true`/`false`); accept them in `configure` (params with defaults); in `open()`, pass them into `overlay.present(... filtering: filtering, isLoading: isLoading ...)`.

```swift
    private var filtering = true
    private var isLoading = false
    // configure(... filtering: Bool = true, isLoading: Bool = false ...): set self.filtering = filtering; self.isLoading = isLoading
    // open(): overlay.present(in: host, anchor: self, items: items, selected: selectedValue, filtering: filtering, isLoading: isLoading) { ... }
```

- [ ] **Step 4: Honor the flags in `DropdownOverlay`.** Add `filtering`/`isLoading` params to `present(...)` (store them). Add a height constraint handle for the search field so it can collapse:
  - In `build()`, capture the search-field top/height into a deactivatable constraint and add a separator-height constraint, OR simpler: keep references to `searchField` + `sep` (already instance members) and toggle `isHidden` + a height constraint.
  - In `present(...)`: when `!filtering` → `searchField.isHidden = true`; collapse the search field's vertical space (set a stored `searchFieldHeight` constraint constant to 0 and the `sep` hidden) so the list starts at the top; when `filtering` → restore. (Add `private var searchFieldHeight: NSLayoutConstraint!` built in `build()` as `searchField.heightAnchor.constraint(equalToConstant: 20)`; set `.constant = filtering ? 20 : 0`, and `sep.isHidden = !filtering`.)
  - In `applyFilter(_:)`: `filtered = (!filtering || query.isEmpty) ? allItems : allItems.filter { $0.title.lowercased().contains(query) }`.
  - `isLoading`: when `true`, after building rows, if `filtered.isEmpty` (or always), insert a single non-selectable "Loading…" row with a small spinning `NSProgressIndicator` (style `.spinning`, `startAnimation`). Keep it simple: a `DropdownRow`-sized container with a spinner + "Loading…" label; not hoverable/clickable. When `isLoading` is false, no such row.

- [ ] **Step 5: Build.** `swift build --package-path apps/macos 2>&1 | tail -20` → `Build complete!`.

- [ ] **Step 6: Commit.**
```bash
git add apps/macos/Sources/InvokeShell/AppController.swift apps/macos/Sources/InvokeShell/PaletteWindow.swift apps/macos/Sources/InvokeShell/SearchBarDropdown.swift
git commit -m "feat(dropdown): honor filtering={false} (hide inline filter) + isLoading (spinner row)"
```

---

### Task 6: Fixture (`list-search-demo`) + end-to-end verify

**Files:** Create `examples/list-search-demo/package.json`, `examples/list-search-demo/src/controlled-search.tsx`, `examples/list-search-demo/src/static-list.tsx`.

- [ ] **Step 1: Read the reference manifest.** `cat examples/tech-radar/package.json` and `cat examples/empty-action-demo/package.json` — mirror the actual repo manifest shape (schema, deps `@raycast/api`, no `$schema`/`scripts`/`license` if the others omit them, `platforms`, `peerDependencies` react). Two view commands.

- [ ] **Step 2: Create `package.json`** (mirror the empty-action-demo manifest exactly; commands `controlled-search` + `static-list`, both `mode: view`; titles/description describing the controlled search + filtering demos).

- [ ] **Step 3: Create `src/controlled-search.tsx`** — controlled `searchText` + `throttle` + a `storeValue` dropdown:
```tsx
import { List, useState } from "@raycast/api"; // if useState is not re-exported, import from "react"
```
(Use `import { useState } from "react";` — match how `examples/empty-action-demo` imports React hooks.)
```tsx
import { List } from "@raycast/api";
import { useState } from "react";

const ALL = ["Apple", "Banana", "Cherry", "Date", "Elderberry"];

export default function ControlledSearch() {
  const [text, setText] = useState("");
  const [cat, setCat] = useState("all");
  // Controlled: upper-case the query back into the bar (proves controlled reflection).
  const onChange = (q: string) => setText(q.toUpperCase());
  const items = ALL.filter((f) => f.toUpperCase().includes(text)).filter((f) => cat === "all" || f[0].toLowerCase() <= "c" === (cat === "early"));
  return (
    <List
      searchText={text}
      onSearchTextChange={onChange}
      throttle
      filtering={false}
      searchBarPlaceholder="Type — it reflects UPPER-CASED"
      searchBarAccessory={
        <List.Dropdown tooltip="Category" storeValue value={cat} onChange={setCat}>
          <List.Dropdown.Item title="All" value="all" />
          <List.Dropdown.Item title="Early (A–C)" value="early" />
          <List.Dropdown.Item title="Late (D+)" value="late" />
        </List.Dropdown>
      }
    >
      {items.map((f) => (
        <List.Item key={f} title={f} />
      ))}
    </List>
  );
}
```

- [ ] **Step 4: Create `src/static-list.tsx`** — `filtering={false}`, no handler (typing filters nothing):
```tsx
import { List } from "@raycast/api";

export default function StaticList() {
  return (
    <List filtering={false} searchBarPlaceholder="Typing here filters nothing (filtering=false)">
      <List.Item title="Always Visible 1" />
      <List.Item title="Always Visible 2" />
      <List.Item title="Always Visible 3" />
    </List>
  );
}
```

- [ ] **Step 5: Typecheck** the fixture the same way `examples/empty-action-demo` is typechecked. Expected: no type errors (`searchText`, `throttle`, `filtering`, `List.Dropdown` `tooltip`/`storeValue`/`value`/`onChange` all exist in the shim — confirm `storeValue`/`tooltip`/`filtering`/`isLoading` are accepted by the Dropdown props type; if a prop is missing from the TS type, add it to the Dropdown props interface in `packages/api/src/index.ts`, mirroring how Chunk E added `CommonActionProps.style`).

- [ ] **Step 6: Build app + relaunch + check log.** `scripts/build-app.sh 2>&1 | tail -5`; relaunch `Invoke.app`; `tail -40 /tmp/invoke-run.log` → command count increased by +2 for the fixture, no load/parse error.

- [ ] **Step 7: Human visual checklist (record in the report, don't assert):**
  - `controlled-search`: typing shows UPPER-CASED text in the bar (controlled); results update without firing per-keystroke (throttle); the "Category" dropdown shows a tooltip and its pick persists across an app relaunch (storeValue).
  - `static-list`: typing filters nothing — all three items stay (filtering=false).

- [ ] **Step 8: Commit.**
```bash
git add examples/list-search-demo
git commit -m "test(fixture): list-search-demo exercises controlled searchText/throttle/filtering + Dropdown storeValue/tooltip"
```

---

## Self-Review

**1. Spec coverage:** Item 1 filtering → Task 1. Item 2 controlled searchText → Task 2. Item 3 throttle → Task 3. Item 4 storeValue+tooltip → Task 4. Item 5 filtering={false}+isLoading → Task 5. Item 6 fixture → Task 6. ✅

**2. Placeholder scan:** No TBD/TODO; concrete code for each non-mechanical step. Task 5 Step 4 describes the overlay layout toggle precisely (constraint handle + isHidden + applyFilter branch + spinner row). ✅

**3. Type/identifier consistency:** `searchSurfaceNode`/`surfaceHasSearchHandler`/`hostShouldFilter` defined Task 1, reused Tasks 2-3. `reflectSearchText` defined Task 2 Step 1, called Task 2 Step 2. `setSearchDropdown` gains `tooltip` (Task 4) then `filtering`/`isLoading` (Task 5) — params added with defaults so intermediate states compile. `configure` likewise. `storeKey` uses `currentExtId` + `lastLaunch?.command` + `ddId` (all exist). `searchThrottleWork` defined Task 3 Step 1, used Steps 2-3. ✅

**Note for the implementer of Tasks 1 & 3:** Task 3 Step 2 REPLACES the `onSearch` extensionView branch that Task 1 Step 3 created (Task 3 reads the surface once and folds in `throttle`). When doing Task 3, replace Task 1's branch wholesale with the Task 3 version. The behavior (filtering decision) is identical; Task 3 just adds throttle and avoids re-reading the surface.

**Known nuance (final-review triage):** controlled `searchText` reflection runs on every extension commit; if an extension sets `searchText` but the user is mid-type with a host filter active, the reflect no-op guard (`!=`) avoids caret disruption in the echo case. A transforming controlled list (e.g. upper-casing) will move the caret to end on each keystroke — that is the correct controlled behavior and matches Raycast.
