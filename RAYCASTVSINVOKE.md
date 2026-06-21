# Raycast vs Invoke — API Parity Gap Analysis

> **Audited 2026-06-16** against [developers.raycast.com](https://developers.raycast.com), component-by-component, against the live `@invoke/api` / `@invoke/utils` surface and the AppKit renderer.
> **Member-level re-audit 2026-06-21** — all 29 pages under `/api-reference` swept page-by-page; nested types, enums, and props folded into the tables below (incl. the previously-absent `Keyboard` namespace).
> **Code-level reconciliation 2026-06-21** — every row re-checked against the actual `@invoke/api` exports + AppKit renderer + host RPC; states corrected with `file:line` evidence (many ⬜/🟡 rows were stale — the implementation had outrun the doc).
> This is the canonical, standalone parity document. It is mirrored in `PLAN.md → Appendix A`, and `STATUS.md` tracks delivery against it.
>
> **Legend:** **✅ working** · **🟡 partial / lossy** (member is defined but the renderer ignores props, or semantics differ from Raycast) · **⬜ missing** (throws `unsupported()`, crashes as `"Element type is invalid"`, or is a silent no-op).

---

## 0. Executive summary

**The spine is in place.** Invoke renders the core Raycast component model natively: **List, Grid, Detail, Form, ActionPanel/Action, Detail.Metadata, List.Dropdown, List.Item.Detail**. Real Raycast-shaped extensions launch end-to-end through the process-per-extension runtime + mutation-mode reconciler.

**Recently landed & verified:** navigation push/pop (declarative `Action.Push` **and** programmatic `useNavigation().push/pop`), command arguments (inline search-bar chips), per-extension Trust (run unsandboxed), in-palette `confirmAlert` modal (both launch hosts), world-class search dropdown (custom popover + favicons), constant palette size/position, Form validation + value preservation, and `AI.ask` / `OAuth.PKCEClient` as real host-driven RPCs.

**What remains is two kinds of gap:**
1. **Breadth** — many SDK members are *defined* (so extensions importing them type-check and load) but the renderer doesn't honor every prop.
2. **Depth** — controlled-input semantics (`onChange` for Checkbox, typed values), pagination, and streaming (AI tokens, `useStreamJSON`) are not fully wired.

**Implementation has since outrun the original gap analysis.** The 2026-06-21 code-level reconciliation found the former "takes down the whole view" crash members — `Action.Trash` / `OpenWith` / `ShowInFinder` / `ToggleQuickLook` / `CreateQuicklink` / `CreateSnippet` / `PickDate`, `Form.TagPicker` / `FilePicker` / `LinkAccessory`, and `MenuBarExtra.*` — are **all defined now and either functional or degrade gracefully** (no more `"Element type is invalid"`). Menu-bar commands render to a real `NSStatusItem`; `launchCommand` / `updateCommandMetadata` work; the `Keyboard` namespace is exported. The remaining gaps are mostly **depth** (controlled non-text inputs, pagination, streaming, native pickers/masking) and **named-type exports**, not crashes.

---

## 1. List & Grid

| API | State | Gap / pending |
|---|---|---|
| `List` render + `searchBarPlaceholder` + `onSearchTextChange` | ✅ | search text routes to the child |
| `List` / `Grid` controlled `searchText` + `throttle` | ⬜ | controlled search value & debounce prop not honored |
| `List` / `Grid` component-level `actions` (empty-state ActionPanel) | ⬜ | top-level `actions` prop not rendered |
| `List.Section`, `List.Item` (title/subtitle/icon) | ✅ | |
| `List.Dropdown` / `.Item` / `.Section` (searchBarAccessory) | ✅ | world-class popover (landed) |
| `List.Dropdown` / `Grid.Dropdown` controlled props (`value` / `defaultValue` / `onChange` / `storeValue` / `filtering` / `onSearchTextChange` / `isLoading` / `tooltip`) | 🟡 | `value` / `defaultValue` / `onChange` wired (`AppController.swift:3660`); `storeValue` / `filtering` / `isLoading` / `tooltip` ignored |
| `List.isLoading` | ✅ | thin accent sweep bar (List/Grid/Detail), 2026-06-21 |
| `List` pagination `{hasMore, onLoadMore, pageSize}` | ✅ | renderer near-bottom → `onLoadMore` (in-flight guarded); `@invoke/api` flattens the prop, 2026-06-21 |
| Native fuzzy `filtering` of static items / `filtering={false}` escape hatch | 🟡 | built-in client-side filter exists (`AppController.swift:121` `filterTree`, substring on title/subtitle/keywords) — but not fuzzy-ranked, and `filtering={false}` is not honored (gated on presence of `onSearchTextChange`) |
| `selectedItemId` / `onSelectionChange` | ⬜ | selection not reported back to the extension |
| `List.EmptyView` | ⬜ | exported (`index.ts:139`) so no crash, but renderer never handles `empty-view` → no-op |
| `List.Item.accessories[]` | ✅ | text/tag/date/icon/tooltip + per-accessory `color` + combined entries, 2026-06-21 |
| `List.Item` `keywords` / `detail` (isShowingDetail) / `quickLook` | 🟡 | keywords used by the filter (`AppController.swift:115`); master-detail `isShowingDetail` honored; `quickLook` ⬜ |
| `List.Item.Detail.isLoading` (detail-pane bar, distinct from `List.isLoading`) | ✅ | selected item's detail `isLoading` drives the top sweep bar, 2026-06-21 |
| `Grid` `columns` | ✅ | |
| `Grid` `aspectRatio` / `fit` (contain/fill) / `inset` | ⬜ | ignored (`renderGrid` reads only `columns`/`itemHeight`) |
| `Grid.Section` / `Grid.Dropdown` / `Grid.EmptyView` | 🟡 / ⬜ | sections flattened; EmptyView unrendered |
| `Grid.Section` per-section `columns` / `aspectRatio` / `fit` / `inset` overrides | ⬜ | only top-level Grid layout props read |
| `Grid.Item.accessory` (`Grid.Item.Accessory`) | ✅ | single accessory (icon/text/tag + tooltip) rendered under the tile title, 2026-06-21 |
| `Grid.ItemSize` (deprecated enum) | ⬜ | defined (`index.ts:158`) but a no-op (renderer sizes by `columns`) |

## 2. Detail, Colors & Icons

| API | State | Gap / pending |
|---|---|---|
| `Detail` CommonMark `markdown` (incl. images, clamped) | ✅ | tables / LaTeX / footnotes — ⬜ |
| `Detail` own `isLoading` (accent sweep bar) | ✅ | honored via the shared sweep bar, 2026-06-21 |
| `Detail.Metadata.Label` (`text` string) / `.Separator` | ✅ | (note: standalone-`Detail` sidebar renders Label only — Link/TagList dropped there) |
| `Detail.Metadata.Label` colored `text:{color,value}` + `icon` | 🟡 | rendered, but `Color` not applied & label icon lossy |
| `Detail.Metadata.Link` | 🟡 | rendered as text in master-detail — **not clickable**; dropped entirely on the standalone-`Detail` sidebar |
| `Detail.Metadata.TagList` | 🟡 | comma-joined; no per-tag color/icon chips; dropped on standalone-`Detail` sidebar |
| `Detail.Metadata.TagList.Item` (`text` / `icon` / `color` / `onAction`) | 🟡 | leaf tag element not individually rendered; `onAction` (clickable tag) ⬜ |
| `Icon` enum | 🟡 | 48 members defined (`index.ts:369`); 30 SF-Symbol-mapped (`PaletteView.swift:2197`), the rest fall back to a default glyph |
| `Color` enum (9 named members) | 🟡 | applied to List/Grid accessory text/tags/icon tints (`RaycastColor`, `PaletteView.swift:1811`/`1815`/`2108`); **not** applied in `Detail.Metadata` (hardcoded). `Color.Dynamic` constant **not** exported |
| raw HEX / `{light,dark}` color values | 🟡 | honored at runtime for accessories (`RaycastColor.colorFromHex`, `PaletteView.swift:2023`); no named `Color.Raw` / `ColorLike` type exported |
| `Image.Mask` (Circle / RoundedRectangle) | ⬜ | masks ignored |
| `Image` fallback + dynamic `{source:{light,dark}}` | ⬜ | single source resolved; no light/dark image dispatch |
| `Image.tintColor` (as `Image` prop) | 🟡 | applied to **accessory** icons (`PaletteView.swift:2062`/`2108`); not to Detail / top-level row icons; no `Image.tintColor` API export |
| `Image.ImageLike` union (URL \| Asset \| `Icon` \| `FileIcon` \| `Image`) | 🟡 | type accepted; `fileIcon` resolved; masks / Image tint lossy |
| `FileIcon` (`{fileIcon}`) — Finder file/folder icon | 🟡 | resolved to a real Finder icon for list/grid/detail (`PaletteView.swift:1010`, `NSWorkspace.icon(forFile:)`); not a named API export |

## 3. Form

| API | State | Gap / pending |
|---|---|---|
| `Form.TextField` / `TextArea` / `Checkbox` / `Dropdown` | ✅ | render + value-collecting submit |
| `Form.Description` (`text` / `title`) / `Separator` | ✅ | landed |
| `Form` container props (`navigationTitle` / `isLoading` / `searchBarAccessory`) | 🟡 | `isLoading` honored (shared sweep bar, `PaletteView.swift:335`); `navigationTitle` & `searchBarAccessory` not |
| `Form.Dropdown.Item` / `Form.Dropdown.Section` | 🟡 | dropdown renders, but item `keywords` & section `title` lossy |
| `Form.Dropdown` searchable props (`onSearchTextChange` / `filtering` / `throttle` / `isLoading`) | ⬜ | popover has local typeahead (`FormDropdown.swift:125`), but the async/controlled API props are unwired |
| `Form.TextArea` `enableMarkdown` | ⬜ | markdown toolbar/preview not rendered |
| Validation (`FormValidation.Required`) + error rendering | 🟡 | only `Required`; no custom / async validators |
| `Form.PasswordField` | 🟡 | aliases a plain text field (not masked — no `NSSecureTextField`) |
| `Form.DatePicker` (+ `min` / `max`) | 🟡 | aliases a plain text field (no `NSDatePicker`, no `Date` value, bounds ignored) |
| `Form.DatePicker.Type` enum (`Date` / `DateTime`) + `Form.DatePicker.isFullDay()` | 🟡 | `Type` enum exported (`index.ts:208`); `isFullDay()` helper still absent & DatePicker itself text-aliased |
| `Form.TagPicker` / `Form.TagPicker.Item` | 🟡 | exported (`index.ts:192`); **no longer crashes** — degrades to a single-select dropdown (value is a string, not an array) |
| `Form.FilePicker` (+ `allowMultipleSelection` / `canChooseFiles` / `canChooseDirectories` / `showHiddenFiles`) | 🟡 | exported (`index.ts:218`); **no longer crashes** — degrades to a path text field; options still ignored |
| `Form.LinkAccessory` (`target` / `text`) | 🟡 | exported (`index.ts:220`); **no longer crashes** — degrades to inert description text (not a clickable accessory) |
| `onChange` | 🟡 | fires for text fields **and Dropdown** (`PaletteView.swift:1559`); still **not** Checkbox (`:1519`) |
| `onBlur` / `onFocus` / `autoFocus` / `storeValue` / `info` / `enableDrafts` | ⬜ | |
| `Form.Event` / `Form.Event.Type` (`focus`/`blur`) / `Form.Values` types | ⬜ | event payload & values type not modeled |
| Typed values (Checkbox→`bool`, DatePicker→`Date`, TagPicker→`array`) | 🟡 | all field values are strings |
| Imperative `focus()` / `reset()` via ref | ⬜ | per-item refs (`useRef<Form.TextField>`) — must be exposed on all controlled item types |

## 4. Actions & ActionPanel

| API | State | Gap / pending |
|---|---|---|
| `Action` (onAction), `CopyToClipboard`, `Paste`, `OpenInBrowser`, `Open`, `SubmitForm`, `Push` | ✅ | the 7 wired actions |
| `Action.OpenWith` / `Trash` / `ShowInFinder` / `ToggleQuickLook` / `CreateQuicklink` / `CreateSnippet` / `PickDate` | 🟡 | all defined + routed (`index.ts:281`–`315`, `AppController.swift:3760`) — **no longer crash**; most fire real host RPCs (ShowInFinder→`showInFinder`, Trash→`trash`, OpenWith→`open.with`, ToggleQuickLook→`quicklook.preview`, CreateQuicklink/Snippet→store RPCs, PickDate→`date.pick`) |
| `ActionPanel.Submenu` | ✅ | drill-in (level stack); →/Return enters, ←/Esc pops. Lazy `onOpen` ⬜ |
| `ActionPanel.Submenu` search props (`filtering` / `keepSectionOrder` / `throttle` / `onSearchTextChange` / `isLoading`) | 🟡 | client-side title filter works per level; async `onSearchTextChange` / `throttle` / `isLoading` not wired |
| `ActionPanel.Section` | ✅ | grouped: separators + small-caps titles, 2026-06-21 |
| `Action.shortcut` (custom) | 🟡 | ignored; only first=Enter / second=⌘Enter assigned |
| `Action.style` (destructive) | ⬜ | `props["style"]` never decoded in the panel (no red emphasis) |
| `Action.Style` enum (`Regular` / `Destructive`) | 🟡 | enum exported (`index.ts:273`); the `style` prop is still not rendered |
| `Action.PickDate.Type` enum (`Date` / `DateTime`) + `Action.PickDate.isFullDay()` | ⬜ | nested enum & helper absent (only `PickDate` itself assigned) |
| `Keyboard.Shortcut` / `Keyboard.Shortcut.Common` (type behind `Action.shortcut`) | 🟡 | `Keyboard.Shortcut.Common` exported (`index.ts:878`); custom shortcuts still not applied (see §8) |
| `Action.autoFocus` | ⬜ | |

## 5. Navigation & Menu Bar

| API | State | Gap / pending |
|---|---|---|
| `Action.Push` + `useNavigation().push/pop` + Esc-pops | ✅ | render-on-push frames (landed) |
| `Navigation` (type returned by `useNavigation`) | 🟡 | push/pop work; type not exported/modeled |
| `navigationTitle` breadcrumb | ✅ | |
| `menu-bar` command mode | ✅ | accepted at discovery (`AppController.swift:3001`); real `NSStatusItem` (`MenuBarController.swift:41`) |
| `MenuBarExtra` + `.Item` | ✅ | exported (`index.ts:345`) + rendered to `NSMenu` (`MenuBarController.swift:76`/`121`) |
| `MenuBarExtra.Submenu` / `.Section` / `.Separator` | ✅ | rendered (`MenuBarController.swift:123`–`139`: separator / disabled-header section / nested submenu) |
| `MenuBarExtra.Item` `alternate` / `subtitle` / `shortcut` | 🟡 | `subtitle` rendered (`MenuBarController.swift:151`); `alternate` / `shortcut` not |
| `MenuBarExtra.ActionEvent` (`left-click` / `right-click`) | ⬜ | onAction fires with no event arg |

## 6. Feedback

| API | State | Gap / pending |
|---|---|---|
| `showToast` (Success/Failure/Animated; object + positional overload; updatable handle) | ✅ | |
| `Toast.primaryAction` / `secondaryAction` (`Toast.ActionOptions`) | ⬜ | accepted in the constructor but the `toast.show` RPC drops them; not surfaced |
| `Toast.Style` enum (`Success` / `Failure` / `Animated`) | 🟡 | states used by `showToast`, but enum not tracked; minimal visual differentiation |
| Toast visual style (icon / color per style) | 🟡 | minimal differentiation |
| `showHUD` | 🟡 | renders, but `options` (`clearRootSearch` / `popToRootType`) are decorative no-ops |
| `confirmAlert` (in-palette modal, `primaryAction.onAction`, destructive, key capture) | ✅ | landed this iteration, both hosts |
| `Alert.Options` `icon` / `dismissAction` / `rememberUserChoice` | ⬜ | custom icon, secondary dismiss action & "don't ask again" not honored |
| `Alert.ActionStyle` enum (`Default` / `Destructive` / `Cancel`) + `Alert.ActionOptions` | 🟡 | enum exported (`index.ts:873`) + destructive honored end-to-end (`AppController.swift:2013`); `Alert.ActionOptions` type not modeled |
| `showFailureToast` (utils) | ✅ | |

## 7. Storage, Preferences & Environment

| API | State | Gap / pending |
|---|---|---|
| `LocalStorage` get/set/remove/allItems/clear (getItem→`undefined` parity) | ✅ | |
| `LocalStorage.Value` / `LocalStorage.Values` types | 🟡 | functions work; named types not exported |
| `Cache` get/set/has/remove/clear | ✅ | `subscribe` — ⬜ no-op; `capacity` / LRU eviction — ⬜ |
| `Cache` constructor `{namespace, capacity}` / `isEmpty` | 🟡 | `namespace` isolation (`index.ts:631`) & `isEmpty` (`index.ts:664`) honored; `capacity` / LRU ignored |
| `Cache.Subscriber` / `Cache.Subscription` / `Cache.Options` types | ⬜ | not modeled |
| `getPreferenceValues` + types textfield/password/checkbox/dropdown/appPicker | ✅ | `file` / `directory` pref types — ⬜ |
| `Preferences` / `PreferenceValues` types | 🟡 | `getPreferenceValues` works; named types not exported |
| Per-command preference override + required-before-run | ✅ | |
| `environment.supportPath` / `assetsPath` / `commandName` / `commandMode` | ✅ | |
| `environment.extensionName` / `ownerOrAuthorName` | 🟡 | always `""` (`INVOKE_EXTENSION`/`INVOKE_OWNER` env vars never set) |
| `environment.appearance` / `textSize` / `launchType` / `isDevelopment` / `raycastVersion` | 🟡 | `launchType` wired (`INVOKE_LAUNCH_TYPE`, `index.ts:587`); `appearance` / `textSize` / `isDevelopment` / `raycastVersion` hardcoded |
| `LaunchType` enum (`UserInitiated` / `Background`) | ✅ | exported (`index.ts:474`); drives `launchCommand` + `environment.launchType` |
| `FileSystemItem` (return type of `getSelectedFinderItems`) | ⬜ | inline `{path:string}[]`; no named type |
| `environment.canAccess(api)` | 🟡 | hardcoded `false` |
| `openExtensionPreferences` / `openCommandPreferences` | 🟡 | send a `scope` arg, but host ignores it & opens the Commands tab (not scoped) |
| `updateCommandMetadata` | ✅ | real RPC (`index.ts:796`) + host stores subtitle override & re-renders root (`AppController.swift:2120`) |
| `launchCommand` (cross-command launch) | ✅ | real `command.launch` RPC (`index.ts:783`) + host launches view/no-view/background/menu-bar with args + context (`AppController.swift:2127`) |

## 8. Clipboard, Keyboard, Window & Applications

| API | State | Gap / pending |
|---|---|---|
| `Clipboard.copy` / `paste` / `readText` | ✅ | `concealed` flag dropped (🟡); `html` / `file` copy — ⬜ (note: `transient` is **not** a current Raycast `CopyOptions` field) |
| `Clipboard.Content` / `Clipboard.ReadContent` / `Clipboard.CopyOptions` types | 🟡 | text path works; `html` / `file` content shapes not modeled |
| `Clipboard.read({offset})` → `{text, html, file}` / `Clipboard.clear` | 🟡 | `read` exported + host returns `{text,file,html}` (`AppController.swift:2232`), but the JS shim returns text only (`index.ts:501`; `html`/`file`/`offset` dropped); `Clipboard.clear` still absent |
| **`Keyboard` namespace** — `Keyboard.Shortcut` (`{key, modifiers}`) | 🟡 | **exported** (`index.ts:878`) — namespace is **not** absent; `Shortcut` is a local type (unexported); shortcuts still not applied to the UI |
| `Keyboard.KeyModifier` / `Keyboard.KeyEquivalent` / `Keyboard.Shortcut.Common` | 🟡 | `Shortcut.Common` populated (`index.ts:881`); `KeyModifier` / `KeyEquivalent` unions not exported |
| `getApplications` / `getDefaultApplication` / `getFrontmostApplication` (+ `Application` type) | ✅ | real; `Application` interface **is** exported (`index.ts:760`) |
| `getSelectedText` / `getSelectedFinderItems` | ✅ | |
| `open` / `trash` / `showInFinder` (imperative System-Utilities fns) | ✅ | exported (`index.ts:547`/`770`/`774`) + real host handlers (`AppController.swift:2035`/`2300`/`2210`) |
| `captureException` (error reporting) | 🟡 | exported + host handler (`index.ts:847`, `AppController.swift:2116`) but it logs only & **discards** message/stack (privacy) |
| `closeMainWindow` (+ `PopToRootType` enum: `Default`/`Immediate`/`Suspended`) | ✅ | `PopToRootType` **is** exported (`index.ts:475`); `clearRootSearch` / `popToRootType` options still decorative (🟡) |
| `clearSearchBar` | ⬜ | exported but an empty no-op (import-safe; no RPC) |
| `popToRoot` | 🟡 | just closes the palette (doesn't pop nav to root and stay open) |
| Window Management API — `getActiveWindow` / `getWindowsOnActiveDesktop` / `getDesktops` / `setWindowBounds` + `WindowManagement.Window` / `.Desktop` / `.DesktopType` | ⬜ | `WindowManagement` is exported but every method throws `unsupported()` (`index.ts:940`); no host handler (native window-mgmt exists only as first-party built-ins) |

## 9. `@raycast/utils` hooks

| API | State | Gap / pending |
|---|---|---|
| `usePromise` / `useCachedState` / `useCachedPromise` / `useFetch` / `useExec` / `useSQL` / `useForm` / `useLocalStorage` / `useFrecencySorting` / `useAI` | ✅ | present and used by real extensions |
| `mutate` / `MutatePromise` (`optimisticUpdate` / `rollbackOnError`) | 🟡 | working runtime `mutate` (awaits update + revalidates, `utils:88`/`358`); `optimisticUpdate` / `rollbackOnError` options still ignored |
| Pagination (function-form source in `useFetch` / `useCachedPromise`) | ✅ | `usePromise` + `useFetch` (url-as-fn) + `useCachedPromise` accumulate pages (`mergePages`) + expose `pagination`, 2026-06-21 |
| `useStreamJSON` | 🟡 | exported + functional (`dataPath`/`filter`/`transform`, `utils:851`), but buffered (`res.json()`) — not progressive streaming |
| `useAI` streaming (`.on('data')` token stream) | 🟡 | resolves once; no progressive tokens |
| `getFavicon` / `getAvatarIcon` / `getProgressIcon` | ✅ | |
| `createDeeplink` / `withCache` / `OAuthService` / `withAccessToken` / `getAccessToken` | ✅ | present |
| `runPowerShellScript` | ⬜ | throws on macOS (by design) |

## 10. OAuth, AI, Browser Extension & Tools

| API | State | Gap / pending |
|---|---|---|
| `AI.ask(prompt, {model, creativity, system})` | 🟡 | real host RPC (Anthropic); `system` honored; `model` / `creativity` sent but **dropped host-side** (`AppController.swift:1856`); `signal` not honored |
| `AI.Creativity` (type / `none`…`maximum` \| 0–2) | 🟡 | accepted in `ask`, not modeled as a type (and dropped host-side) |
| `AI.ask` streaming / Promise-as-EventEmitter | ⬜ | single resolve only |
| `AI.Model.*` | 🟡 | Proxy returns the key string; no real model metadata |
| `OAuth.PKCEClient` (authorizationRequest / authorize / set·get·removeTokens) | ✅ | host-driven, tokens in Keychain |
| `OAuth.PKCEClient.Options` (`redirectMethod` / `providerName` / `providerIcon` / `providerId` / `description`) | 🟡 | client constructs; option fields not individually modeled as a named type |
| `OAuth.RedirectMethod` enum (`Web` / `App` / `AppURI`) | ✅ | exported (`index.ts:715`) |
| `OAuth.TokenSet` (+ `isExpired()`) / `TokenSetOptions` / `TokenResponse` | 🟡 | `TokenSet`/`TokenResponse` exported with `isExpired()`; `TokenSetOptions` not a distinct named export |
| `OAuth.AuthorizationRequest` (+ `toURL()`) / `AuthorizationRequestOptions` / `AuthorizationOptions` / `AuthorizationResponse` | ✅ | exported with working `toURL()` → `buildAuthorizeURL` (`index.ts:702`/`745`) |
| OAuth prebuilt provider configs (GitHub / Slack / Google / Linear / Zoom) | ⬜ | extensions must hand-roll endpoints |
| `BrowserExtension.getContent` (+ `cssSelector` / `format` / `tabId`) / `getTabs` / `BrowserExtension.Tab` | 🟡 | real RPCs via `BrowserDriver` AppleScript (`index.ts:825`, `AppController.swift:1879`); `Tab` exported; markdown conversion is a regex approximation |
| AI Extensions / Tools (`src/tools/*.ts`) | ⬜ | manifest `tools[]` parsed for display only — not invoked |
| `Tool.Confirmation<T>` type + `confirmation` export (`style`/`info`/`message`/`image`) | ⬜ | `Tool.Confirmation` is an identity passthrough; does not gate execution |
| MCP client / Skills | ⬜ | v2 |

## 11. Manifest & command modes

| API | State | Gap / pending |
|---|---|---|
| Command modes `view` / `no-view` | ✅ | accepted at discovery |
| Command mode `menu-bar` | ✅ | accepted at discovery + rendered (`AppController.swift:3001`/`3020`); see §5 |
| Arguments `text` / `password` / `dropdown` | ✅ | inline search-bar chips |
| `LaunchProps` (`arguments` / `draftValues` / `launchContext` / `fallbackText`) | 🟡 | `arguments` **and** `launchContext` delivered (`child.ts:140`/`143`); `draftValues` / `fallbackText` not passed |
| `LaunchType` enum (`UserInitiated` / `Background`) / `LaunchContext` | 🟡 | `LaunchType` exported (§7); `LaunchContext` type not modeled |
| Background refresh (`interval`) | 🟡 | scheduled for `no-view` commands (`AppController.swift:3017`, `parseInterval` → timer) |
| Fallback commands | ⬜ | |
| `disabledByDefault` | ⬜ | |
| Preferences `textfield` / `password` / `checkbox` / `dropdown` / `appPicker` (+`required`) | ✅ | `file` / `directory` — ⬜; per-platform `default` — 🟡 |
| `tools[]` / `ai{}` objects | 🟡 | parsed for the Commands detail panel; not executed |

---

## 12. Prioritized backlog

### P0 — crash-prevention & correctness
1. ~~**Graceful-degrade every undefined component**~~ — **DONE (2026-06-21):** the `Action.*`, `Form.TagPicker`/`FilePicker`/`LinkAccessory`, and `MenuBarExtra.*` members are all defined now; nothing throws `"Element type is invalid"`. (`Keyboard` namespace also exported.)
2. Render `List.EmptyView` / `Grid.EmptyView` (still ⬜ no-ops).
3. Fire `onChange` for **Checkbox** (Dropdown now fires; DatePicker is text-aliased so fires as text) — controlled-input parity.
4. Honor `Action.style` (destructive red) and bind custom `Action.shortcut` to the exported `Keyboard.Shortcut` values (not yet applied to the UI).

### P1 — depth (the props extensions most rely on)
- _(Done 2026-06-21: `List`/`Detail` `isLoading` bars; `List.Item`/`Grid.Item` accessories incl. `Color`/`Icon` tint + `FileIcon`; grouped `ActionPanel.Section` + drill-in `Submenu`; imperative `open`/`trash`/`showInFinder`; working `mutate` runtime.)_
- List / Grid **pagination** (`hasMore` / `onLoadMore`) + controlled `searchText` / `throttle`; surface `pagination` through `useFetch` / `useCachedPromise`
- `List.Dropdown` / `Grid.Dropdown` remaining controlled props (`storeValue` / `filtering` / `isLoading`)
- Clickable `Detail.Metadata.Link` + per-tag `TagList.Item` chips (+ `onAction`); apply `Color` inside `Detail.Metadata`
- `Form.PasswordField` masking + native `Form.DatePicker` (+ `isFullDay`); typed (non-string) field values
- `Toast` primary / secondary actions (`Toast.ActionOptions`) + `Alert.Options` (`icon` / `dismissAction` / `rememberUserChoice`)
- `optimisticUpdate` / `rollbackOnError` on the working `mutate`
- `Clipboard.read` full `{text,html,file}` + `offset` (host already returns them) + `Clipboard.clear`

### P2 — breadth / v2
- _(Done: `menu-bar` mode + `NSStatusItem` + `MenuBarExtra`/`.Item`/`.Submenu`/`.Section`; `launchCommand`; `updateCommandMetadata`; `BrowserExtension`.)_ Remaining: `MenuBarExtra.Item` `alternate`/`shortcut` + click `ActionEvent`
- AI streaming (+ `signal`; honor `model`/`creativity` host-side) + AI Extensions / Tools (`Tool.Confirmation`) / MCP / Skills
- Window Management API (`getActiveWindow` / `getDesktops` / `setWindowBounds` + types) — currently `unsupported()`-throws
- Full `Icon` / `Color` enum coverage + `Image.Mask` / dynamic light/dark images
- `useStreamJSON` true progressive streaming; `useAI` token stream
- Fallback commands; `disabledByDefault`
- Real `environment` fields (`appearance` / `textSize` / `extensionName` / `canAccess`)
- OAuth provider presets
- Export remaining named types/enums project-wide: `Cache.*` / `Preferences` / `Form.Values` / `KeyModifier` / `Navigation` / `LaunchContext`

---

_Related: `PLAN.md` (Appendix A mirrors this), `STATUS.md` (delivery checklist). Audited against developers.raycast.com on 2026-06-16; member-level re-audit (all 29 `/api-reference` pages) + code-level implementation reconciliation on 2026-06-21._
