# Remediation 04 — Selection, Application discovery & Finder / file-system APIs

Gap category: the seven `@raycast/api` functions that currently `throw` via `unsupported(...)`
in `packages/api/src/index.ts:367-372`. All of them are pure platform calls that have no
host RPC method, no schema allowlist entry, and no Swift handler. This doc specifies the
end-to-end implementation for each, modeled on the **already-working** `runAppleScript`,
`open`, and `executeSQL` bridges.

> Scope note: do not modify anything outside `tools/compat-check/remediation/`. This is a
> spec; the file:line citations are the change sites for the implementer.

---

## How an existing host-bridged call works (the pattern to copy)

The IPC contract is **method-name based**, not per-method-typed. A single generic frame
carries every capability, so adding a new API needs **no new `schema/src/index.ts` message
type** — only an allowlist entry on both sides plus a Swift `case`. Trace of `runAppleScript`:

1. **SDK stub → RPC** — `packages/api/src/index.ts:314-316`
   ```ts
   export async function runAppleScript(source: string): Promise<string> {
     return (await rpc("runAppleScript", { source })) as string;
   }
   ```
   `rpc()` (`packages/api/src/index.ts:284-288`) calls the process-global bridge
   `globalThis.__invokeHostRpc__` (`BRIDGE_KEY`, line 279), wired by the runtime child via
   `__setHostBridge` (line 281).

2. **Wire frame** — the bridge emits a `HostBound` message
   `{ kind: "rpc"; id; method; params }` (`schema/src/index.ts:49`); the host replies with
   `{ kind: "rpcResult"; id; result?; error? }` (`schema/src/index.ts:56`). Length-prefixed
   framing via `encodeFrame`/`FrameDecoder` (`schema/src/index.ts:66-92`). **No change here.**

3. **Node-side allowlist** — `runtime/node-host/src/supervisor.ts:30-46` `ALLOWED_RPC`.
   A method missing from this set is rejected before reaching the host. The dev runner has a
   parallel `switch` in `runtime/node-host/src/run.ts` (see `case "open"` at line 74,
   `executeSQL` at line 119) used by `invoke run` outside the macOS app.

4. **Host-side allowlist + dispatch** — `apps/macos/Sources/InvokeShell/ExtensionHost.swift`:
   - `allowedRPC` set, lines 36-43 (mirrors the Node set; denial enforced here, lines 149-151).
   - `rpc` frames dispatched at lines 145-156 → `onCapability(method, params)`.
   - `onCapability` is bound to `AppController.handleCapability` at
     `AppController.swift:109` (palette host) and `:2009`/`:2046` (no-view / headless hosts).

5. **Swift handler** — `AppController.handleCapability(_:_:)`
   (`AppController.swift:1554-1667`), a `switch method`. `open` → `openTarget`
   (`:1571-1573`, impl `:1815-1818`, uses `NSWorkspace.shared.open`). `runAppleScript`
   (`:1604-1633`) shows the **gating template**: shell-escape refusal, per-extension consent
   via `ensureAppleScriptGrant()` (`:1539-1552`), execution, and TCC-denial handling that
   routes to `presentPermissionHelp(.automation)` (`:1694-1719`). `executeSQL`
   (`:1634-1663`) shows **per-(extension,resource) consent** via `ensureSQLGrant`
   (`:1673-1687`).

Consent is keyed to the **extension**, not the command: `extGrantKey(forId:)`
(`:1531-1535`) collapses `ext.apple-notes.index` and `ext.apple-notes.add-text` to
`ext.apple-notes`. Grants persist in `AppSettings` (`appleScriptGrants`, `sqlGrants`).

**Reusable Swift building blocks already present:**
- `NSWorkspace.shared` — `open` (`:1816`), `frontmostApplication` (`:320`),
  `urlForApplication(toOpen:)` / `urlsForApplications(toOpen:)` exist on the same class.
- Accessibility: `AXIsProcessTrusted()` (`:1190`, `:1239`), one-time prompt
  `promptAccessibility()` (`:1252-1259`), keystroke synthesis `synthesizePaste()` (used
  at `:1198`) — the basis for a "copy selection" path.
- TCC deep-links: `presentPermissionHelp` (`:1694-1719`) already handles `.fullDiskAccess`
  and `.automation`; add an `.accessibility` case
  (`x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility`).

### Steps common to every API below
1. Replace the `unsupported(...)` body in `packages/api/src/index.ts` with an
   `rpc("<method>", params)` call (and return the typed result).
