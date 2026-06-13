# Remediation 05 — AI and OAuth

Scope: the two big v2 feature areas from PLAN.md §7. Tally is over the sandboxed scan
(`tools/compat-check/report-sandboxed/results.json`, 2961 extensions; 650 SUPPORTED /
475 DEGRADED / 1836 UNSUPPORTED).

**Headline numbers**

| Area | Distinct extensions blocked |
|---|---|
| AI (any of: `AI.ask`, `tools[]`, `ai` instructions, `useAI`) | **254** |
| OAuth (any of: `OAuth.PKCEClient`, `OAuthService`, `withAccessToken`, `getAccessToken`) | **120** |
| **Union (AI ∪ OAuth)** | **346** |
| Overlap (need BOTH) | 28 |

Per-symbol counts (exact scan blocker strings):

| Symbol / blocker | Count |
|---|---|
| `declares extension-level \`ai\` instructions — ignored` | 145 |
| `OAuth: OAuth.PKCEClient throws` | 96 |
| `AI: AI.ask throws` | 90 |
| `declares AI tools[] (N) — AI extensions not supported` | 186 (extensions) |
| `@raycast/utils:withAccessToken` | 57 |
| `@raycast/utils:OAuthService` | 55 |
| `@raycast/utils:getAccessToken` | 32 |
| `@raycast/utils:useAI` | 23 |
| `@raycast/api:OAuthClient` (alias, review) | 1 |
| `@raycast/utils:AI` (alias, review) | 1 |

Every AI- and OAuth-blocked extension is currently **UNSUPPORTED** (the gap is the only or
a co-blocker). Closing both areas moves up to 346 extensions toward runnable (subject to
their other gaps — many also need `useNavigation`, `confirmAlert`, sandbox built-ins, etc.,
covered in other remediation docs).

---

## What already exists (do not rebuild)

The host already ships a complete Anthropic client and secret storage — the work is almost
entirely *wiring an existing host capability out to the sandboxed extension runtime over RPC*,
not building an LLM client or a Keychain layer from scratch.

- **`apps/macos/Sources/InvokeServices/AIService.swift`** — Anthropic Messages API client.
  `complete(system:user:maxTokens:)` (one-shot) and `stream(system:messages:…)` (SSE).
  Reads the key from `ANTHROPIC_API_KEY` env, falling back to Keychain (`com.invoke.ai` /
  `anthropic-api-key`). Model from `INVOKE_AI_MODEL` env, default `claude-sonnet-4-6`
  (`AIService.swift:27`). Key is never logged/echoed; `hasKey` checked via a non-secret
  UserDefaults presence marker so status checks never trigger a Keychain prompt.
- **`AppController.swift:1274–1430`** — built-in AI commands (Improve Writing, Ask AI, AI
  Chat) already drive `AIService`. These are *host* commands, NOT reachable by extensions yet.
- **Secret storage** — `AppSettings.swift:116–141` (`keychainGet`/`keychainSet`,
  per-extension service `com.invoke.ext.<extID>`); `extensionPref(extID:name:secret:)` at
  `:88`. `password`-type prefs already route to Keychain; non-secret prefs to UserDefaults
  and are delivered to the child via `INVOKE_PREFERENCES` env (read by `getPreferenceValues`,
  `packages/api/src/index.ts:342`).
- **RPC plumbing** — child→host bridge `globalThis.__invokeHostRpc__` (`packages/api/src/index.ts:279`),
  wired by `runtime/node-host/src/child.ts:37`. Host dispatch + capability allowlist in
  `ExtensionHost.swift:36` (`allowedRPC`) and the big `switch method` in
  `AppController.swift:1559`. Adding a capability = add the method name to `allowedRPC`,
  add a `case` to the switch, add a wrapper in `packages/api`.
- **Manifest `tools[]` already parsed** — `AppController.swift:1989` reads `json["tools"]`
  into `ExtensionCapability` (name/title/description) for the Settings detail panel. It is
  parsed but never executable.
