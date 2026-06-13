# Gap 01 — Node built-ins / sandbox escape + `useExec` / `runPowerShellScript`

The single largest blocker in the corpus. Of **2961** scanned extensions, **1023** are
reported by `report-sandboxed/results.json` `topGaps` under *"denied Node built-ins in
sandbox"*; **1039** are in scope once `useExec`/`runPowerShellScript` are folded in. **510**
of these have *no other blocker* — i.e. solving this gap alone makes them runnable.

All counts below are recomputed directly from `report-sandboxed/results.json` against the
live allowlist `runtime/node-host/src/safe-builtins.json` (the 23 pure-compute builtins) plus
the curated `os` shim (`runtime/node-host/src/import.ts:40`). A builtin is "forbidden" when it
is in `node:module`'s `builtinModules` but not in the safe list and not `os`.

---

## 1. Forbidden-builtin histogram

| Built-in | # extensions | Capability class |
|---|---|---|
| `fs` (+ `fs/promises`) | 789 | filesystem |
| `child_process` | 522 | subprocess / arbitrary exec |
| `https` | 48 | network (HTTP client) |
| `http` | 23 | network (HTTP client/server) |
| `net` | 12 | raw TCP sockets |
| `readline` | 6 | tty/stdin (mostly dead in GUI) |
| `dns` | 6 | network (resolution) |
| `tls` | 5 | network (raw TLS) |
| `dgram` | 4 | network (UDP) |
| `module` | 3 | loader (escape risk) |
| `http2` | 1 | network |
| `v8` | 1 | introspection |
| `vm` | 1 | code-gen (escape risk) |

Plus, from `utilsImports`/`apiImports` (these import to a host shim, not a raw builtin):

| Symbol | # extensions | Notes |
|---|---|---|
| `useExec` (`@raycast/utils`) | 41 | React hook wrapping `child_process.execa` |
| `runPowerShellScript` (`@raycast/api`) | 18 | Windows-only; macOS no-op candidate |

Capability groupings (a single extension can be in more than one):

- **filesystem (fs/fs-promises):** 789
- **subprocess (`child_process` + `useExec` + `runPowerShellScript`):** 548
- **network (`net`/`http`/`https`/`http2`/`dns`/`tls`/`dgram`):** 81 — of which **19** use a
  *raw socket* family (`net`/`dns`/`tls`/`dgram`) that an HTTP-only shim would not cover.
- **fs-only** (no subprocess, no net — pure local file readers, the cleanest win): **442**

---

## 2. Current Invoke state (file:line)

The sandbox denies everything not on the safe list, by default, in three layers
(`runtime/node-host/src/sandbox.ts`):

- ESM `import`: a `module.register("./deny-loader.mjs")` resolve hook —
  `runtime/node-host/src/sandbox.ts:~178`.
- CJS `require`: `Module._load` patch, pinned non-writable — `sandbox.ts:~140-176`.
- Native escapes: `process.binding`/`_linkedBinding`/`dlopen` and `process.report.*` neutered,
  fail-closed — `sandbox.ts:~57-104`.
- `isDeniedBuiltin()` is `!SAFE_BUILTINS.has(name)` — `sandbox.ts:~45`; safe list at
  `runtime/node-host/src/safe-builtins.json` (23 pure-compute modules).
- Lockdown is invoked from `runtime/node-host/src/child.ts:54`, **after** trusted infra loads
  and **before** the extension bundle imports. `INVOKE_TRUSTED=1` skips it entirely
  (`child.ts:54-58`) → full Node, like Raycast.

Existing curated redirects (the template every new capability should follow):

- **`os`** → read-only shim `os-safe.mjs`, wired in both the ESM loader and the CJS `_load`
  patch (`sandbox.ts:~115`, `CURATED_OS_CJS`), and excluded from the scan
  (`import.ts:40`, `CURATED_BUILTINS`).
- **`run-applescript`** (npm pkg, not a builtin) → `RUN_APPLESCRIPT_CJS` shim that forwards to
  the host `runAppleScript` RPC instead of spawning `osascript` via `child_process`
  (`sandbox.ts:~31`, redirect at `sandbox.ts:~118`).

The RPC bridge (the *only* path to host authority):

- Child side: `globalThis.__invokeHostRpc__`, set by `child.ts:37` via `__setHostBridge`
  (`packages/api/src/index.ts:281`); every API call funnels through `rpc()`
  (`packages/api/src/index.ts:284-288`).
- IPC contract: `{ kind:"rpc", id, method, params }` / `{ kind:"rpcResult", id, result?, error? }`
  — `schema/src/index.ts:49,56`.
