# Remediation 02 — Core runtime stubs that need real wiring

Scope: the runtime primitives that are present as exports (so extensions *load*) but
are no-ops / throw / return defaults when *called*. All stub code lives in
`packages/api/src/index.ts` lines 358–381. RPC plumbing already exists end-to-end
(`__setHostBridge` → `globalThis.__invokeHostRpc__` → `rpc()` → schema `kind:"rpc"` →
host `ExtensionHost.handle` → `allowedRPC` gate → `AppController.handleCapability`),
so most of these are "add a method + an allowlist entry + a switch case". The exception
is navigation, which needs a *new render path*, not just an RPC.

Counts are extensions whose `blockers`/`degraded`/`unknown`/`apiImports` reference the
symbol, from `tools/compat-check/report-sandboxed/results.json` (2961 entries total).

| Capability | Extensions | Effort | Risk |
|---|---|---|---|
| `useNavigation().push/pop` (+ render-on-push) | 815 | **L** | **High** |
| `confirmAlert` | 650 | S | Low |
| `Cache` get/set/has/remove/clear | 279 | S–M | Low |
| `openExtensionPreferences` | 376 | M | Medium |
| `openCommandPreferences` | 153 | M | Medium |
| `captureException` | 37 | S | Low |

---

## 1. `useNavigation().push / pop` — programmatic navigation (PRIORITY)

**815 extensions.** This is the single most impactful gap. Examples: 1bookmark,
1password, 40-questions, ableton-live, accordance, advanced-replace,
agent-client-protocol, agent-usage, ai-by-vercel, ai-gen, ai-git-assistant,
ai-screenshot, ai-stats, ai-usage-tracker, algorand.

### Current state (why it's a no-op)

- `packages/api/src/index.ts:379-381` — `useNavigation()` returns `{ push: () => {}, pop: () => {} }`.
  Pure client-side no-op; the pushed `ReactNode` never reaches the host.
- `packages/api/src/index.ts:19-33` — the design comment + `PushTarget`. `MAX_EAGER_PUSH_DEPTH = 0`
  means `PushTarget` renders `null`: the declarative `Action.Push` target is **deliberately
  not rendered** into the tree to avoid eagerly mounting every row's target (recursion + mount
  side-effects, e.g. apple-notes firing one AppleScript per row just from searching).
- `packages/api/src/index.ts:192-196` — `Action.Push` wraps `target` in `<PushTarget>` and emits a
  host `action` element with `variant:"push"`. Because `PushTarget` returns `null`, the pushed
  surface node is absent from `action.children`.
- Host side **already has the navigation machinery**: `AppController.swift:59-73`
  (`navStack: [ViewNode]`, `activeTree` renders `navStack.last`), `:118-121` (Esc pops),
  `:2214-2224` (`variant:"push"` snapshots `n.children.first(where: surface type)` via
  `deepCopy` and pushes). **But** because the target renders to `null` upstream,
  `n.children` has no surface node, so even *declarative* `Action.Push` snapshots nothing
  today. Programmatic `useNavigation().push` has no path to the host at all.

So there are two distinct bugs: (a) the push target is never serialized, and (b) programmatic
push/pop is unwired. Both are solved by the same mechanism: **render-on-push as a separate,
on-demand surface render**, rather than pre-rendering targets in the base tree.

### The model to build: dynamic render-target snapshots mid-stream

Keep the "never render targets eagerly" invariant (it's correct — see the apple-notes note at
`index.ts:22-24`). Instead, render a target **only when it is actually pushed**, as a fresh
top-level render into the same surface, tagged so the host stacks it.

Concretely, every push (declarative or programmatic) carries a `ReactNode`. On push we ask the
reconciler to render *that node* as the surface's new root and emit its mutations under a new
"navigation frame" id; the host pushes a frame onto `navStack` and renders it; pop tells the
child to re-render the previous frame.

#### Changes

**`schema/src/index.ts`** — new messages on both directions (mirror in the Swift `Codable`):

