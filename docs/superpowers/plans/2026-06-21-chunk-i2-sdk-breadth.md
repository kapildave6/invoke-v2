# Chunk I2 — P2 SDK breadth Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development.

**Goal:** Export the remaining named TS types and make `environment.appearance`/`textSize`/`canAccess` real (host-provided).

**Architecture:** Item 1 is pure-TS `export type`/`interface` additions in `packages/api`. Item 2 has the Swift host pass real env vars at spawn + the api read them.

**Tech Stack:** TS (`packages/api`), Swift (`apps/macos`), TS fixture.

## Global Constraints
- Faithful parity (canonical Raycast type shapes); commit on `main`; relaunch after build.
- No Xcode/XCTest: `npx tsc --noEmit` + `swift build --package-path apps/macos` + fixture/relaunch/log.
- Ignore SourceKit false-positives when `swift build` succeeds.

---

### Task 1: Named-type exports

**Files:** Modify `packages/api/src/index.ts`. Create (test): `<scratchpad>/types-test.ts`.

- [ ] **Step 1: Add the exported types.** Add (no runtime — pure types), matching Raycast shapes + the runtime objects already built:
```ts
/** Raycast LaunchProps — command arguments + launch metadata the host passes (see child.ts launchProps). */
export interface LaunchProps<A extends Record<string, string> = Record<string, string>> {
  arguments: A;
  launchType: string;
  launchContext?: Record<string, unknown>;
  fallbackText?: string;
}
export type PreferenceValues = Record<string, unknown>;
/** Augmentable base (extensions extend `Preferences` via `declare module "@raycast/api"`). */
export interface Preferences {}
export type Navigation = { push: (view: ReactNode) => void; pop: () => void };
export type FormValues = { [id: string]: unknown };
```
Attach `Form.Values` + `Keyboard.KeyModifier`/`KeyEquivalent` to their namespaces (read how `Form` and `Keyboard` are currently typed/declared and mirror it):
- `Form.Values` → a type member equal to `FormValues` (if `Form` is a value with a companion `namespace Form { export type Values = FormValues }`, add that; else export `FormValues` and alias).
- `Keyboard.KeyModifier = "cmd" | "ctrl" | "opt" | "shift"`, `Keyboard.KeyEquivalent = string` — add to the `Keyboard` namespace alongside `Shortcut`.
Type `useNavigation(): Navigation` and `getPreferenceValues<T = PreferenceValues>()`.

- [ ] **Step 2: Standalone type test.** Create `<scratchpad>/types-test.ts` that `import type { LaunchProps, PreferenceValues, Preferences, Navigation, FormValues } from "<abs path>/packages/api/src/index.ts"` and uses each in a typed position (e.g. `const n: Navigation = null as any; const p: PreferenceValues = {};` etc.). Run `cd packages/api && npx tsc --noEmit <scratchpad>/types-test.ts` style check — OR simply rely on the repo `tsc --noEmit` after adding a usage in the fixture (Task 3). The gate is `tsc --noEmit` clean.

- [ ] **Step 3: typecheck.** `cd packages/api && npx tsc --noEmit 2>&1 | tail -8` → clean (one pre-existing unrelated `accessory-demo` error OK). Also typecheck an example that imports the api to ensure no export breakage.

- [ ] **Step 4: Commit.**
```bash
git add packages/api/src/index.ts
git commit -m "feat(types): export LaunchProps / PreferenceValues / Preferences / Navigation / Form.Values / Keyboard.KeyModifier"
```

---

### Task 2: Real `environment` fields

**Files:** Modify `apps/macos/Sources/InvokeShell/ExtensionHost.swift` (spawn env ~146-165), `packages/api/src/index.ts` (`environment` ~752). Possibly `AppController.swift` if `canAccessAI` must be threaded.

- [ ] **Step 1: Swift — pass real env vars at spawn.** In `ExtensionHost`'s env construction (~146-165), add:
```swift
        let dark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        env["INVOKE_APPEARANCE"] = dark ? "dark" : "light"
        env["INVOKE_TEXT_SIZE"] = "medium"
```
For `INVOKE_CAN_ACCESS_AI`: set `env["INVOKE_CAN_ACCESS_AI"]` from whether AI is configured. SOURCE it the cleanest available way — read how `ExtensionHost` is constructed/called: if `AppController` (which knows `ai.hasKey`) can pass it, add a `canAccessAI: Bool` field/param the host sets (default `false`); OR if `AppController` sets a process env `INVOKE_CAN_ACCESS_AI` at startup that the child inherits, leave the host to not override it. Pick the minimal-ripple option and state it in the report. (Appearance is the primary win; AI access is best-effort.)

