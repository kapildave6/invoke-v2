# Chunk I-menubar — MenuBarExtra.Item alternate/shortcut/event Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development.

**Goal:** `MenuBarExtra.Item` honors `shortcut` (key equivalent), `alternate` (Option-key item), and passes a click `ActionEvent` to `onAction`.

**Architecture:** api lifts the `alternate` element prop + exports `ActionEvent`; the host (`MenuBarController`) sets the key equivalent, renders the alternate `NSMenuItem` (`isAlternate`), and passes the event arg.

**Tech Stack:** Swift/AppKit (`apps/macos`), TS (`packages/api`), menu-bar TS fixture.

## Global Constraints
- Faithful parity; commit on `main`; relaunch after build.
- No Xcode/XCTest: `swift build --package-path apps/macos` + menu-bar fixture/relaunch/log; `npx tsc --noEmit`.
- Ignore SourceKit false-positives. `Keyboard` (Chunk E, InvokeShell) is reusable here.

---

### Task 1: api — lift `alternate` + export `ActionEvent`

**Files:** Modify `packages/api/src/index.ts` (`MenuBarExtra.Item` ~386).

- [ ] **Step 1: Lift `alternate`.** Change `MenuBarExtra.Item = host(T.MenuBarItem);` to `MenuBarExtra.Item = host(T.MenuBarItem, ["alternate"]);` so the `alternate` element prop is serialized as a child node (instead of being dropped). (Read how `host(type, liftProps)` lifts — confirm `["alternate"]` renders the alternate element as a child of the `menubar-item` node, the way `["actions"]` works for List.EmptyView.)

- [ ] **Step 2: Export `ActionEvent`.** Add an exported type + attach to the `MenuBarExtra` namespace (mirror how other `MenuBarExtra.*`/`Form.Values` are typed):
```ts
export type MenuBarExtraActionEvent = { type: "left-click" | "right-click" };
```
and make `MenuBarExtra.ActionEvent` resolve as that type (via the `export declare namespace`/value-merge idiom used for `Form.Values`/`Keyboard.KeyModifier` — read that and mirror it). Type `MenuBarExtra.Item`'s `onAction?: (event: MenuBarExtraActionEvent) => void` if the props type is declared.

- [ ] **Step 3: typecheck.** `cd packages/api && npx tsc --noEmit | tail -5` → clean.

- [ ] **Step 4: Commit.**
```bash
git add packages/api/src/index.ts
git commit -m "feat(menubar): lift MenuBarExtra.Item alternate + export ActionEvent type"
```

---

### Task 2: host — shortcut + alternate + click event

**Files:** Modify `apps/macos/Sources/InvokeShell/MenuBarController.swift` (`makeItem` ~146; `appendChildren` menubar-item case ~121).

- [ ] **Step 1: Helper — modifiers → NSEvent.ModifierFlags.** Add to `MenuBarController`:
```swift
    private func modifierFlags(_ raw: JSONValue?) -> NSEvent.ModifierFlags {
        guard case .array(let arr)? = raw else { return [] }
        let mods = Keyboard.normalize(arr.compactMap { $0.stringValue })
        var f: NSEvent.ModifierFlags = []
        if mods.contains("cmd") { f.insert(.command) }
        if mods.contains("shift") { f.insert(.shift) }
        if mods.contains("opt") { f.insert(.option) }
        if mods.contains("ctrl") { f.insert(.control) }
        return f
    }
```

