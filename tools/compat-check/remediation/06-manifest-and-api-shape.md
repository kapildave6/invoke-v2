# Remediation 06 — Manifest features + legacy `@raycast/api` shape

Scope: command modes the runtime rejects, manifest fields the runtime reads but ignores
(`arguments[]`, background `interval`), inter-command launching
(`launchCommand` / `updateCommandMetadata` / deeplinks), and legacy v1 `@raycast/api`
symbol names that only need re-export aliases.

Source data: `tools/compat-check/report-sandboxed/results.json` (2961 extensions scanned
sandboxed; SUPPORTED 650 / DEGRADED 475 / UNSUPPORTED 1836). Counts below are extensions
whose `blockers`/`degraded`/`unknown`/`apiImports` match each feature.

Grounding files:
- Manifest reader: `runtime/node-host/src/run.ts:18-42` (the `Manifest` interface + helpers).
- Child runtime / mode dispatch: `runtime/node-host/src/child.ts:95-112`.
- API surface: `packages/api/src/index.ts`.
- `@raycast/api` shim: `packages/compat-raycast/src/index.ts:10` — literally
  `export * from "@invoke/api"`, so **anything added to `@invoke/api` is automatically
  exported as `@raycast/api`**. This is why the alias work below is so cheap.
- Host command registration / mode gate: `apps/macos/Sources/InvokeShell/AppController.swift:1866-1894`.
- Host launch: `apps/macos/Sources/InvokeShell/ExtensionHost.swift:56-89` (`mode` + `INVOKE_MODE`).

---

## 0. THE CHEAPEST WIN — legacy alias shims (do this first)

105 extensions (all currently UNSUPPORTED) import at least one legacy v1 `@raycast/api`
name that the scan flagged as an `unknown` import. These are pure renames: the new
namespaced API already exists in `packages/api/src/index.ts`; the symbol just isn't
exported under its old name, so the ESM import fails at module load and takes the whole
extension down. A few dozen lines of re-exports in `packages/api/src/index.ts` (flowing
through the shim automatically) load them all.

### Current state
`packages/api/src/index.ts` exports the modern forms only:
- `Action.OpenInBrowser` / `Action.CopyToClipboard` / `Action.Paste` / `Action.Open` /
  `Action.Push` / `Action.SubmitForm` defined at `:182-202`.
- `Toast.Style` at `:264-266`.
- `Image.Mask` at `:409`.
- `LocalStorage.{getItem,setItem,removeItem}` at `:326-334`.
- `Clipboard.{copy,paste}` at `:290-295`.
- `Alert.ActionStyle` at `:382`.

None of the v1 top-level names (`ToastStyle`, `OpenInBrowserAction`, `getLocalStorageItem`,
…) are exported, so importing them throws `SyntaxError: does not provide an export named …`.

### Concrete change — append to `packages/api/src/index.ts`
```ts
/* ---------------------------------------- legacy v1 @raycast/api aliases (compat) */
// Old top-level Action names → Action.* (v1 → v1.0 namespacing).
export const OpenInBrowserAction = Action.OpenInBrowser;
export const CopyToClipboardAction = Action.CopyToClipboard;
export const PasteAction = Action.Paste;
export const OpenAction = Action.Open;
export const PushAction = Action.Push;
export const SubmitFormAction = Action.SubmitForm;

// Old enums.
export const ToastStyle = Toast.Style;          // ToastStyle.Success, …
export const ImageMask = Image.Mask;            // ImageMask.Circle, …

// Old top-level LocalStorage functions.
export const getLocalStorageItem = LocalStorage.getItem;
export const setLocalStorageItem = LocalStorage.setItem;
export const removeLocalStorageItem = LocalStorage.removeItem;
export const allLocalStorageItems = LocalStorage.allItems;
export const clearLocalStorage = LocalStorage.clear;

// Old top-level Clipboard functions.
export const copyTextToClipboard = Clipboard.copy;
export const pasteText = Clipboard.paste;

// `preferences` — v1 exposed the raw resolved-preferences object (now getPreferenceValues()).
export const preferences = getPreferenceValues();

// Trivial helpers some v1 extensions import from the api package.
export function randomId(): string {
  return Math.random().toString(36).slice(2) + Date.now().toString(36);
}
// clearSearchBar — v1 imperative; we have no imperative search handle yet, so no-op
// (keeps the import alive; calling it is harmless). See §6 for the real wiring.
export async function clearSearchBar(_opts?: { forceScrollToTop?: boolean }): Promise<void> {}
```

