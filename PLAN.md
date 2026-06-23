# Invoke — Implementation Plan

> A faithful, buildable clone of Raycast: a keyboard-first command palette + extensible plugin platform, macOS-first.
> **Personal project** · **Date:** 2026-05-30 · **Status:** Draft for build

---

## 1. Product Vision & Scope

**What we're building.** `invoke` is a keyboard-first productivity launcher for macOS, built around a single translucent command palette summoned by a global hotkey. It unifies app launching, file search, clipboard history, snippets, quicklinks, a natural-language calculator, window management, system commands, and a system-wide AI layer — all behind one fuzzy-searched result list with a contextual Action Panel. The real moat, like Raycast, is a **third-party extension platform**: React + TypeScript extensions that render to native UI through a custom reconciler, distributed via a store.

**Target platforms.**
- **v1: macOS 14+ (Apple Silicon + Intel).** Lead surface. Native Swift/AppKit shell.
- **v2: macOS parity + maturity.** Full extension store, hosted AI gateway, sync.
- **v3: Windows 11** (and an iOS companion) reusing the cross-platform architecture. Explicitly *not* a v1 concern.

**Explicit clone goals (faithfulness bar).**
1. Two latency budgets, both enforced by CI perf gates (§8): **native-summon p95 < 150ms** (window paints instantly, process kept warm); **extension-first-paint p95 < 300ms** (skeleton/`isLoading` paint before data).
2. The same declarative component model (`List`/`Grid`/`Detail`/`Form`/`ActionPanel`) so Raycast-style extensions port mechanically. We target **API-shape compatibility plus a real compat shim + codemod** (see §5.0) — not binary source-compatibility with the Raycast Store.
3. Out-of-process extension runtime with **true per-extension OS-process isolation** (not worker-thread "isolation" — see §4.4), hot reload, and a typed SDK.
4. Keyboard-operable everything; Action Panel (Cmd+K); push/pop navigation; aliases/hotkeys/fallbacks; user Favorites pinned to root; manual ranking overrides; Search Menu Items of the frontmost app.
5. **AI woven into the root**, not a bolted-on window: AI-as-fallback-result in root search + AI Commands on `{selection}`/`{clipboard}`, BYOK in v1. Full gateway/Chat/tool-calling/MCP in v2.

**In scope for v1 (MVP).** Root search/command palette; app launch + search; file/folder search; clipboard history; snippets; quicklinks; calculator; window management; **Search Menu Items** (frontmost app via AX); emoji picker; system commands; script commands; Favorites/Pins + manual ranking overrides; the extension runtime + SDK + CLI + ~15 first-party extensions; **in-app Store browse/install UX** (against a small static registry); ~6–10 curated themes (light/dark + accent); preferences; **minimal Calendar / My Schedule** (EventKit, join-conference, menu-bar agenda); **Confetti**; a stable `invoke://` deeplink scheme + "Add to Invoke" web button. **AI in v1:** AI-as-root-fallback result + basic AI Commands, BYOK-only.

**Out of scope for v1.** Windows/iOS clients; cloud sync; teams/RBAC/SSO; Theme Studio; Translate; screenshot OCR; multi-turn AI Chat workspace; AI Extensions/MCP tool-calling; Skills; dictation; the hosted/metered AI gateway; the public PR-based store review pipeline (v1 ships a curated static registry + in-app browse UX). These are v2/v3. Floating Notes is late-v1/early-v2.

**Non-goals (ever, unless revisited).** Reproducing Raycast's exact branding, theme-gallery URLs, or drop-in binary compatibility with `@raycast/api`-published extensions (legal + practical — see §10). Note: a clean-room compat *shim* re-exporting our own implementations under aliased names is in scope and not a non-goal (§5.0, §10).

---

## 2. Feature Inventory

Priority legend: **P0** = MVP must-ship, **P1** = v2, **P2** = v3. Effort: S/M/L/XL (engineer-weeks, see §8 staffing).

### v1 (MVP) — P0

| Feature | Notes | Effort |
|---|---|---|
| Root search / command palette | Fuzzy + frecency ranking, strict-prefix alias pinning, fallback commands, **AI fallback result** | L |
| **Favorites/Pins + ranking overrides** | User-pinned items above frecency; per-result Reset Ranking + Move Up/Down (Cmd+Shift+arrows) | S |
| App launching & app search | `NSWorkspace` indexing, running/quit/switch, recency ranking | M |
| **Search Menu Items** | Drive frontmost app's menu bar via Accessibility (reuses window-mgmt AX grant) | M |
| File & folder search | Local index honoring `.gitignore`/`.rayignore`, filename-only, never uploaded | L |
| Clipboard history | Text/image/file/link/color; retention cap; pin/rename; paste-as; password-mgr exclusion; **encrypted at rest** | L |
| Snippets / text expansion | Keystroke monitor, 3 expansion modes, dynamic placeholders, **Secure Input detection + graceful fallback** | XL |
| Quicklinks | URL/file/deeplink; full placeholder grammar `{clipboard}`/`{selection}`/`{date}`/`{uuid}`/named `{argument}`; per-link default app/browser profile; keyword-then-query search-engine pattern | M |
| Calculator | NL math/units/currency/dates via **licensed** SoulverCore wrapper (§3.3); fallback engine scoped | M |
| Window management | Maximize/halves/thirds/quarters, multi-display, Accessibility API | L |
| Emoji & symbols picker | Name search + category filters; pin/recent; skin tone | S |
| System commands | Lock/sleep/restart, media keys, volume, dark mode, trash, etc. | M |
| Script commands | `@raycast`-style metadata headers; bash/zsh/python/node/swift/applescript | M |
| Aliases / hotkeys / fallbacks | Global hotkey (CGEvent-tap subsystem §3.2), conflict detection, double-tap modifiers, **Hyper key** | M |
| **Calendar / My Schedule** | EventKit, My Schedule list, join-conference action, menu-bar agenda | M |
| **Confetti** | Trivial delight built-in | S |
| **Extension runtime + SDK + CLI** | **Process-per-extension** Node isolation, custom reconciler, `@invoke/api`, `invoke` CLI hot reload | XL |
| **`@raycast/api` compat shim + codemod** | Alias package + `invoke import` codemod; validated against top-200 corpus (§5.0) | L |
| ~15 first-party extensions | Search, calc helpers, GitHub, etc. — dogfood the SDK | L |
| **In-app Store browse/install** | Categories, search, screenshots, README/CHANGELOG render, one-keystroke install/update | M |
| Themes (6–10 curated, light/dark + accent) | Semantic color tokens; no Theme Studio yet | S |
| Preferences window | Separate AppKit window; manifest-driven forms | M |
| **AI in root + AI Commands (BYOK)** | AI-as-fallback result, streamed inline; hotkey-bound AI Commands w/ `{selection}`/`{clipboard}`/`{argument}` | M |
| **`invoke://` deeplink scheme** | Command/extension launch w/ args; quicklink + snippet import; "Add to Invoke" web button | S |
| **Onboarding / permission-priming** | TCC grant flows (Accessibility, Full Disk) with explanations + graceful degradation | M |

### v2 — P1

| Feature | Notes | Effort |
|---|---|---|
| AI Chat | Multi-turn, model switching, history, attachments | L |
| Quick Fix + dynamic AI placeholders | In-place grammar fix; richer prompt templating | M |
| AI Extensions (tool-calling) | Tools from `src/tools/*.ts`, schema-from-types, confirmation gate, evals | XL |
| MCP client | stdio + Streamable HTTP, OAuth, registry | L |
| Skills | Markdown context units, progressive disclosure | M |
| Hosted/metered AI gateway | Provider abstraction, quotas, free 50/mo, Pro gating — **own backend workstream** | XL |
| Store + publishing pipeline + ops | PR-based review, linter, private/org extensions, **moderation runbook (§7.x/§9)** | XL |
| Cloud Sync | E2EE settings/notes/snippets/quicklinks | L |
| Theme Studio | Live editor, gradients, import/export | M |
| Translate | Fuzzy language pickers, inline + selected-text | M |
| Screenshot OCR search | On-device OCR (Vision framework), prefix filters | M |
| Floating Notes / Raycast Notes | Markdown notepad, stack nav, numpad pins | M |
| Dictation | Speech-to-text, push-to-talk | M |

### v3 — P2

| Feature | Notes | Effort |
|---|---|---|
| Windows 11 client | C#/.NET 8 + WPF shell, WebView2, shared Node backend + Rust core | XL |
| iOS companion | Chat/Notes/Quicklinks/Snippets/keyboard/Shortcuts | XL |
| Teams / RBAC / SSO | SAML, SCIM, domain capture, shared resources, admin | XL |
| Wrapped / yearly stats | Local stats, shareable images | S |
| `extensions-swift-tools` escape hatch | Codegen-bridged native Swift from TS extensions | L |
| Browser Extension companion | `getTabs`/`getContent` for AI context | M |

---

## 3. Tech Stack Decision

### 3.1 The shell: native Swift/AppKit (chosen)

| Criterion | Native Swift/AppKit | Electron | Tauri v2 (Rust) |
|---|---|---|---|
| Bundle size | ~15–40 MB | ~244 MB | ~8 MB |
| Idle RAM (shell only) | ~15–40 MB | ~200–400 MB | ~30–50 MB |
| Cold start | Instant (no vDOM/GC) | 1–1.5 s | <0.5 s |
| True vibrancy/blur | `NSVisualEffectView` (first-class) | OK on modern Electron | CSS-only, no whole-window opacity API |
| Global hotkey | Carbon / CGEvent tap (native) | `globalShortcut` | works; Wayland is per-DE pain |
| Accessibility / CGEvent taps | Direct, first-class | bridged | bridged |
| App indexing (`NSWorkspace`/Spotlight) | Direct | bridged | bridged |
| Cross-platform | macOS only | Excellent | Good (webview quirks) |
| Dev velocity | Slower UI | Fastest | Medium (Rust) |

**Decision: native Swift + AppKit for the v1 shell.** This is what Raycast itself uses, and it is the only option delivering the four launcher-critical OS capabilities natively (global hotkey, Accessibility/CGEvent for keystroke injection + window mgmt, `NSWorkspace` indexing, AppleScript automation) **and** true `NSVisualEffectView` vibrancy with ~15MB idle and instant paint. AppKit (not SwiftUI) for the result list specifically — Raycast deliberately chose AppKit for stability/perf; thin SwiftUI only for settings/static panels.

