# Task 2 Report: Fallback persistence + Settings "Fallback Commands" section

## Status: DONE

**Commit:** ff5fc94  
**Build:** `Build complete! (4.89s)` — only pre-existing warnings (Sendable, unused binding), no new warnings or errors.

---

## AppSettings additions (`apps/macos/Sources/InvokeShell/AppSettings.swift`)

Added after `trustedExtensions` (line ~54):

```swift
@Published public var fallbackCommands: [String] { didSet { d.set(fallbackCommands, forKey: "fallbackCommands") } }
public func addFallback(_ id: String) { if !fallbackCommands.contains(id) { fallbackCommands.append(id) } }
public func removeFallback(_ id: String) { fallbackCommands.removeAll { $0 == id } }
public func moveFallback(_ id: String, up: Bool) {
    guard let i = fallbackCommands.firstIndex(of: id) else { return }
    let j = up ? i - 1 : i + 1
    guard j >= 0, j < fallbackCommands.count else { return }
    fallbackCommands.swapAt(i, j)
}
```

Loaded in `init()`:
```swift
fallbackCommands = (d.array(forKey: "fallbackCommands") as? [String]) ?? []
```

Persists to `UserDefaults` as an ordered `[String]` array under key `"fallbackCommands"`.

---

## Fallback Commands section in `CommandsPane` (`apps/macos/Sources/InvokeShell/SettingsView.swift`)

### Placement
Below the main command-list/detail `HStack`, separated by a `Divider`, spanning the full pane width. The existing `HStack` is now wrapped in a `VStack` alongside the fallback section. This keeps the table layout untouched and gives the fallback config its own clearly separated zone.

### Command metadata source
The section reuses `groups: [ExtensionGroup]` passed into `CommandsPane` (populated by `AppController.extensionGroups()` at settings open). Three computed helpers were added to the struct:

- `allCommands: [CommandInfo]` — flattens all groups in display order.
- `commandInfo(for:) -> CommandInfo?` — id → CommandInfo lookup (title, icon, iconPath).
- `groupName(for:) -> String` — resolves the owning group name for icon colour keying, matching `CommandTileIcon`'s deterministic djb2 colouring used in the command table.

### Eligible command determination
```swift
private var fallbackEligible: [CommandInfo] {
    let added = Set(settings.fallbackCommands)
    return allCommands.filter { $0.supportsBinding && !added.contains($0.id) }
}
```

- `supportsBinding == true` excludes the Calculator (which has `supportsBinding: false`).
- `extensionGroups()` never emits menu-bar (`menu-bar` mode) or background/interval commands — these are filtered out at discovery time in `AppController`. No additional exclusion needed.
- Already-added ids are excluded from the picker.

### UI elements
- Section header: "Fallback Commands" (caption, uppercased, secondary colour) with a one-liner caption: "Shown when a search has no results; the query is passed to the command."
- "Add Fallback Command…" `Menu` button (borderless, top-right of the header row) listing eligible commands with their SF symbol icon via `Label`. Shows a "All eligible commands already added" placeholder when exhausted.
- Per-row: drag-handle glyph (visual affordance), `CommandTileIcon` at 18pt (same icon+colour logic as the table), title, Up/Down chevron buttons (`settings.moveFallback`), `xmark.circle.fill` remove button (`settings.removeFallback`).
- Up button disabled for the first row; Down button disabled for the last row.
- Empty-state label ("No fallback commands. Add one above.") when the list is empty.
- Styling: `font(.callout)` for titles, `font(.caption)` for buttons and header, `buttonStyle(.borderless)`, 16pt horizontal padding — consistent with the command table rows.

---

## Concerns

None blocking. One note: the `VStack` wrapping means the fallback section is always visible below the command table (not inside the scroll area). On very constrained window heights, users would need to resize the window to see it. This is consistent with how multi-section macOS Settings panes behave.

---

## Eligibility-filter fix

### What changed

**`RootCommand` (`AppController.swift`):** Added `var fallbackEligible: Bool = false` (default false) to the private struct. This is distinct from `supportsBinding` — a menu-bar command can legitimately have a hotkey binding but must not appear as a fallback.

**`discoverExtensionCommands` (`AppController.swift`):** Three branches updated:
- **Menu-bar branch:** `fallbackEligible` left as default `false` — these are toggle-driven, not query-driven.
- **No-view branch:** Introduced `isIntervalNoView` boolean. When `cmode == "no-view"` and the manifest carries an `interval` key that parses to a valid duration, `isIntervalNoView = true`. `fallbackEligible: !isIntervalNoView` — so user-invoked no-view commands are eligible; timer-driven background ones are not. Interval detection is distinguishable here because `parseInterval()` is called just before the branch.
- **View branch (else):** `fallbackEligible: true` — always query-driven UI surface.
- **AI-ask ("Ask \<ext\>") branch:** `fallbackEligible: true` — these accept the user's raw query and pass it to the extension's AI tools.

**`makeCommands` (`AppController.swift`):** `ai.chat` ("AI Chat") built-in set to `fallbackEligible: true`. All other built-ins (window management, folder navigation, system commands, snippet/quicklink, settings tabs) remain `fallbackEligible: false` (default) — they are either action-only or navigational, not query consumers.

**`CommandInfo` (`SettingsView.swift`):** Added `public let fallbackEligible: Bool` field with default `false` in the init. `supportsBinding` is preserved unchanged.

**`extensionGroups()` (`AppController.swift`):** The `CommandInfo(...)` construction now passes `fallbackEligible: c.fallbackEligible`, propagating the flag from `RootCommand` to the Settings UI layer.

**Fallback picker (`SettingsView.swift`):**
- Renamed `fallbackEligible: [CommandInfo]` computed property to `fallbackEligibleCommands` to avoid name clash.
- Filter changed from `$0.supportsBinding && !added.contains($0.id)` to `$0.fallbackEligible && !added.contains($0.id)`.
- `ForEach(Array(settings.fallbackCommands.enumerated()), id: \.element)` changed to `id: \.offset` — prevents a SwiftUI duplicate-id crash if a stale duplicate id ever appears in UserDefaults.

### Command eligibility summary

| Class | `fallbackEligible` | Reason |
|---|---|---|
| Extension view commands | `true` | Query-driven UI surface |
| Extension no-view (user-invoked) | `true` | Accepts query, runs headless |
| Extension no-view (interval/background) | `false` | Timer-driven, no user query |
| Extension menu-bar commands | `false` | Toggle-driven (on/off), not query consumers |
| Extension AI-ask commands | `true` | Accepts raw query, routes to AI tools |
| Built-in: `ai.chat` | `true` | Query-driven chat UI |
| Built-in: AI text transforms (ai.improve, ai.grammar, etc.) | `false` | Selection-driven transforms, not search-query consumers |
| Built-in: window/folder/system/snippet/quicklink/settings | `false` | Action or navigation, not query consumers |
| Calculator | `false` | `supportsBinding: false`; typed inline fallback, not a command |

### Interval no-view handling

Interval no-view commands are fully distinguishable at discovery time: `isIntervalNoView` is set to `true` inside the `if cmode == "no-view", let iv = c["interval"] as? String, let secs = Self.parseInterval(iv)` block, which runs before the branch that builds the `RootCommand`. No ambiguity remained — interval detection is precise.

### Build tail

```
Build complete! (0.11s)
```

No new warnings or errors.
