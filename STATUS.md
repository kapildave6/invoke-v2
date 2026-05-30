# Invoke — Build Status

> Living checklist of what's **implemented** vs **pending**, tracked against `PLAN.md`.
> Updated as features land. Legend: ✅ done · 🟡 partial · ⬜ not started.

_Last updated: 2026-05-31_

## How we track progress
- **This file (`STATUS.md`)** — the source of truth for done-vs-pending, mapped to PLAN.md sections.
- **Git history** — every increment is a focused, reviewed commit on `main`.
- **PLAN.md** — the spec/roadmap (phases & feature inventory). STATUS.md tracks delivery against it.

---

## Phase 0 — Spine & isolation (PLAN §4, §8.2)
| Item | Status | Notes |
|---|---|---|
| Mutation-mode `react-reconciler` host-config | ✅ | `runtime/reconciler` |
| Process-per-extension runtime + framed fd3 JSON-RPC | ✅ | `runtime/node-host` |
| Shared typed wire schema (TS + Swift mirror) | ✅ | `schema`, `InvokeIPC` |
| **Extension isolation** (built-ins denied 3 ways + RPC allowlist) | ✅ | `sandbox.ts`, red-team gate `npm run redteam` |
| Native host ↔ Node runtime bridge (live extension → AppKit) | ✅ | `ExtensionHost` over socketpair |
| Red-team CI security gate | ✅ | 8 probes + allowlist, adversarially reviewed |
| Warm pool / crash-restart / backpressure | ⬜ | Phase-0 perf hardening still open |
| Perf gates (summon <150ms / first-paint <300ms) | ⬜ | not yet measured in CI |

## Shell / UI (PLAN §4.3, §6)
| Item | Status | Notes |
|---|---|---|
| Translucent NSPanel + vibrancy, compact sizing | ✅ | content-sized window |
| Keyboard nav (arrows / Enter / ⌘Enter / Esc) | ✅ | via field-editor + key monitor |
| ⌘K Action Panel + bottom action bar | ✅ | review-hardened |
| Edit-menu shortcuts (⌘A/C/V/X/Z) + ⌘Q | ✅ | |
| Action-feedback toasts (Copy…) + extension `showToast` | ✅ | |
| Polished rows (icon · title · subtitle · type · selection) | ✅ | Raycast-style row parity |
| Result **card** (calculator conversion) | ✅ | |
| Global ⌥Space summon hotkey | ✅ | Carbon (no Accessibility grant) |
| Themes / semantic color tokens | ⬜ | single look for now |
| Navigation stack (push/pop) | ⬜ | |

## Root search (PLAN §4.3, §4.7)
| Item | Status | Notes |
|---|---|---|
| Native **Applications** index + fuzzy launch | ✅ | `AppIndexService` |
| **Command registry** (built-in commands) | 🟡 | folder/navigation commands; more to come |
| **Frecency ranking** + Suggestions default | ✅ | `Frecency`, persisted |
| **Composed sections** (apps + commands + calc card, one tree) | ✅ | |
| Aliases / hotkeys per command / fallbacks | ⬜ | |
| Favorites/Pins + manual ranking overrides | ⬜ | |

## Extension platform & SDK (PLAN §5)
| Item | Status | Notes |
|---|---|---|
| `@invoke/api` components (List/Grid/Detail/Form/ActionPanel) | 🟡 | List/Item/Section/Actions used; others stubbed |
| `@invoke/utils` hooks | 🟡 | useFetch/usePromise/useCachedState |
| `@raycast/api` compat shim | 🟡 | re-export alias only; no codemod/corpus |
| `invoke` CLI (dev/build/import/publish) | ⬜ | scaffold stubs only |
| In-app store + registry | ⬜ | |

## First-party features (PLAN §2)
| Item | Status | Notes |
|---|---|---|
| **Calculator** (math · units · live currency) | ✅ | bundled extension, 55 engine tests |
| Applications launcher | ✅ | see Root search |
| Clipboard history | ✅ | in-memory (encryption pending §3.4); ⌘⇧V opens it; search + copy-back |
| Window management (maximize/halves) | ⬜ | needs Accessibility |
| Snippets / text expansion | ⬜ | |
| Quicklinks | ⬜ | |
| Emoji & symbols picker | ⬜ | |
| System commands | 🟡 | folder-open commands only |
| Calendar / My Schedule | ⬜ | |
| AI in root + AI Commands ("improve writing") | ⬜ | |

## AI / v2 / v3
Per PLAN §7/§8 — all ⬜ (AI Chat, MCP, Skills, gateway, store pipeline, sync, Translate, Screenshot OCR, Windows/iOS, Teams). Branded third-party integrations (1Password, Spotify, Linear, …) arrive via the **ecosystem** (compat shim + store), not built here.
