# Chunk E — P0 Correctness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Close the three remaining P0 parity items — render `List/Grid.EmptyView`, fire `Checkbox` `onChange` as a real boolean, and honor `Action.style` (destructive red) + custom `Action.shortcut` (display + functional binding).

**Architecture:** All renderer work is in the AppKit host. EmptyView + Checkbox land in `PaletteView.swift`; shortcut glyph/matching logic in a new AppKit-only `Keyboard.swift`; `Action.style`/`shortcut` flow through `PaletteAction` → `paletteAction(for:)`/`extensionActions` (AppController) → `ActionRowView` (display) and `PaletteWindow.keyMonitor` (functional). A fixture (`examples/empty-action-demo`) exercises every path.

**Tech Stack:** Swift 6 / AppKit (SwiftPM `apps/macos`), TypeScript fixture importing `@raycast/api`.

## Global Constraints
- World-class Raycast-quality UX; never ship system-default/janky UI.
- Faithful Raycast parity; do NOT fabricate third-party brands. Fixture imports `@raycast/api`.
- Commit directly on `main` (no feature branches). Relaunch `Invoke.app` after build+install.
- No Xcode/XCTest in this env. Pure logic verified via standalone `swift` scripts; AppKit verified via `swift build --package-path apps/macos` + `scripts/build-app.sh` + relaunch + `/tmp/invoke-run.log`.
- Build command: `swift build --package-path apps/macos` (cwd resets between calls — always use `--package-path`).
- Ignore SourceKit "Cannot find X in scope" / "let binding pattern" false positives when `swift build` succeeds.

---

### Task 1: Render `List.EmptyView` / `Grid.EmptyView`

**Files:**
- Modify: `apps/macos/Sources/InvokePalette/PaletteView.swift` (render reset ~300-314; `renderGrid` ~1031-1057; `renderListVirtualized` ~1982-2012; add members + helpers)

**Interfaces:**
- Consumes: existing `imageSource(_:)`, `loadLocalImage(_:)`, `loadRemoteImage(_:into:)`, `fileIconPath(_:)`, `sfSymbol(for:)`; `ViewNode.type/props/children`; `JSONValue.stringValue`.
- Produces: `firstEmptyView(in:)`, `showEmptyState(_:)`, `emptyStateIcon(_:)`, `emptyStateView` member — used only within `PaletteView`.

- [ ] **Step 1: Add the `emptyStateView` member.** In `PaletteView.swift`, near the other surface members (around line 41, after `private let listScroll = NSScrollView()`), add:

```swift
    /// Centered empty-state view for List/Grid.EmptyView (icon + title + description). Shown in place of
    /// the table/collection when the surface has zero items AND the tree carries an `empty-view` node.
    private var emptyStateView: NSView?
```

- [ ] **Step 2: Tear down the empty state on every render.** In `render(...)`, in the reset block (right after `listScroll.isHidden = true; listData = []`, ~line 310), add:

```swift
        emptyStateView?.removeFromSuperview(); emptyStateView = nil
```

- [ ] **Step 3: Add the DFS finder + builders.** Add these methods to `PaletteView` (place them just above `renderListVirtualized`, ~line 1978):