- [ ] **Step 2: api — read the real values.** In `environment` (`:752`), change:
```ts
  appearance: ((process.env.INVOKE_APPEARANCE as "dark" | "light") || "dark"),
  ...
  textSize: ((process.env.INVOKE_TEXT_SIZE as "medium" | "large") || "medium"),
  ...
  canAccess: (_api: unknown): boolean => process.env.INVOKE_CAN_ACCESS_AI === "1",
```
(Keep the rest of `environment` unchanged.)

- [ ] **Step 3: typecheck + build.** `cd packages/api && npx tsc --noEmit | tail -5`; `swift build --package-path apps/macos | tail -10`.

- [ ] **Step 4: Commit.**
```bash
git add apps/macos/Sources/InvokeShell/ExtensionHost.swift packages/api/src/index.ts apps/macos/Sources/InvokeShell/AppController.swift
git commit -m "feat(environment): real appearance/textSize from host + canAccess(AI) from config"
```

---

### Task 3: Fixture (`env-demo`) + verify

**Files:** Create `examples/env-demo/package.json`, `examples/env-demo/src/env.tsx` (filename = command name `env`).

- [ ] **Step 1: Read `examples/empty-action-demo/package.json`** and mirror (one `view` command `env`).
- [ ] **Step 2: `package.json`** (command `env` mode view).
- [ ] **Step 3: `src/env.tsx`** — render the environment + use the new types:
```tsx
import { Detail, environment, type LaunchProps, type Navigation, type PreferenceValues } from "@raycast/api";

export default function Env(_props: LaunchProps) {
  const _n: Navigation | null = null; // type-only use (proves export)
  const _p: PreferenceValues = {};
  const md = [
    `# Environment`,
    `- appearance: \`${environment.appearance}\``,
    `- textSize: \`${environment.textSize}\``,
    `- commandName: \`${environment.commandName}\``,
    `- extensionName: \`${environment.extensionName}\``,
    `- canAccess(AI): \`${String((environment as { canAccess?: (a: unknown) => boolean }).canAccess?.(null))}\``,
  ].join("\n");
  return <Detail markdown={md} />;
}
```
(Confirm `LaunchProps`/`Navigation`/`PreferenceValues` are exported by Task 1 + `type`-imported correctly.)

- [ ] **Step 4: Typecheck** the fixture per the examples' norm (this is also the real test of Task 1's exports).
- [ ] **Step 5: Build + relaunch + log.** `scripts/build-app.sh 2>&1 | tail -5`; relaunch; `tail -40 /tmp/invoke-run.log` → fixture loaded, no error.
- [ ] **Step 6: Human visual checklist (record):** the Detail shows `appearance` matching the actual system appearance (toggle system Dark/Light and it should read accordingly — proves it's real, not hardcoded "dark"); `canAccess(AI)` reads `true` iff an Anthropic key is configured.
- [ ] **Step 7: Commit.**
```bash
git add examples/env-demo
git commit -m "test(fixture): env-demo shows real environment + uses LaunchProps/Navigation/PreferenceValues types"
```

---

## Self-Review

**1. Spec coverage:** type exports → Task 1; real environment → Task 2; fixture (+ the real typecheck of the exports) → Task 3. ✅

**2. Placeholder scan:** Concrete code for the types, env vars, and `environment` reads. The `NOTE`s (Form/Keyboard namespace idiom, canAccessAI sourcing) are read-the-code decisions — explicit.

**3. Type/identifier consistency:** `LaunchProps`/`PreferenceValues`/`Navigation`/`FormValues` (Task 1) used in the fixture (Task 3); `environment` reads (Task 2) consume the env vars set in Task 2 Step 1.

**Known risk (final-review triage):** (a) `environment.appearance` is a spawn-time snapshot — won't live-update on a mid-run appearance change (image dispatch already reads live appearance host-side; this is the child-side env field). (b) `canAccess` returns the AI flag for ANY api arg (can't distinguish which API was passed) — honest for the common AI case, crude for others. (c) `Form.Values`/`Keyboard.KeyModifier` namespace attachment must match how `Form`/`Keyboard` are declared (value+namespace merge) — verify `tsc` accepts it.
