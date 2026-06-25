# Task 1 Report: Respect Stage Manager

## Engine additions (WindowManager.swift)

Added to `WindowManager` (before `init()`):
- `public var respectStageManager: Bool = false`
- `public static let stageManagerStripWidth: CGFloat = 64`
- `public static func insetForStageManager(_ vf: CGRect) -> CGRect` — pure inset: x += 64, width -= 64
- `public static func stageManagerEnabled() -> Bool` — reads `com.apple.WindowManager` `GloballyEnabled` from UserDefaults(suiteName:)
- `public static func effectiveVisibleFrame(_ vf: CGRect, respectStageManager: Bool) -> CGRect` — returns `insetForStageManager(vf)` if `respectStageManager && stageManagerEnabled()`, else `vf`

## The 3 visibleFrame swaps in WindowManager.swift

Each of `apply`, `applyRect`, `applyCycling` had:
```swift
guard let visible = screen?.visibleFrame else { ... }
```
Changed to:
```swift
guard let rawVisible = screen?.visibleFrame else { ... }
let visible = Self.effectiveVisibleFrame(rawVisible, respectStageManager: respectStageManager)
```
The rest of each method (which uses `visible`) is unchanged.

## WindowEnumerator.swift changes

- Added `public var respectStageManager: Bool = false` to the class
- In `visibleAX(forCenter:)`, wrapped the returned AX frame:
  ```swift
  return WindowManager.effectiveVisibleFrame(Self.axRect(cocoaFrame: s.visibleFrame, primaryHeight: h), respectStageManager: respectStageManager)
  ```

## AppSettings.swift

Added `@Published public var respectWindowStageManager: Bool` with `didSet` persisting to `"respectWindowStageManager"` key, and `init` line `respectWindowStageManager = d.object(forKey: "respectWindowStageManager") as? Bool ?? false`, mirroring `windowCyclingEnabled` pattern.

## AppController.swift host sync sites (5 sites)

1. `applyWindow(_:pid:)` — before `windowManager.applyCycling(...)`:
   `windowManager.respectStageManager = AppSettings.shared.respectWindowStageManager`
2. Custom command action in `currentActions()` — before `windowEnumerator.applyPlacement(wc.placement, toPid: pid)`:
   `self.windowEnumerator.respectStageManager = AppSettings.shared.respectWindowStageManager`
3. Layout action in `currentActions()` — before `windowEnumerator.applyLayout(...)`:
   `self.windowEnumerator.respectStageManager = AppSettings.shared.respectWindowStageManager`
4. Custom command run closure in `makeCommands()` — before `windowEnumerator.applyPlacement(c.placement, toPid: pid)`:
   `self.windowEnumerator.respectStageManager = AppSettings.shared.respectWindowStageManager`
5. Layout run closure in `makeCommands()` — before `windowEnumerator.applyLayout(...)`:
   `self.windowEnumerator.respectStageManager = AppSettings.shared.respectWindowStageManager`

## Settings toggle (SettingsView.swift GeneralPane)

Added after "Enable window cycling" toggle + caption:
```swift
Toggle("Respect Stage Manager", isOn: $settings.respectWindowStageManager)
Text("Leaves room for the Stage Manager strip when positioning windows (best-effort).")
    .font(.caption).foregroundStyle(.secondary)
```

## Pure test result

Test file: `<scratch>/main.swift` (content from brief's `sm-test.swift`, named `main.swift` per Swift top-level-code rule).

Compile cmd:
```
swiftc WindowPlacement.swift WindowManager.swift main.swift -o smt -framework AppKit -framework ApplicationServices
```

Output:
```
ok: off → unchanged
ok: inset 64 left
ALL PASS
```

## swift build result

```
Build complete! (14.72s)
```

Zero errors.

## Commit Hash

See `git log` after commit.

## Concerns

- `stageManagerEnabled()` reads `com.apple.WindowManager` suite — heuristic, no public API. Key stable since macOS Ventura but could change.
- 64pt strip width is a heuristic matching the SM thumbnail strip. No public constant exists.
- Live behavior (windows actually leaving the strip) requires Stage Manager enabled at the OS level — human-required per brief.
- Sync-at-apply strategy means setting changes are picked up on the next WM operation automatically.