- Host allowlist (denial enforced host-side, not by SDK convention):
  `ExtensionHost.allowedRPC` — `apps/macos/Sources/InvokeShell/ExtensionHost.swift:36-43`;
  unknown methods are rejected at `ExtensionHost.swift:148-152`.
- Host dispatch + consent: `AppController.handleCapability` —
  `AppController.swift:1554`. The two **gated** capabilities that establish the consent
  pattern we should reuse:
  - `runAppleScript` (`AppController.swift:1604`): blocks `do shell script`, then
    default-deny per-extension consent dialog `ensureAppleScriptGrant()`
    (`AppController.swift:1539`).
  - `executeSQL` (`AppController.swift:1634`): opens `SQLITE_OPEN_READONLY` with an authorizer
    that allows only SELECT/READ/FUNCTION, and a **per-(extension, canonical-file)** consent
    `ensureSQLGrant()` (`AppController.swift:1673`) — the model for scoped fs grants.
- Grant/trust persistence: `AppSettings.appleScriptGrants` / `sqlGrants` /
  `trustedExtensions` (`AppSettings.swift:48-58`); the trust unit is the *extension*, keyed by
  `extGrantKey(forId:)` (`AppController.swift:1531`). Trusted extensions are launched with
  `trusted:` → `INVOKE_TRUSTED=1` (`AppController.swift:2024`).

Key insight: `executeSQL` already proves the "host holds the OS authority, the child gets a
narrow capability, consent is per-(extension, resource)" pattern end-to-end. A virtual `fs`
capability is the same shape with a different verb set.

---

## Option A — RPC-bridged virtual capabilities with consent prompts

Add curated builtin shims (`fs`, an HTTP-only `http`/`https`, a subprocess verb) that forward
to new host RPC methods, gated exactly like `executeSQL`. This is the architecturally
consistent path and keeps the default sandbox intact.

**A1 — Virtual `fs` (covers 789, incl. 442 fs-only)**

- *How extensions use it:* `readFileSync`/`readFile`/`existsSync` to read config, caches, app
  data; `writeFileSync` to export; `readdirSync`/`stat` to enumerate. Most are reads.
- *Build:* a `fs-safe.mjs` shim (mirror of `os-safe.mjs`) exporting the common surface
  (`readFile[Sync]`, `writeFile[Sync]`, `existsSync`, `readdir[Sync]`, `stat[Sync]`,
  `mkdir`, `rm/unlink`, `promises.*`). Each call forwards to host RPC `fs.read` / `fs.write` /
  `fs.readdir` / `fs.stat`. Sync variants are the hard part — the framed socket is async; a
  sync shim needs `Atomics.wait` on a `SharedArrayBuffer` worker, or accept that only the
  async/promise surface is faithful (a meaningful subset still fails on `*Sync`).
- *Consent:* reuse the `executeSQL` per-(extension, canonical-path) model
  (`ensureSQLGrant`, `AppController.swift:1673`). First read under a directory prompts; grant
  scopes to that path prefix. Writes prompt separately and are framed louder.
- *Files to change:* new `runtime/node-host/src/fs-safe.mjs`; redirect in `sandbox.ts`
  (`_load` patch + deny-loader, like `os`); add `"fs"` to `CURATED_BUILTINS` in
  `import.ts:40`; add `fs.*` to `ExtensionHost.allowedRPC` (`ExtensionHost.swift:36`); new
  cases in `handleCapability` (`AppController.swift:1554`) + new grant set in
  `AppSettings.swift`. Add `fs.read/write/...` to `schema/src/index.ts` (the method/params are
  already free-form strings, so the contract is method-name-only).
- *Pros:* default-deny preserved; host (which is not itself OS-sandboxed) mediates every path
  and can canonicalize + deny TCC-protected locations; per-resource auditability.
- *Cons:* large surface to faithfully shim; **sync API is the blocker** — many extensions use
  `readFileSync` at import time; path-prefix consent UX can get noisy; symlink/`..` traversal
  must be canonicalized host-side (the `executeSQL` resolveSymlinksInPath precedent).
- *Security:* arbitrary host fs is a file-disclosure + tamper primitive — must be default-deny,
  per-path, read/write split, with the same `do shell script`-style refusals for sensitive
  roots. Writes especially need a hard consent gate.