- [ ] **Step 2: shortcut + click event in `makeItem`.** In `makeItem` (~146), after building the action item (the `if let handler` branch), set the key equivalent from `shortcut`, and pass the event arg to the handler. Replace the `MenuItemAction(...) { host?.invoke(handler:) }` so it invokes with an event arg:
```swift
        if let handler = node.props["onAction"]?.handlerRef {
            let action = MenuItemAction(title: title) { [weak host = entry.host] in
                host?.invoke(handler: handler, args: [.object(["type": .string("left-click")])])
            }
            if case .object(let sc)? = node.props["shortcut"], let key = sc["key"]?.stringValue, !key.isEmpty {
                action.menuItem.keyEquivalent = key.lowercased()
                action.menuItem.keyEquivalentModifierMask = modifierFlags(sc["modifiers"])
            }
            if let sub = node.props["subtitle"]?.stringValue, !sub.isEmpty { action.menuItem.title = "\(title)  —  \(sub)" }
            entry.actions.append(action)
            return action.menuItem
        }
```
(Confirm `MenuItemAction`'s block + `host.invoke(handler:args:)` signature; the existing call used no args — add the args param.)

- [ ] **Step 3: alternate rendering in `appendChildren`.** In the `case "menubar-item":` of `appendChildren` (~121-122), after `menu.addItem(makeItem(child, entry: entry))`, render a lifted alternate child as an `isAlternate` item:
```swift
            case "menubar-item":
                menu.addItem(makeItem(child, entry: entry))
                if let alt = child.children.first(where: { $0.type == "menubar-item" }) {
                    let altItem = makeItem(alt, entry: entry)
                    altItem.isAlternate = true
                    altItem.keyEquivalentModifierMask = [.option]
                    menu.addItem(altItem)
                }
```
(The alternate's own onAction/shortcut flow through `makeItem`. `isAlternate` + `.option` mask makes AppKit show it only while Option is held, replacing the primary.)

- [ ] **Step 4: Build.** `swift build --package-path apps/macos 2>&1 | tail -10` → `Build complete!`.

- [ ] **Step 5: Commit.**
```bash
git add apps/macos/Sources/InvokeShell/MenuBarController.swift
git commit -m "feat(menubar): MenuBarExtra.Item shortcut (key equiv) + alternate (Option item) + click ActionEvent"
```

---

### Task 3: Fixture (`menubar-demo`) + verify

**Files:** Create `examples/menubar-demo/package.json`, `examples/menubar-demo/src/menubar.tsx` (filename = command `menubar`).

- [ ] **Step 1: Read `examples/empty-action-demo/package.json`** + find an existing `mode: "menu-bar"` manifest if any (e.g. search `examples/` for `"mode": "menu-bar"`) to mirror the menu-bar command shape.
- [ ] **Step 2: `package.json`** — one command `menubar` with `"mode": "menu-bar"` (NOT "view").
- [ ] **Step 3: `src/menubar.tsx`:**
```tsx
import { MenuBarExtra, showHUD, Clipboard } from "@raycast/api";

export default function Menubar() {
  return (
    <MenuBarExtra icon="⌘" title="Demo">
      <MenuBarExtra.Item title="Reload" shortcut={{ modifiers: ["cmd"], key: "r" }} onAction={() => showHUD("Reloaded")} />
      <MenuBarExtra.Item
        title="Copy ID"
        onAction={() => Clipboard.copy("id-123")}
        alternate={<MenuBarExtra.Item title="Copy ID (raw)" onAction={() => Clipboard.copy("123")} />}
      />
      <MenuBarExtra.Item title="Show event type" onAction={(e) => showHUD(`clicked: ${e.type}`)} />
    </MenuBarExtra>
  );
}
```
(Confirm `MenuBarExtra.Item` accepts `shortcut`/`alternate` + `onAction(e)` with `e.type` typechecks against the shim after Task 1.)

- [ ] **Step 4: Typecheck** per the examples' norm.
- [ ] **Step 5: Build + relaunch + log.** `scripts/build-app.sh 2>&1 | tail -5`; relaunch; `tail -40 /tmp/invoke-run.log` → the menu-bar command registers (NSStatusItem), no load error.
- [ ] **Step 6: Human visual checklist (record):** the menu shows "Reload  ⌘R"; holding Option swaps "Copy ID" → "Copy ID (raw)"; clicking "Show event type" shows a HUD "clicked: left-click".
- [ ] **Step 7: Commit.**
```bash
git add examples/menubar-demo
git commit -m "test(fixture): menubar-demo exercises MenuBarExtra.Item shortcut/alternate/event"
```

---

## Self-Review

**1. Spec coverage:** shortcut+event → Task 2; alternate lift → Task 1 + render Task 2; ActionEvent type → Task 1; fixture → Task 3. ✅

**2. Placeholder scan:** Concrete code for the helper, makeItem changes, alternate rendering, api lift, fixture. `NOTE`s (host(type, lift) mechanics, MenuItemAction block signature, namespace idiom) are read-the-code checks.

**3. Consistency:** `modifierFlags` (Task 2) used in makeItem; `host(T.MenuBarItem, ["alternate"])` (Task 1) produces the alternate child consumed in Task 2 Step 3; `ActionEvent` type (Task 1) used in the fixture (Task 3); `host.invoke(handler:args:)` arg added in Task 2.

**Known risk (final-review triage):** (a) the lifted `alternate` becomes a child `menubar-item`; confirm `appendChildren`'s `menubar-item` case is where lifted children land (not double-rendered as a normal child elsewhere). (b) NSMenuItem `isAlternate` requires the alternate to immediately follow the primary with the SAME keyEquivalent (empty here) + a superset modifier mask — verify the pairing shows/hides correctly. (c) `keyEquivalentModifierMask` for the primary shortcut must not collide with the `.option` alternate.