```swift
    /// Depth-first search for the first `empty-view` node (List.EmptyView / Grid.EmptyView).
    private func firstEmptyView(in node: ViewNode) -> ViewNode? {
        if node.type == "empty-view" { return node }
        for c in node.children { if let e = firstEmptyView(in: c) { return e } }
        return nil
    }

    /// A 48pt icon view for the empty state, resolving the same Image.ImageLike sources as grid cells
    /// (asset/base64, fileIcon, local/remote URL, or an SF Symbol name). May fill asynchronously for a
    /// remote URL.
    private func emptyStateIcon(_ v: JSONValue?) -> NSImageView {
        let iv = NSImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentTintColor = .tertiaryLabelColor
        iv.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        if let p = fileIconPath(v) {
            iv.image = NSWorkspace.shared.icon(forFile: p)
        } else if let src = imageSource(v) {
            if let local = loadLocalImage(src) { iv.image = local }
            else if src.hasPrefix("http://") || src.hasPrefix("https://") { loadRemoteImage(src, into: iv) }
            else { iv.image = NSImage(systemSymbolName: src, accessibilityDescription: nil)
                ?? NSImage(systemSymbolName: sfSymbol(for: src), accessibilityDescription: nil) }
        }
        NSLayoutConstraint.activate([
            iv.widthAnchor.constraint(equalToConstant: 48),
            iv.heightAnchor.constraint(equalToConstant: 48),
        ])
        return iv
    }

    /// Show a centered empty state for the given `empty-view` node, hiding the list/grid/stack surfaces.
    private func showEmptyState(_ node: ViewNode) {
        listScroll.isHidden = true; gridScroll.isHidden = true; scrollView.isHidden = true
        let container = NSView(); container.translatesAutoresizingMaskIntoConstraints = false
        let col = NSStackView(); col.orientation = .vertical; col.alignment = .centerX; col.spacing = 8
        col.translatesAutoresizingMaskIntoConstraints = false
        if node.props["icon"] != nil { col.addArrangedSubview(emptyStateIcon(node.props["icon"])) }
        if let t = node.props["title"]?.stringValue, !t.isEmpty {
            let lbl = NSTextField(labelWithString: t)
            lbl.font = .systemFont(ofSize: 15, weight: .semibold); lbl.textColor = .labelColor; lbl.alignment = .center
            col.addArrangedSubview(lbl)
        }
        if let d = node.props["description"]?.stringValue, !d.isEmpty {
            let lbl = NSTextField(wrappingLabelWithString: d)
            lbl.font = .systemFont(ofSize: 13); lbl.textColor = .secondaryLabelColor; lbl.alignment = .center
            lbl.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            col.addArrangedSubview(lbl)
            lbl.widthAnchor.constraint(lessThanOrEqualToConstant: 320).isActive = true
        }
        container.addSubview(col)
        addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            col.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            col.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            col.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 24),
            col.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -24),
        ])
        emptyStateView = container
    }
```

- [ ] **Step 4: Hook the List path.** In `renderListVirtualized(_:selectedIndex:)`, immediately after `walk(root)` and `listData = entries; itemCounter = itemIdx` (~line 2004), insert BEFORE the `listSelected = ...` line:

```swift
        if itemIdx == 0, let ev = firstEmptyView(in: root) {
            showEmptyState(ev)
            return
        }
```

- [ ] **Step 5: Hook the Grid path.** In `renderGrid(_:selectedIndex:)`, immediately after `collect(grid)` and `gridData = items` (~line 1039), insert:

```swift
        if items.isEmpty, let ev = firstEmptyView(in: grid) {
            showEmptyState(ev)
            return
        }
```

- [ ] **Step 6: Build.** Run: `swift build --package-path apps/macos 2>&1 | tail -20`
Expected: `Compiling`/`Build complete!` with no errors (SourceKit-only "cannot find in scope" warnings in editor are not build errors).

- [ ] **Step 7: Commit.**

```bash
git add apps/macos/Sources/InvokePalette/PaletteView.swift
git commit -m "feat(empty-view): render List/Grid.EmptyView centered empty state"
```

---

### Task 2: Fire `Checkbox` `onChange` as a real boolean

**Files:**
- Modify: `apps/macos/Sources/InvokePalette/PaletteView.swift` (`form-checkbox` case ~1650-1659; add member + `@objc` selector)
- Modify: `apps/macos/Sources/InvokeShell/AppController.swift` (wire the typed channel ~line 212)

**Interfaces:**
- Consumes: `JSONValue.handlerRef` (as used by `form-dropdown` at line 1692), `JSONValue.bool` case, `extHost?.invoke(handler:args:)`.
- Produces: `PaletteView.onFormCheckboxChange: ((String, Bool) -> Void)?` — consumed by AppController.

- [ ] **Step 1: Add the typed channel + associated-object key.** In `PaletteView.swift`, near `public var onFormFieldChange: ((String, String) -> Void)?` (line 1284), add:

```swift
    /// Checkbox delivers a real Bool (a "false" string is truthy in JS — would break onChange={(c)=>…}).
    public var onFormCheckboxChange: ((String, Bool) -> Void)?
    private static var checkboxHandlerKey: UInt8 = 0
```

- [ ] **Step 2: Wire the checkbox in the `form-checkbox` case.** In the `case "form-checkbox":` block (~line 1650), AFTER the existing `formApply[id] = { ... }` closure and BEFORE `control = cb`, add:

