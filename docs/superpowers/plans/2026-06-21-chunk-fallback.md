# Chunk Fallback — fallback commands + disabledByDefault Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development.

**Goal:** Hide `disabledByDefault` commands until enabled; let the user curate fallback commands shown on a no-match root search, passing the query as `LaunchProps.fallbackText`.

**Architecture:** `disabledByDefault` via an `AppSettings` registry consulted by the existing `isEnabled`/`setEnabled` (so `matchCommands` + the Commands toggle work unchanged). Fallback = an ordered `AppSettings.fallbackCommands` + a Settings section + a `renderRoot` no-match branch + a `fallbackText` launch param → `INVOKE_FALLBACK_TEXT` → `child.ts launchProps`.

**Tech Stack:** Swift/AppKit/SwiftUI (`apps/macos`), TS (`runtime/node-host`, `packages/api`), TS fixture.

## Global Constraints
- World-class Raycast-quality UX (Settings section + root rows clean); commit on `main`; relaunch after build.
- No Xcode/XCTest: `swift build --package-path apps/macos` + relaunch/log + human visual; `npx tsc --noEmit`.
- Ignore SourceKit false-positives. UX signed off: fallbacks **only on no-match**.

---

### Task 1: `disabledByDefault` (registry-backed, minimal ripple)

**Files:** Modify `apps/macos/Sources/InvokeShell/AppSettings.swift` (~26, 166-170), `apps/macos/Sources/InvokeShell/AppController.swift` (`RootCommand` ~156; `discoverExtensionCommands` command-building branches ~3110-3145; register ids after discovery).

- [ ] **Step 1: AppSettings — opt-in set + registry + consult in isEnabled/setEnabled.**
```swift
    // Commands the user has explicitly ENABLED (opt-in), for disabledByDefault commands. (disabledCommands
    // remains the opt-OUT set for normal commands.)
    @Published public var enabledCommands: Set<String> { didSet { d.set(Array(enabledCommands), forKey: "enabledCommands") } }
    // NON-persisted registry of command ids whose manifest sets disabledByDefault: true (set by AppController
    // each discovery). isEnabled/setEnabled consult it so callers don't need the flag.
    public var disabledByDefaultIds: Set<String> = []
```
Load `enabledCommands` in init: `enabledCommands = Set((d.array(forKey: "enabledCommands") as? [String]) ?? [])`. Then:
```swift
    public func isEnabled(_ commandID: String) -> Bool {
        disabledByDefaultIds.contains(commandID) ? enabledCommands.contains(commandID) : !disabledCommands.contains(commandID)
    }
    public func setEnabled(_ commandID: String, _ enabled: Bool) {
        if disabledByDefaultIds.contains(commandID) {
            if enabled { enabledCommands.insert(commandID) } else { enabledCommands.remove(commandID) }
        } else {
            if enabled { disabledCommands.remove(commandID) } else { disabledCommands.insert(commandID) }
        }
    }
```

- [ ] **Step 2: RootCommand flag + parse + register.** Add `var disabledByDefault: Bool = false` to `RootCommand`. In `discoverExtensionCommands`, where each view/no-view command's `RootCommand` is built (the branches that read the command dict `c`), set `disabledByDefault: (c["disabledByDefault"] as? Bool) ?? false`. After `out` is fully built (end of `discoverExtensionCommands`, before `return out`), register: `AppSettings.shared.disabledByDefaultIds = Set(out.filter { $0.disabledByDefault }.map { $0.id })`. (matchCommands' `settings.isEnabled($0.id)` now correctly hides disabledByDefault commands not in enabledCommands; the CommandsPane toggle works unchanged.)

- [ ] **Step 3: Build.** `swift build --package-path apps/macos 2>&1 | tail -10` → `Build complete!`.

- [ ] **Step 4: Commit.**
```bash
git add apps/macos/Sources/InvokeShell/AppSettings.swift apps/macos/Sources/InvokeShell/AppController.swift
git commit -m "feat(commands): disabledByDefault — hidden until enabled (enabledCommands opt-in registry)"
```

---

### Task 2: Fallback persistence + Settings "Fallback Commands" section

**Files:** Modify `apps/macos/Sources/InvokeShell/AppSettings.swift` (add `fallbackCommands`), `apps/macos/Sources/InvokeShell/SettingsView.swift` (`CommandsPane` — add a Fallback section).

- [ ] **Step 1: AppSettings — ordered fallback list.**
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
Load in init: `fallbackCommands = (d.array(forKey: "fallbackCommands") as? [String]) ?? []`.

