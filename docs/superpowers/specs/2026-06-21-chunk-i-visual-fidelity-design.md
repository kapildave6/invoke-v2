# Chunk I — P2 Visual Fidelity (Icon/Color coverage + Image.Mask + dynamic light/dark) Design

**Part of the autonomous Raycast-parity push** (`[[autonomous-parity-goal]]`). The first of the P2 "safe breadth" sub-chunks. Closes the visual-coverage items in `RAYCASTVSINVOKE.md` §2:
- Full(er) `Icon` enum coverage + SF-Symbol mapping (today ~48 of Raycast's ~250 members defined; ~30 SF-mapped, rest → generic "app").
- `Color.Dynamic` export + complete the named `Color` set.
- `Image.Mask` (Circle / RoundedRectangle) — currently ignored.
- Dynamic `{ source: { light, dark } }` image source — pick by appearance.

## Global constraints
- World-class Raycast-quality UX; never ship system-default/janky UI.
- Faithful parity; don't fabricate third-party brands. Fixture imports `@raycast/api`.
- Commit on `main`. Relaunch after build+install.
- No Xcode/XCTest → TS via tsc; AppKit via build + fixture/relaunch/log; pure mappings via standalone `swift`.
- `RaycastColor.swift` stays AppKit-only (standalone-testable).

---

## Item 1 — `Icon` enum + SF-Symbol mapping coverage

**Current:** `packages/api/src/index.ts:388` `Icon` = ~48 members; `PaletteView.sfSymbol(for:)` (`:2478`) maps ~30 explicit names, else `"app"`. The renderers already try `NSImage(systemSymbolName: rawName)` BEFORE `sfSymbol(for:)`, so Raycast names that happen to be valid SF symbols ("envelope", "gear", "trash", "wifi", …) already resolve; the gap is (a) Raycast `Icon.*` members not defined in the api enum (extensions can't reference them — no crash, but no value), and (b) name-mismatches not in `sfSymbol(for:)` (kebab Raycast name ≠ dotted SF name) falling to the generic "app".

**Design:**
- **api `Icon` enum:** expand toward the full Raycast `Icon` set (the public enum is a known, stable list — e.g. `ArrowDown`, `ArrowLeft`, `ArrowRight`, `ArrowUp`, `Bell`, `Bolt`, `Bug`, `Bookmark`, `Calendar`, `Check`, `CheckList`, `ChevronDown/Left/Right/Up`, `CircleProgress*`, `Clock`, `Cloud`, `Coin`, `Cog`/`Gear`, `Compass`, `Copy`/`CopyClipboard`, `Desktop`, `Download`, `Ellipsis`, `Exclamationmark`, `Filter`, `Heart`, `House`, `Image`, `Info`, `Keyboard`, `Layers`, `LightBulb`, `Link`, `List`, `Lock`, `Map`, `Maximize`, `Message`, `Microphone`, `Minus`, `Moon`, `Mouse`, `Music`, `Network`, `Pencil`, `Phone`, `PieChart`, `Play`, `Plus`, `Power`, `QuestionMark`, `Receipt`, `Redo`, `Reply`, `Rocket`, `Ruler`, `Save`/`SaveDocument`, `Shield`, `SpeakerHigh/Low/Off`, `Star`, `Stop`, `Sun`, `Tag`, `Text`, `Trash`, `Trophy`, `Undo`, `Upload`, `Video`, `Wand`, `Warning`, `Window`, `XMarkCircle`, …). Add the members not already present, each mapped to its Raycast kebab-case string id. (Use the canonical Raycast `Icon` member→id list; do NOT invent ids.)
- **`sfSymbol(for:)`:** add explicit mappings for the kebab ids whose name differs from a valid SF symbol; and improve the FALLBACK: before `"app"`, try the raw id with dots-for-dashes (e.g. `"arrow-up" → "arrow.up"`) via `NSImage(systemSymbolName:)` at the call sites that already do the two-step — i.e. keep `sfSymbol(for:)` returning the best dotted candidate (`name.replacingOccurrences(of: "-", with: ".")`) instead of `"app"` when no explicit case matches, so `NSImage(systemSymbolName:)` gets a real shot before the generic glyph. (Net: far more icons resolve to a real SF Symbol.)
- This stays best-effort: an id with no valid SF symbol still falls back to a generic glyph (no crash).

## Item 2 — `Color.Dynamic` + complete the named `Color` set

**Current:** `packages/api/src/index.ts:442` `Color` has the named members; `Color.Dynamic` (a function returning a `{light,dark,adjustContrast}` dynamic color) is NOT exported (§12 note). `RaycastColor.colorFromNamed` (`:8`) maps red/green/blue/yellow/orange/purple/magenta/primary-text/secondary-text.

**Design:**
- **api:** add `Color.Dynamic = (opts: { light: string; dark: string; adjustContrast?: boolean }) => ({ light: opts.light, dark: opts.dark })` (returns a `{light,dark}` value the renderer already dispatches for hex/dynamic colors). Ensure all 9 Raycast named `Color` members are present (`Blue`, `Green`, `Magenta`, `Orange`, `Purple`, `Red`, `Yellow`, `PrimaryText`, `SecondaryText`) — add any missing.
- **`RaycastColor.colorFromNamed`:** confirm it covers all 9 named ids; add any missing (the serialized ids — e.g. `"red"`, `"primary-text"`). (The `{light,dark}` dynamic dispatch already exists in PaletteView's `accessoryColor`; `Color.Dynamic` produces exactly that shape, so no Swift change beyond named-set completeness.)

## Item 3 — `Image.Mask` (Circle / RoundedRectangle)

**Current:** `Image.Mask` is exported (`:982`) but the renderer ignores it — icons/thumbnails render unmasked.

**Design:**
- Where an `Image.ImageLike` is `{ source, mask }` (an object with a `mask` of `"circle"` / `"roundedRectangle"`), apply the mask to the rendered image view: `circle` → `imageView.wantsLayer = true; layer.cornerRadius = side/2; masksToBounds = true` (a circular clip for square images, e.g. avatars); `roundedRectangle` → a modest corner radius (≈ side * 0.18). Apply at the icon/thumbnail render sites that resolve an `Image.ImageLike` (grid cell thumb `configureGridItem`, list row leading icon, Detail). A small helper `applyImageMask(_ maskName: String?, to iv: NSImageView, side: CGFloat)` centralizes it.
- The mask comes from the image prop object; thread the mask name through the existing image resolution (the resolvers currently read `source`; also read `mask`).

## Item 4 — Dynamic `{ source: { light, dark } }` images

**Current:** a single image source is resolved; a `{ light, dark }` source object isn't dispatched by appearance.

**Design:**
- In the image-source resolver (`imageSource(_:)` / the ImageLike unwrap), when `source` is an object `{ light, dark }`, pick `dark` vs `light` by the current appearance (`NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua`). Re-resolve on appearance change is out of scope (resolved at render time; a re-render picks up the new appearance).

## Item 5 — Fixture + verify

- `examples/visual-demo/` (manifest mirrors `examples/empty-action-demo`, imports `@raycast/api`): a `List`/`Detail` showing items with: several `Icon.*` that previously fell back (e.g. `Icon.Bug`, `Icon.Rocket`, `Icon.Bell`, `Icon.House`) to prove expanded coverage; a `List.Item` icon with `{ source, mask: Image.Mask.Circle }`; a `Color.Dynamic({light,dark})` tinted accessory; an icon with `{ source: { light, dark } }`.
- Verify: typecheck clean; `scripts/build-app.sh`; relaunch; `/tmp/invoke-run.log` shows the fixture loaded, no error. Human visual: the previously-generic icons now render real glyphs; the masked icon is a circle; the dynamic color/image follow the system appearance.

## Testing strategy
- **Pure/standalone (`swift`):** `sfSymbol(for:)` returns a dotted candidate (not "app") for unmapped kebab ids, and the explicit mappings; `RaycastColor.colorFromNamed` covers all 9 named ids — via a standalone `swift` script.
- **AppKit/integration:** Image.Mask clip + dynamic image/color → via build + fixture + relaunch + human visual.

## Out of scope (tracked elsewhere)
- Exhaustively enumerating ALL ~250 Raycast `Icon` members — this chunk adds the common set + a smart fallback so most resolve; a literal-complete enum is a mechanical tail (note remaining).
- `Image.tintColor` as a top-level `Image` prop API export (accessory tint already works).
- Appearance-change live re-render (resolved at render time only).