```swift
            if let h = f.props["onChange"]?.handlerRef {
                objc_setAssociatedObject(cb, &Self.checkboxHandlerKey, h, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                cb.target = self
                cb.action = #selector(formCheckboxChanged(_:))
            }
```

- [ ] **Step 3: Add the selector.** Add this method to `PaletteView` (near `formDatePickerChanged`, ~line 78, or anywhere in the class):

```swift
    @objc private func formCheckboxChanged(_ sender: NSButton) {
        guard let h = objc_getAssociatedObject(sender, &Self.checkboxHandlerKey) as? String else { return }
        onFormCheckboxChange?(h, sender.state == .on)
    }
```

- [ ] **Step 4: Wire AppController to invoke with a Bool.** In `AppController.swift`, right after the `palette.onFormFieldChange = { ... }` line (line 212), add:

```swift
        palette.onFormCheckboxChange = { [weak self] handler, on in self?.extHost?.invoke(handler: handler, args: [.bool(on)]) }
```

- [ ] **Step 5: Build.** Run: `swift build --package-path apps/macos 2>&1 | tail -20`
Expected: `Build complete!`. (If `objc_setAssociatedObject` is "cannot find", add `import ObjectiveC` at the top of `PaletteView.swift` — but with AppKit imported it is normally available.)

- [ ] **Step 6: Commit.**

```bash
git add apps/macos/Sources/InvokePalette/PaletteView.swift apps/macos/Sources/InvokeShell/AppController.swift
git commit -m "feat(form): fire Checkbox onChange as a real boolean"
```

---

### Task 3: `Action.style` (destructive) + `Action.shortcut` display

**Files:**
- Create: `apps/macos/Sources/InvokeShell/Keyboard.swift`
- Create (test): `/private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad/keyboard-test.swift`
- Modify: `apps/macos/Sources/InvokeShell/PaletteAction.swift`
- Modify: `apps/macos/Sources/InvokeShell/AppController.swift` (`paletteAction(for:)` ~3731; `extensionActions` ~3722)
- Modify: `apps/macos/Sources/InvokeShell/ActionPanel.swift` (`ActionRowView.init` ~358; `rebuildRows` line 228)

**Interfaces:**
- Consumes: `ViewNode.props`, `JSONValue` cases `.object`/`.array`/`.string` + `.stringValue`.
- Produces:
  - `Keyboard.normalize(_ modifiers: [String]) -> Set<String>` (canonical `cmd`/`shift`/`opt`/`ctrl`)
  - `Keyboard.keyGlyph(_ key: String) -> String`
  - `Keyboard.glyphs(modifiers: [String], key: String) -> String`
  - `PaletteAction.isDestructive: Bool`, `.shortcutModifiers: [String]?`, `.shortcutKey: String?` (parsed shortcut — consumed by Task 4)

- [ ] **Step 1: Write the failing standalone test for `Keyboard`.** Create `scratchpad/keyboard-test.swift` (paste the `Keyboard` enum body from Step 3 above its asserts when running, OR `cat` the source in — see Step 4 command):

```swift
import Foundation

func eq(_ a: String, _ b: String, _ label: String) {
    if a == b { print("ok: \(label)") } else { print("FAIL: \(label) — got \(a), want \(b)"); exit(1) }
}
func eqSet(_ a: Set<String>, _ b: Set<String>, _ label: String) {
    if a == b { print("ok: \(label)") } else { print("FAIL: \(label) — got \(a), want \(b)"); exit(1) }
}

eq(Keyboard.glyphs(modifiers: ["cmd","shift"], key: "k"), "⇧⌘K", "cmd+shift+k")
eq(Keyboard.glyphs(modifiers: ["cmd"], key: "r"), "⌘R", "cmd+r")
eq(Keyboard.glyphs(modifiers: ["ctrl","opt"], key: "delete"), "⌃⌥⌫", "ctrl+opt+delete")
eq(Keyboard.glyphs(modifiers: ["cmd"], key: "arrowUp"), "⌘↑", "cmd+arrowup")
eqSet(Keyboard.normalize(["command","option","alt"]), ["cmd","opt"], "alias normalize")
eq(Keyboard.keyGlyph("enter"), "↵", "enter glyph")
print("ALL PASS")
```

