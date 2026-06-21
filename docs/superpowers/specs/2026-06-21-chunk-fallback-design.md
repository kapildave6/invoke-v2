# Chunk Fallback — fallback commands + disabledByDefault Design

**Part of the autonomous Raycast-parity push** (`[[autonomous-parity-goal]]`). Closes the P2 "Fallback commands; `disabledByDefault`" item. **UX signed off by the user:** fallbacks appear **only on no-match**; the rest of the proposed design (disabledByDefault via an `enabledCommands` opt-in set, a Fallback section in the Commands settings pane, fallbackText wiring) approved.

## Global constraints
- World-class Raycast-quality UX; commit on `main`; relaunch after build.
- No Xcode/XCTest → Swift via `swift build --package-path apps/macos` + relaunch/log + human visual; TS via tsc.
- Reuse existing infra: `AppSettings.disabledCommands`/`isEnabled(id)`, the `CommandsPane` Settings UI, `RootCommand`, `discoverExtensionCommands`, `ExtensionHost` env, `child.ts launchProps`.

## Item 1 — `disabledByDefault`
**Current:** `matchCommands` (`AppController.swift:1159`) filters `commands.filter { settings.isEnabled($0.id) }`; `isEnabled(id) = !disabledCommands.contains(id)` (opt-out). Manifest `disabledByDefault` is not parsed; a `disabledByDefault` command shows by default (wrong — Raycast hides it until enabled).
**Design:**
- Parse `disabledByDefault` (bool) from each command's manifest in `discoverExtensionCommands`; add `disabledByDefault: Bool = false` to `RootCommand`.
- Add `AppSettings.enabledCommands: Set<String>` (opt-in, persisted like `disabledCommands`).
- New effective check `AppSettings.commandEnabled(id, disabledByDefault:) -> Bool`: `disabledByDefault ? enabledCommands.contains(id) : !disabledCommands.contains(id)`. Use it in `matchCommands` + the suggestion/root list (`suggestionItems`) so disabled-by-default commands are hidden until enabled.
- **Settings (`CommandsPane`):** the existing Enabled toggle must bind to the correct set per the command's `disabledByDefault`. The `CommandInfo`/row model needs the `disabledByDefault` flag (thread it from the manifest into the Settings command metadata). Toggle ON: normal → remove from `disabledCommands`; disabledByDefault → add to `enabledCommands`. Toggle OFF: inverse. (So a disabledByDefault command shows OFF + the user flips it ON, persisting in `enabledCommands`.)

## Item 2 — Fallback commands: persistence + Settings UI
- Add `AppSettings.fallbackCommands: [String]` (ORDERED command ids, persisted).
- **`CommandsPane` "Fallback Commands" section:** a labeled section (above or below the command groups) listing the chosen fallbacks in order, each with remove + reorder (up/down buttons — SwiftUI `.onMove` in a List, or up/down buttons for simplicity), and an "Add Fallback Command…" control (a menu/picker over fallback-eligible commands NOT already added). **Fallback-eligible** = any extension `view`/`no-view` command + relevant built-ins that take a query meaningfully (e.g. Ask AI). (Exclude menu-bar/background commands + apps.) World-class: clean section, matches the pane's style.

## Item 3 — Root no-match integration + `fallbackText` wiring
- **Root behavior (`renderRoot`/`onSearch`):** when `mode == .root`, the query is non-empty, AND there is NO command match (`matchCommands(query).isEmpty`) AND no application match, append the user's `fallbackCommands` (resolved to their `RootCommand`s) as rows at the BOTTOM, each labeled to show the query — e.g. title `"Ask AI"` with a subtitle/accessory showing `"…"` + the query, or Raycast-style `"<title>"` row whose run uses the query. (Keep it visually a "fallback" affordance — e.g. a trailing accessory `"Fallback"` or the query echoed.) If `fallbackCommands` is empty, no change.
- **Launch with fallbackText:** activating a fallback row launches that command's extension WITH `fallbackText = currentQuery`. Thread a `fallbackText` param through the extension-launch path (`launchExtension(...)` → `ExtensionHost` env `INVOKE_FALLBACK_TEXT`). For built-in fallbacks (Ask AI), pass the query as their input directly (no env needed).
- **`child.ts`:** add `fallbackText: process.env.INVOKE_FALLBACK_TEXT || undefined` to `launchProps` (line 145). `LaunchProps.fallbackText` type already exists.
- **Host (`ExtensionHost`):** set `env["INVOKE_FALLBACK_TEXT"]` from the launch param (only for a fallback launch; empty/unset otherwise).

## Item 4 — Fixture + verify
- `examples/fallback-demo/` (manifest mirrors `examples/empty-action-demo`): a `view` command (mark `disabledByDefault: true` on a SECOND command to exercise that) whose default export reads `props.fallbackText` and renders it (e.g. a Detail showing "Fallback text: <text>"), proving the query arrives. The user adds it as a fallback in Settings, types a no-match query, and selects it.
- Verify: typecheck; `scripts/build-app.sh`; relaunch; `/tmp/invoke-run.log` shows the commands (the disabledByDefault one hidden from root until enabled). Human visual: a no-match query shows the fallback row; selecting it opens the command with `fallbackText` = the query; the disabledByDefault command is absent from root until toggled on in Settings.

## Testing strategy
- **Pure (if extractable):** `commandEnabled(id, disabledByDefault:)` truth table (standalone or inline).
- **AppKit/SwiftUI + integration:** Settings Fallback section, root no-match rows, fallbackText round-trip → build + relaunch + human visual (the Settings UI + root behavior need eyes).

## Out of scope
- Reordering via drag (`onMove`) if fiddly → up/down buttons acceptable.
- Fallback for apps/non-extension targets beyond the built-ins chosen.
- Per-extension "this command can be a fallback" manifest opt-in (Raycast lets the user add most commands; we allow view/no-view + built-ins).
