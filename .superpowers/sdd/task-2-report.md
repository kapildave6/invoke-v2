# Task 2 Report: WindowEnumerator

## Status
COMPLETE

## File Created
`apps/macos/Sources/InvokeServices/WindowEnumerator.swift` — 140 lines, verbatim from brief.

## Module Purity
Imports ONLY `AppKit` and `ApplicationServices`. No imports of `InvokeShell`, `InvokeIPC`, `AppSettings`, or `JSONValue`. Confirmed by inspection of the file header.

## Pure-Helper Test

**Command:**
```
cd <scratch> && swiftc /Users/test/Documents/code/invoke-v2/apps/macos/Sources/InvokeServices/WindowEnumerator.swift main.swift -o wm2test -framework AppKit -framework ApplicationServices && ./wm2test
```

**Output:**
```
ok: center-in-A
ok: center-in-B
ok: offscreen→first
ok: merge-x-only
ok: merge-size-only
ALL PASS
```

All 5 assertions pass (compile exit 0, run exit 0).

## swift build Result

```
Build complete! (3.46s)
```

Command: `swift build --package-path apps/macos`

## Commit Hash
`8774a03`

Full message: `feat(wm): WindowEnumerator — AX window enumeration + id cache + bounds set (InvokeServices)`

## Concerns / Notes
- `_AXUIElementGetWindow` resolved via `dlsym` is a private API — intentional per brief; included verbatim.
- `cache` is per-`WindowEnumerator` instance and repopulated on each enumeration call; `setBounds` only works if the target window appeared in a prior enumeration.
- The `windowsOnActiveDesktop()` method enumerates all `.regular` policy apps, not just those on the active Space — filtering by active Space would require CGSPrivate, which is intentionally out of scope here.
- AX live parts (`activeWindow`, `windowsOnActiveDesktop`, `desktops`, `setBounds`) are NOT unit-tested (require AX permission + running app); human verification required.

---

## Review-Fixes Report (post-commit 8774a03)

### FIX 1 — axDouble crash guard (Important)
Added `CFGetTypeID(ref) == AXValueGetTypeID()` type check in `axDouble` before the force-cast `ref as! AXValue`. The guard is appended to the existing `guard` clause so it fails out cleanly returning `nil` instead of trapping. Mirrors the identical `AXUIElementGetTypeID()` pattern already used in `focusedWindow`.

### FIX 2 — setBounds wrong pid (Important)
Replaced the "find frontmost focused window's pid" approach with a direct `AXUIElementGetPid(win, &pid)` call on the cached AX element. This correctly returns the owning process for background windows. `NSRunningApplication(processIdentifier:)` returns Optional — accepted by `info(for:pid:app:frontFocused:)` which already takes `NSRunningApplication?`.

### FIX 3 — screenTuples coordinate-space bug (Minor)
Added `static func axRect(cocoaFrame:primaryHeight:)` pure helper that converts a Cocoa frame (y-up, bottom-left origin) to AX-native space (y-down, top-left of primary). `screenTuples()` now computes `primaryHeight` from the screen with `frame.origin == .zero` (fallback: first screen) and maps all screen frames through `axRect`. Fixes `desktopId` mis-assignment on vertically-stacked multi-monitor setups.

### FIX 4 — fullScreen: false clarity (Minor)
Added inline comment on the `fullScreen: false` literal in `desktops()`: `// intentional: no public per-display fullscreen-state API; per-window fullScreen lives on WindowInfo`.

### Pure-helper test (re-run after fixes)

**Command:**
```
cd <scratch> && swiftc /Users/test/Documents/code/invoke-v2/apps/macos/Sources/InvokeServices/WindowEnumerator.swift main.swift -o wm2test -framework AppKit -framework ApplicationServices && ./wm2test
```

**Output (8 assertions, ALL PASS):**
```
ok: center-in-A
ok: center-in-B
ok: offscreen→first
ok: merge-x-only
ok: merge-size-only
ok: axRect-primary
ok: axRect-screen-above
ok: axRect-screen-below
ALL PASS
```

New assertions added: `axRect-primary`, `axRect-screen-above`, `axRect-screen-below`.

### swift build result
```
Build complete! (1.59s)
```
Command: `swift build --package-path apps/macos`

### Commit
`9ccb21b` — `fix(wm): WindowEnumerator review fixes (axDouble guard, setBounds pid, screenTuples AX space, fullScreen comment)`
