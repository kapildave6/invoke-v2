# Chunk I — P2 Visual Fidelity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development.

**Goal:** Broaden `Icon`/`Color` coverage, honor `Image.Mask`, and dispatch dynamic `{light,dark}` images/colors.

**Architecture:** Extract the icon→SF-Symbol mapping into a standalone-testable `IconSymbol` (mirrors `RaycastColor`), expand it + the api `Icon` enum; add `Color.Dynamic`; add an `applyImageMask` helper + light/dark source dispatch in the renderers.

**Tech Stack:** Swift/AppKit (`apps/macos`), TS (`packages/api`), TS fixture.

## Global Constraints
- World-class UX; faithful parity (canonical Raycast ids only, no invented ones); commit on `main`; relaunch after build.
- No Xcode/XCTest: `swift build --package-path apps/macos`; pure mappings via standalone `swift`; TS via `npx tsc --noEmit`.
- `IconSymbol.swift`/`RaycastColor.swift` stay AppKit-only (no project types) so they compile in a standalone `swift` test.
- Ignore SourceKit "cannot find X" false-positives when `swift build` succeeds.

---

### Task 1: `IconSymbol` extraction + expanded Icon coverage + smart fallback

**Files:**
- Create: `apps/macos/Sources/InvokePalette/IconSymbol.swift`
- Create (test): `<scratchpad>/iconsymbol-test.swift`
- Modify: `apps/macos/Sources/InvokePalette/PaletteView.swift` (`sfSymbol(for:)` ~2478 → delegate)
- Modify: `packages/api/src/index.ts` (`Icon` enum ~388)

**Interfaces:**
- Produces: `IconSymbol.sfName(for id: String) -> String` (explicit map → validated dotted-transform → "app").

- [ ] **Step 1: Write the failing standalone test.** Create `<scratchpad>/iconsymbol-test.swift` (use the absolute scratchpad path `/private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad/iconsymbol-test.swift`):
```swift
import AppKit
func eq(_ a: String, _ b: String, _ l: String) { if a == b { print("ok: \(l)") } else { print("FAIL: \(l) got \(a) want \(b)"); exit(1) } }
// explicit mappings
eq(IconSymbol.sfName(for: "magnifying-glass"), "magnifyingglass", "magnifying-glass")
eq(IconSymbol.sfName(for: "check-circle"), "checkmark.circle", "check-circle")
// dotted-transform fallback for a valid SF symbol (arrow.up exists)
eq(IconSymbol.sfName(for: "arrow-up"), "arrow.up", "arrow-up dotted")
// raw valid SF name passes through (envelope is a valid SF symbol; no explicit case needed)
let env = IconSymbol.sfName(for: "envelope"); if env != "envelope" && env != "envelope" { print("FAIL envelope") }
// unknown → generic "app"
eq(IconSymbol.sfName(for: "totally-not-a-symbol-xyz"), "app", "unknown → app")
print("ALL PASS")
```

- [ ] **Step 2: Run it to fail.** `cd apps/macos/Sources/InvokePalette && swift /private/tmp/.../scratchpad/iconsymbol-test.swift` → FAIL (`IconSymbol` not found).