- **Command modes** — `view` / `no-view` only. `import.ts:197` defaults unknown modes to
  `view`; `child.ts:96` branches on `INVOKE_MODE`. There is no `ai` command mode yet.

Stubs to replace: `packages/api/src/index.ts:365` (`AI.ask` → `unsupported`), `:366`
(`OAuth.PKCEClient` → throws in ctor). `packages/utils/src/index.ts` has **none** of the
OAuth/AI helpers (confirmed by grep — they are entirely absent, not stubbed).

---

# Section A — AI

Default model policy (apply everywhere a model is chosen): default to the latest Claude —
**Opus 4.8** for higher-quality / agentic `tools[]` runs, **Sonnet 4.6** for fast
`AI.ask`/inline calls — via the Anthropic Messages API. This is the Anthropic-friendly
default and matches the existing `AIService` shape. Update the `INVOKE_AI_MODEL` default in
`AIService.swift:27` to the current Opus/Sonnet IDs and let it stay overridable by env.
**Do not hardcode or request an API key** anywhere — the key is read by the host from
`ANTHROPIC_API_KEY` or the Keychain via `AIService.apiKey()` (already implemented). The
sandboxed child never sees the key; it only sees text responses over RPC.

### A1. `AI.ask` (+ `AI.Model` / `AI.Creativity` enums) — host-bridged LLM call

**Files:** `packages/api/src/index.ts`, `runtime/node-host/src/child.ts` (no change —
generic RPC), `ExtensionHost.swift` (allowlist), `AppController.swift` (dispatch),
optional `schema/src/index.ts` (only if streaming, see below).

Replace the stub at `packages/api/src/index.ts:365` with a real RPC wrapper:

```ts
export const AI = {
  Model: { /* Raycast enum mirror */ "Anthropic_Claude_Opus": "claude-opus", "Anthropic_Claude_Sonnet": "claude-sonnet",
           "OpenAI_GPT4": "claude-opus" /* alias unsupported providers onto Claude */ } as Record<string, string>,
  Creativity: { none: 0, low: 0.25, medium: 0.5, high: 0.75, maximum: 1 } as const,
  ask(prompt: string, opts?: { model?: string; creativity?: number | string; signal?: AbortSignal }): Promise<string> & { on?: unknown } {
    return rpc("ai.ask", { prompt, model: opts?.model, creativity: opts?.creativity }) as Promise<string>;
  },
};
```

Host side: add `"ai.ask"` to `ExtensionHost.allowedRPC` (`:36`) and a `case "ai.ask"` in the
`AppController.swift:1559` switch that calls the **existing** `ai.complete(system:user:)`:

```swift
case "ai.ask":
    let prompt = arg("prompt")?.stringValue ?? ""
    guard ai.hasKey else { return .null }              // Raycast throws "no access"; mirror with an error result
    let modelOverride = arg("model")?.stringValue       // map to Opus 4.8 / Sonnet 4.6
    let r = await ai.complete(system: "You are a helpful assistant.", user: prompt, maxTokens: 2000)
    switch r { case .success(let t): return .string(t); case .failure(let e): /* send rpcResult error */ }
```

Notes:
- `AI.ask` in Raycast returns a `Promise` that is *also* an `EventEmitter` (`.on("data", …)`
  for token streaming). MVP: resolve the full string (most callers `await` it). Streaming is
  a follow-up — `AIService.stream` already exists; surface it as incremental `rpcResult`
  frames (needs a new `schema` message kind, see A5).
- Raycast gates AI behind a Pro entitlement / per-extension `ai` access; Invoke gates behind
  "is a key configured" (`ai.hasKey`) + the existing per-extension consent pattern used for
  `runAppleScript`/`executeSQL`. Throw a clear `AI.ask: no AI access configured` when no key,
  so extensions that `try/catch` degrade gracefully.
- Map unknown/3rd-party `AI.Model` values (OpenAI/Google strings) onto the Claude default
  rather than failing — keeps extensions that hardcode a model running.