- child → host (`HostBound`): add
  `| { kind: "navPush"; frame: number; title?: string }`
  emitted right *before* the `mutations` for the pushed subtree, so the host knows the next
  commit belongs to a new stacked frame rather than the base surface. (Alternatively, tag the
  existing mutations message: add optional `frame?: number` to
  `{ kind:"mutations"; commit; ops; frame? }` — lower-churn, preferred.)
- host → child (`ChildBound`): add
  `| { kind: "navPop"; frame: number }` so the child re-mounts the previous frame's element and
  re-streams it (handlers in the popped frame are released).

**`runtime/reconciler/src/index.ts`** — today there is one global container/`root`
(`:209-221`) and a single `onCommit` (`:44`). To stack frames without losing the base tree's
handlers, support **multiple roots**:

- Add `Surface.pushRoot(element): number` and `Surface.popRoot(): void`. `pushRoot` creates a
  *new* `R.createContainer` with its own container id, renders `element` into it, and emits its
  ops tagged with the frame id (extend `onCommit` to carry `frame`). `popRoot` unmounts the top
  container (releasing its handler registry entries) and re-activates the parent.
- The handler registry (`registry`, used at `:232`/`:237`) must be **per-frame** or
  frame-namespaced so `invoke`/`searchText` route to the live frame's handlers and a popped
  frame's stale handlers can't be invoked.

**`packages/api/src/index.ts`**:

- Replace the no-op `useNavigation` (`:379-381`) with a real one backed by a process-global
  navigation controller (same pattern as `BRIDGE_KEY`/`__setHostBridge`, `:279-288`):
  ```ts
  type NavController = { push: (v: ReactNode) => void; pop: () => void };
  const NAV_KEY = "__invokeNav__";
  export function __setNavController(c: NavController): void {
    (globalThis as Record<string, unknown>)[NAV_KEY] = c;
  }
  export function useNavigation(): NavController {
    return ((globalThis as Record<string, unknown>)[NAV_KEY] as NavController)
      ?? { push: () => {}, pop: () => {} };
  }
  ```
- `Action.Push` (`:192-196`): stop wrapping the target in `<PushTarget>`/rendering it inline.
  Instead make its `onAction` call `useNavigation().push(target)` so declarative and programmatic
  push share **one** code path (render-on-push). The host's `variant:"push"` snapshot branch
  (`AppController.swift:2215-2224`) is then removed in favor of the `navPush` stream.
- `PushTarget`/`PushDepthContext`/`MAX_EAGER_PUSH_DEPTH` (`:27-33`) can be deleted once targets
  are never rendered eagerly.

**`runtime/node-host/src/child.ts`**:

- Wire `__setNavController` (next to `__setHostBridge` at `:19`/`:37-43`). `push(v)` →
  `surface.pushRoot(v)` (emits a tagged commit, which `onCommit` at `:108` already forwards as
  `mutations`, now with `frame`); also `send({ kind:"navPush", frame })` if using the separate
  message. `pop()` → `surface.popRoot()`.
- Handle incoming `navPop` in the `sock.on("data")` switch (`:74-92`) so Esc-driven pops from the
  host re-render the previous frame and release the popped frame's handlers.

**`apps/macos/Sources/InvokeShell` (host)**:

- `ExtensionHost.swift:136-142` (`case "mutations"`): when `msg.frame` differs from the current
  frame, route ops to a *new* `ViewTree` (a stacked frame) rather than the base `tree`. Expose
  `onNavPush(frame, title)` / keep `navPop` send on Esc.
- `AppController.swift`: the `navStack` (`:61`), `activeTree` (`:63-73`), Esc-pop (`:118-121`),
  and back-chevron title (`:987-988`) infrastructure is already present and largely reusable —
  switch it from "snapshot a child node" to "own the stacked `ViewTree` the host built from the
  framed mutations". On Esc, send `ChildBound.navPop` so the child releases handlers, then pop
  `navStack`.

#### Why L / High risk

Touches all four layers (api, reconciler multi-root + per-frame handler registry, schema, Swift
host) and changes the commit-routing contract. Multi-root React-reconciler handler isolation is
the subtle part: getting `invoke`/`searchText` to target the live frame, and releasing popped
frames, is where regressions (stale handlers firing, leaked effects) will appear. Mitigation:
land reconciler multi-root behind a test in `runtime/reconciler` first; keep the existing
single-frame path working when no push has occurred.

