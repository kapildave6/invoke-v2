# Raycast vs Invoke — API Parity Gap Analysis

> **Audited 2026-06-16** against [developers.raycast.com](https://developers.raycast.com), component-by-component, against the live `@invoke/api` / `@invoke/utils` surface and the AppKit renderer.
> **Member-level re-audit 2026-06-21** — all 29 pages under `/api-reference` swept page-by-page; nested types, enums, and props folded into the tables below (incl. the previously-absent `Keyboard` namespace).
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

The single most user-visible risk is category (1)'s crash members — a ported extension that uses `Action.Trash` or `Form.TagPicker` takes down its entire view. Fixing those (graceful degradation) is **P0**. The 2026-06-21 re-audit also surfaced one whole **namespace with zero representation — `Keyboard`** (`Keyboard.Shortcut` et al.) — now tracked in §8.

---

## 1. List & Grid

| API | State | Gap / pending |
|---|---|---|
| `List` render + `searchBarPlaceholder` + `onSearchTextChange` | ✅ | search text routes to the child |
| `List` / `Grid` controlled `searchText` + `throttle` | ⬜ | controlled search value & debounce prop not honored |
| `List` / `Grid` component-level `actions` (empty-state ActionPanel) | ⬜ | top-level `actions` prop not rendered |
| `List.Section`, `List.Item` (title/subtitle/icon) | ✅ | |
| `List.Dropdown` / `.Item` / `.Section` (searchBarAccessory) | ✅ | world-class popover (landed) |
| `List.Dropdown` / `Grid.Dropdown` controlled props (`value` / `defaultValue` / `onChange` / `storeValue` / `filtering` / `onSearchTextChange` / `isLoading` / `tooltip`) | ⬜ | selection renders, but controlled-value & behavioral props not wired |
| `List.isLoading` | ⬜ | prop ignored — no indeterminate progress bar under the search bar |
| `List` pagination `{hasMore, onLoadMore, pageSize}` | ⬜ | not wired anywhere |
| Native fuzzy `filtering` of static items / `filtering={false}` escape hatch | 🟡 | extension list filtering deferred to the child; no built-in client-side filter |
| `selectedItemId` / `onSelectionChange` | ⬜ | selection not reported back to the extension |
| `List.EmptyView` | ⬜ | child element not rendered |
| `List.Item.accessories[]` | 🟡 | text + tag only; `icon` / `date` / `tooltip` / per-accessory `color` are lossy |
| `List.Item` `keywords` / `detail` (isShowingDetail) / `quickLook` | 🟡 | partial |
| `List.Item.Detail.isLoading` (detail-pane bar, distinct from `List.isLoading`) | ⬜ | not honored |
| `Grid` `columns` | ✅ | |
| `Grid` `aspectRatio` / `fit` (contain/fill) / `inset` | ⬜ | ignored |
| `Grid.Section` / `Grid.Dropdown` / `Grid.EmptyView` | 🟡 / ⬜ | sections flattened; EmptyView unrendered |
| `Grid.Section` per-section `columns` / `aspectRatio` / `fit` / `inset` overrides | ⬜ | only top-level Grid layout props read |
| `Grid.Item.accessory` (`Grid.Item.Accessory`) | ⬜ | single grid-item accessory not rendered |
| `Grid.ItemSize` (deprecated enum) | ⬜ | undefined |

## 2. Detail, Colors & Icons

| API | State | Gap / pending |
|---|---|---|
| `Detail` CommonMark `markdown` (incl. images, clamped) | ✅ | tables / LaTeX / footnotes — ⬜ |
| `Detail` own `isLoading` (accent sweep bar) | ⬜ | Detail-pane loading prop not honored |
| `Detail.Metadata.Label` (`text` string) / `.Separator` | ✅ | |
| `Detail.Metadata.Label` colored `text:{color,value}` + `icon` | 🟡 | rendered, but `Color` not applied & label icon lossy |
| `Detail.Metadata.Link` | 🟡 | rendered as text — **not clickable** |
| `Detail.Metadata.TagList` | 🟡 | comma-joined; no per-tag color/icon chips |
| `Detail.Metadata.TagList.Item` (`text` / `icon` / `color` / `onAction`) | 🟡 | leaf tag element not individually rendered; `onAction` (clickable tag) ⬜ |
| `Icon` enum | 🟡 | ~48 of 250+ members defined; ~30 SF-Symbol-mapped, the rest fall back to a default glyph |
| `Color` enum (named + `Color.Dynamic` + raw HEX/RGB/HSL) | 🟡 | defined but **never applied** as `tintColor` anywhere (icons / tags / text) |
| `Color.Raw` (HEX/RGB/HSL string/object type) | 🟡 | accepted but never applied (see `Color` above) |
| `Image.Mask` (Circle / RoundedRectangle) | ⬜ | masks ignored |
| `Image` fallback + dynamic `{source:{light,dark}}` | ⬜ | |
| `Image.tintColor` (as `Image` prop) | ⬜ | tint never applied to icons/images |
| `Image.ImageLike` union (URL \| Asset \| `Icon` \| `FileIcon` \| `Image`) | 🟡 | type accepted; `FileIcon` / masks / tint lossy |
| `FileIcon` (`{fileIcon}`) — Finder file/folder icon | ⬜ | not resolved to a system icon |

## 3. Form

| API | State | Gap / pending |
|---|---|---|
| `Form.TextField` / `TextArea` / `Checkbox` / `Dropdown` | ✅ | render + value-collecting submit |
| `Form.Description` (`text` / `title`) / `Separator` | ✅ | landed |
| `Form` container props (`navigationTitle` / `isLoading` / `searchBarAccessory`) | ⬜ | form-level nav title, loading bar & accessory slot not honored |
| `Form.Dropdown.Item` / `Form.Dropdown.Section` | 🟡 | dropdown renders, but item `keywords` & section `title` lossy |
| `Form.Dropdown` searchable props (`onSearchTextChange` / `filtering` / `throttle` / `isLoading`) | ⬜ | dropdown not searchable/async |
| `Form.TextArea` `enableMarkdown` | ⬜ | markdown toolbar/preview not rendered |
| Validation (`FormValidation.Required`) + error rendering | 🟡 | only `Required`; no custom / async validators |
| `Form.PasswordField` | 🟡 | aliases a plain text field (not masked) |
| `Form.DatePicker` (+ `min` / `max`) | 🟡 | aliases a plain text field (no native picker, no `Date` value, bounds ignored) |
| `Form.DatePicker.Type` enum (`Date` / `DateTime`) + `Form.DatePicker.isFullDay()` | ⬜ | granularity enum & helper absent |
| `Form.TagPicker` / `Form.TagPicker.Item` | ⬜ | **undefined → crash** (`"Element type is invalid"`) when used |
| `Form.FilePicker` (+ `allowMultipleSelection` / `canChooseFiles` / `canChooseDirectories` / `showHiddenFiles`) | ⬜ | **undefined → crash**; none of its options exist |
| `Form.LinkAccessory` (`target` / `text`) | ⬜ | **undefined → crash**; note: it's a `searchBarAccessory`, **not** a child field |
| `onChange` | 🟡 | fires for text fields only — **not** Checkbox / Dropdown / DatePicker |
| `onBlur` / `onFocus` / `autoFocus` / `storeValue` / `info` / `enableDrafts` | ⬜ | |
| `Form.Event` / `Form.Event.Type` (`focus`/`blur`) / `Form.Values` types | ⬜ | event payload & values type not modeled |
| Typed values (Checkbox→`bool`, DatePicker→`Date`, TagPicker→`array`) | 🟡 | all field values are strings |
| Imperative `focus()` / `reset()` via ref | ⬜ | per-item refs (`useRef<Form.TextField>`) — must be exposed on all controlled item types |

## 4. Actions & ActionPanel

| API | State | Gap / pending |
|---|---|---|
| `Action` (onAction), `CopyToClipboard`, `Paste`, `OpenInBrowser`, `Open`, `SubmitForm`, `Push` | ✅ | the 7 wired actions |
| `Action.OpenWith` / `Trash` / `ShowInFinder` / `ToggleQuickLook` / `CreateQuicklink` / `CreateSnippet` / `PickDate` | ⬜ | **undefined → crash** (`"Element type is invalid"`) when an extension uses them |
| `ActionPanel.Submenu` | 🟡 | flattened — no nested popover, no lazy `onOpen` |
| `ActionPanel.Submenu` search props (`filtering` / `keepSectionOrder` / `throttle` / `onSearchTextChange` / `isLoading`) | ⬜ | submenu not searchable/filterable |
| `ActionPanel.Section` | 🟡 | flattened — section titles dropped |
| `Action.shortcut` (custom) | 🟡 | ignored; only first=Enter / second=⌘Enter assigned |
| `Action.style` (destructive) | ⬜ | no red emphasis |
| `Action.Style` enum (`Regular` / `Destructive`) | ⬜ | enum type absent (only the lowercase prop is noted) |
| `Action.PickDate.Type` enum (`Date` / `DateTime`) + `Action.PickDate.isFullDay()` | ⬜ | nested enum & helper absent |
| `Keyboard.Shortcut` / `Keyboard.Shortcut.Common` (type behind `Action.shortcut`) | ⬜ | see §8 — `Keyboard` namespace absent |
| `Action.autoFocus` | ⬜ | |

## 5. Navigation & Menu Bar

| API | State | Gap / pending |
|---|---|---|
| `Action.Push` + `useNavigation().push/pop` + Esc-pops | ✅ | render-on-push frames (landed) |
| `Navigation` (type returned by `useNavigation`) | 🟡 | push/pop work; type not exported/modeled |
| `navigationTitle` breadcrumb | ✅ | |
| `menu-bar` command mode | ⬜ | rejected at discovery; no `NSStatusItem` |
| `MenuBarExtra` + `.Item` | ⬜ | unrendered |
| `MenuBarExtra.Submenu` / `.Section` / `.Separator` | ⬜ | undefined → crash |
| `MenuBarExtra.Item` `alternate` / `subtitle` / `shortcut` | ⬜ | item modifiers absent |
| `MenuBarExtra.ActionEvent` (`left-click` / `right-click`) | ⬜ | onAction event type absent |

## 6. Feedback

| API | State | Gap / pending |
|---|---|---|
| `showToast` (Success/Failure/Animated; object + positional overload; updatable handle) | ✅ | |
| `Toast.primaryAction` / `secondaryAction` (`Toast.ActionOptions`) | ⬜ | not surfaced |
| `Toast.Style` enum (`Success` / `Failure` / `Animated`) | 🟡 | states used by `showToast`, but enum not tracked; minimal visual differentiation |
| Toast visual style (icon / color per style) | 🟡 | minimal differentiation |
| `showHUD` | 🟡 | renders, but `options` (`clearRootSearch` / `popToRootType`) are decorative no-ops |
| `confirmAlert` (in-palette modal, `primaryAction.onAction`, destructive, key capture) | ✅ | landed this iteration, both hosts |
| `Alert.Options` `icon` / `dismissAction` / `rememberUserChoice` | ⬜ | custom icon, secondary dismiss action & "don't ask again" not honored |
| `Alert.ActionStyle` enum (`Default` / `Destructive` / `Cancel`) + `Alert.ActionOptions` | 🟡 | destructive handled ad-hoc; enum & action-options type not modeled |
| `showFailureToast` (utils) | ✅ | |

## 7. Storage, Preferences & Environment

| API | State | Gap / pending |
|---|---|---|
| `LocalStorage` get/set/remove/allItems/clear (getItem→`undefined` parity) | ✅ | |
| `LocalStorage.Value` / `LocalStorage.Values` types | 🟡 | functions work; named types not exported |
| `Cache` get/set/has/remove/clear | ✅ | `subscribe` — ⬜ no-op; `capacity` / LRU eviction — ⬜ |
| `Cache` constructor `{namespace, capacity}` / `isEmpty` | 🟡 | namespace isolation & `isEmpty` not honored |
| `Cache.Subscriber` / `Cache.Subscription` / `Cache.Options` types | ⬜ | not modeled |
| `getPreferenceValues` + types textfield/password/checkbox/dropdown/appPicker | ✅ | `file` / `directory` pref types — ⬜ |
| `Preferences` / `PreferenceValues` types | 🟡 | `getPreferenceValues` works; named types not exported |
| Per-command preference override + required-before-run | ✅ | |
| `environment.supportPath` / `assetsPath` / `commandName` / `commandMode` | ✅ | |
| `environment.extensionName` / `ownerOrAuthorName` | 🟡 | always `""` |
| `environment.appearance` / `textSize` / `launchType` / `isDevelopment` / `raycastVersion` | 🟡 | hardcoded |
| `LaunchType` enum (`UserInitiated` / `Background`) | ⬜ | enum & members not exported |
| `FileSystemItem` (return type of `getSelectedFinderItems`) | ⬜ | type not modeled |
| `environment.canAccess(api)` | 🟡 | hardcoded `false` |
| `openExtensionPreferences` / `openCommandPreferences` | 🟡 | open Settings but don't scope to the ext / command |
| `updateCommandMetadata` | ⬜ | no host handler (silent no-op) — first-class **command** export (also §11) |
| `launchCommand` (cross-command launch) | ⬜ | `unsupported()` throws |

## 8. Clipboard, Keyboard, Window & Applications

| API | State | Gap / pending |
|---|---|---|
| `Clipboard.copy` / `paste` / `readText` | ✅ | `concealed` flag dropped (🟡); `html` / `file` copy — ⬜ (note: `transient` is **not** a current Raycast `CopyOptions` field) |
| `Clipboard.Content` / `Clipboard.ReadContent` / `Clipboard.CopyOptions` types | 🟡 | text path works; `html` / `file` content shapes not modeled |
| `Clipboard.read({offset})` → `{text, html, file}` / `Clipboard.clear` | ⬜ | absent |
| **`Keyboard` namespace** — `Keyboard.Shortcut` (`{key, modifiers}`) | ⬜ | **entire namespace absent**; only `Action.shortcut`'s behavior is noted (§4) |
| `Keyboard.KeyModifier` / `Keyboard.KeyEquivalent` / `Keyboard.Shortcut.Common` | ⬜ | modifier/key unions & predefined shortcuts (Copy, Save, …) absent |
| `getApplications` / `getDefaultApplication` / `getFrontmostApplication` (+ `Application` type) | ✅ | real; `Application` type not separately exported (🟡) |
| `getSelectedText` / `getSelectedFinderItems` | ✅ | |
| `open` / `trash` / `showInFinder` (imperative System-Utilities fns) | ⬜ | only the `Action.*` cousins exist; programmatic forms absent |
| `captureException` (error reporting) | ⬜ | no-op / absent |
| `closeMainWindow` (+ `PopToRootType` enum: `Default`/`Immediate`/`Suspended`) | ✅ | `clearRootSearch` / `popToRootType` decorative (🟡); `PopToRootType` enum not exported |
| `clearSearchBar` | ⬜ | no-op |
| `popToRoot` | 🟡 | just closes the palette (doesn't pop nav to root and stay open) |
| Window Management API — `getActiveWindow` / `getWindowsOnActiveDesktop` / `getDesktops` / `setWindowBounds` + `WindowManagement.Window` / `.Desktop` / `.DesktopType` | ⬜ | **entirely absent** from the SDK (native window-mgmt commands exist as built-ins, but there's no extension API) |

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
| `AI.ask(prompt, {model, creativity, system})` | 🟡 | real host RPC (Anthropic); `signal` (AbortSignal) option not honored |
| `AI.Creativity` (type / `none`…`maximum` \| 0–2) | 🟡 | accepted in `ask`, not modeled as a type |
| `AI.ask` streaming / Promise-as-EventEmitter | ⬜ | single resolve only |
| `AI.Model.*` | 🟡 | Proxy returns the key string; no real model metadata (enum-key fidelity unverified) |
| `OAuth.PKCEClient` (authorizationRequest / authorize / set·get·removeTokens) | ✅ | host-driven, tokens in Keychain |
| `OAuth.PKCEClient.Options` (`redirectMethod` / `providerName` / `providerIcon` / `providerId` / `description`) | 🟡 | client constructs; option fields not individually modeled |
| `OAuth.RedirectMethod` enum (`Web` / `App` / `AppURI`) | ⬜ | enum not exported |
| `OAuth.TokenSet` (+ `isExpired()`) / `TokenSetOptions` / `TokenResponse` | 🟡 | token round-trip works; named shapes not modeled |
| `OAuth.AuthorizationRequest` (+ `toURL()`) / `AuthorizationRequestOptions` / `AuthorizationOptions` / `AuthorizationResponse` | 🟡 | request/authorize work; types not exported |
| OAuth prebuilt provider configs (GitHub / Slack / Google / Linear / Zoom) | ⬜ | extensions must hand-roll endpoints |
| `BrowserExtension.getContent` (+ `cssSelector` / `format` / `tabId`) / `getTabs` / `BrowserExtension.Tab` | ⬜ | `unsupported()` throws; options & `Tab` type absent |
| AI Extensions / Tools (`src/tools/*.ts`) | ⬜ | manifest `tools[]` parsed for display only — not invoked |
| `Tool.Confirmation<T>` type + `confirmation` export (`style`/`info`/`message`/`image`) | ⬜ | AI-extension confirmation API absent |
| MCP client / Skills | ⬜ | v2 |

## 11. Manifest & command modes

| API | State | Gap / pending |
|---|---|---|
| Command modes `view` / `no-view` | ✅ | only these two accepted at discovery |
| Command mode `menu-bar` | ⬜ | rejected at discovery |
| Arguments `text` / `password` / `dropdown` | ✅ | inline search-bar chips |
| `LaunchProps` (`arguments` / `draftValues` / `launchContext` / `fallbackText`) | 🟡 | `arguments` delivered; `draftValues` / `launchContext` / `fallbackText` not passed |
| `LaunchType` enum (`UserInitiated` / `Background`) / `LaunchContext` | ⬜ | not modeled (see §7) |
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
   - Form: `TagPicker` (+ `.Item`), `FilePicker`, `Form.LinkAccessory`
   - Menu bar: `MenuBarExtra.*`
2. Render `List.EmptyView` / `Grid.EmptyView`.
3. Fire `onChange` for **Checkbox / Dropdown / DatePicker** (controlled-input parity).
4. Honor `Action.style` (destructive red) and custom `Action.shortcut` — requires exporting the **`Keyboard` namespace** (`Keyboard.Shortcut` / `KeyModifier` / `KeyEquivalent` / `Shortcut.Common`), currently absent (§8).

### P1 — depth (the props extensions most rely on)
- `List.isLoading` progress bar (and `List.Item.Detail.isLoading` / `Detail.isLoading`)
- List / Grid **pagination** (`hasMore` / `onLoadMore`) + controlled `searchText` / `throttle`
- `List.Dropdown` / `Grid.Dropdown` controlled props (`value` / `onChange` / `storeValue`)
- Clickable `Detail.Metadata.Link` + colored `TagList` / `TagList.Item` (+ `onAction`)
- `Form.PasswordField` masking + native `Form.DatePicker` (+ `DatePicker.Type` / `isFullDay`)
- `Toast` primary / secondary actions (`Toast.ActionOptions`) + `Alert.Options` (`icon` / `dismissAction` / `rememberUserChoice`)
- Working `mutate` / `MutatePromise` (optimistic updates)
- `Clipboard.read` / `clear` + System-Utilities fns (`open` / `trash` / `showInFinder` / `captureException`)
- Un-flatten `ActionPanel.Section` / `Submenu` (+ submenu search props)
- Apply `Color` / `Icon` `tintColor`; `FileIcon` resolution

### P2 — breadth / v2
- `menu-bar` command mode + `NSStatusItem` + `MenuBarExtra` (+ `.Item` `alternate`/`subtitle`/`shortcut`, `ActionEvent`)
- AI streaming (+ `signal`) + AI Extensions / Tools (`Tool.Confirmation`) / MCP / Skills
- Window Management API (`getActiveWindow` / `getDesktops` / `setWindowBounds` + types)
- Full `Icon` / `Color` enum coverage + `Image.Mask` / `Image.ImageLike`
- `useStreamJSON`
- Background `interval` refresh
- Fallback commands
- Real `environment` fields (`appearance` / `textSize` / `launchType` / `extensionName` / `canAccess`)
- OAuth provider presets + export named OAuth types/enums (`RedirectMethod` / `TokenSet` / `AuthorizationRequest` …)
- Export named types/enums project-wide: `LaunchProps` / `LaunchType` / `Cache.*` / `Preferences` / `Form.Values` / `Application` / `PopToRootType` / `Action.Style`

---

_Related: `PLAN.md` (Appendix A mirrors this), `STATUS.md` (delivery checklist). Audited against developers.raycast.com on 2026-06-16; member-level re-audit (all 29 `/api-reference` pages) on 2026-06-21._