**Effort: M · Risk: Low** (client + secrets already exist; this is RPC wiring + an enum
mirror). **Unblocks: 90** (`AI.ask`). Examples (15): ai-code-namer, ai-git-assistant,
anonaddy, app-updates, apple-notes, apple-reminders, bhagavad-gita-quotes, bootstrap-icons,
caltask, cleanshotx, color-picker, colorify, dnb-book-lookup, dtf, duck-facts.

### A2. `useAI` (@raycast/utils hook)

**Files:** `packages/utils/src/index.ts` (new export).

Thin hook over `usePromise` + `AI.ask` (mirrors the existing `runAppleScript`/`executeSQL`
lazy-import pattern at `utils/src/index.ts:79`):

```ts
export function useAI(prompt: string, options: { creativity?: number|string; model?: string; stream?: boolean; execute?: boolean } = {}) {
  const state = usePromise(async () => {
    if (options.execute === false) return "";
    const api = await import("@invoke/api");
    return api.AI.ask(prompt, { model: options.model, creativity: options.creativity });
  }, [prompt, options.model, String(options.creativity), options.execute]);
  return { ...state, data: state.data ?? "" };   // Raycast's useAI.data is "" until first chunk
}
```

**Effort: S · Risk: Low** (depends on A1). **Unblocks: 23.** Examples (15): color-picker,
dtf, dungeons-dragons, effect-docs, feedbin, ingredients-lister, laravel-artisan, linear,
lucide-icons, markdown-slides, meduza, my-daily-log, oblique-strategies, opencode-sessions,
promptlab.

### A3. Manifest `ai` instructions (extension-level + command-level)

**Files:** `runtime/node-host/src/import.ts` (manifest parse), `AppController.swift`
(launch env), `packages/api/src/index.ts` (expose on `environment`).

The `ai` block (Raycast: top-level `ai.instructions` + `ai.evals`, plus per-command
overrides) is currently parsed nowhere and dropped (`declares extension-level \`ai\`
instructions — ignored`, 145). It is a *system-prompt prefix* used when the extension's AI
tools / `@`-mode run. Lowest-risk fix:

1. In `import.ts` manifest read, capture `json.ai?.instructions` (and per-command `ai`).
2. Pass to the child as `INVOKE_AI_INSTRUCTIONS` env (same delivery channel as
   `INVOKE_PREFERENCES`, set in `launchExtension`, `AppController.swift:2004`).
3. The host prepends these instructions to the `system` string of any `ai.ask` /
   `ai.tools.run` call originating from that extension (host already owns the `system`
   argument — see `AppController.swift:1351`).
4. Optionally expose read-only on `environment.aiInstructions` in `packages/api`.

For an extension whose ONLY AI surface is the `ai` block + `tools[]` (no `AI.ask` calls),
this combined with A4 makes it loadable instead of flagged.

**Effort: S (instructions only) / M (with evals)** · Risk: Low. **Unblocks: 145.**
Examples (15): anytype, app, apple-notes, apple-reminders, arc, aws, bartender, bear,
beeper, beszel, better-uptime, betterdisplay, cal-com-share-meeting-links, caschys-blog,
ccusage.

### A4. AI-extension model: manifest `tools[]` + the `@` AI command mode

**Files:** `runtime/node-host/src/import.ts` (mode/tool parse), `child.ts` (new `ai-tool`
exec path), `schema/src/index.ts` (tool-call frames), `ExtensionHost.swift` +
`AppController.swift` (agent loop), `packages/api/src/index.ts` (`Tool` types).

This is the largest piece. A Raycast AI extension declares `tools[]` in the manifest (each a
file exporting a default async function + a JSON-schema `input`); the user invokes the
extension as an `@extension` mention in the AI command bar, and the model decides which tools
to call. Wiring:

1. **Parse** — `tools[]` is already read into `ExtensionCapability` at
   `AppController.swift:1989` (name/title/description). Extend to also capture each tool's
   `input` JSON schema (Raycast keeps it in a sibling type file / `input` field) and its
   entry path, like commands are resolved in `import.ts:197`.