- [ ] **Step 2: SettingsView — "Fallback Commands" section in `CommandsPane`.** Read the `CommandsPane` body + `CommandInfo` model first. Add a section (above or below the command groups) that:
  - Renders the current `settings.fallbackCommands` IN ORDER, resolving each id to its `CommandInfo` (title/icon) — a row per fallback with: the title/icon, up/down buttons (`settings.moveFallback(id, up:)`), and a remove (✕) button (`settings.removeFallback(id)`).
  - An "Add Fallback Command…" `Menu`/picker listing fallback-ELIGIBLE commands NOT already in the list — eligible = the Settings command metadata for view/no-view extension commands + the built-ins that take a query (e.g. "Ask AI"). (Reuse the command metadata `CommandsPane` already has; exclude menu-bar/background + already-added.)
  - Title the section "Fallback Commands" with a one-line caption ("Shown when a search has no results; the query is passed to the command."). Match the pane's existing styling (fonts/insets) — world-class, not janky.
  - The `CommandInfo` list the pane builds is the source of titles/ids; if it doesn't already expose enough (id+title+icon+kind), thread what's needed.

- [ ] **Step 3: Build.** `swift build --package-path apps/macos 2>&1 | tail -10` → `Build complete!`.

- [ ] **Step 4: Commit.**
```bash
git add apps/macos/Sources/InvokeShell/AppSettings.swift apps/macos/Sources/InvokeShell/SettingsView.swift
git commit -m "feat(fallback): persist ordered fallbackCommands + Settings Fallback Commands section"
```

---

### Task 3: Root no-match integration + `fallbackText` wiring

**Files:** Modify `apps/macos/Sources/InvokeShell/AppController.swift` (`renderRoot`/`onSearch` no-match branch; `launchExtension` ~3272 + a fallback-launch path), `apps/macos/Sources/InvokeShell/ExtensionHost.swift` (env), `runtime/node-host/src/child.ts` (~145).

- [ ] **Step 1: child.ts — fallbackText in launchProps.** Change (line ~145):
```ts
  const launchProps = { arguments: launchArguments, launchType: process.env.INVOKE_LAUNCH_TYPE || "userInitiated", launchContext, fallbackText: process.env.INVOKE_FALLBACK_TEXT || undefined };
```

- [ ] **Step 2: ExtensionHost — INVOKE_FALLBACK_TEXT.** In `ExtensionHost.launch(...)`, add a `fallbackText: String = ""` parameter; in the env block set `if !fallbackText.isEmpty { env["INVOKE_FALLBACK_TEXT"] = fallbackText }`.

- [ ] **Step 3: launchExtension — thread fallbackText.** Add `fallbackText: String = ""` to `launchExtension(...)` (`:3272`) and pass it to `h.launch(... fallbackText: fallbackText)`. Existing callers default to "".

- [ ] **Step 4: renderRoot — append fallback rows on no-match.** In the root render path, after computing the normal command/app matches for a non-empty query: if `mode == .root`, the query is non-empty, AND there are NO command matches (`matchCommands(query).isEmpty`) AND no app matches, append rows for each id in `settings.fallbackCommands` (resolved to its `RootCommand`/extension-launch info — use the `extLaunchables` map or the `commands`/discovered list). Each fallback row shows the command title + an accessory/subtitle echoing the query (e.g. a trailing `"Fallback"` tag or the query text). Read how root rows are built (`itemNode`, `suggestionItems`, the matched-list rendering) and append the fallback rows in the same shape at the BOTTOM. Store enough per fallback row so activating it knows the command's launch info + that it's a fallback (so the activation passes `fallbackText = lastQuery`).

