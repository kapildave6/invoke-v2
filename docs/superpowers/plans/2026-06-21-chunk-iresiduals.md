# Chunk I-residuals — type exports + env secret-scrub Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development.

**Goal:** Export `LaunchContext`/`Form.Event`/`Image.ImageLike` types; scrub `ANTHROPIC_API_KEY` from the spawned extension child's env.

**Tech Stack:** TS (`packages/api`), Swift (`apps/macos`).

## Global Constraints
- Faithful parity (canonical Raycast shapes); **org security: never expose the AI secret to extensions**; commit on `main`.
- No Xcode/XCTest: `npx tsc --noEmit` + `swift build --package-path apps/macos`. Ignore SourceKit false-positives.

---

### Task 1: Named-type exports

**Files:** Modify `packages/api/src/index.ts`. Create test: `<scratchpad>/residual-types-test.ts`.

- [ ] **Step 1: Add the types.**
```ts
export type LaunchContext = Record<string, unknown>;
export interface FormEvent<T = unknown> { target: { id: string; value?: T } }
```
Attach to namespaces via the established `export declare namespace` merge (mirror `Form.Values`/`Keyboard.KeyModifier`/`MenuBarExtra.ActionEvent` — read one first):
```ts
export declare namespace Form { export type Event<T = unknown> = FormEvent<T>; /* (keep existing Values) */ }
export declare namespace Image {
  export type ImageLike = string | { source?: string; tintColor?: string; mask?: string; fileIcon?: string };
  export type Source = string | { light: string; dark: string };
}
```
(IMPORTANT: `Form` already has an `export declare namespace Form { export type Values = … }` from a prior chunk — ADD `Event` to that SAME namespace block, don't create a second conflicting one. Same care for any existing `Image` namespace. `const Image` already has `Mask` at runtime; the namespace merge adds TYPES only.)

- [ ] **Step 2: Type-import usage test.** `<scratchpad>/residual-types-test.ts` (import from the abs path to `packages/api/src/index.ts`):
```ts
import type { LaunchContext, Form, Image } from "<abs>/packages/api/src/index.ts";
const _lc: LaunchContext = { a: 1 };
const _fe: Form.Event<string> = { target: { id: "x", value: "v" } };
const _il: Image.ImageLike = { source: "x", tintColor: "blue" };
const _il2: Image.ImageLike = "icon-name";
const _is: Image.Source = { light: "a", dark: "b" };
void _lc; void _fe; void _il; void _il2; void _is;
```
Run `cd packages/api && npx tsc --noEmit <scratchpad>/residual-types-test.ts` — OR just rely on the repo `tsc --noEmit` after adding the usages (the gate). Confirm all resolve (no TS2503/2305).

- [ ] **Step 3: typecheck.** `cd packages/api && npx tsc --noEmit 2>&1 | tail -8` → clean (pre-existing `accessory-demo` error OK).

- [ ] **Step 4: Commit.**
```bash
git add packages/api/src/index.ts
git commit -m "feat(types): export LaunchContext + Form.Event + Image.ImageLike/Source"
```

---

### Task 2: Scrub `ANTHROPIC_API_KEY` from the child env

**Files:** Modify `apps/macos/Sources/InvokeShell/ExtensionHost.swift` (env construction ~147).

- [ ] **Step 1: Scrub the secret.** Immediately after `var env = ProcessInfo.processInfo.environment` (~147), add:
```swift
        // Security: the host's AI key must never be readable by a (possibly unsandboxed) extension.
        // AI is reached via the gated ai.ask RPC, which runs in the host — the child never needs the key.
        env["ANTHROPIC_API_KEY"] = nil
```
(Search the codebase for any OTHER host-only secret env var the host reads — e.g. another `*_API_KEY` or token the host uses internally — and scrub those too if found. Do NOT scrub general env or the extension's own preferences, which arrive via `INVOKE_PREFERENCES`. Keep the denylist to genuine host secrets; `ANTHROPIC_API_KEY` is the known one.)

- [ ] **Step 2: Confirm host AI is unaffected.** Read `AIService` (or wherever the host reads the key) — confirm it reads `ANTHROPIC_API_KEY` (or the Keychain) in the HOST process, NOT via a child. The scrub only removes the CHILD's inherited copy, so host-side `AI.ask`/`useAI` still work. State this in the report.

- [ ] **Step 3: Build.** `swift build --package-path apps/macos 2>&1 | tail -10` → `Build complete!`.

- [ ] **Step 4: Commit.**
```bash
git add apps/macos/Sources/InvokeShell/ExtensionHost.swift
git commit -m "fix(security): scrub ANTHROPIC_API_KEY from the spawned extension child env"
```

---

## Self-Review

**1. Spec coverage:** type exports → Task 1; env secret-scrub → Task 2. ✅ (No fixture: types tsc-gated; scrub verified by code inspection + build + the host-AI-unaffected reasoning — and we deliberately do NOT fixture/log the secret.)

**2. Placeholder scan:** Concrete code for both. The `NOTE`s (existing Form/Image namespace merge; other-secret search) are read-the-code checks.

**3. Consistency:** `Form.Event` added to the EXISTING `Form` namespace (not a duplicate); `Image` namespace types added alongside the runtime `Mask`. Scrub is one line + an optional denylist.

**Known risk (final-review triage):** (a) if a SECOND `export declare namespace Form`/`Image` block is added instead of merging into the existing one, TS may error or the existing members vanish — verify the merge extends the existing block. (b) Over-scrubbing the env could break extensions that rely on inherited env — scope strictly to `ANTHROPIC_API_KEY` (+ confirmed host secrets), not a broad wipe. (c) Confirm no host code path relies on the CHILD seeing `ANTHROPIC_API_KEY` (it shouldn't — AI is host-side RPC).
