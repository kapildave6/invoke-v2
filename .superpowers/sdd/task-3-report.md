# Task 3 Report: Root no-match integration + `fallbackText` wiring

## Status: DONE

---

## Per-file changes

### `runtime/node-host/src/child.ts` (line 145)

Added `fallbackText: process.env.INVOKE_FALLBACK_TEXT || undefined` to the `launchProps` object. `packages/api` already had `fallbackText?: string` in its `LaunchProps` interface — no API change needed.

### `apps/macos/Sources/InvokeShell/ExtensionHost.swift`

- Added `fallbackText: String = ""` as a trailing default parameter to `launch(...)`.
- After the `env["INVOKE_LAUNCH_CONTEXT"]` assignment, added:
  ```swift
  if !fallbackText.isEmpty { env["INVOKE_FALLBACK_TEXT"] = fallbackText }
  ```
  Conditional so the env var is absent (not just empty) for all non-fallback launches.

### `apps/macos/Sources/InvokeShell/AppController.swift`

Three distinct changes:

#### 1. `launchExtension` and `runNoViewExtension` — thread fallbackText

Both private functions received `fallbackText: String = ""` as a new trailing default parameter. Their internal `h.launch(...)` call passes `fallbackText: fallbackText`. All existing callers (RootCommand closures, `launchCommand` RPC, `handleSandboxDenial` relaunch) use keyword arguments and gain default `""` automatically — zero callers updated.

#### 2. `buildRoot` — append fallback rows on no-match

**No-match detection:** Inside the non-empty-query `else` branch, after `matchCommands(q)` → `cmdItems` and `appIndex.search(q)` → `appItems`, the block fires iff `cmdItems.isEmpty && appItems.isEmpty`. This is the exact spot where both command and application results are known to be zero — not on partial matches.

**Fallback rows built:** For each id in `AppSettings.shared.fallbackCommands` (in order), the code calls `commands.first(where: { $0.id == fbId })` — NOT filtered by `isEnabled`. A `disabledByDefault` command added as a fallback is resolved and shown. The node is built via the existing `itemNode(...)` helper with `commandId: nil`, then:
- `node.props["fallbackCommandId"] = .string(fbId)` — marks it for `currentActions()` dispatch
- `node.props["accessories"] = .array([{"text":"Fallback"}, {"tag": q}])` — shows "Fallback" label + the query text as the accessory tag

Section title: "Fallback Commands". Empty fallbackCommands → no section appended.

Fallback rows appear AFTER the "Use AI" section (absolute bottom).

#### 3. `currentActions()` — fallback activation branch

Inserted before the final `actions(under: node)` generic path. When `node.props["fallbackCommandId"]` is set, `lastQuery` is read at action-build time (currentActions is called just before activation):

1. **`ai.chat` built-in:** calls `enterAIChat(initial: q)` — seeds the chat with the query directly.
2. **Extension commands** (id in `extLaunchables`): calls `launchExtensionCommand(...)` with the resolved `ExtLaunchable`, then in the completion closure calls `runNoViewExtension(..., fallbackText: q)` or `launchExtension(..., fallbackText: q)` based on `target.mode`. Bumps frecency.
3. **Generic built-ins** (not in extLaunchables): calls `cmd.run()` and `afterLaunch()` if `closesPalette`. fallbackText does not apply to these built-ins but they still launch.

---

## No-match detection — exact mechanics

- `mode == .root` is implicit: `buildRoot` is only called from `renderRoot`, which is only called in root mode.
- Non-empty query is implicit: we are in the `else` branch of `if q.isEmpty`.
- `cmdItems.isEmpty` → `matchCommands(q)` returned zero enabled commands matching the query.
- `appItems.isEmpty` → `appIndex.search(q)` returned zero application results.
- The "Ask AI" row is NOT a trigger blocker — it appears independently when `ai.hasKey`. Fallbacks appear below it.

---

## disabledByDefault-as-fallback

`commands.first(where: { $0.id == fbId })` scans the full `commands` array without an `isEnabled` filter. `extLaunchables` is populated for all discovered extension commands regardless of `disabledByDefault`. So a `disabledByDefault` command that the user has added as a fallback will appear and launch correctly.

---

## Build + tsc

```
packages/api:        npx tsc --noEmit  → (no output, clean)
runtime/node-host:   npx tsc --noEmit  → (no output, clean)
swift build:         Build complete! (5.63s)
```

---

## Concerns

None. `INVOKE_FALLBACK_TEXT` is set conditionally (only when non-empty), so non-fallback launches have no new env key. The fallback row uses `fallbackCommandId` (not `commandId`) so `selectedRootCommand()` and `updateRootArguments()` (which read `commandId`) correctly ignore fallback rows — no unwanted argument chips appear for fallback rows.

---

## Double-bump fix

### What changed

`currentActions()` fallback-command branch (`AppController.swift`, ~line 1436): the `self.frecency.bump("cmd:\(fbId)")` call was moved from BEFORE the `launchExtensionCommand(...)` callback into the ELSE (view-mode) branch of the callback. Two clarifying comments were added inline.

Before the fix, the call sequence for a no-view fallback command was:
1. explicit `frecency.bump("cmd:\(fbId)")` in the closure — bump #1
2. `runNoViewExtension(...)` called → its first line is `frecency.bump("cmd:\(id)")` — bump #2

### Each path now bumps exactly once

- **no-view fallback**: `runNoViewExtension` bumps at its first line (`frecency.bump("cmd:\(id)")`, line 3401). The fallback closure no longer bumps before calling it. Total: 1 bump.
- **view-mode fallback**: `launchExtension` does not bump internally (confirmed: no `frecency.bump` in its body). The fallback closure now bumps in the `else` branch immediately before calling `launchExtension`. Total: 1 bump.
- **non-fallback launches** (normal command rows): unchanged — they bump via their own closures or via `perform()`/`runNoViewExtension` as before.

### Build tail

```
[5/7] Linking invoke
[6/7] Applying invoke
Build complete! (3.40s)
```