- [ ] **Step 2: Run it to verify it fails.** Run: `cd apps/macos/Sources/InvokeShell && swift /private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad/keyboard-test.swift`
Expected: FAIL — `error: cannot find 'Keyboard' in scope` (the type does not exist yet).

- [ ] **Step 3: Create `Keyboard.swift`.**

```swift
import AppKit

/// Pure keyboard-shortcut mappings for Raycast's `Keyboard.Shortcut` ({ modifiers, key }). AppKit/
/// Foundation only (no project types) so it compiles in a standalone `swift` script for unit testing.
/// Used to render a shortcut as glyph chips (via Keycap.chips) and to match a pressed combo against a
/// bound action shortcut (PaletteWindow.keyMonitor).
enum Keyboard {
    /// Normalize a Raycast modifier list to our canonical lowercase vocabulary: cmd / shift / opt / ctrl.
    static func normalize(_ modifiers: [String]) -> Set<String> {
        var out = Set<String>()
        for m in modifiers {
            switch m.lowercased() {
            case "cmd", "command": out.insert("cmd")
            case "shift": out.insert("shift")
            case "opt", "option", "alt": out.insert("opt")
            case "ctrl", "control": out.insert("ctrl")
            default: break
            }
        }
        return out
    }

    /// One key token → its display glyph (named keys) or upper-cased character(s).
    static func keyGlyph(_ key: String) -> String {
        switch key.lowercased() {
        case "enter", "return": return "↵"
        case "delete", "backspace": return "⌫"
        case "deleteforward": return "⌦"
        case "arrowup": return "↑"
        case "arrowdown": return "↓"
        case "arrowleft": return "←"
        case "arrowright": return "→"
        case "escape", "esc": return "⎋"
        case "tab": return "⇥"
        case "space": return "␣"
        case "pageup": return "⇞"
        case "pagedown": return "⇟"
        case "home": return "↖"
        case "end": return "↘"
        default: return key.uppercased()
        }
    }

    /// Render modifiers + key as a contiguous glyph string in Raycast's render order (⌃⌥⇧⌘ then key),
    /// e.g. ["cmd","shift"]+"k" → "⇧⌘K". Keycap.chips(for:) splits this into one chip per glyph.
    static func glyphs(modifiers: [String], key: String) -> String {
        let m = normalize(modifiers)
        var s = ""
        if m.contains("ctrl") { s += "⌃" }
        if m.contains("opt") { s += "⌥" }
        if m.contains("shift") { s += "⇧" }
        if m.contains("cmd") { s += "⌘" }
        return s + keyGlyph(key)
    }
}
```

- [ ] **Step 4: Run the test against the real source.** Run: `cat apps/macos/Sources/InvokeShell/Keyboard.swift /private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad/keyboard-test.swift > /private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad/kb-run.swift && swift /private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad/kb-run.swift`
Expected: prints `ok:` lines then `ALL PASS`.

- [ ] **Step 5: Extend `PaletteAction`.** Replace the body of `PaletteAction.swift` struct (keep the doc comments) so it has the new fields with defaults (defaults keep the ~20 built-in call sites compiling):

```swift
public struct PaletteAction {
    public let title: String
    /// Display-only shortcut hint (e.g. "↵", "⌘↵", or a custom "⇧⌘K").
    public let shortcut: String?
    /// Optional SF Symbol name for the ⌘K Action Panel row (inferred from the title when nil).
    public let icon: String?
    /// Action.Style.Destructive → render the title red.
    public let isDestructive: Bool
    /// Parsed custom Action.shortcut for functional key-equivalent binding (nil = positional only).
    public let shortcutModifiers: [String]?
    public let shortcutKey: String?
    public let run: () -> Void

    public init(title: String, shortcut: String?, icon: String? = nil,
                isDestructive: Bool = false, shortcutModifiers: [String]? = nil, shortcutKey: String? = nil,
                run: @escaping () -> Void) {
        self.title = title
        self.shortcut = shortcut
        self.icon = icon
        self.isDestructive = isDestructive
        self.shortcutModifiers = shortcutModifiers
        self.shortcutKey = shortcutKey
        self.run = run
    }
}
```

- [ ] **Step 6: Parse `style` + `shortcut` in `paletteAction(for:)`.** Replace `paletteAction(for:shortcut:)` (AppController ~3731) with:

