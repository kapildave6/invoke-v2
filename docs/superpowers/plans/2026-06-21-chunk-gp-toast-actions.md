# Chunk G′ — Toast primary/secondary actions Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Render `Toast` `primaryAction`/`secondaryAction` as buttons in the in-palette toast, firing their `onAction` via a new imperative host→child callback channel.

**Architecture:** A `globalThis`-backed callback registry in `@invoke/api` (ids `icb-<n>`) lets `showToast`/`Toast` register `onAction`s and send their ids in `toast.show`; `child.ts` routes `icb-` invoke ids to the registry. The host renders toast action buttons; a click reuses the existing `extHost.invoke(id)` → child → registry round-trip. The toast stays visible while it has actions.

**Tech Stack:** TS (`packages/api`, `runtime/node-host`), Swift/AppKit (`apps/macos`), TS fixture importing `@raycast/api`.

## Global Constraints
- World-class Raycast-quality UX; never ship system-default/janky UI.
- Faithful parity; do NOT fabricate third-party brands. Fixture imports `@raycast/api`.
- Commit on `main`. Relaunch `Invoke.app` after build+install.
- No Xcode/XCTest: TS via `npx tsc --noEmit` + `tsx` standalone; AppKit via `swift build --package-path apps/macos` + fixture/relaunch/log.
- The api may be instantiated more than once per child (compat shim) — the registry + its counter MUST live on `globalThis` (like `BRIDGE_KEY`), never module scope.
- Ignore SourceKit "cannot find X in scope" / "let binding" false-positives when `swift build` succeeds.

---

### Task 1: Imperative callback channel (api registry + toast.show payload + child.ts routing)

**Files:**
- Modify: `packages/api/src/index.ts` (registry near `BRIDGE_KEY` ~497; `showToast` ~525-546; `Toast` `reshow`/`show` ~464-483)
- Modify: `runtime/node-host/src/child.ts` (import ~19; `invoke` case ~131-133)
- Create (test): `/private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad/toast-cb-test.ts`

**Interfaces:**
- Produces: `__registerToastCallback(fn: () => void): string`, `__clearToastCallbacks(): void`, `__invokeCallback(id: string, args: unknown[]): void`.

- [ ] **Step 1: Write the failing standalone test.** Create `scratchpad/toast-cb-test.ts`:
```ts
import { __registerToastCallback, __invokeCallback, __clearToastCallbacks } from "../../../../../Users/test/Documents/code/invoke-v2/packages/api/src/index.ts";
// NOTE: adjust the import path to the repo's packages/api/src/index.ts (absolute path is safest).
let calls: string[] = [];
const id1 = __registerToastCallback(() => calls.push("a"));
const id2 = __registerToastCallback(() => calls.push("b"));
if (id1 === id2 || !id1.startsWith("icb-")) { console.error("FAIL: ids not unique/prefixed", id1, id2); process.exit(1); }
__invokeCallback(id2, []); __invokeCallback(id1, []); __invokeCallback("icb-nope", []);
if (calls.join(",") !== "b,a") { console.error("FAIL: wrong dispatch", calls); process.exit(1); }
__clearToastCallbacks();
__invokeCallback(id1, []); // cleared → no-op
if (calls.join(",") !== "b,a") { console.error("FAIL: not cleared", calls); process.exit(1); }
console.log("ALL PASS");
```

- [ ] **Step 2: Run it to verify it fails.** `cd packages/api && npx tsx /private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad/toast-cb-test.ts`
Expected: FAIL — the three functions aren't exported yet (import error / undefined).

- [ ] **Step 3: Add the registry to `@invoke/api`.** After the `rpc(...)` function (~506) add:
```ts
/* ----- imperative host→child callback channel (toast actions; reusable). Lives on globalThis because
   @invoke/api may be instantiated more than once per child (see BRIDGE_KEY note). ----- */
const TOAST_CB_KEY = "__invokeToastCallbacks__";
const TOAST_CB_SEQ = "__invokeToastCbSeq__";
function toastCbMap(): Map<string, () => void> {
  const g = globalThis as Record<string, unknown>;
  let m = g[TOAST_CB_KEY] as Map<string, () => void> | undefined;
  if (!m) { m = new Map(); g[TOAST_CB_KEY] = m; }
  return m;
}
export function __clearToastCallbacks(): void { toastCbMap().clear(); }
export function __registerToastCallback(fn: () => void): string {
  const g = globalThis as Record<string, unknown>;
  const n = ((g[TOAST_CB_SEQ] as number | undefined) ?? 0) + 1;
  g[TOAST_CB_SEQ] = n;
  const id = `icb-${n}`;
  toastCbMap().set(id, fn);
  return id;
}
export function __invokeCallback(id: string, _args: unknown[]): void { toastCbMap().get(id)?.(); }
```