2. **Tool-call exec path in `child.ts`** — today `child.ts:96` handles only `no-view`
   (run default export) and `view` (render). Add an `INVOKE_MODE === "ai-tool"` branch:
   import the tool module, `await default(input)`, return the JSON result. Reuse the same
   socket/RPC; the result returns over a new schema frame (A5).
3. **Agent loop in the host** — when the user runs `@ext <prompt>`, the host calls
   `AIService` with `tools` = the extension's tool schemas (Anthropic `tools` + tool_use
   blocks). On a `tool_use` from the model, the host spawns/reuses that extension's child in
   `ai-tool` mode, passes the tool name + input, gets the JSON result, feeds it back as a
   `tool_result`, and loops until the model emits final text. `AIService` needs a small
   extension to pass `tools` and parse `tool_use` blocks (the Messages API already supports
   this; current `complete`/`stream` don't send `tools`).
4. **`@` command mode UI** — extend the palette: typing `@` lists AI-capable extensions
   (those with `tools[]`), selecting one enters an AI-chat-like surface scoped to that
   extension. Reuse the existing AI Chat surface (`AppController.swift:1373+`) with the
   extension's tools + `ai` instructions (A3) bound in.
5. Default the agent model to **Opus 4.8** (better tool use); fall back to Sonnet 4.6.

**Effort: L · Risk: Med** (new exec mode, agent loop, tool-schema marshaling, UI; the
sandbox per-tool spawn must respect the same capability gating as commands). **Unblocks: 186**
(the `tools[]` count). Examples (15): anytype, apple-notes, apple-reminders, arc, are-na,
at-profile, awork, aws, bartender, base64, bear, beeper, beszel, better-uptime, anytype.

### A5. Schema additions for AI streaming + tool calls (supporting)

**File:** `schema/src/index.ts`.

Add child↔host frames so A1 streaming and A4 tool calls don't overload generic `rpcResult`:

```ts
// host → child:  | { kind: "aiToolCall"; id: number; tool: string; input: unknown }
// child → host:  | { kind: "aiToolResult"; id: number; result?: unknown; error?: string }
// host → child:  | { kind: "rpcDelta"; id: number; chunk: string }   // incremental AI.ask streaming
```

Keep Swift `Codable` mirror in lockstep (PLAN.md §8.7). **Effort: S · Risk: Low.**

---

# Section B — OAuth

The OAuth need is concentrated in API/cloud integrations (GitHub, Google, Jira, Linear,
Asana, Slack-likes, etc.). Token storage reuses the **existing per-extension Keychain**
(`com.invoke.ext.<extID>`, `AppSettings.swift:116`). The macOS host must own the
authorize/redirect leg because the sandboxed child has no `net`/loopback server and cannot
open a browser except via the allowlisted `open` capability.

### B1. `OAuth.PKCEClient` (authorize + token store + refresh)

**Files:** `packages/api/src/index.ts` (replace stub `:366`), `ExtensionHost.swift`
(allowlist), `AppController.swift` (dispatch + redirect handling), `AppSettings.swift`
(token store helpers — reuse `keychainGet/Set`).

Replace the throwing stub with a real class whose methods are RPC calls — the *logic* lives
in the host:

```ts
export const OAuth = {
  RedirectMethod: { Web: "web", App: "app", AppURI: "appURI" } as const,
  PKCEClient: class {
    constructor(private opts: { redirectMethod: string; providerName: string; providerIcon?: unknown; providerId?: string; description?: string }) {}
    authorizationRequest(o: { endpoint: string; clientId: string; scope: string; extraParameters?: Record<string,string> }) {
      // PKCE (codeVerifier/codeChallenge) generated host-side; return an opaque handle the host tracks.
      return rpc("oauth.authorizeRequest", { ...this.opts, ...o }) as Promise<{ codeChallenge: string; state: string; redirectURI: string; toURL: () => string }>;
    }
    authorize(req: unknown) { return rpc("oauth.authorize", { provider: this.opts.providerId ?? this.opts.providerName, request: req }) as Promise<{ authorizationCode: string }>; }
    setTokens(t: unknown)   { return rpc("oauth.setTokens",   { provider: this.opts.providerId ?? this.opts.providerName, tokens: t }) as Promise<void>; }
    getTokens()             { return rpc("oauth.getTokens",   { provider: this.opts.providerId ?? this.opts.providerName }) as Promise<{ accessToken: string; refreshToken?: string; expiresIn?: number; isExpired(): boolean } | undefined>; }
    removeTokens()          { return rpc("oauth.removeTokens",{ provider: this.opts.providerId ?? this.opts.providerName }) as Promise<void>; }
  },
};
```

Host implementation (`AppController.swift`, all five methods added to `allowedRPC` at
`ExtensionHost.swift:36` and as `case`s in the `:1559` switch):

- **`oauth.authorizeRequest`** — host generates a PKCE `code_verifier` + `code_challenge`
  (S256, `CryptoKit` SHA256), a random `state`, and builds the loopback `redirect_uri`
  (`http://127.0.0.1:<port>/callback` for `RedirectMethod.App`, or the Raycast-style
  `https://raycast.com/redirect` web flow — Invoke should use its own
  `https://invoke.app/redirect` / a custom `invoke://` URL scheme; **do not fabricate a
  Raycast-hosted endpoint**). Returns verifier/challenge/state/redirectURI; host keeps the
  verifier in memory keyed by `state` (never crosses to the child).
- **`oauth.authorize`** — host opens the provider's authorize URL in the default browser
  (reuse the existing `open` capability path), then:
  - **App/loopback:** start a transient `NWListener`/`GCDAsyncSocket` on `127.0.0.1`,
    capture the `?code=&state=` redirect, validate `state`, shut the listener down.
  - **URL scheme:** register an `invoke://oauth-callback` scheme (Info.plist
    `CFBundleURLTypes`) and resolve the pending request in
    `application(_:open:)` / `NSApp` URL-event handler.
  Returns `{ authorizationCode }` to the extension, which then exchanges it for tokens
  (Raycast extensions usually do the token POST themselves with `fetch`, which already works).
- **`oauth.setTokens` / `getTokens` / `removeTokens`** — persist the token JSON in the
  per-extension Keychain (`AppSettings.keychainSet(service: "com.invoke.ext.<extID>",
  account: "oauth.tokens")`). `getTokens` computes `isExpired()` host-side from a stored
  `expiresAt` and exposes it; for refresh, either (a) let the extension call its own refresh
  endpoint and re-`setTokens` (Raycast's model), or (b) add an optional host refresh in B2.
- **Data residency:** token storage is local Keychain only (GCC/EU footprint preserved — no
  token leaves the device). Note this in the consent dialog.

**Effort: L · Risk: Med-High** (loopback/redirect handling, URL-scheme registration, PKCE
crypto, and these are credential flows — get `state` validation + Keychain scoping right).
**Unblocks: 96** (`OAuth.PKCEClient`). Examples (15): akkoma, alloy, are-na, awork, backstage,
beeper, calendly, canva, chatwork-search, circleback, clipmate, cloudstash, confluence, coze,
dash-off.

### B2. `@raycast/utils` `OAuthService` + `withAccessToken` + `getAccessToken`

**Files:** `packages/utils/src/index.ts` (new exports — all currently **absent**).

These are convenience wrappers around `OAuth.PKCEClient` (B1). Implement in `@invoke/utils`:

- **`OAuthService`** — class bundling a `PKCEClient` + an `authorize()` that runs the full
  request→authorize→token-exchange→setTokens sequence, plus the named provider presets
  Raycast ships (`OAuthService.github(...)`, `.google(...)`, `.slack(...)`, etc.). Port the
  preset endpoint/scopes config; the actual auth uses B1's RPCs. Presets are config, not
  brand fabrication — they target the providers' real OAuth endpoints the extension already
  names.

```ts
export class OAuthService {
  constructor(public options: { client: InstanceType<typeof OAuth.PKCEClient>; clientId: string; scope: string; authorizeUrl: string; tokenUrl: string; refreshTokenUrl?: string; extraParameters?: Record<string,string>; onAuthorize?: (t: {token:string}) => void }) {}
  async authorize(): Promise<string> {
    const existing = await this.options.client.getTokens();
    if (existing?.accessToken && !existing.isExpired()) return existing.accessToken;
    const req = await this.options.client.authorizationRequest({ endpoint: this.options.authorizeUrl, clientId: this.options.clientId, scope: this.options.scope, extraParameters: this.options.extraParameters });
    const { authorizationCode } = await this.options.client.authorize(req);
    const tokens = await fetchTokenExchange(this.options.tokenUrl, { code: authorizationCode, /* codeVerifier from req */ });
    await this.options.client.setTokens(tokens);
    this.options.onAuthorize?.({ token: tokens.access_token });
    return tokens.access_token;
  }
  static github(o: Partial<…>) { return new OAuthService({ authorizeUrl: "https://github.com/login/oauth/authorize", tokenUrl: "https://github.com/login/oauth/access_token", scope: "repo", ...o }); }
  // .google(), .slack(), .jira(), .linear(), .asana(), … (port Raycast preset config)
}
```

- **`getAccessToken()`** — returns the access token of the current request scope. Backed by a
  module-level holder set by `withAccessToken` after a successful `authorize()`:

```ts
let _token: { token: string; type?: "oauth"|"personal" } | undefined;
export function getAccessToken() { if (!_token) throw new Error("getAccessToken: called outside a withAccessToken-wrapped command"); return _token; }
```

- **`withAccessToken(service)(fnOrComponent)`** — HOC/wrapper that runs
  `service.authorize()` before the command's function/component, stores the token for
  `getAccessToken`, and (for view commands) shows a loading state until authorized. Mirror
  Raycast's dual signature (wrap a `() => Promise` for no-view, or a React component for
  view). Type `WithAccessTokenComponentOrFn` also needs exporting (2 extensions import it).

**Effort: M · Risk: Med** (depends entirely on B1; the wrappers are mechanical but the
provider presets and the view-vs-function HOC dual mode need care). **Unblocks: 55
(`OAuthService`) / 57 (`withAccessToken`) / 32 (`getAccessToken`) — 96 distinct via OAuth
overall.** Examples (15): alloy, asana, beeper, chatwork-search, circleback, days2,
done-bear, dub, dust-tt, fabric, figma-files-raycast-extension, forked-extensions, freeagent,
github, github-copilot.

### B3. `OAuthClient` / `AI` import aliases (cleanup)

One extension imports `@raycast/api:OAuthClient` and one imports `@raycast/utils:AI` (alias
forms). Re-export aliases (`export { OAuth as OAuthClient }` etc.) so the module loads.
**Effort: S · Risk: Low. Unblocks: 2.**

---

## Suggested sequencing

1. **A1 + A2** (S/M, low risk) — `AI.ask` + `useAI` reuse the existing `AIService`; biggest
   single win (90 + 23) for least work. Bump the model default to Opus 4.8 / Sonnet 4.6.
2. **A3** (S) — `ai` instructions env wiring; unblocks 145 manifest-only flags cheaply.
3. **B1 → B2** (L → M) — PKCEClient first (host owns redirect + Keychain token store), then
   the utils wrappers on top (96 + their consumers).
4. **A4 + A5** (L) — full AI-extension `tools[]` + `@`-mode agent loop; largest, do last.

## Guardrails (org compliance)

- No API key or token value is ever hardcoded, requested in this doc, logged, or sent to the
  child. The host reads the Anthropic key from env/Keychain (existing `AIService.apiKey()`);
  OAuth tokens live only in the per-extension Keychain and never leave the device.
- OAuth provider presets reference the providers' own real OAuth endpoints (no fabricated
  Invoke/Raycast-hosted auth services beyond Invoke's own redirect endpoint).
- Each new capability (`ai.ask`, the `oauth.*` methods) must be added to BOTH the Node
  supervisor allowlist AND `ExtensionHost.allowedRPC`, and gated by the same per-extension
  consent pattern already used for `runAppleScript`/`executeSQL`.
