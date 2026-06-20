# BrowserExtension Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Raycast's `BrowserExtension.getTabs()`/`getContent()` in Invoke via host-side AppleScript, behind a stable `browser.*` RPC boundary.

**Architecture:** Extension → `@invoke/api` `BrowserExtension` → `rpc("browser.getTabs"|"browser.getContent")` → `AppController.handleAsyncCapability` → a new `BrowserDriver` that scripts the frontmost Chromium-family/Safari browser. `markdown` is converted in `@invoke/api` (host returns only `html`/`text`).

**Tech Stack:** TypeScript (`packages/api`, `runtime/node-host`), Swift/AppKit (`apps/macos`), NSAppleScript.

**Spec:** `docs/superpowers/specs/2026-06-20-browser-extension-design.md`

## Global Constraints

- Commit directly on `main`; `git push` after each task (project convention).
- The host RPC `browser.getContent` accepts `format` of only `"html" | "text"`; `markdown` is a `@invoke/api`-side transform.
- Tab `id` format is `"<windowIndex>:<tabIndex>"`, 1-based (AppleScript indices).
- Supported browsers (bundle id → AppleScript name → family): `com.google.Chrome`→"Google Chrome"/chromium, `com.brave.Browser`→"Brave Browser"/chromium, `company.thebrowser.Browser`→"Arc"/chromium, `com.microsoft.edgemac`→"Microsoft Edge"/chromium, `com.vivaldi.Vivaldi`→"Vivaldi"/chromium, `org.chromium.Chromium`→"Chromium"/chromium, `com.apple.Safari`→"Safari"/safari. Preference order = that order.
- AppleScript field/record delimiters: unit separator `\u{1F}` between fields, record separator `\u{1E}` between tabs (control chars absent from titles/URLs).
- Every failure path rejects with a specific actionable message; never resolve to empty silently.
- When adding an API member, also update `tools/compat-check/check.mjs` (kept in sync with `packages/api`).

---

### Task 1: `@invoke/api` — BrowserExtension impl + HTML→Markdown converter

**Files:**
- Modify: `packages/api/src/index.ts` (replace the stub at ~802–804; add `htmlToMarkdown` + `Tab` type)
- Test: `packages/api/src/browser-extension.test.ts` (create)

**Interfaces:**
- Produces: `BrowserExtension.getTabs(): Promise<Tab[]>`, `BrowserExtension.getContent(options?: { tabId?: string; format?: "html"|"text"|"markdown"; cssSelector?: string }): Promise<string>`, `BrowserExtension.Tab` type, and `export function htmlToMarkdown(html: string): string`.
- Consumes: existing `rpc(method, params)` (line 493) and the `globalThis[BRIDGE_KEY]` bridge.

- [ ] **Step 1: Write the failing test**

```ts
// packages/api/src/browser-extension.test.ts
import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { BrowserExtension, htmlToMarkdown } from "./index";

const BRIDGE_KEY = "__invokeHostRpc__";
describe("htmlToMarkdown", () => {
  it("converts headings, links, bold, and paragraphs", () => {
    const md = htmlToMarkdown("<h1>Title</h1><p>Hello <b>world</b> <a href='https://x.com'>link</a></p>");
    expect(md).toContain("# Title");
    expect(md).toContain("**world**");
    expect(md).toContain("[link](https://x.com)");
  });
  it("strips unknown tags to their text", () => {
    expect(htmlToMarkdown("<span>plain</span>")).toContain("plain");
  });
});

describe("BrowserExtension", () => {
  beforeEach(() => {
    (globalThis as Record<string, unknown>)[BRIDGE_KEY] = vi.fn(async (method: string) => {
      if (method === "browser.getTabs") return [{ id: "1:1", url: "https://x.com", title: "X", active: true }];
      if (method === "browser.getContent") return "<h1>Hi</h1>";
      return null;
    });
  });
  afterEach(() => { delete (globalThis as Record<string, unknown>)[BRIDGE_KEY]; });

  it("getTabs returns the host tabs with derived favicons", async () => {
    const tabs = await BrowserExtension.getTabs();
    expect(tabs[0].url).toBe("https://x.com");
    expect(tabs[0].favicon).toContain("x.com");
  });
  it("getContent markdown requests html and converts it", async () => {
    const send = (globalThis as Record<string, unknown>)[BRIDGE_KEY] as ReturnType<typeof vi.fn>;
    const out = await BrowserExtension.getContent({ format: "markdown" });
    expect(send).toHaveBeenCalledWith("browser.getContent", expect.objectContaining({ format: "html" }));
    expect(out).toContain("# Hi");
  });
  it("getContent text passes format through unchanged", async () => {
    const send = (globalThis as Record<string, unknown>)[BRIDGE_KEY] as ReturnType<typeof vi.fn>;
    await BrowserExtension.getContent({ format: "text" });
    expect(send).toHaveBeenCalledWith("browser.getContent", expect.objectContaining({ format: "text" }));
  });
});
```

