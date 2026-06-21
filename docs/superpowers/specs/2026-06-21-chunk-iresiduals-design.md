# Chunk I-residuals — P2 residual mop-up (type exports + env secret-scrub) Design

**Part of the autonomous Raycast-parity push** (`[[autonomous-parity-goal]]`, P2 tail). Two bounded residuals:
- **Named-type exports** still missing: `LaunchContext`, a `Form.Event` type, `Image.ImageLike` (the canonical Image type).
- **Security hardening (opus-flagged):** scrub the host's AI key (`ANTHROPIC_API_KEY`) from the spawned extension child's environment — a trusted/unsandboxed extension shouldn't be able to read the host's secret (AI is reached via the gated `ai.ask` RPC, never the raw key).

## Global constraints
- Faithful parity (canonical Raycast type shapes); **org security: never expose the AI secret to extensions**; commit on `main`.
- No Xcode/XCTest → TS via `npx tsc --noEmit`; Swift via `swift build --package-path apps/macos`.

## Item 1 — Named-type exports
- `export type LaunchContext = Record<string, unknown>;` (the `launchContext` payload type; `LaunchProps.launchContext` already references this shape).
- `Form.Event`: Raycast form field events (`onFocus`/`onBlur`) — `export interface FormEvent<T = unknown> { target: { id: string; value?: T } }` and expose as `Form.Event` via the established `export declare namespace Form` merge (alongside `Form.Values`).
- `Image.ImageLike`: the canonical Raycast image union — via `export declare namespace Image { export type ImageLike = string | { source?: string; tintColor?: string; mask?: string; fileIcon?: string }; export type Source = string | { light: string; dark: string } }` merged with the existing `const Image` (which already has `Mask`). (This documents `tintColor`/`mask`/`fileIcon`/dynamic `source` — the "Image.tintColor as an Image prop" residual.)
- All pure types — no runtime change. Verified by `tsc --noEmit` + a `type`-import usage.

## Item 2 — Scrub the AI key from the child env
- `ExtensionHost.swift` builds the child env as `var env = ProcessInfo.processInfo.environment` (~line 147), which inherits `ANTHROPIC_API_KEY` if the host has it as an env var. **Remove it** (`env["ANTHROPIC_API_KEY"] = nil`) right after the copy, so the spawned extension can't read the host's AI secret. (Extensions use `AI.ask` → the `ai.ask` RPC, which runs in the HOST with the key — the child never needs the raw key.)
- Also scrub any other obvious host-only secret env keys if present in the codebase's known set (search for other `*_API_KEY`/token env reads the host uses); at minimum `ANTHROPIC_API_KEY`. Keep it a small denylist (don't over-scrub — extensions may legitimately need their OWN env/prefs, which arrive via `INVOKE_PREFERENCES`, not the host's process env).
- This must NOT break host-side AI: the host's `AIService` reads the key in the HOST process (unaffected); only the CHILD's inherited copy is removed.

## Verification
- **tsc:** the type exports compile + a `type`-import (`import type { LaunchContext, Form, Image } from "@raycast/api"`; use `Form.Event`, `Image.ImageLike`, `LaunchContext` in typed positions).
- **Swift build** clean; reason that host AI still works (key read in-host) + the child no longer inherits `ANTHROPIC_API_KEY`. (A fixture isn't required: types are tsc-gated; the scrub is verified by code inspection + the build — optionally a fixture logging `process.env.ANTHROPIC_API_KEY` should show undefined, but exposing that even in a fixture is a smell, so DON'T fixture the secret; verify by reasoning + the env-construction diff.)

## Out of scope (tracked / to surface)
- `disabledByDefault` + **fallback commands** — both need a Settings UI (command enable/disable + fallback-picker) → product/UX decision; surface alongside J, don't guess.
- `Clipboard.read` `offset` (Nth clipboard-history entry) — needs clipboard-history integration; defer.
- `Form.DatePicker` `isFullDay()` value-helper; `TagPicker`→array typed values; non-AI `canAccess` — niche; defer.
