# Invoke v2 — Raycast compatibility roadmap

Synthesized from a scan of **2,961 cloned extensions** and six capability deep-dives.
Numbers are from `project.mjs`, which recomputes runnability per milestone and
**de-duplicates** extensions blocked by multiple gaps (so milestones don't double-count).

## Where we are today (sandboxed, default)

| Status | Count | % |
|---|---:|---:|
| ✅ Supported | 650 | 22% |
| ⚠️ Degraded (runs, limited) | 475 | 16% |
| ❌ Unsupported | 1,836 | 62% |
| **Runs at all (supported+degraded)** | **1,125** | **38%** |

Trusted mode (unsandboxed) today: 650 / 883 / 1,428.

## Hard-blocker reach (how many extensions each gap blocks from running)

| Capability | Extensions blocked |
|---|---:|
| Node built-ins / sandbox (`fs`, `child_process`…) + `useExec` | 1,031 |
| System/selection APIs (`getSelectedText`, `getApplications`, Finder, `trash`…) | 582 |
| Missing pure-JS `@raycast/utils` (`getFavicon`, `useLocalStorage`…) | 410 |
| Interop stubs absent (`launchCommand`, `BrowserExtension`, deeplinks…) | 352 |
| AI (`AI.ask`, `tools[]`, `ai`, `useAI`) | 254 |
| Unsupported command modes (`menu-bar`) | 236 |
| OAuth (`OAuth.PKCEClient`, `OAuthService`, `withAccessToken`…) | 120 |
| Legacy v1 API names (`ToastStyle`, `OpenInBrowserAction`…) | 105 |
| Other / third-party (unmapped) | 141 |

(`useNavigation` push/pop, `confirmAlert`, `Cache` writes show as *degradations*, not
hard blockers — they don't crash the import, they silently no-op; ~815 / 650 / 258 extensions.)

## Projected roadmap

| Milestone | Runs | Fully supported | Run % |
|---|---:|---:|---:|
| **M0** today | 1,125 | 650 | 38% |
| **M1** cheap S-tier wins | 1,392 | 908 | 47% |
| **M2** + trusted-mode (Node built-ins) | 1,923 | 1,240 | 65% |
| **M3** + arguments + nav render-on-push + system APIs + AI.ask | 2,517 | 2,476 | 85% |
| **M4** + OAuth + AI-extensions + menu-bar + intervals | 2,820 | 2,820 | 95% |

~141 extensions remain blocked only by unmapped third-party causes (native deps, exotic packages).

---

## M1 — cheap wins (mostly hours, no host changes) → ~47% run, ~31% fully supported

The highest leverage-per-effort tier. Almost all of this is JS in `packages/`.

1. **Legacy v1 API alias shims** (`packages/compat-raycast/src/index.ts`) — re-export
   old flat names to the modern namespaced APIs that already exist:
   `ToastStyle→Toast.Style`, `OpenInBrowserAction→Action.OpenInBrowser`,
   `getLocalStorageItem→LocalStorage.getItem`, `copyTextToClipboard→Clipboard.copy`,
   `ImageMask→Image.Mask`, etc. ~30 lines fixes ~105 extensions. → `06-manifest-and-api-shape.md`
2. **Load-stubs for absent interop exports** (`launchCommand`, `updateCommandMetadata`,
   `createDeeplink`, `BrowserExtension`, `getSelectedFinderItems`) so imports stop
   crashing module load (follow the existing `unsupported(...)` pattern). → `06`, `04`
3. **Pure-JS `@raycast/utils` helpers** (`packages/utils`): `getFavicon`, `getAvatarIcon`,
   `getProgressIcon`, `MutatePromise` (type), `useLocalStorage`, `useFrecencySorting`,
   `withCache`. No host work. → `03-utils-hooks.md`
4. **Wire the simple RPC stubs** (`packages/api` + one Swift switch case each, copying the
   `localStorage` template): `confirmAlert` (650 degraded→ok), `Cache` write-through (258),
   `captureException`, `openExtensionPreferences`/`openCommandPreferences`. → `02-core-runtime-stubs.md`

## M2 — trusted mode for Node built-ins → ~65% run

The single biggest unlock (~1,031 extensions). The engine already exists
(`trustedExtensions`, `setTrusted`, `INVOKE_TRUSTED=1` at `child.ts:54`); this is mostly a
**consent UX** decision, not new runtime. Follow with an RPC-bridged virtual-fs for the
~442 fs-only readers if you want them sandboxed. → `01-sandbox-node-builtins.md`

## M3 — the functional core → ~85% run, ~84% fully supported

- **`useNavigation` render-on-push** (`runtime/reconciler`, `child.ts`, `schema`, host):
  the hardest item (L) but flips ~815 extensions from degraded→working and is what makes
  multi-view extensions actually usable. → `02`
- **Command `arguments[]`** plumbing (`run.ts` + host input UI + `INVOKE_ARGUMENTS` env): 481. → `06`
- **System/selection APIs** (new RPC methods + Swift handlers; mind TCC/Accessibility, needs the
  stable signing identity per the `build-app-and-signing` note): 582. → `04`
- **`AI.ask` + `useAI`** — host already ships `AIService.swift` (Anthropic client), so this is
  RPC wiring. Default to latest Claude (Opus 4.8 agentic / Sonnet 4.6 inline). → `05-ai-and-oauth.md`

## M4 — the long tail → ~95% run

OAuth (`PKCEClient` + utils wrappers, Keychain-backed), AI-extension agent loop (`tools[]` + `@`-mode),
`menu-bar` execution (component exists; needs child branch + `NSStatusItem` host rendering),
background `interval` scheduler, `useStreamJSON`. → `05`, `06`

---

## Per-category deep-dives

| Doc | Covers |
|---|---|
| `remediation/01-sandbox-node-builtins.md` | Node built-ins, sandbox model, trusted mode, virtual fs/net, `useExec` |
| `remediation/02-core-runtime-stubs.md` | `useNavigation`, `confirmAlert`, `Cache`, prefs openers, `captureException` |
| `remediation/03-utils-hooks.md` | Missing `@raycast/utils` helpers/hooks |
| `remediation/04-selection-application-apis.md` | `getSelectedText`, `getApplications`, Finder, `trash`, default-app |
| `remediation/05-ai-and-oauth.md` | `AI.ask`/AI-extensions and the full OAuth stack |
| `remediation/06-manifest-and-api-shape.md` | Command modes, arguments, intervals, interop, legacy aliases |