- [ ] **Step 3: Create `IconSymbol.swift`.** Move the existing explicit mappings from `PaletteView.sfSymbol(for:)` here, add more, and a validated dotted-transform fallback:
```swift
import AppKit

/// Raycast `Icon` id (kebab-case) → an SF Symbol name. AppKit-only (no project types) so it compiles in
/// a standalone `swift` test. Explicit map for name-mismatches; else a dashes→dots transform IF that's a
/// real SF Symbol; else a generic "app" placeholder (never nil — so an unknown icon still shows a glyph).
enum IconSymbol {
    private static let map: [String: String] = [
        "circle": "circle.fill", "star": "star.fill", "clipboard": "doc.on.clipboard",
        "window": "macwindow", "magnifying-glass": "magnifyingglass", "app-window-grid-3x3": "square.grid.3x3",
        "code": "chevron.left.forwardslash.chevron.right", "code-block": "curlybraces", "credit-card": "creditcard",
        "crypto": "bitcoinsign.circle", "fingerprint": "touchid", "hard-drive": "internaldrive",
        "heartbeat": "waveform.path.ecg", "star-circle": "star.circle", "switch": "switch.2",
        "text": "text.alignleft", "tree": "leaf", "wallet": "wallet.pass", "wifi-disabled": "wifi.slash",
        "check-circle": "checkmark.circle", "check": "checkmark", "check-list": "checklist",
        "arrow-clockwise": "arrow.clockwise", "arrow-counter-clockwise": "arrow.counterclockwise",
        "arrow-ne": "arrow.up.right", "new-document": "doc.badge.plus", "document": "doc",
        "speaker-high": "speaker.wave.3", "speaker-low": "speaker.wave.1", "speaker-off": "speaker.slash",
        "x-mark-circle": "xmark.circle", "exclamationmark": "exclamationmark.triangle", "question-mark": "questionmark",
        "light-bulb": "lightbulb", "magnifying-glass": "magnifyingglass", "ellipsis": "ellipsis",
        "house": "house", "cog": "gearshape", "gear": "gearshape", "trophy": "trophy", "rocket": "paperplane",
        "warning": "exclamationmark.triangle", "info": "info.circle", "bug": "ant", "wand": "wand.and.stars",
        // (add more name-mismatches as needed; raw-valid names like envelope/gear/wifi/bell/lock/tag/heart
        //  pass through the transform/identity below.)
    ]
    static func sfName(for id: String) -> String {
        if let m = map[id] { return m }
        let dotted = id.replacingOccurrences(of: "-", with: ".")
        if NSImage(systemSymbolName: dotted, accessibilityDescription: nil) != nil { return dotted }
        if NSImage(systemSymbolName: id, accessibilityDescription: nil) != nil { return id }
        return "app"
    }
}
```

- [ ] **Step 4: Delegate `PaletteView.sfSymbol(for:)`.** Replace its body (`:2478-2514`) with `return IconSymbol.sfName(for: icon)`.

- [ ] **Step 5: Run the test → ALL PASS.** `cat apps/macos/Sources/InvokePalette/IconSymbol.swift <scratchpad>/iconsymbol-test.swift > <scratchpad>/icon-run.swift && swift <scratchpad>/icon-run.swift` → `ALL PASS`.

- [ ] **Step 6: Expand the api `Icon` enum.** In `packages/api/src/index.ts:388`, add the canonical Raycast `Icon` members not already present, each mapped to its real kebab-case id. Use the canonical Raycast `Icon` enum member→id list (stable public API — do NOT invent ids). Cover the common set (arrows, chevrons, bell, bolt, bug, bookmark, check/checklist, clock, cloud, coin, cog, compass, copy, desktop, download, ellipsis, exclamationmark, filter, heart, house, image, info, keyboard, layers, light-bulb, list, map, maximize, message, microphone, minus, moon, mouse, music, network, pencil, phone, pie-chart, play, power, question-mark, receipt, redo, reply, rocket, ruler, save-document, speaker-high/low/off, stop, sun, trophy, undo, upload, video, wand, warning, x-mark-circle, …). Keep `as const`.

- [ ] **Step 7: typecheck + build.** `cd packages/api && npx tsc --noEmit 2>&1 | tail -5`; `swift build --package-path apps/macos 2>&1 | tail -10`.

- [ ] **Step 8: Commit.**
```bash
git add apps/macos/Sources/InvokePalette/IconSymbol.swift apps/macos/Sources/InvokePalette/PaletteView.swift packages/api/src/index.ts
git commit -m "feat(icon): IconSymbol (standalone-testable) + expanded Icon enum + validated dashes->dots SF fallback"
```

---

### Task 2: `Color.Dynamic` + complete named `Color` set

**Files:**
- Modify: `packages/api/src/index.ts` (`Color` ~442)
- Modify: `apps/macos/Sources/InvokePalette/RaycastColor.swift` (`colorFromNamed` ~8) + the standalone test
- Create (test): `<scratchpad>/color-test.swift`

