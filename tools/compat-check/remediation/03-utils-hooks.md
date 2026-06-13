# Remediation 03 — Missing `@raycast/utils` helpers & hooks

Gap category: **Missing `@raycast/utils` helpers & hooks** (the package is aliased
`@raycast/utils` → `@invoke/utils`, implemented at `packages/utils/src/index.ts`).
Excludes auth helpers (`OAuthService`/`withAccessToken`/`getAccessToken`/`useAI`) — owned by another agent.

Source of truth: `tools/compat-check/report-sandboxed/results.json` (2961 extensions; each entry has
`utilsImports[]` and `unknown[]` lines like `@raycast/utils:getFavicon (not implemented in Invoke)`).

## Tally (extensions referencing each absent export)

| Export | Extensions | Verdict | Effort |
|---|---:|---|---|
| `getFavicon` | 152 | PURE-JS ✅ quick win | S |
| `useLocalStorage` | 86 | PURE-JS ✅ (wraps existing `LocalStorage` RPC) | S |
| `getAvatarIcon` | 70 | PURE-JS ✅ quick win | S |
| `MutatePromise` (type) | 60 | PURE-JS ✅ (type only) | S |
| `useFrecencySorting` | 47 | PURE-JS ✅ (wraps `LocalStorage` RPC) | M |
| `getProgressIcon` | 46 | PURE-JS ✅ quick win | S |
| `withCache` | 18 | PURE-JS-ish — needs `Cache.set` un-stubbed (host) | M |
| `runPowerShellScript` | 18 | Windows-only → **N/A on macOS** (stub that throws) | S |
| `createDeeplink` | 7 | PURE-JS ✅ (needs `environment.extensionName`) | S |
| `useStreamJSON` | 3 | Needs fetch streaming + temp-file cache → host work | L |

**379 extensions** have *no other* `@raycast/utils` unknown besides the PURE-JS set
(`getFavicon`, `getAvatarIcon`, `getProgressIcon`, `useLocalStorage`, `useFrecencySorting`,
`MutatePromise`, `withCache`, `createDeeplink`) — i.e. closing those eight unblocks them on this axis.
**509** reference any `@raycast/utils` unknown at all.

All these helpers can live entirely in `packages/utils/src/index.ts`. The existing file already shows the
patterns to copy: hooks built on `usePromise`/`useState`/`useRef`; RPC done by lazy
`await import("@invoke/api")` (see `showFailureToast`, `runAppleScript`, `executeSQL`); image masks live at
`api.Image.Mask` (`packages/api/src/index.ts:409`); KV via `api.LocalStorage.*` (`api/src/index.ts:325-334`).

---

## QUICK PURE-JS WINS (do these first — S effort, no host changes)

These return Raycast `Image.ImageLike` descriptors or a thin RPC wrapper. They are plain functions/objects,
so they only need to be *exported* with the right shape; nothing in the Swift host changes.

### `getFavicon(url, options?)` — 152 extensions — Effort S

Real behavior: returns an `Image.ImageLike` descriptor that resolves a site's favicon. Raycast routes through
its favicon service; for parity we hit Google's S2 favicon endpoint (a public, no-auth, image URL) and apply a
fallback. Signature: `getFavicon(url: string, options?: { fallback?: Image.Fallback; size?: number; mask?: Image.Mask })`.
Returns either a string URL or an `{ source, fallback, mask }` object — both are valid `ImageLike`, so List/Detail
icon props accept it directly.