```swift
    /// One extension action node → a PaletteAction that runs via extHost (all variants + form submit).
    /// Reads Action.style (destructive) and a custom Action.shortcut ({ modifiers, key }) — the custom
    /// shortcut overrides the positional ↵/⌘↵ display and is bound functionally by the window keyMonitor.
    private func paletteAction(for n: ViewNode, shortcut: String? = nil) -> PaletteAction {
        let destructive = (n.props["style"]?.stringValue == "destructive")
        var display = shortcut
        var mods: [String]? = nil
        var key: String? = nil
        if case .object(let sc)? = n.props["shortcut"], let k = sc["key"]?.stringValue, !k.isEmpty {
            var ml: [String] = []
            if case .array(let arr)? = sc["modifiers"] { ml = arr.compactMap { $0.stringValue } }
            mods = Array(Keyboard.normalize(ml))
            key = k.lowercased()
            display = Keyboard.glyphs(modifiers: ml, key: k)
        }
        return PaletteAction(title: title(for: n), shortcut: display, icon: n.props["icon"]?.stringValue,
                             isDestructive: destructive, shortcutModifiers: mods, shortcutKey: key) { [weak self] in
            self?.runExtensionAction(n)
        }
    }
```

- [ ] **Step 7: Route the flat action list through `paletteAction(for:)`.** Replace `extensionActions(under:)` (AppController ~3722) so the window's `actionsProvider`/action-bar list also carries style + parsed shortcuts:

```swift
    private func extensionActions(under node: ViewNode) -> [PaletteAction] {
        actions(under: node).enumerated().map { i, n in
            paletteAction(for: n, shortcut: i == 0 ? "↵" : (i == 1 ? "⌘↵" : nil))
        }
    }
```

- [ ] **Step 8: Redden the destructive row in `ActionRowView`.** In `ActionPanel.swift`, change the `init` signature (line 358) to add a `destructive` param, and the title color line (377):

Change line 358 from:
```swift
    init(title: String, shortcut: String?, icon: String, isSubmenu: Bool, height: CGFloat) {
```
to:
```swift
    init(title: String, shortcut: String?, icon: String, isSubmenu: Bool, height: CGFloat, destructive: Bool = false) {
```
Change line 377 from:
```swift
        titleLabel.textColor = .labelColor
```
to:
```swift
        titleLabel.textColor = destructive ? .systemRed : .labelColor
```

- [ ] **Step 9: Pass `isDestructive` from `rebuildRows`.** In `ActionPanel.swift` line 228, change:
```swift
                let r = ActionRowView(title: a.title, shortcut: a.shortcut, icon: ActionPanel.inferIcon(a), isSubmenu: false, height: rowHeight)
```
to:
```swift
                let r = ActionRowView(title: a.title, shortcut: a.shortcut, icon: ActionPanel.inferIcon(a), isSubmenu: false, height: rowHeight, destructive: a.isDestructive)
```

- [ ] **Step 10: Build.** Run: `swift build --package-path apps/macos 2>&1 | tail -20`
Expected: `Build complete!`.

- [ ] **Step 11: Commit.**

```bash
git add apps/macos/Sources/InvokeShell/Keyboard.swift apps/macos/Sources/InvokeShell/PaletteAction.swift apps/macos/Sources/InvokeShell/AppController.swift apps/macos/Sources/InvokeShell/ActionPanel.swift
git commit -m "feat(actions): Action.style destructive red + custom Action.shortcut display (Keyboard glyphs)"
```

---

### Task 4: Functional `Action.shortcut` key-equivalent binding

**Files:**
- Modify: `apps/macos/Sources/InvokeShell/PaletteWindow.swift` (`keyMonitor` ~641-673)

**Interfaces:**
- Consumes: `PaletteAction.shortcutKey`/`.shortcutModifiers`/`.run` (Task 3); existing `self.actionsProvider: (() -> [PaletteAction])?` (line 49).
- Produces: nothing new; behavior only.

- [ ] **Step 1: Add the custom-shortcut match to `keyMonitor`.** In `installKeyMonitor()`, insert this block AFTER the Esc handler (the `if event.keyCode == 53 { … return nil }` block ending ~line 661) and BEFORE `guard event.modifierFlags.contains(.command) else { return event }` (line 662):

