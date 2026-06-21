# ActionPanel Section/Submenu Grouping Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Render an extension's `<ActionPanel>` in the ⌘K panel with grouped `Section`s (separators + small-caps titles) and drill-in `Submenu`s, instead of one flat list.

**Architecture:** A structured `[ActionSection]` model replaces the panel's flat `[PaletteAction]` input. `@invoke/api` gets a real `action-panel-submenu` node type; `AppController` builds the section tree from the selected item's `<ActionPanel>` subtree; `ActionPanel.swift` renders sections and maintains a navigation stack for submenu drill-in. The bottom action bar and `currentActions()` are untouched.

**Tech Stack:** Swift / AppKit (`apps/macos`), `JSONValue`/`ViewNode` (InvokeIPC), TypeScript (`@invoke/api`, fixture).

## Global Constraints

- **`currentActions()` and the bottom action bar are untouched.** Built-in modes (chat/clip/snippet/quicklink/command/screenshot) reach the panel as ONE untitled section wrapping their flat `currentActions()` — zero behavior change. Only `mode == .extensionView` builds real sections.
- **Submenus drill in** (Raycast-faithful): a submenu is a row with a trailing "›"; Return/→ pushes its sections, Esc/← pops, Esc at root dismisses. Not inline expansion.
- **Shortcut parity:** the first leaf `action` in document order (not descending into submenus) shows ↵, the second ⌘↵ — matching the bar so chips agree.
- **Section rendering:** a thin separator before every section after the first; a non-selectable small-caps `secondaryLabelColor` title row when a section has a `title`. ↑/↓ and hover skip non-selectable rows.
- **The action run path is `perform(_ n: ViewNode)`** (what `currentActions()`'s extension branch uses) — reuse it; do not invent a new runner.
- **Pure nav logic** (`nextSelectable`/`firstSelectable`) lives in a project-type-free file so it is standalone-`swift`-testable. Everything else (AppKit, `ViewNode` walker) is verified via `swift build` + the fixture in the running app (CLT-only: no Xcode, no XCTest, no pixels).
- **Commit on `main`; push after each task.**

---

### Task 1: Structured model + pure nav helper

**Files:**
- Create: `apps/macos/Sources/InvokeShell/ActionSection.swift`
- Create: `apps/macos/Sources/InvokeShell/ActionPanelNav.swift`
- Test: `/private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad/actionnav_tests.swift`

**Interfaces:**
- Produces (used by Tasks 2 & 3): `struct ActionSection { let title: String?; let entries: [ActionEntry] }`; `enum ActionEntry { case action(PaletteAction); case submenu(title: String, icon: String?, sections: [ActionSection]) }`; `func nextSelectable(_ selectable: [Bool], from: Int, delta: Int) -> Int`; `func firstSelectable(_ selectable: [Bool]) -> Int`.

- [ ] **Step 1: Write the failing test** — create the test file:

```swift
// actionnav_tests.swift — top-level assertions; cat-combined with ActionPanelNav.swift to run.
var failures = 0
func check(_ c: Bool, _ m: String) { if c { print("ok: \(m)") } else { failures += 1; print("FAIL: \(m)") } }

let s = [false, true, true, false, true] // header, action, action, header, action
check(nextSelectable(s, from: 1, delta: 1) == 2, "down to next action")
check(nextSelectable(s, from: 2, delta: 1) == 4, "down skips header")
check(nextSelectable(s, from: 4, delta: 1) == 4, "down at last clamps")
check(nextSelectable(s, from: 4, delta: -1) == 2, "up skips header")
check(nextSelectable(s, from: 1, delta: -1) == 1, "up at first clamps")
check(firstSelectable(s) == 1, "first selectable skips leading header")
check(firstSelectable([false, false]) == 0, "none selectable → 0")
check(nextSelectable([false, false], from: 0, delta: 1) == 0, "none selectable stays")

print(failures == 0 ? "ALL PASS" : "\(failures) FAILED")
exit(Int32(failures == 0 ? 0 : 1))
```

- [ ] **Step 2: Run it to verify it fails**

```bash
S=/private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad
cat apps/macos/Sources/InvokeShell/ActionPanelNav.swift "$S/actionnav_tests.swift" > "$S/nav_combined.swift" 2>/dev/null; swift "$S/nav_combined.swift"
```
Expected: FAIL — `ActionPanelNav.swift` doesn't exist yet.

- [ ] **Step 3: Write `ActionPanelNav.swift`**

```swift
import Foundation

/// Next selectable row index moving `delta` (+1 down / −1 up) from `from`, skipping non-selectable
/// rows (section headers / separators) and clamping at the ends (no wrap). Returns `from` if nothing
/// is selectable. `from` is expected to already be a selectable index (the selection invariant).
func nextSelectable(_ selectable: [Bool], from: Int, delta: Int) -> Int {
    guard selectable.contains(true), delta != 0 else { return from }
    var i = from
    while true {
        let n = i + delta
        if n < 0 || n >= selectable.count { return i } // hit an end → stay put
        i = n
        if selectable[i] { return i }
    }
}

/// First selectable index (initial selection), or 0 if none.
func firstSelectable(_ selectable: [Bool]) -> Int { selectable.firstIndex(of: true) ?? 0 }
```

- [ ] **Step 4: Write `ActionSection.swift`**

```swift
import Foundation

/// A group of actions in the ⌘K Action Panel (Raycast's `ActionPanel.Section`). `title` renders as a
/// small-caps header; `entries` render in order. Built from an extension's `<ActionPanel>` subtree, or a
/// single untitled section wrapping a built-in mode's flat action list.
struct ActionSection {
    let title: String?
    let entries: [ActionEntry]
}

/// One entry in a section: a runnable action, or a submenu that drills into its own sections.
enum ActionEntry {
    case action(PaletteAction)
    case submenu(title: String, icon: String?, sections: [ActionSection])
}
```

- [ ] **Step 5: Run the test to verify it passes**

```bash
S=/private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad
cat apps/macos/Sources/InvokeShell/ActionPanelNav.swift "$S/actionnav_tests.swift" > "$S/nav_combined.swift"; swift "$S/nav_combined.swift"
```
Expected: all `ok:` lines then `ALL PASS`.

- [ ] **Step 6: Build the module** (types compile, used by later tasks)

Run: `swift build --package-path apps/macos 2>&1 | tail -3`
Expected: `Build complete!`

- [ ] **Step 7: Commit**

```bash
git add apps/macos/Sources/InvokeShell/ActionSection.swift apps/macos/Sources/InvokeShell/ActionPanelNav.swift
git commit -m "ActionPanel: structured ActionSection/ActionEntry model + pure selection-skip nav helper"
git push origin main
```

---

### Task 2: `@invoke/api` Submenu type + structured collection

**Files:**
- Modify: `packages/api/src/index.ts` (add `action-panel-submenu`; un-alias `ActionPanel.Submenu`)
- Modify: `apps/macos/Sources/InvokeShell/AppController.swift` (add `paletteAction(for:shortcut:)`, `extensionActionSections(under:)`, `currentActionSections()`)

**Interfaces:**
- Consumes (Task 1): `ActionSection`, `ActionEntry`.
- Produces (Task 3): `currentActionSections() -> [ActionSection]` (the provider is registered in Task 3, where `PaletteWindow` declares it).

- [ ] **Step 1: Add the submenu node type** — in `packages/api/src/index.ts`, find the type map entry `ActionPanelSection: "action-panel-section",` (~line 66) and add directly after it:

```ts
  ActionPanelSubmenu: "action-panel-submenu",
```

- [ ] **Step 2: Un-alias `ActionPanel.Submenu`** — replace the existing block (the comment + `ActionPanel.Submenu = host(T.ActionPanelSection);`, ~lines 331-335) with:

```ts
ActionPanel.Submenu = host(T.ActionPanelSubmenu);
```

- [ ] **Step 3: Typecheck**

Run: `npm run typecheck 2>&1 | tail -5`
Expected: no errors (exit 0).

- [ ] **Step 4: Add the action builder + section walker** — in `apps/macos/Sources/InvokeShell/AppController.swift`, add these methods near `extensionActions(under:)` (~line 3687). `perform(_:)` (`:1718`) and `title(for:)` (`:1777`) already exist.

```swift
    /// One extension action node → a PaletteAction that runs via the live `perform(_:)` path.
    private func paletteAction(for n: ViewNode, shortcut: String? = nil) -> PaletteAction {
        PaletteAction(title: title(for: n), shortcut: shortcut, icon: n.props["icon"]?.stringValue) { [weak self] in
            self?.perform(n)
        }
    }

    /// Build the structured ⌘K model from the selected item's `<ActionPanel>` subtree (Raycast sections
    /// + submenus). No action-panel node → one untitled section over the flat actions (back-compat).
    private func extensionActionSections(under node: ViewNode) -> [ActionSection] {
        func firstActionPanel(_ n: ViewNode) -> ViewNode? {
            if n.type == "action-panel" { return n }
            for c in n.children { if let p = firstActionPanel(c) { return p } }
            return nil
        }
        guard let panel = firstActionPanel(node) else {
            return [ActionSection(title: nil, entries: actions(under: node).map { .action(paletteAction(for: $0)) })]
        }
        // ↵/⌘↵ to the first two LEAF actions in document order (do not descend into submenus).
        var leafIndex = 0
        func makeEntry(_ n: ViewNode) -> ActionEntry? {
            switch n.type {
            case "action":
                let sc = leafIndex == 0 ? "↵" : (leafIndex == 1 ? "⌘↵" : nil)
                leafIndex += 1
                return .action(paletteAction(for: n, shortcut: sc))
            case "action-panel-submenu":
                return .submenu(title: n.props["title"]?.stringValue ?? "Submenu",
                                icon: n.props["icon"]?.stringValue,
                                sections: sectionsOf(n))
            default:
                return nil
            }
        }
        func sectionsOf(_ container: ViewNode) -> [ActionSection] {
            var out: [ActionSection] = []
            var loose: [ActionEntry] = []
            func flushLoose() { if !loose.isEmpty { out.append(ActionSection(title: nil, entries: loose)); loose = [] } }
            for child in container.children {
                if child.type == "action-panel-section" {
                    flushLoose()
                    out.append(ActionSection(title: child.props["title"]?.stringValue,
                                             entries: child.children.compactMap(makeEntry)))
                } else if let e = makeEntry(child) {
                    loose.append(e)
                }
            }
            flushLoose()
            return out
        }
        return sectionsOf(panel)
    }

    /// Sections for the ⌘K panel: real sections for an extension view, else one untitled section over
    /// the existing flat `currentActions()` (built-in modes unchanged).
    private func currentActionSections() -> [ActionSection] {
        if mode == .extensionView {
            return extensionActionSections(under: node)
        }
        return [ActionSection(title: nil, entries: currentActions().map { ActionEntry.action($0) })]
    }
```

Note: `node` is the same selected-node reference `currentActions()` uses in its extension fallthrough (`actions(under: node)`). Use that identical reference. The new methods are `private` and have no caller yet (the provider is registered in Task 3); Swift does not warn on unused private methods, so the build stays clean.

- [ ] **Step 5: Build** (the new methods + the api change compile; methods are unused until Task 3)

Run: `swift build --package-path apps/macos 2>&1 | tail -3`
Expected: `Build complete!`

- [ ] **Step 6: Commit**

```bash
git add packages/api/src/index.ts apps/macos/Sources/InvokeShell/AppController.swift
git commit -m "ActionPanel: un-alias Submenu (@invoke/api) + build structured sections from the ActionPanel subtree"
git push origin main
```

---

### Task 3: Panel rewrite — sections + submenu drill-in

**Files:**
- Modify: `apps/macos/Sources/InvokeShell/ActionPanel.swift` (full rewrite of the panel body + `ActionRowView` init)
- Modify: `apps/macos/Sources/InvokeShell/PaletteWindow.swift` (declare `actionSectionsProvider`; present via it)
- Modify: `apps/macos/Sources/InvokeShell/AppController.swift` (register `actionSectionsProvider`)

**Interfaces:**
- Consumes (Tasks 1-2): `ActionSection`/`ActionEntry`, `nextSelectable`/`firstSelectable`, `currentActionSections()`.
- Produces: `ActionPanel.present(in:sections:title:)`; `palette.actionSectionsProvider`.

- [ ] **Step 1: Declare the provider, register it, present via it.**

(a) In `PaletteWindow.swift` add a stored property next to `actionsProvider`:
```swift
    var actionSectionsProvider: (() -> [ActionSection])?
```
(b) In `AppController` find `palette.actionsProvider = { [weak self] in self?.currentActions() ?? [] }` (~line 200) and add directly after it:
```swift
        palette.actionSectionsProvider = { [weak self] in self?.currentActionSections() ?? [] }
```
(c) In `PaletteWindow.swift` replace the present call (`:682`) `actionPanel.present(in: content, actions: actions, title: actionPanelTitleProvider?() ?? "")` with:
```swift
        actionPanel.present(in: content, sections: actionSectionsProvider?() ?? [], title: actionPanelTitleProvider?() ?? "")
```
(Leave the separate `actionsProvider` usage that feeds the bottom action bar unchanged. If a now-unused local `let actions = …` remains right above this call and is referenced nowhere else, delete that line.)

- [ ] **Step 2: Replace `ActionPanel.swift`** with the sections+submenu implementation. The view scaffolding (`buildViews`, constraints, `container`/`scroll`/`searchField`/`headerLabel`) is UNCHANGED; replace the state, `present`, filtering/rendering/selection, keyboard, and `ActionRowView`. Full file:

```swift
import AppKit

private final class FlippedView: NSView { override var isFlipped: Bool { true } }
private final class BackdropView: NSView {
    var onClick: (() -> Void)?
    override func mouseDown(with event: NSEvent) { onClick?() }
}

/// One displayed row in the panel. Headers/separators are non-selectable.
private enum PanelRow {
    case separator
    case header(String)
    case action(PaletteAction)
    case submenu(title: String, icon: String?, sections: [ActionSection])
    var isSelectable: Bool { if case .action = self { return true }; if case .submenu = self { return true }; return false }
}

/// Raycast-style Action Panel (PLAN.md §6): a floating rounded panel anchored bottom-right inside the
/// palette, listing the selected result's actions grouped into sections, with submenus that drill in.
/// Arrow keys move, Return runs / enters a submenu, →/← drill in/out, Esc pops a level or dismisses.
final class ActionPanel: NSObject, NSTextFieldDelegate {
    private let backdrop = BackdropView()
    private let container = NSVisualEffectView()
    private let headerLabel = NSTextField(labelWithString: "")
    private let listStack = NSStackView()
    private let docView = FlippedView()
    private let scroll = NSScrollView()
    private let searchField = NSTextField()
    private var scrollHeight: NSLayoutConstraint!

    private weak var parent: NSView?
    private var levels: [[ActionSection]] = []   // navigation stack; .last is the current level
    private var levelTitles: [String] = []
    private var rows: [PanelRow] = []            // current filtered display rows
    private var rowViews: [NSView] = []
    private var selectable: [Bool] = []
    private var selected = 0

    var onDismiss: (() -> Void)?
    var isShown: Bool { container.superview != nil }

    private let rowHeight: CGFloat = 34
    private let headerHeight: CGFloat = 22
    private let sepHeight: CGFloat = 9
    private let maxVisibleRows = 8
    private let panelWidth: CGFloat = 340

    override init() { super.init(); buildViews() }

    private func buildViews() {
        backdrop.translatesAutoresizingMaskIntoConstraints = false
        backdrop.onClick = { [weak self] in self?.dismiss() }

        container.material = .menu
        container.blendingMode = .withinWindow
        container.state = .active
        container.wantsLayer = true
        container.layer?.cornerRadius = 10
        container.layer?.masksToBounds = true
        container.layer?.borderWidth = 1
        container.translatesAutoresizingMaskIntoConstraints = false

        headerLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        headerLabel.textColor = .secondaryLabelColor
        headerLabel.translatesAutoresizingMaskIntoConstraints = false

        let headerSep = NSBox(); headerSep.boxType = .separator
        headerSep.translatesAutoresizingMaskIntoConstraints = false

        listStack.orientation = .vertical
        listStack.spacing = 2
        listStack.alignment = .leading
        listStack.translatesAutoresizingMaskIntoConstraints = false

        docView.translatesAutoresizingMaskIntoConstraints = false
        docView.addSubview(listStack)

        scroll.drawsBackground = false
        scroll.hasVerticalScroller = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.documentView = docView

        let searchSep = NSBox(); searchSep.boxType = .separator
        searchSep.translatesAutoresizingMaskIntoConstraints = false

        searchField.placeholderString = "Search for actions…"
        searchField.font = .systemFont(ofSize: 13)
        searchField.isBordered = false
        searchField.drawsBackground = false
        searchField.focusRingType = .none
        searchField.delegate = self
        searchField.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(headerLabel)
        container.addSubview(headerSep)
        container.addSubview(scroll)
        container.addSubview(searchSep)
        container.addSubview(searchField)

        scrollHeight = scroll.heightAnchor.constraint(equalToConstant: rowHeight)
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: panelWidth),
            headerLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            headerLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            headerLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            headerSep.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            headerSep.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            headerSep.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            scroll.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 6),
            scroll.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -6),
            scroll.topAnchor.constraint(equalTo: headerSep.bottomAnchor, constant: 6),
            scrollHeight,
            docView.topAnchor.constraint(equalTo: scroll.contentView.topAnchor),
            docView.leadingAnchor.constraint(equalTo: scroll.contentView.leadingAnchor),
            docView.trailingAnchor.constraint(equalTo: scroll.contentView.trailingAnchor),
            listStack.topAnchor.constraint(equalTo: docView.topAnchor),
            listStack.leadingAnchor.constraint(equalTo: docView.leadingAnchor),
            listStack.trailingAnchor.constraint(equalTo: docView.trailingAnchor),
            listStack.bottomAnchor.constraint(equalTo: docView.bottomAnchor),
            searchSep.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            searchSep.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            searchSep.topAnchor.constraint(equalTo: scroll.bottomAnchor, constant: 6),
            searchField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            searchField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            searchField.topAnchor.constraint(equalTo: searchSep.bottomAnchor, constant: 10),
            searchField.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),
        ])
    }

    // MARK: - Present / dismiss

    func present(in parent: NSView, sections: [ActionSection], title: String) {
        guard sections.contains(where: { $0.entries.contains(where: { if case .action = $0 { return true }; if case .submenu = $0 { return true }; return false }) }) else { return }
        self.parent = parent
        levels = [sections]
        levelTitles = [title.isEmpty ? "Actions" : title]
        searchField.stringValue = ""

        if backdrop.superview == nil {
            parent.addSubview(backdrop)
            parent.addSubview(container)
            NSLayoutConstraint.activate([
                backdrop.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
                backdrop.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
                backdrop.topAnchor.constraint(equalTo: parent.topAnchor),
                backdrop.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
                container.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -8),
                container.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -44),
            ])
        }
        backdrop.isHidden = false
        container.isHidden = false
        container.layer?.borderColor = NSColor.separatorColor.cgColor

        applyFilter("")
        parent.window?.makeFirstResponder(searchField)
    }

    func dismiss() {
        guard isShown else { return }
        backdrop.removeFromSuperview()
        container.removeFromSuperview()
        levels = []; levelTitles = []
        onDismiss?()
    }

    // MARK: - Build rows from the current level

    private func applyFilter(_ query: String) {
        let q = query.lowercased()
        let sections = levels.last ?? []
        rows = []
        var firstSection = true
        for section in sections {
            let entries = section.entries.filter { entry in
                guard !q.isEmpty else { return true }
                switch entry {
                case .action(let a): return a.title.lowercased().contains(q)
                case .submenu(let t, _, _): return t.lowercased().contains(q)
                }
            }
            guard !entries.isEmpty else { continue }
            if !firstSection { rows.append(.separator) }
            firstSection = false
            if let title = section.title, !title.isEmpty { rows.append(.header(title)) }
            for entry in entries {
                switch entry {
                case .action(let a): rows.append(.action(a))
                case .submenu(let t, let i, let s): rows.append(.submenu(title: t, icon: i, sections: s))
                }
            }
        }
        selectable = rows.map { $0.isSelectable }
        rebuildRows()
        selected = firstSelectable(selectable)
        updateSelectionHighlight()
        updateScrollHeight()
        updateHeader()
    }

    private func rebuildRows() {
        rowViews.forEach { $0.removeFromSuperview() }
        rowViews.removeAll()
        for (i, row) in rows.enumerated() {
            let view: NSView
            switch row {
            case .separator:
                let box = NSBox(); box.boxType = .separator
                box.translatesAutoresizingMaskIntoConstraints = false
                box.heightAnchor.constraint(equalToConstant: 1).isActive = true
                view = box
            case .header(let title):
                let l = NSTextField(labelWithString: title.uppercased())
                l.font = .systemFont(ofSize: 10, weight: .semibold)
                l.textColor = .tertiaryLabelColor
                l.translatesAutoresizingMaskIntoConstraints = false
                let wrap = NSView(); wrap.translatesAutoresizingMaskIntoConstraints = false
                wrap.addSubview(l)
                NSLayoutConstraint.activate([
                    wrap.heightAnchor.constraint(equalToConstant: headerHeight),
                    l.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 12),
                    l.bottomAnchor.constraint(equalTo: wrap.bottomAnchor, constant: -4),
                ])
                view = wrap
            case .action(let a):
                let r = ActionRowView(title: a.title, shortcut: a.shortcut, icon: ActionPanel.inferIcon(a), isSubmenu: false, height: rowHeight)
                r.onClick = { [weak self] in self?.activate(i) }
                r.onHover = { [weak self] in self?.setSelected(i) }
                view = r
            case .submenu(let t, let icon, _):
                let r = ActionRowView(title: t, shortcut: nil, icon: icon ?? "chevron.right.2", isSubmenu: true, height: rowHeight)
                r.onClick = { [weak self] in self?.activate(i) }
                r.onHover = { [weak self] in self?.setSelected(i) }
                view = r
            }
            listStack.addArrangedSubview(view)
            view.widthAnchor.constraint(equalTo: listStack.widthAnchor).isActive = true
            rowViews.append(view)
        }
    }

    private func updateScrollHeight() {
        var h: CGFloat = 0
        for (i, row) in rows.enumerated() {
            switch row {
            case .separator: h += 1
            case .header: h += headerHeight
            default: h += rowHeight
            }
            if i < rows.count - 1 { h += listStack.spacing }
        }
        let maxH = CGFloat(maxVisibleRows) * (rowHeight + listStack.spacing)
        scrollHeight.constant = min(max(h, rowHeight), maxH)
    }

    private func updateHeader() {
        let title = levelTitles.last ?? "Actions"
        headerLabel.stringValue = levels.count > 1 ? "‹  \(title)" : title
    }

    // MARK: - Selection

    private func setSelected(_ i: Int) {
        guard i >= 0, i < rows.count, selectable[i] else { return }
        selected = i
        updateSelectionHighlight()
    }

    private func updateSelectionHighlight() {
        for (i, v) in rowViews.enumerated() { (v as? ActionRowView)?.setSelected(i == selected) }
        if selected < rowViews.count { rowViews[selected].scrollToVisible(rowViews[selected].bounds) }
    }

    private func move(_ delta: Int) {
        guard !rows.isEmpty else { return }
        selected = nextSelectable(selectable, from: selected, delta: delta)
        updateSelectionHighlight()
    }

    // MARK: - Activate / navigate

    private func activate(_ i: Int) {
        guard i >= 0, i < rows.count else { return }
        switch rows[i] {
        case .action(let a): dismiss(); a.run()
        case .submenu(_, _, let sections): drillIn(sections, title: submenuTitle(at: i))
        default: break
        }
    }

    private func submenuTitle(at i: Int) -> String {
        if case .submenu(let t, _, _) = rows[i] { return t }
        return "Submenu"
    }

    private func drillIn(_ sections: [ActionSection], title: String) {
        guard sections.contains(where: { $0.entries.contains(where: { if case .action = $0 { return true }; if case .submenu = $0 { return true }; return false }) }) else { return }
        levels.append(sections)
        levelTitles.append(title)
        searchField.stringValue = ""
        applyFilter("")
    }

    private func popLevel() {
        guard levels.count > 1 else { return }
        levels.removeLast(); levelTitles.removeLast()
        searchField.stringValue = ""
        applyFilter("")
    }

    /// Esc: pop a submenu level, or dismiss at the root.
    private func back() {
        if levels.count > 1 { popLevel() } else { dismiss() }
    }

    // MARK: - NSTextFieldDelegate (the panel's own search field)

    func controlTextDidChange(_ obj: Notification) { applyFilter(searchField.stringValue) }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch commandSelector {
        case #selector(NSResponder.moveDown(_:)): move(1); return true
        case #selector(NSResponder.moveUp(_:)): move(-1); return true
        case #selector(NSResponder.moveRight(_:)):
            if selected < rows.count, case .submenu = rows[selected] { activate(selected); return true }
            return false // let the caret move within the search text
        case #selector(NSResponder.moveLeft(_:)):
            if levels.count > 1 { popLevel(); return true }
            return false
        case #selector(NSResponder.insertNewline(_:)): activate(selected); return true
        case #selector(NSResponder.cancelOperation(_:)): back(); return true
        default: return false
        }
    }

    /// Map common action titles to an SF Symbol when the action didn't supply one.
    static func inferIcon(_ a: PaletteAction) -> String {
        if let i = a.icon { return i }
        let t = a.title.lowercased()
        if t.hasPrefix("paste") { return "doc.on.clipboard" }
        if t.hasPrefix("copy") { return "doc.on.doc" }
        if t.hasPrefix("open") { return "arrow.up.forward.app" }
        if t.contains("ai") { return "sparkles" }
        return "return"
    }
}

/// One action row: icon + title (left), and either shortcut keycaps or a submenu chevron (right),
/// with a rounded selection highlight.
final class ActionRowView: NSView {
    var onClick: (() -> Void)?
    var onHover: (() -> Void)?
    private let highlight = NSView()
    private var tracking: NSTrackingArea?

    init(title: String, shortcut: String?, icon: String, isSubmenu: Bool, height: CGFloat) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true

        highlight.wantsLayer = true
        highlight.layer?.cornerRadius = 6
        highlight.layer?.backgroundColor = NSColor.selectedContentBackgroundColor.withAlphaComponent(0.85).cgColor
        highlight.isHidden = true
        highlight.translatesAutoresizingMaskIntoConstraints = false
        addSubview(highlight)

        let iconView = NSImageView()
        iconView.image = NSImage(systemSymbolName: icon, accessibilityDescription: nil)
        iconView.contentTintColor = .secondaryLabelColor
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textColor = .labelColor
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Right side: a submenu chevron, or the shortcut keycaps.
        let trailing: NSView
        if isSubmenu {
            let chev = NSImageView(image: NSImage(systemSymbolName: "chevron.right", accessibilityDescription: nil) ?? NSImage())
            chev.contentTintColor = .tertiaryLabelColor
            chev.translatesAutoresizingMaskIntoConstraints = false
            chev.setContentHuggingPriority(.required, for: .horizontal)
            trailing = chev
        } else {
            let chips = shortcut.map { Keycap.chips(for: $0, fontSize: 10) } ?? []
            let caps = NSStackView(views: chips)
            caps.spacing = 3
            caps.setHuggingPriority(.required, for: .horizontal)
            caps.translatesAutoresizingMaskIntoConstraints = false
            trailing = caps
        }

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(trailing)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: height),
            highlight.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            highlight.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            highlight.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            highlight.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailing.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
            trailing.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            trailing.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setSelected(_ s: Bool) { highlight.isHidden = !s }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let tracking { removeTrackingArea(tracking) }
        let t = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self)
        addTrackingArea(t)
        tracking = t
    }

    private static var lastMouseLocation: NSPoint = .zero
    override func mouseEntered(with event: NSEvent) {
        let loc = NSEvent.mouseLocation
        if loc != ActionRowView.lastMouseLocation { ActionRowView.lastMouseLocation = loc; onHover?() }
    }
    override func mouseMoved(with event: NSEvent) { ActionRowView.lastMouseLocation = NSEvent.mouseLocation; onHover?() }
    override func mouseUp(with event: NSEvent) { onClick?() }
}
```

- [ ] **Step 3: Build**

Run: `swift build --package-path apps/macos 2>&1 | tail -5`
Expected: `Build complete!` (the Task 2 forward-dependency error is now resolved). If SourceKit shows stale "cannot find …" errors but the build succeeds, trust the build.

- [ ] **Step 4: Verify in-app (no regression on flat panels)** — full build + relaunch:

```bash
bash scripts/build-app.sh 2>&1 | tail -3
kill "$(pgrep -f 'MacOS/invoke')" 2>/dev/null; sleep 1
nohup apps/macos/.build/Invoke.app/Contents/MacOS/invoke > /tmp/invoke-run.log 2>&1 &
sleep 3; tail -5 /tmp/invoke-run.log
```
Expected: clean startup. Manual: open ⌘K on a built-in result (e.g. a clipboard item or command) — it still lists actions as before (now one untitled section), arrows + Return + Esc work.

- [ ] **Step 5: Commit**

```bash
git add apps/macos/Sources/InvokeShell/ActionPanel.swift apps/macos/Sources/InvokeShell/PaletteWindow.swift apps/macos/Sources/InvokeShell/AppController.swift
git commit -m "ActionPanel: render Sections (separators + titles) + drill-in Submenus (level stack); skip-header nav"
git push origin main
```

---

### Task 4: Fixture + in-app verification

**Files:**
- Modify: `examples/accessory-demo/src/index.tsx` (add an `<ActionPanel>` with sections + a submenu to one item)

**Interfaces:**
- Consumes: the full pipeline from Tasks 1-3.

- [ ] **Step 1: Add an ActionPanel to the fixture** — replace the imports line and the first `<List.Item>` in `examples/accessory-demo/src/index.tsx`.

Imports:
```tsx
import { List, Color, Icon, ActionPanel, Action, showToast, Toast } from "@raycast/api";
```
First item (replace the `Colored tag` item line):
```tsx
      <List.Item
        title="Colored tag"
        accessories={[{ tag: { value: "Error", color: Color.Red } }]}
        actions={
          <ActionPanel>
            <ActionPanel.Section title="Primary">
              <Action title="Open" icon={Icon.ArrowRight} onAction={() => showToast({ style: Toast.Style.Success, title: "Open" })} />
              <Action title="Copy URL" icon={Icon.Clipboard} onAction={() => showToast({ style: Toast.Style.Success, title: "Copied" })} />
            </ActionPanel.Section>
            <ActionPanel.Section title="Danger">
              <Action title="Delete" icon={Icon.Trash} onAction={() => showToast({ style: Toast.Style.Failure, title: "Deleted" })} />
            </ActionPanel.Section>
            <ActionPanel.Submenu title="Open In" icon={Icon.Globe}>
              <Action title="Safari" onAction={() => showToast({ title: "Safari" })} />
              <Action title="Chrome" onAction={() => showToast({ title: "Chrome" })} />
            </ActionPanel.Submenu>
          </ActionPanel>
        }
      />
```

- [ ] **Step 2: Build + relaunch**

```bash
bash scripts/build-app.sh 2>&1 | tail -3
kill "$(pgrep -f 'MacOS/invoke')" 2>/dev/null; sleep 1
nohup apps/macos/.build/Invoke.app/Contents/MacOS/invoke > /tmp/invoke-run.log 2>&1 &
sleep 3; tail -5 /tmp/invoke-run.log
```
Expected: clean startup, no `accessory-demo` error.

- [ ] **Step 3: Manual verification** (in the running app)

Summon Invoke → run "Accessory Demo" → select the "Colored tag" row → press ⌘K. Verify:
- Two groups with small-caps headers "PRIMARY" and "DANGER", a separator between them.
- An "Open In" row with a trailing "›".
- ↑/↓ skip the headers; "Open" shows ↵, "Copy URL" shows ⌘↵.
- Return/→ on "Open In" drills in (header shows "‹ Open In", lists Safari/Chrome); Esc/← returns to the parent; Esc again dismisses.
- Running an action shows its toast and closes the panel.

- [ ] **Step 4: Commit**

```bash
git add examples/accessory-demo/src/index.tsx
git commit -m "examples/accessory-demo: ActionPanel with two sections + a drill-in submenu (Chunk B fixture)"
git push origin main
```

---

## Notes for the implementer

- `Keycap.chips(for:fontSize:)` already exists (used by the original `ActionRowView`) — reuse it; do not reimplement keycaps.
- The view scaffolding in `ActionPanel.buildViews()` is unchanged from the original; only the data model, `present`, rendering/selection, keyboard, and `ActionRowView`'s init change.
- Do not touch `currentActions()` or the bottom action bar — they stay flat by design.
- `node` in `currentActionSections()` is the same selected-node reference `currentActions()` uses in its extension fallthrough; use that identical reference.