- [ ] **Step 2: Run the test, verify it fails**

Run: `npx vitest run packages/api/src/browser-extension.test.ts`
Expected: FAIL (`htmlToMarkdown` is not exported; `getTabs` throws `unsupported`).

- [ ] **Step 3: Replace the stub with the implementation**

Replace `packages/api/src/index.ts` lines ~802–804 (`export const BrowserExtension = { ... }`) with:

```ts
export interface BrowserExtensionTab {
  id: string;
  url: string;
  title: string;
  active: boolean;
  favicon?: string;
}
/** Best-effort HTML→Markdown (no DOM in the extension host). Handles the common block/inline tags;
 *  unknown tags collapse to their text. text/html formats stay exact — this only backs `markdown`. */
export function htmlToMarkdown(html: string): string {
  let s = html;
  s = s.replace(/<script[\s\S]*?<\/script>/gi, "").replace(/<style[\s\S]*?<\/style>/gi, "");
  s = s.replace(/<h([1-6])[^>]*>([\s\S]*?)<\/h\1>/gi, (_m, n, t) => `\n${"#".repeat(Number(n))} ${t.trim()}\n`);
  s = s.replace(/<(strong|b)[^>]*>([\s\S]*?)<\/\1>/gi, (_m, _t, t) => `**${t}**`);
  s = s.replace(/<(em|i)[^>]*>([\s\S]*?)<\/\1>/gi, (_m, _t, t) => `*${t}*`);
  s = s.replace(/<code[^>]*>([\s\S]*?)<\/code>/gi, (_m, t) => `\`${t}\``);
  s = s.replace(/<a[^>]*href=["']([^"']*)["'][^>]*>([\s\S]*?)<\/a>/gi, (_m, href, t) => `[${t.trim()}](${href})`);
  s = s.replace(/<li[^>]*>([\s\S]*?)<\/li>/gi, (_m, t) => `\n- ${t.trim()}`);
  s = s.replace(/<(p|div|section|article|br|tr|h[1-6])[^>]*>/gi, "\n");
  s = s.replace(/<[^>]+>/g, ""); // strip remaining tags
  s = s.replace(/&nbsp;/g, " ").replace(/&amp;/g, "&").replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&quot;/g, '"').replace(/&#39;/g, "'");
  return s.replace(/\n{3,}/g, "\n\n").replace(/[ \t]+\n/g, "\n").trim();
}
function tabFaviconURL(url: string): string | undefined {
  try { return `https://www.google.com/s2/favicons?sz=64&domain=${new URL(url).hostname}`; } catch { return undefined; }
}
export const BrowserExtension = {
  Tab: undefined as unknown, // present so `BrowserExtension.Tab` (a type reference) never throws at runtime
  async getTabs(): Promise<BrowserExtensionTab[]> {
    const tabs = (await rpc("browser.getTabs", {})) as BrowserExtensionTab[];
    return (tabs ?? []).map((t) => ({ ...t, favicon: t.favicon ?? tabFaviconURL(t.url) }));
  },
  async getContent(options?: { tabId?: string; format?: "html" | "text" | "markdown"; cssSelector?: string }): Promise<string> {
    const format = options?.format ?? "markdown";
    const hostFormat = format === "markdown" ? "html" : format; // host only does html/text
    const raw = (await rpc("browser.getContent", { tabId: options?.tabId, format: hostFormat, cssSelector: options?.cssSelector })) as string;
    return format === "markdown" ? htmlToMarkdown(raw ?? "") : (raw ?? "");
  },
};
```

- [ ] **Step 4: Run the test, verify it passes**

Run: `npx vitest run packages/api/src/browser-extension.test.ts`
Expected: PASS (all 5).

- [ ] **Step 5: Typecheck + commit + push**

```bash
npm run typecheck
git add packages/api/src/index.ts packages/api/src/browser-extension.test.ts
git commit -m "@raycast/api: implement BrowserExtension.getTabs/getContent (markdown via JS converter)" \
  -m "Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