```swift
            // Custom Action.shortcut binding (Raycast Keyboard.Shortcut): match the pressed combo against
            // the current actions and run the first match. Requires a cmd/ctrl/opt modifier so plain
            // typing in the search field is never hijacked, and runs before the ⌘K toggle so an action
            // bound to ⌘⇧K wins over the bare ⌘K panel toggle.
            if event.modifierFlags.intersection([.command, .control, .option]) != [] {
                var pressed = Set<String>()
                if event.modifierFlags.contains(.command) { pressed.insert("cmd") }
                if event.modifierFlags.contains(.shift) { pressed.insert("shift") }
                if event.modifierFlags.contains(.option) { pressed.insert("opt") }
                if event.modifierFlags.contains(.control) { pressed.insert("ctrl") }
                let key = (event.charactersIgnoringModifiers ?? "").lowercased()
                if !key.isEmpty, let match = (self.actionsProvider?() ?? []).first(where: {
                    $0.shortcutKey == key && Set($0.shortcutModifiers ?? []) == pressed
                }) {
                    match.run()
                    return nil
                }
            }
```

- [ ] **Step 2: Build.** Run: `swift build --package-path apps/macos 2>&1 | tail -20`
Expected: `Build complete!`.

- [ ] **Step 3: Commit.**

```bash
git add apps/macos/Sources/InvokeShell/PaletteWindow.swift
git commit -m "feat(actions): bind custom Action.shortcut to a functional key equivalent"
```

---

### Task 5: Fixture (`empty-action-demo`) + end-to-end verify

**Files:**
- Create: `examples/empty-action-demo/package.json`
- Create: `examples/empty-action-demo/src/list-demo.tsx`
- Create: `examples/empty-action-demo/src/checkbox-demo.tsx`

**Interfaces:**
- Consumes: the rendered behavior from Tasks 1-4. Manifest mirrors `examples/tech-radar/package.json` (imports `@raycast/api`).

- [ ] **Step 1: Read the reference manifest.** Run: `cat examples/tech-radar/package.json` — mirror its `$schema`, `preferences`/`commands` shape, `dependencies` (`@raycast/api`), and scripts. Match the fields; only change `name`/`title`/`description`/`commands`.

- [ ] **Step 2: Create `package.json`.**

```json
{
  "$schema": "https://www.raycast.com/schemas/extension.json",
  "name": "empty-action-demo",
  "title": "Empty + Action Demo",
  "description": "Exercises List/Grid.EmptyView, Checkbox onChange (boolean), and Action style/shortcut.",
  "icon": "icon.png",
  "author": "invoke",
  "categories": ["Other"],
  "license": "MIT",
  "commands": [
    { "name": "list-demo", "title": "Empty + Actions Demo", "description": "EmptyView + destructive + custom shortcut", "mode": "view" },
    { "name": "checkbox-demo", "title": "Checkbox Boolean Demo", "description": "Checkbox onChange delivers a real boolean", "mode": "view" }
  ],
  "dependencies": { "@raycast/api": "^1.70.0" },
  "scripts": { "build": "ray build", "dev": "ray develop" }
}
```

- [ ] **Step 3: Create `src/list-demo.tsx`.**

```tsx
import { List, ActionPanel, Action, Icon, Toast, showToast } from "@raycast/api";
import { useState } from "react";

export default function ListDemo() {
  const [query, setQuery] = useState("");
  const all = ["Alpha", "Beta", "Gamma"];
  const items = all.filter((s) => s.toLowerCase().includes(query.toLowerCase()));
  return (
    <List onSearchTextChange={setQuery} searchBarPlaceholder="Filter (try 'zzz' for the empty state)">
      {items.length === 0 ? (
        <List.EmptyView
          icon={Icon.MagnifyingGlass}
          title="No Matches"
          description="Try a different search term"
          actions={
            <ActionPanel>
              <Action
                title="Reset Search"
                icon={Icon.ArrowCounterClockwise}
                shortcut={{ modifiers: ["cmd"], key: "r" }}
                onAction={() => showToast({ title: "Reset (⌘R from EmptyView)" })}
              />
            </ActionPanel>
          }
        />
      ) : (
        items.map((s) => (
          <List.Item
            key={s}
            title={s}
            actions={
              <ActionPanel>
                <Action title="Show Toast" onAction={() => showToast({ title: `Hello ${s}` })} />
                <Action
                  title="Custom Shortcut"
                  shortcut={{ modifiers: ["cmd", "shift"], key: "k" }}
                  onAction={() => showToast({ title: "⌘⇧K fired!" })}
                />
                <Action
                  title="Delete"
                  style={Action.Style.Destructive}
                  onAction={() => showToast({ style: Toast.Style.Failure, title: `Deleted ${s}` })}
                />
              </ActionPanel>
            }
          />
        ))
      )}
    </List>
  );
}
```