---

## 2. `confirmAlert` — 650 extensions

Examples: 1bookmark, adguard-home, advanced-replace, aegis, agent-client-protocol, agent-usage,
ai-by-vercel, alacritty, algorand, alice-ai, alpaca-trading, alwaysdata, amazon-search, anki,
anonaddy.

**Current state:** `packages/api/src/index.ts:376` — `confirmAlert` returns `false`
unconditionally. Any "delete?/overwrite?" flow silently no-ops (user clicks the action, nothing
happens) — a confusing degradation, not just a missing feature.

**Changes:**
- `packages/api/src/index.ts:376`: `return rpc("confirmAlert", opts) as Promise<boolean>;`
  (pass through `title`, `message`, `primaryAction`, `dismissAction`, `icon`).
- `schema/src/index.ts`: no new message kind needed — rides the existing `rpc`/`rpcResult`
  channel; the host reply is a boolean `result`.
- `ExtensionHost.swift:36-43`: add `"confirmAlert"` to `allowedRPC`.
- `AppController.swift` `handleCapability` switch (`:1559+`): add
  `case "confirmAlert":` → present a modal `NSAlert` (title/message, primary +
  cancel buttons, destructive styling when `primaryAction.style == "destructive"`); return
  `.bool(response == .alertFirstButtonReturn)`. **Must reply on the main queue** (it already
  dispatches via `DispatchQueue.main.async` at `ExtensionHost.swift:155`), and run the alert
  modal so the async `rpc` resolves only after the user chooses.

**Effort S / risk Low.** Self-contained; only nuance is making the modal block the RPC reply
correctly so the extension's `await confirmAlert(...)` resolves with the real choice.

---

## 3. `Cache` — get/set/has/remove/clear — 279 extensions

Examples: 1bookmark, 1password, accordance, adb, akkoma, anonaddy, another-boring-piece,
app-updates, appcleaner, append-clipboard, arc-helper, atlassian-data-center, audio-device,
auto-quit-app, bark.

**Current state:** `packages/api/src/index.ts:358-364` — `get`→`undefined`, `has`→`false`,
`remove`→`false`, `clear`→no-op, `set`→**throws** (`unsupported("Cache.set")`). So a write throws
and reads always miss; extensions that cache API responses re-fetch every time or crash on first
`set`.

**Key constraint:** Raycast's `Cache` API is **synchronous** (`get`/`set` return immediately), but
the host RPC is async (`rpc()` returns a Promise). Two options:

- **(M, faithful)** Make the runtime hydrate a per-extension cache snapshot at startup
  (env var like `INVOKE_PREFERENCES`, or a one-shot sync read before lockdown in `child.ts`),
  hold it in-memory in the `Cache` class for synchronous get/set/has, and **write-through**
  asynchronously to the host via `rpc("cache.set", …)`. Mirror the existing `localStorage.*`
  capability set (`ExtensionHost.swift:39-40`, `AppController.swift:1591-1603`,
  `extStorageGet/Set/Remove/Clear/All`) — `Cache` is essentially a second namespaced store with a
  `capacity`/`namespace` option.
- **(S, partial)** Back `Cache` with a plain in-process `Map` (synchronous, no throw). Fixes the
  crash and intra-session caching for all 279 immediately; loses cross-launch persistence. Good
  interim step; upgrade to write-through later.

**Changes (M path):**
- `packages/api/src/index.ts:358-364`: replace the class body with a `Map`-backed sync impl seeded
  from an injected snapshot; `set`/`remove`/`clear` also fire-and-forget `rpc("cache.set"/...)`.
- `ExtensionHost.swift:36-43`: add `"cache.get"`(if async path used), `"cache.set"`,
  `"cache.remove"`, `"cache.clear"`.
- `AppController.swift` `handleCapability`: add cases reusing the `extStorage*` helpers under a
  `cache:` key prefix (namespaced per `currentExtId`, like localStorage).