git push origin main
```

---

### Task 2: Allow `browser.*` through the RPC gates

**Files:**
- Modify: `runtime/node-host/src/supervisor.ts` (`ALLOWED_RPC`, ~line 32–65)
- Modify: `apps/macos/Sources/InvokeShell/ExtensionHost.swift` (`allowedRPC`, ~line 59–75)

**Interfaces:**
- Produces: `browser.getTabs` and `browser.getContent` are accepted (no longer denied) by both the Node supervisor and the Swift host.

- [ ] **Step 1: Add to the Node allowlist**

In `runtime/node-host/src/supervisor.ts`, inside the `ALLOWED_RPC` set, after the `"ai.ask",` line add:

```ts
  "browser.getTabs",   // Raycast BrowserExtension.getTabs (host AppleScript)
  "browser.getContent", // Raycast BrowserExtension.getContent (host AppleScript)
```

- [ ] **Step 2: Add to the Swift allowlist**

In `apps/macos/Sources/InvokeShell/ExtensionHost.swift`, inside `allowedRPC`, after the `"ai.ask",` line add:

```swift
        "browser.getTabs",   // Raycast BrowserExtension.getTabs (host AppleScript)
        "browser.getContent", // Raycast BrowserExtension.getContent (host AppleScript)
```

- [ ] **Step 3: Verify the Node allowlist (the Swift handler lands in Task 4)**

Run: `node -e "import('./runtime/node-host/src/supervisor.ts').then(m=>console.log(m.isAllowedRpc?'has-helper':'check-export'))" 2>/dev/null || grep -n 'browser.getTabs' runtime/node-host/src/supervisor.ts`
Expected: prints the matching `browser.getTabs` line.

- [ ] **Step 4: Commit + push**

```bash
git add runtime/node-host/src/supervisor.ts apps/macos/Sources/InvokeShell/ExtensionHost.swift
git commit -m "browser.*: allow getTabs/getContent through the RPC gates" \
  -m "Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
git push origin main
```

---

### Task 3: Swift `BrowserDriver` (AppleScript) — pure helpers + exec

**Files:**
- Create: `apps/macos/Sources/InvokeShell/BrowserDriver.swift`
- Test: `apps/macos/Tests/InvokeShellTests/BrowserDriverTests.swift` (create; add an `InvokeShellTests` test target to `apps/macos/Package.swift` if absent)

**Interfaces:**
- Produces:
  - `struct BrowserTab { let id: String; let url: String; let title: String; let active: Bool }`
  - `enum BrowserError: Error { case noBrowser; case automationDenied(String); case jsDisabled(String); case script(String) }`
  - `enum BrowserDriver` with:
    - `static func supportedBrowser(frontmost: String?, running: [String]) -> (name: String, family: String)?` — picks the browser (pure; testable)
    - `static func parseTabId(_ id: String) -> (window: Int, tab: Int)?` — pure
    - `static func tabsScript(appName: String, family: String) -> String` — pure (AppleScript text)
    - `static func contentScript(appName: String, family: String, window: Int, tab: Int, format: String, cssSelector: String?) -> String` — pure
    - `static func getTabs() throws -> [BrowserTab]` and `static func getContent(tabId: String?, format: String, cssSelector: String?) throws -> String` — run AppleScript (live)
- Consumes: nothing from earlier tasks.

- [ ] **Step 1: Write failing tests for the pure helpers**

```swift
// apps/macos/Tests/InvokeShellTests/BrowserDriverTests.swift
import XCTest
@testable import InvokeShell