- [ ] **Step 4: Create `src/checkbox-demo.tsx`.** (A controlled checkbox: if `onChange` delivered the string `"false"` it would be truthy and always show "true" — showing "false" proves a real boolean reaches JS.)

```tsx
import { Form } from "@raycast/api";
import { useState } from "react";

export default function CheckboxDemo() {
  const [on, setOn] = useState(false);
  return (
    <Form>
      <Form.Checkbox id="feature" label="Enable feature" value={on} onChange={setOn} />
      <Form.Description
        title="Received value"
        text={on ? "boolean true ✓" : "boolean false ✓ (not a truthy string)"}
      />
    </Form>
  );
}
```

- [ ] **Step 5: Typecheck the fixture.** Run: `cd examples/empty-action-demo && npx tsc --noEmit -p . 2>&1 | tail -20` (or, if no local tsconfig, validate against the repo's `@raycast/api` types as `examples/tech-radar` does — match that example's typecheck command).
Expected: no type errors (`Action.Style.Destructive`, `Icon.MagnifyingGlass`, `Icon.ArrowCounterClockwise`, `Toast.Style.Failure` all exist in the shim).

- [ ] **Step 6: Build the app + relaunch.** Run: `scripts/build-app.sh 2>&1 | tail -5` then relaunch `Invoke.app` (per the standing relaunch-after-build authorization) and tail the log: `tail -40 /tmp/invoke-run.log`
Expected: app builds + relaunches; log shows the extension importer sees `empty-action-demo` with no load/parse error.

- [ ] **Step 7: Visual confirm checklist (record results in the report).**
  - Run "Empty + Actions Demo", type `zzz` → centered magnifying-glass icon + "No Matches" + description; ⌘K shows "Reset Search" with `⌘R` keycaps; ⌘R fires the toast.
  - Clear search → items; ⌘K shows "Delete" in **red**; "Custom Shortcut" shows `⌘⇧K` keycaps; pressing ⌘⇧K (list focused, panel closed) fires the toast.
  - Run "Checkbox Boolean Demo", toggle the checkbox → description flips between "boolean true ✓" and "boolean false ✓"; never stuck on true.

- [ ] **Step 8: Commit.**

```bash
git add examples/empty-action-demo
git commit -m "test(fixture): empty-action-demo exercises EmptyView + Checkbox bool + Action style/shortcut"
```

---

## Self-Review

**1. Spec coverage:**
- Item 1 (EmptyView render) → Task 1. ✅ (EmptyView actions in ⌘K = verify-point in Task 5 Step 7 via existing `extensionActionSections` fallback.)
- Item 2 (Checkbox onChange bool) → Task 2. ✅
- Item 3 (Action.style + shortcut display) → Task 3. ✅
- Item 4 (functional shortcut binding) → Task 4. ✅
- Item 5 (fixture + verify) → Task 5. ✅

**2. Placeholder scan:** No TBD/TODO; every code step carries full code. Fixture has complete files. ✅

**3. Type consistency:** `PaletteAction` fields `isDestructive`/`shortcutModifiers`/`shortcutKey` are defined in Task 3 Step 5 and consumed in Task 3 Step 9 (`a.isDestructive`) and Task 4 Step 1 (`$0.shortcutKey`/`$0.shortcutModifiers`). `Keyboard.normalize/glyphs/keyGlyph` defined Task 3 Step 3, used in `paletteAction(for:)` Step 6 and tested Step 1/4. `onFormCheckboxChange: ((String, Bool) -> Void)?` defined Task 2 Step 1, consumed Task 2 Step 4. ✅

**Known nuances (for the final review, not blockers):**
- An extension binding the bare `⌘K` would be matched by Task 4 before the panel toggle — acceptable (Raycast also reserves ⌘K; explicit binding honored). 
- `Keycap.chips` splits per-Character, so a multi-char key like `F1` renders as two chips — rare; minor.
- EmptyView icon for a remote URL fills asynchronously (same as grid cells).