**Cross-platform later (v3):** adopt the four-layer split — native shell per OS (Swift/AppKit on mac, C#/.NET 8/WPF on Windows), one React+TS frontend in the system WebView (WKWebView / WebView2), one shared long-lived Node backend, and a Rust core for file indexing/data/sync — with a single typed schema + codegen across runtimes (UniFFI-style for Rust). We design the IPC schema in v1 so this is additive, not a rewrite.

### 3.2 Concrete stack

| Layer | Choice | Version | Why |
|---|---|---|---|
| Shell language | Swift | 6.x | Native macOS, concurrency model |
| Shell UI | AppKit (custom rows) + thin SwiftUI for settings | macOS 14+ SDK | Keyboard-first perf + vibrancy |
| Global hotkey | **Unified CGEvent-tap subsystem** (Carbon `RegisterEventHotKey` fast-path, accepted-but-deprecated) | — | Consolidates hotkey + double-tap/modifier-only + keystroke monitor onto one AX-grant path (§9) |
| IPC native side | `DispatchIO` serial queues + **length-prefixed framing**, backpressure-aware | — | In-order JSON-RPC over dedicated fds (§4.6) |
| Calculator core | SoulverCore via thin Swift wrapper — **commercial license required (§3.3)** | — | Don't rebuild NL math; fallback if license blocks |
| Extension runtime | **Embedded, signed+notarized Node** (single-executable build, in bundle) | **22.14+ (pinned patch)** | Inherits app code signature + hardened runtime; deterministic (§3.4) |
| Extension isolation | **One OS child process per extension** + Node built-ins (`fs`/`net`/`child_process`) denied by default, all capability via allowlisted RPC | — | True address-space separation (§4.4) |
| Reconciler | custom host-config on `react-reconciler`, **mutation-mode** (emit patches from commit phase) | React + `react-reconciler` **pinned exact, vendored** | Render-tree mutations, not DOM; avoids O(tree) diffing (§4.5) |
| Wire diff | Mutation stream from reconciler commit phase (primary); JSON Patch (`fast-json-patch`) only where snapshot diffing is unavoidable | — | Cheaper on the search hot path (§4.5) |
| SDK package | `@invoke/api` (types + contract) + `@invoke/utils`; **`@raycast/api` compat alias** | semver decoupled from React version | Impl lives in host, fulfilled over RPC (§5.0) |
| CLI | Go binary embedding `esbuild` (library form) | esbuild latest | Sub-second bundle + hot reload |
| Bundler | esbuild | latest | Fast TS→single JS bundle |
| Per-extension data | **SQLite + SQLCipher** (encrypted, scoped) via `GRDB.swift`, Keychain-managed keys | — | LocalStorage/Cache/prefs; clipboard + OAuth tokens MUST be encrypted (§3.4) |
| AI SDK (gateway, v2) | Anthropic / OpenAI / Google SDKs behind one gateway | — | Provider abstraction |
| Telemetry | Local-only by default; explicit opt-in, no-PII (§ Telemetry) | — | Privacy posture (§10) |

**Process model in one line:** Swift host owns window + hotkey + native UI ↔ length-prefixed JSON-RPC over dedicated fds ↔ a Node supervisor that **forks one child process per running extension** (Node built-ins disabled; capability only via allowlisted RPC).

### 3.3 SoulverCore — commercial dependency (decide before Phase 1)

SoulverCore is a **closed-source xcframework requiring a paid commercial license** (free only for personal/non-commercial). It is on the Phase 1 critical path.
- **Action before Phase 1 start:** secure a signed commercial license with a budget line; confirm redistribution terms for shipping the xcframework inside a **signed + notarized** app; confirm **both Apple Silicon + Intel** slices ship in the licensed build.
- **Fallback if license blocks/slips:** build on a free expression/units/currency engine (e.g. open math parser + a units/FX library) and **scope NL-math down for v1** (arithmetic, unit/currency conversion, basic date math) rather than full natural-language parsing.

### 3.4 Runtime & at-rest encryption specifics

- **Node binary:** embed a **signed, notarized single-executable Node** inside the app bundle so it inherits our code signature and hardened runtime (avoids Gatekeeper/quarantine/library-validation failures of a post-install download). Pin the exact patch version for a deterministic process model. (Downloaded-and-verified Node is rejected: hash "integrity-verify" does not satisfy signing/notarization.)
- **Hardened Runtime entitlements:** explicitly reconcile spawning the Node child + CGEvent/AX usage with library validation — entitlements review is a Phase 0 task (§8 exit criteria).
- **Encryption:** GRDB has **no at-rest encryption out of the box**; use the **GRDB + SQLCipher** build with keys in Keychain. Encrypted (mandatory): clipboard history, OAuth tokens, LocalStorage, per-extension Cache containing user data. Plaintext acceptable: derived indices/caches with no user content. Confirm SQLCipher licensing/build path for a notarized app.

---

## 4. Core Architecture

### 4.1 The blueprint (mirrors Raycast)

Extension JS runs **out-of-process** in a managed Node runtime, **one OS child process per extension** (true address-space separation). A **custom React reconciler in mutation mode** converts the component tree into a **render-tree mutation stream** (createInstance/appendChild/commitUpdate/removeChild emitted from the commit phase); the host applies minimal mutations to a tree of Swift **view models** that drive custom AppKit widgets. Communication is **length-prefixed JSON-RPC over dedicated file descriptors** with a **strict registered-message allowlist** (no arbitrary host calls). Built-in commands are just first-class commands implemented natively *or* as bundled extensions that ride the same pipeline.

### 4.2 ASCII architecture diagram

```
┌───────────────────────────────────────────────────────────────────────────┐
│                         NATIVE HOST  (Swift + AppKit)                       │
│                                                                             │
│  ┌──────────────┐  ┌───────────────┐  ┌────────────────────────────────┐   │
│  │ Hotkey/Events│  │  Window Mgr    │  │  Command Palette (AppKit)      │   │
│  │ CGEvent tap  │─▶│  NSPanel +     │─▶│  search bar · result list ·    │   │
│  │ (+Carbon fp) │  │  VisualEffect  │  │  action bar (Cmd+K)            │   │
│  └──────────────┘  │  vibrancy/blur │  └───────────────┬────────────────┘   │
│                    └───────────────┘                  │ selection/keys      │
│  ┌──────────────────────────────────────┐  ┌──────────▼─────────────────┐  │
│  │  Native Services                       │  │  Render mutations →        │  │
│  │  • App index (NSWorkspace/Spotlight)   │  │  ViewModels applier        │  │
│  │  • File index (FSEvents)               │  └──────────▲─────────────────┘  │
│  │  • Clipboard monitor (NSPasteboard)    │             │                    │
│  │  • Keystroke monitor/inject (CGEvent + │  ┌──────────┴─────────────────┐  │
│  │    Secure-Input detection)             │  │  Frecency + Favorites/Pins │  │
│  │  • Window/Menu control (AX)            │  │  + manual override ranker  │  │
│  │  • Calculator (SoulverCore, licensed)  │  └────────────────────────────┘  │
│  │  • Encrypted SQLite (GRDB+SQLCipher)   │                                   │
│  └──────────────────────────────────────┘                                   │
│            ▲  registered JSON-RPC messages only (render, setClipboard,…)     │
│            │  DispatchIO · length-prefixed framing · backpressure · sessions │
│            │  large binaries OUT-OF-BAND (content-addressed cache by handle) │
└────────────┼─────────────────────────────────────────────────────────────--┘
             │  JSON-RPC over DEDICATED fds (not 0/1/2; ext stdout/stderr separate)
┌────────────▼────────────────────────────────────────────────────────────────┐
│             EXTENSION RUNTIME  (embedded signed Node 22, supervisor)           │
│                                                                                │
│   ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐             │
│   │ CHILD PROCESS   │   │ CHILD PROCESS   │   │ CHILD PROCESS   │  …on demand │
│   │  Extension A    │   │  Extension B    │   │  Built-in ext   │             │
│   │  own address    │   │  own address    │   │                 │             │
│   │  space · capped │   │  space          │   │                 │             │
│   │  ┌───────────┐  │   │  fs/net/child_  │   │  fs/net denied  │             │
│   │  │ reconciler│  │   │  process DENIED │   │  by default     │             │
│   │  │ (mutation)│──┼─▶ render mutations ─┼─▶ all capability ───┼─▶ via RPC   │
│   │  └───────────┘  │   │  via allowlisted│   │  allowlist only │             │
│   └─────────────────┘   │  RPC only       │   └─────────────────┘             │
│         crash/OOM kills ONE child → error screen, host + others survive        │
│                                                                                │
│   @invoke/api (types + RPC stubs)  ·  @invoke/utils (hooks)  ·  @raycast/api shim │
└────────────────────────────────────────────────────────────────────────────--┘
             │ (v2) AI gateway
┌────────────▼─────────────────────────────────────────┐
│  AI GATEWAY (server, v2)  provider router · streaming  │
│  OpenAI · Anthropic · Google · Ollama · MCP client     │
└────────────────────────────────────────────────────--─┘
```

### 4.3 App shell

- **Window:** borderless `NSPanel` (we *do* steal focus), transparent background, `NSVisualEffectView` (`.hudWindow`/`.popover` material, `.behindWindow` blending), ~10–12px corner radius, 1px subtle border + soft shadow, centered upper-third of the active display, ~750px content width, height grows then scrolls. **Compact Mode:** collapse to just the search bar when query empty; expand on input/Action Panel; auto-hide on blur.
- **Global summon:** CGEvent-tap subsystem (default Option+Space; supports double-tap modifiers + Hyper key). Keep the process warm and the window pre-rendered → zero perceived latency; grab key focus on show; Esc/blur to hide.
- **Ranker:** in-memory index merging apps, built-in commands, extension commands, quicklinks, snippets, files, calculator, **AI fallback**. Order = **user Favorites/Pins (top)** → frecency (frequency + recency decay) with strict-prefix alias pinning (exact alias → top) and fuzzy match over title+keywords → **AI fallback result** for natural-language queries. Per-result Action-Panel actions: **Reset Ranking**, **Move Up/Down** (Cmd+Shift+arrows). Fallback commands route unmatched queries to a chosen command.

### 4.4 Extension runtime, isolation & lifecycle (corrected isolation model)

**Isolation (critical correction).** `worker_threads` are **not** a security boundary — workers share the OS process address space (SharedArrayBuffer, prototypes, native bindings) and cannot safely contain malicious third-party code. Therefore:
- **Each extension runs in its own OS child process** (forked from an embedded signed Node), giving real address-space separation. Worker crash/OOM kills exactly one child → error screen; host and all other extensions survive.
- **Node built-ins (`fs`, `net`, `http(s)`, `child_process`, `dgram`, `process.binding`, etc.) are denied by default** at runtime (not by convention): the supervisor boots each child with a locked-down `require`/module policy so the only path to capability is the **allowlisted RPC** to the host. This is enforced by the runtime, not documentation.
- **Defense in depth:** capped heap (bounds OOM only), and a **macOS App Sandbox / seatbelt profile on the child** where compatible. `isolated-vm` (no Node bindings) or a QuickJS/Wasm sandbox is an evaluated alternative for the truly-untrusted store tier in v2; v1 first-party + curated-registry extensions run process-per-extension with built-ins denied.
- **RAM/spin-up cost:** process-per-extension costs more RAM and start time than worker threads — accounted for in the warm-pool design (§4.4 lifecycle) and the extension-first-paint budget (§1, §8).

**Command modes & lifecycle.** `view` (mounts React tree as nav root, unloads on leaving root), `no-view` (runs an exported async fn, unloads on promise resolve), `menu-bar` (renders `MenuBarExtra`, resident until `isLoading` false / menu closes), plus optional **background refresh** on a manifest `interval`. `environment.launchType` distinguishes `UserInitiated` vs `Background`. **Not resident by default.**

**Extension-first-paint pipeline & warm pool.** Opening a `view` command requires: acquire a child runtime → evaluate the bundle/require graph → first React render → emit mutations → RPC → bind view models → AppKit. To hit p95 < 300ms:
- Maintain a **warm pool of pre-forked, SDK-initialized child runtimes** (pre-fork after `@invoke/api` init; consider V8 startup snapshots) so per-open cost excludes Node boot.
- **Skeleton/`isLoading` first paint** before async data resolves.
- **Keep the most-recently-used extension resident.**
- Prototype the *full* path in Phase 0 with a realistic extension (real deps + async fetch); state warm-pool RAM cost given process-per-extension isolation.

### 4.5 The reconciler/renderer (the linchpin)

1. Implement a host-config on `react-reconciler` in **mutation mode**: emit the render mutations **directly from the commit phase** (`createInstance`/`appendChild`/`commitUpdate`/`removeChild`) as the wire patch stream — React already knows what changed, so we avoid re-deriving it by O(tree) snapshot diffing on the search hot path. Use JSON Patch only for the rare cases where snapshot diffing is genuinely needed.
2. On the native side, maintain a parallel tree of **Swift view models** decoupled from concrete AppKit widgets. Apply mutations to view models, then bind view models → AppKit. This indirection lets the wire format evolve without rewriting view code.
3. **Stability discipline (major correction).** `react-reconciler`'s host-config interface is **not semver-stable and changes often**; React 19 concurrent features (transitions, Suspense, interrupted renders) interact non-trivially with a streaming wire protocol (tearing, partial trees). Therefore:
   - **Pin `react` and `react-reconciler` to exact versions and vendor/lock the host config.**
   - The **extension API surface (`@invoke/api`) is OUR stable contract, decoupled from the React version** — document which React 19 features are part of the public contract vs internal, so we can upgrade React without an ecosystem break.
   - Run a **conformance suite** (first-party + top-corpus extensions) against every React/reconciler bump before adoption.
   - Benchmark the mutation stream against a **5k-row list updating per keystroke** in Phase 0; cap/virtualize rows.

### 4.6 IPC

Async, batched, **schema-typed JSON-RPC over dedicated file descriptors** (not 0/1/2 — extension `stdout`/`stderr` go to a separate logging channel so they can't corrupt the protocol), with a **strict allowlist** (`render`, `setClipboard`, `showToast`, `getPreferenceValues`, `oauth.*`, …). Specifics:
- **Framing:** length-prefixed messages; defined max-message-size with a chunking policy beyond it.
- **Backpressure:** DispatchIO read side applies backpressure when Swift can't drain; writers respect it.
- **Large binaries out-of-band:** images, thumbnails, Grid art, clipboard images, OCR/Detail assets are **never base64-inline**. They go to a **content-addressed cache in `supportPath`** and are referenced by handle in the JSON. Base64-over-pipe is reserved for tiny payloads only.
- Swift reads/writes via `DispatchIO` on serial queues; single-threaded child runtimes prevent interleaving; a **per-extension session id** multiplexes parallel extensions. **Minimize boundary crossings** — chatty IPC visibly hurts the latency budgets.

### 4.7 Built-ins vs third-party coexistence

All commands — native built-ins, bundled first-party extensions, and third-party extensions — register the same **command manifest** and render through the same UI pipeline and Action Panel. Performance-critical built-ins (app/file index, clipboard, window mgmt, calculator, Search Menu Items) are implemented natively in Swift and surfaced as commands; everything else (GitHub, etc.) is a normal extension. One ranking index, one Action Panel abstraction, one renderer.

---

## 5. Extension / Plugin System

Design target: **API-shape compatible** with `@raycast/api` **plus a real compat shim + codemod** so porting is genuinely mechanical, not aspirational. Package as `@invoke/api` + `@invoke/utils`.

### 5.0 Ecosystem compatibility (the moat) — REQUIRED

The store is the moat; a renamed package alone forfeits the ~2,000-extension ecosystem. So v1 ships:
- **A `@raycast/api` compatibility shim:** an alias package that **re-exports our own clean-room implementations** under the `@raycast/api` import paths and export names. (Compatible with §10's clean-room stance — it aliases *our* code, never Raycast's.)
- **An automated `invoke import <raycast-ext>` codemod** that rewrites imports, reconciles manifest key deltas, and patches known drifted shapes.
- **A top-200-extension test corpus**: the codemod + shim are validated by type-checking and launching the top ~200 real extensions; the **API surface diff doc** (below) is kept in lockstep with corpus results.

If we ever cannot fund the shim+codemod+corpus, we must explicitly downgrade the §1 moat claim to "launcher with an SDK." The plan cannot both claim the store is the moat and leave porting manual.

### 5.1 Manifest schema (`package.json` superset)

Top-level: `name` (URL-safe id), `title`, `description`, `icon` (512×512 PNG, optional `@dark`), `author`, `categories[]`, `commands[]` (**array**), `platforms[]` (default `["macOS"]`). Optional: `license`, `contributors[]`, `keywords[]`, `preferences[]` (**array**), `tools[]` (v2), `ai{}` (object: `instructions`, etc., v2), `owner` (org), `access` (`public`|`private`), `external[]`.

> **Shape rule (fix):** `commands`, `preferences`, and `arguments` are **JSON arrays** everywhere (matching `@raycast/api`). Earlier object-notation prose is wrong; arrays are canonical.

Each command (array entry): `name` (→ `src/[name].ts`), `title`, `description`, `mode` (`view`|`no-view`|`menu-bar`); optional `subtitle`, `icon`, `keywords[]`, `arguments[]`, `preferences[]`, `interval` (`90s`/`1m`/`12h`/`1d`), `disabledByDefault`. Commands inherit extension preferences; same-named keys override.

**Arguments (array):** `{name, type: text|password|dropdown, placeholder, required, data[]}` — `dropdown` requires `data` as `[{title, value}]`.
**Preferences (array):** `{name, title, description, type: textfield|password|checkbox|dropdown|appPicker|file|directory, required, placeholder, default (per-platform {macOS,Windows}), label, data[]}` — `dropdown` requires `data` as `[{title, value}]`.
Read via `getPreferenceValues<Preferences>()` and `LaunchProps`; both strongly typed by a generated `invoke-env.d.ts`.

### 5.2 Command modes

`view` → push a List/Grid/Detail/Form as nav root. `no-view` → run-and-exit (copy/open/API), optional background interval. `menu-bar` → render `MenuBarExtra` into the macOS menu bar. **Tools** (v2) → `src/tools/*.ts` default-exported functions the AI model calls.

### 5.3 Component library

- **List**: `isLoading`, `navigationTitle`, `searchBarPlaceholder`, `searchBarAccessory` (`List.Dropdown`), `filtering`, `onSearchTextChange`, `throttle`, `isShowingDetail`, `selectedItemId`, `onSelectionChange`, `pagination {hasMore,onLoadMore,pageSize}`, `actions`. Children: `List.Section`, `List.Item` (`title`, `subtitle`, `icon`, `accessories[]`, `keywords`, `detail`, `actions`, `quickLook`), `List.Item.Detail` (`markdown`, `metadata`), `List.Dropdown`, `List.EmptyView`.
- **Grid**: `columns` 1–8, `aspectRatio`, `fit` (contain/fill), `inset`, + same search/pagination props. `Grid.Section`/`Grid.Item`/`Grid.Dropdown`/`Grid.EmptyView`.
- **Detail**: CommonMark `markdown` + `Detail.Metadata` (`Label`/`Link`/`TagList`/`Separator`).
- **Form**: `enableDrafts`, items `TextField`/`TextArea`/`PasswordField`/`Checkbox`/`DatePicker`/`Dropdown`/`TagPicker`/`FilePicker`/`Separator`/`Description`; common props `id`/`title`/`info`/`error`/`value`/`onChange`; imperative `focus()`/`reset()` via ref.
- **ActionPanel / Action**: `ActionPanel.Section`/`Submenu`; `Action`, `Action.CopyToClipboard`, `Action.Paste`, `Action.OpenInBrowser`, `Action.Open`, `Action.ShowInFinder`, `Action.SubmitForm`, `Action.Push` (primary nav, via `target`), `Action.Trash`, `Action.CreateQuicklink`, `Action.CreateSnippet`, `Action.ToggleQuickLook`, `Action.PickDate`. First action = primary (Enter), second = secondary (Cmd+Enter); in Form primary = Cmd+Enter. Standard shortcut conventions honored (e.g. `Action.CopyToClipboard` → Cmd+C, `Action.Paste` → Cmd+V) where unset.
- **MenuBarExtra**: `icon`/`title`/`tooltip`/`isLoading`; `MenuBarExtra.Item`/`Submenu`/`Section`/`Separator`.
- **Navigation**: `useNavigation()` → `{push, pop}`; prefer `Action.Push`; Esc pops; each view sets its own `navigationTitle` (breadcrumb).

### 5.4 Hooks & utilities (`@invoke/utils`)

Data hooks centered on `{data, isLoading, error, revalidate, mutate, pagination}`: `useFetch`, `usePromise`, `useCachedPromise` (optimistic `mutate({optimisticUpdate, rollbackOnError})` + function-form pagination), `useCachedState`, `useExec`, `useSQL`, `useForm`, `useAI`, `useStreamJSON`, `useLocalStorage`, `useFrecencySorting`. Helpers: `runAppleScript`/`runPowerShellScript`, `showFailureToast`, `executeSQL`, `getFavicon`/`getAvatarIcon`/`getProgressIcon`, `createDeeplink`, `withCache`, `OAuthService`/`withAccessToken`/`getAccessToken`.

### 5.5 Platform APIs

- **Application discovery (fix — high-frequency real exports):** `getApplications()`, `getDefaultApplication(path)`, `getFrontmostApplication()`, plus the `Application` type.
- **Clipboard**: `copy(content, {concealed, transient})`, `paste`, `read({offset 0–5})` **returns `{text, html, file}`**, `readText`, `clear`.
- **LocalStorage** (extension-scoped, encrypted SQLite, async): `getItem`/`setItem`/`removeItem`/`allItems`/`clear`.
- **Cache** (synchronous, disk-backed LRU, default 10MB): `get`/`set`/`has`/`remove`/`clear`/`subscribe`.
- **environment**: `appearance`, `commandMode`, `commandName`, `launchType` (`LaunchType.UserInitiated`|`Background`), `supportPath`, `assetsPath`, `canAccess(api)`.
- **Enums (fix):** ship `Icon`, `Color` (named + `Color.Dynamic`/raw), `Image.Mask` (Circle/RoundedRectangle), `Toast.Style` (Success/Failure/Animated), `LaunchType`, `Keyboard.Shortcut`.
- **Window/search**: `closeMainWindow({clearRootSearch, popToRootType})`, `popToRoot`, `open`, `launchCommand`, `updateCommandMetadata`.
- **Feedback**: `showToast` (`Toast.Style.Success`/`Failure`/`Animated`, updatable, with primary/secondary actions) auto-falls-back to `showHUD` when window closed; `Animated` toasts persist until updated/dismissed.
- **OAuth (PKCE)**: `OAuth.PKCEClient` (Web/App/AppURI redirect), prebuilt provider configs (GitHub/Slack/Google/Linear/Zoom…), proxy service for non-PKCE providers. Tokens stored in **encrypted** store (§3.4).
- **AI** (v1 BYOK, v2 gateway): `AI.ask(prompt, {model, creativity, signal})` returns a Promise that is also an EventEmitter (`.on('data', …)`); `environment.canAccess(AI)`; rate limits 10/min, 100/hr per extension.
- **Selection**: `getSelectedFinderItems()`, `getSelectedText()`.

### 5.6 CLI / dev server

Go binary embedding esbuild. `npm run dev` wraps `invoke develop`: watch → esbuild rebuild → hot-deploy + reload into the running app (~200ms), via URL scheme + pid files, no dev server. Also `build` (type-check dist), `lint`, `fix-lint`, `import` (Raycast codemod, §5.0), `publish`, and (v2) `invoke evals`. Generates `invoke-env.d.ts` typing Preferences/Arguments/LaunchProps. Scaffold via a **Create Extension** command with templates.

### 5.7 Store & publishing

- **v1:** curated **static registry** (JSON manifest list + **signed** tarballs) + bundled first-party extensions; install = download + **signature**-verify + extract. **Full in-app Store browse/install UX**: category browsing, search, screenshots, README/CHANGELOG render, one-keystroke install/uninstall/update — the catalog is small but the *experience* reads as a real store. Background auto-updates.
- **v2:** GitHub-PR-based publishing into a public `invoke/extensions` monorepo (separate from the core shell repo — see §8) with human review + an automated linter (icon 512×512 light/dark, screenshots 2000×1250, README/CHANGELOG conventions, no secrets/console logs/keychain access), then auto-publish. Private/org extensions via `owner` + `access:"private"`. **Operations runbook required — see §9 Store Operations.**
- **Security posture:** v1 relies on **process-per-extension isolation + Node-built-ins-denied-by-default + restricted RPC allowlist + signed registry tarballs + curation**. We additionally design (and ship for v2's public tier) a **declared-permission manifest** (`fs`/`network`/`shell`/`clipboard`) enforced at two layers (IPC router + native permission registry), with **install-time disclosure + runtime prompts + a settings panel to revoke** — a more defensible path than trust-the-source.

### 5.8 Minimal example extension

`package.json`:
```json
{
  "name": "hello-world",
  "title": "Hello World",
  "description": "Greets you and copies the greeting",
  "icon": "icon.png",
  "author": "your-handle",
  "categories": ["Fun"],
  "platforms": ["macOS"],
  "preferences": [
    { "name": "name", "title": "Your Name", "type": "textfield", "required": false, "default": "World" }
  ],
  "commands": [
    { "name": "greet", "title": "Greet Me", "description": "Show a greeting", "mode": "view" }
  ]
}
```

`src/greet.tsx`:
```tsx
import { List, ActionPanel, Action, getPreferenceValues } from "@invoke/api";
import { useFetch } from "@invoke/utils";

interface Preferences { name: string; }

export default function Command() {
  const { name } = getPreferenceValues<Preferences>();
  const { data, isLoading } = useFetch<{ value: string }>("https://api.example.com/quote");

  return (
    <List isLoading={isLoading} searchBarPlaceholder="Filter greetings…">
      <List.Item
        title={`Hello, ${name}!`}
        subtitle={data?.value}
        accessories={[{ tag: "greeting" }]}
        actions={
          <ActionPanel>
            <Action.CopyToClipboard content={`Hello, ${name}!`} />
            <Action.OpenInBrowser url="https://example.com" />
          </ActionPanel>
        }
      />
    </List>
  );
}
```

---

## 6. UI/UX Spec

- **Palette window:** centered, frameless, translucent (heavy blur/vibrancy), ~10–12px rounded corners, subtle border + shadow, always-on-top, ~750px wide, height grows then scrolls. Instant paint; Compact Mode collapse on empty query.
- **Search bar + list:** single top input (`searchBarPlaceholder`), optional right-side dropdown accessory (Cmd+P). Below: scrolling `List` grouped into `List.Section` (title + count); **Favorites/Pins render as a pinned top section**. Each row: leading 16px icon, title (~14–15px medium), subtitle (~12–13px), right-aligned accessories (text/date/tags with color+tooltip). Built-in fuzzy filter over title+keywords; `filtering={false}` escape hatch + throttled `onSearchTextChange` for async. Selection via stable ids (auto-UUID if absent); arrows navigate, Cmd+Up/Down jump sections; **Cmd+Shift+Up/Down = manual ranking override; Action Panel exposes Reset Ranking.**
- **AI in root:** a natural-language query surfaces an **AI fallback result**; selecting it (or Tab) streams the answer inline in the same window without leaving root. AI Commands are hotkey-bindable and operate on `{selection}`/`{clipboard}`/`{argument}`.
- **Action bar + Action Panel:** persistent bottom bar — left: command/extension icon; right: primary action label + shortcut + an "Actions" button (Cmd+K). Cmd+K opens a searchable popover anchored bottom-right, `ActionPanel.Section`s + nested `Submenu`s (own search + lazy `onOpen`). First action = primary (Enter), second = secondary (Cmd+Enter); Form primary = Cmd+Enter / secondary = Cmd+Shift+Enter. Shortcuts render as small key-cap chips inline (self-teaching).
- **Navigation stack:** push/pop with quick horizontal slide; breadcrumb from each view's `navigationTitle` top-left ("Extension › Sub View"); Esc pops.
- **Layouts:** List (default), Grid (1–8 cols, aspect ratios, contain/fill, inset), Detail (Markdown + right metadata panel), Form (typed controls + validation). All accept `isLoading` + ActionPanel.
- **States:** thin indeterminate progress bar under the search bar bound to `isLoading`; `EmptyView` (centered icon + title + description + optional actions) for no-results / first-run; built-in pagination gated on ~10+ rows. **Confetti** overlay available as a built-in delight signal.
- **Feedback:** Toast (Animated/Success/Failure, updatable, hover-revealed actions) in the bottom area; HUD capsule overlay after window close; auto-fallback Toast→HUD.
- **Theming:** semantic token set (background/gradient, primaryText, secondaryText, accent + named Blue/Green/Magenta/Orange/Purple/Red/Yellow) resolved per light/dark; Dynamic (per-theme hex) + Raw (HEX/RGB/HSL/keyword) colors with auto-contrast (`adjustContrast`, disable-able). Accent drives selection highlight, focus ring, primary emphasis. **v1 ships 6–10 curated named themes** (built on the token system; near-zero extra cost) so first-run feels comparable; Theme Studio is v2.
- **Typography/spacing/icons:** SF Pro, ~14–15px titles / 12–13px secondary, user-adjustable global size; ~40px rows; 8px-grid padding; single-line truncation with ellipsis; 16px icons monochrome-tinted by default + full-color images / emoji / file thumbnails / masks / avatars (ship an `Icon` enum).
- **Keyboard model:** hotkey to summon → type to filter → arrows → Enter/Cmd+Enter → Cmd+K for full Action Panel → Esc to pop/close → Cmd+P dropdown → Tab between Form fields → Cmd+Shift+arrows ranking override. Mouse optional, never required.
- **Accessibility:** VoiceOver labels on rows/actions; respects Reduce Transparency / Increase Contrast; full keyboard operability is itself an a11y win (see §8 a11y/i18n track).
- **Preferences:** separate conventional macOS settings window (tabbed: General, Extensions, AI, Account, Advanced, About) — not the translucent palette. Per-extension/command preference forms auto-rendered from the typed manifest; required prefs prompted before a command runs. Permission-priming/onboarding flows live here + on first run.

---

## 7. AI Layer

**v1 (BYO-key only) — AI woven into the root (not a bolted-on window).**
- **AI-as-root-fallback:** typing a natural-language question surfaces an AI result in root search; selecting it / Tab streams the answer inline in the same window. This is the daily "feels like Raycast 2026" behavior, not a separate Quick AI window.
- **AI Commands (basic):** hotkey-bound prompt templates operating on `{selection}`/`{clipboard}`/`{argument}`.
- Provider router supports OpenAI/Anthropic/Google with **user-supplied keys stored locally on-device** (Keychain), bypassing any subscription. `AI.ask` exposed to extensions as a Promise-that-is-also-an-EventEmitter; `useAI` drives progressive markdown. Gate with `environment.canAccess(AI)`. Per-extension rate limits (10/min, 100/hr). Multi-turn Chat, the hosted gateway, tool-calling, MCP, and Skills are **v2** — the *surface integration* is what's in the v1 faithfulness bar, not the billing model.

**v2 — full layer.**
- **Provider abstraction / gateway (own backend workstream).** Server-side gateway normalizing OpenAI/Anthropic/Google/Mistral/xAI/Groq/Perplexity/Ollama into one request/response/streaming shape, with model metadata (provider, context window, vision, reasoning, speed/intelligence) so the UI can sort/filter and set per-surface defaults. **Hosted** (we hold keys, meter usage, contractual no-train, free 50/mo + Pro gating) vs **BYOK** (user keys bypass subscription). Even BYOK can flow through the gateway for API unification/fallbacks; only direct-routing keeps keys fully off our servers.
- **Surfaces.** Quick AI handoff to Chat (Cmd+J), AI Chat (multi-turn, mid-conversation model switching, searchable/pinnable history, memory, attachments: files/clipboard/screenshots/browser/calendar/web search), AI Commands + Quick Fix (in-place grammar) + dynamic AI placeholders.
- **Tool-calling.** `src/tools/*.ts` default-export functions taking one typed `Input`; **auto-generate JSON Schema from TS types + JSDoc**. Extension-level `ai.instructions`. Human-in-the-loop via exported `confirmation: Tool.Confirmation<Input>` (`{message, style, info, image}`; `undefined` skips). Quality via **evals** (`callsTool`/`includes`/`matches`/`meetsCriteria`) run in CI.
- **MCP client.** **stdio** (spawn local process) and **Streamable HTTP** transports; OAuth (PKCE + static); encrypted per-server token storage; management surface (status/tool-list/start-stop/restart); registry. MCP tools unified into one tool namespace, @-mentionable across surfaces; auto-generated "Ask [Server]" command per server.
- **Skills.** Markdown context units (front-matter name/description), progressive disclosure (compact catalog first, full content on demand). Reuse `~/.config/invoke/skills` (and cross-tool `~/.claude/skills`) conventions.
- **Streaming UI.** Model the call as both awaitable result and event stream; render partial markdown token-by-token; show tool calls live; confirmation layer gates destructive actions.
- **Privacy.** No prompt retention (operational metadata only — token counts); contractual no-training clauses (hosted path); memory stored locally, encrypted at rest + in transit when synced. Privacy by default: BYOK keys never leave the device (Keychain); document AI data handling clearly; default to on-device processing (file index/OCR). If you ever offer a hosted tier to others, review data handling (and GDPR, if you have EU users) before launch.

---

## 8. Phased Roadmap, Staffing, Milestones & Operations

### 8.1 Staffing model (estimates are meaningless without it)

Assume a **steady-state v1 team of ~7 engineers** across squads; estimates below are **wall-clock under this staffing**, excluding hiring ramp and Apple-review latency.

| Squad | Headcount | Owns |
|---|---|---|
| Native Shell | 2 (senior Swift/AppKit + TCC/Accessibility/CGEvent) | NSPanel, vibrancy, hotkey/event subsystem, native services, window/menu AX, onboarding/permission-priming |
| Extension Platform / Reconciler | 2 (incl. a React-internals engineer for the `react-reconciler` host-config) | reconciler, process-per-ext runtime + sandbox, IPC, component lib, platform APIs, compat shim/codemod |
| DevEx / CLI | 1 (Go) | `invoke` CLI, hot reload, codegen, conformance suite, docs tooling |
| AI | 1 | v1 root AI + AI Commands; v2 gateway/Chat/tools/MCP (gateway needs a dedicated backend hire for v2) |
| Store / Backend | 0.5 v1 → grows in v2 | static registry + in-app store UX (v1); PR pipeline + ops + gateway backend (v2) |

**Specialist-scarcity risk:** the `react-reconciler` host-config and deep TCC/CGEvent work are rare skills rarely co-resident — flag as a hiring/ramp lead-time risk; do not assume day-1 availability.

### 8.2 Phases, exit criteria, dependencies

Effort shown as **eng-weeks (wall-clock under §8.1)**, **including a 25% buffer**. v1 phases are largely serial behind Phase 0; Phase 1 launcher core and early Phase 3 SDK *design* can parallelize.

| Phase | Theme | Key deliverables | Exit criteria (DoD / gate) | Effort |
|---|---|---|---|---|
| **0** | Spike & spine | Native `NSPanel` + vibrancy + CGEvent hotkey; warm process; AppKit list; length-prefixed JSON-RPC over dedicated fds; reconciler (mutation mode) → mutations applied to view models; **process-per-extension** runtime; entitlements review (Node child + AX/CGEvent under hardened runtime) | **(1) Red-team test extension** attempting `fs`/`net`/`child_process` + cross-extension memory reads is **blocked**; **(2)** realistic extension (deps + async fetch) opens at **p95 < 300ms**; **(3)** 5k-row mutation-stream benchmark passes; **(4)** native-summon **p95 < 150ms**; **(5)** crash containment proven (one child dies, host survives); **(6)** SoulverCore license + entitlements signed off | 6–9 |
| **1** | Launcher core | App index + launch; file/folder index (FSEvents, ignore rules); frecency ranker + **Favorites/Pins + manual overrides** + alias pinning + fallback; calculator; system commands; emoji picker; **Search Menu Items (AX)**; **Calendar/My Schedule (EventKit)**; **onboarding/permission-priming**; preferences window | All built-ins keyboard-operable; TCC grant flows degrade gracefully; perf gates green | 8–11 |
| **2** | Productivity utilities + reliability | Clipboard history + monitor + exclusions (**encrypted**); quicklinks (full placeholder grammar); window mgmt (AX); script commands | (separate tracked line) — | 7–9 |
| **2b** | **Snippet injection (own line item)** | Keystroke monitor/inject; 3 trigger modes; **Secure Input detection + clipboard-paste fallback**; known-bad-app matrix; dynamic placeholders | Documented reliability matrix; graceful fallback on Secure Input; no silent failures | 5–7 |
| **3** | Extension platform | `@invoke/api` + `@invoke/utils`; **compat shim + `invoke import` codemod + top-200 corpus**; full component lib; platform APIs; Go CLI + hot reload + codegen; encrypted SQLite (SQLCipher); ~15 first-party extensions; static registry + **in-app store UX** + auto-update | Conformance suite green; corpus type-checks; perf gates green | 14–18 (decomposed: SDK+components 5–6, runtime/IPC hardening 3–4, CLI/codegen 2–3, compat shim/codemod/corpus 2–3, store UX + registry 2) |
| **3.5** | **Hardening / beta** | Signing/notarization in CI; Sparkle updater + channels; crash reporting; security threat-model + pen-test gate; a11y/i18n pass; launch-readiness checklist | **v1 launch-readiness checklist signed (§8.4)** → **v1 ship** | 4–6 |
| **4** | AI v1 | BYOK provider router; **AI-in-root + AI Commands**; `AI.ask`/`useAI`; rate limits + `canAccess` | Privacy review of data handling | 5–7 |
| **5** | AI v2 + ecosystem | (decomposed — multiple sub-teams) | per-subsystem gates | see below |
| **5a** | — AI gateway/billing | Hosted gateway, metering, Pro gating, provider abstraction (**backend workstream**) | quotas enforced; no-train terms signed | 8–10 |
| **5b** | — AI features | Chat, Quick Fix, dynamic placeholders, AI Extensions (tools + evals), MCP, Skills | evals in CI | 10–14 |
| **5c** | — Store + ops | PR pipeline, linter, review tiers + SLAs, **moderation/incident runbook**, kill-list delivery, private/org, declared-permission sandbox | runbook tested; kill-list propagation measured | 8–12 |
| **6** | Pro features | Cloud Sync (E2EE); Theme Studio; Translate; Screenshot OCR; Floating Notes; Dictation | — | 14–18 |
| **7** | Cross-platform | Four-layer split; Windows (C#/.NET 8/WPF + WebView2); Rust core (UniFFI); iOS companion; Teams/RBAC/SSO | — | 26+ |

**Cumulative sanity check.** v1 (Phases 0–3.5) ≈ **44–60 eng-weeks wall-clock** (~10–14 months) under §8.1 staffing including buffer and a dedicated hardening/beta phase — *not* the optimistic ~26–34 weeks implied by summing raw feature effort. AI v1 +5–7. v2 (5a–5c, parallelizable across squads) ≈ two+ quarters. Add Apple-review/notarization latency as a non-engineering scheduling input. **Estimates assume steady-state team; exclude hiring ramp.**

### 8.3 Cross-cutting tracks (run across phases, owned, not optional)

- **Testing & CI (§ below).** Owned by DevEx; gates every phase.
- **Security threat-model + pen-test.** Mandatory gate **before any public store** (Phase 5c) and a lighter review before v1 ship.
- **Accessibility & i18n.** VoiceOver, Reduce Transparency/Increase Contrast, RTL, string externalization — load-bearing for the emoji/symbols picker. Tracked from Phase 1.
- **Developer docs.** `docs/` has a named owner; **rule: docs ship with the SDK** (no SDK surface lands undocumented).
- **Telemetry & analytics (§ below).**
- **Distribution & release (§ below).**
- **Post-launch support / bug intake.** Defined before v1 ship.

### 8.4 Testing & CI

- **Unit:** reconciler mutation correctness, ranker/frecency + override logic, schema codegen, placeholder grammar.
- **Integration:** IPC round-trip (framing/backpressure/chunking), **child-process crash/OOM containment**, lifecycle modes, Secure-Input fallback.
- **E2E:** XCUITest + golden-image for the palette; scripted extension launch.
- **Performance gates (enforce §1 budgets):** CI **fails the build** if native-summon p95 > 150ms or extension-first-paint p95 > 300ms.
- **Security gate:** the Phase 0 red-team extension runs in CI permanently; any capability escape fails the build.
- **Extension Conformance Suite:** published; **every first-party and store extension runs against it per SDK version**; the top-200 corpus type-checks on every `@invoke/api`/React bump to catch silent API drift.
- **CI system:** GitHub Actions (matches the PR-based store); extension PRs run lint + conformance + corpus in the public extensions repo.

### 8.5 Distribution & release

- **App signing:** Developer ID + **Apple notarization + stapling** in CI (a real latency/CI source). Hardened Runtime entitlements reconciled with the embedded Node child + CGEvent/AX (entitlements review — Phase 0).
- **Updater:** **Sparkle 2** with a signed appcast; **stable / beta / nightly** channels; staged rollout + rollback.
- **Packaging:** notarized DMG.
- **Crash reporting:** signal-based reporter + symbol upload/symbolication pipeline.
- **Extension updates:** signed-tarball registry, background auto-update, forced-update path for the kill-list (§9).

### 8.6 Telemetry & analytics

- **Consent:** **explicit opt-in**, captured in onboarding, revocable in settings. Off by default.
- **Event taxonomy:** perf timings (field cold-start/first-paint → SLOs against §1), command usage, crash/error, extension load failures. **No PII.**
- **Residency/retention:** define a retention window; if you ever collect data from EU users, keep it in an EU-adequate region (GDPR). Off by default until you decide.
- **Ingestion:** privacy-reviewed pipeline; field perf telemetry feeds the §1 latency SLOs.

### 8.7 Monorepo / repo structure

```
invoke/  (core shell + platform repo)
├── apps/
│   ├── macos/                  # Swift/AppKit host (Xcode project)
│   │   ├── Shell/              # NSPanel, vibrancy, CGEvent hotkey/event subsystem, window mgr
│   │   ├── Palette/            # search bar, result list (Favorites/overrides), action bar (AppKit)
│   │   ├── Renderer/           # render mutations → view models → AppKit
│   │   ├── IPC/                # DispatchIO JSON-RPC, framing, backpressure, allowlist, sessions
│   │   ├── Services/           # app/file index, clipboard, keystroke (+Secure Input), window/menu AX, calc, EventKit
│   │   └── Persistence/        # GRDB + SQLCipher (LocalStorage/Cache/prefs)
│   ├── windows/                # (v3 placeholder — inert until Phase 7) C#/.NET 8 WPF + WebView2
│   └── ios/                    # (v3 placeholder — inert until Phase 7)
├── runtime/
│   ├── node-host/              # supervisor: process-per-ext fork, RPC, built-ins-deny, warm pool
│   └── reconciler/             # vendored react-reconciler host-config (pinned exact)
├── packages/
│   ├── api/                    # @invoke/api (types + RPC stubs + components)
│   ├── compat-raycast/         # @raycast/api alias shim (re-exports our impls)
│   ├── utils/                  # @invoke/utils (hooks + helpers)
│   └── core-rs/                # (v3 placeholder) Rust core: indexing/data/sync (UniFFI)
├── cli/invoke/                  # Go binary embedding esbuild (dev/build/lint/import/publish/evals)
├── ai/{gateway,mcp-client}/    # (v2)
├── schema/                     # shared typed IPC schema + codegen
└── docs/                       # developer docs (owned; ships with SDK)

invoke-extensions/  (SEPARATE PUBLIC repo — public store, separate from the core repo)
└── <ext>/                      # package.json, src/, src/tools/, assets/, README, CHANGELOG
```

- **Build orchestration:** polyglot (Swift/Xcode + Node/TS + Go + Rust + C#) — use **Turborepo/Nx for the TS/JS graph + cached task running**, with Xcode/`swift build`, `go build`, `cargo`, and `dotnet` invoked as orchestrated tasks; remote build cache in CI.
- **Lockstep versioning (enforces §9 version-drift):** **changesets** keep `app` + `@invoke/api` + `invoke` CLI on aligned versions; a **CI check fails** any PR that bumps one without the others. App enforces `app-version ≥ required-SDK-version` at runtime.
- **Repo split:** the public extensions store lives in a **separate public repo** from the core native shell (per §10); v3 directories are explicit inert placeholders until Phase 7.

---

## 9. Key Risks & Hard Problems

| Risk / hard problem | Why it's hard | Mitigation |
|---|---|---|
| **Extension isolation (corrected)** | `worker_threads` are NOT a security boundary — shared address space, SharedArrayBuffer, reachable prototypes/native bindings; a single malicious extension compromises all others + the host | **One OS child process per extension** (real address-space separation); **Node built-ins denied by default**, all capability via allowlisted RPC enforced by the runtime; capped heap (OOM only); macOS App Sandbox/seatbelt on child where compatible; `isolated-vm`/QuickJS/Wasm evaluated for the untrusted store tier; declared-permission manifest at two layers for the public store; signed registry; kill-list backstop |
| **Custom React reconciler stability** | `react-reconciler` host-config is **not semver-stable, changes often**; React 19 concurrent rendering interacts with a streaming protocol (tearing, partial trees); "extensions don't pin" amplifies blast radius | **Pin react + react-reconciler exact, vendor the host config; the `@invoke/api` surface is OUR stable contract decoupled from React**; document which React features are public vs internal; conformance + top-200 corpus gate every bump; mutation-mode commit-phase patches |
| **SoulverCore is a commercial dependency** | Closed-source xcframework, paid license, redistribution-in-binary + AS/Intel slices unconfirmed; on Phase 1 critical path | Sign commercial license + budget line **before Phase 1**; confirm notarized-bundle redistribution + both arch slices; **fallback**: free expression/units/FX engine with NL-math scoped down |
| **Two latency budgets** | Native summon is easy; **extension-first-paint** (fork/attach child, boot React, first render, mutations, RPC, bind) is not free; process-per-ext costs more than threads | Separate budgets (summon <150ms, ext-first-paint <300ms); **warm pool of pre-forked SDK-initialized runtimes** + V8 snapshots; skeleton/`isLoading` first paint; keep MRU extension resident; prototype full path in Phase 0; state warm-pool RAM cost |
| **CGEvent keystroke injection + Secure Input** | **Secure Input mode** (password fields, terminals, 1Password) blocks both read and inject with no reliable override; Apple Silicon drops/reorders synthetic events into hardened/Electron apps; delay-tuning does not close the gap | **Detect `IsSecureEventInputEnabled` and degrade gracefully** (skip/clipboard-paste fallback + HUD notice, never silent fail); define injection strategy (default: pasteboard + Cmd+V synthesis); known-bad-app matrix + opt-out list; design UX assuming it's never 100% |
| **Global hotkey on deprecated Carbon** | Carbon `RegisterEventHotKey` is long-deprecated; double-tap/modifier-only triggers aren't achievable via Carbon alone | **Unify hotkey + double-tap/modifier + keystroke monitor onto one CGEvent-tap subsystem** (single AX grant); Carbon only as an accepted-but-deprecated fast-path fallback |
| **macOS TCC / Hardened Runtime entitlements** | Accessibility, Full Disk, keystroke inject, file/screenshot grants are brittle; hardened runtime + spawning Node child + CGEvent/AX is an entitlements minefield | Phase 0 entitlements review; **embedded signed+notarized Node** inherits signature/hardened runtime; clear onboarding/permission-priming with explanations + graceful degradation |
| **At-rest encryption** | GRDB has no built-in at-rest encryption; clipboard history + OAuth tokens are sensitive user data | **GRDB + SQLCipher** with Keychain-managed keys; clipboard + tokens + LocalStorage MUST be encrypted; confirm SQLCipher build/license for notarized app |
| **IPC for binary/large payloads** | Base64-over-JSON-over-pipe is slow/heavy; no framing/backpressure/max-size spec | **Length-prefixed framing + max-size + chunking + DispatchIO backpressure**; large binaries **out-of-band** in content-addressed `supportPath` cache by handle; **dedicated fds** (ext stdout/stderr separate so they can't corrupt the channel) |
| **JSON Patch cost on large lists** | Whole-tree snapshot diffing per keystroke is O(tree) on the search hot path | **Mutation-mode reconciler** emits patches from commit phase (React already knows the diff); JSON Patch only where unavoidable; benchmark 5k-row/keystroke in Phase 0; virtualize rows |
| **App/file indexing perf & correctness** | Fast, honor ignore rules, never upload, stay fresh | `NSWorkspace`/Spotlight for apps; FSEvents incremental filename-only index; local-only; (v3) Rust core |
| **Store moderation & untrusted code (ops)** | §9 ranks untrusted code top risk but ops were undefined: review depth, SLA, malware response, kill-list delivery, identity, takedown | **Store Operations runbook (Phase 5c):** review tiers (auto-lint → human code review → security review for permission-sensitive ext) with SLAs + reviewer staffing; incident runbook (detection → **signed kill-list/revocation delivery with measured propagation time → forced auto-update**); author identity/onboarding; abuse/DMCA takedown; permission-consent UX (install disclosure + runtime prompts + revoke panel) |
| **AI gateway cost & abuse (v2)** | Hosted models cost money; runaway extensions | Per-ext rate limits (10/min, 100/hr); `canAccess` gate; metered free tier (50/mo) + Pro gating; operational metadata only |
| **Ecosystem moat vs shape-compat** | Renamed package forfeits ~2,000 extensions; "mechanical port" is aspirational without tooling | **`@raycast/api` shim + `invoke import` codemod + top-200 corpus** in v1; if unfunded, explicitly downgrade the moat claim |
| **Cross-platform parity (v3)** | Extensions hardcode `/Applications/`, call `runAppleScript`, ship native mac binaries; Wayland hotkeys per-DE | Design our own SDK (no binary Raycast compat promise); four-layer split + Rust core + single typed schema from v1 so v3 is additive; Wayland hotkeys via portals/compositor |
| **SDK/CLI/app version drift** | Must stay lockstep or extensions break | **changesets + CI alignment check**; release app + `@invoke/api` + CLI together; runtime enforces `app-version ≥ required-SDK`; authors don't pin |
| **Staffing / specialist scarcity** | reconciler-internals + TCC/CGEvent skills are rare; estimates meaningless without headcount | §8.1 squad model; flag hiring/ramp lead-time; estimates stated as eng-weeks under fixed staffing |

---

## 10. Legal / Naming Note

This is a personal project. The notes below are practical pointers, not legal advice — talk to a lawyer before any public or commercial release.

- **Clean-room implementation.** Build from public API documentation, observed behavior, and our own architecture decisions — **do not** copy Raycast source code, proprietary assets (icons, themes, copy), the `@raycast/api` package *contents*, or decompiled binaries. Our SDK is `@invoke/api`/`@invoke/utils` with our own implementations.
- **Compat shim is clean-room-compatible.** The `@raycast/api` alias package re-exports **our own clean-room implementations** under aliased import paths/names — it ships no Raycast code. This is the supported path to mechanical porting and is *not* a clean-room violation; counsel to confirm the aliasing approach before external release.
- **Naming.** The project name is **"invoke"**. Note other tools already use that name (e.g. InvokeAI, the Python `invoke` task runner), so run a quick trademark/name search before any public release. Don't use "Raycast", its logo, or look-alike marks in the product, store, or marketing.
- **Trademarks & comparative claims.** Nominative reference ("works like Raycast") is generally permissible if truthful and non-misleading; avoid implying endorsement/affiliation. Avoid reusing Raycast's store URLs or scraping their store.
- **Third-party extensions & licenses.** Our store's review/licensing terms are ours to set (MIT-style recommended for first-party); do not redistribute Raycast-Store extensions without their authors' licenses permitting it. The `invoke import` codemod operates on extensions the *user* already has the right to use.
- **Privacy.** Default to local processing (file index, OCR, Wrapped); document AI data handling; BYOK keys stay on-device in Keychain; prefer AI providers with no-training terms. If the project ever grows beyond personal use — collecting data from others, a hosted AI tier, or telemetry — review the privacy law that applies (e.g. GDPR for EU users) and enable telemetry only with explicit opt-in.
- **Recommendation:** have counsel review before public distribution. This plan assumes a clean-room, independently-branded product.

---

## Appendix A — Raycast API Parity: Gap Analysis & Pending Implementation

> **Audited 2026-06-16** against [developers.raycast.com](https://developers.raycast.com), component-by-component, against the live `@invoke/api`/`@invoke/utils` surface and the AppKit renderer.
> **Member-level re-audit 2026-06-21** — all 29 pages under `/api-reference` swept page-by-page; nested types, enums, and props folded in below (incl. the previously-absent `Keyboard` namespace).
> **Code-level reconciliation 2026-06-21** — every row re-checked against the actual `@invoke/api` exports + AppKit renderer + host RPC; states corrected with `file:line` evidence (many ⬜/🟡 rows were stale — the implementation had outrun the doc).
> Legend: **✅ working** · **🟡 partial / lossy** (defined but the renderer ignores props, or semantics differ) · **⬜ missing** (throws `unsupported()`, crashes as "Element type is invalid", or is a silent no-op).
> This appendix is the canonical pending-implementation list; `STATUS.md` tracks delivery against it.

### A.0 What already works (parity baseline)

The component spine is in place and renders natively: **List, Grid, Detail, Form, ActionPanel/Action, Detail.Metadata, List.Dropdown (+ .Item/.Section), List.Item.Detail**. Recently landed and verified: **navigation push/pop** (declarative `Action.Push` *and* programmatic `useNavigation().push/pop`), **command arguments** (inline chips), **per-extension Trust**, **in-palette `confirmAlert`**, the **world-class search dropdown**, **constant palette size/position**, **Form validation + value preservation**, **AI.ask / OAuth.PKCEClient** RPCs, and (2026-06-21) **List/Detail `isLoading` bars, List/Grid accessories with `Color`/`Icon` tint, grouped `ActionPanel.Section` + drill-in `Submenu`, full `menu-bar` + `MenuBarExtra`, `launchCommand`/`updateCommandMetadata`, and `open`/`trash`/`showInFinder`**. **Icon coverage + `Color.Dynamic` + `Image.Mask` + dynamic light/dark images landed (Chunk I, 2026-06-21).** The 2026-06-21 code reconciliation found the former "crash" members all defined now (no `"Element type is invalid"`); remaining work is **depth** (controlled non-text inputs, AI/JSON streaming) and **named-type exports** — pagination, native pickers/masking, and `Detail.Metadata` fidelity landed 2026-06-21.

### A.1 List & Grid

| API | State | Gap / pending |
|---|---|---|
| `List` render + `searchBarPlaceholder` + `onSearchTextChange` | ✅ | search text routes to the child |
| `List` / `Grid` controlled `searchText` + `throttle` | ✅ | controlled `searchText` reflected on commit + `throttle` debounces the onSearchTextChange forward ~250ms (Chunk F) |
| `List` / `Grid` component-level `actions` (empty-state ActionPanel) | ⬜ | top-level `actions` prop not rendered |
| `List.Section`, `List.Item` (title/subtitle/icon) | ✅ | |
| `List.Dropdown` / `.Item` / `.Section` (searchBarAccessory) | ✅ | world-class popover (landed) |
| `List.Dropdown` / `Grid.Dropdown` controlled props (`value` / `defaultValue` / `onChange` / `storeValue` / `filtering` / `onSearchTextChange` / `isLoading` / `tooltip`) | ✅ | value/defaultValue/onChange + **storeValue (persisted) / filtering / isLoading / tooltip** all wired (Chunk F); List.Dropdown has no onSearchTextChange in Raycast |
| `List.isLoading` | ✅ | thin accent sweep bar (List/Grid/Detail), 2026-06-21 |
| `List` pagination `{hasMore, onLoadMore, pageSize}` | ✅ | renderer near-bottom → `onLoadMore` (in-flight guarded); `@invoke/api` flattens the prop, 2026-06-21 |
| Native fuzzy `filtering` of static items / `filtering={false}` | 🟡 | built-in substring filter (`filterTree`); **`filtering={false}` + explicit `filtering={true}` now honored via `hostShouldFilter()` (Chunk F)**; still substring, not fuzzy-ranked |
| `selectedItemId` / `onSelectionChange` | ⬜ | selection not reported back to the extension |
| `List.EmptyView` | ✅ | rendered: centered icon+title+description on 0 items + `empty-view` node (Chunk E) |
| `List.Item.accessories[]` | ✅ | text/tag/date/icon/tooltip + per-accessory `color` + combined entries, 2026-06-21 |
| `List.Item` `keywords` / `detail` (isShowingDetail) / `quickLook` | 🟡 | keywords used by filter; master-detail honored; `quickLook` ⬜ |
| `List.Item.Detail.isLoading` (detail-pane bar, distinct from `List.isLoading`) | ✅ | selected item's detail `isLoading` drives the top sweep bar, 2026-06-21 |
| `Grid` `columns` | ✅ | |
| `Grid` `aspectRatio` / `fit` (contain/fill) / `inset` | ⬜ | ignored |
| `Grid.Section` / `Grid.Dropdown` / `Grid.EmptyView` | 🟡/✅ | sections flattened; **EmptyView rendered** (Chunk E) |
| `Grid.Section` per-section `columns` / `aspectRatio` / `fit` / `inset` overrides | ⬜ | only top-level Grid layout props read |
| `Grid.Item.accessory` (`Grid.Item.Accessory`) | ✅ | single accessory rendered under the tile title, 2026-06-21 |
| `Grid.ItemSize` (deprecated enum) | ⬜ | defined but a no-op (renderer sizes by `columns`) |

### A.2 Detail, Colors & Icons

| API | State | Gap / pending |
|---|---|---|
| `Detail` CommonMark `markdown` (incl. images, clamped) | ✅ | tables / LaTeX / footnotes — ⬜ |
| `Detail` own `isLoading` (accent sweep bar) | ✅ | honored via the shared sweep bar, 2026-06-21 |
| `Detail.Metadata.Label` (`text` string) / `.Separator` | ✅ | both paths share `renderMetadataNode` (sidebar no longer Label-only), 2026-06-21 |
| `Detail.Metadata.Label` colored `text:{color,value}` + `icon` | ✅ | colored value (`labelAndColor`) + leading icon, both paths, 2026-06-21 |
| `Detail.Metadata.Link` | ✅ | clickable (opens the URL) on both paths via the shared `renderMetadataNode`, 2026-06-21 |
| `Detail.Metadata.TagList` | ✅ | per-tag colored chips on both paths, 2026-06-21; wraps on overflow (FlowStackView), Chunk H |
| `Detail.Metadata.TagList.Item` (`text` / `icon` / `color` / `onAction`) | ✅ | per-tag chips + `onAction` clickable + wrapping on overflow (FlowStackView), Chunk H |
| `Icon` enum | 🟡 | **102 members + `IconSymbol` validated dashes→dots SF-symbol fallback (most resolve; unmapped → placeholder, never wrong glyph) (Chunk I, 2026-06-21)**; literal-complete ~250-member set is a remaining tail |
| `Color` enum (9 named members) | ✅ | all 9 named members + **`Color.Dynamic({light,dark})` exported + `satisfies ColorType` (Chunk I, 2026-06-21)**; applied in accessories + Detail.Metadata |
| raw HEX / `{light,dark}` color values | 🟡 | honored at runtime for accessories (`PaletteView.swift:2023`); **dynamic `{light,dark}` honored — `Color.Dynamic` produces this shape (Chunk I)**; no named `Color.Raw`/`ColorLike` type |
| `Image.Mask` (Circle / RoundedRectangle) | ✅ | **circle (true circle, layout-time radius from real bounds; grid thumb squared only when masked) + RoundedRectangle honored (Chunk I, 2026-06-21)** |
| `Image` fallback + dynamic `{source:{light,dark}}` | ✅ | **dispatched by appearance (Chunk I, 2026-06-21)** |
| `Image.tintColor` (as `Image` prop) | 🟡 | applied to **accessory** icons (`PaletteView.swift:2062`); not Detail/top-level; no `Image.tintColor` export |
| `Image.ImageLike` union (URL \| Asset \| `Icon` \| `FileIcon` \| `Image`) | 🟡 | **`Image.ImageLike` + `Image.Source` exported (Chunk I-residuals, 2026-06-21)**; `fileIcon` resolved; masks / Image tint lossy |
| `FileIcon` (`{fileIcon}`) — Finder file/folder icon | 🟡 | resolved to a real Finder icon (`PaletteView.swift:1010`); not a named API export |

### A.3 Form

| API | State | Gap / pending |
|---|---|---|
| `Form.TextField` / `TextArea` / `Checkbox` / `Dropdown` | ✅ | render + value-collecting submit |
| `Form.Description` (`text` / `title`) / `Separator` | ✅ | landed |
| `Form` container props (`navigationTitle` / `isLoading` / `searchBarAccessory`) | 🟡 | `isLoading` honored (`PaletteView.swift:335`); `navigationTitle` & `searchBarAccessory` not |
| `Form.Dropdown.Item` / `Form.Dropdown.Section` | 🟡 | dropdown renders, but item `keywords` & section `title` lossy |
| `Form.Dropdown` searchable props (`onSearchTextChange` / `filtering` / `throttle` / `isLoading`) | ⬜ | local typeahead only; async/controlled props unwired |
| `Form.TextArea` `enableMarkdown` | ⬜ | markdown toolbar/preview not rendered |
| Validation (`FormValidation.Required`) + error rendering | 🟡 | only `Required`; no custom validators / async |
| `Form.PasswordField` | ✅ | masked `NSSecureTextField`, 2026-06-21 |
| `Form.DatePicker` (+ `min` / `max`) | ✅ | native `NSDatePicker`; `min`/`max` bounds + date/datetime `type` + typed `Date` `onChange` (api ISO→Date wrapper), Chunk H |
| `Form.DatePicker.Type` enum (`Date` / `DateTime`) + `Form.DatePicker.isFullDay()` | 🟡 | `Type` enum exported + `date`/`datetime` type honored (Chunk H); `isFullDay()` helper still absent |
| `Form.TagPicker` / `Form.TagPicker.Item` | 🟡 | exported (`index.ts:192`); **no longer crashes** — degrades to a single-select dropdown (string value) |
| `Form.FilePicker` (+ `allowMultipleSelection` / `canChooseFiles` / `canChooseDirectories` / `showHiddenFiles`) | 🟡 | exported (`index.ts:218`); **no longer crashes** — degrades to a path text field; options ignored |
| `Form.LinkAccessory` (`target` / `text`) | 🟡 | exported (`index.ts:220`); **no longer crashes** — degrades to inert description text |
| `onChange` | ✅ | text fields, Dropdown, **and Checkbox** (real bool); handler refreshed each reconcile (Chunk E) |
| `onBlur` / `onFocus` / `autoFocus` / `storeValue` / `info` / `enableDrafts` | ⬜ | |
| `Form.Event` / `Form.Event.Type` (`focus`/`blur`) / `Form.Values` types | 🟡 | **`Form.Values` / `FormValues` now exported (`export declare namespace`, Chunk I2, 2026-06-21)**; **`Form.Event` + `Form.Event.Type` exported (Chunk I-residuals, 2026-06-21)**; event payload (focus/blur lifecycle) still not wired |
| Typed values (Checkbox→bool, DatePicker→Date, TagPicker→array) | 🟡 | **Checkbox→bool (Chunk E) + DatePicker→Date (Chunk H) done**; TagPicker→array still pending |
| Imperative `focus()` / `reset()` via ref | ⬜ | per-item refs (`useRef<Form.TextField>`), exposed on all controlled item types |

### A.4 Actions & ActionPanel

| API | State | Gap / pending |
|---|---|---|
| `Action` (onAction), `CopyToClipboard`, `Paste`, `OpenInBrowser`, `Open`, `SubmitForm`, `Push` | ✅ | the 7 wired actions |
| `Action.OpenWith` / `Trash` / `ShowInFinder` / `ToggleQuickLook` / `CreateQuicklink` / `CreateSnippet` / `PickDate` | 🟡 | all defined + routed (`index.ts:281`–`315`, `AppController.swift:3760`) — **no longer crash**; most fire real host RPCs |
| `ActionPanel.Submenu` | ✅ | drill-in (level stack); →/Return enters, ←/Esc pops. Lazy `onOpen` ⬜ |
| `ActionPanel.Submenu` search props (`filtering` / `keepSectionOrder` / `throttle` / `onSearchTextChange` / `isLoading`) | 🟡 | client-side title filter per level; async props not wired |
| `ActionPanel.Section` | ✅ | grouped: separators + small-caps titles, 2026-06-21 |
| `Action.shortcut` (custom) | ✅ | glyph keycaps + functional binding (Chunk E); positional ↵/⌘↵ default |
| `Action.style` (destructive) | ✅ | red title in ⌘K (Chunk E); action-bar primary red is a follow-up |
| `Action.Style` enum (`Regular` / `Destructive`) | 🟡 | enum exported (`index.ts:273`); `style` prop still not rendered |
| `Action.PickDate.Type` enum (`Date` / `DateTime`) + `Action.PickDate.isFullDay()` | ⬜ | nested enum & helper absent |
| `Keyboard.Shortcut` / `Keyboard.Shortcut.Common` (type behind `Action.shortcut`) | ✅ | exported; custom shortcuts now applied — display + functional (Chunk E) |
| `Action.autoFocus` | ⬜ | |

### A.5 Navigation & Menu Bar

| API | State | Gap / pending |
|---|---|---|
| `Action.Push` + `useNavigation().push/pop` + Esc-pops | ✅ | render-on-push frames (landed) |
| `Navigation` (type returned by `useNavigation`) | ✅ | push/pop work; `Navigation` type now exported (`export declare namespace`, Chunk I2, 2026-06-21) |
| `navigationTitle` breadcrumb | ✅ | |
| `menu-bar` command mode | ✅ | accepted at discovery (`AppController.swift:3001`); real `NSStatusItem` (`MenuBarController.swift:41`) |
| `MenuBarExtra` + `.Item` | ✅ | exported (`index.ts:345`) + rendered to `NSMenu` (`MenuBarController.swift:76`/`121`) |
| `MenuBarExtra.Submenu` / `.Section` / `.Separator` | ✅ | rendered (`MenuBarController.swift:123`–`139`) |
| `MenuBarExtra.Item` `alternate` / `subtitle` / `shortcut` | ✅ | `subtitle` rendered (`MenuBarController.swift:151`); **`alternate` (Option-key alternate item) + `shortcut` (NSMenuItem key equivalent) landed (Chunk I-menubar, 2026-06-21)**. Caveat: named-key `KeyEquivalent` mapping latent — single-letter shortcuts work. |
| `MenuBarExtra.ActionEvent` (`left-click` / `right-click`) | ✅ | **`onAction` now receives `{type:"left-click"}` + `MenuBarExtra.ActionEvent` type exported + typed `MenuBarItemProps` (Chunk I-menubar, 2026-06-21)**. Right-click distinction not possible (NSMenuItem limitation — always "left-click"). |

### A.6 Feedback

| API | State | Gap / pending |
|---|---|---|
| `showToast` (Success/Failure/Animated; object + positional overload; updatable handle) | ✅ | |
| `Toast.primaryAction` / `secondaryAction` (`Toast.ActionOptions`) | ✅ | rendered as buttons in in-palette toast; `onAction` fires via imperative host→child callback channel; actionable toast persists until acted/dismissed. Landed Chunk G′ 2026-06-21. Toast-action `shortcut` key-binding + headless-HUD actions remain follow-ups. |
| `Toast.Style` enum (`Success` / `Failure` / `Animated`) | 🟡 | states used by `showToast`, but enum not tracked; minimal visual differentiation |
| Toast visual style (icon/color per style) | 🟡 | minimal differentiation |
| `showHUD` | 🟡 | renders, but `options` (`clearRootSearch` / `popToRootType`) are decorative no-ops |
| `confirmAlert` (in-palette modal, `primaryAction.onAction`, destructive, key capture) | ✅ | landed this iteration, both hosts |
| `Alert.Options` `icon` / `dismissAction` / `rememberUserChoice` | ✅ | landed Chunk G 2026-06-21; honored by both in-palette modal and native NSAlert hosts |
| `Alert.ActionStyle` enum (`Default` / `Destructive` / `Cancel`) + `Alert.ActionOptions` | 🟡 | enum exported (`index.ts:873`) + destructive honored end-to-end (`AppController.swift:2013`); `Alert.ActionOptions` type not modeled |
| `showFailureToast` (utils) | ✅ | |

### A.7 Storage, Preferences & Environment

| API | State | Gap / pending |
|---|---|---|
| `LocalStorage` get/set/remove/allItems/clear (getItem→`undefined` parity) | ✅ | |
| `LocalStorage.Value` / `LocalStorage.Values` types | 🟡 | functions work; named types not exported |
| `Cache` get/set/has/remove/clear | ✅ | `subscribe` — ⬜ no-op; `capacity`/LRU eviction — ⬜ |
| `Cache` constructor `{namespace, capacity}` / `isEmpty` | 🟡 | namespace isolation & `isEmpty` not honored |
| `Cache.Subscriber` / `Cache.Subscription` / `Cache.Options` types | ⬜ | not modeled |
| `getPreferenceValues` + types textfield/password/checkbox/dropdown/appPicker | ✅ | `file` / `directory` pref types — ⬜ |
| `Preferences` / `PreferenceValues` types | ✅ | `getPreferenceValues` works; `Preferences` (augmentable) + `PreferenceValues` now exported (Chunk I2, 2026-06-21) |
| Per-command preference override + required-before-run | ✅ | |
| `environment.supportPath` / `assetsPath` / `commandName` / `commandMode` | ✅ | |
| `environment.extensionName` / `ownerOrAuthorName` | 🟡 | always `""` |
| `environment.appearance` / `textSize` / `launchType` / `isDevelopment` / `raycastVersion` | 🟡 | `launchType` wired (`index.ts:587`); **`appearance` real (NSApp.effectiveAppearance, main-thread-guarded) + `textSize` host-provided (Chunk I2, 2026-06-21)**; `isDevelopment`/`raycastVersion` hardcoded. Note: live appearance-change push remains pending. |
| `LaunchType` enum (`UserInitiated` / `Background`) | ✅ | exported (`index.ts:474`); drives `launchCommand` + `environment.launchType` |
| `FileSystemItem` (return type of `getSelectedFinderItems`) | ⬜ | inline `{path:string}[]`; no named type |
| `environment.canAccess(api)` | 🟡 | **`canAccess(AI)` real (AIService.hasStoredKey(), boolean, Chunk I2, 2026-06-21)**; non-AI APIs still return `false` |
| `openExtensionPreferences` / `openCommandPreferences` | 🟡 | send a `scope` arg, but host ignores it (not scoped) |
| `updateCommandMetadata` | ✅ | real RPC (`index.ts:796`) + host stores subtitle override & re-renders (`AppController.swift:2120`) |
| `launchCommand` (cross-command launch) | ✅ | real `command.launch` RPC (`index.ts:783`) + host handler (`AppController.swift:2127`) |

### A.8 Clipboard, Keyboard, Window & Applications

| API | State | Gap / pending |
|---|---|---|
| `Clipboard.copy` / `paste` / `readText` | ✅ | `concealed` flag dropped (🟡); `html`/`file` copy — ⬜ (note: `transient` is **not** a current Raycast `CopyOptions` field) |
| `Clipboard.Content` / `Clipboard.ReadContent` / `Clipboard.CopyOptions` types | 🟡 | text path works; `html`/`file` content shapes not modeled |
| `Clipboard.read({offset})` → `{text,html,file}` / `Clipboard.clear` | ✅ | full `{text,html,file}` read + `Clipboard.clear` DONE Chunk G 2026-06-21; `offset` (Nth history entry, backed by `ClipboardHistory`; offset 0 = live pasteboard) DONE Chunk Clipboard-offset 2026-06-22 |
| **`Keyboard` namespace** — `Keyboard.Shortcut` (`{key, modifiers}`) | 🟡 | **exported** (`index.ts:878`) — namespace **not** absent; `Shortcut` is a local type; shortcuts not applied to UI |
| `Keyboard.KeyModifier` / `Keyboard.KeyEquivalent` / `Keyboard.Shortcut.Common` | ✅ | `Shortcut.Common` populated (`index.ts:881`); `KeyModifier` (incl. "win") + `KeyEquivalent` unions now exported (Chunk I2, 2026-06-21) |
| `getApplications` / `getDefaultApplication` / `getFrontmostApplication` (+ `Application` type) | ✅ | real; `Application` interface **is** exported (`index.ts:760`) |
| `getSelectedText` / `getSelectedFinderItems` | ✅ | |
| `open` / `trash` / `showInFinder` (imperative System-Utilities fns) | ✅ | exported (`index.ts:547`/`770`/`774`) + real host handlers (`AppController.swift:2035`/`2300`/`2210`) |
| `captureException` (error reporting) | 🟡 | exported + host handler (`AppController.swift:2116`) but logs only & **discards** message/stack (privacy) |
| `closeMainWindow` (+ `PopToRootType` enum: `Default`/`Immediate`/`Suspended`) | ✅ | `PopToRootType` **is** exported (`index.ts:475`); `clearRootSearch` / `popToRootType` options decorative (🟡) |
| `clearSearchBar` | ⬜ | exported but an empty no-op (import-safe; no RPC) |
| `popToRoot` | 🟡 | just closes the palette (doesn't pop nav to root and stay open) |
| Window Management API — `getActiveWindow` / `getWindowsOnActiveDesktop` / `getDesktops` / `setWindowBounds` + `WindowManagement.Window` / `.Desktop` / `.DesktopType` | ✅ | AX-backed (Chunk WM-2, 2026-06-23): `WindowEnumerator` (InvokeServices) — AX enumeration + `_AXUIElementGetWindow` id-cache + `setWindowBounds`; `getDesktops` = one desktop per display (Spaces not faked); needs Accessibility |

### A.9 `@raycast/utils` hooks

| API | State | Gap / pending |
|---|---|---|
| `usePromise` / `useCachedState` / `useCachedPromise` / `useFetch` / `useExec` / `useSQL` / `useForm` / `useLocalStorage` / `useFrecencySorting` / `useAI` | ✅ | present and used by real extensions |
| `mutate` / `MutatePromise` (`optimisticUpdate` / `rollbackOnError`) | ✅ | working runtime `mutate`; `optimisticUpdate` / `rollbackOnError` now honored (Chunk H); useCachedPromise cache-write is a follow-up |
| Pagination (function-form source in `useFetch`/`useCachedPromise`) | ✅ | `usePromise` + `useFetch` (url-as-fn) + `useCachedPromise` accumulate pages (`mergePages`) + expose `pagination`, 2026-06-21 |
| `useStreamJSON` | ✅ | **top-level array streamed incrementally via `createArrayStreamParser` (Chunk I-stream, 2026-06-21)**; load-whole fallback for `dataPath` (nested array), non-array, or malformed JSON. Residuals: `dataPath` nested-array streaming + progressive mid-stream `setData` still pending |
| `useAI` streaming (`.on('data')` token stream) | 🟡 | resolves once; no progressive tokens |
| `getFavicon` / `getAvatarIcon` / `getProgressIcon` | ✅ | |
| `createDeeplink` / `withCache` / `OAuthService` / `withAccessToken` / `getAccessToken` | ✅ | present |
| `runPowerShellScript` | ⬜ | throws on macOS (expected/by-design) |

### A.10 OAuth, AI, Browser Extension & Tools

| API | State | Gap / pending |
|---|---|---|
| `AI.ask(prompt, {model, creativity, system})` | 🟡 | real host RPC (Anthropic); `system` honored; `model`/`creativity` sent but **dropped host-side** (`AppController.swift:1856`); `signal` not honored |
| `AI.Creativity` (type / `none`…`maximum` \| 0–2) | 🟡 | accepted in `ask`, not modeled as a type (dropped host-side) |
| `AI.ask` streaming / Promise-as-EventEmitter | ⬜ | single resolve only |
| `AI.Model.*` | 🟡 | Proxy returns the key string; no real model metadata |
| `OAuth.PKCEClient` (authorizationRequest/authorize/set·get·removeTokens) | ✅ | host-driven, tokens in Keychain |
| `OAuth.PKCEClient.Options` (`redirectMethod` / `providerName` / `providerIcon` / `providerId` / `description`) | 🟡 | client constructs; option fields not modeled as a named type |
| `OAuth.RedirectMethod` enum (`Web` / `App` / `AppURI`) | ✅ | exported (`index.ts:715`) |
| `OAuth.TokenSet` (+ `isExpired()`) / `TokenSetOptions` / `TokenResponse` | 🟡 | `TokenSet`/`TokenResponse` exported with `isExpired()`; `TokenSetOptions` not a distinct export |
| `OAuth.AuthorizationRequest` (+ `toURL()`) / `AuthorizationRequestOptions` / `AuthorizationOptions` / `AuthorizationResponse` | ✅ | exported with working `toURL()` → `buildAuthorizeURL` (`index.ts:702`/`745`) |
| OAuth prebuilt provider configs (GitHub/Slack/Google/Linear/Zoom) | ⬜ | extensions must hand-roll endpoints |
| `BrowserExtension.getContent` (+ `cssSelector` / `format` / `tabId`) / `getTabs` / `BrowserExtension.Tab` | 🟡 | real RPCs via `BrowserDriver` (`AppController.swift:1879`); `Tab` exported; markdown conversion is a regex approximation |
| AI Extensions / Tools (`src/tools/*.ts`) | ⬜ | manifest `tools[]` parsed for display only — not invoked |
| `Tool.Confirmation<T>` type + `confirmation` export (`style`/`info`/`message`/`image`) | ⬜ | AI-extension confirmation API absent |
| MCP client / Skills | ⬜ | v2 |

### A.11 Manifest & command modes

| API | State | Gap / pending |
|---|---|---|
| Command modes `view` / `no-view` | ✅ | accepted at discovery |
| Command mode `menu-bar` | ✅ | accepted at discovery + rendered (`AppController.swift:3001`/`3020`); see §A.5 |
| Arguments `text` / `password` / `dropdown` | ✅ | inline search-bar chips |
| `LaunchProps` (`arguments` / `draftValues` / `launchContext` / `fallbackText`) | ✅ | `arguments` **and** `launchContext` delivered (`child.ts:140`/`143`); **`LaunchProps` type now exported (Chunk I2, 2026-06-21)**; **`fallbackText` populated (Chunk Fallback, 2026-06-21)** — host `INVOKE_FALLBACK_TEXT` → child `launchProps.fallbackText`; `draftValues` not passed |
| `LaunchType` enum (`UserInitiated` / `Background`) / `LaunchContext` | ✅ | `LaunchType` exported (§A.7); **`LaunchContext` type exported (Chunk I-residuals, 2026-06-21)** |
| Background refresh (`interval`) | 🟡 | scheduled for `no-view` commands (`AppController.swift:3017`) |
| Fallback commands | ✅ | **user-curated ordered list (Settings → Commands → Fallback Commands); shown in root only on no-match query (no command + no app + no calc); selecting launches command with query as `launchProps.fallbackText` (Chunk Fallback, 2026-06-21)** |
| `disabledByDefault` | ✅ | **hidden from root until user enables (Commands pane toggle → `enabledCommands` opt-in) (Chunk Fallback, 2026-06-21)** |
| Preferences `textfield`/`password`/`checkbox`/`dropdown`/`appPicker` (+`required`) | ✅ | `file`/`directory` — ⬜; per-platform `default` — 🟡 |
| `tools[]` / `ai{}` objects | 🟡 | parsed for the Commands detail panel; not executed |

### A.12 Recommended implementation order

- **P0 — crash-prevention & correctness:** ~~graceful-degrade every undefined component~~ **DONE 2026-06-21** (the `Action.*`, `Form.TagPicker`/`FilePicker`/`LinkAccessory`, `MenuBarExtra.*` members are all defined; nothing throws "Element type is invalid"; `Keyboard` exported). Remaining: render `List.EmptyView`/`Grid.EmptyView`; fire `onChange` for **Checkbox**; honor `Action.style` (destructive) + bind custom `Action.shortcut` to the exported `Keyboard.Shortcut`.
- **P1 — depth:** _(Done 2026-06-21: List/Grid **pagination** (+ `useFetch`/`useCachedPromise`); `Form.PasswordField` masking + native `DatePicker`; clickable `Detail.Metadata.Link` + `TagList` chips + `Color` in Metadata; `List`/`Detail` `isLoading`; List/Grid accessories incl. `Color`/`Icon` tint + `FileIcon`; grouped `ActionPanel.Section` + drill-in `Submenu`; `open`/`trash`/`showInFinder`; `mutate` runtime. controlled searchText/throttle/filtering + Dropdown storeValue landed (Chunk F, 2026-06-21). **`Alert.Options` `icon`/`dismissAction.style`/`rememberUserChoice` + `Clipboard.read` full `{text,html,file}` + `Clipboard.clear` landed (Chunk G, 2026-06-21). `Toast` primary/secondary actions (`Toast.ActionOptions`) landed (Chunk G′, 2026-06-21) — P1 feedback group complete. `TagList.Item` `onAction` + TagList wrapping + `DatePicker` `min`/`max`/type + typed `Date` onChange + `optimisticUpdate`/`rollbackOnError` landed (Chunk H, 2026-06-21).**)_ **`Clipboard.read` `offset` (Nth clipboard-history entry) landed (Chunk Clipboard-offset, 2026-06-22)** — the last cleanly-tractable micro-residual. Remaining (deferred, NOT micro-fixes — verified 2026-06-22): `isFullDay()` (needs the picker *type* threaded through the value — host emits a full ISO even for date-only) + TagPicker→array (needs a real multi-select control, not array-wrapping a single-select dropdown); useCachedPromise optimistic cache-write.
- **P2 — breadth / v2:** _(Done: `menu-bar` + `NSStatusItem` + `MenuBarExtra.*`; `launchCommand`; `updateCommandMetadata`; `BrowserExtension`. **`Icon` coverage + `Color.Dynamic` + `Image.Mask` + dynamic light/dark images substantially DONE (Chunk I, 2026-06-21):** 102-member `Icon` enum + `IconSymbol` validated fallback; `Color.Dynamic({light,dark})` exported; `Image.Mask` Circle/RoundedRectangle honored; dynamic `{source:{light,dark}}` dispatched by appearance. Residual tail: literal-complete ~250-member `Icon` enum; `Image.tintColor` top-level export; appearance-change live re-render. **Named-type exports + real `environment` fields (Chunk I2, 2026-06-21):** `LaunchProps`, `PreferenceValues`, `Preferences` (augmentable), `Navigation`, `Form.Values`/`FormValues`, `Keyboard.KeyModifier` (incl. "win"), `Keyboard.KeyEquivalent` exported; `environment.appearance` real (NSApp.effectiveAppearance, main-thread-guarded); `textSize` host-provided; `canAccess(AI)` real (AIService.hasStoredKey()). Still pending: live appearance-change push; non-AI `canAccess`. **`LaunchContext` type exported (Chunk I-residuals, 2026-06-21)** — no longer pending. **`MenuBarExtra.Item` `alternate`/`shortcut` + click `ActionEvent` (`{type:"left-click"}`) + `MenuBarExtra.ActionEvent` type + typed `MenuBarItemProps` DONE (Chunk I-menubar, 2026-06-21)** — caveats: right-click distinction not possible (NSMenuItem); named-key `KeyEquivalent` mapping latent. **`LaunchContext`/`Form.Event`/`Form.Event.Type`/`Image.ImageLike`/`Image.Source` exported (Chunk I-residuals, 2026-06-21)** — named-type export item fully DONE.)_ Remaining: AI streaming (+ `signal`; honor `model`/`creativity` host-side) + Tools (`Tool.Confirmation`)/MCP/Skills; OAuth provider presets; export remaining named types (`Cache.*` sub-types only). **Window Management: WM-1 (cycling/thirds) + WM-2 (extension `WindowManagement` API, AX-backed) + WM-3/builder-parity (Create Window Command — Raycast-style 9-anchor + Size(Auto/pt) + Offset + live-preview editor) DONE 2026-06-23; WM-4 multi-app Create Window Layout (reuses the editor) / WM-5 Stage Manager+presets remain.** _(Fallback commands + `disabledByDefault` DONE — Chunk Fallback, 2026-06-21. `useStreamJSON` top-level streaming DONE — Chunk I-stream, 2026-06-21; residuals: `dataPath` nested-array streaming + progressive mid-stream `setData`.)_

---

*This is the build artifact. Phase 0's spine is the make-or-break spike — and it is not "done" until the red-team isolation test, the extension-first-paint budget, and the large-list mutation benchmark all pass. Start there.*