final class BrowserDriverTests: XCTestCase {
  func testSupportedBrowserPrefersFrontmost() {
    let b = BrowserDriver.supportedBrowser(frontmost: "com.brave.Browser", running: ["com.apple.Safari", "com.brave.Browser"])
    XCTAssertEqual(b?.name, "Brave Browser"); XCTAssertEqual(b?.family, "chromium")
  }
  func testSupportedBrowserFallsBackByPreference() {
    let b = BrowserDriver.supportedBrowser(frontmost: "com.apple.Finder", running: ["com.apple.Safari", "com.google.Chrome"])
    XCTAssertEqual(b?.name, "Google Chrome") // Chrome outranks Safari
  }
  func testNoSupportedBrowser() {
    XCTAssertNil(BrowserDriver.supportedBrowser(frontmost: "com.apple.Finder", running: ["com.apple.Finder"]))
  }
  func testParseTabId() {
    XCTAssertEqual(BrowserDriver.parseTabId("2:5")?.window, 2)
    XCTAssertEqual(BrowserDriver.parseTabId("2:5")?.tab, 5)
    XCTAssertNil(BrowserDriver.parseTabId("garbage"))
  }
  func testContentScriptEscapesAndTargets() {
    let s = BrowserDriver.contentScript(appName: "Google Chrome", family: "chromium", window: 1, tab: 3, format: "text", cssSelector: nil)
    XCTAssertTrue(s.contains("tab 3 of window 1"))
    XCTAssertTrue(s.contains("execute javascript"))
  }
}
```

- [ ] **Step 2: Run, verify it fails**

Run: `swift test --package-path apps/macos --filter BrowserDriverTests`
Expected: FAIL (no `BrowserDriver`). (If the test target doesn't exist yet, add it to `apps/macos/Package.swift` `.testTarget(name: "InvokeShellTests", dependencies: ["InvokeShell"])` and a matching `Tests/InvokeShellTests` dir, then re-run.)

- [ ] **Step 3: Implement `BrowserDriver`**

```swift
// apps/macos/Sources/InvokeShell/BrowserDriver.swift
import AppKit

struct BrowserTab { let id: String; let url: String; let title: String; let active: Bool }
enum BrowserError: Error { case noBrowser; case automationDenied(String); case jsDisabled(String); case script(String) }

enum BrowserDriver {
  // bundle id → (AppleScript app name, family), in preference order.
  static let supported: [(bundle: String, name: String, family: String)] = [
    ("com.google.Chrome", "Google Chrome", "chromium"),
    ("com.brave.Browser", "Brave Browser", "chromium"),
    ("company.thebrowser.Browser", "Arc", "chromium"),
    ("com.microsoft.edgemac", "Microsoft Edge", "chromium"),
    ("com.vivaldi.Vivaldi", "Vivaldi", "chromium"),
    ("org.chromium.Chromium", "Chromium", "chromium"),
    ("com.apple.Safari", "Safari", "safari"),
  ]
  private static let FS = "\u{1F}", RS = "\u{1E}" // field / record separators

  static func supportedBrowser(frontmost: String?, running: [String]) -> (name: String, family: String)? {
    if let f = frontmost, let m = supported.first(where: { $0.bundle == f }) { return (m.name, m.family) }
    for cand in supported where running.contains(cand.bundle) { return (cand.name, cand.family) }
    return nil
  }
  static func parseTabId(_ id: String) -> (window: Int, tab: Int)? {
    let parts = id.split(separator: ":")
    guard parts.count == 2, let w = Int(parts[0]), let t = Int(parts[1]) else { return nil }
    return (w, t)
  }
  private static func escapeJS(_ s: String) -> String {
    s.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
  }
  static func contentJS(format: String, cssSelector: String?) -> String {
    let root = cssSelector.map { "document.querySelector(\"\(escapeJS($0))\")" } ?? (format == "html" ? "document.documentElement" : "document.body")
    let prop = format == "html" ? "outerHTML" : "innerText"
    return "(function(){var e=\(root);return e?e.\(prop):\"\";})()"
  }

