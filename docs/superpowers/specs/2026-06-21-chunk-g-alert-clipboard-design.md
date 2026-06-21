# Chunk G — P1 Alert.Options + Clipboard.read full / clear Design

**Part of the autonomous Raycast-parity push** (`[[autonomous-parity-goal]]`). Closes two of the three P1 "feedback/clipboard" items in `RAYCASTVSINVOKE.md` §12:
- `Alert.Options` — `icon` / `dismissAction` / `rememberUserChoice`.
- `Clipboard.read` full `{text, html, file}` + `Clipboard.clear`.

**Deferred (tracked, NOT dropped):** `Toast` primary/secondary actions — the third P1 feedback item. It requires a new **imperative host→child callback channel** (a persistent toast's `onAction` can fire at any time, unlike `confirmAlert` which resolves once; the reconciler's handler registry is React-prop-only + frame-scoped + cleared each commit). That infra deserves its own focused chunk (**G′**, next). This chunk takes the two items that need no new infra.

## Global constraints
- World-class Raycast-quality UX; never ship system-default/janky UI.
- Faithful parity; don't fabricate third-party brands. Fixture imports `@raycast/api`.
- Commit on `main`. Relaunch `Invoke.app` after build+install.
- No Xcode/XCTest → AppKit verified via build + fixture/relaunch/log; pure logic via standalone scripts.
- Never echo secrets; `clipboard.read` may surface arbitrary user clipboard content — the fixture must use placeholder data and must not log real clipboard contents.

---

## Item 1 — `Alert.Options`: `icon` + `rememberUserChoice` (+ `dismissAction.style`)

**Current:** `confirmAlert` (`packages/api/src/index.ts:853`) accepts `{title, message, icon?, primaryAction, dismissAction, rememberUserChoice}` in its TS signature but only sends `title/message/primaryTitle/primaryStyle/dismissTitle` over RPC; it invokes `primaryAction.onAction`/`dismissAction.onAction` based on the returned bool (this round-trip already works). The host `presentConfirmAlert` (`AppController.swift:2027`) → `ConfirmModal.present` renders title/message/cancel/primary (destructive→red). `icon`, `rememberUserChoice`, and `dismissAction.style` are dropped.

**Design:**
- **api `confirmAlert`:** also send `icon` (resolve the `Image.ImageLike` to a host-renderable string the same way other icons are passed — a string source / SF-symbol name; for the common `Icon.*` case it's the icon id string), `rememberUserChoice` (bool), and `dismissStyle` (`dismissAction.style`). Keep the existing local `onAction` invocation based on the result.
- **host `presentConfirmAlert`:** read `icon`, `rememberUserChoice`, `dismissStyle`. If `rememberUserChoice` is true, compute a stable key `alertRemember.<currentExtId>.<sha-or-joined title+message>`; if a remembered bool is stored under it, **reply immediately with the stored choice (skip the modal)**. Otherwise present the modal; on resolve, if the user ticked "Don't ask again", persist the chosen bool under the key.
- **`ConfirmModal.present`:** gains `icon: NSImage?` (rendered ~32pt centered atop the card, above the title; omitted when nil) and `rememberable: Bool` (renders a small "Don't ask again" checkbox below the message when true). The result callback changes from `(Bool) -> Void` to `(_ confirmed: Bool, _ remember: Bool) -> Void` so AppController can persist. The `dismissStyle == "destructive"` reddens the cancel button (minor; primary already supports destructive).
- Icon resolution: reuse the renderer's existing image/SF-symbol resolution (a small helper or the same `NSImage(systemSymbolName:)` + `sfSymbol(for:)` fallback used elsewhere).

## Item 2 — `Clipboard.read` full `{text, html, file}` + `Clipboard.clear`

**Current:** the host capability `clipboard.read` (`AppController.swift:2252`) **already returns `{text, file, html}`** from `NSPasteboard.general`. But the api `Clipboard.read()` (`index.ts:513`) ignores it and calls `clipboard.readText`, narrowing to `{ text }`. `Clipboard.clear` does not exist in the api or host.

**Design:**
- **api `Clipboard.read()`:** call `rpc("clipboard.read", {})` and return the host object as Raycast's `{ text: string; file?: string; html?: string }` (default `text` to `""` when absent). Keep `readText()` as-is.
- **api `Clipboard.clear()`:** add `clear: () => rpc("clipboard.clear", {}) as Promise<void>`.
- **host:** add a `case "clipboard.clear":` → `NSPasteboard.general.clearContents(); return .null`.
- **allow-lists:** add `"clipboard.clear"` to `ExtensionHost.swift`'s capability allow-list (~line 63, next to `clipboard.copy`/`clipboard.readText`) and to `runtime/node-host/src/supervisor.ts`'s allow-list (~line 33). (`clipboard.read` is already allow-listed at `ExtensionHost.swift:83`.)

## Item 3 — Fixture + verify

- `examples/alert-clipboard-demo/` (manifest mirrors `examples/empty-action-demo`, imports `@raycast/api`), a `view` command that:
  - Has an `Action` that runs `await confirmAlert({ icon: Icon.Trash, title: "Delete?", message: "This cannot be undone", primaryAction: { title: "Delete", style: Alert.ActionStyle.Destructive }, rememberUserChoice: true })` and shows the boolean result in a `Detail` (proves icon + remember).
  - An `Action` that runs `await Clipboard.copy("placeholder text")` then `await Clipboard.read()` and renders the returned `{text, html?, file?}` in the `Detail` (proves full read) — uses only placeholder data, never logs real clipboard content.
  - An `Action` that runs `await Clipboard.clear()` and confirms via a Toast/Detail.
- Verify: typecheck clean; `scripts/build-app.sh` succeeds; relaunch; `/tmp/invoke-run.log` shows the fixture loaded (+1 command), no error. Human visual: alert shows the trash icon + "Don't ask again"; ticking it + re-running skips the dialog; clipboard read shows the placeholder text; clear empties it.

## Testing strategy
- **Pure/standalone:** the `rememberUserChoice` key derivation (stable across launches for the same title+message) as a standalone check, if extracted to a pure helper.
- **AppKit/integration:** modal icon + checkbox + skip-on-remembered, clipboard read/clear — via build + fixture + relaunch + log + human visual.

## Out of scope (tracked elsewhere)
- **Toast primary/secondary actions** → Chunk G′ (next) — needs the imperative callback channel.
- `Clipboard.read` `offset` (read the Nth clipboard entry) — the host reads only the current pasteboard; offset/history wiring is a separate item (note as follow-up, not in this chunk).