2. Add `"<method>"` to `ALLOWED_RPC` (`supervisor.ts:30-46`) **and** to `allowedRPC`
   (`ExtensionHost.swift:36-43`).
3. Add a `case "<method>":` to `handleCapability` (`AppController.swift:1559`).
4. (Optional, for `invoke run` parity) add the same `case` to `run.ts`.

---

## The `Application` shape (real Raycast)

`getApplications`, `getFrontmostApplication`, `getDefaultApplication` all return Raycast's
`Application`:
```ts
interface Application { name: string; path: string; bundleId?: string; localizedName?: string; }
```
The SDK stubs are currently typed `Promise<unknown[]>` / `Promise<unknown>`
(`index.ts:368-370`); tighten to `Application` / `Application[]`. The Swift side builds this
from an `NSRunningApplication` / app-bundle URL: `name`←`localizedName`,
`path`←`bundleURL.path`, `bundleId`←`bundleIdentifier`.

---

## Per-API specification

### 1. `getFrontmostApplication()` — 86 extensions
- **Real Raycast:** resolves the `Application` of the app that had focus when the command was
  invoked.
- **Current stub:** `packages/api/src/index.ts:369` → `unsupported("getFrontmostApplication")`.
- **Implementation:**
  - SDK: `rpc("app.frontmost", {})` → `Application`.
  - Swift `case "app.frontmost"`: return the **captured** target, not the live frontmost.
    `AppController` already records it in `captureTarget()` (`:319-321`, stored as
    `pasteTarget`) precisely because Invoke itself becomes frontmost when summoned. Build the
    `Application` object from `pasteTarget` (`NSRunningApplication`: `localizedName`,
    `bundleURL?.path`, `bundleIdentifier`). Fall back to `NSWorkspace.shared.frontmostApplication`
    for headless/no-view hosts where no palette capture happened.
- **Permissions:** none (NSWorkspace, no TCC). **Effort: S. Risk: Low.**
- **Examples (15):** 1bookmark, 1password, 8-divide, ai-git-assistant, anonaddy,
  antigravity, apple-photos, apply-inline-code, auto-quit-app, bitwarden, browser-tabs,
  cerebras, change-case, chatgpt, claudecast.

### 2. `getApplications(path?)` — 167 extensions
- **Real Raycast:** lists installed apps; with a `path`/URL, lists apps that can open it.
- **Current stub:** `index.ts:368` → `unsupported("getApplications")`.
- **Implementation:**
  - SDK: `rpc("app.list", { path })` → `Application[]`.
  - Swift `case "app.list"`: if `path` given → `NSWorkspace.shared.urlsForApplications(toOpen:)`
    (modern, macOS 12+) or legacy `LSCopyApplicationURLsForURL`; else enumerate
    `/Applications`, `/System/Applications`, `~/Applications` (and `/System/Applications/Utilities`)
    for `.app` bundles, read each `Bundle`'s `bundleIdentifier` + display name. Map each to the
    `Application` shape. De-dupe by `bundleId`.
- **Permissions:** none. Enumerating `/Applications` is unrestricted. **Effort: M
  (enumeration + caching; a cold scan is hundreds of bundles — cache per launch). Risk: Low.**
- **Examples (15):** 1bookmark, ableton-live, amphetamine, android, antinote, anybox,
  appcleaner, appgrid, apply-inline-code, arc, asset-catalog-extractor, audio-writer,
  auto-quit-app, betteraudio, bike.

### 3. `getDefaultApplication(path)` — 17 extensions
- **Real Raycast:** the default `Application` that opens the file/URL at `path`.
- **Current stub:** `index.ts:370` → `unsupported("getDefaultApplication")`.
- **Implementation:**
  - SDK: `rpc("app.default", { path })` → `Application` (reject empty `path`).
  - Swift `case "app.default"`: `NSWorkspace.shared.urlForApplication(toOpen: url)` where
    `url` is a file URL (tilde-expanded like `openTarget` at `:1817`) **or** a scheme URL
    (e.g. `https:` → default browser). Build the `Application` from the returned bundle URL.
    Return an error reply if no handler is found.
- **Permissions:** none. **Effort: S. Risk: Low.**
- **Examples (15):** anonaddy, browser-bookmarks, browser-tabs, chatgpt-search,
  default-web-browser-manager, feishu-document-creator, github-search, installed-extensions,
  markdown-slides, netlify, obsidian, open-link-in-specific-browser, pip, quick-git,
  shell-history.