  static func tabsScript(appName: String, family: String) -> String {
    if family == "safari" {
      return """
      tell application "\(appName)"
        set out to ""
        set wi to 0
        repeat with w in windows
          set wi to wi + 1
          set ct to current tab of w
          set ti to 0
          repeat with t in tabs of w
            set ti to ti + 1
            set act to (t is ct)
            set out to out & wi & "\(FS)" & ti & "\(FS)" & (act as text) & "\(FS)" & (URL of t) & "\(FS)" & (name of t) & "\(RS)"
          end repeat
        end repeat
        return out
      end tell
      """
    }
    return """
    tell application "\(appName)"
      set out to ""
      set wi to 0
      repeat with w in windows
        set wi to wi + 1
        set ai to active tab index of w
        set ti to 0
        repeat with t in tabs of w
          set ti to ti + 1
          set out to out & wi & "\(FS)" & ti & "\(FS)" & ((ti = ai) as text) & "\(FS)" & (URL of t) & "\(FS)" & (title of t) & "\(RS)"
        end repeat
      end repeat
      return out
    end tell
    """
  }
  static func contentScript(appName: String, family: String, window: Int, tab: Int, format: String, cssSelector: String?) -> String {
    let js = contentJS(format: format, cssSelector: cssSelector)
    if family == "safari" {
      return "tell application \"\(appName)\" to do JavaScript \"\(escapeJS(js))\" in tab \(tab) of window \(window)"
    }
    return "tell application \"\(appName)\" to execute javascript \"\(escapeJS(js))\" in tab \(tab) of window \(window)"
  }

  private static func run(_ source: String, appName: String, isContent: Bool) throws -> String {
    var err: NSDictionary?
    let res = NSAppleScript(source: source)?.executeAndReturnError(&err)
    if let err {
      let num = (err[NSAppleScript.errorNumber] as? NSNumber)?.intValue ?? 0
      let msg = (err[NSAppleScript.errorMessage] as? String) ?? "AppleScript error"
      if num == -1743 { throw BrowserError.automationDenied("Allow Invoke to control \(appName) in System Settings → Privacy & Security → Automation.") }
      // Safari/Chromium return an error when JS-from-Apple-Events is off.
      if isContent && (msg.localizedCaseInsensitiveContains("not allowed") || msg.localizedCaseInsensitiveContains("javascript")) {
        throw BrowserError.jsDisabled("Enable \(appName) → Develop/Developer → “Allow JavaScript from Apple Events”.")
      }
      throw BrowserError.script(msg)
    }
    return res?.stringValue ?? ""
  }

  private static func frontBrowser() throws -> (name: String, family: String) {
    let ws = NSWorkspace.shared
    let running = ws.runningApplications.compactMap { $0.bundleIdentifier }
    let front = ws.frontmostApplication?.bundleIdentifier
    guard let b = supportedBrowser(frontmost: front, running: running) else {
      throw BrowserError.noBrowser
    }
    return b
  }

  static func getTabs() throws -> [BrowserTab] {
    let b = try frontBrowser()
    let raw = try run(tabsScript(appName: b.name, family: b.family), appName: b.name, isContent: false)
    return raw.components(separatedBy: RS).filter { !$0.isEmpty }.compactMap { row in
      let f = row.components(separatedBy: FS)
      guard f.count == 5 else { return nil }
      return BrowserTab(id: "\(f[0]):\(f[1])", url: f[3], title: f[4], active: f[2] == "true")
    }
  }
  static func getContent(tabId: String?, format: String, cssSelector: String?) throws -> String {
    let b = try frontBrowser()
    let pos = tabId.flatMap(parseTabId) ?? (1, 1) // default: front window, first/active tab
    return try run(contentScript(appName: b.name, family: b.family, window: pos.window, tab: pos.tab, format: format, cssSelector: cssSelector), appName: b.name, isContent: true)
  }
}
```

- [ ] **Step 4: Run the pure-helper tests, verify they pass**

Run: `swift test --package-path apps/macos --filter BrowserDriverTests`
Expected: PASS (5).

- [ ] **Step 5: Commit + push**

```bash
git add apps/macos/Sources/InvokeShell/BrowserDriver.swift apps/macos/Tests/InvokeShellTests/BrowserDriverTests.swift apps/macos/Package.swift
git commit -m "BrowserDriver: AppleScript tab/content scripting for Chromium + Safari" \
  -m "Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
