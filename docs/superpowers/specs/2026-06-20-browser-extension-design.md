# BrowserExtension support — design

**Date:** 2026-06-20
**Status:** Approved (design)
**Goal:** Implement Raycast's `BrowserExtension` API in Invoke so the ~47 trusted extensions that read browser tabs/content run, without requiring a Raycast (or Invoke) browser companion.

## Background

`@invoke/api` currently ships `BrowserExtension.getContent`/`getTabs` as throwing stubs (`unsupported(...)`). Across the store clone, 77 extensions import `BrowserExtension`; usage is `getTabs` (56) > `getContent` (26). Raycast powers this with a user-installed browser companion talking to the app over a local channel; Invoke has none.

## Goals / Non-goals

**Goals**
- Implement `BrowserExtension.getTabs()` and `BrowserExtension.getContent(options?)` with real data.
- Zero extra install for the user (no browser extension to ship).
- A stable boundary (extension API + host RPC contract) so the backend can later be swapped for a native companion **without touching extensions**.

**Non-goals (YAGNI for v1)**
- Firefox (not AppleScript-scriptable).
- Building/distributing a browser-companion extension + native-messaging/WebSocket bridge.
- Real favicons (derive from the tab URL instead).
- Reactive tab/focus events or write access (activate/close tabs).

## Architecture

Stable boundary, swappable backend:

```
extension → BrowserExtension.getTabs/getContent  (@invoke/api)
          → rpc "browser.getTabs" / "browser.getContent"   ← stable contract
          → AppController.handleCapability
          → BrowserDriver (AppleScript)                     ← today's backend (swappable)
          → Chromium / Safari
```

The extension API and the two RPC methods are the contract. AppleScript is an implementation detail; a future companion replaces `BrowserDriver` only.

## RPC contract

- `browser.getTabs` → params `{}` → returns `Tab[]`
  `Tab = { id: string; url: string; title: string; active: boolean; favicon?: string }`
- `browser.getContent` → params `{ tabId?: string; format: "html" | "text"; cssSelector?: string }` → returns `string`
  - The host RPC returns only **`html` or `text`** (what the browser's JS can produce directly). The extension-facing `BrowserExtension.getContent` accepts Raycast's `format` of `html | text | markdown` (default `markdown`); for `markdown`, `@invoke/api` requests `html` from the host and converts it in JS (no Swift HTML→Markdown). Default tab = the active tab of the front window.

`id` encodes window+tab position as `"<windowIndex>:<tabIndex>"` (1-based, matching AppleScript). `getContent({ tabId })` parses it to target a specific tab.

## Backend — BrowserDriver (AppleScript)

**Browser selection:** target the frontmost *running* supported browser; if the frontmost app isn't a supported browser, fall back to the first running supported browser (preference order: Chrome, Brave, Arc, Edge, Vivaldi, Chromium, Safari). Detect via `NSWorkspace.shared.runningApplications` + `frontmostApplication`.

**Two AppleScript dialects:**
- *Chromium family* (Chrome/Brave/Arc/Edge/Vivaldi/Chromium): `tell application "<name>"` — enumerate `windows`/`tabs`, read `URL`/`title`, `active tab index of window`; content via `execute javascript "<js>" in tab <i> of window <w>`.
- *Safari:* `tell application "Safari"` — `URL`/`name of tabs`, `current tab`; content via `do JavaScript "<js>" in <tab>`.

**Content JS (the host only runs these two; markdown is a JS transform in `@invoke/api`):**
- `text` → `(sel ? document.querySelector(sel) : document.body).innerText`
- `html` → `(sel ? document.querySelector(sel) : document.documentElement).outerHTML`
- `markdown` (in `@invoke/api`, not the host) → request `html`, then convert HTML→Markdown with a small best-effort converter (headings/links/lists/code/paragraphs; unknown tags → their text). Testable in JS; `text`/`html` stay exact.

**Favicon:** derived from the tab URL via the existing remote-favicon path (`https://www.google.com/s2/favicons?sz=64&domain=<host>`); never blocks the tab list.

## Permissions & error handling

AppleScript control is gated by macOS **Automation (Apple Events) TCC** per browser (first use prompts "Invoke wants to control <Browser>"). `getContent` additionally needs the browser's **"Allow JavaScript from Apple Events"** toggle. Every failure rejects with a specific, actionable message (no silent empty results):

- No supported browser running → "No supported browser is running. Open Chrome, Brave, Arc, Edge, or Safari."
- Automation denied (AppleScript error -1743) → "Allow Invoke to control <Browser> in System Settings → Privacy & Security → Automation."
- JS-from-Apple-Events off → "Enable '<Browser> → Develop/Developer → Allow JavaScript from Apple Events'."
- Firefox frontmost / unsupported → the above "no supported browser" message.

The extension receives the rejection (its own try/catch surfaces a toast); for our own callers a HUD names the exact toggle. v1 relies on system TCC as the gate — no separate per-extension consent prompt (matches Raycast's model).

## Components / files

- `packages/api/src/index.ts` — replace the two stubs with real `getTabs`/`getContent`; export the `BrowserExtension.Tab` type; add the HTML→Markdown helper.
- `runtime/node-host/src/supervisor.ts` — add `browser.getTabs`, `browser.getContent` to `ALLOWED_RPC`.
- `apps/macos/Sources/InvokeShell/ExtensionHost.swift` — add the two methods to `allowedRPC`.
- `apps/macos/Sources/InvokeShell/AppController.swift` — `handleCapability` cases + a new `BrowserDriver` (AppleScript per family, browser detection, errno→message mapping). Async path (`handleAsyncCapability`) since AppleScript can block — reuse the existing async-capability mechanism so the child isn't stalled.
- `runtime/node-host/src/run.ts` — dev-runner fulfilment via `osascript` (real) so both methods are verifiable headlessly.
- `tools/compat-check/check.mjs` — move `BrowserExtension` from the degraded set to supported (keep in sync with `packages/api`).

## Testing

- **Headless:** dev runner calls `browser.getTabs`/`getContent` against the real frontmost browser via `osascript`; assert a non-empty tab list with a running Chrome, and content for the active tab.
- **Compat:** re-scan trusted — `BrowserExtension` drops off the top-gaps list (~47 extensions move degraded→supported).
- **Live:** run a real `BrowserExtension` extension end-to-end in the signed app (after granting Automation + the JS toggle).
- **Error paths:** verify the actionable messages when Automation is denied / no browser is running.

## Risks

- AppleScript is slower and more brittle than a companion; mitigated by the swappable backend and clear errors.
- `execute javascript` requires the per-browser toggle; surfaced explicitly, not silently failed.
- Markdown conversion is best-effort; `text`/`html` are exact.