### 4. `showInFinder(path)` — 91 extensions
- **Real Raycast:** reveals & selects the item at `path` in Finder.
- **Current stub:** `index.ts:372` → `unsupported("showInFinder")`.
- **Implementation:**
  - SDK: `rpc("finder.reveal", { path })` → `void`.
  - Swift `case "finder.reveal"`: tilde-expand `path`, then
    `NSWorkspace.shared.activateFileViewerSelecting([url])` (reveals + selects, the exact
    Finder behavior). Validate the path exists via `FileManager.default.fileExists`; reply
    error otherwise.
- **Permissions:** none for the reveal itself; macOS may show the file in Finder regardless
  of TCC. No Automation/Accessibility prompt. **Effort: S. Risk: Low.**
- **Examples (15):** ag-audioflow, arc, archiver, avatar, base64-to-file, better-aliases,
  bing-wallpaper, bitwarden, capture-fullpage-of-website, capture-raycast-metadata,
  code-quarkus, codex-manager, common-directory, copee, croc-transfer.

### 5. `trash(paths)` — 36 extensions
- **Real Raycast:** moves one path or an array of paths to the Trash (recoverable).
- **Current stub:** `index.ts:371` → `unsupported("trash")`.
- **Implementation:**
  - SDK: normalize to an array — `rpc("fs.trash", { paths: Array.isArray(p) ? p : [p] })`
    → `void`.
  - Swift `case "fs.trash"`: for each tilde-expanded path,
    `FileManager.default.trashItem(at: url, resultingItemURL: nil)`. Collect failures and, if
    any, reply with an error string listing them.
  - **Gating (this is the only destructive API in the group):** add a per-extension consent
    gate modeled on `ensureAppleScriptGrant()` (`:1539-1552`). Because `trash` is recoverable
    (not `rm`), a single per-extension grant ("Allow X to move files to the Trash?") is
    proportionate — but the dialog **should list the paths** for the first call, like
    `ensureSQLGrant` names the db (`:1678-1681`). Do **not** allow trashing outside the user
    domain without an explicit confirm (guard against `/`, `/System`, the app bundle).
- **Permissions:** `trashItem` needs read/write to the parent dir. For TCC-protected
  locations (Desktop, Documents, Downloads) macOS prompts on first access; a hard denial
  should route to `presentPermissionHelp(.fullDiskAccess)` (`:1697-1701`). **Effort: M
  (consent gate + path safety + error aggregation). Risk: Medium — destructive; the consent
  gate and domain guard are mandatory.**
- **Examples (15):** append-to-file, apple-passwords, azure-tts-raycast, bunch,
  claude-sessions, claudecast, codex-manager, custom-icon, desktop-manager,
  downloads-manager, easy-invoice, ente-auth, ets2-ats-profiles, finder-file-actions,
  folder-search.

### 6. `getSelectedFinderItems()` — 127 extensions
- **Real Raycast:** returns `[{ path: string }]` for items currently selected in the
  frontmost Finder window.
- **Current stub:** *no stub present.* `getSelectedFinderItems` is referenced in 127
  extensions' imports but is **not exported** from `packages/api/src/index.ts` — an unknown
  named ESM import fails the whole module at load. **First add the export** (alongside the
  others at `:367-372`), then implement.
- **Implementation:**
  - SDK: `export async function getSelectedFinderItems(): Promise<{ path: string }[]>`
    → `rpc("finder.selection", {})`.
  - Swift `case "finder.selection"`: reuse the **existing** `runAppleScript` machinery — run
    `tell application "Finder" to get the selection as alias list`, then resolve each to a
    POSIX path (`get POSIX path of ...`). Easiest: an AppleScript that returns newline-joined
    POSIX paths; split on the host side and map to `{ path }`. (Alternatively the
    Apple-Events `kAEGetData` route, but AppleScript reuses the gating + error handling
    already built.)
  - Reuse `ensureAppleScriptGrant()` for consent and the `-1743` →
    `presentPermissionHelp(.automation)` path (`:1626-1627`) verbatim.
- **Permissions:** **TCC Automation** — first call triggers the "Invoke wants to control
  Finder" prompt; deny surfaces error `-1743` → settings deep-link. **Effort: M. Risk:
  Medium** (depends on Automation grant; behaves exactly like the working `apple-notes`
  path).
- **Examples (15):** ag-audioflow, ai-git-assistant, alacritty, alt-text-generator,
  annotely, antigravity, apfel, archiver, asset-catalog-extractor, at-profile, bambu-lab,
  betterzip, blip-raycast, cerebras, chatgpt.

