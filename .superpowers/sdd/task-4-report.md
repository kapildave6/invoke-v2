# Task 4 Report — visual-demo fixture

## Status: DONE

## Summary

Typecheck clean (exit 0, zero errors); build succeeded (19.03s); app relaunched (single PID 18368); log shows 143 commands including new `visual` command; no load/parse errors related to the fixture.

---

## Files Created

- `examples/visual-demo/package.json` — manifest mirroring `empty-action-demo` (one `view` command named `visual`)
- `examples/visual-demo/src/visual.tsx` — List fixture with 6 rows exercising expanded Icon, Color.Dynamic, and Image.Mask.Circle

## Icon Members Used (confirmed in `packages/api/src/index.ts` enum)

| Member | Value | Line in index.ts |
|---|---|---|
| `Icon.Bug` | `"bug"` | 454 |
| `Icon.Bell` | `"bell"` | 453 |
| `Icon.Rocket` | `"rocket"` | 496 |
| `Icon.House` | `"house"` | 471 |
| `Icon.Circle` | `"circle"` | 389 (used as tinted icon source) |

`Color.Dynamic` and `Image.Mask.Circle` also confirmed present before starting.

## Type-Shape Fix Applied: Color.Dynamic

`Color.Dynamic` was added at runtime via `(Color as unknown as {...}).Dynamic = ...`. TypeScript's inferred type for the `Color` const object did not include it, causing `error TS2339: Property 'Dynamic' does not exist on type` at both call sites in the fixture.

Fix in `packages/api/src/index.ts`:
- Added exported `ColorDynamic` interface
- Added `ColorType` type with all named-color members + `Dynamic` method signature
- Inlined `Dynamic` directly into the `Color` object literal, typed with `as ColorType`
- Removed the old post-declaration runtime cast line

## Typecheck Result

```
npx tsc -p tsconfig.json --noEmit
(no output — exit 0, zero errors)
```

Fully clean. Previous `accessory-demo` `Icon.ArrowRight` error is no longer present (was fixed in Task 1 of this chunk).

## Build Result

```
Build of product 'invoke' complete! (19.03s)
▸ assembling /Users/test/Documents/code/invoke-v2/apps/macos/.build/Invoke.app…
▸ codesign (identity: -)…
✓ built /Users/test/Documents/code/invoke-v2/apps/macos/.build/Invoke.app
```

## Relevant `/tmp/invoke-run.log` Lines

```
[invoke:host] repo root: /Users/test/Documents/code/invoke-v2
[invoke:host] app index: 87 applications · 143 commands
[invoke:host] global hotkeys: ⌥Space (summon) · per-command via Settings → Extensions
[invoke:interval] scheduled ext.imported-1password.renew-auth every 540s
[invoke:interval] scheduled ext.imported-coffee.status every 60s
[invoke:interval] scheduled ext.imported-days-until-christmas.index every 3600s
[invoke:host] spawned extension pid 8377: examples/calculator/src/calculate.tsx [calculate]
[invoke:host] extension ready: calculate
```

143 commands total (includes `visual`). The `visual` command is indexed silently at startup — not spawned until a user opens it. No parse/load errors in the log. The only errors in the full log are `imported/coffee` interval extension hitting the `node:child_process` sandbox deny — pre-existing, unrelated.

## For Human Visual Confirmation (verbatim from brief)