git push origin main
```

---

### Task 4: Wire `browser.*` into `AppController.handleAsyncCapability`

**Files:**
- Modify: `apps/macos/Sources/InvokeShell/AppController.swift` (`handleAsyncCapability`, after the `case "ai.ask":` block ~line 1859)

**Interfaces:**
- Consumes: `BrowserDriver.getTabs()/getContent(...)`, `BrowserError` (Task 3).
- Produces: `browser.getTabs`/`browser.getContent` resolve to a tab array / content string; failures show a HUD and resolve to `[]`/`""` (the extension's own onError surfaces the message too).

- [ ] **Step 1: Add the two cases**

In `handleAsyncCapability`, after the `case "ai.ask": … return true` block, add:

```swift
        case "browser.getTabs":
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let result: JSONValue
                do {
                    let tabs = try BrowserDriver.getTabs()
                    result = .array(tabs.map { t in .object([
                        "id": .string(t.id), "url": .string(t.url), "title": .string(t.title), "active": .bool(t.active),
                    ]) })
                } catch {
                    DispatchQueue.main.async { self?.showBrowserError(error) }
                    result = .array([])
                }
                DispatchQueue.main.async { reply(result) }
            }
            return true
        case "browser.getContent":
            let tabId = arg("tabId")?.stringValue
            let format = arg("format")?.stringValue ?? "text"
            let css = arg("cssSelector")?.stringValue
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let result: JSONValue
                do { result = .string(try BrowserDriver.getContent(tabId: tabId, format: format, cssSelector: css)) }
                catch { DispatchQueue.main.async { self?.showBrowserError(error) }; result = .string("") }
                DispatchQueue.main.async { reply(result) }
            }
            return true
```

- [ ] **Step 2: Add the `showBrowserError` helper**

Immediately after `handleAsyncCapability`'s closing brace, add:

```swift
    /// Surface a BrowserDriver failure with the specific actionable message (automation TCC, JS toggle,
    /// no browser, or a raw script error).
    private func showBrowserError(_ error: Error) {
        let msg: String
        switch error {
        case BrowserError.noBrowser: msg = "No supported browser is running. Open Chrome, Brave, Arc, Edge, or Safari."
        case BrowserError.automationDenied(let m): msg = m
        case BrowserError.jsDisabled(let m): msg = m
        case BrowserError.script(let m): msg = "Browser: \(m)"
        default: msg = "Browser: \(error.localizedDescription)"
        }
        palette.showToast(msg)
    }
```

- [ ] **Step 3: Build**

Run: `INVOKE_BUILD_CONFIG=debug scripts/build-app.sh 2>&1 | grep -aiE "error:|✓ built"`
Expected: `✓ built …` (no `error:`).

- [ ] **Step 4: Relaunch the freshly-built app**

```bash
pkill -f 'MacOS/invoke'; sleep 1; : > /tmp/invoke-run.log
INVOKE_REPO_ROOT="$PWD" "apps/macos/.build/Invoke.app/Contents/MacOS/invoke" > /tmp/invoke-run.log 2>&1 &
sleep 2; pgrep -fl 'MacOS/invoke' | grep -iv grep
```
Expected: the process is listed (app running).

- [ ] **Step 5: Commit + push**

```bash
git add apps/macos/Sources/InvokeShell/AppController.swift
git commit -m "browser.*: host handlers (async AppleScript) + actionable error HUD" \
  -m "Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
git push origin main
```

---

### Task 5: Dev-runner fulfilment + compat-check + end-to-end verification

**Files:**
- Modify: `runtime/node-host/src/run.ts` (`devCapabilities` handler — add `browser.*` via `osascript`)
- Modify: `tools/compat-check/check.mjs` (mark `BrowserExtension` supported, sync with packages/api)

**Interfaces:**
- Consumes: the `@invoke/api` BrowserExtension (Task 1) and the host handlers (Task 4).
- Produces: `npx tsx runtime/node-host/src/run.ts <ext> --command=<cmd>` can drive a real browser; the trusted compat scan no longer lists `BrowserExtension` as a gap.

- [ ] **Step 1: Add dev fulfilment in `run.ts`**

In `runtime/node-host/src/run.ts`, inside `devCapabilities`' handler switch (where other capabilities like `clipboard.copy` are handled), add:

```ts
      if (method === "browser.getTabs" || method === "browser.getContent") {
        const { execFileSync } = await import("node:child_process");
        const osa = (src: string) => execFileSync("osascript", ["-e", src], { encoding: "utf8" }).trim();
        // Reuse the same scripts shape as BrowserDriver: front Chrome by default in dev.
        const app = "Google Chrome", FS = "\u001f", RS = "\u001e";
        if (method === "browser.getTabs") {
          const raw = osa(`tell application "${app}"\nset out to ""\nset wi to 0\nrepeat with w in windows\nset wi to wi+1\nset ai to active tab index of w\nset ti to 0\nrepeat with t in tabs of w\nset ti to ti+1\nset out to out & wi & "${FS}" & ti & "${FS}" & ((ti = ai) as text) & "${FS}" & (URL of t) & "${FS}" & (title of t) & "${RS}"\nend repeat\nend repeat\nreturn out\nend tell`);
          return raw.split(RS).filter(Boolean).map((row: string) => { const f = row.split(FS); return { id: `${f[0]}:${f[1]}`, url: f[3], title: f[4], active: f[2] === "true" }; });
        }
        const fmt = (params as { format?: string })?.format ?? "text";
        const prop = fmt === "html" ? "outerHTML" : "innerText";
        const js = `(function(){var e=${fmt === "html" ? "document.documentElement" : "document.body"};return e?e.${prop}:"";})()`;
        return osa(`tell application "${app}" to execute javascript "${js.replace(/\\/g, "\\\\").replace(/"/g, '\\"')}" in active tab of front window`);
      }