### 7. `getSelectedText()` — 206 extensions (largest)
- **Real Raycast:** returns the highlighted text in the frontmost app (used for "rewrite
  selection", translate, etc.).
- **Current stub:** `index.ts:367` → `unsupported("getSelectedText")`.
- **Implementation (two viable host strategies):**
  - SDK: `rpc("selection.read", {})` → `string`.
  - **Swift, preferred — Accessibility API:** with `AXIsProcessTrusted()` (already checked at
    `:1190`), read the focused element's `kAXSelectedTextAttribute` via
    `AXUIElementCopyAttributeValue` on the system-wide element → focused app → focused UI
    element. No clipboard mutation, no synthetic keystroke.
  - **Swift, fallback — copy synthesis:** refocus the captured `pasteTarget` (`:1195-1197`),
    save current pasteboard, synthesize ⌘C (mirror `synthesizePaste()` used at `:1198` but
    with the `c` keycode), read `NSPasteboard.general.string(forType:.string)`, restore the
    pasteboard. This works in apps with no AX text support but is racy (timing delay like the
    `0.08s` at `:1198`) and clobbers/restores the clipboard.
  - When untrusted, call `promptAccessibility()` (`:1252-1259`) once and reply with an empty
    string + a toast (don't throw), matching the existing paste-fallback UX.
- **Permissions:** **TCC Accessibility.** Add an `.accessibility` case to
  `presentPermissionHelp` (`:1692-1707`) with deep-link
  `…?Privacy_Accessibility`. **Effort: L** (AX traversal + untrusted/fallback handling +
  pasteboard save/restore for the fallback). **Risk: Medium-High** — most-imported API,
  AX selection is unreliable across apps (web views, Electron), and the copy-synthesis
  fallback mutates the clipboard. Ship AX-first, fallback behind a flag.
- **Examples (15):** 8-divide, advanced-replace, ai-text-to-calendar, alacritty, aleph,
  alice-ai, align-rtl, anonaddy, apfel, append-clipboard, apple-notes, arc, azure-tts-raycast,
  bark, bible.

---

## macOS TCC / signed-app interaction

All grant state in this group falls into two layers:

1. **Invoke's own per-extension consent** (`appleScriptGrants` / a new `trashGrants`,
   default-deny, dialog names the extension) — gates which *extension* may use a powerful
   capability. Independent of the OS.
2. **macOS TCC** — gates whether *Invoke (the app)* may use the underlying facility:
   - **Automation** → `getSelectedFinderItems` (Finder), any AppleScript route.
   - **Accessibility** → `getSelectedText` (AX read or synthetic-keystroke fallback).
   - **Full Disk Access** → `trash` into protected dirs (Desktop/Documents/Downloads).
   - **none** → `getApplications`, `getFrontmostApplication`, `getDefaultApplication`,
     `showInFinder`.

TCC grants are keyed to the app's **code signature / bundle id**. Per the memory note
`build-app-and-signing`, an ad-hoc-signed `Invoke.app` re-prompts every rebuild because its
signature changes, **dropping the TCC grant** — so test these with a **stable signing
identity** (`INVOKE_SIGN_IDENTITY` via `scripts/build-app.sh`) or every run re-triggers the
Automation/Accessibility prompt and looks broken. This matters most for #6 and #7. The
existing `presentPermissionHelp` throttle (`:1708`, 10s) already prevents prompt-storms when
a search fires many calls; reuse it for the new `.accessibility` case.

No data-residency concern: every call is local-machine only; nothing leaves the device.

---

## Summary table

| API | RPC method | macOS framework | TCC | Effort | Risk | Ext |
|---|---|---|---|---|---|---|
| getFrontmostApplication | `app.frontmost` | NSWorkspace / captured `pasteTarget` | none | S | Low | 86 |
| getApplications | `app.list` | NSWorkspace + `/Applications` scan | none | M | Low | 167 |
| getDefaultApplication | `app.default` | `NSWorkspace.urlForApplication(toOpen:)` | none | S | Low | 17 |
| showInFinder | `finder.reveal` | `activateFileViewerSelecting` | none | S | Low | 91 |
| trash | `fs.trash` | `FileManager.trashItem` (+consent gate) | FDA* | M | Med | 36 |
| getSelectedFinderItems | `finder.selection` | AppleScript (reuse runAppleScript) | Automation | M | Med | 127 |
| getSelectedText | `selection.read` | AX `kAXSelectedTextAttribute` / ⌘C fallback | Accessibility | L | Med-High | 206 |

*FDA only for protected dirs. **Union: 582 extensions touch at least one of these APIs.**
Schema (`schema/src/index.ts`) needs **no changes** — the generic `rpc`/`rpcResult` frame
carries all seven; only the two allowlists and `handleCapability` change.
