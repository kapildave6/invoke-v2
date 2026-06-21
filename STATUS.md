# Invoke — Build Status

> Living checklist of what's **implemented** vs **pending**, tracked against `PLAN.md`.
> Updated as features land. Legend: ✅ done · 🟡 partial · ⬜ not started.

_Last updated: 2026-06-21_

## How we track progress
- **This file (`STATUS.md`)** — the source of truth for done-vs-pending, mapped to PLAN.md sections.
- **Git history** — every increment is a focused, reviewed commit on `main`.
- **PLAN.md** — the spec/roadmap (phases & feature inventory). STATUS.md tracks delivery against it.
- **PLAN.md → Appendix A** + **`RAYCASTVSINVOKE.md`** — the canonical, component-by-component Raycast-API parity gap analysis (audited 2026-06-16). The "Extension platform & SDK" pending rows below are a condensed pointer to it.

---

## Phase 0 — Spine & isolation (PLAN §4, §8.2)
| Item | Status | Notes |
|---|---|---|
| Mutation-mode `react-reconciler` host-config | ✅ | `runtime/reconciler`; render-on-push frames (container ops target ROOT) |
| Process-per-extension runtime + framed fd3 JSON-RPC | ✅ | `runtime/node-host` |
| Shared typed wire schema (TS + Swift mirror) | ✅ | `schema`, `InvokeIPC` |
| **Extension isolation** (built-ins denied 3 ways + RPC allowlist) | ✅ | `sandbox.ts`, red-team gate `npm run redteam` |
| **Per-extension Trust** (run unsandboxed, opt-in) | ✅ | Settings checkbox → `INVOKE_TRUSTED=1` / `--trusted`; recomputes compatibility + relaunches on import; dotted-id key collision fixed (`sanitizeKeySegment` + `extGrantKey`) |
| Native host ↔ Node runtime bridge (live extension → AppKit) | ✅ | `ExtensionHost` over socketpair; sync `onCapability` + deferred `onCapabilityAsync` (for `confirmAlert`) |
| Red-team CI security gate | ✅ | 8 probes + allowlist, adversarially reviewed |
| Warm pool / crash-restart / backpressure | ⬜ | Phase-0 perf hardening still open |
| Perf gates (summon <150ms / first-paint <300ms) | 🟡 | Harness landed (`npm run bench`). Baseline (2026-06-02): mount 30ms p95 / update 23ms p95 / **first-paint 150ms p95** — green. **Native-summon (release, n=16): p50 145ms / p95 157ms — marginally OVER budget.** Open: trim the ~103ms sync summon path; wire `npm run bench` into CI |

## Shell / UI (PLAN §4.3, §6)
| Item | Status | Notes |
|---|---|---|
| Translucent NSPanel + vibrancy, compact sizing | ✅ | content-sized window |
| **Constant palette size + position** | ✅ | hard-fixed `resizeToFit` (targetH=maxH) + `repositionToActiveScreen` at a fixed height — no per-surface jitter |
| Keyboard nav (arrows / Enter / ⌘Enter / Esc) | ✅ | via field-editor + key monitor |
| ⌘K Action Panel + bottom action bar | ✅ | review-hardened |
| Edit-menu shortcuts (⌘A/C/V/X/Z) + ⌘Q | ✅ | |
| **In-palette `confirmAlert` modal** | ✅ | dimmed-backdrop centered card on both launch hosts; Return→confirm / Esc→cancel (key monitor swallows keys while shown); destructive primary in red; fires `primaryAction.onAction` |
| **World-class search dropdown** | ✅ | custom popover (not `NSPopUpButton`): search filter + favicon rows + accent selection; tracks uncontrolled selection (`extDropdownValue`) |
| Action-feedback toasts (Copy…) + extension `showToast` | ✅ | positional + object overloads; updatable handle |
| Polished rows (icon · title · subtitle · type · selection) | ✅ | Raycast-style row parity |
| Result **card** (calculator conversion) | ✅ | |
| **Detail markdown images** (clamped, crash-proof) | ✅ | width ≤660 / height ≤340, `mdScroll.heightAnchor==h.heightAnchor` to clip; rendering hardened against malformed trees |
| Global ⌥Space summon hotkey | ✅ | Carbon (no Accessibility grant) |
| Auto-hide on blur | ✅ | palette closes when it loses focus (like Raycast) |
| Settings window (SwiftUI, tabbed) | ✅ | General / Commands / Clipboard / Snippets / Quicklinks / Advanced / About; ⌘, or "Open Settings" |
| Commands settings: grouped by extension + per-command alias/hotkey | ✅ | collapsible groups; functional aliases + recordable global hotkeys |
| Themes / semantic color tokens | ⬜ | single look for now |
| Navigation stack (push/pop) | ✅ | **declarative `Action.Push` + programmatic `useNavigation().push/pop`** via render-on-push frames + `__setNavController`; Esc pops; per-view `navigationTitle` breadcrumb |