Notes:
- `Action.*` aliases must be declared **after** `:181-202` (where `Action` is finalized).
- `preferences` as a module-level constant is evaluated at import time; that's fine because
  `getPreferenceValues()` reads `process.env.INVOKE_PREFERENCES` (`:342-348`), which the host
  sets before the bundle loads (`ExtensionHost.swift:56-89`).

### Effort / risk
S (a few dozen lines, no new runtime concepts). Risk: **low** — additive exports only; the
underlying namespaced APIs already exist and are tested.

### Extensions unblocked
~105 (union across all alias names; **all currently UNSUPPORTED**). Per-name tallies:

| legacy name | count | examples |
|---|---|---|
| `ToastStyle` | 44 | aleph, banca-d-italia-currency-converter, bazinga-tools, binance, circle-ci, coinbase-pro, coinmarketcap-crypto-price-crawler, conventional-comments, copy-gcp-icons, copy-text-files, element, elm-search |
| `OpenInBrowserAction` | 30 | atomic, bazinga-tools, binance, bugmenot, circle-ci, coinbase-pro, conventional-comments, daily-sites, debank, elm-search, geohash-encode-decode, google-trends |
| `CopyToClipboardAction` | 24 | atomic, banca-d-italia-currency-converter, biaodian, bugmenot, circle-ci, geohash-encode-decode, huggingcast, inertiajs-documentation, kubectx, laravel-nova, lobsters, mldocs |
| `clearSearchBar` | 41 | apfel, app-tag-manager, apple-reminders, aztu-lms, cerebras, change-case, chatgo, chatgpt, claude, color-casket, dictionary, feedbin |
| `SubmitFormAction` | 11 | circle-ci, commitlint, conventional-comments, debank, grafana, huggingcast, polished, raycast-timeular, remove-background, roblox-games, ulysses |
| `getLocalStorageItem` | 11 | banca-d-italia-currency-converter, circle-ci, debank, kalshi, php-docs, raycast-diki, search-notion, simpread, sketch, stackoverflow, weread-sync |
| `setLocalStorageItem` | 11 | (same set as getLocalStorageItem) |
| `ImageMask` | 8 | codemagic, coinbase-pro, expo, google-trends, lobsters, script-commands, simpread, sketch |
| `PushAction` | 8 | atomic, circle-ci, geohash-encode-decode, kinopoisk, raycast-timeular, script-commands, search-hex, simpread |
| `preferences` | 7 | binance, coinbase-pro, dlmoji, huggingcast, kinopoisk, pubme, v2ex |
| `OpenAction` | 3 | roblox-games, search-notion, sketch |
| `PasteAction` | 3 | biaodian, bugmenot, huggingcast |
| `removeLocalStorageItem` | 3 | debank, php-docs, raycast-diki |
| `copyTextToClipboard` | 3 | commitlint, hexlify, random-email |
| `pasteText` | 3 | conventional-comments, glossary, random-email |
| `randomId` | 3 | moji, raycast-diki, script-commands |

(`clearSearchBar` is alias-shimmed here so the import survives; making it actually clear the
search bar is the larger §6 work.)

---

## 1. `menu-bar` command mode (component exists; only execution + host rendering missing)

**236 extensions** declare a command mode the runtime rejects — overwhelmingly `menu-bar`.

### Current state
- The `MenuBarExtra` **component already exists** in `packages/api/src/index.ts:216-219`
  (`MenuBarExtra` + `MenuBarExtra.Item`), with schema tags `menubar-extra` / `menubar-item`
  registered in the `T` map at `:63-64`. So an extension's `menu-bar` source compiles and
  renders into the view tree fine.
- It is **not executed**: `child.ts:96-112` handles only `INVOKE_MODE === "no-view"` and the
  implicit `view` branch; there is no menu-bar branch.
- The host **rejects** it: `AppController.swift:1871` —
  `guard cmode == "view" || cmode == "no-view" else { continue }` — so `menu-bar` commands
  are dropped at registration. The `ExtensionHost.launch(mode:)` only documents `view`/`no-view`
  (`ExtensionHost.swift:56`).