- *Effort:* **L** (sync-over-async + consent UX). *Risk:* **High**.
- *Unblocks:* up to **789** (442 fs-only run immediately; the rest need their other gaps too).
- *Examples:* 0x0, 1bookmark, abstract-api, accordance, aegis, agent-ecosystem-map, ai-gen,
  ai-screenshot, akkoma, alt-text-generator, android-adb-input, antd-open-browser,
  any-website-search, app-icon-generator, ableton-live.

**A2 — HTTP-only `http`/`https` shim (covers ~62 of the 81 network exts)**

- *How extensions use it:* `https.get`/`http.request` as a `fetch` substitute for API calls;
  a handful run a tiny local callback server for OAuth.
- *Build:* shim `http`/`https` `request`/`get` onto the host (or, simpler, onto the sandbox's
  already-available `fetch`/`undici` if the safe set permits outbound — confirm policy).
  Outbound client calls map cleanly; inbound `createServer` (OAuth loopback) needs a host-side
  listener capability and is rarer.
- *Consent:* per-extension network grant, optionally per-host-allowlist.
- *Files:* shim + `sandbox.ts` redirect + `CURATED_BUILTINS` + (if host-mediated) `allowedRPC`
  + `handleCapability` + schema method `net.fetch`.
- *Pros:* unblocks API-client extensions cheaply if outbound fetch is allowed; smaller surface
  than fs. *Cons:* does **not** cover the 19 raw-socket exts (`net`/`dns`/`tls`/`dgram`);
  loopback-server OAuth needs extra work.
- *Security:* outbound network is an exfiltration channel — gate per-extension; the 19
  raw-socket cases (port scanning, custom protocols) are higher-risk and should stay denied or
  trusted-only.
- *Effort:* **M**. *Risk:* **Medium**.
- *Unblocks:* ~**62** (HTTP-client subset). *Examples:* agent-usage, annotely, antigravity,
  audio-device, awesome-mac, bamboo-self-hosted, bento-me, bitwarden, caschys-blog, ccusage,
  cerebras, chatgpt, code-saver, codegrepper, http-status-codes.

**A3 — Subprocess via a narrow `runShell`/`execFile` capability (covers up to 548)**

- *How extensions use it:* `execa`/`exec`/`spawn` to call CLIs (git, brew, adb, docker,
  AppleScript, app binaries); `useExec` (41) is a React hook over the same; `runPowerShellScript`
  (18) is Windows-only.
- *Build:* a `child_process` shim forwarding `execFile`/`spawn` to a host `runShell` RPC; a
  `useExec` shim in `@invoke/utils`; `runPowerShellScript` → macOS no-op/error stub (it cannot
  run on macOS anyway, so for parity it should resolve-empty rather than block module load).
- *Consent:* this is the most dangerous capability — arbitrary command execution. Mirror the
  `runAppleScript` gate (`AppController.swift:1604`): default-deny per-extension consent dialog
  naming the binary, refuse a shell interpreter (`/bin/sh -c`) the way `do shell script` is
  refused, and prefer `execFile` (argv, no shell string) over `exec`.
- *Files:* shim(s) in `runtime/node-host/src` + `@invoke/utils`; `sandbox.ts` redirect;
  `CURATED_BUILTINS`; `allowedRPC` += `runShell`; `handleCapability` case; new grant set.
- *Pros:* unblocks the largest *additional* slice (many CLI-wrapper extensions). *Cons:*
  effectively re-grants arbitrary code execution through a side door — the consent prompt is
  doing all the security work.
- *Security:* **Highest risk in this document.** A consented `runShell` is equivalent to
  trusting the extension. Strongly argue this should be folded into Option C (trusted mode)
  rather than offered as a "narrow" capability, because there is no meaningful narrowing of
  "run this binary with these args."
- *Effort:* **M** (mechanics) but the *security design* is **L**. *Risk:* **Very High**.
- *Unblocks:* up to **548**. *Examples:* 1-click-confetti, 1bookmark, 1password, adb,
  advanced-speech-to-text, aerospace, ag-audioflow, alacritty, align-rtl, aws, ccusage,
  colima, devpod, bettertouchtool, immich. (`runPowerShellScript` no-op: bilibili, getcompress,
  microsoft-office, slack, spotify-player, visual-studio-code, vmware-vcenter.)

---

## Option B — Expand the safe set

Add modules to `safe-builtins.json` so they load unsandboxed inside the child.

- *How:* edit `runtime/node-host/src/safe-builtins.json` (single source of truth for both ESM
  deny-loader and CJS `_load`, per `sandbox.ts` header) — e.g. add `dns`, `readline`, `v8`.
- *Pros:* one-line change; zero shim work; instantly clears the verdict for exts using only the
  added module. *Cons:* a builtin on the safe list grants its **full ambient OS authority** with
  no consent and no host mediation — directly contradicts "Node built-ins denied by default"
  (PLAN.md §4.4).