## Root search (PLAN §4.3, §4.7)
| Item | Status | Notes |
|---|---|---|
| Native **Applications** index + fuzzy launch | ✅ | `AppIndexService` |
| **Command registry** (built-in commands) | 🟡 | ~28 commands grouped into ~10 extensions; always-listed + scrollable root |
| **Frecency ranking** + Suggestions default | ✅ | `Frecency`, persisted |
| **Composed sections** (apps + commands + calc card, one tree) | ✅ | |
| **Command arguments** (inline search-bar chips) | ✅ | `text` / `password` / `dropdown`; chips render after the query; `presentArgumentsForm` fallback for no-view; required-before-run |
| Aliases / hotkeys per command | ✅ | per-command alias + recordable global hotkey, set in Settings → Commands; persisted |
| Fallback commands | ⬜ | |
| Favorites/Pins + manual ranking overrides | ⬜ | |

## Extension platform & SDK (PLAN §5, Appendix A)
> Component spine renders natively; pending work is **breadth** (SDK members the renderer ignores) + **depth** (controlled inputs, pagination, streaming). Full table: **PLAN.md Appendix A** / **`RAYCASTVSINVOKE.md`**.

| Item | Status | Notes |
|---|---|---|
| `@invoke/api` components (List/Grid/Detail/Form/ActionPanel) | 🟡 | all five render natively; List.Dropdown(+Item/Section), Detail.Metadata, Form.Description/Separator, validation+value-preservation landed; **List.Item accessories (colored text/tags, icon, relative date, tooltip, combined entries) + `isLoading` sweep bar (List/Grid/Detail) landed** (`RaycastColor`/`LoadingBar`, 2026-06-21). **Pending:** EmptyView render; List/Grid pagination; clickable Metadata.Link + colored TagList; PasswordField mask + native DatePicker; un-flatten ActionPanel.Section/Submenu |
| **Crash-safety for undefined members** | ⬜ | **P0:** `Action.OpenWith/Trash/ShowInFinder/ToggleQuickLook/CreateQuicklink/CreateSnippet/PickDate`, `Form.TagPicker/FilePicker/LinkAccessory`, `MenuBarExtra.*` are undefined → "Element type is invalid" crash when used. Degrade gracefully first |
| `@invoke/utils` hooks | 🟡 | usePromise/useFetch(options)/useCachedState/useCachedPromise/useExec/useSQL/useForm/useLocalStorage/useFrecencySorting/useAI present. **Pending:** working `mutate`/`MutatePromise` (type-only today), pagination, `useStreamJSON`, AI token streaming |
| `@raycast/api` / `@raycast/utils` compat shim | 🟡 | real extensions run end-to-end; surface partial (see Appendix A). Missing members `unsupported()`-throw or crash |
| Host capabilities (allowlisted RPC) | ✅ | clipboard/toast/hud/window.close/localStorage/cache/runAppleScript/executeSQL/**confirmAlert**/preferences/app.list/frontmost/default/selection/finder fulfilled natively; allowlist enforced; red-team gated |
| **AI.ask / OAuth.PKCEClient** | ✅ | real host-driven RPCs (Anthropic / Keychain tokens). **Pending:** AI streaming, OAuth provider presets |
| BrowserExtension / launchCommand / Window Management API / AI Tools | ⬜ | `unsupported()` / absent (see Appendix A §A.8, §A.10) |
| **Run extensions in the macOS app** | ✅ | discovered (manifest), surfaced as an "Extensions" group, launched as `.extension` palette mode; search routes to child; actions fire. Verified live (Hacker News, etc.) |
| `invoke` CLI (dev / import) | 🟡 | `npm run dev:ext` / `npm run import:ext` (compatibility scan + codemod + `--trusted`). Go CLI/build/publish still stubs |
| In-app store + registry | ⬜ | |