### Concrete change
1. `child.ts` — add a `menu-bar` branch that renders the default export through the surface
   exactly like `view` (it's a render tree, not headless), but signals the host it's a
   status-item tree rather than a palette surface (e.g. via the `ready` message or a new
   `INVOKE_MODE === "menu-bar"`). Re-render-on-commit already works through `createSurface`.
2. `AppController.swift:1871` — allow `cmode == "menu-bar"`; register it not as a palette
   `RootCommand` but as an `NSStatusItem` whose menu is built from the `menubar-extra` /
   `menubar-item` nodes in the streamed tree.
3. Host menu rendering — new Swift code to map `menubar-item` nodes (title/icon/onAction →
   `NSMenuItem`) and invoke their handlers back over the socket (the `invoke` path already
   exists in `child.ts:88-90`). Also handle background `interval` refresh (see §3) since
   menu-bar items typically refresh on a schedule.

### Effort / risk
M–L. The API/schema half is done; the work is host-side `NSStatusItem`/`NSMenu` rendering plus
a child render branch. Risk: medium (new long-lived host surface + lifecycle, not just a
one-shot launch).

### Extensions unblocked
~236. Examples: 1-click-confetti, 42-api, acqua, adhan-time, ado-search, aerospace,
agent-usage, air-quality, alice-ai, app-updates, apple-notes, apple-reminders,
aranet-co2-monitor, arc, auto-quit-app.

---

## 2. Command `arguments[]` declared but not passed by runtime

**481 extensions** declare per-command `arguments[]` (the small inline fields Raycast prompts
for before launch) that the runtime never collects or forwards.

### Current state
- `run.ts:18-23` `Manifest.commands[]` reads only `{ name, title, mode }` — `arguments` is
  not in the interface, so it's dropped on read.
- `child.ts:99` passes `{ arguments: {}, … }` to a no-view command — **always empty**. The
  `view` branch (`:110`) renders `createElement(Command)` with **no props at all**, so a view
  command never receives `props.arguments` either.

### Concrete change
1. `run.ts:18-23` — extend `Manifest.commands[]` with
   `arguments?: Array<{ name: string; type: "text"|"password"|"dropdown"; placeholder?: string; required?: boolean }>`.
2. Host — before launch, if a command declares `arguments`, present an argument bar / prompt
   (Raycast shows inline argument fields in the palette) and pass the collected values to
   `ExtensionHost.launch` as a new env var (e.g. `INVOKE_ARGUMENTS` JSON), mirroring how
   `INVOKE_PREFERENCES` flows (`ExtensionHost.swift:56-89`).
3. `child.ts` — parse `INVOKE_ARGUMENTS` and pass it as `props.arguments` for **both** the
   no-view branch (`:99`, replace the hardcoded `{}`) and the view branch (`:110`, pass it as
   the component's props instead of none).

### Effort / risk
M. Plumbing across run/host/child plus a host argument-input UI. Risk: low-medium (additive;
existing no-arg commands keep working with an empty object).

### Extensions unblocked
~481. Examples: 40-questions, accordance, adb, aerospace, algorand, alice-ai,
alt-text-generator, antinote, append-clipboard, apple-maps-search, apple-notes,
apple-reminders, arc, area-code-lookup, aspect-raytio.

---

## 3. Background `interval` commands not scheduled

**220 extensions** declare a background command with an `interval` (e.g. `"interval": "10m"`)
that should run headlessly on a timer; nothing schedules them.

### Current state
- `run.ts:18-23` doesn't read `interval` (or the `mode: "no-view"` + `interval` combo), so the
  manifest field is invisible to the runtime.
- There is no scheduler anywhere in `runtime/node-host` or the host; commands only launch on
  explicit user action (`AppController.swift:1878-1894`).

### Concrete change
1. `run.ts:18-23` — add `interval?: string` to `Manifest.commands[]`.
2. Host — add a scheduler that, for each command with an `interval`, periodically calls the
   existing no-view launch path (`runNoViewExtension`, `AppController.swift:1887`) with
   `launchType: "background"`. `child.ts:99` already passes `launchType`; thread the background
   value through instead of the hardcoded `"userInitiated"`. Respect the documented
   data-residency / consent posture — background runs should honor the same per-extension trust
   gating used for foreground launches.
3. Closely tied to §1: menu-bar extras are the most common interval consumers (refresh the
   status item on a timer).

### Effort / risk
M–L. Needs a persistent, app-lifetime scheduler + background-launch policy. Risk: medium
(long-running background execution, battery/permission implications).

### Extensions unblocked
~220. Examples: 1password, 42-api, acqua, adhan-time, ado-search, agent-usage, air-quality,
app-updates, apple-notes, apple-reminders, aranet-co2-monitor, arc, ascii-art-wallpaper,
audio-device.

---

## 4. `launchCommand` — inter-command launching

**250 extensions** call `launchCommand` to launch another command in the same (or another)
extension.

### Current state
Not exported by `packages/api/src/index.ts` at all (no symbol in the file). An import of
`launchCommand` from `@raycast/api` throws at load → whole command fails.

### Concrete change
1. `packages/api/src/index.ts` — add
   `export async function launchCommand(opts: { name: string; type: LaunchType; extensionName?: string; ownerOrExtensionName?: string; arguments?: Record<string,unknown>; context?: unknown }): Promise<void>`
   that RPCs to a new host method (e.g. `rpc("launchCommand", opts)`), following the existing
   `rpc()` pattern at `:284-288`.
2. Host — implement the `launchCommand` RPC: resolve `{extension, command}` to a registered
   `RootCommand` and invoke its launch path (`AppController.swift:1878-1894`), forwarding
   `arguments` (§2) and `launchType` (§3).
3. Minimum viable first step (S): export `launchCommand` as a `unsupported("launchCommand")`
   stub (like `getApplications` at `:368`) so extensions that only import it at module top but
   call it on a rarely-hit path still **load**. Full functionality is M.

### Effort / risk
Stub: S, low risk. Full wiring: M (depends on §2/§3 for arguments/launchType). Risk: medium —
inter-command launching can recurse / open palettes.

### Extensions unblocked
Stub loads all ~250; full feature makes them work. Examples: 42-api, adb, ag-audioflow,
agent-usage, air-quality, alice-ai, anonaddy, app-updates, apple-reminders, arc, audio-device,
auto-quit-app, awork, bear, binance-exchange.

---

## 5. `updateCommandMetadata` and deeplinks

- **`updateCommandMetadata`** (88 extensions) — lets a command update its own subtitle/value
  shown in the root list (used heavily by menu-bar/interval status commands). Not exported.
  Examples: acqua, airpods-noise-control, appcleaner, ascii-art-wallpaper, audio-device,
  bamboohr, bikeshare-station-status, ccusage, chronometer, clipmenu, coffee, copy-path,
  counter, cron, dagster.
- **`createDeeplink` / deeplinks** (7 extensions) — generate `raycast://` deep links. Not
  exported. Examples: bartender, bundles, context7, harpoon, inbox-ai, spiceblow-database,
  trenit.

### Concrete change
- `updateCommandMetadata`: export
  `export async function updateCommandMetadata(meta: { subtitle?: string | null }): Promise<void>`
  in `packages/api/src/index.ts`, RPC to a host method that updates the registered
  `RootCommand`'s subtitle for the current `commandName` (`environment.commandName`, `:339`).
  Effort M (needs host-side mutable command metadata); a no-op stub is S and loads all 88.
- `createDeeplink`: a pure string builder — `export function createDeeplink(opts): string`
  returning an `invoke://extensions/<owner>/<ext>/<command>?...` URL. Effort S, but only
  useful once the host registers a URL scheme to handle those links (separate work). Given
  only 7 extensions, low priority; ship the builder as S to unblock the imports.

### Effort / risk
Stubs: S. Real metadata updates: M. Risk: low (additive).

---

## 6. `BrowserExtension` API

**47 extensions** import `BrowserExtension` (read the active browser tab's content/DOM/tabs via
the companion browser extension).

### Current state
Not exported by `packages/api/src/index.ts`. Import throws → command fails.

### Concrete change
- Short term (S): export a `BrowserExtension` object whose methods are `unsupported(...)`
  stubs (pattern at `:354-372`) so the import loads; commands that only conditionally use it
  still run their non-browser paths.
- Full (L): requires a companion browser extension + a native messaging bridge into the host —
  out of scope for this gap category; track separately.

### Effort / risk
Stub: S, low risk. Full: L (new browser-side component + native messaging).

### Extensions unblocked
Stub loads all ~47. Examples: anonaddy, bitwarden, browser-ai, cerebras, chatgpt, code-wiki,
create-link, daily-sites, deepwiki, digger, discussite, exif, finicky-rule-manager,
font-sniper, helium.

---

## 7. Out of category but adjacent (noted, not actioned here)

The scan also flags **AI tools[] declared** (186, e.g. anytype, apple-notes, apple-reminders,
arc, aws, bartender, bear) and **extension-level `ai` instructions ignored** (145). These are
the AI-tools manifest surface and belong to the AI gap category, not manifest-shape; listed
here only because `run.ts` likewise doesn't read `tools`/`ai` from the manifest (`:18-23`).

---

## Priority summary

1. **§0 legacy aliases** — S, low risk, ~105 extensions, a few dozen lines in
   `packages/api/src/index.ts`. Do first.
2. **§4/§5/§6 stub exports** (`launchCommand`, `updateCommandMetadata`, `createDeeplink`,
   `BrowserExtension`) — S, low risk; loads ~390 more extensions even before full wiring.
3. **§2 arguments[]** — M, ~481 extensions; biggest single feature win.
4. **§1 menu-bar** + **§3 interval** — M–L, ~236 / ~220; component + schema already exist, so
   the remaining work is host status-item rendering, a child render branch, and a scheduler.
