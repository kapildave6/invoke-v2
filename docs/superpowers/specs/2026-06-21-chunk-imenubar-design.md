# Chunk I-menubar — MenuBarExtra.Item alternate / shortcut / click event Design

**Part of the autonomous Raycast-parity push** (`[[autonomous-parity-goal]]`, P2 breadth tail). Closes `RAYCASTVSINVOKE.md` §12 P2: "`MenuBarExtra.Item` `alternate`/`shortcut` + click `ActionEvent`".

## Global constraints
- World-class UX; faithful parity; no fabricated brands. Commit on `main`; relaunch after build.
- No Xcode/XCTest → Swift via `swift build --package-path apps/macos` + menu-bar fixture/relaunch/log; TS via tsc.

## Current
`MenuBarController.makeItem` (`MenuBarController.swift:146`) builds an `NSMenuItem` from a `menubar-item` node: title, onAction (→ `host.invoke`), subtitle. `shortcut`, `alternate`, and a click-event arg to `onAction` are ignored. `MenuBarExtra.Item = host(T.MenuBarItem)` (`packages/api/src/index.ts:386`) — the `alternate` element prop is dropped (not lifted to a child).

## Item 1 — `shortcut`
Read `node.props["shortcut"]` (`{modifiers, key}`); set `item.keyEquivalent = key.lowercased()` and `item.keyEquivalentModifierMask` from the modifiers (cmd→`.command`, shift→`.shift`, opt→`.option`, ctrl→`.control`). Reuse the existing `Keyboard.normalize` (from Chunk E) to canonicalize the modifier list, then map to `NSEvent.ModifierFlags`. (Named keys like "return"/"delete" → the corresponding key-equivalent char; for the common single-letter case, the char is the key.)

## Item 2 — `alternate`
Raycast `MenuBarExtra.Item` `alternate` is another `MenuBarExtra.Item` shown when the user holds Option. 
- **api:** change `MenuBarExtra.Item = host(T.MenuBarItem, ["alternate"])` so the `alternate` element prop is lifted into a child node (a nested `menubar-item`) instead of being dropped by serialization.
- **host:** in `makeItem`/`appendChildren`, after adding the primary item, if the node has an `alternate` child (a `menubar-item` lifted under it), build that as a second `NSMenuItem` with `isAlternate = true` and `keyEquivalentModifierMask = [.option]` (and an empty keyEquivalent so it pairs with the primary). AppKit shows the alternate in place of the primary while Option is held. (The alternate's own onAction wires the same way.)

## Item 3 — click `ActionEvent`
Raycast `MenuBarExtra.Item` `onAction?: (event: MenuBarExtra.ActionEvent) => void` receives `{ type: "left-click" | "right-click" }`. 
- **host:** when invoking the item's onAction, pass an event arg `[.object(["type": .string("left-click")])]` (NSMenu items fire on left-click; right-click isn't distinguished by NSMenuItem, so "left-click" is the honest value). 
- **api:** add a `MenuBarExtra.ActionEvent` exported type `{ type: "left-click" | "right-click" }` (named-type export). The handler already receives args via the invoke channel.

## Item 4 — Fixture + verify
- `examples/menubar-demo/` (manifest mirrors `examples/empty-action-demo` but `mode: "menu-bar"`): a `MenuBarExtra` with an `Item` that has a `shortcut={{modifiers:["cmd"],key:"r"}}`, an `Item` with an `alternate={<MenuBarExtra.Item title="Alt action" onAction={…}/>}`, and an `Item` whose `onAction={(e) => showHUD(e.type)}` (proves the event arg).
- Verify: typecheck clean; `scripts/build-app.sh`; relaunch; `/tmp/invoke-run.log` shows the menu-bar command registered (NSStatusItem), no load error. Human visual: the menu shows the shortcut; holding Option swaps to the alternate; clicking fires with the event.

## Testing strategy
- **Pure (`swift`):** the modifier-list → `NSEvent.ModifierFlags` mapping (if extracted) — or rely on build + fixture.
- **AppKit:** shortcut keyEquivalent, isAlternate swap, event arg → via build + menu-bar fixture + relaunch + human visual.

## Out of scope
- Right-click distinction (NSMenuItem can't); "right-click" type is exported but always reports "left-click".
- `MenuBarExtra.Item` `icon` per-item tint beyond what already renders.