## First-party features (PLAN §2)
| Item | Status | Notes |
|---|---|---|
| **Calculator** (math · units · live currency) | ✅ | bundled extension, 55 engine tests |
| Applications launcher | ✅ | see Root search |
| Clipboard history | ✅ | text/link/file/image; master–detail + metadata; ⌘⇧V; type filter; paste-to-app. In-memory (encryption pending §3.4) |
| Window management (maximize/halves) | ✅ | AX move/resize; root commands + ⌃⌥←/→/↑ hotkeys (needs Accessibility) |
| Search Screenshots | ✅ | browse + preview + metadata, paste/copy |
| Snippets / text expansion | ✅ | create/edit/delete in Settings; "Search Snippets" mode; paste-to-app. (Global keyword auto-expansion deferred) |
| Quicklinks | ✅ | create/edit/delete; "Search Quicklinks" mode; `{query}` placeholder sub-mode; strict query encoding |
| Emoji & symbols picker | ✅ | curated set, search, recents, paste-on-Enter |
| System commands | 🟡 | folders, sleep, volume, mute, quit-frontmost (more to add) |
| Calendar / My Schedule | ⬜ | |
| AI in root + AI Commands ("improve writing") | ✅ | `AIService` (Anthropic; key from env/Keychain, never persisted). Improve/Fix Grammar/Professional/Concise/Summarize + "Ask AI" → Detail. Needs key + Accessibility |

## AI / v2 / v3
Per PLAN §7/§8 — all ⬜ (AI Chat, AI Extensions/Tools, MCP, Skills, gateway, store pipeline, sync, Translate, Screenshot OCR, Windows/iOS, Teams). Branded third-party integrations arrive via the **ecosystem** (compat shim + store), not built here.

## Pending Implementation — Raycast parity (condensed; full detail in PLAN Appendix A / RAYCASTVSINVOKE.md)
- **P0 — crash-prevention & correctness:** graceful-degrade every undefined component (the `Action.*`, `Form.*`, `MenuBarExtra.*` members above); render `List/Grid.EmptyView`; fire `onChange` for Checkbox/Dropdown/DatePicker; honor `Action.style` (destructive) + custom `Action.shortcut`.
- **P1 — depth:** List/Grid pagination; clickable `Detail.Metadata.Link` + colored `TagList`; `PasswordField` masking + native `DatePicker`; `Toast` primary/secondary actions; `Clipboard.read`/`clear`; un-flatten `ActionPanel.Section`/`Submenu`. _(Done: `List.isLoading` bar; List.Item accessories incl. `Color`/`Icon` tint; `mutate`/`MutatePromise`.)_
- **P2 — breadth / v2:** `menu-bar` mode + `NSStatusItem` + `MenuBarExtra`; AI streaming + Tools/MCP/Skills; Window Management API; full `Icon`/`Color` coverage + `Image.Mask`; `useStreamJSON`; background `interval` refresh; fallback commands; real `environment` fields; OAuth provider presets.

## Known low-priority follow-ups (tracked, not blocking)
- **Mouse interaction**: drag-to-move + click-select + double-click-run shipped; scroll under real mouse events awaiting confirmation.
- **Settings editors** (Snippets/Quicklinks): commit-on-every-keystroke (full JSON re-encode) — debounce/commit-on-blur later.
- **Snippets**: global keyword auto-expansion (type-anywhere) needs system-wide keystroke monitoring — deferred.
- **Search Screenshots**: thumbnail grid (currently master–detail).
- **Signed .app bundle** (PLAN §3.4/§8.5): `scripts/build-app.sh` produces a signed `Invoke.app`; set `INVOKE_SIGN_IDENTITY` for stable TCC/Keychain across rebuilds.