```ts
export interface FaviconOptions { fallback?: string; size?: number; mask?: string }
export function getFavicon(url: string, options: FaviconOptions = {}): { source: string; fallback?: string; mask?: string } {
  const size = options.size ?? 64;
  let host = url;
  try { host = new URL(url.includes("://") ? url : `https://${url}`).hostname; } catch { /* keep raw */ }
  return {
    source: `https://www.google.com/s2/favicons?sz=${size}&domain=${encodeURIComponent(host)}`,
    fallback: options.fallback,           // e.g. Icon.Globe passed by caller
    mask: options.mask,                   // api.Image.Mask.* if provided
  };
}
```
Examples (15): 1bookmark, 2fa-directory, alwaysdata, any-website-search, arc, at-profile, awesome-mac,
bento-me, bitly-url-shortener, bmrks, bonk-price, brand-dev, brave, browser-bookmarks, browser-history.

### `getAvatarIcon(name, options?)` — 70 extensions — Effort S

Real behavior: returns an `Image.ImageLike` for a generated initials avatar (colored circle + initials), used as
a placeholder when no profile image exists. Signature:
`getAvatarIcon(name: string, options?: { background?: string; gradient?: boolean })`.
Raycast returns a `data:` SVG URL. We can generate the identical SVG client-side — pure string work, no host:

```ts
const AVATAR_COLORS = ["#EB5757","#F2994A","#F2C94C","#27AE60","#2F80ED","#9B51E0","#56CCF2","#BB6BD9"];
function hashStr(s: string): number { let h = 0; for (const c of s) h = (h * 31 + c.charCodeAt(0)) | 0; return Math.abs(h); }
export function getAvatarIcon(name: string, options: { background?: string; gradient?: boolean } = {}): { source: string; mask?: string } {
  const initials = (name.trim().split(/\s+/).map((w) => w[0]).slice(0, 2).join("") || "?").toUpperCase();
  const bg = options.background ?? AVATAR_COLORS[hashStr(name) % AVATAR_COLORS.length];
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128"><rect width="128" height="128" fill="${bg}"/><text x="64" y="64" font-family="-apple-system,Helvetica,sans-serif" font-size="56" fill="#fff" text-anchor="middle" dominant-baseline="central">${initials}</text></svg>`;
  return { source: `data:image/svg+xml;base64,${Buffer.from(svg).toString("base64")}`, mask: "circle" };
}
```
(Confirm the host's icon renderer accepts `data:image/svg+xml;base64,...` sources; List/Detail icon handling lives
in the macOS extension host — if SVG data URLs aren't rendered, fall back to a PNG service or downgrade `mask`.)
Examples (15): appwrite, asana, chatgo, chatwoot, code-saver, contentful, coolify, cpanel, cron, css-gg,
cursor-directory, dovetail, farcaster, firefox-tabs, frill.

### `getProgressIcon(progress, color?, options?)` — 46 extensions — Effort S

Real behavior: returns an `Image.ImageLike` of a circular progress ring (0..1). `progress: number`,
`color?: Color | string` (default Raycast accent), `options?: { background?; backgroundOpacity? }`. Pure SVG:

```ts
export function getProgressIcon(progress: number, color = "#FF6363", options: { background?: string; backgroundOpacity?: number } = {}): { source: string } {
  const p = Math.max(0, Math.min(1, progress));
  const r = 45, c = 2 * Math.PI * r, dash = c * p;
  const bg = options.background ?? "#000000", bgOp = options.backgroundOpacity ?? 0.1;
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="100" height="100"><circle cx="50" cy="50" r="${r}" fill="none" stroke="${bg}" stroke-opacity="${bgOp}" stroke-width="10"/><circle cx="50" cy="50" r="${r}" fill="none" stroke="${color}" stroke-width="10" stroke-dasharray="${dash} ${c}" stroke-linecap="round" transform="rotate(-90 50 50)"/></svg>`;
  return { source: `data:image/svg+xml;base64,${Buffer.from(svg).toString("base64")}` };
}
```
Examples (15): aegis, agent-usage, brew, checklist, deepl-api-usage, digger, ente-auth, helldivers2, hue,
intermittent-fasting, jellyfin, jsr, life-progress, lifx, linear.

### `MutatePromise<T, U>` (type) — 60 extensions — Effort S

Real behavior: a **type only** — the signature of the `mutate` function returned by `usePromise`/`useCachedPromise`.
Extensions import it to annotate props (`mutate: MutatePromise<Item[]>`). Adding the export silences 60 failures with
zero runtime. Note: our `usePromise`/`useCachedPromise` (`utils/src/index.ts:17,171`) currently return
`{ data, isLoading, error, revalidate }` and do **not** expose `mutate` yet. Add the type now; a real `mutate`
implementation (optimistic update + rollback) is a separate M task on the hooks themselves.

```ts
export type MutatePromise<T, U = undefined> = (
  asyncUpdate?: Promise<U>,
  options?: { optimisticUpdate?: (data: T) => T; rollbackOnError?: boolean | ((data: T) => T); shouldRevalidateAfter?: boolean },
) => Promise<U>;
```
Examples (15): anytype, apple-reminders, appwrite, arc, asana, autumn, aws, brew, browser-tabs,
cal-com-share-meeting-links, changedetection-io, creem, dub, easy-new-file, firefox-tabs.

### `useLocalStorage<T>(key, initialValue?)` — 86 extensions — Effort S

Real behavior: a hook over `LocalStorage` returning `{ value, setValue, removeValue, isLoading }` with `value`
JSON-(de)serialized. `LocalStorage` is already host-fulfilled (`api/src/index.ts:325`), so this is a pure wrapper
built on `usePromise` exactly like `useSQL` wraps `executeSQL`:

```ts
export function useLocalStorage<T>(key: string, initialValue?: T) {
  const api = useRef<typeof import("@invoke/api")>();
  const state = usePromise<T | undefined>(async () => {
    const a = (api.current ??= await import("@invoke/api"));
    const raw = await a.LocalStorage.getItem<string>(key);
    return raw == null ? initialValue : (JSON.parse(raw) as T);
  }, [key]);
  const setValue = useCallback(async (val: T) => {
    const a = (api.current ??= await import("@invoke/api"));
    await a.LocalStorage.setItem(key, JSON.stringify(val));
    state.revalidate();
  }, [key]); // eslint-disable-line react-hooks/exhaustive-deps
  const removeValue = useCallback(async () => {
    const a = (api.current ??= await import("@invoke/api"));
    await a.LocalStorage.removeItem(key);
    state.revalidate();
  }, [key]); // eslint-disable-line react-hooks/exhaustive-deps
  return { value: state.data, setValue, removeValue, isLoading: state.isLoading };
}
```
Examples (15): aave-search, ai-stats, appwrite, arca, at-profile, bartender, bash-commands, beeper, bible,
bikeshare-station-status, brand-dev, brave-search-with-results, brreg, chiikawa-character, close-apps.

### `createDeeplink(options)` — 7 extensions — Effort S

Real behavior: builds a `raycast://` deeplink string (synchronous, pure). Overloads:
- Extension: `{ command: string; extensionName?: string; ownerOrAuthorName?: string; arguments?: object; launchType?: LaunchType; context?: object; fallbackText?: string }`
- Script command: `{ type: "script-command"; command; arguments?: string[] }`
We mint `invoke://` (or keep `raycast://` for string-compat) URLs. Needs the current extension name — add
`extensionName`/`ownerOrAuthorName` to `environment` (`api/src/index.ts:336`); `commandName` already exists.

```ts
export function createDeeplink(opts: { command?: string; extensionName?: string; ownerOrAuthorName?: string; arguments?: Record<string, unknown>; context?: Record<string, unknown>; fallbackText?: string; type?: string }): string {
  const protocol = "raycast://"; // alias target; swap to invoke:// if the host registers that scheme
  if (opts.type === "script-command") return `${protocol}script-commands/${opts.command}`;
  const ext = opts.extensionName ?? ""; const owner = opts.ownerOrAuthorName ?? "";
  const params = new URLSearchParams();
  if (opts.arguments) params.set("arguments", JSON.stringify(opts.arguments));
  if (opts.context) params.set("context", JSON.stringify(opts.context));
  if (opts.fallbackText) params.set("fallbackText", opts.fallbackText);
  const qs = params.toString();
  return `${protocol}extensions/${owner}/${ext}/${opts.command}${qs ? `?${qs}` : ""}`;
}
```
Examples (7): bartender, bundles, context7, harpoon, inbox-ai, spiceblow-database, trenit.

---

## NEEDS A LITTLE HOST / HOOK WORK

### `useFrecencySorting<T>(data, options?)` — 47 extensions — Effort M

Real behavior: returns `{ data: T[] (sorted by frecency), visitItem(item), resetRanking(item) }`. Frecency =
frequency × recency; rankings persist in `LocalStorage` keyed per item id. PURE-JS — wraps the existing
`LocalStorage` RPC, no host change; M only because of the scoring/persistence logic. `options`:
`{ namespace?, key?: (item) => string, sortUnvisited?: (a,b) => number }`.

Sketch: keep a `Record<id, { lastVisited: number; visitCount: number }>` in `LocalStorage` under
`frecency-<namespace>`; load via `useLocalStorage`; sort `data` by a frecency score
(`visitCount * recencyWeight(now - lastVisited)`); `visitItem` bumps count + timestamp and persists;
`resetRanking` deletes the entry. Build it on top of `useLocalStorage` above so it's one composition, not new RPC.
Examples (15): aws, bartender, beeper, better-aliases, ccf-what, chatgpt-atlas, cheatsheets-remastered,
coinmarketcap-crypto-price-crawler, dashlane-vault, defbro, dust-tt, ente-auth, filemaker-snippets, gif-search,
git-co-authors.

### `withCache(fn, options?)` — 18 extensions — Effort M

Real behavior: wraps an async fn so its result is cached (with `maxAge`) in Raycast's `Cache`; returns a fn with
`.clearCache()`. **Blocked by a host stub**: `Cache.set` currently throws `unsupported("Cache.set")` and
`Cache.get` returns `undefined` (`api/src/index.ts:358-364`). Two options:
1. Implement against `LocalStorage` instead of `Cache` (pure-JS, no host change) — serialize
   `{ value, expiresAt }` under a hash of args. Recommended for a quick unblock.
2. Un-stub `Cache` in the host (separate task) and wrap that.

```ts
export function withCache<A extends unknown[], T>(fn: (...a: A) => Promise<T>, options: { maxAge?: number; validate?: (d: T) => boolean } = {}) {
  const ns = "withCache:";
  const wrapped = async (...args: A): Promise<T> => {
    const a = await import("@invoke/api");
    const key = ns + JSON.stringify(args);
    const raw = await a.LocalStorage.getItem<string>(key);
    if (raw) { const { value, expiresAt } = JSON.parse(raw); if ((!expiresAt || Date.now() < expiresAt) && (!options.validate || options.validate(value))) return value as T; }
    const value = await fn(...args);
    await a.LocalStorage.setItem(key, JSON.stringify({ value, expiresAt: options.maxAge ? Date.now() + options.maxAge : 0 }));
    return value;
  };
  (wrapped as { clearCache?: () => Promise<void> }).clearCache = async () => { /* prefix-clear via allItems+removeItem */ };
  return wrapped;
}
```
Examples (15): anonaddy, base-ui-docs, clockodo, crypto-portfolio-tracker, essay, git-worktrees, google-calendar,
laravel-herd, meme-generator, model-context-protocol-registry, open-props, purpleair, ram-prices, slack-summarizer,
tablepro.

---

## DEFER / N/A

### `runPowerShellScript(script, options?)` — 18 extensions — Effort S (stub)

Windows-only (PowerShell). **N/A on macOS** — these extensions are Windows-targeted (e.g. powertoys-tool-runner,
windows-default-wallpapers, remote-desktop, vmware-vcenter). Export a stub that throws a clear error at call time
(mirror the `unsupported(...)` pattern in `api/src/index.ts:354`) so merely importing it doesn't break module load:

```ts
export async function runPowerShellScript(_script: string, _options?: unknown): Promise<string> {
  throw new Error("@invoke/utils: runPowerShellScript is Windows-only and not available on macOS");
}
```
Adding the export alone fixes the *load-time* import failure for the few cross-platform extensions that import it
behind a platform guard. Examples (15): bilibili, getcompress, immich, microsoft-office, one-time-password,
open-in-visual-studio-code, powertoys-tool-runner, prism-launcher, raycast-wallpaper, remote-desktop, slack,
spotify-player, visual-studio-code, vmware-vcenter, windows-default-wallpapers.

### `useStreamJSON<T>(url|file, options?)` — 3 extensions — Effort L

Real behavior: streams a large JSON array (over fetch or a local file), parsing incrementally with backpressure,
filtering/transform, and caching to a temp file; returns `{ data, isLoading, pagination, mutate, revalidate }`.
Needs **host work**: streaming fetch + a writable temp-file cache (the sandboxed child has no fs — see the
`fs`-denied blocker that dominates `topGaps`). Lowest priority (3 extensions). Examples: dicom, haystack, nusmods.

---

## Recommended order

1. **S, no host:** `getFavicon`, `getAvatarIcon`, `getProgressIcon`, `MutatePromise` (type), `useLocalStorage`,
   `createDeeplink`, `runPowerShellScript` (throwing stub). → bulk of the 379 pure-only extensions.
2. **M, no host:** `useFrecencySorting` (on `useLocalStorage`), `withCache` (on `LocalStorage`, option 1).
3. Host follow-ups (separate tasks): add `environment.extensionName`/`ownerOrAuthorName` for `createDeeplink`;
   un-stub `Cache` if `withCache` should use it; verify the icon renderer accepts `data:image/svg+xml` sources.
4. **L, defer:** `useStreamJSON` (needs streaming fetch + temp-file cache).
