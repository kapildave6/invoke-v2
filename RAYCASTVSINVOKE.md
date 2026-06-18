# Raycast vs Invoke — API Parity Gap Analysis

> **Audited 2026-06-16** against [developers.raycast.com](https://developers.raycast.com), component-by-component, against the live `@invoke/api` / `@invoke/utils` surface and the AppKit renderer.
> This is the canonical, standalone parity document. It is mirrored in `PLAN.md → Appendix A`, and `STATUS.md` tracks delivery against it.
>
> **Legend:** **✅ working** · **🟡 partial / lossy** (member is defined but the renderer ignores props, or semantics differ from Raycast) · **⬜ missing** (throws `unsupported()`, crashes as `"Element type is invalid"`, or is a silent no-op).

---

## 0. Executive summary

**The spine is in place.** Invoke renders the core Raycast component model natively: **List, Grid, Detail, Form, ActionPanel/Action, Detail.Metadata, List.Dropdown, List.Item.Detail**. Real Raycast-shaped extensions launch end-to-end through the process-per-extension runtime + mutation-mode reconciler.

**Recently landed & verified:** navigation push/pop (declarative `Action.Push` **and** programmatic `useNavigation().push/pop`), command arguments (inline search-bar chips), per-extension Trust (run unsandboxed), in-palette `confirmAlert` modal (both launch hosts), world-class search dropdown (custom popover + favicons), constant palette size/position, Form validation + value preservation, and `AI.ask` / `OAuth.PKCEClient` as real host-driven RPCs.

**What remains is two kinds of gap:**
1. **Breadth** — many SDK members are *defined* (so extensions importing them type-check and load) but the renderer doesn't honor their props, or, worse, a handful are *undefined* and crash the whole extension with `"Element type is invalid"` the moment they're used.
2. **Depth** — controlled-input semantics (`onChange` for non-text fields), pagination, and streaming (AI tokens, `useStreamJSON`) are not yet wired.

The single most user-visible risk is category (1)'s crash members — a ported extension that uses `Action.Trash` or `Form.TagPicker` takes down its entire view. Fixing those (graceful degradation) is **P0**.

---

## 1. List & Grid

| API | State | Gap / pending |
|---|---|---|
| `List` render + `searchBarPlaceholder` + `onSearchTextChange` | ✅ | search text routes to the child |
| `List.Section`, `List.Item` (title/subtitle/icon) | ✅ | |
| `List.Dropdown` / `.Item` / `.Section` (searchBarAccessory) | ✅ | world-class popover (landed) |
| `List.isLoading` | ⬜ | prop ignored — no indeterminate progress bar under the search bar |
| `List` pagination `{hasMore, onLoadMore, pageSize}` | ⬜ | not wired anywhere |
| Native fuzzy `filtering` of static items / `filtering={false}` escape hatch | 🟡 | extension list filtering deferred to the child; no built-in client-side filter |
| `selectedItemId` / `onSelectionChange` | ⬜ | selection not reported back to the extension |
| `List.EmptyView` | ⬜ | child element not rendered |
| `List.Item.accessories[]` | 🟡 | text + tag only; `icon` / `date` / `tooltip` / per-accessory `color` are lossy |
| `List.Item` `keywords` / `detail` (isShowingDetail) / `quickLook` | 🟡 | partial |
| `Grid` `columns` | ✅ | |
| `Grid` `aspectRatio` / `fit` (contain/fill) / `inset` | ⬜ | ignored |
| `Grid.Section` / `Grid.Dropdown` / `Grid.EmptyView` | 🟡 / ⬜ | sections flattened; EmptyView unrendered |

## 2. Detail, Colors & Icons

| API | State | Gap / pending |
|---|---|---|
| `Detail` CommonMark `markdown` (incl. images, clamped) | ✅ | tables / LaTeX / footnotes — ⬜ |
| `Detail.Metadata.Label` / `.Separator` | ✅ | |
| `Detail.Metadata.Link` | 🟡 | rendered as text — **not clickable** |
| `Detail.Metadata.TagList` | 🟡 | comma-joined; no per-tag color/icon chips |
| `Icon` enum | 🟡 | ~48 of 250+ members defined; ~30 SF-Symbol-mapped, the rest fall back to a default glyph |
| `Color` enum (named + `Color.Dynamic` + raw HEX/RGB/HSL) | 🟡 | defined but **never applied** as `tintColor` anywhere (icons / tags / text) |
| `Image.Mask` (Circle / RoundedRectangle) | ⬜ | masks ignored |
| `Image` fallback + dynamic `{source:{light,dark}}` | ⬜ | |

## 3. Form

| API | State | Gap / pending |
|---|---|---|
| `Form.TextField` / `TextArea` / `Checkbox` / `Dropdown` | ✅ | render + value-collecting submit |
| `Form.Description` / `Separator` | ✅ | landed |
| Validation (`FormValidation.Required`) + error rendering | 🟡 | only `Required`; no custom / async validators |
| `Form.PasswordField` | 🟡 | aliases a plain text field (not masked) |
| `Form.DatePicker` | 🟡 | aliases a plain text field (no native picker, no `Date` value) |
| `Form.TagPicker` / `FilePicker` / `Form.LinkAccessory` | ⬜ | **undefined → crash** (`"Element type is invalid"`) when used |
| `onChange` | 🟡 | fires for text fields only — **not** Checkbox / Dropdown / DatePicker |
| `onBlur` / `autoFocus` / `storeValue` / `info` / `enableDrafts` | ⬜ | |
| Typed values (Checkbox→`bool`, DatePicker→`Date`, TagPicker→`array`) | 🟡 | all field values are strings |
| Imperative `focus()` / `reset()` via ref | ⬜ | |

## 4. Actions & ActionPanel

| API | State | Gap / pending |
|---|---|---|
| `Action` (onAction), `CopyToClipboard`, `Paste`, `OpenInBrowser`, `Open`, `SubmitForm`, `Push` | ✅ | the 7 wired actions |
| `Action.OpenWith` / `Trash` / `ShowInFinder` / `ToggleQuickLook` / `CreateQuicklink` / `CreateSnippet` / `PickDate` | ⬜ | **undefined → crash** (`"Element type is invalid"`) when an extension uses them |
| `ActionPanel.Submenu` | 🟡 | flattened — no nested popover, no lazy `onOpen` |
| `ActionPanel.Section` | 🟡 | flattened — section titles dropped |
| `Action.shortcut` (custom) | 🟡 | ignored; only first=Enter / second=⌘Enter assigned |
| `Action.style` (destructive) | ⬜ | no red emphasis |
| `Action.autoFocus` | ⬜ | |

## 5. Navigation & Menu Bar

| API | State | Gap / pending |
|---|---|---|
| `Action.Push` + `useNavigation().push/pop` + Esc-pops | ✅ | render-on-push frames (landed) |
| `navigationTitle` breadcrumb | ✅ | |
| `menu-bar` command mode | ⬜ | rejected at discovery; no `NSStatusItem` |
| `MenuBarExtra` + `.Item` | ⬜ | unrendered |
| `MenuBarExtra.Submenu` / `.Section` / `.Separator` | ⬜ | undefined → crash |

## 6. Feedback

| API | State | Gap / pending |
|---|---|---|
| `showToast` (Success/Failure/Animated; object + positional overload; updatable handle) | ✅ | |
| `Toast.primaryAction` / `secondaryAction` (hover buttons) | ⬜ | not surfaced |
| Toast visual style (icon / color per style) | 🟡 | minimal differentiation |
| `showHUD` | ✅ | `options` ignored (🟡) |
| `confirmAlert` (in-palette modal, `primaryAction.onAction`, destructive, key capture) | ✅ | landed this iteration, both hosts |
| `showFailureToast` (utils) | ✅ | |

## 7. Storage, Preferences & Environment

| API | State | Gap / pending |
|---|---|---|
| `LocalStorage` get/set/remove/allItems/clear (getItem→`undefined` parity) | ✅ | |
| `Cache` get/set/has/remove/clear | ✅ | `subscribe` — ⬜ no-op; `capacity` / LRU eviction — ⬜ |
| `getPreferenceValues` + types textfield/password/checkbox/dropdown/appPicker | ✅ | `file` / `directory` pref types — ⬜ |
| Per-command preference override + required-before-run | ✅ | |
| `environment.supportPath` / `assetsPath` / `commandName` / `commandMode` | ✅ | |
| `environment.extensionName` / `ownerOrAuthorName` | 🟡 | always `""` |
| `environment.appearance` / `textSize` / `launchType` / `isDevelopment` / `raycastVersion` | 🟡 | hardcoded |
| `environment.canAccess(api)` | 🟡 | hardcoded `false` |
| `openExtensionPreferences` / `openCommandPreferences` | 🟡 | open Settings but don't scope to the ext / command |
| `updateCommandMetadata` | ⬜ | no host handler (silent no-op) |
| `launchCommand` (cross-command launch) | ⬜ | `unsupported()` throws |

## 8. Clipboard, Keyboard, Window & Applications

| API | State | Gap / pending |
|---|---|---|
| `Clipboard.copy` / `paste` / `readText` | ✅ | `concealed` / `transient` flags dropped (🟡); `html` / `file` copy — ⬜ |
| `Clipboard.read({offset})` → `{text, html, file}` / `Clipboard.clear` | ⬜ | absent |
| `getApplications` / `getDefaultApplication` / `getFrontmostApplication` | ✅ | real |
| `getSelectedText` / `getSelectedFinderItems` | ✅ | |
| `closeMainWindow` | ✅ | `clearRootSearch` / `popToRootType` decorative (🟡) |
| `clearSearchBar` | ⬜ | no-op |
| `popToRoot` | 🟡 | just closes the palette (doesn't pop nav to root and stay open) |
| Window Management API (`getActiveWindow` / `WindowManagement`) | ⬜ | **entirely absent** from the SDK (native window-mgmt commands exist as built-ins, but there's no extension API) |

## 9. `@raycast/utils` hooks

| API | State | Gap / pending |
|---|---|---|
| `usePromise` / `useCachedState` / `useCachedPromise` / `useFetch` / `useExec` / `useSQL` / `useForm` / `useLocalStorage` / `useFrecencySorting` / `useAI` | ✅ | present and used by real extensions |
| `mutate` / `MutatePromise` (`optimisticUpdate` / `rollbackOnError`) | ⬜ | **type only — no runtime**; data hooks don't return a working `mutate` |
| Pagination (function-form source in `useFetch` / `useCachedPromise`) | ⬜ | absent everywhere |
| `useStreamJSON` | ⬜ | |
| `useAI` streaming (`.on('data')` token stream) | 🟡 | resolves once; no progressive tokens |
| `getFavicon` / `getAvatarIcon` / `getProgressIcon` | ✅ | |
| `createDeeplink` / `withCache` / `OAuthService` / `withAccessToken` / `getAccessToken` | ✅ | present |
| `runPowerShellScript` | ⬜ | throws on macOS (by design) |

## 10. OAuth, AI, Browser Extension & Tools

| API | State | Gap / pending |
|---|---|---|
| `AI.ask(prompt, {model, creativity, system})` | ✅ | real host RPC (Anthropic) |
| `AI.ask` streaming / Promise-as-EventEmitter | ⬜ | single resolve only |
| `AI.Model.*` | 🟡 | Proxy returns the key string; no real model metadata |
| `OAuth.PKCEClient` (authorizationRequest / authorize / set·get·removeTokens) | ✅ | host-driven, tokens in Keychain |
| OAuth prebuilt provider configs (GitHub / Slack / Google / Linear / Zoom) | ⬜ | extensions must hand-roll endpoints |
| `BrowserExtension.getContent` / `getTabs` | ⬜ | `unsupported()` throws |
| AI Extensions / Tools (`src/tools/*.ts`) | ⬜ | manifest `tools[]` parsed for display only — not invoked |
| MCP client / Skills | ⬜ | v2 |

## 11. Manifest & command modes

| API | State | Gap / pending |
|---|---|---|
| Command modes `view` / `no-view` | ✅ | only these two accepted at discovery |
| Command mode `menu-bar` | ⬜ | rejected at discovery |
| Arguments `text` / `password` / `dropdown` | ✅ | inline search-bar chips |
| Background refresh (`interval`) | ⬜ | |
| Fallback commands | ⬜ | |
| `disabledByDefault` | ⬜ | |
| Preferences `textfield` / `password` / `checkbox` / `dropdown` / `appPicker` (+`required`) | ✅ | `file` / `directory` — ⬜; per-platform `default` — 🟡 |
| `tools[]` / `ai{}` objects | 🟡 | parsed for the Commands detail panel; not executed |

---

## 12. Prioritized backlog

### P0 — crash-prevention & correctness (do first)
These make real ported extensions fail *today*.
1. **Graceful-degrade every undefined component** so a missing member renders a placeholder instead of crashing the whole extension with `"Element type is invalid"`:
   - Actions: `Action.OpenWith`, `Trash`, `ShowInFinder`, `ToggleQuickLook`, `CreateQuicklink`, `CreateSnippet`, `PickDate`
   - Form: `TagPicker`, `FilePicker`, `Form.LinkAccessory`
   - Menu bar: `MenuBarExtra.*`
2. Render `List.EmptyView` / `Grid.EmptyView`.
3. Fire `onChange` for **Checkbox / Dropdown / DatePicker** (controlled-input parity).
4. Honor `Action.style` (destructive red) and custom `Action.shortcut`.

### P1 — depth (the props extensions most rely on)
- `List.isLoading` progress bar
- List / Grid **pagination** (`hasMore` / `onLoadMore`)
- Clickable `Detail.Metadata.Link` + colored `TagList`
- `Form.PasswordField` masking + native `Form.DatePicker`
- `Toast` primary / secondary actions
- Working `mutate` / `MutatePromise` (optimistic updates)
- `Clipboard.read` / `clear`
- Un-flatten `ActionPanel.Section` / `Submenu`
- Apply `Color` / `Icon` `tintColor`

### P2 — breadth / v2
- `menu-bar` command mode + `NSStatusItem` + `MenuBarExtra`
- AI streaming + AI Extensions / Tools / MCP / Skills
- Window Management API
- Full `Icon` / `Color` enum coverage + `Image.Mask`
- `useStreamJSON`
- Background `interval` refresh
- Fallback commands
- Real `environment` fields (`appearance` / `textSize` / `launchType` / `extensionName` / `canAccess`)
- OAuth provider presets

---

_Related: `PLAN.md` (Appendix A mirrors this), `STATUS.md` (delivery checklist). Audited against developers.raycast.com on 2026-06-16._