- `child.ts`: read the cache snapshot before `lockdown()` (`:54-55`) and pass it to the api via a
  setter, same shape as how preferences arrive.

**Effort S–M / risk Low.** The sync-API-over-async-host mismatch is the only design call.

---

## 4. `openExtensionPreferences` (376) / `openCommandPreferences` (153)

`openExtensionPreferences` examples: 1password, 42-api, adhan-time, aegis, air-quality,
anna-s-archive, apfel, app-icon-generator, append-to-file, apple-reminders,
atomberg-raycast-extension, auto-quit-app, bark, battery-optimizer, beehiiv.
`openCommandPreferences` examples: 42-api, accordance, aegis, agent-usage, app-updates,
apple-notes, apple-reminders, aranet-co2-monitor, arc, audio-device, auto-quit-app, avatar, bark,
bartender, base-stats.

**Current state:** `packages/api/src/index.ts:374-375` — both are `async () => {}` no-ops.
Extensions that, on first run, detect a missing API key and call `openExtensionPreferences()` to
let the user fill it in just silently do nothing — the user is stuck.

**Changes:**
- `packages/api/src/index.ts:374-375`:
  `openExtensionPreferences` → `await rpc("preferences.open", { scope: "extension" })`;
  `openCommandPreferences` → `await rpc("preferences.open", { scope: "command" })`.
- `ExtensionHost.swift:36-43`: add `"preferences.open"`.
- `AppController.swift` `handleCapability`: add `case "preferences.open":` → open the existing
  Settings window focused on the current extension's preferences detail. The host already renders
  per-extension/per-command preferences in Settings (recent commits: "Settings detail: Raycast-style
  preference + command layout", `SettingsView.swift`/`AppSettings.swift`), and `currentExtId` is
  tracked (commit c9e14ac) — so this is "summon Settings + select extension (+ command for the
  command scope)". The child process can't *read back* edited prefs live (they arrive via
  `INVOKE_PREFERENCES` env at launch, see `getPreferenceValues` `:342-347` and `preferences.get`
  returning `{}` at `AppController.swift:1589-1590`); document that edited prefs apply on next
  command launch, matching Raycast's relaunch behavior.

**Effort M / risk Medium.** Wiring is small; the work is the Settings-window deep-link/focus and
deciding the command-scope target. Distinguish the two scopes via the `scope` param.

---

## 5. `captureException` — 37 extensions

Examples: alpaca-trading, anonaddy, aws, bitwarden, browser-tabs, copy-path, cut-out,
dashlane-vault, dub, folder-cleaner, github, haystack, hide-files, ip-geolocation, ivpn.

**Current state:** `packages/api/src/index.ts:377` — `captureException` is a no-op. Functionally
harmless (it's telemetry), so these 37 already *work*; the only loss is diagnostic. Lowest
priority.

**Changes:**
- `packages/api/src/index.ts:377`: forward to the host as a log/diagnostic, e.g.
  `rpc("captureException", { message: String(error), stack: (error as Error)?.stack })`
  (fire-and-forget; never throw).
- `ExtensionHost.swift`: either add `"captureException"` to `allowedRPC` and log it in
  `handleCapability`, **or** simplest: emit it through the existing `kind:"log"` stream
  (`schema/src/index.ts:47`, handled at `ExtensionHost.swift:143-144`) — no new RPC needed.

**Effort S / risk Low.** Reuse the log channel; no host UI.

---

## Suggested order

1. **confirmAlert** (S, 650, pure RPC) and **captureException** (S, 37, log channel) — fastest
   wins, no new render machinery.
2. **Cache** interim `Map` impl (S, 279) — stops the `set` crash immediately; upgrade to
   write-through later.
3. **openExtension/CommandPreferences** (M, 376/153) — needs Settings deep-link.
4. **useNavigation push/pop** (L, 815) — the headline fix; schedule the reconciler multi-root work
   deliberately and gate it behind tests, since it touches every layer and the commit-routing
   contract.

Total distinct extensions touched across these capabilities: ~1.6k of 2961 (heavy overlap —
many import several of these symbols), with navigation alone gating 815.