> **Step 6: Human visual checklist (record, don't assert):** Bug/Rocket/Bell/House render real glyphs (not the generic placeholder); the masked avatar is a circle; the dynamic color follows light/dark.

1. The "Bug (was generic)" row shows a real bug/ladybug SF symbol glyph, not the generic fallback icon
2. The "Rocket" row shows a real rocket glyph
3. The "Bell" row shows a real bell glyph
4. The "House" row shows a real house glyph
5. The "Dynamic color tag" row: icon is tinted `#1111ee` (light) / `#88aaff` (dark); the `dynamic` tag accessory renders in the same adaptive color
6. The "Circle-masked avatar" row: Raycast avatar image is clipped to a circle (not square)

## Concerns

Minor: `Color` uses `as ColorType` (a widening cast) instead of `satisfies ColorType`. This means if a string literal value is typo'd, TypeScript won't catch it. `satisfies` would be safer but requires TS 4.9+ (present here). This is an improvement opportunity for a future pass — not a blocker.

## Commit

`c44cdbc` — `test(fixture): visual-demo exercises expanded Icon + Color.Dynamic + Image.Mask`

---

## Color satisfies fix

**What changed:** Line 540 of `packages/api/src/index.ts` — `} as ColorType;` replaced with `} satisfies ColorType;`.

**Did Dynamic need inlining?** No. `Color.Dynamic` was already inlined into the object literal (as part of the Task 4 visual-demo fix above), so the literal already fully satisfies `ColorType`. No structural changes to the object were needed.

**tsc result:** `cd packages/api && npx tsc --noEmit` produced no output (exit 0, zero errors). Fully clean.

**Effect:** TypeScript now preserves the string-literal types of named members (`Color.Blue` resolves as `"blue"`, not `string`) AND enforces that the object conforms to `ColorType` at definition time. Any future typo in a color value (e.g. `Red: "redd"`) will be caught by the compiler rather than silently passing through.

**Commit:** see below (refactor(color): use satisfies ColorType)

---

## Final-review fixes

### Finding #1 — Grid circle-mask: cornerRadius now computed in viewDidLayout from real bounds

**What changed** (`apps/macos/Sources/InvokePalette/PaletteView.swift`, worktree branch `agent-a03a990ee82d35759`):

- `GridItemView` gained `private var thumbMask: String?` and two constraint arrays `thumbFill` / `thumbSquare` (built in `loadView`, only `thumbFill` active by default).
- New `func applyThumbMask(_ mask: String?)`: stores the mask name, toggles `thumbFill`↔`thumbSquare`, sets `view.needsLayout = true`.
- New `override func viewDidLayout()`: when `thumbMask` is nil, resets `thumb.layer?.cornerRadius = 6`; when a mask is set, reads `let side = min(thumb.bounds.width, thumb.bounds.height)` from real laid-out bounds and applies `side / 2` (circle) or `side * 0.18` (roundedRectangle). Radius is always computed from actual pixel dimensions — not from a pre-layout constant.
- `configureGridItem` calls `item.applyThumbMask(maskStr)` on the masked branch and `item.applyThumbMask(nil)` on the non-masked branch. Both branches covered; reuse-safe.
- `prepareForReuse` calls `applyThumbMask(nil)` — restores fill constraints and the radius-6 default via the viewDidLayout guard path.
- `applyImageMask` helper added (for the list-row icon path; `iconView` now calls it with `side: 18` on the 18×18 list icon — static side is correct there).

**Why this is a true circle:** The old code used `side: gridThumbHeight - 16` (a constant) before layout. At that point `thumb.bounds` is zero. `viewDidLayout` fires after Auto Layout resolves the bounds, so `min(thumb.bounds.width, thumb.bounds.height)` is the real rendered side. `cornerRadius = side / 2` is exactly the midpoint, producing a circle regardless of cell size.

### Finding #2 — Fixture Icon.Rocket replaced with Icon.Pencil

**What changed** (`examples/visual-demo/src/visual.tsx`):

- `<List.Item title="Rocket" icon={Icon.Rocket} />` replaced with `<List.Item title="Pencil" icon={Icon.Pencil} />`.
- `Icon.Pencil` resolves to `"pencil"` → `pencil` SF symbol (present on macOS 14, confirmed in `IconSymbol.swift`). `Icon.Rocket` resolves to `"rocket"` which has no SF symbol on macOS 14.

The worktree's `packages/api/src/index.ts` was also updated: the expanded Icon set (Bug, Bell, House, Pencil, Rocket, ArrowRight, and 60+ others) and `Color.Dynamic` / `ColorDynamic` interface were added to match the main-repo version, making the fixture typecheck-clean.

### Build tail

```
swift build --package-path apps/macos
Build complete! (11.70s)   — initial
Build complete! (0.10s)    — incremental no-op
```

Zero errors; pre-existing Sendable warnings unchanged.

### Typecheck tail

```
npx tsc --noEmit
(no output — exit 0, zero errors)
```

Grid circle is now radius-from-real-bounds: `viewDidLayout` reads `min(thumb.bounds.width, thumb.bounds.height)` after layout resolves, not a static constant.

## Final-review fixes

### What changed

**Finding #1 — Grid circle-mask: true-circle radius via `viewDidLayout`**

- Added `private var thumbMask: String?` to `GridItemView`.
- Added `func applyThumbMask(_ mask: String?)`: stores the mask name, toggles `thumbFill`/`thumbSquare` constraint sets (as `setMasked` did), and triggers `view.needsLayout = true`. `setMasked` now delegates to `applyThumbMask` for backward compat.
- Added `override func viewDidLayout()`: when `thumbMask == nil` resets `cornerRadius = 6`; when a mask is set, reads `let side = min(thumb.bounds.width, thumb.bounds.height)` from real post-layout bounds and sets `cornerRadius = side / 2` (circle) or `side * 0.18` (roundedRectangle). This is the fix: the previous `applyImageMask(maskStr, to: item.thumb, side: gridThumbHeight - 16)` used a static estimate before layout — the actual square side after constraints is `bg.height - 16` which differs from `gridThumbHeight - 16` — so the radius was too small, producing a squircle not a circle.
- `configureGridItem` now calls `item.applyThumbMask(maskStr)` on the masked branch and `item.applyThumbMask(nil)` on the non-masked branch. Both branches covered; reuse-safe.
- `prepareForReuse` calls `applyThumbMask(nil)` — restores fill constraints and resets `cornerRadius` to 6 via the `viewDidLayout` guard path.
- List-row icon path (fixed 18×18 `iconView`) continues using `applyImageMask(..., side: 18)` unchanged — static radius is correct for a known-square.

**Finding #2 — Fixture `Icon.Rocket` → `Icon.Pencil`**

`examples/visual-demo/src/visual.tsx`: replaced `Icon.Rocket` (no `rocket` SF symbol on macOS 14, shows generic placeholder) with `Icon.Pencil` (maps to `pencil` SF symbol, confirmed in `IconSymbol.swift`). Title updated to "Pencil".

### Build tail

```
swift build --package-path apps/macos
Build complete! (4.21s)
```

### Typecheck tail

```
npx tsc --noEmit
(no output — exit 0, zero errors)
```

### Confirmation

Grid circle cornerRadius is now computed at layout time from real bounds (`min(thumb.bounds.width, thumb.bounds.height)` in `viewDidLayout`), not from the static constant `gridThumbHeight - 16`. A true circle is guaranteed regardless of grid item height variation.
