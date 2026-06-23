# Task 1 Report: Placement Model + Engine + Store

## Files Changed

- **CREATED** `apps/macos/Sources/InvokeServices/WindowPlacement.swift` — `Sizing`, `Anchor`, `WindowPlacement` types (all `Codable`/`Equatable`)
- **MODIFIED** `apps/macos/Sources/InvokeServices/WindowEnumerator.swift` — added `primaryFullHeight()`, `visibleAX(forCenter:)`, `placementRect`, `serializePlacement`, `parsePlacement`, `applyPlacement`, `applyPlacementToFocused`, `applyLayout`
- **MODIFIED** `apps/macos/Sources/InvokeShell/AppSettings.swift` — added `import InvokeServices`, replaced `CustomWindowCommand.fx/fy/fw/fh` with `placement: WindowPlacement`, added `WindowLayout` struct + `windowLayouts` + CRUD methods
- **MODIFIED** `apps/macos/Sources/InvokeShell/AppController.swift` — updated 3 call sites that referenced old `fx/fy/fw/fh` fields: `presentCustomWindowForm` now serializes/deserializes `WindowPlacement`; two `applyRect(fx:fy:fw:fh:pid:)` calls replaced with `windowEnumerator.applyPlacementToFocused`

## visibleAX / primaryFullHeight Status

**Neither existed before this task.** Both `visibleAX(forCenter:)` and `primaryFullHeight()` were absent from `WindowEnumerator.swift` (WM-4 was superseded without being applied). Added per the WM-4 spec in this task.

## Migration Note

`CustomWindowCommand` previously stored `fx: Double, fy: Double, fw: Double, fh: Double` (fractional screen coordinates). These fields are replaced by `placement: WindowPlacement`. Any existing `customWindowCommands` data in UserDefaults will fail to decode with the new schema → the `?? []` fallback silently drops them. This is acceptable: the feature was days-old dev-only data with no user-facing exposure.

## Pure Test

**Command used:**
```
cd <scratch> && swiftc /Users/test/Documents/code/invoke-v2/apps/macos/Sources/InvokeServices/WindowPlacement.swift /Users/test/Documents/code/invoke-v2/apps/macos/Sources/InvokeServices/WindowEnumerator.swift main.swift -o pt -framework AppKit -framework ApplicationServices && ./pt
```

Note: The brief specifies `placement-test.swift` as the test filename. `swiftc` requires top-level-expression files to be named `main.swift` when compiling multiple files. The test content is identical to the brief; the file was copied as `main.swift` in the scratch directory to satisfy the compiler.

**Output:**
```
ok: center 800x600
ok: topLeft auto
ok: bottomRight 400x300 offset
ok: serialize roundtrip
ok: parse center auto
ok: parse bad → nil
ok: codable roundtrip
ALL PASS
```

## Swift Build Result

```
Build complete! (3.81s)
```

## Commit Hash

(recorded after commit below)

## Concerns

1. **`window-grid-picker` form element**: `presentCustomWindowForm` now serializes a `WindowPlacement` string (anchor;w;h;ox;oy format) into the `window-grid-picker` field. The existing picker was built for the old fraction format. Until a later UI task updates the picker, the create/edit form's grid field will not parse correctly — the fallback `parsePlacement` → `.default` keeps it non-crashing. This is a UI task concern, not a model concern.

2. **`applyPlacement`/`applyPlacementToFocused`/`applyLayout`**: These methods require Accessibility permission and a running UI, so they can only be verified by human testing. The pure geometry (`placementRect`) and serialization tests pass.

3. **`AppController.swift` was not listed in the brief's changed files** — it was required because `AppController` directly referenced the old `fx/fy/fw/fh` fields on `CustomWindowCommand`. Updating it was unavoidable for a clean build.

---

## Code Review Fix Report (applied after commit 382d4b1)

### FIX 1 (CRITICAL — custom window commands silently do nothing from the palette)

**Root cause:** Both run sites called `applyPlacementToFocused`, which resolves `NSWorkspace.shared.frontmostApplication`. When the palette is open, Invoke itself is frontmost, so the command targeted the palette window instead of the user's app.

**How fixed:**
1. Added a new pid-targeted overload to `WindowEnumerator.swift` (after `applyPlacementToFocused`):
   ```swift
   public func applyPlacement(_ p: WindowPlacement, toPid pid: pid_t) -> Bool {
       guard hasAccessibility, let win = focusedWindow(ofPid: pid) else { return false }
       return applyPlacement(p, toWindow: win)
   }
   ```
2. In `AppController.swift` line ~1444 (palette action path, local var `wc`):
   - Before: `self.windowEnumerator.applyPlacementToFocused(wc.placement)`
   - After: `if let pid = self.pasteTarget?.processIdentifier { self.windowEnumerator.applyPlacement(wc.placement, toPid: pid) }`
3. In `AppController.swift` line ~4232 (makeCommands RootCommand run, local var `c`):
   - Before: `self.windowEnumerator.applyPlacementToFocused(c.placement)`
   - After: `if let pid = self.pasteTarget?.processIdentifier { self.windowEnumerator.applyPlacement(c.placement, toPid: pid) }`

`applyPlacementToFocused` was left defined (harmless; may be used elsewhere).

### FIX 2 (Minor — dead code)

Removed unused `private func currentSize(_ win: AXUIElement) -> CGSize` from `WindowEnumerator.swift`. It was never called; `applyPlacement` reads size inline via `axDouble`.

### FIX 3 (Minor — interim form silently saves default on bad input)

In `AppController.swift`'s `presentCustomWindowForm` submit closure:
- Before: `let placement = WindowEnumerator.parsePlacement(vals["grid"] ?? "") ?? .default`
- After: `guard let placement = WindowEnumerator.parsePlacement(vals["grid"] ?? "") else { return }`

This prevents silently persisting a default placement when the grid picker returns unparseable data.

### Pure Test Result

```
ok: center 800x600
ok: topLeft auto
ok: bottomRight 400x300 offset
ok: serialize roundtrip
ok: parse center auto
ok: parse bad → nil
ok: codable roundtrip
ALL PASS
```

### Swift Build Result

```
Build complete! (4.26s)
```

### Commit Hash

`45ed37d`
