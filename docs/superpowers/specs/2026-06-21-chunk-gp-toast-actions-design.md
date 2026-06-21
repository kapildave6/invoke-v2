# Chunk G′ — Toast primary/secondary actions (imperative callback channel) Design

**Part of the autonomous Raycast-parity push** (`[[autonomous-parity-goal]]`). Closes the remaining P1 feedback item: `Toast` `primaryAction` / `secondaryAction` (`Toast.ActionOptions` — `{ title, onAction, shortcut? }`) on both `showToast({...})` and `new Toast({...})`.

**Why its own chunk:** unlike `confirmAlert` (which resolves its RPC once and the api invokes the local `onAction` from the result), a toast **persists** and its `onAction` can fire at any later time (button click). That requires a **host→child imperative callback channel** — the reconciler's handler registry is React-tree-only, frame-scoped, and cleared each commit, so it can't hold a toast's callback. This chunk builds that small channel (reusable for any future imperative host→child callback) + the toast action UI.

## Global constraints
- World-class Raycast-quality UX; never ship system-default/janky UI.
- Faithful parity; don't fabricate third-party brands. Fixture imports `@raycast/api`.
- Commit on `main`. Relaunch `Invoke.app` after build+install.
- No Xcode/XCTest → TS verified via typecheck + `tsx` standalone; AppKit via build + fixture/relaunch/log.
- Never echo secrets.

## Architecture (verified)
- `child.ts` imports `__setHostBridge, showToast, Toast` from `@invoke/api` and shares the SAME module instance with the extension (the `globalThis` bridge, `packages/api/src/index.ts:491-505`).
- Host→child messages flow through `child.ts`'s `sock.on("data")` loop; `case "invoke": surface?.invokeHandler(msg.handler, msg.args)` (`child.ts:131-133`) dispatches action handlers via the reconciler registry (ids are `h<seq>`, `reconciler/index.ts:95`).
- The host sends an `invoke` message via `extHost.invoke(handler:args:)` — the SAME path Action `onAction` uses. Toast buttons reuse it.

---

## Item 1 — Imperative callback channel (`@invoke/api` + `child.ts`)

**Design:**
- `@invoke/api`: a `globalThis`-backed registry (same pattern as the bridge), holding **only the current toast's callbacks** (cleared + replaced on each new toast with actions, so no leak):
  - `__registerToastCallback(fn: () => void): string` → returns an id `icb-<n>` (the `icb-` prefix is distinct from reconciler `h<seq>` ids — no collision).
  - `__clearToastCallbacks(): void` → empties the map (called at the start of each toast.show that has actions, and on `hide()`).
  - exported `__invokeCallback(id: string, args: unknown[]): void` → looks up + calls the fn (no-op if absent).
- `showToast` / `Toast.show` / `Toast.reshow`: when `primaryAction`/`secondaryAction` is present, `__clearToastCallbacks()` then register each `onAction` → id, and include in the `toast.show` RPC payload: `primaryAction: { title, __handler: id, shortcut? }` and `secondaryAction: { ... }`. (Title-only when `onAction` absent.) The existing `{style, title, message}` payload is unchanged otherwise.
- `child.ts`: in `case "invoke"`, route by id prefix:
  ```ts
  case "invoke":
    if (typeof msg.handler === "string" && msg.handler.startsWith("icb-")) __invokeCallback(msg.handler, msg.args);
    else surface?.invokeHandler(msg.handler, msg.args);
    break;
  ```
  (Import `__invokeCallback` from `@invoke/api` alongside the existing imports.)
- Allow-list: no change (toast.show is already allow-listed; the invoke is host→child, not a child RPC).

## Item 2 — Host toast UI with action buttons (`AppController` + `PaletteWindow`)

**Current:** `toast.show` (`AppController.swift:2044`) builds a plain string → `palette.showToast(text)` (a centered auto-hiding label) or `hud.show(text)` when headless. No buttons.

**Design:**
- `AppController` `toast.show` handler: parse `primaryAction`/`secondaryAction` as `(title: String, handler: String)?` (handler = the `__handler` id). If present AND the palette is visible, call a new `palette.showToast(title:message:actions:)` overload that renders the toast with action button(s); on a button click, fire `extHost?.invoke(handler: id)` (the round-trip). If headless (palette not visible), fall back to `hud.show(text)` (actions dropped — rare for headless; documented).
- `PaletteWindow.showToast` gains an actions variant: `showToast(_ title: String, actions: [(title: String, onTap: () -> Void)])`. When actions are present: render the toast container with the title (left) + trailing pill button(s) (Raycast-style: subtle rounded, accent-tinted primary), and **do NOT auto-hide** (`toastHideWork` not scheduled) — the toast stays until replaced by a new toast, manually dismissed, or the surface changes. When no actions: unchanged (string + auto-hide).
- The existing string `showToast(_:)` stays for built-in callers; the actions variant is additive.
- A new toast (with or without actions) replaces the previous (cancel the old hide-work, clear old buttons). When an action is tapped, the toast can dismiss (Raycast dismisses the toast after the action runs) — dismiss then `extHost.invoke`.

## Item 3 — Fixture + verify

- `examples/toast-actions-demo/` (manifest mirrors `examples/empty-action-demo`, imports `@raycast/api`), a `view` command whose action runs:
  ```ts
  const toast = await showToast({ style: Toast.Style.Failure, title: "Upload failed", primaryAction: { title: "Retry", onAction: (t) => { t.hide(); showToast({ title: "Retrying…" }); } }, secondaryAction: { title: "Copy Error", onAction: () => Clipboard.copy("error details") } });
  ```
  (Match the actual `Toast.ActionOptions` `onAction` signature the shim exposes — adjust if `onAction` takes the toast instance or no args.)
- Verify: typecheck clean; `scripts/build-app.sh`; relaunch; `/tmp/invoke-run.log` shows the fixture loaded, no error. Human visual: the failure toast shows "Retry" + "Copy Error" buttons; clicking "Retry" fires its callback (a new "Retrying…" toast); clicking "Copy Error" copies; the toast stays visible until acted (doesn't auto-vanish).

## Testing strategy
- **Pure/standalone (`tsx`):** the callback registry — `__registerToastCallback` returns unique `icb-` ids, `__invokeCallback` calls the right fn, `__clearToastCallbacks` empties it. Exercised via a standalone `tsx` script.
- **AppKit/integration:** toast buttons + keep-visible + click round-trip → via build + fixture + relaunch + log + human visual.

## Out of scope (tracked elsewhere)
- Toast action **`shortcut`** firing via a key equivalent (display/registration only if cheap; functional toast-action shortcuts can be a follow-up — Raycast supports `⌘⇧Z`-style toast shortcuts, lower priority than the buttons).
- Headless (HUD) toast actions (no window to host buttons) — text-only fallback.
- `Clipboard.read` `offset` (separate P1 item).
