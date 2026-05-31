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
| Auto-hide on blur | ✅ | palette closes when it loses focus (like Raycast) |
| Settings window (SwiftUI, tabbed) | ✅ | Native NSTabViewController(.toolbar) icon tabs. General / Commands / Clipboard / Advanced / About; ⌘, or "Open Settings" |
| Commands settings: grouped by extension + per-command alias/hotkey | ✅ | Raycast-style: collapsible extension groups, columns Name·Type·Alias·Hotkey·Enabled; functional aliases (surface in root) + recordable global hotkeys per command |
| Themes / semantic color tokens | ⬜ | single look for now |
| Navigation stack (push/pop) | ✅ | declarative `Action.Push` → renders the (snapshotted) target surface on a nav stack; Esc pops. Programmatic `useNavigation().push()` is a follow-up |

## Root search (PLAN §4.3, §4.7)
| Item | Status | Notes |
|---|---|---|
| Native **Applications** index + fuzzy launch | ✅ | `AppIndexService` |
| **Command registry** (built-in commands) | 🟡 | 28 commands grouped into 10 extensions (Window Management/System/Navigation/Clipboard/Emoji/Screenshots/Snippets/Quicklinks/Calculator/Invoke); always-listed + scrollable root |
| **Frecency ranking** + Suggestions default | ✅ | `Frecency`, persisted |
| **Composed sections** (apps + commands + calc card, one tree) | ✅ | |
| Aliases / hotkeys per command | ✅ | per-command alias (typed in root) + recordable global hotkey, set in Settings → Commands; persisted |
| Fallback commands | ⬜ | |
| Favorites/Pins + manual ranking overrides | ⬜ | |

## Extension platform & SDK (PLAN §5)
| Item | Status | Notes |
|---|---|---|
| `@invoke/api` components (List/Grid/Detail/Form/ActionPanel) | ✅ | **all render natively** (Track 1.3): List · markdown **Detail** + metadata sidebar · thumbnail **Grid** · **Form** (textfield/textarea/checkbox + value-collecting submit via `Action.SubmitForm`). +`open()`, `LocalStorage`. Verified via `examples/ui-gallery`. (Navigation push/pop still ⬜) |
| `@invoke/utils` hooks | 🟡 | useFetch/usePromise/useCachedState |
| `@raycast/api` compat shim | 🟡 | `@raycast/api` + `@raycast/utils` shims; real extensions run end-to-end. +stub exports (Cache/AI/OAuth/getSelectedText/useNavigation/…) so importing them doesn't fail the load — they throw only if used. Surface still partial |
| Host capabilities (allowlisted RPC) | ✅ | **fulfilled natively in Swift** (open=NSWorkspace · clipboard=NSPasteboard+⌘V · toast/hud · window.close · localStorage=UserDefaults · preferences) and in Node (dev runner). Allowlist enforced host-side both places. Red-team gated |
| **Run extensions in the macOS app** | ✅ | extensions in `examples/*` are discovered (manifest), surfaced in root as an "Extensions" group, and launched as a `.extension` palette mode — their `List` renders, search routes to the child, actions (onAction / OpenInBrowser / Copy) fire. Verified live with Hacker News |
| `invoke` CLI (dev / import) | 🟡 | `npm run dev:ext <dir>` runs an extension; **`npm run import:ext <src>` imports one** — compatibility scan (flags `@raycast/api` symbols we lack as fatal + sandbox-denied builtins), copies into `imported/<name>/` with a JSX-pragma codemod, discovered by the app. (Go CLI/build/publish still stubs) |
| In-app store + registry | ⬜ | |

## First-party features (PLAN §2)
| Item | Status | Notes |
|---|---|---|
| **Calculator** (math · units · live currency) | ✅ | bundled extension, 55 engine tests |
| Applications launcher | ✅ | see Root search |
| Clipboard history | ✅ | text/link/file/image; master–detail view + metadata; ⌘⇧V; type filter; paste-to-app (⌘V, needs Accessibility). In-memory (encryption pending §3.4) |
| Window management (maximize/halves) | ✅ | AX move/resize: maximize, halves, quarters, center; root commands + ⌃⌥←/→/↑ hotkeys (needs Accessibility) |
| Search Screenshots | ✅ | browse screenshot folder, preview + metadata, paste/copy (grid layout is a follow-up) |
| Snippets / text expansion | ✅ | create/edit/delete in Settings → Snippets; "Search Snippets" mode (master–detail) + keyword chip; paste-to-app on Enter. Adversarially reviewed. (Global keyword auto-expansion deferred — needs system-wide keystroke monitoring) |
| Quicklinks | ✅ | create/edit/delete in Settings → Quicklinks; "Search Quicklinks" mode; opens URL on Enter; `{query}` placeholder → input sub-mode then opens substituted URL (strict query encoding; scheme decided from template; http/bare/mailto/tel/sms). Adversarially reviewed |
| Emoji & symbols picker | ✅ | curated set, search, recents (frecency), paste-on-Enter |
| System commands | 🟡 | folders, sleep, volume, mute, quit-frontmost (more to add) |
| Calendar / My Schedule | ⬜ | |
| AI in root + AI Commands ("improve writing") | ✅ | `AIService` (Anthropic; key from `ANTHROPIC_API_KEY`/Keychain, never persisted). Commands: Improve Writing / Fix Grammar / Make Professional / Make Concise / Summarize (act on the selection, paste back; clipboard restored). "Ask AI" in root → answer in a Detail. Needs a key + Accessibility |

## AI / v2 / v3
Per PLAN §7/§8 — all ⬜ (AI Chat, MCP, Skills, gateway, store pipeline, sync, Translate, Screenshot OCR, Windows/iOS, Teams). Branded third-party integrations (1Password, Spotify, Linear, …) arrive via the **ecosystem** (compat shim + store), not built here.

## Known low-priority follow-ups (tracked, not blocking)
- **Mouse interaction**: drag-to-move + click-select + double-click-run shipped; awaiting user confirmation that scroll works under real mouse events.
- **Settings editors** (Snippets/Quicklinks): commit to the store on every keystroke (full JSON re-encode). Correct but wasteful — debounce or commit-on-blur later.
- **Snippets**: global keyword auto-expansion (type-anywhere) needs system-wide keystroke monitoring — deferred.
- **Search Screenshots**: thumbnail grid (currently master–detail).
- **Signed .app bundle** (PLAN §3.4/§8.5): so the brand icon shows in Dock/Finder and the Accessibility grant persists across rebuilds.