- [ ] **Step 5: Fallback activation launches with fallbackText.** When a fallback row is activated, launch its extension command via `launchExtension(... fallbackText: lastQuery)` (or, for a built-in fallback like Ask AI, pass `lastQuery` as the input directly). Wire this through the existing row-activation path (the fallback row's `commandId`/run resolves to a fallback launch). Confirm a NON-fallback launch still passes `fallbackText: ""` (default).

- [ ] **Step 6: typecheck + build.** `cd packages/api && npx tsc --noEmit | tail -3` (no change there, but confirm); `cd runtime/node-host && npx tsc --noEmit | tail -3` if it has a tsconfig; `swift build --package-path apps/macos 2>&1 | tail -10` → `Build complete!`.

- [ ] **Step 7: Commit.**
```bash
git add apps/macos/Sources/InvokeShell/AppController.swift apps/macos/Sources/InvokeShell/ExtensionHost.swift runtime/node-host/src/child.ts
git commit -m "feat(fallback): root no-match shows fallback commands + passes query as LaunchProps.fallbackText"
```

---

### Task 4: Fixture (`fallback-demo`) + verify

**Files:** Create `examples/fallback-demo/package.json` (TWO commands: `fallback-demo` view + a second `hidden-cmd` with `disabledByDefault: true`), `examples/fallback-demo/src/fallback-demo.tsx`, `examples/fallback-demo/src/hidden-cmd.tsx`.

- [ ] **Step 1: Read `examples/empty-action-demo/package.json`** + mirror. `package.json` commands:
```json
  "commands": [
    { "name": "fallback-demo", "title": "Fallback Demo", "description": "Reads LaunchProps.fallbackText", "mode": "view" },
    { "name": "hidden-cmd", "title": "Hidden Command", "description": "disabledByDefault — hidden until enabled", "mode": "view", "disabledByDefault": true }
  ],
```
- [ ] **Step 2: `src/fallback-demo.tsx`** — reads `props.fallbackText`:
```tsx
import { Detail, type LaunchProps } from "@raycast/api";
export default function FallbackDemo(props: LaunchProps) {
  const t = props.fallbackText;
  return <Detail markdown={`# Fallback Demo\n\nfallbackText: \`${t ?? "(none)"}\``} />;
}
```
- [ ] **Step 3: `src/hidden-cmd.tsx`** — a trivial `<Detail markdown="Hidden command (was disabledByDefault)" />`.
- [ ] **Step 4: Typecheck** the fixture.
- [ ] **Step 5: Build + relaunch + log.** `scripts/build-app.sh 2>&1 | tail -5`; relaunch; `tail -40 /tmp/invoke-run.log` → commands discovered; the `hidden-cmd` should be ABSENT from the root list (disabledByDefault) until enabled.
- [ ] **Step 6: Human visual checklist (record):** (a) "Hidden Command" does NOT appear in root search by default; enabling it in Settings → Commands makes it appear. (b) Add "Fallback Demo" as a fallback in Settings → Commands → Fallback Commands. (c) Type a no-match query (e.g. "zzzqqq") → "Fallback Demo" appears at the bottom; selecting it opens the Detail showing `fallbackText: zzzqqq`.
- [ ] **Step 7: Commit.**
```bash
git add examples/fallback-demo
git commit -m "test(fixture): fallback-demo (fallbackText + disabledByDefault hidden command)"
```

---

## Self-Review

**1. Spec coverage:** disabledByDefault → Task 1; fallback persistence + Settings → Task 2; root no-match + fallbackText → Task 3; fixture → Task 4. ✅

**2. Placeholder scan:** Concrete code for AppSettings (Task 1/2), child.ts/ExtensionHost (Task 3 Steps 1-3), fixture (Task 4). The SwiftUI Fallback section (Task 2 Step 2) + the renderRoot no-match branch + fallback activation (Task 3 Steps 4-5) are read-the-existing-code-and-match instructions — concrete in WHAT, with the existing `CommandsPane`/`renderRoot`/`itemNode`/`extLaunchables` as the integration points (can't fully inline SwiftUI without the surrounding code).

**3. Type/identifier consistency:** `enabledCommands`/`disabledByDefaultIds`/`isEnabled`/`setEnabled` (Task 1) — `isEnabled`/`setEnabled` callers unchanged. `fallbackCommands`/`addFallback`/`removeFallback`/`moveFallback` (Task 2) used by the Settings section + renderRoot (Task 3). `launchExtension(... fallbackText:)` (Task 3) → `ExtensionHost.launch(... fallbackText:)` → `INVOKE_FALLBACK_TEXT` → `child.ts launchProps.fallbackText` (type already exported, Chunk I-residuals).

**Known risks (final-review triage):** (a) the no-match detection must match how `renderRoot` ACTUALLY decides emptiness (apps + commands) — verify it triggers only when truly no match, not on partial. (b) fallback activation must pass `lastQuery` as fallbackText AND a non-fallback launch must NOT (default ""). (c) the disabledByDefault registry is set each discovery (non-persisted) — ensure it's set BEFORE the root list / Settings read `isEnabled` (discovery runs at startup; confirm ordering). (d) a disabledByDefault command added as a fallback: should it still launch as a fallback even though hidden from root? (Raycast: yes — fallbacks can be otherwise-hidden; the fallback list is independent of root visibility. Confirm the fallback row path doesn't re-filter by isEnabled.)