- *Security:* **Unacceptable for `fs`/`child_process`/`net`/`http`/`https`/`tls`/`module`/`vm`**
  — each is a full disclosure / exec / exfiltration / sandbox-escape primitive (`vm` and
  `module` can mint a fresh loader and undo the lockdown). Only defensible for genuinely
  authority-free modules. `readline` (6) is near-useless in a GUI child but harmless. `dns`
  (6) leaks resolution/exfil — borderline, prefer Option A2. `v8` (1) exposes heap
  introspection — low but nonzero.
- *Effort:* **S**. *Risk:* **Low only for the truly safe few; Critical if misapplied to
  fs/exec/net.**
- *Unblocks:* realistically a handful (the ~6 `readline`-only / `dns`-only / `v8`-only exts);
  **must not** be used to "solve" the fs/child_process/net bulk.
- *Examples (safe-ish only):* bibmanager, claudecast, disk-usage, fuzzy-file-search,
  gemini-cli, mozeidon (readline); digger, ip-finder, network-diagnostics, popicons (dns);
  models-dev (v8).

---

## Option C — Trusted-mode UX (full Node per consented extension)

Make `INVOKE_TRUSTED=1` (no sandbox; full `fs`/`child_process`/`net`) reachable for any
extension via an explicit, well-surfaced per-extension trust decision.

- *How extensions use it:* whatever they want — this is real Node.
- *Current state:* the mechanism already exists end-to-end. `child.ts:54-58` skips `lockdown()`
  when `INVOKE_TRUSTED=1`; `AppSettings.trustedExtensions` + `setTrusted` (`AppSettings.swift:53`)
  persist the decision; launch passes `trusted:` (`AppController.swift:2024`). The remaining
  work is **UX + flow**: a clear, scary "Trust" affordance, and (ideally) a "this extension
  needs full system access — trust it?" prompt triggered when a sandboxed run hits a denied
  builtin, with one click to re-launch trusted.
- *Files to change:* mostly host UI — `SettingsView.swift` (a per-extension Trust toggle with a
  strong warning) and `AppController.swift` (intercept the denied-builtin failure and offer
  trust-and-relaunch). No shim or schema work.
- *Pros:* unblocks **all 1023+** in this category at once; faithful to how Raycast actually runs
  these (full Node); no per-API shim debt; honest about the security boundary instead of
  pretending a `runShell` consent is "narrow." *Cons:* trust is all-or-nothing per extension
  (no per-resource scoping); a trusted extension is fully unsandboxed in a host that is *not*
  itself OS-sandboxed — the blast radius is the user's whole account.
- *Security:* this is the correct place to concentrate the risk: make it explicit,
  default-off, with a loud warning, ideally gated behind the source being inspected/imported by
  the user. Far safer than silently broadening the safe set, and more honest than a "narrow"
  exec capability. Production should still layer a macOS App-Sandbox/seatbelt profile on the
  child (PLAN.md §4.4) so even trusted extensions are bounded by entitlements.
- *Effort:* **S–M** (UX only; engine exists). *Risk:* **Medium** (well-understood, opt-in,
  blast radius is documented).
- *Unblocks:* **all ~1039** in this gap category. *Examples:* every name listed above.

---

## Recommendation (priority order)

1. **Option C (trusted-mode UX)** first — S–M effort, the engine already exists, and it
   honestly unblocks the entire 1039 for power users who accept the risk. Couple it with a
   "needs full access → Trust & relaunch" prompt on denied-builtin failure.
2. **Option A1 (virtual fs)** next for the **442 fs-only** extensions, so common config/cache
   *readers* run sandboxed without trust. The `executeSQL` consent machinery
   (`AppController.swift:1673`) ports almost directly; solve sync-over-async with an
   `Atomics.wait` worker or ship async-only and accept partial.
3. **Option A2 (HTTP-only net)** for ~62 API-client extensions, gated per-extension.
4. **Option B** only for the genuine authority-free stragglers (`readline`, maybe `dns`/`v8`)
   — never for fs/child_process/net.
5. **Option A3 (subprocess)** is best *not* shipped as a "narrow capability" — fold arbitrary
   exec into Option C, because a consented `runShell` is functionally equivalent to trusting
   the extension anyway.

`runPowerShellScript` (18, Windows-only) should become a resolve-empty/no-op stub on macOS so
those extensions *load* even when that command can never run — a one-liner in
`packages/api/src/index.ts` independent of the above.