- [ ] **Step 4: Run the test to verify it passes.** `cd packages/api && npx tsx /private/tmp/.../scratchpad/toast-cb-test.ts` → prints `ALL PASS`.

- [ ] **Step 5: Serialize toast actions in `showToast`.** In `showToast` (~525-546), before the `rpc("toast.show", opts)` call, build the action payloads referencing the returned `handle`. Add a module-local helper above `showToast`:
```ts
function buildToastAction(action: unknown, handle: ToastHandle): { title: string; __handler?: string; shortcut?: unknown } | undefined {
  if (!action || typeof action !== "object") return undefined;
  const a = action as { title?: string; onAction?: (t: ToastHandle) => void; shortcut?: unknown };
  const out: { title: string; __handler?: string; shortcut?: unknown } = { title: a.title ?? "" };
  if (typeof a.onAction === "function") out.__handler = __registerToastCallback(() => a.onAction!(handle));
  if (a.shortcut) out.shortcut = a.shortcut;
  return out;
}
```
Then in `showToast`: accept `primaryAction`/`secondaryAction` from the options object; after constructing the returned `handle` object, if either action exists, `__clearToastCallbacks()` then set `opts.primaryAction = buildToastAction(primaryAction, handle)` / `opts.secondaryAction = buildToastAction(secondaryAction, handle)` on the payload sent to `rpc("toast.show", ...)`. (Read the current `showToast` body — it has an `opts`/`state` object and a `reshow`; thread the actions into the RPC payload and into the `reshow`'s payload too so updates keep the buttons. Keep the existing positional/object overloads.)

- [ ] **Step 6: Serialize toast actions in the `Toast` class.** In `Toast.reshow` (~464) and `Toast.show` (~482), change the `rpc("toast.show", {...})` payload to also include the actions: before sending, if `this._primaryAction || this._secondaryAction`, `__clearToastCallbacks()` and include `primaryAction: buildToastAction(this._primaryAction, this as unknown as ToastHandle)` / `secondaryAction: ...`. (The Toast instance is the handle Raycast passes to `onAction`; `Toast` has `.hide()`/`.show()`/setters, so casting to `ToastHandle` for the callback is sound.)

- [ ] **Step 7: Route `icb-` ids in `child.ts`.** Add `__invokeCallback` to the `@invoke/api` import (line 19): `import { __setHostBridge, __setNavController, __invokeCallback, showToast, Toast } from "@invoke/api";`. Change the `invoke` case (~131-133):
```ts
        case "invoke":
          if (typeof msg.handler === "string" && msg.handler.startsWith("icb-")) __invokeCallback(msg.handler, msg.args);
          else surface?.invokeHandler(msg.handler, msg.args);
          break;
```

- [ ] **Step 8: Typecheck.** `cd packages/api && npx tsc --noEmit 2>&1 | tail -5` (clean) and `cd runtime/node-host && npx tsc --noEmit 2>&1 | tail -5` (clean, if it has its own tsconfig; else build per its norm).

- [ ] **Step 9: Commit.**
```bash
git add packages/api/src/index.ts runtime/node-host/src/child.ts
git commit -m "feat(toast): imperative host->child callback channel + serialize Toast primary/secondary actions"
```

---

### Task 2: Host toast action buttons + click round-trip

**Files:**
- Modify: `apps/macos/Sources/InvokeShell/PaletteWindow.swift` (toast build ~224-248; `showToast` ~582-598)
- Modify: `apps/macos/Sources/InvokeShell/AppController.swift` (`toast.show` capability ~2044-2054)

**Interfaces:**
- Consumes: the `toast.show` params now carry `primaryAction`/`secondaryAction` `{title, __handler}` (Task 1); `extHost.invoke(handler:)` (existing).
- Produces: `PaletteWindow.showToast(_ title: String, actions: [(title: String, onTap: () -> Void)])`.

- [ ] **Step 1: Restructure the toast capsule to host buttons.** In the toast build block (~224-248), replace the direct edge-pinning of `toastLabel` with a horizontal `NSStackView` so buttons can sit beside the label. Add a member `private let toastActions = NSStackView()` near `toastLabel`/`toastContainer`. In `build()`:
```swift
        toastActions.orientation = .horizontal
        toastActions.spacing = 8
        toastActions.translatesAutoresizingMaskIntoConstraints = false
        let toastRow = NSStackView(views: [toastLabel, toastActions])
        toastRow.orientation = .horizontal
        toastRow.spacing = 12
        toastRow.alignment = .centerY
        toastRow.translatesAutoresizingMaskIntoConstraints = false
        toastBg.addSubview(toastRow)
        // (remove the old toastLabel edge constraints; pin toastRow with the same 16/8 insets)
        NSLayoutConstraint.activate([
            toastRow.leadingAnchor.constraint(equalTo: toastBg.leadingAnchor, constant: 16),
            toastRow.trailingAnchor.constraint(equalTo: toastBg.trailingAnchor, constant: -16),
            toastRow.topAnchor.constraint(equalTo: toastBg.topAnchor, constant: 8),
            toastRow.bottomAnchor.constraint(equalTo: toastBg.bottomAnchor, constant: -8),
            toastBg.centerXAnchor.constraint(equalTo: blur.centerXAnchor),
            toastBg.bottomAnchor.constraint(equalTo: blur.bottomAnchor, constant: -52),
        ])
```
(`toastActions` starts empty → collapses; the string toast looks unchanged.)

- [ ] **Step 2: Add the actions variant + keep the string variant.** Add a stored `private var toastActionHandlers: [() -> Void] = []` (retain the tap closures while the toast is shown). Add:
```swift
    /// Toast with action buttons (Toast.ActionOptions). Stays visible until replaced/acted (no auto-hide).
    public func showToast(_ title: String, actions: [(title: String, onTap: () -> Void)]) {
        guard let container = toastContainer else { return }
        toastHideWork?.cancel(); toastHideWork = nil
        toastLabel.stringValue = title
        toastActions.arrangedSubviews.forEach { $0.removeFromSuperview() }
        toastActionHandlers = actions.map { $0.onTap }
        for (i, a) in actions.enumerated() {
            let b = NSButton(title: a.title, target: self, action: #selector(toastActionTapped(_:)))
            b.bezelStyle = .rounded; b.controlSize = .small; b.tag = i
            b.translatesAutoresizingMaskIntoConstraints = false
            toastActions.addArrangedSubview(b)
        }
        NSAnimationContext.runAnimationGroup { ctx in ctx.duration = 0.12; container.animator().alphaValue = 1 }
        // No auto-hide: an actionable toast persists until a new toast or a tap dismisses it.
    }

    @objc private func toastActionTapped(_ sender: NSButton) {
        let handlers = toastActionHandlers
        hideToastNow()
        if sender.tag >= 0, sender.tag < handlers.count { handlers[sender.tag]() }
    }

    private func hideToastNow() {
        toastHideWork?.cancel(); toastHideWork = nil
        toastActionHandlers = []
        NSAnimationContext.runAnimationGroup { ctx in ctx.duration = 0.2; toastContainer?.animator().alphaValue = 0 }
    }
```
And in the EXISTING string `showToast(_ message: String)` (~582), before showing, clear any action buttons + handlers so a plain toast after an actionable one is clean: add at the top (after the `guard`): `toastActions.arrangedSubviews.forEach { $0.removeFromSuperview() }; toastActionHandlers = []`.

- [ ] **Step 3: Parse actions + route the click in `AppController.toast.show`.** Replace the `toast.show`/`hud.show` handler (~2044-2054):
```swift
        case "toast.show", "hud.show":
            let title = arg("title")?.stringValue ?? ""
            let message = arg("message")?.stringValue
            let text = message.map { "\(title) — \($0)" } ?? title
            // Toast.ActionOptions → buttons (foreground only; headless HUD has no window for buttons).
            func action(_ key: String) -> (title: String, handler: String)? {
                if case .object(let o)? = arg(key), let t = o["title"]?.stringValue, let h = o["__handler"]?.stringValue {
                    return (t, h)
                }
                return nil
            }
            let acts = [action("primaryAction"), action("secondaryAction")].compactMap { $0 }
            if method == "toast.show", palette.isVisible, !acts.isEmpty {
                palette.showToast(title, actions: acts.map { a in (a.title, { [weak self] in self?.extHost?.invoke(handler: a.handler) }) })
            } else if !text.isEmpty {
                if method == "hud.show" || !palette.isVisible { hud.show(text) }
                else { palette.showToast(text) }
            }
            return .null
```

- [ ] **Step 4: Build.** `swift build --package-path apps/macos 2>&1 | tail -10` → `Build complete!`.

- [ ] **Step 5: Commit.**
```bash
git add apps/macos/Sources/InvokeShell/PaletteWindow.swift apps/macos/Sources/InvokeShell/AppController.swift
git commit -m "feat(toast): render primary/secondary action buttons (persist until acted) + click->invoke round-trip"
```

---

### Task 3: Fixture (`toast-actions-demo`) + verify

**Files:** Create `examples/toast-actions-demo/package.json`, `examples/toast-actions-demo/src/toast-actions.tsx` (filename MUST match the command name).

- [ ] **Step 1: Read `examples/empty-action-demo/package.json`** and mirror its shape (one `view` command named `toast-actions`).

- [ ] **Step 2: `package.json`** (mirror; command `toast-actions` mode view).

- [ ] **Step 3: `src/toast-actions.tsx`.** (Confirm the `Toast.ActionOptions.onAction` signature against the shim — Raycast passes the Toast instance; match it.)
```tsx
import { List, ActionPanel, Action, Toast, showToast, Clipboard } from "@raycast/api";

export default function ToastActions() {
  return (
    <List>
      <List.Item
        title="Show toast with actions"
        actions={
          <ActionPanel>
            <Action
              title="Upload (fails)"
              onAction={async () => {
                await showToast({
                  style: Toast.Style.Failure,
                  title: "Upload failed",
                  primaryAction: { title: "Retry", onAction: (t) => { t.hide(); void showToast({ title: "Retrying…" }); } },
                  secondaryAction: { title: "Copy Error", onAction: () => { void Clipboard.copy("error details"); } },
                });
              }}
            />
          </ActionPanel>
        }
      />
    </List>
  );
}
```

- [ ] **Step 4: Typecheck** the fixture per the other `examples/` norm. (Add a shim type only if genuinely missing.)

- [ ] **Step 5: Build + relaunch + log.** `scripts/build-app.sh 2>&1 | tail -5`; relaunch; `tail -40 /tmp/invoke-run.log` → fixture command discovered (+1), no error.

- [ ] **Step 6: Human visual checklist (record, don't assert):** running "Upload (fails)" shows a Failure toast with "Retry" + "Copy Error" buttons that STAYS visible (no auto-vanish); clicking "Retry" dismisses it then shows "Retrying…"; clicking "Copy Error" copies the placeholder error.

- [ ] **Step 7: Commit.**
```bash
git add examples/toast-actions-demo
git commit -m "test(fixture): toast-actions-demo exercises Toast primary/secondary actions"
```

---

## Self-Review

**1. Spec coverage:** callback channel + serialize actions → Task 1; host buttons + round-trip + persist → Task 2; fixture → Task 3. ✅

**2. Placeholder scan:** Task 1 has full code + a real assertion test; Task 2 has the constraint/button code; the only "read the current body" directives (showToast options threading, Toast.reshow payload) are because those bodies have positional/object overloads the implementer must preserve — concrete enough.

**3. Type/identifier consistency:** `__registerToastCallback`/`__clearToastCallbacks`/`__invokeCallback` defined Task 1 Step 3, used Steps 5-7 + child.ts. `icb-` prefix (Task 1) matches the child.ts routing (Step 7) and is distinct from reconciler `h<seq>` ids. `PaletteWindow.showToast(_:actions:)` + `toastActionTapped`/`hideToastNow`/`toastActions`/`toastActionHandlers` defined Task 2, consumed by AppController (Step 3).

**Known nuances (final-review triage):**
- Toast-action `shortcut` is serialized but not bound to a key equivalent (display/future-only) — out of scope per spec.
- Headless (HUD) toasts drop actions (no window) — documented fallback.
- Callbacks are cleared on each new actionable toast (only the current toast's callbacks live) — no leak; a stale `icb-` invoke after replacement is a safe no-op (`?.()`).
- The toast stays visible until acted/replaced; verify a surface change / palette hide also clears it (the existing hide paths cancel `toastHideWork`; confirm an actionable toast doesn't linger across a palette close — if it does, clear `toastActions` on hide).