- [ ] **Step 1: api `Color.Dynamic` + named completeness.** Ensure `Color` has all 9 named members (`Blue`,`Green`,`Magenta`,`Orange`,`Purple`,`Red`,`Yellow`,`PrimaryText`,`SecondaryText`); add `Color.Dynamic`:
```ts
(Color as unknown as { Dynamic: (o: { light: string; dark: string; adjustContrast?: boolean }) => { light: string; dark: string } }).Dynamic =
  (o) => ({ light: o.light, dark: o.dark });
```
(Match how `Color` is currently declared; add `Dynamic` as a member like the existing `Toast.Style`/`Action.Style` patterns. The returned `{light,dark}` is exactly the shape PaletteView's `accessoryColor` already dispatches.)

- [ ] **Step 2: `RaycastColor.colorFromNamed` completeness.** Confirm it maps all 9 named ids (the serialized lowercase/kebab forms: `red`,`green`,`blue`,`yellow`,`orange`,`purple`,`magenta`,`primary-text`,`secondary-text`). Add any missing. (Currently has all but verify `yellow` etc. — it does; add only if a gap.)

- [ ] **Step 3: Standalone test.** `<scratchpad>/color-test.swift`:
```swift
import AppKit
func nn(_ c: NSColor?, _ l: String) { if c != nil { print("ok: \(l)") } else { print("FAIL: \(l) nil"); exit(1) } }
for id in ["red","green","blue","yellow","orange","purple","magenta","primary-text","secondary-text"] { nn(RaycastColor.colorFromNamed(id), id) }
if RaycastColor.colorFromNamed("not-a-color") != nil { print("FAIL: unknown should be nil"); exit(1) }
print("ALL PASS")
```
Run: `cat apps/macos/Sources/InvokePalette/RaycastColor.swift <scratchpad>/color-test.swift > <scratchpad>/color-run.swift && swift <scratchpad>/color-run.swift` → `ALL PASS`. (If `RaycastColor.swift` references other project types it won't compile standalone — it shouldn't; it's AppKit-only.)

- [ ] **Step 4: typecheck + build.** `cd packages/api && npx tsc --noEmit | tail -5`; `swift build --package-path apps/macos | tail -10`.

- [ ] **Step 5: Commit.**
```bash
git add packages/api/src/index.ts apps/macos/Sources/InvokePalette/RaycastColor.swift
git commit -m "feat(color): Color.Dynamic({light,dark}) + complete named Color set"
```

---

### Task 3: `Image.Mask` (Circle/RoundedRectangle) + dynamic `{light,dark}` images

**Files:**
- Modify: `apps/macos/Sources/InvokePalette/PaletteView.swift` (`imageSource(_:)` ~1211; icon/thumb render sites: `configureGridItem` ~1074, list row icon, Detail; add `applyImageMask`)

**Interfaces:**
- Produces: `applyImageMask(_ mask: String?, to iv: NSImageView, side: CGFloat)`; `imageSource` light/dark dispatch.

- [ ] **Step 1: light/dark source dispatch in `imageSource`.** In `imageSource(_:)` (the ImageLike unwrap, ~1211), when the resolved `source` is an object `{ light, dark }`, pick by appearance:
```swift
            if case .object(let o)? = ... source ..., let l = o["light"]?.stringValue, let d = o["dark"]?.stringValue {
                let dark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                return dark ? d : l
            }
```
(Adapt to the exact structure of `imageSource`/the ImageLike unwrap — read it first; the `{light,dark}` may be at `source` or `source.source`.)

- [ ] **Step 2: `applyImageMask` helper.** Add to PaletteView:
```swift
    /// Apply a Raycast Image.Mask to a rendered icon/thumbnail. `side` = the view's square side.
    private func applyImageMask(_ mask: String?, to iv: NSImageView, side: CGFloat) {
        guard let mask else { return }
        iv.wantsLayer = true
        iv.layer?.masksToBounds = true
        switch mask {
        case "circle": iv.layer?.cornerRadius = side / 2
        case "roundedRectangle": iv.layer?.cornerRadius = side * 0.18
        default: iv.layer?.cornerRadius = 0
        }
    }
```

- [ ] **Step 3: Read the `mask` + apply at the render sites.** Where an `Image.ImageLike` object is resolved for a thumbnail/icon (e.g. `configureGridItem` reads `node.props["thumb"]`/`content`/`icon`), also read the `mask` (`if case .object(let o)? = imgProp, let m = o["mask"]?.stringValue`) and call `applyImageMask(m, to: thumb, side: <thumb side>)` after setting the image. Apply at least to the grid cell thumb (most impactful — avatars) and the list-row leading icon if it resolves an ImageLike object. (Read the sites; thread `mask` from the same prop object the source comes from.)

- [ ] **Step 4: Build.** `swift build --package-path apps/macos 2>&1 | tail -10` → `Build complete!`.

- [ ] **Step 5: Commit.**
```bash
git add apps/macos/Sources/InvokePalette/PaletteView.swift
git commit -m "feat(image): honor Image.Mask (circle/roundedRectangle) + dynamic {light,dark} source"
```

---

### Task 4: Fixture (`visual-demo`) + verify

**Files:** Create `examples/visual-demo/package.json`, `examples/visual-demo/src/visual.tsx` (filename = command name `visual`).

- [ ] **Step 1: Read `examples/empty-action-demo/package.json`** and mirror (one `view` command `visual`).
- [ ] **Step 2: `package.json`** (command `visual` mode view).
- [ ] **Step 3: `src/visual.tsx`** — a List exercising the new coverage:
```tsx
import { List, Icon, Color, Image } from "@raycast/api";

export default function Visual() {
  return (
    <List>
      <List.Item title="Bug (was generic)" icon={Icon.Bug} />
      <List.Item title="Rocket" icon={Icon.Rocket} />
      <List.Item title="Bell" icon={Icon.Bell} />
      <List.Item title="House" icon={Icon.House} />
      <List.Item title="Dynamic color tag" icon={{ source: Icon.Circle, tintColor: Color.Dynamic({ light: "#1111ee", dark: "#88aaff" }) }} accessories={[{ tag: { value: "dynamic", color: Color.Dynamic({ light: "#1111ee", dark: "#88aaff" }) } }]} />
      <List.Item title="Circle-masked avatar" icon={{ source: "https://raycast.com/uploads/avatar.png", mask: Image.Mask.Circle }} />
    </List>
  );
}
```
(Confirm `Icon.Bug`/`Rocket`/`Bell`/`House` are now in the enum (Task 1); confirm `Color.Dynamic`/`Image.Mask.Circle` are exported; use only what typechecks. The avatar URL is a placeholder remote image — fine.)

- [ ] **Step 4: Typecheck** the fixture per the other examples.
- [ ] **Step 5: Build + relaunch + log.** `scripts/build-app.sh 2>&1 | tail -5`; relaunch; `tail -40 /tmp/invoke-run.log` → fixture loaded (+1), no error.
- [ ] **Step 6: Human visual checklist (record, don't assert):** Bug/Rocket/Bell/House render real glyphs (not the generic placeholder); the masked avatar is a circle; the dynamic color follows light/dark.
- [ ] **Step 7: Commit.**
```bash
git add examples/visual-demo
git commit -m "test(fixture): visual-demo exercises expanded Icon + Color.Dynamic + Image.Mask"
```

---

## Self-Review

**1. Spec coverage:** Icon enum+mapping → Task 1; Color.Dynamic+named → Task 2; Image.Mask+dynamic source → Task 3; fixture → Task 4. ✅

**2. Placeholder scan:** Concrete code for `IconSymbol`, the fallback, `applyImageMask`, `Color.Dynamic`, and tests. The `NOTE`s (canonical Icon id list, exact `imageSource`/render-site structure, `Color` declaration idiom) are read-the-code checks — explicit. The Icon enum expansion lists the member set to add (canonical ids).

**3. Type/identifier consistency:** `IconSymbol.sfName` (Task 1) used by `PaletteView.sfSymbol` delegate; `applyImageMask` (Task 3) used at render sites; `Color.Dynamic` (Task 2) used in the fixture (Task 4). Tests are standalone (no project deps).

**Known risk (final-review triage):** (a) `IconSymbol.sfName`'s NSImage-validity check runs per icon resolution — fine (cheap, cached by AppKit); (b) the dashes→dots transform can occasionally hit a WRONG-but-valid SF symbol (a Raycast id that dots into an unrelated real symbol) — acceptable (still a glyph; rare); (c) `Image.Mask` `side` must be the actual rendered square side or the circle clip is off — verify the side passed at each call site matches the image view's frame.
