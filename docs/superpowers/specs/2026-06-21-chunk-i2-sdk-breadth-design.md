# Chunk I2 — P2 SDK breadth (named-type exports + real environment fields) Design

**Part of the autonomous Raycast-parity push** (`[[autonomous-parity-goal]]`). A P2 "safe breadth" sub-chunk. Closes two `RAYCASTVSINVOKE.md` §12 P2 items:
- Export remaining named types/enums: `Preferences`/`PreferenceValues`, `Form.Values`, `Keyboard.KeyModifier`/`KeyEquivalent`, `Navigation`, `LaunchProps` (the doc lists `Cache.*`/`Preferences`/`Form.Values`/`KeyModifier`/`Navigation`/`LaunchContext` — `Cache` is already an exported class).
- Real `environment` fields: `appearance`/`textSize` reflecting the host (not hardcoded), and `canAccess` returning a real value.

## Global constraints
- Faithful parity; canonical Raycast type shapes only. Don't fabricate brands.
- Commit on `main`. Relaunch after build.
- No Xcode/XCTest → TS via `npx tsc --noEmit`; Swift via `swift build --package-path apps/macos`; runtime via fixture/relaunch/log.

---

## Item 1 — Named-type exports (pure TS, `packages/api`)

**Current:** `Cache` (class), `Application`, `Accessory`, `CommonActionProps`, `ColorDynamic`, `OAuth*`, `BrowserExtensionTab`, `AIAskOptions` are exported; but several types Raycast extensions `import type {…}` are NOT: `LaunchProps`, `Form.Values`, `Preferences`/`PreferenceValues`, `Navigation`, `Keyboard.KeyModifier`/`KeyEquivalent`.

**Design:** add these exported TS types (no runtime — pure `export type`/`export interface`), matching Raycast's shapes:
- `export interface LaunchProps<T = { arguments?: Record<string, string>; launchContext?: Record<string, unknown>; fallbackText?: string }> { arguments: …; launchType: string; launchContext?: …; fallbackText?: string }` — match the `launchProps` object the child already builds (`runtime/node-host/src/child.ts` ~138-144) so the type and runtime agree.
- `Form.Values`: `export interface FormValues { [id: string]: any }` and attach as `Form.Values` (a type member on the `Form` namespace/type) — extensions write `Form.Values`. (If `Form` is a value with a `.Values` type member is awkward in TS; export a top-level `FormValues` AND, if feasible, a `Form.Values` type alias — match how `Form` is currently typed.)
- `export type PreferenceValues = Record<string, any>` and `export interface Preferences {}` (augmentable, Raycast's empty base interface extensions augment via module declaration). `getPreferenceValues<T>` already exists; type it `<T = PreferenceValues>`.
- `export type Navigation = { push: (view: ReactNode) => void; pop: () => void }` and type `useNavigation(): Navigation`.
- `Keyboard.KeyModifier = "cmd" | "ctrl" | "opt" | "shift"`; `Keyboard.KeyEquivalent = string` (Raycast's full union is large; a `string` alias is acceptable + honest) — attach to the exported `Keyboard` namespace alongside `Shortcut`.
- These must not break existing exports; verify `tsc --noEmit` clean across `packages/api` + the examples.

## Item 2 — Real `environment` fields

**Current:** `environment` (`packages/api/src/index.ts:752`) has `appearance: "dark"` (hardcoded), `textSize: "medium"` (hardcoded), `canAccess: () => false` (stub); `extensionName`/`commandName` already read env vars.

**Design:**
- **Swift (`ExtensionHost.swift` ~146-165, the spawn env):** the host passes the real values at spawn — `env["INVOKE_APPEARANCE"] = <NSApp.effectiveAppearance dark/aqua → "dark"/"light">`, `env["INVOKE_TEXT_SIZE"] = "medium"` (macOS has no per-app text-size like iOS; "medium" is the honest default — pass it for forward-compat), and `env["INVOKE_CAN_ACCESS_AI"] = <AI configured ? "1" : "0">`. The appearance + AI-availability are known to `AppController` (`NSApp.effectiveAppearance`, `ai.hasKey`) — thread them into the `ExtensionHost.launch(...)` env construction (add params or read from a host-provided closure). (Note: appearance is a spawn-time snapshot — a live appearance change mid-run isn't pushed to `environment.appearance`; image dispatch already reads live appearance host-side. Acceptable; note it.)
- **api (`environment`):** `appearance: (process.env.INVOKE_APPEARANCE as "dark"|"light") ?? "dark"`; `textSize: (process.env.INVOKE_TEXT_SIZE as "medium"|"large") ?? "medium"`; `canAccess: (_api) => process.env.INVOKE_CAN_ACCESS_AI === "1"` (AI is the API extensions gate on; honest for that case — a crude-but-real improvement over always-false). Keep `extensionName`/`ownerOrAuthorName` as-is (already env-backed).

## Item 3 — Fixture + verify

- `examples/env-demo/` (manifest mirrors `examples/empty-action-demo`): a `Detail` rendering `environment.appearance`, `environment.textSize`, `environment.commandName`, `environment.canAccess?.(AI)`, and the `LaunchProps`-typed default export signature (proving the types compile). Plus a `.ts` import line exercising the new `import type { LaunchProps, PreferenceValues, Navigation } from "@raycast/api"` (typecheck proves the exports).
- Verify: typecheck clean; `scripts/build-app.sh`; relaunch; `/tmp/invoke-run.log` shows the fixture loaded; the Detail shows `appearance` matching the actual system appearance (proves real, not hardcoded "dark" — switch the system to light and it should read "light").

## Testing strategy
- **Pure (`tsc`):** the type exports — a standalone `.ts` that `import type`s each new type + uses it; `tsc --noEmit` is the gate.
- **Integration:** real `environment.appearance` via fixture + relaunch + visual (the Detail shows the live appearance).

## Out of scope (tracked elsewhere)
- Fallback commands + `disabledByDefault` (manifest/launch-routing — separate, more involved; not this chunk).
- Live appearance-change push to `environment.appearance` (spawn-time snapshot only).
- `canAccess` for non-AI APIs (AI is the only one extensions commonly gate on).
- Augmentable `Preferences` via the extension's own `.d.ts` (we export the base interface; per-extension augmentation is the extension's concern).