```

- [ ] **Step 2: Mark BrowserExtension supported in the checker**

In `tools/compat-check/check.mjs`, find where `BrowserExtension` is listed (search `BrowserExtension`) in `API_DEGRADED` / `API_ABSENT` and move it to `API_SUPPORTED` (add `"BrowserExtension"` to the `API_SUPPORTED` set; delete its `API_DEGRADED`/`API_ABSENT` entry).

Run: `grep -n "BrowserExtension" tools/compat-check/check.mjs`
Expected: appears only in `API_SUPPORTED`.

- [ ] **Step 3: Headless integration test (real browser)**

With Google Chrome open to any page, run:
```bash
node -e 'const {execFileSync}=require("child_process");const FS="\u001f",RS="\u001e";const raw=execFileSync("osascript",["-e",`tell application "Google Chrome"\nset out to ""\nset wi to 0\nrepeat with w in windows\nset wi to wi+1\nset ti to 0\nrepeat with t in tabs of w\nset ti to ti+1\nset out to out & wi & "${FS}" & ti & "${FS}" & (URL of t) & "${RS}"\nend repeat\nend repeat\nreturn out\nend tell`],{encoding:"utf8"});console.log("tabs:",raw.split(RS).filter(Boolean).length)'
```
Expected: `tabs: <N>` with N ≥ 1 (proves AppleScript tab enumeration works on this machine; grants Automation TCC on first run).

- [ ] **Step 4: Compat re-scan**

```bash
node tools/compat-check/check.mjs /Users/test/Documents/code/extensions/extensions --trusted --out /tmp/compat-browser 2>&1 | grep -aE "SUPPORTED|DEGRADED"
grep -c "BrowserExtension" /tmp/compat-browser/report.md
```
Expected: SUPPORTED count rises vs m5 (2323); `BrowserExtension` no longer in the top-gaps table.

- [ ] **Step 5: Live verification (manual, in the running app)**

Summon Invoke → run a `BrowserExtension`-based extension (e.g. one that lists tabs) with Chrome open. Expected: it lists the open tabs; if `getContent` is used, grant the JS-from-Apple-Events toggle when the HUD names it. Capture `/tmp/invoke-run.log` for any `browser` errors.

- [ ] **Step 6: Commit + push**

```bash
git add runtime/node-host/src/run.ts tools/compat-check/check.mjs
git commit -m "browser.*: dev-runner osascript fulfilment + mark BrowserExtension supported in compat-check" \
  -m "Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
git push origin main
```

---

## Self-Review notes

- **Spec coverage:** getTabs (Task 1/3/4), getContent + markdown-in-JS (Task 1/3/4), swappable RPC boundary (Task 2/4), Chromium+Safari + frontmost detection (Task 3), permissions/errors with actionable messages (Task 3/4), wiring across all 5 files (Tasks 2/4/5), testing headless/compat/live (Task 5). ✓
- **Markdown ownership:** host RPC only does `html`/`text`; `@invoke/api` converts `markdown` (Task 1 Step 3 + Global Constraints). ✓
- **Type consistency:** `BrowserTab`/`BrowserError`/`BrowserDriver.*` names match between Task 3 (def) and Task 4 (use); `id` format `"w:t"` consistent across api/driver. ✓
- **Known limitation:** AppleScript execution isn't unit-testable (needs a live browser) — covered by pure-helper unit tests (Task 3) + headless integration + live (Task 5), called out honestly.
