# Invoke v2 — Raycast extension compatibility report

- **Root scanned:** `/Users/test/Documents/code/extensions/extensions`
- **Mode:** sandboxed (default)
- **Extensions found:** 2961

## Summary

| Status | Count | % |
|---|---:|---:|
| SUPPORTED | 650 | 22.0% |
| DEGRADED | 475 | 16.0% |
| UNSUPPORTED | 1836 | 62.0% |

## Top gaps (extensions blocked/degraded per missing capability)

| Capability | Extensions affected |
|---|---:|
| denied Node built-ins in sandbox | 1023 |
| useNavigation | 815 |
| confirmAlert | 650 |
| @raycast/utils | 509 |
| declares command `arguments[]` — not passed by runtime yet | 481 |
| openExtensionPreferences | 376 |
| Cache | 258 |
| launchCommand | 250 |
| @raycast/api | 240 |
| unsupported command mode(s) | 236 |
| declares background `interval` command(s) — not scheduled | 220 |
| getSelectedText | 206 |
| declares AI tools[] | 186 |
| getApplications | 167 |
| openCommandPreferences | 153 |
| declares extension-level `ai` instructions — ignored | 145 |
| getSelectedFinderItems | 127 |
| OAuth | 96 |
| showInFinder | 91 |
| AI | 90 |
| updateCommandMetadata | 88 |
| getFrontmostApplication | 86 |
| useExec | 41 |
| captureException | 37 |
| trash | 36 |

## UNSUPPORTED (1836)

### `0x0` — 0x0
- dir: `0x0` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `1-click-confetti` — 1-Click Confetti
- dir: `1-click-confetti` · commands: 2 · modes: menu-bar|no-view
- **Blockers:** unsupported command mode(s): confetti-menu: mode "menu-bar"; denied Node built-ins in sandbox: child_process

### `1bookmark` — 1Bookmark
- dir: `1bookmark` · commands: 3 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `1loc` — 1 LOC - JavaScript Utilities in Single Line of Code
- dir: `1loc` · commands: 1 · modes: view
- Needs review: @raycast/utils:getPreferenceValues (not implemented in Invoke); @raycast/utils:List (not implemented in Invoke)

### `1password` — 1Password
- dir: `1password` · commands: 4 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares background `interval` command(s) — not scheduled

### `2fa-directory` — 2FA Directory
- dir: `2fa-directory` · commands: 1 · modes: view
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `42-api` — 42 Api Tools
- dir: `42-api` · commands: 2 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): today-logtime: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled

### `8-divide` — 8 Divide
- dir: `8-divide` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getSelectedText: throws — selection APIs not wired

### `aave-search` — Aave Contract Search
- dir: `aave-search` · commands: 1 · modes: view
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `ableton-live` — Ableton Live
- dir: `ableton-live` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `abstract-api` — Abstract API
- dir: `abstract-api` · commands: 8 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `accordance` — Accordance
- dir: `accordance` · commands: 6 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openCommandPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet

### `acqua` — Acqua
- dir: `acqua` · commands: 2 · modes: view|menu-bar
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; unsupported command mode(s): menubar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `adb` — Android Debug Bridge (Adb) Commands
- dir: `adb` · commands: 20 · modes: no-view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: child_process, fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet

### `adhan-time` — Adhan Time
- dir: `adhan-time` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): adhan: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled

### `ado-search` — Azure DevOps Repositories Search
- dir: `ado-search` · commands: 5 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `advanced-replace` — Advanced Replace
- dir: `advanced-replace` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `advanced-speech-to-text` — Advanced Speech to Text
- dir: `advanced-speech-to-text` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `aegis` — Aegis Authenticator
- dir: `aegis` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `aerospace` — Aerospace Tiling Window Manager
- dir: `aerospace` · commands: 5 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): shortcutsMenubar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ag-audioflow` — AG AudioFlow
- dir: `ag-audioflow` · commands: 11 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; getSelectedFinderItems: throws — Finder selection not wired; launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: fs, child_process

### `agent-client-protocol` — Agent Client Protocol
- dir: `agent-client-protocol` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `agent-ecosystem-map` — Agent Ecosystem Map
- dir: `agent-ecosystem-map` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `agent-usage` — Agent Usage
- dir: `agent-usage` · commands: 2 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): agent-usage-menubar: mode "menu-bar"; denied Node built-ins in sandbox: fs, module, child_process, http, https
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `ai-agency` — AI Agency
- dir: `ai-agency` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `ai-code-namer` — AI Code Namer
- dir: `ai-code-namer` · commands: 9 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired

### `ai-gen` — OpenAI Generator
- dir: `ai-gen` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ai-git-assistant` — AI Git Assistant
- dir: `ai-git-assistant` · commands: 2 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; AI: AI.ask throws — Invoke AI not yet wired; getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ai-screenshot` — AI Screenshot
- dir: `ai-screenshot` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ai-stats` — AI Stats
- dir: `ai-stats` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `ai-text-to-calendar` — AI Text to Calendar
- dir: `ai-text-to-calendar` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `air-quality` — Air Quality
- dir: `air-quality` · commands: 2 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): air-quality-menu: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled

### `airpods-noise-control` — AirPods Noise Control
- dir: `airpods-noise-control` · commands: 2 · modes: no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented

### `akkoma` — Akkoma
- dir: `akkoma` · commands: 4 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `alacritty` — Alacritty
- dir: `alacritty` · commands: 4 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog)

### `aleph` — Aleph Tools
- dir: `aleph` · commands: 4 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Needs review: @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `alice-ai` — Alice AI - Your Daily AI Actions Companion
- dir: `alice-ai` · commands: 5 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; getSelectedText: throws — selection APIs not wired; unsupported command mode(s): menubar: mode "menu-bar"
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `align-rtl` — Align RTL
- dir: `align-rtl` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process

### `alist-downloder` — AList Downloder
- dir: `alist-downloder` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `alloy` — Alloy
- dir: `alloy` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Needs review: @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `alt-text-generator` — Alt-Text Generator
- dir: `alt-text-generator` · commands: 3 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `alwaysdata` — alwaysdata
- dir: `alwaysdata` · commands: 4 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `amphetamine` — Amphetamine
- dir: `amphetamine` · commands: 4 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired

### `android` — Android
- dir: `android` · commands: 2 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process

### `android-adb-input` — Android ADB Input
- dir: `android-adb-input` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `android-screen-capture` — Android Screen Capture
- dir: `android-screen-capture` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `animated-window-manager` — Animated Window Manager
- dir: `animated-window-manager` · commands: 4 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `annotely` — Annotely
- dir: `annotely` · commands: 3 · modes: no-view|view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs, child_process, http

### `anonaddy` — Addy
- dir: `anonaddy` · commands: 5 · modes: view|no-view
- **Blockers:** getDefaultApplication: throws — application discovery not wired; getFrontmostApplication: throws — application discovery not wired; AI: AI.ask throws — Invoke AI not yet wired; launchCommand: launchCommand not implemented; getSelectedText: throws — selection APIs not wired
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; captureException: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review); @raycast/utils:withCache (not implemented in Invoke)

### `another-boring-piece` — Art Wallpapers
- dir: `another-boring-piece` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; confirmAlert: always returns false (no dialog); declares background `interval` command(s) — not scheduled

### `antd-open-browser` — Antd
- dir: `antd-open-browser` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `antigravity` — Antigravity
- dir: `antigravity` · commands: 6 · modes: view|no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process, http
- Degraded: confirmAlert: always returns false (no dialog)

### `antinote` — Antinote
- dir: `antinote` · commands: 3 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `any-website-search` — Universal Website Search
- dir: `any-website-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `anybox` — Anybox
- dir: `anybox` · commands: 15 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `anytype` — Anytype
- dir: `anytype` · commands: 5 · modes: view
- **Blockers:** declares AI tools[] (12) — AI extensions not supported
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:MutatePromise (not implemented in Invoke)

### `apfel` — Apfel
- dir: `apfel` · commands: 13 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `app` — App Creator
- dir: `app-creator` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `app-icon-generator` — App Icon Generator
- dir: `app-icon-generator` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op

### `app-keeper-manager` — App Keeper Manager
- dir: `app-keeper-manager` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `app-store-connect` — App Store Connect
- dir: `app-store-connect` · commands: 6 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `app-tag-manager` — App Tag Manager
- dir: `app-tag-manager` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `app-updates` — App Updates
- dir: `app-updates` · commands: 4 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; AI: AI.ask throws — Invoke AI not yet wired; unsupported command mode(s): menu-bar: mode "menu-bar", brew-maintenance: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: openCommandPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled

### `appcleaner` — App Cleaner
- dir: `appcleaner` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; updateCommandMetadata: menu-bar/command metadata updates not implemented; denied Node built-ins in sandbox: child_process, fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `append-clipboard` — Append Clipboard
- dir: `append-clipboard` · commands: 3 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet

### `append-to-file` — Append Text to File
- dir: `append-to-file` · commands: 5 · modes: view|no-view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `appgrid` — AppGrid
- dir: `appgrid` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired

### `apple-notes` — Apple Notes
- dir: `apple-notes` · commands: 7 · modes: view|no-view|menu-bar
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired; unsupported command mode(s): menu-bar: mode "menu-bar"; declares AI tools[] (4) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `apple-passwords` — Apple Password
- dir: `apple-passwords` · commands: 2 · modes: view|no-view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: child_process, module, fs
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: namespace import of @raycast/api (member usage unverified)

### `apple-photos` — Apple Photos
- dir: `apple-photos` · commands: 2 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs

### `apple-reminders` — Apple Reminders
- dir: `apple-reminders` · commands: 7 · modes: view|menu-bar|no-view
- **Blockers:** launchCommand: launchCommand not implemented; AI: AI.ask throws — Invoke AI not yet wired; unsupported command mode(s): menu-bar: mode "menu-bar"; declares AI tools[] (8) — AI extensions not supported; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; openExtensionPreferences: no-op; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review); @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:MutatePromise (not implemented in Invoke)

### `apply-inline-code` — Apply Inline Code
- dir: `apply-inline-code` · commands: 2 · modes: no-view|view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getApplications: throws — application discovery not wired
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `appwrite` — Appwrite
- dir: `appwrite` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke); @raycast/utils:MutatePromise (not implemented in Invoke); @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `aranet-co2-monitor` — Aranet CO2 Monitor
- dir: `aranet-co2-monitor` · commands: 3 · modes: menu-bar|view
- **Blockers:** unsupported command mode(s): index: mode "menu-bar"
- Degraded: openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled

### `arc` — Arc
- dir: `arc` · commands: 16 · modes: view|no-view|menu-bar
- **Blockers:** getApplications: throws — application discovery not wired; showInFinder: throws — showInFinder not wired; launchCommand: launchCommand not implemented; getSelectedText: throws — selection APIs not wired; unsupported command mode(s): menu-bar: mode "menu-bar"; declares AI tools[] (12) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: openCommandPreferences: no-op; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke); @raycast/utils:getFavicon (not implemented in Invoke)

### `arca` — Arca
- dir: `arca` · commands: 3 · modes: view
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `archiver` — Archiver
- dir: `archiver` · commands: 4 · modes: view|no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `are-na` — Are.na
- dir: `are-na` · commands: 7 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; declares AI tools[] (7) — AI extensions not supported
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke)

### `asana` — Asana
- dir: `asana` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke); @raycast/utils:MutatePromise (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `ascii-art-wallpaper` — ASCII Art Wallpaper
- dir: `ascii-art-wallpaper` · commands: 3 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `asset-catalog-extractor` — Asset Catalog Extractor
- dir: `asset-catalog-extractor` · commands: 1 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs

### `at-profile` — @ Profile
- dir: `at-profile` · commands: 6 · modes: view|no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke); @raycast/utils:getFavicon (not implemented in Invoke)

### `atlassian-data-center` — Atlassian Data Center (Self-Hosted)
- dir: `atlassian-data-center` · commands: 8 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `atomic` — Atomic Data
- dir: `atomic` · commands: 1 · modes: view
- Needs review: @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:Preferences (not in Invoke surface — needs review); @raycast/api:PushAction (not in Invoke surface — needs review)

### `atproto-utilities` — AT Protocol Utilities
- dir: `atproto-utilities` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `audio-device` — Set Audio Device
- dir: `audio-device` · commands: 12 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: fs, https
- Degraded: openCommandPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled

### `audio-writer` — Audio Writer
- dir: `audio-writer` · commands: 3 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired

### `auto-quit-app` — Auto Quit App
- dir: `auto-quit-app` · commands: 2 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; getApplications: throws — application discovery not wired; getFrontmostApplication: throws — application discovery not wired; unsupported command mode(s): auto-quit-app-menubar: mode "menu-bar"
- Degraded: openCommandPreferences: no-op; openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled

### `autumn` — Autumn
- dir: `autumn` · commands: 3 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `avatar` — Avatar
- dir: `avatar` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openCommandPreferences: no-op

### `awesome-mac` — Awesome Mac
- dir: `awesome-mac` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: https
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `awork` — awork
- dir: `awork` · commands: 3 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; launchCommand: launchCommand not implemented; declares AI tools[] (4) — AI extensions not supported
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `aws` — Amazon AWS
- dir: `amazon-aws` · commands: 19 · modes: view
- **Blockers:** declares AI tools[] (10) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; captureException: no-op; confirmAlert: always returns false (no dialog); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke); @raycast/utils:MutatePromise (not implemented in Invoke)

### `aztu-lms` — AzTU LMS
- dir: `aztu-lms` · commands: 8 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `azure-icons` — Azure Icons
- dir: `azure-icons` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `azure-tts-raycast` — Azure Speech TTS
- dir: `azure-tts-raycast-extension` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; trash: throws — file trash not wired; denied Node built-ins in sandbox: child_process

### `backlog-md-manager` — Backlog.md Manager
- dir: `backlog-md-manager` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `backstage` — Backstage
- dir: `backstage` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `badges` — Badges - Shields.io
- dir: `badges` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `baidu-ocr` — Baidu OCR
- dir: `baidu-ocr` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `bamboo-self-hosted` — Bamboo Search (Self Hosted)
- dir: `bamboo-search-self-hosted` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: https

### `bamboohr` — BambooHR
- dir: `bamboohr` · commands: 4 · modes: view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: declares background `interval` command(s) — not scheduled

### `bambu-lab` — Bambu Lab Controller
- dir: `bambu-lab` · commands: 2 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `banca-d-italia-currency-converter` — Banca d'Italia Currency Converter
- dir: `banca-d-italia-currency-converter` · commands: 1 · modes: view
- Needs review: @raycast/api:getLocalStorageItem (not in Invoke surface — needs review); @raycast/api:setLocalStorageItem (not in Invoke surface — needs review); @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `barassistant` — Bar Assistant
- dir: `barassistant` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `barcuts-companion` — BarCuts Companion
- dir: `barcuts-companion` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `bark` — Bark
- dir: `bark` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process
- Degraded: openCommandPreferences: no-op; openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet

### `bartender` — Bartender
- dir: `bartender` · commands: 4 · modes: no-view|view
- **Blockers:** declares AI tools[] (4) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openCommandPreferences: no-op; confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke); @raycast/utils:useLocalStorage (not implemented in Invoke); @raycast/utils:createDeeplink (not implemented in Invoke); @raycast/utils:DeeplinkType (not implemented in Invoke)

### `base-stats` — Base Stats
- dir: `base-stats` · commands: 2 · modes: menu-bar
- **Blockers:** unsupported command mode(s): gas-price: mode "menu-bar", gas-price-no-unit: mode "menu-bar"
- Degraded: openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled

### `base-ui-docs` — Base UI Components
- dir: `base-ui-docs` · commands: 1 · modes: view
- Needs review: @raycast/utils:withCache (not implemented in Invoke)

### `base64` — Base64
- dir: `base64` · commands: 3 · modes: view|no-view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported

### `base64-to-file` — Base64 to File
- dir: `base64-to-file` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `bash-commands` — Bash Commands
- dir: `bash-commands` · commands: 1 · modes: view
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `battery-menubar` — Battery Menu Bar
- dir: `battery-menubar` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): index: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: declares background `interval` command(s) — not scheduled

### `battery-optimizer` — Battery Optimizer
- dir: `battery-optimizer` · commands: 5 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): battery_optimizer_menu_bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled

### `bazinga-tools` — Bazinga Tools
- dir: `bazinga-tools` · commands: 1 · modes: view
- Needs review: @raycast/api:ToastStyle (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review)

### `bear` — Bear Notes
- dir: `bear` · commands: 4 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar: mode "menu-bar"; declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: openCommandPreferences: no-op; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `beehiiv` — Beehiiv
- dir: `beehiiv` · commands: 4 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menubar-count-subscribers: mode "menu-bar", menubar-last-email: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled

### `beeper` — Beeper Desktop
- dir: `beeper` · commands: 6 · modes: view|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; declares AI tools[] (6) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:useFrecencySorting (not implemented in Invoke); @raycast/utils:useLocalStorage (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `bento-me` — Bento
- dir: `bento-me` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: https
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `beszel` — Beszel
- dir: `beszel-extension` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: openExtensionPreferences: no-op; declares extension-level `ai` instructions — ignored

### `better-aliases` — Better Aliases
- dir: `better-aliases` · commands: 11 · modes: view|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `better-uptime` — Better Uptime
- dir: `better-uptime` · commands: 6 · modes: view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `betteraudio` — BetterAudio
- dir: `betteraudio` · commands: 17 · modes: view|no-view|menu-bar
- **Blockers:** getApplications: throws — application discovery not wired; unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `betterdisplay` — BetterDisplay
- dir: `betterdisplay` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (14) — AI extensions not supported; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `betterzip` — BetterZip
- dir: `betterzip` · commands: 3 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog)

### `bhagavad-gita-quotes` — Bhagavad Gita Quotes
- dir: `bhagavad-gita-quotes` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired
- Degraded: openExtensionPreferences: no-op

### `biaodian` — Search Chinese Punctuation Marks
- dir: `biaodian` · commands: 1 · modes: view
- Needs review: @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review); @raycast/api:PasteAction (not in Invoke surface — needs review)

### `bible` — Bible
- dir: `bible` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `bibmanager` — Bibmanager
- dir: `bibmanager` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, readline

### `bike` — Bike
- dir: `bike` · commands: 13 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `bikeshare-station-status` — Bikeshare Station Status
- dir: `bikeshare-station-status` · commands: 2 · modes: view|menu-bar
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; unsupported command mode(s): favorite-stations: mode "menu-bar"
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `bilibili` — Bilibili
- dir: `Bilibili` · commands: 5 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:runPowerShellScript (not implemented in Invoke)

### `binance` — Binance Portfolio
- dir: `binance` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review); @raycast/api:preferences (not in Invoke surface — needs review)

### `binance-exchange` — Binance
- dir: `binance-exchange` · commands: 3 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): my-wallet-menu-bar: mode "menu-bar"
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; openCommandPreferences: no-op; openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled

### `bing-wallpaper` — Bing Wallpaper
- dir: `bing-wallpaper` · commands: 3 · modes: view|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled

### `biome` — Biome
- dir: `biome` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `bird` — Bird
- dir: `bird` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `bitcoin-price` — Bitcoin Price
- dir: `bitcoin-price` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): bitcoin-menu-bar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `bitly-url-shortener` — Bitly URL Shortener
- dir: `bitly-url-shortener` · commands: 2 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `bitwarden` — Bitwarden Vault
- dir: `bitwarden` · commands: 11 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented; showInFinder: throws — showInFinder not wired; getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process, http, https
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw; captureException: no-op; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `bj-share` — BJ-Share
- dir: `bj-share` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `bklit-analytics` — Bklit Analytics
- dir: `bklit-analytics` · commands: 2 · modes: menu-bar|view
- **Blockers:** unsupported command mode(s): top-countries-menubar: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled

### `blip-raycast` — Blip
- dir: `blip-raycast` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: child_process, fs

### `bluesky` — Bluesky
- dir: `bluesky` · commands: 7 · modes: menu-bar|view
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar-notifications: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet

### `blurhash` — BlurHash
- dir: `blurhash` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `bmrks` — (Basic) Bookmarks
- dir: `bmrks` · commands: 3 · modes: view
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `bmw` — BMW
- dir: `bmw` · commands: 12 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): car-overview: mode "menu-bar"
- Degraded: confirmAlert: always returns false (no dialog)

### `bobcontrol` — Bob - Control Bob Translate
- dir: `bob` · commands: 10 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `bonjour` — Bonjour
- dir: `bonjour` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `bonk-price` — BONK Price
- dir: `bonk-price` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): index: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `bootstrap-icons` — Bootstrap Icons
- dir: `bootstrap-icons` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: fs

### `braid` — Braid Design System
- dir: `braid` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `brand-dev` — Brand.dev
- dir: `brand-dev` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke); @raycast/utils:getFavicon (not implemented in Invoke)

### `brand-fetch` — Brandfetch
- dir: `brand-fetch` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `brave` — Brave
- dir: `brave` · commands: 5 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `brave-search-with-results` — Brave Search with Results
- dir: `brave-search-with-results` · commands: 2 · modes: view
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `brew` — Brew
- dir: `brew` · commands: 6 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke); @raycast/utils:MutatePromise (not implemented in Invoke)

### `brew-services` — Manage Services
- dir: `brew-services` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `brightness-control` — Brightness Control
- dir: `brightness-control` · commands: 4 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `browser-ai` — Browser AI Companion
- dir: `browser-ai` · commands: 5 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `browser-bookmarks` — Browser Bookmarks
- dir: `browser-bookmarks` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; getDefaultApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `browser-history` — Browser History
- dir: `browser-history` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: openCommandPreferences: no-op
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `browser-tabs` — Browser Tabs
- dir: `browser-tabs` · commands: 1 · modes: view
- **Blockers:** getDefaultApplication: throws — application discovery not wired; getFrontmostApplication: throws — application discovery not wired; getApplications: throws — application discovery not wired
- Degraded: openCommandPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; captureException: no-op
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke); @raycast/utils:getFavicon (not implemented in Invoke)

### `browsers-profiles` — Open Browsers Profiles
- dir: `browsers-profiles` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `brreg` — The Brønnøysund Register Centre Search
- dir: `brreg` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke); @raycast/utils:getFavicon (not implemented in Invoke)

### `bugmenot` — BugMeNot
- dir: `bugmenot` · commands: 1 · modes: view
- Needs review: @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review); @raycast/api:ListItem (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:PasteAction (not in Invoke surface — needs review)

### `builtbybit` — BuiltByBit
- dir: `builtbybit` · commands: 4 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): get-notifications: mode "menu-bar"
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `bunch` — Bunch
- dir: `bunch` · commands: 9 · modes: view|no-view
- **Blockers:** trash: throws — file trash not wired; getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: openCommandPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `bundles` — Bundles
- dir: `bundles` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:createDeeplink (not implemented in Invoke); @raycast/utils:getFavicon (not implemented in Invoke)

### `cache-control-builder` — Cache-Control Builder
- dir: `cache-control-builder` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `cal-com-share-meeting-links` — Cal.com
- dir: `cal-com-share-meeting-links` · commands: 5 · modes: view
- **Blockers:** declares AI tools[] (33) — AI extensions not supported
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openCommandPreferences: no-op; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:MutatePromise (not implemented in Invoke)

### `calendly` — Calendly Share Meeting Links
- dir: `calendly` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `calibre-library` — Calibre Library
- dir: `calibre-search` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `caltask` — CalTask
- dir: `caltask` · commands: 4 · modes: view|menu-bar
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `cangjie` — Cangjie Dictionary
- dir: `cangjie` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `canva` — Canva
- dir: `canva` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `capture-fullpage-of-website` — Capture Fullpage of Website
- dir: `capture-fullpage-of-website` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `capture-raycast-metadata` — Capture Raycast Metadata
- dir: `capture-raycast-metadata` · commands: 1 · modes: no-view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog)

### `caschys-blog` — Caschys Blog
- dir: `caschys-blog` · commands: 3 · modes: view|no-view
- **Blockers:** declares AI tools[] (4) — AI extensions not supported; denied Node built-ins in sandbox: https
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `ccf-what` — CCF What?
- dir: `ccf-what` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `ccusage` — Claude Code Usage (ccusage)
- dir: `ccusage` · commands: 3 · modes: view|menu-bar|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; unsupported command mode(s): menubar-ccusage: mode "menu-bar"; declares AI tools[] (5) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs, http
- Degraded: openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; openCommandPreferences: no-op; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled

### `cerebras` — Cerebras
- dir: `cerebras` · commands: 8 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; getFrontmostApplication: throws — application discovery not wired; getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: http, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review); @raycast/api:BrowserExtension (not in Invoke surface — needs review); @raycast/api:Navigation (not in Invoke surface — needs review)

### `certificate-viewer` — Certificate Viewer
- dir: `certificate-viewer` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: tls
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `chakra-ui-docs` — Chakra UI Documentation
- dir: `chakra-ui-docs` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `change-case` — Change Case
- dir: `change-case` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getSelectedText: throws — selection APIs not wired
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `changedetection-io` — ChangeDetection.io
- dir: `changedetection-io` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke); @raycast/utils:getFavicon (not implemented in Invoke)

### `charged` — Charged: Starknet Shortcuts
- dir: `charged` · commands: 7 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `charming-chatgpt` — Charming ChatGPT
- dir: `charming-chatgpt` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op

### `chartmogul` — ChartMogul
- dir: `chartmogul` · commands: 2 · modes: view
- **Blockers:** declares AI tools[] (13) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored

### `chatgo` — ChatGo
- dir: `chatgo` · commands: 6 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review); @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `chatgpt` — ChatGPT
- dir: `chatgpt` · commands: 10 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; getFrontmostApplication: throws — application discovery not wired; getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: http, fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review); @raycast/api:BrowserExtension (not in Invoke surface — needs review); @raycast/api:Navigation (not in Invoke surface — needs review)

### `chatgpt-atlas` — ChatGPT Atlas
- dir: `chatgpt-atlas` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke); @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `chatgpt-quick-actions` — ChatGPT Quick Actions
- dir: `chatgpt-quick-actions` · commands: 8 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `chatgpt-search` — ChatGPT Search
- dir: `chatgpt-search` · commands: 1 · modes: view
- **Blockers:** getDefaultApplication: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `chatwoot` — Chatwoot
- dir: `chatwoot` · commands: 7 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `chatwork-search` — Chatwork Search
- dir: `search-chatwork` · commands: 3 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Needs review: @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `cheatsheets-remastered` — Cheatsheets Remastered
- dir: `cheatsheets-remastered` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `checklist` — Checklist
- dir: `checklist` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `checksum` — Checksum
- dir: `checksum` · commands: 4 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menubar: mode "menu-bar"; denied Node built-ins in sandbox: fs

### `cheetah` — Cheetah
- dir: `cheetah` · commands: 7 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op

### `chiikawa-character` — Chiikawa Characters
- dir: `chiikawa-character` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `chinese-character` — Chinese Character
- dir: `chinese-character` · commands: 3 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `chronometer` — Chronometer
- dir: `chronometer` · commands: 4 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented

### `circle-ci` — CircleCI Workflows
- dir: `circle-ci` · commands: 1 · modes: view
- Needs review: @raycast/api:getLocalStorageItem (not in Invoke surface — needs review); @raycast/api:setLocalStorageItem (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review); @raycast/api:ImageLike (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:SubmitFormAction (not in Invoke surface — needs review); @raycast/api:PushAction (not in Invoke surface — needs review); @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review)

### `circleback` — Circleback
- dir: `circleback` · commands: 3 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Needs review: @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `claude` — Claude
- dir: `claude` · commands: 5 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `claude-code-config-switcher` — Claude Code Switcher
- dir: `claude-code-config-switcher` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `claude-code-launcher` — Claude Code Launcher
- dir: `claude-code-launcher` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `claude-sessions` — Claude Sessions
- dir: `claude-sessions` · commands: 2 · modes: view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: fs, child_process
- Needs review: @raycast/api:useState (not in Invoke surface — needs review); @raycast/api:useEffect (not in Invoke surface — needs review); @raycast/api:readdir (not in Invoke surface — needs review); @raycast/api:stat (not in Invoke surface — needs review); @raycast/utils:useState (not implemented in Invoke); @raycast/utils:useEffect (not implemented in Invoke)

### `claudecast` — ClaudeCast
- dir: `claudecast` · commands: 10 · modes: view|no-view|menu-bar
- **Blockers:** getSelectedText: throws — selection APIs not wired; getFrontmostApplication: throws — application discovery not wired; trash: throws — file trash not wired; launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar-monitor: mode "menu-bar"; denied Node built-ins in sandbox: fs, child_process, readline
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled

### `clean-keyboard` — Clean Keyboard
- dir: `clean-keyboard` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `clean-text` — Clean Text
- dir: `clean-text` · commands: 3 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getSelectedText: throws — selection APIs not wired

### `cleanshotx` — CleanShot X
- dir: `cleanshotx` · commands: 23 · modes: no-view|view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `cling` — Cling File Search
- dir: `cling` · commands: 2 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares command `arguments[]` — not passed by runtime yet

### `clip-swap` — Clip Swap
- dir: `clip-swap` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `clipmate` — Clipmate AI
- dir: `clipmate` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `clipmenu` — ClipMenu
- dir: `clipmenu` · commands: 1 · modes: menu-bar
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; unsupported command mode(s): index: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `clippyx` — CLIPPyX
- dir: `clippyx` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `clipsign` — Clipsign
- dir: `clipsign` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `clipyai` — Clipyai
- dir: `clipyai` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `clockify` — Clockify
- dir: `clockify` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): clockifymenu: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled

### `clockodo` — Clockodo
- dir: `clockodo` · commands: 8 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented; declares AI tools[] (3) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:withCache (not implemented in Invoke)

### `close-apps` — Close All Open Apps
- dir: `close-apps` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `cloud-cli-login-statuses` — Cloud CLI Login Statuses
- dir: `cloud-cli-login-statuses` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `cloudflare` — Cloudflare
- dir: `cloudflare` · commands: 4 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `cloudflare-warp` — Cloudflare WARP
- dir: `cloudflare-warp` · commands: 3 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `cloudstash` — Cloudstash
- dir: `cloudstash` · commands: 2 · modes: no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cmux` — cmux
- dir: `cmux` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `cobalt` — Cobalt
- dir: `cobalt` · commands: 2 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op

### `cocart-docs` — CoCart Docs
- dir: `cocart-docs` · commands: 8 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `cocktail-db` — Cocktail DB
- dir: `cocktail-db` · commands: 2 · modes: view
- Degraded: openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `code` — Code Execution
- dir: `code-execution` · commands: 1 · modes: no-view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: child_process
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `code-quarkus` — Code Quarkus
- dir: `code-quarkus` · commands: 2 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: openCommandPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `code-runway` — Code Runway
- dir: `code-runway` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `code-saver` — Code Saver
- dir: `code-saver` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, https
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `code-stash` — Code Stash
- dir: `code-stash` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `code-wiki` — Code Wiki
- dir: `code-wiki` · commands: 2 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `codeblocks` — CodeBlocks
- dir: `CodeBlocks` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `codeforces-extension` — Codeforces
- dir: `codeforces-extension` · commands: 4 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): upcoming-contest: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `codegeex` — CodeGeex
- dir: `codegeex` · commands: 5 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `codegrepper` — Code Grepper
- dir: `codegrepper` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: https

### `codemagic` — Codemagic
- dir: `codemagic` · commands: 2 · modes: view
- Degraded: openExtensionPreferences: no-op
- Needs review: @raycast/api:ImageMask (not in Invoke surface — needs review)

### `codex-manager` — Codex Manager
- dir: `codex-manager` · commands: 3 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; launchCommand: launchCommand not implemented; trash: throws — file trash not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `coffee` — Coffee
- dir: `coffee` · commands: 9 · modes: no-view|view|menu-bar
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; launchCommand: launchCommand not implemented; unsupported command mode(s): index: mode "menu-bar"; declares AI tools[] (6) — AI extensions not supported; denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `coinbase-pro` — Coinbase Pro
- dir: `coinbase-pro` · commands: 1 · modes: view
- Needs review: @raycast/api:preferences (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:ImageMask (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `coinmarketcap-crypto-price-crawler` — Coinmarketcap Crypto Search
- dir: `coinmarketcap-crypto-crawler` · commands: 3 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:ToastStyle (not in Invoke surface — needs review); @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `colima` — Colima
- dir: `colima` · commands: 5 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `color-casket` — Color Casket
- dir: `color-casket` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; launchCommand: launchCommand not implemented
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `color-hunt` — Color Hunt
- dir: `color-hunt` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `color-picker` — Color Picker
- dir: `color-picker` · commands: 8 · modes: no-view|view|menu-bar
- **Blockers:** getSelectedText: throws — selection APIs not wired; getSelectedFinderItems: throws — Finder selection not wired; AI: AI.ask throws — Invoke AI not yet wired; launchCommand: launchCommand not implemented; getFrontmostApplication: throws — application discovery not wired; unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw; openCommandPreferences: no-op; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `color-studio-picker` — Color Studio Picker
- dir: `color-studio-picker` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `colorify` — Colorify - Generate Themes From Images
- dir: `colorify` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: fs

### `colorslurp` — ColorSlurp
- dir: `colorslurp` · commands: 7 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `comet` — Comet
- dir: `comet` · commands: 7 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; declares AI tools[] (4) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: openExtensionPreferences: no-op; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke); namespace import of @raycast/api (member usage unverified)

### `cometapi` — CometAPI
- dir: `cometapi` · commands: 7 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `commit-message-formatter` — Commit Message Formatter
- dir: `commit-message-formatter` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `commitlint` — CommitLint
- dir: `commitlint` · commands: 1 · modes: view
- Needs review: @raycast/api:copyTextToClipboard (not in Invoke surface — needs review); @raycast/api:SubmitFormAction (not in Invoke surface — needs review)

### `common-directory` — Common Directory
- dir: `common-directory` · commands: 3 · modes: view|menu-bar
- **Blockers:** showInFinder: throws — showInFinder not wired; getSelectedFinderItems: throws — Finder selection not wired; unsupported command mode(s): open-common-directory-menu-bar: mode "menu-bar"
- Degraded: openCommandPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `comodoro` — Comodoro
- dir: `comodoro` · commands: 3 · modes: menu-bar|no-view
- **Blockers:** unsupported command mode(s): get: mode "menu-bar"; denied Node built-ins in sandbox: fs, child_process
- Degraded: declares background `interval` command(s) — not scheduled

### `composerize` — Composerize
- dir: `composerize` · commands: 2 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; declares AI tools[] (2) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `compress-pdf` — Compress PDF
- dir: `compress-pdf` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, https

### `compressx` — Compresto
- dir: `compressx` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process

### `confluence` — Confluence
- dir: `confluence-search` · commands: 8 · modes: view|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `connect-to-vpn` — Connect to VPN
- dir: `connect-to-vpn` · commands: 3 · modes: no-view|view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: declares background `interval` command(s) — not scheduled

### `contentful` — Contentful
- dir: `contentful` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `context7` — Context7
- dir: `context7` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:createDeeplink (not implemented in Invoke)

### `contexts` — Contexts
- dir: `contexts` · commands: 2 · modes: no-view|view
- **Blockers:** declares AI tools[] (6) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `conventional-comments` — Conventional Comments
- dir: `conventional-comments` · commands: 2 · modes: view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:FormValue (not in Invoke surface — needs review); @raycast/api:SubmitFormAction (not in Invoke surface — needs review); @raycast/api:pasteText (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `convert-3d-models` — Convert 3D Models
- dir: `convert-3d-models` · commands: 4 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: openCommandPreferences: no-op

### `convert-px-to-vw-vh` — Pixels to Viewport Width or Height
- dir: `convert-px-to-vw-vh` · commands: 4 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; openCommandPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `convert-typescript-to-javascript` — Convert TypeScript to JavaScript
- dir: `convert-typescript-to-javascript` · commands: 2 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `coolify` — Coolify
- dir: `coolify` · commands: 5 · modes: view
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `copee` — Copee
- dir: `copee` · commands: 3 · modes: no-view
- **Blockers:** showInFinder: throws — showInFinder not wired; getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs

### `copilot-workspace` — Copilot Workspace
- dir: `copilot-workspace` · commands: 2 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `copy-gcp-icons` — Copy GCP Icons
- dir: `copy-gcp-icons` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `copy-notion-markdown-link` — Copy Notion Markdown Link
- dir: `copy-notion-markdown-link` · commands: 1 · modes: no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

### `copy-path` — Copy Path
- dir: `copy-path` · commands: 1 · modes: no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getSelectedFinderItems: throws — Finder selection not wired; updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: captureException: no-op

### `copy-text-files` — Copy Text Files
- dir: `copy-text-files` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Needs review: @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `copymoveto` — CopyMoveTo
- dir: `copymoveto` · commands: 3 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog)

### `copyq-clipboard-manager` — CopyQ Clipboard Manager
- dir: `copyq-clipboard-manager` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: openExtensionPreferences: no-op

### `corcel` — Corcel AI
- dir: `corcel` · commands: 4 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `cosmic-bookmarks` — Cosmic Bookmarks
- dir: `cosmic-bookmarks` · commands: 3 · modes: view|no-view|menu-bar
- **Blockers:** getSelectedText: throws — selection APIs not wired; unsupported command mode(s): menubar: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled

### `counter` — Counter
- dir: `counter` · commands: 3 · modes: no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; launchCommand: launchCommand not implemented

### `coze` — Coze
- dir: `coze` · commands: 3 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/api:fetch (not in Invoke surface — needs review); @raycast/utils:useLocalStorage (not implemented in Invoke)

### `cpanel` — cPanel
- dir: `cpanel` · commands: 7 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke); @raycast/utils:getFavicon (not implemented in Invoke)

### `craft-cms-docs` — Craft CMS
- dir: `craft-cms-docs` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `craftdocs` — Craft
- dir: `craftdocs` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw; confirmAlert: always returns false (no dialog)
- Needs review: namespace import of @raycast/api (member usage unverified)

### `crawldoc` — CrawlDoc - Documentations Search Engine
- dir: `crawldoc` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: https
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; openExtensionPreferences: no-op

### `create-link` — Create Link
- dir: `create-link` · commands: 5 · modes: no-view|view
- Degraded: openExtensionPreferences: no-op
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `create-remix` — Create Remix
- dir: `raycast-create-remix` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: openCommandPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `create-t3-app` — Create T3 App
- dir: `create-t3-app` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: openCommandPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `creem` — Creem
- dir: `creem` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `cricketcast` — CricketCast
- dir: `cricketcast` · commands: 3 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): scores-menu-bar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `croc-transfer` — Croc Transfer
- dir: `croc-transfer` · commands: 4 · modes: view|no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `cron` — Cron
- dir: `cron` · commands: 2 · modes: view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: openExtensionPreferences: no-op
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `cron-manager` — Cron Manager
- dir: `cron-manager` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `crossbell` — Crossbell
- dir: `crossbell` · commands: 5 · modes: no-view|view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op

### `crypto-portfolio-tracker` — Crypto Portfolio Tracker
- dir: `crypto-portfolio-tracker` · commands: 2 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:withCache (not implemented in Invoke)

### `crypto-price` — Crypto Price
- dir: `crypto-price` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled

### `csfd` — ČSFD
- dir: `csfd` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `css-gg` — CSS.GG
- dir: `css-gg` · commands: 2 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `csv-to-excel` — Convert CSV to Excel
- dir: `csv-to-excel` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `cta` — CTA - Chicago Transit Authority
- dir: `cta` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `curl` — cURL
- dir: `curl` · commands: 2 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Navigation (not in Invoke surface — needs review)

### `cursor-agents` — Cursor Agents
- dir: `cursor-agents` · commands: 3 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar: mode "menu-bar"; declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares extension-level `ai` instructions — ignored

### `cursor-costs` — Cursor Costs
- dir: `cursor-costs` · commands: 2 · modes: menu-bar|view
- **Blockers:** unsupported command mode(s): cursor-costs-menu: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled

### `cursor-directory` — Cursor Directory
- dir: `cursor-directory` · commands: 3 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `cursor-recent-projects` — Cursor
- dir: `cursor-recent-projects` · commands: 5 · modes: view|no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog)

### `custom-folder` — Custom Folder
- dir: `custom-folder` · commands: 4 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `custom-icon` — Custom Icon
- dir: `custom-icon` · commands: 2 · modes: view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `cut-out` — Cut Out
- dir: `cut-out` · commands: 2 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: captureException: no-op

### `cyberchef` — CyberChef
- dir: `cyberchef` · commands: 62 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `cyberduck` — Cyberduck
- dir: `cyberduck` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs

### `cyberpanel` — CyberPanel
- dir: `cyberpanel` · commands: 9 · modes: no-view|view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `dagster` — Dagster
- dir: `dagster` · commands: 4 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; declares AI tools[] (7) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `daily-sites` — Daily Sites - Site Launcher
- dir: `daily-sites` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/utils:getFavicon (not implemented in Invoke)

### `dash` — Dash
- dir: `dash` · commands: 3 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `dash-off` — Dash Off
- dir: `dash-off` · commands: 2 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired; launchCommand: launchCommand not implemented; OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `dashlane-vault` — Dashlane Vault
- dir: `dashlane-vault` · commands: 4 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; confirmAlert: always returns false (no dialog); captureException: no-op; openExtensionPreferences: no-op
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke); @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `databuddy` — Databuddy
- dir: `databuddy` · commands: 7 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `datafast` — Datafast
- dir: `datafast` · commands: 7 · modes: view|menu-bar
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar-realtime: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `day-one` — Day One
- dir: `day-one` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `days-until-christmas` — Days Until Christmas
- dir: `days-until-christmas` · commands: 2 · modes: no-view|menu-bar
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `days2` — Days 2 - Google Calendar Countdown
- dir: `days2` · commands: 3 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; launchCommand: launchCommand not implemented
- Degraded: openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `db-schema-explorer` — DB Schema Explorer
- dir: `db-schema-explorer` · commands: 3 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: fs

### `debank` — debank
- dir: `debank` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:ActionPanelItem (not in Invoke surface — needs review); @raycast/api:AlertActionStyle (not in Invoke surface — needs review); @raycast/api:ListSection (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:SubmitFormAction (not in Invoke surface — needs review); @raycast/api:setLocalStorageItem (not in Invoke surface — needs review); @raycast/api:getLocalStorageItem (not in Invoke surface — needs review); @raycast/api:removeLocalStorageItem (not in Invoke surface — needs review)

### `deepcast` — Deepcast
- dir: `deepcast` · commands: 33 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; launchCommand: launchCommand not implemented
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `deepl-api-usage` — DeepL API Usage
- dir: `deepl-api-usage` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `deepseeker` — Deepseek Quick Actions
- dir: `deepseeker` · commands: 12 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet

### `deepwiki` — DeepWiki
- dir: `deepwiki` · commands: 3 · modes: no-view|view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review); @raycast/utils:LaunchProps (not implemented in Invoke); @raycast/utils:open (not implemented in Invoke); @raycast/utils:Action (not implemented in Invoke); @raycast/utils:ActionPanel (not implemented in Invoke); @raycast/utils:Icon (not implemented in Invoke); @raycast/utils:launchCommand (not implemented in Invoke); @raycast/utils:LaunchType (not implemented in Invoke); @raycast/utils:List (not implemented in Invoke); @raycast/utils:showToast (not implemented in Invoke); @raycast/utils:Toast (not implemented in Invoke)

### `default-web-browser-manager` — Default Web Browser Manager
- dir: `default-web-browser-manager` · commands: 2 · modes: view|no-view
- **Blockers:** getDefaultApplication: throws — application discovery not wired; denied Node built-ins in sandbox: child_process

### `defbro` — Defbro
- dir: `defbro` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `definitelytyped` — DefinitelyTyped
- dir: `definitelytyped` · commands: 1 · modes: view
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `defuddle` — Defuddle
- dir: `defuddle` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `delivery-tracker` — Delivery Tracker
- dir: `delivery-tracker` · commands: 4 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `demo-flow` — Demo Flow
- dir: `demo-flow` · commands: 5 · modes: view|no-view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `deno-deploy` — Deno Deploy
- dir: `deno-deploy` · commands: 4 · modes: view|no-view
- **Blockers:** declares AI tools[] (6) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `descript-to-youtube-chapters` — Descript to YouTube Chapters
- dir: `descript-to-youtube-chapters` · commands: 1 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs

### `design-skills` — Design Skills
- dir: `design-skills` · commands: 1 · modes: view
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `desktop-manager` — Desktop Manager
- dir: `desktop-manager` · commands: 6 · modes: view|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired; trash: throws — file trash not wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog)

### `desktoprenamer` — DesktopRenamer
- dir: `desktoprenamer` · commands: 10 · modes: no-view|view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; getApplications: throws — application discovery not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `deta-space` — Deta Space
- dir: `deta-space` · commands: 5 · modes: view
- Needs review: @raycast/utils:CachedPromiseOptions (not implemented in Invoke)

### `dev-cache-cleaner` — Dev Cache Cleaner
- dir: `dev-cache-cleaner` · commands: 3 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog); declares background `interval` command(s) — not scheduled

### `dev-servers` — Dev Servers
- dir: `dev-servers` · commands: 2 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; getFrontmostApplication: throws — application discovery not wired; getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `devdocs` — DevDocs
- dir: `devdocs` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `devonthink` — DEVONthink
- dir: `devonthink` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired

### `devutils` — DevUtils
- dir: `devutils` · commands: 41 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired

### `dia` — Dia
- dir: `dia` · commands: 7 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `dice-and-coin` — Dice & Coin
- dir: `dice-and-coin` · commands: 3 · modes: no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: openExtensionPreferences: no-op

### `dicom` — DICOM
- dir: `dicom` · commands: 1 · modes: view
- Needs review: @raycast/utils:useStreamJSON (not implemented in Invoke)

### `dict-cc` — dict.cc
- dir: `dict-cc` · commands: 3 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs, https

### `dictionary` — Web Dictionaries
- dir: `dictionary` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `diff-view` — Diff View
- dir: `diff-view` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `digger` — Digger
- dir: `digger` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: dns, tls
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review); @raycast/utils:getProgressIcon (not implemented in Invoke); @raycast/utils:getFavicon (not implemented in Invoke)

### `digitalocean` — DigitalOcean
- dir: `digitalocean` · commands: 7 · modes: view
- Degraded: openExtensionPreferences: no-op
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `directadmin-reseller` — DirectAdmin Reseller
- dir: `directadmin-reseller` · commands: 6 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `discord` — Discord
- dir: `discord` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `discord-timestamps` — Discord Timestamps
- dir: `discord-timestamps` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

### `discussite` — Discussite
- dir: `discussite` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `disk-usage` — Disk Usage
- dir: `disk-usage` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs, child_process, readline
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `diskutil` — Disk Utility
- dir: `diskutil` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `diskutil-mac` — Diskutil
- dir: `diskutil-mac` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog)

### `display-input-switcher` — Display Input Switcher
- dir: `display-input-switcher` · commands: 3 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `display-modes` — Display Modes
- dir: `display-modes` · commands: 3 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): display-modes-status-menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `displayplacer` — Display Placer
- dir: `displayplacer` · commands: 7 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `distraction-tracker` — Distraction Tracker
- dir: `distraction-tracker` · commands: 2 · modes: view
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `dlmoji` — DLmoji
- dir: `dlmoji` · commands: 1 · modes: view
- Needs review: @raycast/api:Component (not in Invoke surface — needs review); @raycast/api:Fragment (not in Invoke surface — needs review); @raycast/api:checkEmojiOnly (not in Invoke surface — needs review); @raycast/api:preferences (not in Invoke surface — needs review)

### `dnb-book-lookup` — DNB Book Lookup
- dir: `dnb-book-lookup` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `do-not-disturb` — Do Not Disturb
- dir: `do-not-disturb` · commands: 4 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `doccheck` — DocCheck
- dir: `doccheck` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `dock` — Dock
- dir: `dock` · commands: 4 · modes: no-view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): move-dock: mode "menu-bar"

### `dock-tinker` — Dock Tinker
- dir: `dock-tinker` · commands: 12 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet

### `docker` — Docker
- dir: `docker` · commands: 3 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `dockit` — DocKit - Document Toolkit
- dir: `dockit` · commands: 3 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `docklock-plus` — DockLock Plus
- dir: `docklock-plus` · commands: 8 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `doge-tracker` — Department of Government Efficiency Tracker
- dir: `doge-tracker` · commands: 4 · modes: view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented

### `dokploy` — Dokploy
- dir: `dokploy` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `dolar-cripto-ar` — DolarCripto AR
- dir: `dolar-cripto-ar` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): index: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `domainr` — Fastly Domain Search
- dir: `domainr` · commands: 1 · modes: view
- Degraded: openCommandPreferences: no-op
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `done-bear` — Done Bear
- dir: `done-bear` · commands: 10 · modes: view|menu-bar
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; unsupported command mode(s): menu-bar-today: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `doorstopper` — Doorstopper
- dir: `doorstopper` · commands: 5 · modes: no-view|menu-bar
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; launchCommand: launchCommand not implemented; unsupported command mode(s): statusmenu: mode "menu-bar"; denied Node built-ins in sandbox: child_process

### `dot-new` — dot-new
- dir: `dot-new` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `dot-underscore-files-cleaner` — Dot Underscore Files Cleaner
- dir: `dot-underscore-files-cleaner` · commands: 1 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog)

### `dota-2` — Dota 2
- dir: `dota-2` · commands: 2 · modes: view
- Needs review: @raycast/api:useState (not in Invoke surface — needs review); @raycast/api:useEffect (not in Invoke surface — needs review); @raycast/api:useMemo (not in Invoke surface — needs review)

### `dotmate` — Dotmate
- dir: `dotmate` · commands: 5 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: fs

### `doubao-tts` — Doubao TTS
- dir: `doubao-tts` · commands: 4 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: openExtensionPreferences: no-op

### `doutu` — DouTu
- dir: `doutu` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `dovetail` — Dovetail
- dir: `dovetail` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `downloads-manager` — Downloads Manager
- dir: `downloads-manager` · commands: 7 · modes: view|no-view
- **Blockers:** trash: throws — file trash not wired; showInFinder: throws — showInFinder not wired; declares AI tools[] (6) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `drafts` — Drafts
- dir: `drafts` · commands: 18 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; getApplications: throws — application discovery not wired; declares AI tools[] (9) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `dreamhost` — DreamHost
- dir: `dreamhost` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `dropover` — Dropover
- dir: `dropover` · commands: 2 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: child_process, fs

### `dropshare` — Dropshare
- dir: `dropshare` · commands: 6 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `drupal-toolbox` — Drupal Toolbox
- dir: `drupal-toolbox` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `dtf` — DTF
- dir: `dtf` · commands: 8 · modes: view|menu-bar
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar: mode "menu-bar"; declares AI tools[] (6) — AI extensions not supported
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `duan-raycast-extension` — Duan: Shorten and Manage Links
- dir: `duan-raycast-extension` · commands: 2 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw

### `dub` — Dub
- dir: `dub` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; getSelectedText: throws — selection APIs not wired; declares AI tools[] (6) — AI extensions not supported
- Degraded: confirmAlert: always returns false (no dialog); captureException: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:MutatePromise (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `duck-duck-go-search` — DuckDuckGo Search
- dir: `duck-duck-go-search` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `duck-facts` — Duck Facts
- dir: `duck-facts` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored

### `duckduckgo-image-search` — DuckDuckGo Image Search
- dir: `duckduckgo-image-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `dungeons-dragons` — Dungeons & Dragons
- dir: `dungeons-and-dragons` · commands: 6 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `dust-tt` — Ask Dust
- dir: `dust-tt` · commands: 6 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; launchCommand: launchCommand not implemented; OAuth: OAuth.PKCEClient throws — OAuth not yet wired; updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `e2b` — E2B Code Interpreter
- dir: `e2b` · commands: 1 · modes: no-view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `eagle` — Eagle
- dir: `eagle` · commands: 6 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `easy-invoice` — Easy Invoice
- dir: `easy-invoice` · commands: 4 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; trash: throws — file trash not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `easy-new-file` — Easy New File
- dir: `easy-new-file` · commands: 3 · modes: no-view|view
- **Blockers:** launchCommand: launchCommand not implemented; showInFinder: throws — showInFinder not wired; getSelectedFinderItems: throws — Finder selection not wired; getSelectedText: throws — selection APIs not wired
- Degraded: openCommandPreferences: no-op; openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `easy-ocr` — Easy OCR
- dir: `easy-ocr` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `easydict` — Easy Dictionary
- dir: `easydict` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: openCommandPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `easyvariable` — Easy Variable
- dir: `easyvariable` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired

### `edgestore-raycast` — EdgeStore
- dir: `edgestore-raycast` · commands: 3 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: https, fs
- Degraded: confirmAlert: always returns false (no dialog)

### `effect-docs` — Effect Docs
- dir: `effect-docs` · commands: 2 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (2) — AI extensions not supported
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `element` — Element
- dir: `element` · commands: 2 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired
- Needs review: @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `elevenlabs-tts` — ElevenLabs TTS
- dir: `elevenlabs-tts` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process, fs

### `elgato-key-light` — Elgato Key Light
- dir: `elgato-key-light` · commands: 7 · modes: no-view|view
- **Blockers:** declares AI tools[] (7) — AI extensions not supported
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `elm-search` — Elm Search
- dir: `elm-search` · commands: 2 · modes: view
- Needs review: @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review); @raycast/api:allLocalStorageItems (not in Invoke surface — needs review); @raycast/api:setLocalStorageItem (not in Invoke surface — needs review)

### `emoji` — Emoji Search
- dir: `emoji` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `emoji-kitchen` — Emoji Mashups
- dir: `emoji-kitchen` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `emojify` — Emojify
- dir: `emojify` · commands: 2 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `emojis-com` — emojis.com
- dir: `emojis-com` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `empty-screenshots` — Empty Screenshot Folder
- dir: `empty-screenshots` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `encoding-tools` — Encoding Tools
- dir: `encoding-tools` · commands: 7 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `ensk-is` — Ensk.is
- dir: `ensk-is` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `ente-auth` — Ente Auth
- dir: `ente-auth` · commands: 4 · modes: view|no-view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: child_process
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke); @raycast/utils:getProgressIcon (not implemented in Invoke); @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `envato` — Envato Sales, Purchases and Search
- dir: `envato` · commands: 5 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `epim` — Entra PIM Role
- dir: `epim` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `espanso` — Espanso
- dir: `espanso` · commands: 5 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `essay` — Essay
- dir: `essay` · commands: 3 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:withCache (not implemented in Invoke)

### `esse-actions` — Esse Actions
- dir: `esse-actions` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `ethereum-gas-tracker` — Ethereum Gas Tracker
- dir: `ethereum-gas-tracker` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): ethereum-gas-tracker: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `ethereum-price` — Ethereum Price
- dir: `ethereum-price` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): eth-menu-bar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `ethereum-utils` — Ethereum Utils — EVM Development
- dir: `ethereum-utils` · commands: 9 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `ets2-ats-profiles` — ETS2/ATS Profiles
- dir: `ets2-ats-profiles` · commands: 3 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; trash: throws — file trash not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `eudic` — Eudic
- dir: `eudic` · commands: 3 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `evaluate-math-expression` — Evaluate Math Expression
- dir: `evaluate-math-expression` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `everhour` — Everhour Time Tracking
- dir: `everhour` · commands: 3 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `evernote` — Evernote Instant Search
- dir: `evernote` · commands: 2 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs

### `everything-search` — Everything
- dir: `everything-search` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, https, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `evm-toolkit` — EVM Toolkit
- dir: `evm-toolkit` · commands: 11 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `exa-search` — Exa
- dir: `exa` · commands: 2 · modes: view|no-view
- **Blockers:** declares AI tools[] (5) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `exif` — Exif Viewer
- dir: `exif` · commands: 2 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `expand-video-canvas` — Expand Video Canvas
- dir: `expand-video-canvas` · commands: 1 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog)

### `expo` — Expo
- dir: `expo` · commands: 5 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/api:ImageMask (not in Invoke surface — needs review)

### `extend-display` — Extend Display
- dir: `extend-display` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `f1-standings` — Formula 1
- dir: `f1-standings` · commands: 3 · modes: view
- **Blockers:** declares AI tools[] (8) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `fabric` — Fabric
- dir: `fabric` · commands: 3 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Needs review: @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `fake-financial-data` — Fake Financial Data
- dir: `fake-financial-data` · commands: 5 · modes: no-view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar-commands: mode "menu-bar"

### `fake-typing-effect` — Fake Typing Effect
- dir: `fake-typing-effect` · commands: 3 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `fakecrime-upload` — Fakecrime Upload
- dir: `fakecrime-upload` · commands: 1 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired

### `fancy-text` — Fancy Text
- dir: `fancy-text` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: openExtensionPreferences: no-op

### `fantastical` — Fantastical
- dir: `fantastical` · commands: 4 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `farcaster` — Farcaster
- dir: `farcaster` · commands: 2 · modes: view
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `farrago` — Farrago
- dir: `farrago` · commands: 3 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs, dgram
- Degraded: openExtensionPreferences: no-op

### `fathom` — Fathom
- dir: `fathom` · commands: 2 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op

### `fathom-analytics-stats` — Fathom Analytics Stats
- dir: `fathom-analytics-stats` · commands: 9 · modes: view|menu-bar|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; unsupported command mode(s): current-visitors-menu-bar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `favoro` — FAVORO
- dir: `favoro` · commands: 3 · modes: view|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `feedbin` — Feedbin
- dir: `feedbin` · commands: 6 · modes: view|menu-bar|no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; launchCommand: launchCommand not implemented; updateCommandMetadata: menu-bar/command metadata updates not implemented; getSelectedText: throws — selection APIs not wired; unsupported command mode(s): unread-menu-bar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review); @raycast/utils:useAI (not implemented in Invoke); @raycast/utils:getFavicon (not implemented in Invoke); @raycast/utils:CachedPromiseOptions (not implemented in Invoke)

### `feishu-document-creator` — Feishu Document Creator
- dir: `feishu-document-creator` · commands: 4 · modes: no-view
- **Blockers:** getDefaultApplication: throws — application discovery not wired

### `fetch-youtube-transcript` — Fetch YouTube Transcript
- dir: `fetch-youtube-transcript` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ffmpeg` — FFmpeg - View, Analyze and Manipulate
- dir: `ffmpeg` · commands: 1 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw; declares extension-level `ai` instructions — ignored

### `fifteen-million-merits` — Fifteen Million Merits
- dir: `fifteen-million-merits` · commands: 2 · modes: menu-bar|no-view
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): show-ai-agent-sessions-counter: mode "menu-bar"; denied Node built-ins in sandbox: fs, child_process
- Degraded: declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `figlet` — FIGlet
- dir: `figlet` · commands: 2 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `figma-files-raycast-extension` — Figma File Search
- dir: `figma-files` · commands: 2 · modes: view|menu-bar
- **Blockers:** getApplications: throws — application discovery not wired; OAuth: OAuth.PKCEClient throws — OAuth not yet wired; unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `figma-link-cleaner` — Figma Link Cleaner
- dir: `figma-link-cleaner` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `file-info` — File Info
- dir: `file-info` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog)

### `file-manager` — File Manager
- dir: `file-manager` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `file-organizer` — File Organizer
- dir: `file-organizer` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog)

### `filemaker-snippets` — FileMaker Snippets
- dir: `filemaker-snippets` · commands: 7 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `files-shelf` — Files Shelf
- dir: `files-shelf` · commands: 5 · modes: no-view|view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `filezilla` — FileZilla
- dir: `filezilla` · commands: 3 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs

### `find-opengl-enum` — Find OpenGL Enum
- dir: `find-opengl-enum` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `find-website` — Find Website
- dir: `find-website` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `finder-file-actions` — Finder File Actions
- dir: `finder-file-actions` · commands: 5 · modes: view|no-view
- **Blockers:** trash: throws — file trash not wired; getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `finderutils` — Finder Utilities
- dir: `finderutils` · commands: 2 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `findnearby` — Google Maps Explorer
- dir: `findnearby` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `finicky-rule-manager` — Finicky Rule Manager
- dir: `finicky-rule-manager` · commands: 3 · modes: view
- **Blockers:** declares AI tools[] (5) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review); @raycast/utils:getFavicon (not implemented in Invoke)

### `fip` — Fip
- dir: `fip` · commands: 6 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: child_process

### `firebase-import-export` — Manage Firebase Firestore Collections
- dir: `firebase-import-export` · commands: 2 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog)

### `firebase-remote-config-admin` — Firebase - Remote Config
- dir: `firebase-remote-config-admin` · commands: 5 · modes: view
- **Blockers:** declares AI tools[] (10) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op

### `firecrawl` — Firecrawl
- dir: `firecrawl` · commands: 2 · modes: no-view|view
- **Blockers:** declares AI tools[] (4) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `firefox-tabs` — Firefox Tabs
- dir: `firefox-tabs` · commands: 2 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: child_process, fs
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke); @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `fisher` — Fisher
- dir: `fisher` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op

### `fitdesk` — FitDesk
- dir: `fitdesk` · commands: 4 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): exercise-reminder: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `fix-helper` — FIX Helper
- dir: `fix-helper` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: https, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `fix-language` — Fix Language
- dir: `fix-language` · commands: 3 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: openExtensionPreferences: no-op

### `fix-link-embeds` — Fix Link Embeds
- dir: `fix-link-embeds` · commands: 3 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `fizzy` — Fizzy
- dir: `fizzy` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `flashspace` — FlashSpace
- dir: `flashspace` · commands: 27 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `flaticon` — Flaticon — Search Icons
- dir: `flaticon` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `flibusta-search` — Flibusta Search
- dir: `flibusta-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op

### `flight-miles-calculator` — Flight Miles Calculator
- dir: `flight-miles-calculator` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:Form (not implemented in Invoke); @raycast/utils:Action (not implemented in Invoke); @raycast/utils:ActionPanel (not implemented in Invoke); @raycast/utils:Icon (not implemented in Invoke); @raycast/utils:useNavigation (not implemented in Invoke)

### `flighty` — Flighty
- dir: `flighty` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:useState (not in Invoke surface — needs review); @raycast/api:useEffect (not in Invoke surface — needs review); @raycast/utils:AsyncState (not implemented in Invoke); @raycast/utils:useState (not implemented in Invoke); @raycast/utils:useEffect (not implemented in Invoke)

### `floaty` — Floaty
- dir: `floaty` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:useCallback (not in Invoke surface — needs review); @raycast/api:useEffect (not in Invoke surface — needs review); @raycast/api:useMemo (not in Invoke surface — needs review); @raycast/api:useRef (not in Invoke surface — needs review); @raycast/api:useState (not in Invoke surface — needs review); @raycast/utils:useCallback (not implemented in Invoke); @raycast/utils:useEffect (not implemented in Invoke); @raycast/utils:useMemo (not implemented in Invoke); @raycast/utils:useRef (not implemented in Invoke); @raycast/utils:useState (not implemented in Invoke); @raycast/utils:Toast (not implemented in Invoke); @raycast/utils:closeMainWindow (not implemented in Invoke); @raycast/utils:showHUD (not implemented in Invoke); @raycast/utils:showToast (not implemented in Invoke)

### `flow` — Flow Timer
- dir: `flow` · commands: 10 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `flush-dns` — Flush DNS
- dir: `flush-dns` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog)

### `flutter-documentation-search` — Flutter Documentation Search
- dir: `flutter-documentation-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `flutter-utils` — Flutter Utils
- dir: `flutter-utils` · commands: 1 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `flycheck-raycast` — FlyCheck
- dir: `flycheck-raycast` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `focus` — Focus
- dir: `focus` · commands: 9 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; declares AI tools[] (4) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `focus-anchor` — Focus Anchor
- dir: `focus-anchor` · commands: 1 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `focus-flow` — Focusflow - a Study Clock
- dir: `focus-flow` · commands: 9 · modes: view|menu-bar|no-view
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares background `interval` command(s) — not scheduled

### `focustask` — FocusTask
- dir: `focustask` · commands: 3 · modes: menu-bar|view
- **Blockers:** unsupported command mode(s): current-menubar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:Action (not implemented in Invoke); @raycast/utils:ActionPanel (not implemented in Invoke); @raycast/utils:Form (not implemented in Invoke); @raycast/utils:Icon (not implemented in Invoke); @raycast/utils:popToRoot (not implemented in Invoke); @raycast/utils:showToast (not implemented in Invoke); @raycast/utils:Toast (not implemented in Invoke); @raycast/utils:open (not implemented in Invoke)

### `folder-cleaner` — Folder Cleaner
- dir: `folder-cleaner` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: captureException: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `folder-organizer` — Folder Organizer
- dir: `folder-organizer` · commands: 3 · modes: no-view|view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `folder-search` — Folder Search
- dir: `folder-search` · commands: 2 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; trash: throws — file trash not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `font-awesome` — Font Awesome
- dir: `fontawesome` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `font-converter` — Font Converter
- dir: `font-converter` · commands: 3 · modes: view|no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs

### `font-search` — Font Search
- dir: `font-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `font-sniper` — Font Sniper
- dir: `font-sniper` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `foodle-recipes` — Foodle Recipes
- dir: `foodle-recipes` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `fork-repositories` — Fork Repositories
- dir: `fork-repositories` · commands: 2 · modes: view|menu-bar
- **Blockers:** getApplications: throws — application discovery not wired; unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: openCommandPreferences: no-op

### `forked-extensions` — Forked Extensions
- dir: `forked-extensions` · commands: 1 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `forscore` — forScore
- dir: `forscore` · commands: 6 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `fotmob` — Fotmob
- dir: `fotmob` · commands: 10 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `foundry-cast-cli` — Foundry Cast CLI
- dir: `foundry-cast-cli` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `frame-crop-art` — Frame Crop - Discover Art for Your TV
- dir: `frame-crop` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `freeagent` — FreeAgent
- dir: `freeagent` · commands: 8 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; declares AI tools[] (25) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `freedns` — FreeDNS
- dir: `freedns` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `freesound` — Freesound
- dir: `freesound` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `french-company-search` — French Company Search
- dir: `french-company-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `frill` — Frill
- dir: `frill` · commands: 5 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `fronius-inverter` — Fronius Inverter
- dir: `fronius-inverter` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): watch: mode "menu-bar"

### `fuelix` — Fuelix
- dir: `fuelix` · commands: 16 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `fullscreentext` — Fullscreen Text
- dir: `fullscreentext` · commands: 3 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `fuzzy-file-search` — Fuzzy File Search
- dir: `fuzzy-file-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process, readline

### `fvm` — FVM
- dir: `fvm` · commands: 4 · modes: view|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares command `arguments[]` — not passed by runtime yet

### `g-cloud` — Google Cloud CLI
- dir: `g-cloud` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw; openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)

### `gather` — Gather
- dir: `gather` · commands: 4 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `gcp-ip-search` — Google Cloud Platform IP Search
- dir: `gcp-ip-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `gemini-cli` — Gemini CLI
- dir: `gemini-cli` · commands: 1 · modes: view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: fs, readline
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `gemini-tts` — Gemini TTS
- dir: `gemini-tts` · commands: 9 · modes: no-view|view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; getSelectedText: throws — selection APIs not wired; unsupported command mode(s): playback-status: mode "menu-bar"; denied Node built-ins in sandbox: fs, child_process
- Degraded: openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled

### `genius-lyrics` — Genius Lyrics
- dir: `genius-lyrics` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `geohash-encode-decode` — Geohash
- dir: `geohash-encode-decode` · commands: 2 · modes: view
- Needs review: @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:PushAction (not in Invoke surface — needs review)

### `geoping` — Geoping
- dir: `geoping` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `gerrit-code-review` — Gerrit Code Review
- dir: `gerrit-code-review` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: http, https
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `get-app-icon` — Get App Icon
- dir: `get-app-icon` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process, fs

### `get-favicon` — Get Favicon
- dir: `get-favicon` · commands: 3 · modes: no-view
- **Blockers:** showInFinder: throws — showInFinder not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `get-note` — GetNote
- dir: `get-note` · commands: 5 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; declares AI tools[] (14) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `get-ssh-key` — Get SSH Key
- dir: `get-ssh-key` · commands: 2 · modes: no-view|view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: fs

### `getcompress` — GetCompress
- dir: `getcompress` · commands: 3 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:runPowerShellScript (not implemented in Invoke)

### `getsound` — GetSound
- dir: `getsound` · commands: 3 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `gh-pic` — GHPic
- dir: `gh-pic` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `ghostty` — Ghostty
- dir: `ghostty` · commands: 7 · modes: no-view|view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op

### `ghq` — ghq
- dir: `ghq` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `gif-search` — GIF Search
- dir: `gif-search` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `git` — Git
- dir: `git` · commands: 6 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; getApplications: throws — application discovery not wired; AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review); @raycast/utils:getFavicon (not implemented in Invoke); @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `git-assistant` — Git Assistant
- dir: `git-assistant` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (21) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: openExtensionPreferences: no-op; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `git-batch-tools` — Git Batch Tools
- dir: `git-batch-tools` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `git-buddy` — Git Buddy
- dir: `git-buddy` · commands: 3 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: child_process

### `git-co-authors` — Git Co-Authors
- dir: `git-co-authors` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `git-profile` — Git Profile
- dir: `git-profile` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `git-repos` — Git Repos
- dir: `git-repos` · commands: 3 · modes: view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog)

### `git-worktrees` — Git Worktrees
- dir: `git-worktrees` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke); @raycast/utils:withCache (not implemented in Invoke)

### `gitcdn` — GitCDN
- dir: `gitcdn` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op

### `gitfox` — Gitfox Repositories
- dir: `gitfox` · commands: 3 · modes: view|menu-bar|no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: openCommandPreferences: no-op

### `github` — GitHub
- dir: `github` · commands: 20 · modes: view|menu-bar
- **Blockers:** showInFinder: throws — showInFinder not wired; launchCommand: launchCommand not implemented; unsupported command mode(s): unread-notifications: mode "menu-bar", my-issues-menu: mode "menu-bar", my-stats-menu: mode "menu-bar", my-pull-requests-menu: mode "menu-bar"; declares AI tools[] (15) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; openExtensionPreferences: no-op; captureException: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:Preferences (not in Invoke surface — needs review); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:MutatePromise (not implemented in Invoke); @raycast/utils:getFavicon (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `github-codespaces` — GitHub Codespaces
- dir: `github-codespaces` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): active-codespaces: mode "menu-bar"
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `github-copilot` — GitHub Copilot
- dir: `github-copilot` · commands: 5 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; OAuth: OAuth.PKCEClient throws — OAuth not yet wired; unsupported command mode(s): github-copilot-tasks: mode "menu-bar"; declares AI tools[] (2) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke)

### `github-for-enterprise` — GitHub Enterprise
- dir: `github-for-enterprise` · commands: 8 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): unread-notifications: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openCommandPreferences: no-op; openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:FormValues (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:MutatePromise (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `github-gist` — GitHub Gist
- dir: `github-gist` · commands: 2 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getSelectedText: throws — selection APIs not wired
- Degraded: openCommandPreferences: no-op; openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:MutatePromise (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `github-menu-bar` — GitHub Commits Menu
- dir: `github-menu-bar` · commands: 1 · modes: menu-bar
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; unsupported command mode(s): menu: mode "menu-bar"
- Degraded: openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled

### `github-repository-search` — GitHub Repository Search
- dir: `github-repository-search` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `github-review-requests` — GitHub Review Requests
- dir: `github-review-requests` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): actionablePullRequests: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `github-search` — GitHub Search
- dir: `github-search` · commands: 2 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; getDefaultApplication: throws — application discovery not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke); @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `github-status` — GitHub Status
- dir: `github-status` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored

### `github-trending` — GitHub Trending
- dir: `github-trending` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/api:KeyEquivalent (not in Invoke surface — needs review); @raycast/utils:Action (not implemented in Invoke); @raycast/utils:ActionPanel (not implemented in Invoke); @raycast/utils:Detail (not implemented in Invoke); @raycast/utils:Icon (not implemented in Invoke)

### `gitignore` — Gitignore
- dir: `gitignore` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `gitlab` — GitLab
- dir: `gitlab` · commands: 24 · modes: view|menu-bar|no-view
- **Blockers:** launchCommand: launchCommand not implemented; OAuth: OAuth.PKCEClient throws — OAuth not yet wired; unsupported command mode(s): todomenubar: mode "menu-bar", mrmenu: mode "menu-bar", issuemenu: mode "menu-bar"; declares AI tools[] (12) — AI extensions not supported; denied Node built-ins in sandbox: https, fs
- Degraded: confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `gitmoji` — Gitmoji Search
- dir: `gitmoji` · commands: 1 · modes: view
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `gitpod` — Gitpod
- dir: `gitpod` · commands: 4 · modes: view|menu-bar
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; getApplications: throws — application discovery not wired; launchCommand: launchCommand not implemented; unsupported command mode(s): menubar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:clearLocalStorage (not in Invoke surface — needs review); @raycast/utils:MutatePromise (not implemented in Invoke)

### `gles-to-malioc` — GLES to MaliOC
- dir: `gles-to-malioc` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `glide` — Glide
- dir: `glide` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `global-media-key` — Media Key Emulate
- dir: `global-media-key` · commands: 5 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `globalping` — Globalping
- dir: `globalping` · commands: 5 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `glossary` — Glossary
- dir: `glossary` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:pasteText (not in Invoke surface — needs review)

### `gmail` — Gmail
- dir: `gmail` · commands: 9 · modes: view|no-view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; OAuth: OAuth.PKCEClient throws — OAuth not yet wired; unsupported command mode(s): unreadmailsmenu: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: openCommandPreferences: no-op; confirmAlert: always returns false (no dialog); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `gmail-accounts` — Gmail Accounts
- dir: `gmail-accounts` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `gokapi` — Gokapi
- dir: `gokapi` · commands: 2 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog)

### `goodlinks` — GoodLinks
- dir: `goodlinks` · commands: 3 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired

### `google-books` — Google Books
- dir: `google-books` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `google-calendar` — Google Calendar
- dir: `google-calendar` · commands: 5 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; declares AI tools[] (9) — AI extensions not supported
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:getFavicon (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:withCache (not implemented in Invoke); @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `google-calendar-quickadd` — Google Calendar Events Quick Add
- dir: `google-calendar-quickadd` · commands: 2 · modes: no-view|view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `google-chrome` — Google Chrome
- dir: `google-chrome` · commands: 10 · modes: view|no-view
- **Blockers:** declares AI tools[] (7) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke); namespace import of @raycast/api (member usage unverified)

### `google-chrome-profiles` — Google Chrome Profiles
- dir: `google-chrome-profiles` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `google-contacts` — Google Contacts
- dir: `google-contacts` · commands: 3 · modes: view|no-view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:getAvatarIcon (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `google-drive` — Google Drive
- dir: `google-drive` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: openExtensionPreferences: no-op

### `google-lens` — Google Lens
- dir: `google-lens` · commands: 1 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog)

### `google-maps-search` — Google Maps Search
- dir: `google-maps-search` · commands: 4 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `google-maven-repository` — Google Maven Repository
- dir: `google-maven-repository` · commands: 2 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `google-search` — Google Search
- dir: `google-search` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `google-tasks` — Google Tasks
- dir: `google-tasks` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `google-trends` — Google Trends
- dir: `google-trends` · commands: 2 · modes: view
- Needs review: @raycast/api:ImageMask (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `google-workspace` — Google Workspace
- dir: `google-workspace` · commands: 7 · modes: no-view|view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): starred-google-drive-files-menubar: mode "menu-bar"; declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:WithAccessTokenComponentOrFn (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `gopass` — Gopass
- dir: `gopass` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog)

### `govee` — Govee
- dir: `govee` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `gpu-fleet-monitor` — GPU Fleet Monitor
- dir: `gpu-fleet-monitor` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `gradient-generator` — Gradient Generator
- dir: `gradient-generator` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `grafana` — Grafana
- dir: `grafana` · commands: 7 · modes: view
- Needs review: @raycast/api:SubmitFormAction (not in Invoke surface — needs review); @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `gram` — Gram
- dir: `gram` · commands: 3 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog)

### `grammari-x` — Grammarix
- dir: `grammari-x` · commands: 4 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `grammaring` — Grammaring
- dir: `grammaring` · commands: 2 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `granola` — Granola
- dir: `granola` · commands: 7 · modes: view|no-view
- **Blockers:** declares AI tools[] (7) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:getFavicon (not implemented in Invoke)

### `graphcalc` — GraphCalc
- dir: `graphcalc` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `grok-ai` — Grok AI
- dir: `grok-ai` · commands: 3 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `groq` — Groq
- dir: `groq` · commands: 14 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `groq-tools` — GROQ Tools
- dir: `groq-tools` · commands: 3 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:ComponentType (not in Invoke surface — needs review); @raycast/api:SetStateAction (not in Invoke surface — needs review); @raycast/api:Dispatch (not in Invoke surface — needs review); @raycast/api:useState (not in Invoke surface — needs review); @raycast/api:useEffect (not in Invoke surface — needs review); @raycast/api:readFile (not in Invoke surface — needs review)

### `grpcui` — gRPC UI
- dir: `grpcui` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)

### `guitar-tools` — Guitar Tools
- dir: `guitar-tools` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `gumroad` — Gumroad Sales
- dir: `gumroad` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `gyazo-uploader` — Gyazo Uploader
- dir: `gyazo-uploader` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `habitica-todos` — Habitica ToDos
- dir: `habitica-todos` · commands: 7 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `habits` — SupaHabits
- dir: `supahabits` · commands: 5 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op

### `hacker-news` — Hacker News
- dir: `hacker-news` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares extension-level `ai` instructions — ignored

### `hacker-news-top-stories` — Hacker News Top Stories
- dir: `hacker-news-top-stories` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): view-top-stories: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `hackmd` — HackMD
- dir: `hackmd` · commands: 4 · modes: view
- **Blockers:** declares AI tools[] (8) — AI extensions not supported
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:useLocalStorage (not implemented in Invoke)

### `hakuna` — Hakuna
- dir: `hakuna` · commands: 9 · modes: view|menu-bar|no-view
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menubar: mode "menu-bar"
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `hammerspoon` — Hammerspoon
- dir: `hammerspoon` · commands: 10 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:useContext (not in Invoke surface — needs review); @raycast/api:useState (not in Invoke surface — needs review); @raycast/api:useMemo (not in Invoke surface — needs review); @raycast/utils:closeMainWindow (not implemented in Invoke); @raycast/utils:ActionPanel (not implemented in Invoke); @raycast/utils:List (not implemented in Invoke); @raycast/utils:Action (not implemented in Invoke); @raycast/utils:Icon (not implemented in Invoke); @raycast/utils:Color (not implemented in Invoke); @raycast/utils:getPreferenceValues (not implemented in Invoke); @raycast/utils:open (not implemented in Invoke); @raycast/utils:Application (not implemented in Invoke); @raycast/utils:showHUD (not implemented in Invoke); @raycast/utils:showToast (not implemented in Invoke); @raycast/utils:Toast (not implemented in Invoke); @raycast/utils:popToRoot (not implemented in Invoke); @raycast/utils:Detail (not implemented in Invoke); @raycast/utils:useContext (not implemented in Invoke); @raycast/utils:useState (not implemented in Invoke); @raycast/utils:useMemo (not implemented in Invoke)

### `handoff-toggle` — Handoff Toggle
- dir: `handoff-toggle` · commands: 2 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `handy` — Handy
- dir: `handy` · commands: 9 · modes: no-view|view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `hardcover` — Hardcover
- dir: `hardcover` · commands: 7 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `harmonic` — Harmonic
- dir: `harmonic` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `harpoon` — Harpoon
- dir: `harpoon` · commands: 6 · modes: no-view|view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:createDeeplink (not implemented in Invoke)

### `harvest` — Harvest
- dir: `harvest` · commands: 6 · modes: view|no-view|menu-bar
- **Blockers:** getApplications: throws — application discovery not wired; launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke); @raycast/utils:useLocalStorage (not implemented in Invoke)

### `haystack` — Haystack
- dir: `haystack` · commands: 4 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented; declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: captureException: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:useStreamJSON (not implemented in Invoke)

### `hazeover` — HazeOver Controls
- dir: `hazeover` · commands: 4 · modes: no-view|view
- Needs review: @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `hdri-library` — HDRI Library
- dir: `hdri-library` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `height` — Height
- dir: `height` · commands: 5 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; launchCommand: launchCommand not implemented; getApplications: throws — application discovery not wired
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:CachedPromiseOptions (not implemented in Invoke)

### `helium` — Helium
- dir: `helium` · commands: 6 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review); @raycast/utils:getFavicon (not implemented in Invoke); @raycast/utils:MutatePromise (not implemented in Invoke)

### `helldivers2` — Helldivers 2
- dir: `helldivers2` · commands: 4 · modes: view|no-view
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `hellonext-wallpapers` — Hellonext Wallpapers
- dir: `hellonext-wallpapers` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog)

### `helm-chart` — Helm Chart
- dir: `helm-chart` · commands: 1 · modes: view
- Needs review: @raycast/utils:Response (not implemented in Invoke)

### `heptabase` — Heptabase
- dir: `heptabase` · commands: 6 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `hermes-agent` — Hermes Agent
- dir: `hermes-agent` · commands: 6 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process, net
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `heroku` — Heroku
- dir: `heroku` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: https
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `hestiacp-admin` — HestiaCP Admin
- dir: `hestiacp-admin` · commands: 2 · modes: view
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `hetrixtools` — HetrixTools
- dir: `hetrixtools` · commands: 4 · modes: view
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `hetzner` — Hetzner
- dir: `hetzner` · commands: 3 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: confirmAlert: always returns false (no dialog)

### `hevy` — Hevy
- dir: `hevy` · commands: 2 · modes: view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored

### `hexlify` — Hexlify
- dir: `hexlify` · commands: 2 · modes: no-view
- Needs review: @raycast/api:ToastStyle (not in Invoke surface — needs review); @raycast/api:copyTextToClipboard (not in Invoke surface — needs review)

### `heyclaude` — HeyClaude
- dir: `heyclaude` · commands: 14 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `hidden-icons` — Hidden Icons
- dir: `hidden-icons` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: openCommandPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `hide-files` — Hide Files
- dir: `hide-files` · commands: 4 · modes: no-view|view
- **Blockers:** showInFinder: throws — showInFinder not wired; getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: child_process
- Degraded: openCommandPreferences: no-op; confirmAlert: always returns false (no dialog); captureException: no-op

### `hiit` — HIIT
- dir: `hiit` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `hijri-converter` — Hijri Converter
- dir: `hijri-converter` · commands: 5 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled

### `himalaya` — Himalaya
- dir: `himalaya` · commands: 3 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `hole-sandbox-launcher` — Hole Sandbox Launcher
- dir: `hole-sandbox-launcher` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process

### `homeassistant` — Home Assistant
- dir: `homeassistant` · commands: 43 · modes: view|no-view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): notificationmenu: mode "menu-bar", weathermenu: mode "menu-bar", mediaplayermenu: mode "menu-bar", lightsmenu: mode "menu-bar", coversmenu: mode "menu-bar", batteriesmenu: mode "menu-bar", entitiesmenu: mode "menu-bar", entitymenu01: mode "menu-bar", entitymenu02: mode "menu-bar", entitymenu03: mode "menu-bar", calendarmenu: mode "menu-bar"; declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: fs, https, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `homepage` — Homepage
- dir: `homepage` · commands: 2 · modes: view
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `homey` — Homey
- dir: `homey` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `hop` — Hop
- dir: `hop` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `host-switch` — Host Switch
- dir: `host-switch` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `hotcorner` — HotCorner
- dir: `hotcorner` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `hotel-manager` — Hotel Manager
- dir: `hotel-manager` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `houdahspot-search` — Search HoudahSpot
- dir: `houdahspot-search` · commands: 1 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `http-status-codes` — HTTP Status Codes
- dir: `http-status-codes` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: http

### `httpperf` — HTTP Performance Analyzer
- dir: `httpperf` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `hubspot` — HubSpot
- dir: `hubspot` · commands: 5 · modes: view
- Degraded: openExtensionPreferences: no-op
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke); @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `hubspot-portal-launcher` — HubSpot Portal Launcher
- dir: `hubspot-portal-launcher` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `hue` — Hue
- dir: `hue` · commands: 4 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; denied Node built-ins in sandbox: tls, https, net, fs, http2, dns
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `hugeicons-ui` — Hugeicons UI
- dir: `hugeicons-ui` · commands: 4 · modes: view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw

### `huggingcast` — Huggingcast
- dir: `huggingcast` · commands: 6 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:preferences (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review); @raycast/api:SubmitFormAction (not in Invoke surface — needs review); @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review); @raycast/api:PasteAction (not in Invoke surface — needs review)

### `hypersonic` — Hypersonic
- dir: `hypersonic` · commands: 2 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; OAuth: OAuth.PKCEClient throws — OAuth not yet wired; getApplications: throws — application discovery not wired; unsupported command mode(s): active-todos: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:TransparentEmpty (not in Invoke surface — needs review); @raycast/api:useDatabases (not in Invoke surface — needs review); @raycast/api:useFilter (not in Invoke surface — needs review); @raycast/api:useAuth (not in Invoke surface — needs review); @raycast/api:Tag (not in Invoke surface — needs review); @raycast/api:AuthorizationAction (not in Invoke surface — needs review); @raycast/api:OpenPreferencesAction (not in Invoke surface — needs review); @raycast/api:discord (not in Invoke surface — needs review); @raycast/api:figma (not in Invoke surface — needs review); @raycast/api:github (not in Invoke surface — needs review); @raycast/api:gitlab (not in Invoke surface — needs review); @raycast/api:linear (not in Invoke surface — needs review); @raycast/api:notion (not in Invoke surface — needs review); @raycast/api:slack (not in Invoke surface — needs review); @raycast/api:x (not in Invoke surface — needs review); @raycast/api:youtube (not in Invoke surface — needs review); @raycast/api:reauthorize (not in Invoke surface — needs review); @raycast/api:Project (not in Invoke surface — needs review); @raycast/api:useMemo (not in Invoke surface — needs review); @raycast/api:useState (not in Invoke surface — needs review); @raycast/api:getTodos (not in Invoke surface — needs review); @raycast/api:Filter (not in Invoke surface — needs review); @raycast/utils:useDatabases (not implemented in Invoke); @raycast/utils:useFilter (not implemented in Invoke); @raycast/utils:Tag (not implemented in Invoke); @raycast/utils:Project (not implemented in Invoke); @raycast/utils:Action (not implemented in Invoke); @raycast/utils:ActionPanel (not implemented in Invoke); @raycast/utils:Color (not implemented in Invoke); @raycast/utils:Icon (not implemented in Invoke); @raycast/utils:Image (not implemented in Invoke); @raycast/utils:Filter (not implemented in Invoke); @raycast/utils:loadPreferences (not implemented in Invoke); @raycast/utils:parseTodosToDoneWorkString (not implemented in Invoke); @raycast/utils:getTodos (not implemented in Invoke)

### `hyrule-compendium-search` — Hyrule Compendium Search
- dir: `hyrule-compendium-search` · commands: 2 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `iconify` — Iconify — Search Icons
- dir: `iconify` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `iconpark` — IconPark
- dir: `iconpark` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: openCommandPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `icons8` — Icons8
- dir: `icons8` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `icy-veins-quicklinks` — Icy Veins Quicklinks
- dir: `icy-veins-quicklinks` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `ideate` — Ideate
- dir: `ideate` · commands: 3 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `idonthavespotify` — I Don't Have Spotify
- dir: `idonthavespotify` · commands: 10 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, https, child_process
- Degraded: openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw

### `ihosts` — iHosts
- dir: `ihosts` · commands: 3 · modes: view|menu-bar|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired; unsupported command mode(s): switch: mode "menu-bar"; denied Node built-ins in sandbox: fs, child_process, https
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw

### `ilovepdf` — iLovePDF
- dir: `ilovepdf` · commands: 16 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `image-base64` — Image Base64 Converter
- dir: `image-base64` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `image-flow` — Imageflow
- dir: `image-flow` · commands: 3 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `image-hash-rename` — Image Hash Rename
- dir: `image-hash-rename` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `image-search` — Image Web Search
- dir: `image-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `image-shield` — Image Shield
- dir: `image-shield` · commands: 2 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op

### `image-to-ascii` — Image to Ascii
- dir: `image-to-ascii` · commands: 1 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `image-wallet` — Image Wallet
- dir: `image-wallet` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op

### `imagekit-uploader` — ImageKit Uploader
- dir: `imagekit-uploader` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op

### `imageoptim` — ImageOptim
- dir: `imageoptim` · commands: 1 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process

### `imessage-2fa` — 2FA Code Finder
- dir: `imessage-2fa` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `imgur` — Imgur
- dir: `imgur` · commands: 2 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs

### `immich` — Immich
- dir: `immich` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:runPowerShellScript (not implemented in Invoke)

### `improvmx` — ImprovMX
- dir: `improvmx` · commands: 6 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: openExtensionPreferences: no-op; openCommandPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `inbox-ai` — Inbox AI
- dir: `inbox-ai` · commands: 7 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review); @raycast/utils:createDeeplink (not implemented in Invoke)

### `incident-io` — Incident.io
- dir: `incident-io` · commands: 4 · modes: view|menu-bar
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; unsupported command mode(s): live-incidents: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `inertiajs-documentation` — InertiaJS Documentation
- dir: `inertiajs-documentation` · commands: 1 · modes: view
- Needs review: @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `infakt` — InFakt
- dir: `infakt` · commands: 5 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `infisical` — Infisical
- dir: `infisical` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `infomaniak` — Infomaniak
- dir: `infomaniak` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `ingredients-lister` — Ingredients Lister
- dir: `ingredients-lister` · commands: 2 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `inkeep` — Inkeep
- dir: `inkeep` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `inoreader` — Inoreader
- dir: `inoreader` · commands: 4 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: child_process
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `input-source-switcher` — Input Source Switcher
- dir: `input-source-switcher` · commands: 2 · modes: no-view|view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getSelectedText: throws — selection APIs not wired

### `input-switcher` — Keyboard Layout Switcher
- dir: `keyboard-layout-switcher` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `instagram-media-downloader` — Instagram Media Downloader
- dir: `instagram-media-downloader` · commands: 3 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `installed-extensions` — Installed Extensions
- dir: `installed-extensions` · commands: 1 · modes: view
- **Blockers:** getDefaultApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op

### `instant-domain-search` — Instant Domain Search
- dir: `instant-domain-search` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `intermittent-fasting` — Intermittent Fasting
- dir: `intermittent-fasting` · commands: 2 · modes: view|menu-bar
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; launchCommand: launchCommand not implemented; unsupported command mode(s): menubar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `internet-radio` — Internet Radio
- dir: `internet-radio` · commands: 11 · modes: view|no-view|menu-bar
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; launchCommand: launchCommand not implemented; unsupported command mode(s): menubar-radio: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `invisible-text-detector` — Invisible Text Detector
- dir: `invisible-text-detector` · commands: 3 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: namespace import of @raycast/api (member usage unverified)

### `invoice-generator` — Invoice Generator
- dir: `invoice-generator` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `ip-finder` — Ip Finder - Network Scanner
- dir: `ip-finder` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, dns
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `ip-geolocation` — IP Geolocation
- dir: `ip-geolocation` · commands: 3 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; denied Node built-ins in sandbox: net
- Degraded: openCommandPreferences: no-op; openExtensionPreferences: no-op; captureException: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `ipinfo` — IP Info
- dir: `ipinfo` · commands: 3 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `iridium` — Iridium
- dir: `iridium` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `irish-rail` — Irish Rail
- dir: `irish-rail` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: https

### `ishader` — iShader
- dir: `ishader` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `iterm` — iTerm
- dir: `iterm` · commands: 11 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `itranslate` — iTranslate
- dir: `itranslate` · commands: 4 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; openCommandPreferences: no-op; openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)

### `ivpn` — IVPN
- dir: `ivpn` · commands: 12 · modes: no-view|view
- **Blockers:** launchCommand: launchCommand not implemented; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); captureException: no-op; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Environment (not in Invoke surface — needs review); @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `iwork` — iWork
- dir: `iwork` · commands: 19 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `jellyamp` — Jellyamp
- dir: `jellyamp` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `jellyfin` — Jellyfin
- dir: `jellyfin` · commands: 4 · modes: view
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `jenkins` — Jenkins
- dir: `jenkins` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: http, https
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `jetbrains` — JetBrains Toolbox Recent Projects
- dir: `jetbrains` · commands: 2 · modes: view|menu-bar
- **Blockers:** getApplications: throws — application discovery not wired; unsupported command mode(s): recentMenu: mode "menu-bar"; denied Node built-ins in sandbox: fs, child_process
- Degraded: captureException: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `jetpack-commands` — Jetpack Commands
- dir: `jetpack-commands` · commands: 46 · modes: no-view|view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `jira` — Jira
- dir: `jira` · commands: 9 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; launchCommand: launchCommand not implemented; declares AI tools[] (11) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:MutatePromise (not implemented in Invoke); @raycast/utils:getAvatarIcon (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `jira-search` — Jira Search
- dir: `jira-search` · commands: 5 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:ResultItem (not in Invoke surface — needs review); @raycast/api:SearchCommand (not in Invoke surface — needs review); @raycast/api:jiraFetchObject (not in Invoke surface — needs review); @raycast/api:jiraUrl (not in Invoke surface — needs review)

### `jira-search-self-hosted` — Jira Search (Self-Hosted)
- dir: `jira-search-self-hosted` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, https

### `jira-self-hosted` — Jira (Self-Hosted)
- dir: `jira-self-hosted` · commands: 9 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; launchCommand: launchCommand not implemented; declares AI tools[] (10) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke); @raycast/utils:getAvatarIcon (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `joey-vocab` — Joey Vocab
- dir: `joey-vocab` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: openExtensionPreferences: no-op

### `johnny-decimal` — Johnny.Decimal
- dir: `johnny-decimal` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `jotoba` — Jotoba — Japanese Dictionary
- dir: `jotoba` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `json-format` — Format JSON
- dir: `json-format` · commands: 6 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `json-resume` — JSON Resume
- dir: `json-resume` · commands: 2 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: declares extension-level `ai` instructions — ignored

### `json-to-toon-converter` — JSON to TOON Converter
- dir: `json-to-toon-converter` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `jsr` — JSR
- dir: `jsr` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (11) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; captureException: no-op; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke); @raycast/utils:useLocalStorage (not implemented in Invoke)

### `jsrepo` — jsrepo
- dir: `jsrepo` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `jules-agents` — Jules Agents
- dir: `jules-agents` · commands: 4 · modes: view|menu-bar
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; launchCommand: launchCommand not implemented; showInFinder: throws — showInFinder not wired; unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openCommandPreferences: no-op

### `jump` — Jump
- dir: `jump` · commands: 4 · modes: no-view|view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `jup-agg` — Jupiter Aggregator
- dir: `jupiter-aggregator` · commands: 2 · modes: menu-bar|view
- **Blockers:** unsupported command mode(s): menu-bar-token-price: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `just-breathe` — Just Breathe
- dir: `just-breathe` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `just-focus` — Just Focus
- dir: `just-focus` · commands: 4 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog)

### `jwt-decoder` — JWT Decoder
- dir: `jwt-decoder` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `kafka` — Kafka
- dir: `kafka` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): kafka-menubar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw; openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled

### `kaleidoscope` — Kaleidoscope
- dir: `kaleidoscope` · commands: 4 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; getFrontmostApplication: throws — application discovery not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `kalshi` — Kalshi
- dir: `kalshi` · commands: 1 · modes: view
- Needs review: @raycast/api:getLocalStorageItem (not in Invoke surface — needs review); @raycast/api:setLocalStorageItem (not in Invoke surface — needs review)

### `kaneo-for-raycast` — Kaneo
- dir: `kaneo-for-raycast` · commands: 3 · modes: view
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `karabiner-profile-switcher` — Karabiner Profile Switcher
- dir: `karabiner-profile-switcher` · commands: 2 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; denied Node built-ins in sandbox: child_process
- Degraded: declares background `interval` command(s) — not scheduled

### `karakeep` — Karakeep
- dir: `karakeep` · commands: 11 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `kaset-control` — Kaset Control
- dir: `kaset-control` · commands: 12 · modes: menu-bar|view|no-view
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `kde-connect` — KDE Connect
- dir: `kde-connect` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `keepassxc` — KeePassXC
- dir: `keepassxc` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `keeply` — Keeply
- dir: `keeply` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `kef-control` — Control Kef
- dir: `kef-control` · commands: 3 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): set-volume-menubar: mode "menu-bar"; declares AI tools[] (3) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:useLocalStorage (not implemented in Invoke)

### `keka` — Keka
- dir: `keka` · commands: 3 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog)

### `key-value` — Key Value
- dir: `key-value` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `keyboard-brightness` — Keyboard Brightness
- dir: `keyboard-brightness` · commands: 4 · modes: no-view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menubar-keyboard-brightness: mode "menu-bar"; denied Node built-ins in sandbox: fs

### `keyboard-shortcut-sequences` — Keyboard Shortcut Sequences
- dir: `keyboard-shortcut-sequences` · commands: 2 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; getFrontmostApplication: throws — application discovery not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `keyboard-win-mac-switch` — Keyboard Win Mac Switch
- dir: `keyboard-win-mac-switch` · commands: 2 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `keygen` — Keygen
- dir: `keygen` · commands: 7 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `keyraycast` — KeyRaycast
- dir: `keyraycast` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `kill-mcp` — Kill MCP Servers
- dir: `kill-mcp` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog)

### `kill-node-modules` — Kill Node Modules
- dir: `kill-node-modules` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `kill-process` — Kill Process
- dir: `kill-process` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review); @raycast/api:Tool (not in Invoke surface — needs review)

### `kimai` — Kimai
- dir: `kimai` · commands: 4 · modes: view|menu-bar|no-view
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): logged-hours: mode "menu-bar"
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `kimi` — Kimi
- dir: `kimi` · commands: 5 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `kinopio-inbox` — Kinopio Inbox
- dir: `kinopio-inbox` · commands: 2 · modes: view|no-view
- Needs review: @raycast/api:Preferences (not in Invoke surface — needs review)

### `kinopoisk` — Kinopoisk
- dir: `kinopoisk` · commands: 1 · modes: view
- Needs review: @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:preferences (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review); @raycast/api:PushAction (not in Invoke surface — needs review)

### `kiro` — Kiro
- dir: `kiro` · commands: 5 · modes: view|no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog)

### `kitty` — Kitty
- dir: `kitty` · commands: 5 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `klack` — Klack
- dir: `klack` · commands: 10 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; declares AI tools[] (7) — AI extensions not supported; denied Node built-ins in sandbox: child_process
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `knowyourmeme` — KnowYourMeme
- dir: `knowyourmeme` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op

### `kommand` — Kommand
- dir: `kommand` · commands: 2 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs

### `korean-add-calendar` — Korean Add Calendar
- dir: `korean-add-calendar` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `korean-date-converter` — Korean Date Converter
- dir: `korean-date-converter` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `korean-spell-checker` — Korean Spell Checker
- dir: `korean-spell-checker` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `koyeb` — Koyeb
- dir: `koyeb` · commands: 4 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `kubectx` — kubectx
- dir: `kubectx` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Needs review: @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `kubens` — kubens
- dir: `kubens` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `kurslog` — Kurslog
- dir: `kurslog` · commands: 5 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `kutt` — Kutt
- dir: `kutt` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `lacinka` — Lacinka
- dir: `lacinka` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `laliga` — LaLiga
- dir: `laliga` · commands: 4 · modes: view
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `language-detector` — Language Detector
- dir: `language-detector` · commands: 3 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired; AI: AI.ask throws — Invoke AI not yet wired
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet

### `lapack-blas-documentation-search` — LAPACK/BLAS Documentation Search
- dir: `lapack-blas-documentation-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `larajobs-search` — Search LaraJobs
- dir: `larajobs-search` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `laravel-artisan` — Laravel Artisan
- dir: `laravel-artisan` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `laravel-cloud` — Laravel Cloud
- dir: `laravel-cloud` · commands: 10 · modes: view
- **Blockers:** declares AI tools[] (15) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `laravel-docs` — Laravel Docs
- dir: `laravel-docs` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `laravel-forge` — Laravel Forge
- dir: `laravel-forge` · commands: 2 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; updateCommandMetadata: menu-bar/command metadata updates not implemented; trash: throws — file trash not wired; unsupported command mode(s): check-deploy-status: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `laravel-herd` — Laravel Herd
- dir: `laravel-herd` · commands: 17 · modes: no-view|view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:withCache (not implemented in Invoke)

### `laravel-nova` — Laravel Nova
- dir: `laravel-nova` · commands: 1 · modes: view
- Needs review: @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review)

### `laravel-tips` — Laravel Tips
- dir: `laravel-tips` · commands: 3 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `laravel-valet` — Laravel Valet
- dir: `laravel-valet` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `lark` — Lark Documents
- dir: `lark` · commands: 2 · modes: view
- Degraded: openExtensionPreferences: no-op
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `lastfm` — Last.fm
- dir: `lastfm` · commands: 7 · modes: menu-bar|view
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menubar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openCommandPreferences: no-op; openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled

### `lastpass` — LastPass Credentials Search
- dir: `lastpass` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `later` — Read Later
- dir: `later` · commands: 3 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `latex-board` — LaTeX Board
- dir: `latex-board` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `lattice-scholar-extension` — Lattice Scholar Extension
- dir: `lattice-scholar-extension` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `launch-agents` — Launch Agents
- dir: `launch-agents` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: captureException: no-op; confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `launchd-monitor` — Launchd Monitor
- dir: `launchd-monitor` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): menubar: mode "menu-bar"; denied Node built-ins in sandbox: fs, child_process
- Degraded: declares background `interval` command(s) — not scheduled

### `launchdarkly` — LaunchDarkly
- dir: `launchdarkly` · commands: 1 · modes: view
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `launchpad-plus` — Launchpad+
- dir: `launchpad-plus` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `lavinprognoser` — Lavinprognoser
- dir: `lavinprognoser` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored

### `leader-key` — Leader Key
- dir: `leader-key` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke); @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `leafcast` — Leafcast
- dir: `leafcast` · commands: 8 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented; declares AI tools[] (7) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw; declares extension-level `ai` instructions — ignored

### `leap-new` — Leap.new
- dir: `leap-new` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"

### `learning-snacks` — Learning Snacks
- dir: `learning-snacks` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired
- Degraded: openCommandPreferences: no-op

### `leave-time-calculator` — Leave Time Calculator
- dir: `leave-time-calculator` · commands: 2 · modes: no-view|view
- **Blockers:** launchCommand: launchCommand not implemented; updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: declares background `interval` command(s) — not scheduled

### `lemniscate-system-monitor` — Lemniscate | System Monitor
- dir: `lemniscate-system-monitor` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `lemon-squeezy` — Lemon Squeezy
- dir: `lemon-squeezy` · commands: 2 · modes: view
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `letta` — Letta Agents
- dir: `letta` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `library-genesis` — Library Genesis
- dir: `library-genesis` · commands: 2 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: https
- Degraded: openExtensionPreferences: no-op

### `life-progress` — Life Progress
- dir: `life-progress` · commands: 2 · modes: view|menu-bar
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; unsupported command mode(s): life-progress-menubar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openCommandPreferences: no-op; confirmAlert: always returns false (no dialog); declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `lifx` — LIFX
- dir: `lifx` · commands: 5 · modes: view|no-view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `lightshot-gallery` — Lightshot Gallery
- dir: `lightshot-gallery` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired
- Degraded: openCommandPreferences: no-op

### `linak-desk-controller` — Linak Desk Controller
- dir: `linak-controller` · commands: 4 · modes: no-view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menubar-move: mode "menu-bar"; declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: child_process
- Degraded: openExtensionPreferences: no-op; declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `linak-desk-controller` — Linak Desk Controller
- dir: `linak-desk-controller` · commands: 4 · modes: no-view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menubar-move: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `linear` — Linear
- dir: `linear` · commands: 14 · modes: view|menu-bar|no-view
- **Blockers:** getApplications: throws — application discovery not wired; launchCommand: launchCommand not implemented; unsupported command mode(s): unread-notifications: mode "menu-bar"; declares AI tools[] (22) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; openExtensionPreferences: no-op; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:useAI (not implemented in Invoke); @raycast/utils:MutatePromise (not implemented in Invoke); @raycast/utils:getProgressIcon (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `lingo-rep-raycast` — Lingorep - Translate, Repeat, Memorize
- dir: `lingo-rep-raycast` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `link-bundles` — Link Bundles
- dir: `link-bundles` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; openCommandPreferences: no-op; confirmAlert: always returns false (no dialog)

### `link-cleaner` — Link Cleaner
- dir: `link-cleaner` · commands: 2 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; getFrontmostApplication: throws — application discovery not wired

### `link-transformer` — Link Transformer
- dir: `link-transformer` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `linkace-search` — LinkAce Search
- dir: `linkace-search` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `linkding` — Linkding
- dir: `linkding` · commands: 3 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke); @raycast/utils:getFavicon (not implemented in Invoke)

### `linkinize` — Linkinize
- dir: `linkinize` · commands: 3 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled

### `linkwarden` — Linkwarden
- dir: `linkwarden` · commands: 2 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; launchCommand: launchCommand not implemented
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `list-randomizer` — List Randomizer
- dir: `list-randomizer` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `litterbox` — Litterbox
- dir: `litterbox` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `lobsters` — Lobste.rs Homepage
- dir: `lobsters` · commands: 1 · modes: view
- Needs review: @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review); @raycast/api:ImageMask (not in Invoke surface — needs review)

### `localcan` — LocalCan
- dir: `localcan` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `localsend` — LocalSend
- dir: `localsend` · commands: 9 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): localsend-status: mode "menu-bar"; denied Node built-ins in sandbox: fs, dgram, http
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `lock-time` — Lock Time
- dir: `lock-time` · commands: 3 · modes: view|no-view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: declares background `interval` command(s) — not scheduled

### `lodash` — Lodash
- dir: `lodash` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `logitech-litra` — Logitech Litra
- dir: `logitech-litra` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `logos-launcher` — Logos Launcher
- dir: `logos-launcher` · commands: 10 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `logseq` — Logseq
- dir: `logseq` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `lokalise` — Lokalise
- dir: `lokalise` · commands: 3 · modes: view|no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (5) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `lol-esports` — LoL Esports
- dir: `lol-esports` · commands: 2 · modes: view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored

### `lookaway` — Lookaway
- dir: `lookaway` · commands: 9 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `looma-fm` — Looma.fm
- dir: `looma-fm` · commands: 4 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `looped` — Looped
- dir: `looped` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `lorem-ipsum` — Lorem Ipsum
- dir: `lorem-ipsum` · commands: 4 · modes: no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `lotus-mtg-companion` — Lotus - MTG Companion
- dir: `lotus-mtg-companion` · commands: 3 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `lucide-icons` — Lucide Icons Search
- dir: `lucide-icons` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `lucky-surf` — Lucky Surf
- dir: `lucky-surf` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `luma` — Luma
- dir: `luma` · commands: 2 · modes: view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored

### `luna-search` — Luna Search
- dir: `luna-search` · commands: 2 · modes: view|menu-bar
- **Blockers:** getApplications: throws — application discovery not wired; unsupported command mode(s): luna-quick-access: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet

### `lunaris` — Lunaris
- dir: `lunaris` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `luxafor-controller` — Luxafor Controller
- dir: `luxafor-controller` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): luxafor-status: mode "menu-bar"
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled

### `lyne` — Lyne
- dir: `lyne` · commands: 3 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired

### `lyric-fever-control` — Lyric Fever Control
- dir: `lyric-fever-control` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `m3o` — M3O
- dir: `m3o` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `mac-mouse-fix` — Mac Mouse Fix
- dir: `mac-mouse-fix` · commands: 8 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `mac-network-location-changer` — Mac Network Location Changer
- dir: `mac-network-location-changer` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `macos-tweaks` — macOS Tweaks
- dir: `macos-tweaks` · commands: 3 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog)

### `macosicons` — macOSIcons.com
- dir: `macosicons` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: openCommandPreferences: no-op

### `macports` — MacPorts
- dir: `macports` · commands: 2 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `magic-ingest` — Magic Ingest
- dir: `magic-ingest` · commands: 2 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; updateCommandMetadata: menu-bar/command metadata updates not implemented; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `mail` — Apple Mail
- dir: `mail` · commands: 11 · modes: no-view|view
- **Blockers:** showInFinder: throws — showInFinder not wired; declares AI tools[] (6) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `mail-finder` — Mail Finder
- dir: `email-finder` · commands: 3 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `mailerlite-stats` — MailerLite Stats
- dir: `mailerlite-stats` · commands: 2 · modes: view
- Degraded: openExtensionPreferences: no-op
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `mailersend` — MailerSend
- dir: `mailersend` · commands: 5 · modes: no-view|view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke); @raycast/utils:MutatePromise (not implemented in Invoke)

### `mailsy` — Mailsy
- dir: `mailsy` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `mailwip` — Mailwip
- dir: `mailwip` · commands: 3 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `mamp-utility` — MAMP Utility
- dir: `mamp-utility` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `man-pages` — Man Pages
- dir: `man-pages` · commands: 3 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: child_process, fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `manage-clickup-tasks` — ClickUp - Tasks & Docs Explorer
- dir: `clickup` · commands: 6 · modes: view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `manotori` — Manotori
- dir: `manotori` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `mantine-documentation` — Mantine UI Documentation
- dir: `mantine` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `manus-manager` — Manus Manager
- dir: `manus-manager` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `maplestory-gg` — MapleStory.gg
- dir: `maplestory-gg` · commands: 2 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `marginnote` — MarginNote
- dir: `marginnote` · commands: 3 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; getApplications: throws — application discovery not wired
- Degraded: openCommandPreferences: no-op

### `markdown-blog` — Markdown Blog Manager
- dir: `markdown-blog-manager` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op

### `markdown-codeblock` — Markdown Codeblock
- dir: `markdown-codeblock` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getSelectedText: throws — selection APIs not wired

### `markdown-docs` — Markdown Documents
- dir: `markdown-docs` · commands: 3 · modes: view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `markdown-image-to-html` — Markdown Image to HTML
- dir: `markdown-image-to-html` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `markdown-navigator` — Markdown Navigator
- dir: `markdown-navigator` · commands: 1 · modes: view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op

### `markdown-slides` — Markdown Slides
- dir: `markdown-slides` · commands: 4 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; launchCommand: launchCommand not implemented; getDefaultApplication: throws — application discovery not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `markdown-styler` — Markdown Styler
- dir: `markdown-styler` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs

### `markdown-to-jira` — Markdown to Jira
- dir: `markdown-to-jira` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `markmarks` — MarkMarks
- dir: `markmarks` · commands: 2 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `masked-link-generator` — Masked Link Generator
- dir: `masked-link-generator` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:Response (not implemented in Invoke)

### `masscode` — massCode
- dir: `masscode` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired

### `mastodon` — Mastodon
- dir: `mastodon` · commands: 6 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; OAuth: OAuth.PKCEClient throws — OAuth not yet wired; unsupported command mode(s): menu-bar-notifications: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled

### `mastodon-search` — Mastodon Search
- dir: `mastodon-search` · commands: 1 · modes: view
- Needs review: @raycast/api:useMemo (not in Invoke surface — needs review); @raycast/api:useState (not in Invoke surface — needs review); @raycast/utils:useMemo (not implemented in Invoke)

### `material-icons` — Material Icons
- dir: `material-icons` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `mattermost` — Mattermost
- dir: `mattermost` · commands: 3 · modes: view
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `maven-central-repository` — Maven Central Repository
- dir: `maven-central-repository` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `mayar` — Mayar
- dir: `mayar` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): mayar-balance-recent-transaction: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `maybe` — Maybe
- dir: `maybe` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `mbta-tracker` — MBTA Tracker
- dir: `mbta-tracker` · commands: 2 · modes: view
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `mcp` — Model Context Protocol
- dir: `mcp` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `media-converter` — Media Converter
- dir: `media-converter` · commands: 4 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; getSelectedFinderItems: throws — Finder selection not wired; launchCommand: launchCommand not implemented; declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process, module
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openCommandPreferences: no-op; confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `medialister-marketplace-helper` — Medialister Marketplace Helper
- dir: `medialister-marketplace-helper` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; AI: AI.ask throws — Invoke AI not yet wired

### `meduza` — Meduza
- dir: `meduza` · commands: 2 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `memberstack` — Memberstack
- dir: `memberstack` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `meme-generator` — Meme Generator
- dir: `meme-generator` · commands: 2 · modes: view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:withCache (not implemented in Invoke)

### `memo` — Memo
- dir: `memo` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Needs review: @raycast/api:Page (not in Invoke surface — needs review); @raycast/api:Api (not in Invoke surface — needs review); @raycast/api:OAuthClient (not in Invoke surface — needs review); @raycast/api:RaycastAdapter (not in Invoke surface — needs review); @raycast/api:useEffect (not in Invoke surface — needs review); @raycast/api:useState (not in Invoke surface — needs review); @raycast/api:Saver (not in Invoke surface — needs review)

### `memorable-generate-password` — Memorable Password Generator
- dir: `memorable-generate-password` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: openCommandPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `memory` — Memory
- dir: `memory` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (9) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored

### `memos` — Memos
- dir: `memos` · commands: 4 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `menubar-calendar` — Menubar Calendar
- dir: `menubar-calendar` · commands: 2 · modes: menu-bar|view
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): index: mode "menu-bar"
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; openExtensionPreferences: no-op; captureException: no-op; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `menubar-weather` — Menubar Weather
- dir: `menubar-weather` · commands: 1 · modes: menu-bar
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; unsupported command mode(s): menubar-weather: mode "menu-bar"
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled

### `mercury` — Mercury
- dir: `mercury` · commands: 2 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (3) — AI extensions not supported
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke); @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `mermaid-to-image` — Mermaid to Image
- dir: `mermaid-to-image` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: declares extension-level `ai` instructions — ignored

### `messages` — Messages
- dir: `messages` · commands: 5 · modes: view|menu-bar|no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; launchCommand: launchCommand not implemented; unsupported command mode(s): unread-messages: mode "menu-bar"; declares AI tools[] (3) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openCommandPreferences: no-op; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `meta-music` — Meta Music
- dir: `meta-music` · commands: 1 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `metabase` — Metabase
- dir: `metabase` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (4) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `metaphor` — Metaphor
- dir: `metaphor` · commands: 2 · modes: view
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `metronome` — Metronome
- dir: `metronome` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `micro-snitch-logs` — Micro Snitch Logs
- dir: `micro-snitch-logs` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `microsoft-azure` — Microsoft Azure
- dir: `microsoft-azure` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `microsoft-edge` — Microsoft Edge
- dir: `microsoft-edge` · commands: 7 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `microsoft-office` — Microsoft Office
- dir: `microsoft-office` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Needs review: @raycast/utils:runPowerShellScript (not implemented in Invoke)

### `microsoft-onedrive` — Microsoft OneDrive
- dir: `microsoft-onedrive` · commands: 2 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `microsoft-teams` — Microsoft Teams
- dir: `microsoft-teams` · commands: 3 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `midjourney` — Midjourney
- dir: `midjourney` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `migadu` — Migadu
- dir: `migadu` · commands: 4 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `migros` — Migros
- dir: `migros` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: https, fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `mindnode` — MindNode
- dir: `mindnode` · commands: 3 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs

### `miniflux` — Miniflux
- dir: `miniflux` · commands: 5 · modes: view|no-view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `minimax-tts` — MiniMax TTS
- dir: `minimax-tts` · commands: 10 · modes: no-view|view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; getSelectedText: throws — selection APIs not wired; unsupported command mode(s): playback-status: mode "menu-bar"; denied Node built-ins in sandbox: fs, child_process
- Degraded: openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled

### `minio-manager` — Minio Manager
- dir: `minio-manager` · commands: 2 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs, http, https
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `minttr` — Minttr
- dir: `minttr` · commands: 3 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

### `miraie-ac-control` — MirAIe AC Control
- dir: `miraie-ac-control` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op

### `miro` — Miro
- dir: `miro` · commands: 3 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke); @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `mirror-displays` — Mirror Displays
- dir: `mirror-displays` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `mistral` — Mistral
- dir: `mistral` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `mite` — Mite
- dir: `mite` · commands: 4 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: declares background `interval` command(s) — not scheduled

### `mlb-scores` — MLB Scores
- dir: `mlb-scores` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `mldocs` — MLDocs
- dir: `mldocs` · commands: 8 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `mobile-provisions` — Mobile Provisions
- dir: `mobile-provisions` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `moco` — MOCO
- dir: `moco` · commands: 3 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): moco_menu_bar: mode "menu-bar"; denied Node built-ins in sandbox: http
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `model-context-protocol-registry` — Model Context Protocol Registry
- dir: `model-context-protocol-registry` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: openCommandPreferences: no-op
- Needs review: @raycast/utils:withCache (not implemented in Invoke)

### `models-dev` — Models Dev
- dir: `models-dev` · commands: 7 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs, v8
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled

### `modify-hash` — Modify Hash
- dir: `modify-hash` · commands: 4 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs

### `moji` — Moji Dict Search
- dir: `moji` · commands: 1 · modes: view
- Needs review: @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review); @raycast/api:randomId (not in Invoke surface — needs review)

### `mole` — Mole
- dir: `mole` · commands: 10 · modes: view|menu-bar
- **Blockers:** trash: throws — file trash not wired; launchCommand: launchCommand not implemented; unsupported command mode(s): health-menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares background `interval` command(s) — not scheduled

### `mollie-for-raycast` — Mollie
- dir: `mollie-for-raycast` · commands: 4 · modes: menu-bar|view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; unsupported command mode(s): transactionsMenuBar: mode "menu-bar"
- Degraded: confirmAlert: always returns false (no dialog)

### `momentum` — Momentum
- dir: `momentum` · commands: 5 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `moneybird` — Moneybird
- dir: `moneybird` · commands: 3 · modes: view|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `moneytree` — Moneytree
- dir: `moneytree` · commands: 3 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet

### `monitor-mate` — MonitorMate
- dir: `monitor-mate` · commands: 3 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: net, child_process
- Degraded: declares background `interval` command(s) — not scheduled

### `monobank` — monobank
- dir: `monobank` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `monorepo-manager` — Manage Monorepo Projects/Workspaces
- dir: `monorepo-manager` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; openCommandPreferences: no-op

### `monse` — Monse - Banking In Raycast
- dir: `monse` · commands: 2 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `monzo` — Monzo
- dir: `monzo` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `mood` — Mood Tracker
- dir: `mood` · commands: 3 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored

### `moodist` — Moodist
- dir: `moodist` · commands: 7 · modes: view|no-view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `moon-phrase` — Moon Phrase
- dir: `moon-phrase` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `morning-coffee` — Morning Coffee
- dir: `morning-coffee` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `mound-for-pile` — Mound
- dir: `mound-for-pile` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `mouse-jiggle` — Mouse Jiggle
- dir: `mouse-jiggle` · commands: 2 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `mousehunt-helper` — MouseHunt Helper
- dir: `mousehunt-helper` · commands: 1 · modes: view
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `mozeidon` — Mozeidon
- dir: `mozeidon` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: readline, child_process
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `mozilla-firefox` — Mozilla Firefox
- dir: `mozilla-firefox` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `mozilla-vpn` — Mozilla VPN Connect
- dir: `mozilla-vpn` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs, https, http
- Needs review: namespace import of @raycast/api (member usage unverified)

### `mui-documentation` — MUI Documentation
- dir: `mui-documentation` · commands: 1 · modes: view
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `mullvad` — Mullvad VPN
- dir: `mullvad` · commands: 5 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `multi-force` — MultiForce
- dir: `multi-force` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `multi-links` — Open Multiple Links
- dir: `multi-links` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `multilinks` — Multilinks
- dir: `multilinks` · commands: 3 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `music` — Music
- dir: `music` · commands: 26 · modes: no-view|view|menu-bar
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; unsupported command mode(s): currently-playing-menu-bar: mode "menu-bar"; declares AI tools[] (21) — AI extensions not supported; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openCommandPreferences: no-op; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:ArgumentsLaunchProps (not in Invoke surface — needs review)

### `music-assistant-controls` — Music Assistant Controls
- dir: `music-assistant-controls` · commands: 12 · modes: menu-bar|no-view|view
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); declares background `interval` command(s) — not scheduled

### `music-link-converter` — Music Link Converter
- dir: `music-link-converter` · commands: 2 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; declares AI tools[] (3) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `music-recognition` — Music Recognition
- dir: `music-recognition` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `mute-microphone` — Toggle Audio Input (Microphone)
- dir: `mute-microphone` · commands: 3 · modes: menu-bar|no-view
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): mute-menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; openCommandPreferences: no-op; openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `mutedeck` — MuteDeck
- dir: `mutedeck` · commands: 4 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: confirmAlert: always returns false (no dialog)

### `mxroute` — MXroute
- dir: `mxroute` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `my-daily-log` — My Daily Log
- dir: `my-daily-log` · commands: 6 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `myanimelist-search` — Myanimelist Search
- dir: `myanimelist-search` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; confirmAlert: always returns false (no dialog)

### `myidlers` — MyIdlers
- dir: `my-idlers` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke); @raycast/utils:MutatePromise (not implemented in Invoke)

### `myip` — MyIP
- dir: `myip` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menubar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `mymind` — mymind
- dir: `mymind` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `n8n` — n8n
- dir: `n8n` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: openCommandPreferences: no-op; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `name-com` — Name.com
- dir: `name-com` · commands: 2 · modes: no-view|view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; declares AI tools[] (3) — AI extensions not supported
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke); @raycast/utils:MutatePromise (not implemented in Invoke)

### `namecheap` — Namecheap
- dir: `namecheap` · commands: 1 · modes: view
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `namesilo` — NameSilo
- dir: `namesilo` · commands: 7 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `namespaces` — NameSpaces
- dir: `namespaces` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `napkin` — Napkin
- dir: `napkin` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `naver-search` — Naver Search
- dir: `naver-search` · commands: 6 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `neon` — Neon
- dir: `neon` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke); @raycast/utils:MutatePromise (not implemented in Invoke)

### `nepali-date-converter` — Nepali Date Converter
- dir: `nepali-date-converter` · commands: 1 · modes: no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: declares background `interval` command(s) — not scheduled

### `nerd-font-picker` — Nerd Font Picker
- dir: `nerd-font-picker` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `netbird` — NetBird
- dir: `netbird` · commands: 7 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `netlify` — Netlify
- dir: `netlify` · commands: 7 · modes: view
- **Blockers:** getDefaultApplication: throws — application discovery not wired; declares AI tools[] (7) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke); @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `netnewswire` — NetNewsWire
- dir: `netnewswire` · commands: 1 · modes: view
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `network-diagnostics` — Network Diagnostics
- dir: `network-diagnostics` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: dns

### `network-drive` — Network Drive
- dir: `network-drive` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op

### `network-menubar-monitor` — Network Menubar Monitor
- dir: `network-menubar-monitor` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): index: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: declares background `interval` command(s) — not scheduled

### `network-proxy` — Network Proxy
- dir: `network-proxy` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `network-speed` — Network Speed
- dir: `network-speed` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: openCommandPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw

### `next-up` — Next Up
- dir: `next-up` · commands: 5 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `nextdns` — NextDNS
- dir: `nextdns` · commands: 4 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `nextjs-docs` — Next.js Documentation
- dir: `nextjs-docs` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `nhk-program-search` — NHK Program Search
- dir: `nhk-program-search` · commands: 4 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented; updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `night-light` — Night Light
- dir: `night-light` · commands: 4 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `nightscout` — Nightscout
- dir: `nightscout` · commands: 6 · modes: view|no-view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; updateCommandMetadata: menu-bar/command metadata updates not implemented; unsupported command mode(s): glucoseMenuBar: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `nippon-colors` — Nippon Colors
- dir: `nippon-colors` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `nix-flake-templates` — Nix Flake Templates
- dir: `nix-flake-templates` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process

### `no-more-caffeine` — No More Caffeine
- dir: `no-more-caffeine` · commands: 4 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares background `interval` command(s) — not scheduled

### `nocal` — nocal
- dir: `nocal` · commands: 4 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: openExtensionPreferences: no-op

### `node-release-notes` — Node Release Notes
- dir: `node-release-notes` · commands: 1 · modes: view
- Needs review: @raycast/utils:AsyncState (not implemented in Invoke)

### `node-version-manager` — Node Version Manager
- dir: `node-version-manager` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `nos-nieuws` — NOS Nieuws
- dir: `nos-news` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review)

### `not-diamond` — Not Diamond
- dir: `not-diamond` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `note-in-google-doc` — Notes in Google Docs
- dir: `note-in-google-doc` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `noteman` — Noteman
- dir: `noteman` · commands: 4 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; trash: throws — file trash not wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `noteplan-3` — NotePlan 3
- dir: `noteplan-3` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `notion` — Notion
- dir: `notion` · commands: 4 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; AI: AI.ask throws — Invoke AI not yet wired; OAuth: OAuth.PKCEClient throws — OAuth not yet wired; declares AI tools[] (6) — AI extensions not supported
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `notion-url-to-id` — Notion URL to ID
- dir: `notion-url-to-id` · commands: 2 · modes: no-view|view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `notis` — Ask Notis
- dir: `notis` · commands: 3 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar-command: mode "menu-bar"; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `noun-project` — Noun Project
- dir: `noun-project` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `nouns` — Nouns
- dir: `nouns` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): nouns-menu: mode "menu-bar"

### `now-playing` — Now Playing
- dir: `now-playing` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): now-playing-menubar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled

### `nowledge-mem` — Nowledge Mem
- dir: `nowledge-mem` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `npm-claimer` — npm Claimer
- dir: `npm-claimer` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `ntfy` — Ntfy
- dir: `ntfy` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `nts-radio` — NTS Radio
- dir: `nts-radio` · commands: 7 · modes: no-view|view
- **Blockers:** launchCommand: launchCommand not implemented
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `nuget-package-explorer` — NuGet Package Explorer
- dir: `nuget-package-explorer` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `numi` — Numi
- dir: `numi` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, http
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `numpy-documentation-search` — Numpy Documentation Search
- dir: `numpy-documentation-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: openCommandPreferences: no-op

### `nusmods` — NUSMods
- dir: `nusmods` · commands: 1 · modes: view
- Needs review: @raycast/utils:useStreamJSON (not implemented in Invoke)

### `nuxt` — Nuxt
- dir: `nuxt` · commands: 6 · modes: no-view|view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; getSelectedText: throws — selection APIs not wired; unsupported command mode(s): nuxt-dev-server: mode "menu-bar"; declares AI tools[] (8) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: openExtensionPreferences: no-op; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `oblique-strategies` — Oblique Strategies
- dir: `oblique-strategies` · commands: 3 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `obs-clippings` — Obsidian Clippings
- dir: `obs-clippings` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op

### `obs-control` — OBS Control
- dir: `obs-control` · commands: 8 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: confirmAlert: always returns false (no dialog)

### `obsidian` — Obsidian
- dir: `obsidian` · commands: 12 · modes: view|menu-bar
- **Blockers:** getSelectedText: throws — selection APIs not wired; getDefaultApplication: throws — application discovery not wired; unsupported command mode(s): obsidianMenuBar: mode "menu-bar"; declares AI tools[] (7) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `obsidian-bookmarks` — Obsidian Bookmarks
- dir: `obsidian-bookmarks` · commands: 3 · modes: view|no-view
- **Blockers:** trash: throws — file trash not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/api:FileIcon (not in Invoke surface — needs review); @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `obsidian-link-opener` — Obsidian Link Opener
- dir: `obsidian-link-opener` · commands: 3 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: namespace import of @raycast/api (member usage unverified)

### `obsidian-smart-capture` — Obsidian Smart Capture
- dir: `obsidian-smart-capture` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw

### `obsidian-tasks` — Obsidian Tasks
- dir: `obsidian-tasks` · commands: 5 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menubar-item: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op

### `oci` — Oracle Cloud
- dir: `oci` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `odesli` — Odesli
- dir: `odesli` · commands: 2 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `office2pdf` — Office2PDF
- dir: `office2pdf` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs, https

### `ok-json` — OK JSON
- dir: `ok-json` · commands: 7 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired; showInFinder: throws — showInFinder not wired; getApplications: throws — application discovery not wired
- Degraded: confirmAlert: always returns false (no dialog)

### `okta-app-manager` — Okta Manager
- dir: `okta-app-manager` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `olacv` — OlaCV
- dir: `olacv` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `omg-lol` — omg.lol
- dir: `omg-lol` · commands: 7 · modes: view|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `omnifocus` — OmniFocus
- dir: `omnifocus` · commands: 3 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `omnivore` — Omnivore
- dir: `omnivore` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getPreferenceValues (not implemented in Invoke)

### `onbo` — Onbo: New Grad & Internship Tracker
- dir: `onbo` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `one-thing` — One Thing
- dir: `one-thing` · commands: 3 · modes: menu-bar|view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; launchCommand: launchCommand not implemented; unsupported command mode(s): show-one-thing: mode "menu-bar"; declares AI tools[] (2) — AI extensions not supported
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `one-time-password` — One Time Password
- dir: `one-time-password` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke); @raycast/utils:runPowerShellScript (not implemented in Invoke)

### `one-time-secret` — One-Time Secret
- dir: `one-time-secret` · commands: 3 · modes: view|no-view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored

### `onenote` — OneNote
- dir: `onenote` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `open-camera-menu-bar` — Open Camera Menu Bar
- dir: `open-camera-menu-bar` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): index: mode "menu-bar"

### `open-docker` — Open Docker
- dir: `open-docker` · commands: 1 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired

### `open-folders` — Open Folders
- dir: `open-folders` · commands: 11 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `open-graph` — Open Graph
- dir: `open-graph` · commands: 2 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `open-in-android-studio` — Open in Android Studio
- dir: `open-in-android-studio` · commands: 3 · modes: no-view|view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `open-in-cursor` — Open in Cursor
- dir: `open-in-cursor` · commands: 1 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: child_process

### `open-in-shopify-admin` — Open in Shopify Admin
- dir: `open-in-shopify-admin` · commands: 1 · modes: no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

### `open-in-sublime-text` — Open in Sublime Text
- dir: `open-in-sublime-text` · commands: 2 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: child_process, fs

### `open-in-textmate` — Open in TextMate
- dir: `open-in-textmate` · commands: 1 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: child_process

### `open-in-trae` — Open in Trae
- dir: `open-in-trae` · commands: 1 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: child_process

### `open-in-visual-studio-code` — Open in Visual Studio Code
- dir: `open-in-visual-studio-code` · commands: 1 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; getSelectedFinderItems: throws — Finder selection not wired
- Needs review: @raycast/utils:runPowerShellScript (not implemented in Invoke)

### `open-laravel-herd-site` — Open Laravel Herd Site
- dir: `open-laravel-herd-site` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `open-link-in-specific-browser` — Open Link in Specific Browser
- dir: `open-link-in-specific-browser` · commands: 3 · modes: view|menu-bar|no-view
- **Blockers:** getApplications: throws — application discovery not wired; getDefaultApplication: throws — application discovery not wired; getSelectedText: throws — selection APIs not wired; getFrontmostApplication: throws — application discovery not wired; unsupported command mode(s): open-link-from-menubar: mode "menu-bar"; denied Node built-ins in sandbox: net
- Degraded: confirmAlert: always returns false (no dialog); openCommandPreferences: no-op
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke); @raycast/utils:useLocalStorage (not implemented in Invoke); @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `open-path` — Open Path
- dir: `open-path` · commands: 1 · modes: no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; updateCommandMetadata: menu-bar/command metadata updates not implemented; getSelectedText: throws — selection APIs not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `open-props` — Open Props
- dir: `open-props` · commands: 2 · modes: view
- Needs review: @raycast/utils:withCache (not implemented in Invoke)

### `open-with-app` — Open With App
- dir: `open-with-app` · commands: 1 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; getFrontmostApplication: throws — application discovery not wired; getApplications: throws — application discovery not wired
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `openai-gpt` — OpenAI GPT
- dir: `openai-gpt` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: openCommandPreferences: no-op

### `openai-speak` — OpenAI Speak
- dir: `openai-speak` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs, child_process

### `openai-translator` — OpenAI Translator
- dir: `openai-translator` · commands: 8 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; launchCommand: launchCommand not implemented; updateCommandMetadata: menu-bar/command metadata updates not implemented; AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `openclaw` — OpenClaw
- dir: `openclaw` · commands: 6 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `opencode-sessions` — OpenCode Sessions
- dir: `opencode-sessions` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `openfortivpn` — Openfortivpn
- dir: `openfortivpn` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog)

### `openhue` — OpenHue
- dir: `openhue` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: https, fs
- Degraded: openExtensionPreferences: no-op

### `openrouter-manager` — OpenRouter Manager
- dir: `openrouter-manager` · commands: 4 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `openrouter-models-finder` — OpenRouter Models Finder
- dir: `openrouter-models-finder` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `openrouter-quick-actions` — Openrouter Quick Actions
- dir: `openrouter-quick-actions` · commands: 5 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `openstatus` — OpenStatus
- dir: `openstatus` · commands: 5 · modes: view
- **Blockers:** declares AI tools[] (6) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `openstreetmap-search` — OpenStreetMap Search
- dir: `openstreetmap-search` · commands: 3 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `openverse` — Openverse
- dir: `openverse` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:RequestInit (not in Invoke surface — needs review); @raycast/api:existsSync (not in Invoke surface — needs review); @raycast/api:runAppleScript (not in Invoke surface — needs review); @raycast/api:useEffect (not in Invoke surface — needs review); @raycast/api:useRef (not in Invoke surface — needs review); @raycast/api:useState (not in Invoke surface — needs review)

### `openvpn` — OpenVPN
- dir: `openvpn` · commands: 3 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `opera` — Opera
- dir: `opera` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `opsgenie` — Opsgenie
- dir: `opsgenie` · commands: 2 · modes: view
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `opslevel` — OpsLevel
- dir: `opslevel` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `orbit` — Orbit
- dir: `orbit` · commands: 3 · modes: no-view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `orbstack` — OrbStack
- dir: `orbstack` · commands: 2 · modes: view
- **Blockers:** declares AI tools[] (7) — AI extensions not supported; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `origami` — Origami
- dir: `origami` · commands: 2 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; declares AI tools[] (7) — AI extensions not supported
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `orion` — Orion
- dir: `orion` · commands: 5 · modes: view
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `orshot` — Orshot
- dir: `orshot` · commands: 2 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `osint-web-check` — OSINT Web Check
- dir: `osint-web-check` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: dns, net, tls
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `osquery` — Osquery
- dir: `osquery` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `oss` — OSS
- dir: `aliyun-oss` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `oss-browser` — OSS Browser
- dir: `oss-browser` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openCommandPreferences: no-op; confirmAlert: always returns false (no dialog)

### `otp-auth` — OTP Auth
- dir: `otp-auth` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke); @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `otp-inbox` — OTP Inbox
- dir: `otp-inbox` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired
- Degraded: openExtensionPreferences: no-op
- Needs review: @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke)

### `otter` — Otter Bookmarks
- dir: `otter` · commands: 4 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menubar: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:useCachedPromise (not in Invoke surface — needs review); @raycast/utils:List (not implemented in Invoke); @raycast/utils:ActionPanel (not implemented in Invoke); @raycast/utils:Action (not implemented in Invoke); @raycast/utils:Icon (not implemented in Invoke); @raycast/utils:Detail (not implemented in Invoke); @raycast/utils:getPreferenceValues (not implemented in Invoke); @raycast/utils:Image (not implemented in Invoke); @raycast/utils:MenuBarExtra (not implemented in Invoke); @raycast/utils:open (not implemented in Invoke); @raycast/utils:Keyboard (not implemented in Invoke); @raycast/utils:openExtensionPreferences (not implemented in Invoke); @raycast/utils:useFetchRecentItems (not implemented in Invoke)

### `ottomatic` — Ottomatic
- dir: `ottomatic` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `oura` — Oura
- dir: `oura` · commands: 9 · modes: view|no-view|menu-bar
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; launchCommand: launchCommand not implemented; OAuth: OAuth.PKCEClient throws — OAuth not yet wired; unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `outline-document-search` — Outline Document Search
- dir: `outline-document-search` · commands: 2 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke); @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `outline-page` — Outline Page
- dir: `outline-page` · commands: 1 · modes: no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

### `ovhcloud` — OVHcloud
- dir: `ovh` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke); @raycast/utils:getFavicon (not implemented in Invoke)

### `owl` — Owl
- dir: `owl` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); captureException: no-op; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `oxford-collocation-dictionary` — Oxford Collocation Dictionary
- dir: `oxford-collocation-dictionary` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; launchCommand: launchCommand not implemented
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `pagerduty` — PagerDuty
- dir: `pagerduty` · commands: 3 · modes: view
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `pagespeed` — Pagespeed
- dir: `pagespeed` · commands: 2 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke); @raycast/utils:getFavicon (not implemented in Invoke)

### `palette-picker` — Color Palette Picker
- dir: `palette-picker` · commands: 2 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `pangu-for-raycast` — Pangu for Raycast
- dir: `pangu-for-raycast` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `paper` — Paper
- dir: `paper` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `paper-agent` — Paper Agent
- dir: `paper-agent` · commands: 11 · modes: view|no-view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: fs, child_process

### `paperform` — Paperform
- dir: `paperform` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored

### `paperless-ngx` — Paperless-ngx
- dir: `paperless-ngx` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `papermatch` — PaperMatch
- dir: `papermatch` · commands: 2 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op

### `paperspace` — Paperspace
- dir: `paperspace` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `papra` — Papra
- dir: `papra` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `parallels-virtual-machines` — Parallels Virtual Machines
- dir: `parallels-virtual-machines` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `parcel` — Parcel
- dir: `parcel` · commands: 2 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; declares AI tools[] (2) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored

### `parrot-translate` — Parrot Translate
- dir: `parrot-translate` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Needs review: @raycast/api:exec (not in Invoke surface — needs review); @raycast/api:execFile (not in Invoke surface — needs review); @raycast/api:COPY_TYPE (not in Invoke surface — needs review)

### `parse-logs` — Parse Logs
- dir: `parse-logs` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `party-parrot` — Party Parrot
- dir: `party-parrot` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `pass` — Pass
- dir: `pass` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `passbolt` — Passbolt
- dir: `passbolt` · commands: 5 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `passphrase-generator` — Passphrase Generator
- dir: `passphrase-generator` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `password-store` — Password Store
- dir: `password-store` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `password-strength` — Password Strength
- dir: `password-strength` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `paste-as-plain-text` — Paste as Plain Text
- dir: `paste-as-plain-text` · commands: 1 · modes: no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: captureException: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet

### `paste-safely` — Paste Safely
- dir: `paste-safely` · commands: 2 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `paste-to-markdown` — Paste to Markdown
- dir: `paste-to-markdown` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `pastery` — Pastery
- dir: `pastery` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `paynow` — Paynow.gg
- dir: `paynow` · commands: 5 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke); @raycast/utils:CachedPromiseOptions (not implemented in Invoke); @raycast/utils:PaginationOptions (not implemented in Invoke)

### `paystack` — Paystack
- dir: `paystack` · commands: 8 · modes: view
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:showToast (not implemented in Invoke); @raycast/utils:Toast (not implemented in Invoke); @raycast/utils:List (not implemented in Invoke); @raycast/utils:ActionPanel (not implemented in Invoke); @raycast/utils:Action (not implemented in Invoke); @raycast/utils:openExtensionPreferences (not implemented in Invoke); @raycast/utils:Icon (not implemented in Invoke); @raycast/utils:Form (not implemented in Invoke); @raycast/utils:Clipboard (not implemented in Invoke); @raycast/utils:confirmAlert (not implemented in Invoke); @raycast/utils:Alert (not implemented in Invoke)

### `pcloud` — pCloud
- dir: `pcloud` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: openExtensionPreferences: no-op
- Needs review: @raycast/utils:Response (not implemented in Invoke)

### `pdf-compression` — PDF Compression
- dir: `pdf-compression` · commands: 1 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `pdfsearch` — PDFSearch
- dir: `pdfsearch` · commands: 2 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `penflow-ai` — Penflow AI
- dir: `penflow-ai` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired

### `pera-explorer` — Pera Algorand Explorer
- dir: `pera-explorer` · commands: 1 · modes: view
- Needs review: @raycast/utils:Response (not implemented in Invoke)

### `performance-hud` — Metal Performance HUD
- dir: `performance-hud` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `perplexity-api` — Perplexity API
- dir: `perplexity-api` · commands: 15 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; declares AI tools[] (2) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `pestphp-documentation` — Pest Documentation
- dir: `pestphp-documentation` · commands: 1 · modes: view
- Needs review: @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `petal` — Petal - Offline Voice to Text
- dir: `petal` · commands: 5 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: openCommandPreferences: no-op

### `pexels` — Pexels
- dir: `pexels` · commands: 4 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired
- Degraded: openCommandPreferences: no-op; openExtensionPreferences: no-op

### `phonenumber-in-im` — Fast Chat With Phone Number in IM Apps
- dir: `phonenumber-in-im` · commands: 2 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `photoroom-image-editing` — Photoroom Image Editing
- dir: `photoroom-image-editing` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: captureException: no-op; openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)

### `php-docs` — PHP Documentation Search
- dir: `php-docs` · commands: 1 · modes: view
- Needs review: @raycast/api:getLocalStorageItem (not in Invoke surface — needs review); @raycast/api:removeLocalStorageItem (not in Invoke surface — needs review); @raycast/api:setLocalStorageItem (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `php-monitor` — PHP Monitor
- dir: `phpmon` · commands: 11 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `pi-drill` — Pi Drill
- dir: `pi-drill` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `pia-controls` — Private Internet Access Controls
- dir: `pia-controls` · commands: 4 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process

### `pianoman` — Pianoman
- dir: `pianoman` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `picgo` — PicGo
- dir: `picgo` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `pick-your-wallpaper` — Pick Your Wallpaper
- dir: `pick-your-wallpaper` · commands: 2 · modes: view|no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getSelectedFinderItems: throws — Finder selection not wired; declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: openExtensionPreferences: no-op; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `pie-for-pi-hole` — Pie for Pi-Hole
- dir: `pie-for-pihole` · commands: 16 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: http, https, fs
- Degraded: openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `pieces-raycast` — Pieces for Raycast
- dir: `pieces-raycast` · commands: 9 · modes: no-view|view
- **Blockers:** launchCommand: launchCommand not implemented; getSelectedFinderItems: throws — Finder selection not wired; getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/api:Preferences (not in Invoke surface — needs review); @raycast/api:BrowserExtension (not in Invoke surface — needs review); @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `pika` — Pika
- dir: `pika` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `pin` — Pin
- dir: `pin-raycast` · commands: 5 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: fs

### `pinata` — Pinata
- dir: `pinata` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)

### `pinboard` — Pinboard
- dir: `pinboard` · commands: 3 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `ping` — Ping
- dir: `ping` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ping-menu` — Ping Menu
- dir: `ping-menu` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): ping-monitor: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: declares background `interval` command(s) — not scheduled

### `pins` — Pins
- dir: `pins` · commands: 8 · modes: menu-bar|view|no-view
- **Blockers:** launchCommand: launchCommand not implemented; getApplications: throws — application discovery not wired; getSelectedText: throws — selection APIs not wired; getFrontmostApplication: throws — application discovery not wired; AI: AI.ask throws — Invoke AI not yet wired; unsupported command mode(s): index: mode "menu-bar"; denied Node built-ins in sandbox: fs, vm, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `pinwork` — Pinwork
- dir: `pinwork` · commands: 6 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `pip` — PiP
- dir: `pip` · commands: 2 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; getDefaultApplication: throws — application discovery not wired; getFrontmostApplication: throws — application discovery not wired
- Degraded: captureException: no-op; confirmAlert: always returns false (no dialog)

### `pipe-commands` — Pipe Commands
- dir: `pipe-commands` · commands: 4 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog)

### `pipedrive` — Pipedrive Search
- dir: `pipedrive` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op

### `pitchcast` — Pitchcast - Pitchfork Reviews Search
- dir: `pitchcast` · commands: 1 · modes: view
- Needs review: @raycast/utils:Response (not implemented in Invoke)

### `pivot` — Pivot
- dir: `pivot` · commands: 3 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `pixabay` — Pixabay
- dir: `pixabay` · commands: 2 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `placeholder` — Placeholder
- dir: `placeholder` · commands: 2 · modes: view|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired
- Degraded: openCommandPreferences: no-op; openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet

### `plane` — Plane
- dir: `plane` · commands: 3 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:getAvatarIcon (not implemented in Invoke); @raycast/utils:PaginationOptions (not implemented in Invoke)

### `planetscale` — PlanetScale
- dir: `planetscale` · commands: 5 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: confirmAlert: always returns false (no dialog)

### `planwell` — PlanWell
- dir: `planwell` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `plausible-analytics` — Plausible Analytics
- dir: `plausible-analytics` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `playnite-launcher` — Playnite Launcher
- dir: `playnite-launcher` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: openExtensionPreferences: no-op

### `plexamp` — Plexamp
- dir: `plexamp` · commands: 8 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): now-playing-menubar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled

### `plexus` — Plexus - Localhost Search
- dir: `plexus` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, net, fs
- Degraded: confirmAlert: always returns false (no dialog)

### `pm2` — PM2
- dir: `pm2` · commands: 2 · modes: view|no-view
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `podcasts-now` — Podcasts Now
- dir: `podcasts-now` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): podcasts-menubar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/api:Navigation (not in Invoke surface — needs review)

### `polar` — Polar
- dir: `polar` · commands: 3 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `polidict` — Polidict
- dir: `polidict` · commands: 6 · modes: view|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet

### `polished` — Polished
- dir: `polished` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:SubmitFormAction (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review); @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review)

### `pomo` — Pomo
- dir: `pomo` · commands: 8 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired

### `pomodoro` — Pomodoro
- dir: `pomodoro` · commands: 5 · modes: menu-bar|view
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): pomodoro-menu-bar: mode "menu-bar", slack-pomodoro-menu-bar: mode "menu-bar"; declares AI tools[] (4) — AI extensions not supported; denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `popcorn` — Popcorn - Explore Stremio Streams
- dir: `popcorn` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `popicons` — Popicons
- dir: `popicons` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: dns, fs

### `porkbun` — Porkbun
- dir: `porkbun` · commands: 8 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `port-from-project-name` — Port from Project Name
- dir: `port-from-project-name` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `port-manager` — Port Manager
- dir: `port-manager` · commands: 4 · modes: no-view|view|menu-bar
- **Blockers:** unsupported command mode(s): open-ports-menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw; openCommandPreferences: no-op; openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `portfolio-tracker` — Portfolio Tracker
- dir: `portfolio-tracker` · commands: 3 · modes: view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; declares AI tools[] (6) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw; declares extension-level `ai` instructions — ignored

### `portless` — Portless Active Routes
- dir: `portless` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `ports` — Port Manager
- dir: `ports` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `positron` — Positron
- dir: `positron` · commands: 3 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs, child_process

### `postey` — Postey
- dir: `postey` · commands: 5 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (4) — AI extensions not supported
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `power-management` — Power Management
- dir: `power-management` · commands: 5 · modes: view|no-view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): lowpower-menubar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled

### `powertoys-tool-runner` — PowerToys Tool Runner
- dir: `powertoys-tool-runner` · commands: 13 · modes: no-view
- Needs review: @raycast/utils:runPowerShellScript (not implemented in Invoke)

### `premier-league` — Premier League
- dir: `premier-league` · commands: 5 · modes: view
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `pretty-pr-link` — Pretty PR Link
- dir: `pretty-pr-link` · commands: 2 · modes: no-view
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `printer-status` — Printer Status
- dir: `printer-status` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored

### `prism-launcher` — Prism Launcher
- dir: `prism-launcher` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Needs review: @raycast/utils:runPowerShellScript (not implemented in Invoke)

### `pritunl` — Connect Pritunl Vpn Tunnel
- dir: `pritunl` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `privatebin` — PrivateBin
- dir: `privatebin` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `privileges` — Privileges
- dir: `privileges` · commands: 3 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process

### `productboard` — Productboard
- dir: `productboard` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `producthunt` — Product Hunt
- dir: `producthunt` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `productlane` — Productlane
- dir: `productlane` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `project-code-to-text` — Project Code to Text
- dir: `project-code-to-text` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:// Keep LaunchProps
  Clipboard (not in Invoke surface — needs review)

### `project-hub` — Project Hub
- dir: `project-hub` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke); @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `projects` — Projects
- dir: `projects` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `prompt-builder` — Prompt Builder
- dir: `prompt-builder` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `prompt-stash` — Prompt Stash
- dir: `prompt-stash` · commands: 3 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `promptlab` — PromptLab
- dir: `promptlab` · commands: 7 · modes: view|menu-bar
- **Blockers:** showInFinder: throws — showInFinder not wired; AI: AI.ask throws — Invoke AI not yet wired; launchCommand: launchCommand not implemented; getSelectedText: throws — selection APIs not wired; unsupported command mode(s): menubar-item: mode "menu-bar"; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `promptnote` — PromptNote
- dir: `promptnote` · commands: 6 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `pronounce-the-word` — Pronounce the Word
- dir: `pronounce-the-word` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog)

### `proton-authenticator` — Proton Authenticator
- dir: `proton-authenticator` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke); @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `proton-mail` — Proton Mail
- dir: `proton-mail` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op

### `proton-pass` — Proton Pass
- dir: `proton-pass` · commands: 5 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `proxmox` — Proxmox
- dir: `proxmox` · commands: 2 · modes: view
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `proxyman` — Proxyman
- dir: `proxyman` · commands: 13 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired

### `prusa` — Prusa Printer Control
- dir: `prusa` · commands: 4 · modes: view|menu-bar|no-view
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): printer-progress: mode "menu-bar"
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled

### `psn` — PSN
- dir: `psn` · commands: 3 · modes: no-view|view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op

### `public-bug-bounty-and-vulnerability-disclosure-programs` — Public Bug Bounty and Vulnerability Disclosure Programs
- dir: `public-bug-bounty-and-vulnerability-disclosure-programs` · commands: 1 · modes: view
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `pubme` — PubMe Search
- dir: `pubme` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:preferences (not in Invoke surface — needs review)

### `punto` — Punto Switcher
- dir: `punto` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `purelymail` — Purelymail
- dir: `purelymail` · commands: 11 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; launchCommand: launchCommand not implemented
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `purpleair` — PurpleAir
- dir: `purpleair` · commands: 1 · modes: view
- Degraded: openCommandPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:withCache (not implemented in Invoke)

### `putio` — put.io
- dir: `putio` · commands: 5 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `python` — Python
- dir: `python` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `qalc` — Qalccast
- dir: `qalc` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: openExtensionPreferences: no-op

### `qbitorrent` — qBittorrent
- dir: `qbittorrent` · commands: 2 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: fs

### `qmd` — QMD
- dir: `qmd` · commands: 13 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented; trash: throws — file trash not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `qoder` — Qoder
- dir: `qoder` · commands: 5 · modes: no-view|view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog)

### `qonto` — Qonto
- dir: `qonto` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `qotp` — QOTP
- dir: `qotp` · commands: 1 · modes: view
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `qq-mail` — QQ Mail
- dir: `qq-mail` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op

### `qr-code-scanner` — QR Code Scanner
- dir: `qr-code-scanner` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `qrcode-generator` — QR Code Generator
- dir: `qrcode-generator` · commands: 3 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs

### `qrcp` — QRCP
- dir: `qrcp` · commands: 2 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: http, fs

### `quarantine-manager` — Quarantine Manager
- dir: `quarantine-manager` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog)

### `quick-access` — Quick Access
- dir: `quick-access` · commands: 3 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; showInFinder: throws — showInFinder not wired; getFrontmostApplication: throws — application discovery not wired; getSelectedFinderItems: throws — Finder selection not wired; unsupported command mode(s): search-pins-menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: openCommandPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `quick-call` — Quick Phone Call
- dir: `quick-call` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `quick-git` — Quick Git
- dir: `quick-git` · commands: 2 · modes: view
- **Blockers:** getDefaultApplication: throws — application discovery not wired; launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke); @raycast/utils:getProgressIcon (not implemented in Invoke); @raycast/utils:useLocalStorage (not implemented in Invoke)

### `quick-jump` — Quick Jump
- dir: `quick-jump` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `quick-latex` — LaTeX to Image
- dir: `quick-latex` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `quick-notes` — Quick Notes
- dir: `quick-notes` · commands: 6 · modes: view|no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; trash: throws — file trash not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `quick-open-project` — Quick Open Project
- dir: `quick-open-project` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `quick-quit` — Quick Quit
- dir: `quick-quit` · commands: 4 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/api:// Import the Application type (not in Invoke surface — needs review)

### `quick-references` — Quick References
- dir: `quick-references` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `quick-search` — Quick Search
- dir: `quick-search` · commands: 4 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `quick-toshl` — Quick Toshl
- dir: `quick-toshl` · commands: 12 · modes: view
- **Blockers:** declares AI tools[] (25) — AI extensions not supported; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op; declares extension-level `ai` instructions — ignored

### `quicklinker` — QuickLinker
- dir: `quicklinker` · commands: 2 · modes: no-view|view
- Degraded: openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `quip` — Quip
- dir: `quip` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `quit-applications` — Quit Applications
- dir: `quit-applications` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `qutebrowser-tabs` — Qutebrowser Tabs
- dir: `qutebrowser-tabs` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `r2-uploader` — Cloudflare R2 File Uploader
- dir: `r2-uploader` · commands: 1 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: openExtensionPreferences: no-op

### `rabbit-hole` — Rabbit Hole
- dir: `rabbit-hole` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs, https
- Degraded: declares background `interval` command(s) — not scheduled

### `radix` — Radix
- dir: `radix` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `railway` — Railway Project Search
- dir: `railway` · commands: 2 · modes: view
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `raindrop-io` — Raindrop.io
- dir: `raindrop-io` · commands: 5 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; declares AI tools[] (4) — AI extensions not supported
- Degraded: confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review); @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:getFavicon (not implemented in Invoke)

### `ram-prices` — RAM Prices
- dir: `ram-prices` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): market-trends-menu-bar: mode "menu-bar"
- Needs review: @raycast/utils:withCache (not implemented in Invoke)

### `random-color` — Random Color
- dir: `random-color` · commands: 2 · modes: no-view|view
- Needs review: @raycast/api:randomColor (not in Invoke surface — needs review)

### `random-email` — Random Email
- dir: `random-email` · commands: 2 · modes: no-view
- Needs review: @raycast/api:copyTextToClipboard (not in Invoke surface — needs review); @raycast/api:pasteText (not in Invoke surface — needs review)

### `random-fart` — Random Fart
- dir: `random-fart` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `random-text-picker` — Random Text Picker
- dir: `random-text-picker` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `rapidcap` — RapidCap
- dir: `rapidcap` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ratingsdb` — RatingsDB
- dir: `ratingsdb` · commands: 2 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (1) — AI extensions not supported
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `ray-boop` — Ray Boop
- dir: `ray-boop` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `ray-clicker` — Ray Clicker
- dir: `ray-clicker` · commands: 1 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ray-code` — Ray Code
- dir: `ray-code` · commands: 1 · modes: view
- **Blockers:** trash: throws — file trash not wired; declares AI tools[] (9) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: openExtensionPreferences: no-op

### `ray-so` — ray.so
- dir: `ray-so` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `raycast-ai-custom-providers` — Raycast AI Custom Providers
- dir: `raycast-ai-custom-providers` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `raycast-airtable-extension` — Airtable
- dir: `airtable` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `raycast-arcade` — Raycast Arcade
- dir: `raycast-arcade` · commands: 6 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `raycast-bard-ai` — Google Bard
- dir: `raycast-bard-ai` · commands: 11 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `raycast-diki` — Diki Translate
- dir: `raycast-diki` · commands: 1 · modes: view
- Needs review: @raycast/api:getLocalStorageItem (not in Invoke surface — needs review); @raycast/api:randomId (not in Invoke surface — needs review); @raycast/api:removeLocalStorageItem (not in Invoke surface — needs review); @raycast/api:setLocalStorageItem (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `raycast-explorer` — Raycast Explorer
- dir: `raycast-explorer` · commands: 5 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; AI: AI.ask throws — Invoke AI not yet wired
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `raycast-focus-stats` — Raycast Focus Stats
- dir: `raycast-focus-stats` · commands: 3 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs, https
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled

### `raycast-gemini` — Google Gemini
- dir: `raycast-gemini` · commands: 16 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `raycast-google-palm` — Google PaLM
- dir: `raycast-google-palm` · commands: 10 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `raycast-ia-writer` — iA Writer
- dir: `raycast-ia-writer` · commands: 3 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `raycast-icons` — Raycast Icons
- dir: `raycast-icons` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `raycast-jq` — Jq
- dir: `raycast-jq` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox
- Needs review: @raycast/utils:AsyncState (not implemented in Invoke)

### `raycast-kozip-extension` — Kozip
- dir: `raycast-kozip-extension` · commands: 1 · modes: view
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `raycast-language-tool` — Language Tool - Spell & Grammar Checker
- dir: `language-tool` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `raycast-link-lock` — Link Lock - Password Locked Links
- dir: `raycast-link-lock` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `raycast-monkeytype-theme` — Raycast MonkeyType Theme Explorer
- dir: `raycast-monkeytype-theme` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired
- Degraded: confirmAlert: always returns false (no dialog)

### `raycast-motion-preview` — Motion Preview
- dir: `raycast-motion-preview` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `raycast-new-instance` — New Instance
- dir: `raycast-new-instance` · commands: 2 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process

### `raycast-norwegian-public-transport` — Norwegian Public Transport
- dir: `norwegian-public-transport` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review); @raycast/utils:getFavicon (not implemented in Invoke)

### `raycast-ollama` — Ollama AI
- dir: `raycast-ollama` · commands: 21 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; getSelectedText: throws — selection APIs not wired; getSelectedFinderItems: throws — Finder selection not wired; declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review); @raycast/utils:useLocalStorage (not implemented in Invoke); @raycast/utils:getProgressIcon (not implemented in Invoke)

### `raycast-port` — Raycast Port
- dir: `raycast-port` · commands: 3 · modes: no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: child_process
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review); @raycast/api:WindowManagement (not in Invoke surface — needs review)

### `raycast-rsync-extension` — Rsync File Transfer
- dir: `raycast-rsync-extension` · commands: 3 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `raycast-sink` — Sink Short Links Manager
- dir: `raycast-sink` · commands: 2 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw

### `raycast-store-updates` — Raycast Store Updates
- dir: `raycast-store-updates` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `raycast-surge` — Surge
- dir: `surge` · commands: 5 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: https
- Needs review: @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `raycast-svg64` — SVG64 - Convert SVGs to Base64 Strings
- dir: `raycast-svg64` · commands: 2 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs

### `raycast-svgo` — SVGO
- dir: `svgo` · commands: 3 · modes: view|no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs

### `raycast-system-monitor` — System Monitor
- dir: `system-monitor` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menubar-system-monitor: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled

### `raycast-tapo-smart-devices` — Tapo Smart Devices
- dir: `tapo-smart-devices` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"

### `raycast-timeular` — Timeular
- dir: `timeular` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:SubmitFormAction (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:PushAction (not in Invoke surface — needs review)

### `raycast-transistorfm` — TransistorFM
- dir: `raycast-transistorfm` · commands: 4 · modes: menu-bar|view
- **Blockers:** unsupported command mode(s): menu: mode "menu-bar"

### `raycast-urbandictionary-word-of-the-day` — Urban Dictionary Word of the Day
- dir: `raycast-urbandictionary-word-of-the-day` · commands: 3 · modes: no-view|view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: declares background `interval` command(s) — not scheduled

### `raycast-wallpaper` — Raycast Wallpaper
- dir: `raycast-wallpaper` · commands: 2 · modes: view|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired
- Degraded: captureException: no-op; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:runPowerShellScript (not implemented in Invoke)

### `raycast-zoxide` — Zoxide
- dir: `raycast-zoxide` · commands: 2 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: child_process
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `raycaster` — Raycaster
- dir: `raycaster` · commands: 2 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op

### `raydocs` — Raycast API Documentation
- dir: `raydocs` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported

### `raydoom` — RayDoom
- dir: `raydoom` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `raylog-markdown-tasks` — Raylog - Markdown Tasks
- dir: `raylog-markdown-tasks` · commands: 3 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar-task: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled

### `raynab` — Raynab — Manage Your Budgets
- dir: `raynab` · commands: 7 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): unreviewed: mode "menu-bar"; declares AI tools[] (6) — AI extensions not supported
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; captureException: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:useLocalStorage (not implemented in Invoke)

### `raytaskwarrior` — Taskwarrior
- dir: `raytaskwarrior` · commands: 3 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `razuna` — Razuna - Add and Browse Files in Razuna
- dir: `razuna` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `rclone-raycast` — rclone
- dir: `rclone-raycast` · commands: 4 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog)

### `react-devtools` — React DevTools
- dir: `react-devtools` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `react-docs` — React Documentation
- dir: `react-docs` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `react-icons` — React Icons
- dir: `react-icons` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `read-ai` — Read AI - Text to Speech
- dir: `read-ai` · commands: 3 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: openExtensionPreferences: no-op

### `readeck` — Readeck
- dir: `readeck` · commands: 2 · modes: view
- Needs review: @raycast/utils:Action (not implemented in Invoke); @raycast/utils:ActionPanel (not implemented in Invoke); @raycast/utils:Icon (not implemented in Invoke); @raycast/utils:Form (not implemented in Invoke); @raycast/utils:showToast (not implemented in Invoke); @raycast/utils:Toast (not implemented in Invoke); @raycast/utils:getPreferenceValues (not implemented in Invoke); @raycast/utils:List (not implemented in Invoke)

### `reader-mode` — Reader Mode
- dir: `reader-mode` · commands: 3 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review); @raycast/utils:useAI (not implemented in Invoke)

### `readwise-reader` — Readwise Reader
- dir: `readwise-reader` · commands: 11 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `readwise-to-tana` — Readwise to Tana
- dir: `readwise-to-tana` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getPreferenceValues (not implemented in Invoke)

### `real-calc` — Real Calc
- dir: `real-calc` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `real-debrid-manager` — Real-Debrid Manager
- dir: `real-debrid-manager` · commands: 5 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `rebaptize` — Rebaptize - Rename
- dir: `rebaptize` · commands: 40 · modes: view|no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs, child_process, https
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `rebrandly` — Rebrandly
- dir: `rebrandly` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `recent-excel` — Recent Excel - Show Recent Excel Files
- dir: `recent-excel` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `recents` — Recents
- dir: `recents` · commands: 5 · modes: view
- **Blockers:** trash: throws — file trash not wired
- Degraded: confirmAlert: always returns false (no dialog)

### `reclaim-ai` — Reclaim
- dir: `reclaim-ai` · commands: 6 · modes: menu-bar|view
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): notifications: mode "menu-bar"
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `rectangle` — Rectangle
- dir: `rectangle` · commands: 42 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: captureException: no-op

### `rednote-viewer` — RedNote Viewer
- dir: `rednote-viewer` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review); @raycast/utils:useAI (not implemented in Invoke)

### `reflect` — Reflect
- dir: `reflect` · commands: 6 · modes: view|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; getApplications: throws — application discovery not wired
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `refresh-browsers` — Refresh Browsers
- dir: `refresh-browsers` · commands: 1 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; getFrontmostApplication: throws — application discovery not wired
- Degraded: confirmAlert: always returns false (no dialog); captureException: no-op

### `regex-batch-renamer` — Regex Batch Renamer
- dir: `regex-batch-renamer` · commands: 3 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `regex-repl` — RegEx REPL
- dir: `regex-repl` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openCommandPreferences: no-op
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `regex-tester` — Regex Tester
- dir: `regex-tester` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `relagit` — RelaGit
- dir: `relagit` · commands: 2 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs

### `remember-the-date` — Remember the Date
- dir: `remember-the-date` · commands: 4 · modes: view|menu-bar|no-view
- **Blockers:** launchCommand: launchCommand not implemented; updateCommandMetadata: menu-bar/command metadata updates not implemented; unsupported command mode(s): menu-bar: mode "menu-bar"; declares AI tools[] (4) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled

### `remember-this` — Remember This
- dir: `remember-this` · commands: 3 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:ListItem (not in Invoke surface — needs review)

### `remix-icon` — Remix Icon
- dir: `remix-icon` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `remo-notes` — Remo
- dir: `remo-notes` · commands: 8 · modes: no-view|menu-bar|view
- **Blockers:** unsupported command mode(s): pinned-notes: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `remote-desktop` — Remote Desktop
- dir: `remote-desktop` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Needs review: @raycast/utils:runPowerShellScript (not implemented in Invoke)

### `remove-background` — Remove Background
- dir: `remove-background` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:SubmitFormAction (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `remove-background---replicate-api` — Remove Background
- dir: `remove-background---replicate-api` · commands: 1 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs

### `remove-background-powered-by-mac` — Remove Background - Powered by Mac
- dir: `remove-background-powered-by-mac` · commands: 1 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process, fs

### `remove-paywall` — Remove Paywall
- dir: `remove-paywall` · commands: 3 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `rename-images-with-ai` — Rename Images with AI
- dir: `rename-images-with-ai` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `renaming` — Renaming
- dir: `renaming` · commands: 3 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `render` — Render
- dir: `render` · commands: 1 · modes: view
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `replicate` — Replicate
- dir: `replicate` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); openCommandPreferences: no-op

### `repo-launcher` — Repo Launcher
- dir: `repo-launcher` · commands: 2 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `repository-manager` — Repository Manager
- dir: `repository-manager` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/api:useMemo (not in Invoke surface — needs review); @raycast/api:useCallback (not in Invoke surface — needs review); @raycast/api:useEffect (not in Invoke surface — needs review); @raycast/api:useRef (not in Invoke surface — needs review); @raycast/api:useState (not in Invoke surface — needs review); @raycast/api:existsSync (not in Invoke surface — needs review); @raycast/api:readFileSync (not in Invoke surface — needs review); @raycast/utils:Action (not implemented in Invoke); @raycast/utils:ActionPanel (not implemented in Invoke); @raycast/utils:AI (not implemented in Invoke); @raycast/utils:Detail (not implemented in Invoke); @raycast/utils:Icon (not implemented in Invoke); @raycast/utils:environment (not implemented in Invoke); @raycast/utils:useNavigation (not implemented in Invoke); @raycast/utils:Color (not implemented in Invoke); @raycast/utils:Image (not implemented in Invoke); @raycast/utils:List (not implemented in Invoke); @raycast/utils:Clipboard (not implemented in Invoke); @raycast/utils:Toast (not implemented in Invoke); @raycast/utils:showToast (not implemented in Invoke); @raycast/utils:confirmAlert (not implemented in Invoke); @raycast/utils:useEffect (not implemented in Invoke); @raycast/utils:useMemo (not implemented in Invoke); @raycast/utils:useRef (not implemented in Invoke); @raycast/utils:useState (not implemented in Invoke)

### `rescuetime-focus-session-trigger` — RescueTime
- dir: `rescuetime-focus-session-trigger` · commands: 8 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `research` — Deep Research
- dir: `deep-research` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored

### `resend` — Resend
- dir: `resend` · commands: 4 · modes: view
- **Blockers:** declares AI tools[] (12) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:getFavicon (not implemented in Invoke)

### `resend-wallpaper` — Resend Wallpaper
- dir: `resend-wallpaper` · commands: 2 · modes: view|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired
- Degraded: captureException: no-op; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled

### `respace` — Respace
- dir: `respace` · commands: 3 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `restart-system-processes` — Restart System Processes
- dir: `restart-system-processes` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `restore-photos` — Restore Photos
- dir: `restore-photo` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `retrac` — Retrac
- dir: `retrac` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: captureException: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `retrace` — Retrace Quick Actions
- dir: `retrace` · commands: 3 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `rhttp` — rhttp
- dir: `rhttp` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, https
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw

### `roam-research` — Roam Research
- dir: `roam-research` · commands: 10 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `roblox` — Roblox
- dir: `roblox` · commands: 9 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): favourite-game-players: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: openCommandPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `roblox-games` — Roblox
- dir: `roblox-games` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Needs review: @raycast/api:OpenAction (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:SubmitFormAction (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `rss-reader` — RSS Reader
- dir: `rss-reader` · commands: 3 · modes: view
- **Blockers:** declares AI tools[] (7) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review); @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:getFavicon (not implemented in Invoke)

### `rsync-commands` — Rsync Commands
- dir: `rsync-commands` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:FC (not in Invoke surface — needs review); @raycast/api:useCallback (not in Invoke surface — needs review); @raycast/api:memo (not in Invoke surface — needs review); @raycast/api:useState (not in Invoke surface — needs review); @raycast/api:useEffect (not in Invoke surface — needs review)

### `ruby-evaluate` — Ruby Evaluate
- dir: `ruby-evaluate` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `runcloud` — RunCloud
- dir: `runcloud` · commands: 3 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled

### `running-page` — Running Page
- dir: `running-page` · commands: 3 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menubar-totals: mode "menu-bar"
- Degraded: openCommandPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `sabnzbd` — SABnzbd
- dir: `sabnzbd` · commands: 8 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `safari` — Safari
- dir: `safari` · commands: 8 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented; AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (9) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `salesforce` — Salesforce Search
- dir: `salesforce-search` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: fs

### `sap-logon` — SAP GUI Connector
- dir: `sap-logon` · commands: 4 · modes: view|no-view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `saucenao` — SauceNAO - Reverse Image Search
- dir: `saucenao` · commands: 3 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `sav` — Sav
- dir: `sav` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `save-clipboard` — Save Clipboard
- dir: `save-clipboard` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `save-link` — Save Link
- dir: `save-link` · commands: 3 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `savvycal` — SavvyCal
- dir: `savvycal` · commands: 1 · modes: view
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `say` — Say - Text to Speech
- dir: `say` · commands: 5 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `say-no-to-notch` — Say No to Notch
- dir: `say-no-to-notch` · commands: 3 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: confirmAlert: always returns false (no dialog)

### `scheduler` — Command Scheduler
- dir: `scheduler` · commands: 4 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: confirmAlert: always returns false (no dialog); declares background `interval` command(s) — not scheduled

### `scira` — Scira
- dir: `scira` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `scoop` — Scoop
- dir: `scoop` · commands: 5 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `scrapbook` — Scrapbook
- dir: `scrapbook` · commands: 3 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented

### `scrapbox-search` — Scrapbox Search
- dir: `scrapbox-search` · commands: 1 · modes: view
- Needs review: @raycast/api:Response (not in Invoke surface — needs review); @raycast/api:useEffect (not in Invoke surface — needs review); @raycast/api:useState (not in Invoke surface — needs review); @raycast/utils:useEffect (not implemented in Invoke); @raycast/utils:useState (not implemented in Invoke)

### `scratchpad` — Scratchpad
- dir: `scratchpad` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired

### `scrcpy` — Scrcpy
- dir: `scrcpy` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `screen-math` — Screen Math
- dir: `screen-math` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `screen-saver` — Screen Saver
- dir: `screen-saver` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `screen-sharing-recents` — Screen Sharing Recents
- dir: `screen-sharing-recents` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `screenpipe` — Screenpipe
- dir: `screenpipe` · commands: 1 · modes: view
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `screenshot` — Screenshot
- dir: `screenshot` · commands: 8 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `script-commands` — Script Commands Store – Find and manage your Raycast Script Commands
- dir: `script-commands` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:ImageMask (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:OpenWithAction (not in Invoke surface — needs review); @raycast/api:PushAction (not in Invoke surface — needs review); @raycast/api:randomId (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review); @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review); @raycast/api:ImageLike (not in Invoke surface — needs review); @raycast/api:KeyboardShortcut (not in Invoke surface — needs review)

### `script-kit` — Run Script Kit Command
- dir: `script-kit` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `scrycast` — Scrycast
- dir: `scrycast` · commands: 5 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `scss-compile` — SCSS Compile
- dir: `scss-compile` · commands: 2 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `sdotee` — S.EE
- dir: `sdotee` · commands: 5 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog)

### `search-domain` — Search Domain
- dir: `search-domain` · commands: 2 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented

### `search-hex` — Search Hex
- dir: `search-hexpm` · commands: 1 · modes: view
- Needs review: @raycast/api:PushAction (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `search-hookmark` — Hookmark Search
- dir: `search-hookmark` · commands: 4 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `search-joplin-notes` — Search Joplin Notes
- dir: `search-joplin-notes` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired

### `search-notion` — Notion Page Search
- dir: `search-notion` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired
- Needs review: @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:OpenAction (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review); @raycast/api:getLocalStorageItem (not in Invoke surface — needs review); @raycast/api:setLocalStorageItem (not in Invoke surface — needs review)

### `search-private-npm-packages` — Private npm Packages Search
- dir: `search-private-npm-packages` · commands: 2 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired
- Degraded: confirmAlert: always returns false (no dialog)

### `search-regexp` — Regular Expressions Search
- dir: `search-regexp` · commands: 1 · modes: view
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `search-router` — Search Router
- dir: `search-router` · commands: 3 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet

### `search-with-algolia` — Search with Algolia
- dir: `algolia` · commands: 1 · modes: view
- Needs review: @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `searchcaster` — Searchcaster
- dir: `searchcaster` · commands: 2 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired

### `secret-browser-commands` — Secret Browser Commands
- dir: `secret-browser-commands` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `securecrt-sessions` — SecureCRT Sessions
- dir: `securecrt-sessions` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `seedsnote` — Seedsnote
- dir: `seedsnote` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `selfh-st-icons` — Selfh.st Icons
- dir: `selfh-st-icons` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `send-ai` — SendAI
- dir: `send-ai` · commands: 13 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; declares AI tools[] (23) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw; declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:withAccessToken (not implemented in Invoke)

### `send-to-e-reader` — Send to E-Reader
- dir: `send-to-e-reader` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `send-to-flomo` — Send to flomo
- dir: `send-to-flomo` · commands: 1 · modes: view
- Needs review: @raycast/api:FormValue (not in Invoke surface — needs review)

### `send-to-kindle` — Send to Kindle
- dir: `send-to-kindle` · commands: 6 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; launchCommand: launchCommand not implemented; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: net, tls, fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `sendme` — Sendme File Share
- dir: `sendme` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `sensible` — Sensible - Document Data Extraction
- dir: `sensible` · commands: 1 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `sentry` — Sentry
- dir: `sentry` · commands: 2 · modes: view
- Degraded: openCommandPreferences: no-op
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke); @raycast/utils:MutatePromise (not implemented in Invoke)

### `seo-lighthouse` — SEO Lighthouse
- dir: `seo-lighthouse` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: openCommandPreferences: no-op

### `sequel-ace` — Sequel Ace
- dir: `sequel-ace` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `sequoia-tiling` — Sequoia Window Tiling
- dir: `sequoia-tiling` · commands: 23 · modes: no-view
- **Blockers:** launchCommand: launchCommand not implemented

### `serialcast` — SerialCast
- dir: `serialcast` · commands: 3 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired

### `series-rating-graphs` — Series Rating Graphs
- dir: `series-rating-graphs` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op

### `servicenow` — ServiceNow
- dir: `servicenow` · commands: 15 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review); @raycast/utils:getAvatarIcon (not implemented in Invoke); @raycast/utils:MutatePromise (not implemented in Invoke)

### `sesh` — Sesh
- dir: `sesh` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `session` — Session - Pomodoro Focus Timer
- dir: `session` · commands: 7 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired

### `setapp` — Setapp
- dir: `setapp` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `setlist-fm` — setlist.fm
- dir: `setlist-fm` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported

### `sevalla` — Sevalla
- dir: `sevalla` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke); @raycast/utils:getFavicon (not implemented in Invoke)

### `seventv-search` — 7TV Emotes Search
- dir: `seventv-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `sf-symbols-search` — SF Symbols Search
- dir: `sf-symbols-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; confirmAlert: always returns false (no dialog)

### `shadcn-ui` — shadcn/ui
- dir: `shadcn-ui` · commands: 4 · modes: view
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `shakespearify` — Shakespearify
- dir: `shakespearify` · commands: 2 · modes: view
- Degraded: openCommandPreferences: no-op
- Needs review: @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `shape-calendar` — Shape Calendar
- dir: `shape-calendar` · commands: 3 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; declares AI tools[] (10) — AI extensions not supported
- Degraded: confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `share-a-quote` — Share a Quote
- dir: `share-a-quote` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `share-my-code` — Share My Code
- dir: `share-my-code` · commands: 3 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `sharex` — ShareX
- dir: `sharex` · commands: 9 · modes: view|no-view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `shell` — Shell
- dir: `shell` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `shell-alias` — Shell Alias
- dir: `shell-alias` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `shell-history` — Shell History
- dir: `shell-history` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getDefaultApplication: throws — application discovery not wired; trash: throws — file trash not wired; denied Node built-ins in sandbox: child_process
- Degraded: openCommandPreferences: no-op; openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); captureException: no-op

### `shiftplus` — ShiftPlus
- dir: `shiftplus` · commands: 3 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `shiori-sh` — Shiori
- dir: `shiori-sh` · commands: 4 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review); @raycast/utils:getFavicon (not implemented in Invoke)

### `shopify-polaris-docs` — Shopify Polaris Docs
- dir: `shopify-polaris-docs` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `shopinfo-app` — Shopinfo.app
- dir: `shopinfo-app` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired
- Degraded: openExtensionPreferences: no-op

### `short-io` — Short.io
- dir: `short-io` · commands: 4 · modes: view|menu-bar
- **Blockers:** getSelectedText: throws — selection APIs not wired; unsupported command mode(s): search-links-menu-bar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke); @raycast/utils:getFavicon (not implemented in Invoke)

### `shortcut` — Shortcut
- dir: `shortcut` · commands: 5 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke); @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `shortcuts-search` — Shortcuts Search
- dir: `shortcuts-search` · commands: 4 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: child_process
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke); @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `shottr` — Shottr
- dir: `shottr` · commands: 14 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `shroud-email` — Shroud.email
- dir: `shroud-email` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `shutdown-timer` — Shutdown Timer
- dir: `shutdown-timer` · commands: 3 · modes: no-view|view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; denied Node built-ins in sandbox: child_process
- Degraded: declares background `interval` command(s) — not scheduled

### `sidecar` — Sidecar
- dir: `sidecar` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `silent-mention` — Silent Mention
- dir: `silent-mention` · commands: 2 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `silent-mode` — Silent Mode
- dir: `silent-mode` · commands: 4 · modes: no-view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): silent-mode-menu-bar: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op

### `similarweb` — Similarweb
- dir: `similarweb` · commands: 2 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `simon` — Simon
- dir: `simon` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `simple-dictionary` — Simple Dictionary
- dir: `simple-dictionary` · commands: 3 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `simple-http` — Simple Http
- dir: `simple-http` · commands: 2 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: child_process

### `simple-icons` — Brand Icons - simpleicons.org
- dir: `simple-icons` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `simple-reminder` — Simple Reminder
- dir: `simple-reminder` · commands: 3 · modes: view|no-view|menu-bar
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; launchCommand: launchCommand not implemented; unsupported command mode(s): reminderMenuBar: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog); captureException: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled

### `simple-youdao` — Simple Youdao Translate
- dir: `simple-youdao` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `simpletexocr` — SimpleTexOCR
- dir: `simpletexocr` · commands: 2 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `simpread` — SimpRead
- dir: `simpread` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:ImageMask (not in Invoke surface — needs review); @raycast/api:PushAction (not in Invoke surface — needs review); @raycast/api:getLocalStorageItem (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `simulator-control` — Simulator Control
- dir: `simctl` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `simulator-manager` — Simulator Manager
- dir: `simulator-manager` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: openExtensionPreferences: no-op

### `single-disk-eject` — Single Disk Eject
- dir: `single-disk-eject` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `single-focus` — Single Focus
- dir: `single-focus` · commands: 1 · modes: no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired
- Degraded: confirmAlert: always returns false (no dialog)

### `sip` — Sip
- dir: `sip` · commands: 5 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired

### `sips` — Image Modification
- dir: `sips` · commands: 12 · modes: no-view|view
- **Blockers:** showInFinder: throws — showInFinder not wired; getFrontmostApplication: throws — application discovery not wired; declares AI tools[] (11) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process, https
- Degraded: openCommandPreferences: no-op; openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `siri` — Siri
- dir: `siri` · commands: 1 · modes: no-view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `sketch` — Sketch
- dir: `sketch` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review); @raycast/api:OpenAction (not in Invoke surface — needs review); @raycast/api:ImageMask (not in Invoke surface — needs review); @raycast/api:setLocalStorageItem (not in Invoke surface — needs review); @raycast/api:KeyEquivalent (not in Invoke surface — needs review); @raycast/api:clearLocalStorage (not in Invoke surface — needs review); @raycast/api:getLocalStorageItem (not in Invoke surface — needs review)

### `skills` — Skills
- dir: `skills` · commands: 2 · modes: view
- **Blockers:** declares AI tools[] (5) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `skyscanner-flights` — Flight Search
- dir: `skyscanner-flights` · commands: 2 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired

### `slack` — Slack
- dir: `slack` · commands: 9 · modes: view|no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getApplications: throws — application discovery not wired; declares AI tools[] (6) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review); @raycast/utils:runPowerShellScript (not implemented in Invoke); @raycast/utils:useAI (not implemented in Invoke); @raycast/utils:useFrecencySorting (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:WithAccessTokenComponentOrFn (not implemented in Invoke)

### `slack-status` — Slack Status
- dir: `slack-status` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:MutatePromise (not implemented in Invoke)

### `slack-summarizer` — Slack Summarizer
- dir: `slack-summarizer` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:withCache (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `slack-templated-message` — Slack Templated Message
- dir: `slack-templated-message` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `slackmojis` — Slackmojis
- dir: `slackmojis` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `sleep-timer` — Sleep Timer
- dir: `sleep-timer` · commands: 8 · modes: no-view|view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): timersMenuBar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `slowed-reverb` — Slowed + Reverb
- dir: `slowed-reverb` · commands: 4 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: child_process

### `slugify-file-folder-names` — Slugify File / Folder Names
- dir: `slugify-file-folder-names` · commands: 1 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs

### `sm-ms` — SM.MS
- dir: `sm-ms` · commands: 5 · modes: view|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)

### `smallweb` — Smallweb
- dir: `smallweb` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review); @raycast/utils:getFavicon (not implemented in Invoke); @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `smart-calendars-ai-create-events-using-ai` — Smart Calendars AI – Create Events / Reminders Using AI
- dir: `smart-calendars-ai-create-events-using-ai` · commands: 3 · modes: no-view|view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs

### `smart-reply` — Smart Reply - AI-Powered Multilingual Response Generator
- dir: `smart-reply` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `smartthings-connector` — SmartThings Connector
- dir: `smartthings-connector` · commands: 5 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:ToastStyle (not in Invoke surface — needs review); @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review); @raycast/api:// useNavigation (not in Invoke surface — needs review); @raycast/api:// Entfernen Sie diesen Import
  Action (not in Invoke surface — needs review)

### `smultron` — Smultron
- dir: `smultron` · commands: 1 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; getSelectedText: throws — selection APIs not wired

### `snake` — Snake
- dir: `snake` · commands: 1 · modes: view
- Needs review: @raycast/api:Environment (not in Invoke surface — needs review)

### `snap-jot` — SnapJot
- dir: `snap-jot` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op

### `snapocr-via-paddle` — SnapOCR Via Paddle
- dir: `snapocr-via-paddle` · commands: 3 · modes: no-view|view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process, fs

### `sniffer` — Sniffer
- dir: `sniffer` · commands: 1 · modes: view
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `snippetslab` — SnippetsLab
- dir: `snippetslab` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs

### `snippetsurfer` — Snippet Surfer
- dir: `snippetsurfer` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `social-network-trends` — Social Network Trends
- dir: `social-network-trends` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): search-trends-of-social-network-menu-bar: mode "menu-bar"
- Degraded: openCommandPreferences: no-op; openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled

### `solana_nodes` — Solana Nodes
- dir: `nodes` · commands: 2 · modes: menu-bar|view
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menuBarStats: mode "menu-bar"

### `solana-explorer` — Solana Explorer
- dir: `solana-explorer` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `solusvm-2` — SolusVM 2
- dir: `solusvm-2` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke); @raycast/utils:MutatePromise (not implemented in Invoke)

### `somafm` — SomaFM
- dir: `somafm` · commands: 2 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar-player: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: declares background `interval` command(s) — not scheduled

### `sonos` — Sonos
- dir: `sonos` · commands: 7 · modes: no-view|view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; updateCommandMetadata: menu-bar/command metadata updates not implemented; unsupported command mode(s): now-playing: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `sort-mentions` — Sort Mentions
- dir: `sort-mentions` · commands: 2 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process

### `soundboard` — Soundboard
- dir: `soundboard` · commands: 11 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented; updateCommandMetadata: menu-bar/command metadata updates not implemented; denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `sourcegraph` — Sourcegraph
- dir: `sourcegraph` · commands: 7 · modes: view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; launchCommand: launchCommand not implemented; OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: http
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getProgressIcon (not implemented in Invoke)

### `sourcegraph-amp-dash-x` — Amp Dash X
- dir: `sourcegraph-amp-dash-x` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `sourcetree` — Sourcetree
- dir: `sourcetree` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: openExtensionPreferences: no-op

### `spacer` — Spacer
- dir: `spacer` · commands: 2 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `spaces` — Spaces
- dir: `spaces` · commands: 3 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process

### `spaceship` — Spaceship
- dir: `spaceship` · commands: 2 · modes: no-view|view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `spanish-tv-guide` — Spanish TV Guide
- dir: `spanish-tv-guide` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `spatie-documentation` — Spatie Documentation
- dir: `spatie-documentation` · commands: 5 · modes: view
- Needs review: @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `specify` — Specify
- dir: `specify` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `speech-to-text` — Speech to Text
- dir: `speech-to-text` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; launchCommand: launchCommand not implemented; trash: throws — file trash not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `speedtest` — Speedtest
- dir: `speedtest` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog)

### `spiceblow-database` — Spiceblow - Sql Database Management
- dir: `spiceblow-database` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:createDeeplink (not implemented in Invoke); @raycast/utils:DeeplinkType (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:getAvatarIcon (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `spike` — Spike
- dir: `spike` · commands: 6 · modes: view|menu-bar
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; unsupported command mode(s): openIncidents: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `spirii-go` — Spirii Go
- dir: `spirii-go` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: openExtensionPreferences: no-op

### `split-video-scenes` — Split Video Scenes
- dir: `split-video-scenes` · commands: 1 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog)

### `splix` — Splix
- dir: `splix` · commands: 2 · modes: view|no-view
- Needs review: @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `spoiler-converter` — Discord Spoiler Spammer
- dir: `spoiler-converter` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; getFrontmostApplication: throws — application discovery not wired

### `sportssync` — Sportssync
- dir: `sportssync` · commands: 20 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): live-scores-menubar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `spotify-controls` — Spotify Controls
- dir: `spotify-controls` · commands: 22 · modes: no-view|menu-bar
- **Blockers:** getApplications: throws — application discovery not wired; unsupported command mode(s): menuBarPlayer: mode "menu-bar"
- Degraded: openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `spotify-player` — Spotify Player
- dir: `spotify-player` · commands: 35 · modes: view|menu-bar|no-view
- **Blockers:** launchCommand: launchCommand not implemented; OAuth: OAuth.PKCEClient throws — OAuth not yet wired; updateCommandMetadata: menu-bar/command metadata updates not implemented; AI: AI.ask throws — Invoke AI not yet wired; getApplications: throws — application discovery not wired; unsupported command mode(s): nowPlayingMenuBar: mode "menu-bar"; declares AI tools[] (7) — AI extensions not supported
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openCommandPreferences: no-op; confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:runPowerShellScript (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `spring-initializr` — Spring Initializr
- dir: `spring-initializr` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `sql-format` — Format SQL
- dir: `sql-format` · commands: 4 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ssh-manager` — SSH Connection Manager
- dir: `ssh-manager` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `ssh-tunnel-manager` — SSH Tunnel Manager
- dir: `ssh-tunnel-manager` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `stablecog` — Stablecog
- dir: `stablecog` · commands: 5 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `stackoverflow` — Search Stack Exchange Sites
- dir: `stackoverflow` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:getLocalStorageItem (not in Invoke surface — needs review); @raycast/api:setLocalStorageItem (not in Invoke surface — needs review)

### `standing-desk-tracker` — Standing Desk Tracker
- dir: `standing-desk-tracker` · commands: 4 · modes: view|menu-bar|no-view
- **Blockers:** unsupported command mode(s): standing-desk-menubar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `stardew-valley-wiki` — Stardew Vally Character Search
- dir: `stardew-valley-wiki` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `stashit` — Stashit
- dir: `stashit` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `static-marks` — Static Marks - Bookmark Search
- dir: `static-marks-bookmarks` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `stealth-ai-tool` — Stealth AI
- dir: `stealth-ai-tool` · commands: 10 · modes: view|no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired; launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: child_process, https
- Degraded: declares extension-level `ai` instructions — ignored

### `steam` — Steam
- dir: `steam` · commands: 1 · modes: view
- **Blockers:** trash: throws — file trash not wired; AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openCommandPreferences: no-op
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `steamgriddb` — SteamGridDB
- dir: `steamgriddb` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `stickies` — Stickies
- dir: `stickies` · commands: 7 · modes: view|menu-bar|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; getFrontmostApplication: throws — application discovery not wired; launchCommand: launchCommand not implemented; unsupported command mode(s): menubar-stickies: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: captureException: no-op; openCommandPreferences: no-op; openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `stockholm-public-transport` — Stockholm Public Transport
- dir: `stockholm-public-transport` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `storybook-sandboxes` — Storybook Sandboxes
- dir: `storybook-sandboxes` · commands: 2 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; getDefaultApplication: throws — application discovery not wired
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `streamshare-uploader` — Streamshare Uploader
- dir: `to-streamshare` · commands: 4 · modes: no-view|view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: fs

### `stretchly` — Stretchly
- dir: `stretchly` · commands: 2 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `stripe` — Stripe
- dir: `stripe` · commands: 16 · modes: view|no-view
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `subflow` — Subflow
- dir: `subflow` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled

### `sublime` — Sublime
- dir: `sublime` · commands: 7 · modes: view|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `subnoto` — Subnoto - Confidential Electronic Signature
- dir: `subnoto` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `substack` — Substack
- dir: `substack` · commands: 2 · modes: view
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `summarize-youtube-video-with-ai` — Summarize YouTube Videos with AI
- dir: `summarize-youtube-video-with-ai` · commands: 5 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `summation` — Summation - Sum Calculator
- dir: `summation` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `sun-moon-times` — Sun/Moon Times
- dir: `sun-moon-times` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:List (not implemented in Invoke)

### `supabase-cron-monitor` — Supabase Cron Monitor
- dir: `supabase-cron-monitor` · commands: 3 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menubar-cron-monitor: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; openCommandPreferences: no-op

### `supergenpass` — SuperGenPass
- dir: `superpassgen` · commands: 1 · modes: view
- Needs review: @raycast/api:useState (not in Invoke surface — needs review)

### `superhuman` — Superhuman
- dir: `superhuman` · commands: 1 · modes: no-view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `supernotes` — Supernotes
- dir: `supernotes` · commands: 4 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; declares AI tools[] (3) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `supernova` — Supernova
- dir: `supernova` · commands: 6 · modes: view|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:Asset (not in Invoke surface — needs review); @raycast/api:AssetGroup (not in Invoke surface — needs review); @raycast/api:Component (not in Invoke surface — needs review); @raycast/api:DesignComponent (not in Invoke surface — needs review); @raycast/api:DesignSystemVersion (not in Invoke surface — needs review); @raycast/api:DocSearchResultData (not in Invoke surface — needs review); @raycast/api:DocumentationGroup (not in Invoke surface — needs review); @raycast/api:DocumentationPage (not in Invoke surface — needs review); @raycast/api:Token (not in Invoke surface — needs review); @raycast/api:TokenGroup (not in Invoke surface — needs review); @raycast/api:DesignSystem (not in Invoke surface — needs review); @raycast/api:Supernova (not in Invoke surface — needs review); @raycast/api:Workspace (not in Invoke surface — needs review); @raycast/api:AssetFormat (not in Invoke surface — needs review); @raycast/api:AssetScale (not in Invoke surface — needs review); @raycast/api:ComponentPropertyLinkElementType (not in Invoke surface — needs review); @raycast/api:ComponentPropertyType (not in Invoke surface — needs review); @raycast/api:RenderedAsset (not in Invoke surface — needs review)

### `superwhisper` — Superwhisper - Offline Voice to Text
- dir: `superwhisper` · commands: 6 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: openCommandPreferences: no-op

### `surfed` — Surfed
- dir: `surfed` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `svelte-docs` — Search Svelte Docs
- dir: `svelte-docs` · commands: 2 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported

### `svg-studio` — SVG Studio
- dir: `svg-studio` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `svgl` — Svgl
- dir: `svgl` · commands: 3 · modes: view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: openCommandPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw; declares extension-level `ai` instructions — ignored

### `svgr` — SVGR
- dir: `svgr` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `swap-commas-dots` — Swap Commas & Dots
- dir: `swap-commas-dots` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `swift-command` — Swift Command
- dir: `swift-command` · commands: 2 · modes: view
- **Blockers:** getDefaultApplication: throws — application discovery not wired; getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `swift-repl` — Swift REPL
- dir: `swift-repl` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `swipe-photo-cleaner` — Swipe Photo Cleaner
- dir: `swipe-photo-cleaner` · commands: 2 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; trash: throws — file trash not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `sync-folders` — Sync Folders
- dir: `sync-folders` · commands: 6 · modes: menu-bar|view|no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; launchCommand: launchCommand not implemented; getSelectedFinderItems: throws — Finder selection not wired; unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `synology-download-station` — Synology Download Station
- dir: `synology-download-station` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `synonyms` — Synonyms
- dir: `synonyms` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `system-information` — System Information
- dir: `system-information` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (5) — AI extensions not supported; denied Node built-ins in sandbox: child_process
- Degraded: declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `tabby` — Tabby
- dir: `tabby` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `tableplus` — TablePlus
- dir: `tableplus` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menubar: mode "menu-bar"; declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `tablepro` — TablePro
- dir: `tablepro` · commands: 9 · modes: view|no-view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar-connections: mode "menu-bar"; declares AI tools[] (12) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:withCache (not implemented in Invoke)

### `tabler` — Tabler
- dir: `tabler` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `tabstash` — TabStash
- dir: `tabstash` · commands: 2 · modes: view|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:getFavicon (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `tails` — Tails
- dir: `tails` · commands: 4 · modes: view|no-view|menu-bar
- **Blockers:** getSelectedText: throws — selection APIs not wired; launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `tailscale` — Tailscale
- dir: `tailscale` · commands: 11 · modes: view|no-view|menu-bar
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; unsupported command mode(s): menubar: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled

### `tailwindcss` — Tailwind CSS
- dir: `tailwindcss` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `tallinn-transport` — Tallinn Transport
- dir: `tallinn-transport` · commands: 3 · modes: view
- Needs review: @raycast/utils:withCache (not implemented in Invoke)

### `tasklink` — Tasklink
- dir: `tasklink` · commands: 2 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `tategaki` — Tategaki
- dir: `tategaki` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `teak-raycast` — Teak
- dir: `teak-raycast` · commands: 8 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; declares AI tools[] (6) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review); @raycast/api:Tool (not in Invoke surface — needs review)

### `team-time` — Team Time
- dir: `team-time` · commands: 4 · modes: view|no-view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; updateCommandMetadata: menu-bar/command metadata updates not implemented; unsupported command mode(s): teamTimeMenuBar: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `telegram` — Telegram
- dir: `telegram` · commands: 5 · modes: view
- **Blockers:** declares AI tools[] (4) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `teleport` — Teleport
- dir: `teleport` · commands: 6 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares command `arguments[]` — not passed by runtime yet

### `tella` — Tella
- dir: `tella` · commands: 4 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op

### `tembo` — Tembo
- dir: `tembo` · commands: 3 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menubar-tasks: mode "menu-bar"; declares AI tools[] (2) — AI extensions not supported
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled

### `tempmail` — TempMail
- dir: `tempmail` · commands: 2 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `terminal-image-paste` — Terminal Image Paste
- dir: `terminal-image-paste` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `terminaldotshop` — Terminal Shop
- dir: `terminaldotshop` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `terminalfinder` — Terminal Finder
- dir: `terminalfinder` · commands: 22 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `tesla-energy` — Tesla Energy
- dir: `tesla-energy` · commands: 2 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; OAuth: OAuth.PKCEClient throws — OAuth not yet wired; AI: AI.ask throws — Invoke AI not yet wired; unsupported command mode(s): menu-bar-status: mode "menu-bar"
- Degraded: openCommandPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke)

### `text-decorator` — Text Decorator
- dir: `text-decorator` · commands: 3 · modes: no-view|view
- **Blockers:** launchCommand: launchCommand not implemented; updateCommandMetadata: menu-bar/command metadata updates not implemented; getSelectedText: throws — selection APIs not wired
- Degraded: openCommandPreferences: no-op; openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet

### `text-differ` — Text Differ
- dir: `text-differ` · commands: 1 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process

### `text-enhance` — Text Enhance
- dir: `text-enhance` · commands: 2 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `text-format-improver` — CJK Text Format Improver
- dir: `text-format-improver` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `text-replacements` — Text Replacements
- dir: `text-replacements` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `text-rewrap` — Text Rewrap
- dir: `text-rewrap` · commands: 3 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `text-shortcuts` — Text Shortcuts
- dir: `text-shortcuts` · commands: 4 · modes: view|menu-bar
- **Blockers:** getSelectedText: throws — selection APIs not wired; unsupported command mode(s): shortcut-library-menu-bar: mode "menu-bar"
- Degraded: confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `textream` — Textream
- dir: `textream` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: captureException: no-op

### `tfl` — TFL
- dir: `tfl` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): favourite-stop-points: mode "menu-bar"

### `tflink-tmpfile` — Tflink Tmpfile
- dir: `tflink-tmpfile` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `thaw` — Thaw
- dir: `thaw` · commands: 7 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired

### `the-blue-cloud` — The Blue Cloud
- dir: `the-blue-cloud` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `the-nobel-prize` — The Nobel Prize
- dir: `the-nobel-prize` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `thesaurus` — Thesaurus
- dir: `thesaurus` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `things` — Things
- dir: `things` · commands: 10 · modes: view|menu-bar|no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; launchCommand: launchCommand not implemented; unsupported command mode(s): show-today-in-menu-bar: mode "menu-bar"; declares AI tools[] (12) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `thock` — Thock
- dir: `thock` · commands: 2 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `threads` — Threads
- dir: `threads` · commands: 9 · modes: no-view|view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ticktick` — TickTick
- dir: `ticktick` · commands: 6 · modes: view|no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired; declares AI tools[] (3) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `tidal` — Tidal
- dir: `tidal` · commands: 12 · modes: menu-bar|view|no-view
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menubar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs, http
- Degraded: openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled

### `tidal-controller` — Tidal Controller
- dir: `tidal-controller` · commands: 10 · modes: no-view|menu-bar
- **Blockers:** unsupported command mode(s): now-playing-menu-bar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `tidyread---streamline-your-daily-reading` — TidyRead - Streamline Your Daily Reading
- dir: `tidyread---streamline-your-daily-reading` · commands: 5 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; launchCommand: launchCommand not implemented; AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: fs, http, child_process
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares background `interval` command(s) — not scheduled

### `tiktoken` — Tiktoken
- dir: `tiktoken` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `tikz` — TikZ
- dir: `tikz` · commands: 1 · modes: view
- **Blockers:** trash: throws — file trash not wired; declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs

### `tim` — Tim
- dir: `tim` · commands: 7 · modes: no-view|view
- **Blockers:** showInFinder: throws — showInFinder not wired; getSelectedFinderItems: throws — Finder selection not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: captureException: no-op; confirmAlert: always returns false (no dialog)

### `time-awareness` — Time Awareness
- dir: `time-awareness` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): time-awareness-menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: declares background `interval` command(s) — not scheduled

### `time-logs` — Time Logs
- dir: `time-logs` · commands: 6 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menuBarTimer: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke); @raycast/utils:useLocalStorage (not implemented in Invoke)

### `time-machine` — Time Machine
- dir: `time-machine` · commands: 4 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `time-teller` — Time Teller
- dir: `time-teller` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired

### `time-tracking` — Time Tracking
- dir: `time-tracking` · commands: 5 · modes: view|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired; launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `timecamp` — TimeCamp
- dir: `timecamp` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `timely` — Timely
- dir: `timely` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `timers` — Timers
- dir: `timers` · commands: 19 · modes: no-view|view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): timersMenuBar: mode "menu-bar", stopwatchMenuBar: mode "menu-bar"; declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `timezone-buddy` — Timezone Buddy
- dir: `timezone-buddy` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): timezone-buddy-menubar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `tinyimg` — TinyIMG
- dir: `tinyimg` · commands: 1 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs

### `tinypng` — TinyPNG
- dir: `tinypng` · commands: 2 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `tl-dr-ai-summary-tool` — TL;DR (Too Long; Didn't Read)
- dir: `tl-dr-ai-summary-tool` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: https
- Degraded: openExtensionPreferences: no-op
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `tldr` — TLDR Pages
- dir: `tldr` · commands: 1 · modes: view
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `tldv` — Tldv Meetings
- dir: `tldv` · commands: 4 · modes: view|menu-bar|no-view
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): recent-meetings: mode "menu-bar"
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `tmux-cheatsheet` — Tmux Cheatsheet
- dir: `tmux-cheatsheet` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `tmux-sessioner` — Tmux Sessioner
- dir: `tmux-sessioner` · commands: 4 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `tny` — Tny
- dir: `tny` · commands: 3 · modes: view|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; getSelectedText: throws — selection APIs not wired

### `todo-list` — Todo List
- dir: `todo-list` · commands: 2 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu_bar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review); @raycast/utils:getFavicon (not implemented in Invoke)

### `todoist` — Todoist
- dir: `todoist` · commands: 11 · modes: view|no-view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; OAuth: OAuth.PKCEClient throws — OAuth not yet wired; getApplications: throws — application discovery not wired; unsupported command mode(s): menu-bar: mode "menu-bar"; declares AI tools[] (29) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openCommandPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:useLocalStorage (not implemented in Invoke)

### `toggl-track` — Toggl Track
- dir: `toggl-track` · commands: 7 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menuBar: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review); @raycast/utils:CachedPromiseOptions (not implemented in Invoke)

### `toggle-desktop-visibility` — Toggle Desktop Visibility
- dir: `toggle-desktop-visibility` · commands: 6 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `toggle-menu-bar` — Toggle Menu Bar
- dir: `toggle-menu-bar` · commands: 1 · modes: no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; denied Node built-ins in sandbox: child_process

### `toggle-proxy` — Toggle Proxy
- dir: `toggle-proxy` · commands: 6 · modes: menu-bar|view
- **Blockers:** unsupported command mode(s): menu-bar-proxy: mode "menu-bar"; denied Node built-ins in sandbox: fs, net
- Degraded: confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `toggle-scroll-bars-visibility` — Toggle Scroll Bars Visibility
- dir: `toggle-scroll-bars-visibility` · commands: 5 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `tokenizer` — Tokenizer
- dir: `tokenizer` · commands: 2 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `tomito-controls` — Tomito Controls
- dir: `tomito-controls` · commands: 8 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired

### `toncoin-price` — Toncoin (TON) Price
- dir: `toncoin-price` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): index: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `toneclone` — ToneClone
- dir: `toneclone` · commands: 7 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: openCommandPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review); @raycast/api:KeyEquivalent (not in Invoke surface — needs review)

### `toothpick` — Toothpick
- dir: `toothpick` · commands: 19 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: openExtensionPreferences: no-op; declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `torbox` — TorBox
- dir: `torbox` · commands: 3 · modes: view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs

### `torr-manager` — Torr Manager
- dir: `torr-manager` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `tourbox` — TourBox
- dir: `tourbox` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `tower` — Tower Repositories
- dir: `tower` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `trakt-manager` — Trakt Manager
- dir: `trakt-manager` · commands: 7 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: fs
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `transfer-sh_upload` — Transfer.sh Uploader
- dir: `transfer-sh_upload` · commands: 1 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs

### `translate` — Google Translate
- dir: `google-translate` · commands: 6 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: https, child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `translate-send-webpage-to-reader` — Translate and Send Webpage to Reader
- dir: `translate-send-webpage-to-reader` · commands: 1 · modes: no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `transmission` — Transmission
- dir: `transmission` · commands: 3 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `transmit` — Transmit
- dir: `transmit` · commands: 1 · modes: view
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `transport-nsw` — Transport NSW
- dir: `transport-nsw` · commands: 2 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar-trips: mode "menu-bar"; declares AI tools[] (5) — AI extensions not supported
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled

### `trek` — Trek
- dir: `trek` · commands: 6 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented; OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke); @raycast/utils:getProgressIcon (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `trenit` — Trenit
- dir: `trenit` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:createDeeplink (not implemented in Invoke)

### `trimmy` — Trimmy
- dir: `trimmy` · commands: 3 · modes: no-view|view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; getSelectedText: throws — selection APIs not wired

### `trovu` — Trovu - Web Search Command Line
- dir: `trovu` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `trustmrr` — TrustMRR
- dir: `trustmrr` · commands: 2 · modes: view
- Degraded: openExtensionPreferences: no-op
- Needs review: @raycast/utils:withCache (not implemented in Invoke)

### `try` — Try
- dir: `try` · commands: 1 · modes: view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `turso` — Turso
- dir: `turso` · commands: 3 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: http
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `twenty` — Twenty
- dir: `twenty` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:ItemProps (not in Invoke surface — needs review); @raycast/api:FormItemRef (not in Invoke surface — needs review)

### `twitch` — Twitch
- dir: `twitch` · commands: 4 · modes: view|menu-bar
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; launchCommand: launchCommand not implemented; unsupported command mode(s): live: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `twitter` — Twitter
- dir: `twitter` · commands: 4 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op

### `twitter-video-downloader` — X/Twitter Video Downloader
- dir: `twitter-video-downloader` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `two-factor-authentication-code-generator` — Two-Factor Authentication Code Generator
- dir: `two-factor-authentication-code-generator` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `type-the-alphabet` — Type the Alphabet
- dir: `type-the-alphabet` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review)

### `typefully` — Typefully
- dir: `typefully` · commands: 5 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (4) — AI extensions not supported
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `typer` — Typer - Custom Text Hotkey
- dir: `typer` · commands: 5 · modes: no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: openCommandPreferences: no-op

### `typewhisper` — TypeWhisper
- dir: `typewhisper` · commands: 5 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `typographer` — Typographer: Make Text Pretty
- dir: `typographer` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `typora-note-creator` — Typora Note Creator
- dir: `typora-note-creator` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: openExtensionPreferences: no-op

### `u301-url-shortener` — U301 URL Shortener
- dir: `u301-url-shortener` · commands: 3 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `ugly-face` — Ugly Face
- dir: `ugly-face` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:render (not in Invoke surface — needs review)

### `uk-bank-holidays` — UK Bank Holidays
- dir: `uk-bank-holidays` · commands: 2 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: declares background `interval` command(s) — not scheduled

### `ultrahuman` — Ultrahuman
- dir: `ultrahuman` · commands: 3 · modes: view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: openExtensionPreferences: no-op
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `ulysses` — Ulysses
- dir: `ulysses` · commands: 5 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired
- Needs review: @raycast/api:SubmitFormAction (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review)

### `umami` — Umami
- dir: `umami` · commands: 4 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): view-websites-menu-bar: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `unicode-symbols` — Unicode Symbols Search
- dir: `unicode-symbols` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs

### `unifi` — Unifi
- dir: `unifi` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: https
- Degraded: openCommandPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke); @raycast/utils:getProgressIcon (not implemented in Invoke)

### `united-nations` — United Nations
- dir: `united-nations` · commands: 5 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired
- Degraded: confirmAlert: always returns false (no dialog)

### `universal-commands` — Universal Commands
- dir: `universal-commands` · commands: 3 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; getFrontmostApplication: throws — application discovery not wired
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `universal-inbox` — Universal Inbox
- dir: `universal-inbox` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke); @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `universities` — Universities
- dir: `universities` · commands: 1 · modes: view
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `unpackr` — Unpackr
- dir: `unpackr` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `unsplash` — Unsplash
- dir: `unsplash` · commands: 4 · modes: view|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: fs
- Degraded: declares background `interval` command(s) — not scheduled

### `untis` — Untis
- dir: `untis` · commands: 1 · modes: view
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `update-clash-subscription` — Update Clash Subscription
- dir: `update-clash-subscription` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `uploaderx` — UploaderX
- dir: `uploaderx` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, https
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `uploadthing` — UploadThing
- dir: `uploadthing` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)

### `upnote` — UpNote
- dir: `upnote` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `upset-dev` — Upset.dev
- dir: `upset-dev` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `upstash` — Upstash
- dir: `upstash` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke)

### `uptime` — Uptime
- dir: `uptime` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `uptime-kuma` — Uptime Kuma
- dir: `uptime-kuma` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `uptime-robot` — UptimeRobot
- dir: `uptime-robot` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `uranium-raycast-plugin` — NFT Primitive Tools
- dir: `uranium-raycast-plugin` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `url-editor-pro` — URL Editor Pro
- dir: `url-editor-pro` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `url-parse` — URL Parse
- dir: `url-parse` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `url-shortener` — URL Shortener
- dir: `url-shortener` · commands: 2 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `url-unshortener` — URL Unshortener
- dir: `url-unshortener` · commands: 2 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `user-agent` — User-Agent Parser
- dir: `user-agent` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `userplane` — Userplane
- dir: `userplane` · commands: 4 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `utm-virtual-machines` — UTM Virtual Machines
- dir: `utm-virtual-machines` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `v0-by-vercel` — v0 by Vercel
- dir: `v0-by-vercel` · commands: 6 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `v2box-control` — V2BOX VPN
- dir: `v2box-control` · commands: 4 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `v2ex` — v2ex
- dir: `v2ex` · commands: 1 · modes: view
- Needs review: @raycast/api:CopyToClipboardAction (not in Invoke surface — needs review); @raycast/api:OpenInBrowserAction (not in Invoke surface — needs review); @raycast/api:ToastStyle (not in Invoke surface — needs review); @raycast/api:preferences (not in Invoke surface — needs review)

### `vade-mecum` — Vade Mecum
- dir: `vade-mecum` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

### `val-town` — Val Town
- dir: `val-town` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `vault-manager` — Vault Manager
- dir: `vault` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: http, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw

### `vercast` — Vercel
- dir: `vercast` · commands: 9 · modes: view|menu-bar|no-view
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar-deployments: mode "menu-bar"; declares AI tools[] (9) — AI extensions not supported
- Degraded: confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `vesslo` — Vesslo
- dir: `vesslo` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog)

### `viacep` — ViaCEP
- dir: `viacep` · commands: 2 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `video-call-reactions` — Video Call Reactions
- dir: `video-call-reactions` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `video-converter` — Video Converter
- dir: `video-converter` · commands: 2 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; getSelectedFinderItems: throws — Finder selection not wired; getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `video-downloader` — Video Downloader
- dir: `video-downloader` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review); @raycast/utils:withCache (not implemented in Invoke)

### `vikunja` — Vikunja Task Manager
- dir: `vikunja` · commands: 4 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `vim-bro` — Vim Bro - Search Vim Commands
- dir: `vim-bro` · commands: 1 · modes: view
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `vim-leader-key` — Vim Leader Key - Keyboard Shortcut Sequences
- dir: `vim-leader-key` · commands: 4 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getSelectedFinderItems: throws — Finder selection not wired; getSelectedText: throws — selection APIs not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `virtfusion` — VirtFusion
- dir: `virtfusion` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `virtual-desktop-manager` — Virtual Desktop Manager
- dir: `virtual-desktop-manager` · commands: 35 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `virtual-pet` — Virtual Pet
- dir: `virtual-pet` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: confirmAlert: always returns false (no dialog); declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `virtualizor-enduser` — Virtualizor Enduser
- dir: `virtualizor-enduser` · commands: 4 · modes: view
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke); @raycast/utils:getProgressIcon (not implemented in Invoke)

### `virustotal` — VirusTotal
- dir: `virustotal` · commands: 1 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: net, fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `visual-studio-code` — Visual Studio Code
- dir: `visual-studio-code-recent-projects` · commands: 6 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getSelectedFinderItems: throws — Finder selection not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:runPowerShellScript (not implemented in Invoke)

### `vivaldi` — Vivaldi
- dir: `vivaldi` · commands: 5 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `vivapb` — VivaPB
- dir: `vivapb` · commands: 1 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process

### `vixai` — Vixai
- dir: `vixai` · commands: 5 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:withAccessToken (not implemented in Invoke)

### `vlc` — VLC
- dir: `vlc` · commands: 22 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `vmware-vcenter` — VMware VCenter
- dir: `vmware-vcenter` · commands: 4 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; declares AI tools[] (5) — AI extensions not supported
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:runPowerShellScript (not implemented in Invoke)

### `vn-textify` — VN Textify
- dir: `vn-textify` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `vocabuilder` — VocaBuilder
- dir: `vocabuilder` · commands: 3 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `voice-to-text-windows` — Voice-to-Text for Windows
- dir: `voice-to-text-windows` · commands: 3 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog)

### `voiceink` — VoiceInk
- dir: `voiceink` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: openExtensionPreferences: no-op; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `voicemeeter-raycast` — Voicemeeter Control
- dir: `voicemeeter-raycast` · commands: 5 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `vortex` — Vortex
- dir: `vortex` · commands: 4 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `vps-explorer` — VPS Explorer
- dir: `vps-explorer` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `vscode-project-manager` — Visual Studio Code - Project Manager
- dir: `visual-studio-code-project-manager` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `vuejobs` — VueJobs
- dir: `vuejobs` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"

### `wakatime` — Wakatime
- dir: `wakatime` · commands: 4 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): today-summary: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `waktu-solat` — Waktu Solat
- dir: `waktu-solat` · commands: 2 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled

### `wallhaven` — Wallhaven
- dir: `wallhaven` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `warp` — Warp
- dir: `warp` · commands: 5 · modes: view|no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process

### `watchkey` — Watchkey
- dir: `watchkey` · commands: 5 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog)

### `wave` — Wave
- dir: `wave` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `wayback-machine` — Wayback Machine
- dir: `wayback-machine` · commands: 4 · modes: no-view|view
- **Blockers:** launchCommand: launchCommand not implemented; getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `weather` — Weather
- dir: `weather` · commands: 2 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menubar: mode "menu-bar"
- Degraded: openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled

### `web-blocker` — Web Blocker
- dir: `web-blocker` · commands: 5 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `web-page-design-mode` — Web Page Design Mode
- dir: `web-page-design-mode` · commands: 1 · modes: no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

### `webbites` — WebBites
- dir: `webbites` · commands: 2 · modes: view|no-view
- Degraded: openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `webdav-uploader` — WebDAV Uploader
- dir: `webdav-uploader` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `webflow-sites` — Webflow
- dir: `webflow-sites` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: openExtensionPreferences: no-op
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `webpage-to-markdown` — Webpage to Markdown
- dir: `webpage-to-markdown` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `website-blocker` — Website Blocker
- dir: `website-blocker` · commands: 2 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `wechat` — WeChat
- dir: `wechat` · commands: 2 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog)

### `wechat-devtool` — WeChat DevTool
- dir: `wechat-devtool` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `week-number` — Week Number
- dir: `week-number` · commands: 2 · modes: menu-bar|view
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): week-number: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `weread-sync` — WeRead Sync
- dir: `weread-sync` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: https
- Needs review: @raycast/api:getLocalStorageItem (not in Invoke surface — needs review); @raycast/api:setLocalStorageItem (not in Invoke surface — needs review)

### `wezterm-navigator` — WezTerm Navigator
- dir: `wezterm-navigator` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `whatsapp` — WhatsApp
- dir: `whatsapp` · commands: 4 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `whentomeet` — WhenToMeet
- dir: `whentomeet` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored

### `whimsical` — Whimsical
- dir: `whimsical` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored

### `whisper` — Whisper - Share Secrets
- dir: `whisper` · commands: 2 · modes: no-view|view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `whisper-dictation` — Whisper Dictation
- dir: `whisper-dictation` · commands: 5 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: child_process, fs, https
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)

### `whitebit` — WhiteBIT Exchange
- dir: `whitebit` · commands: 7 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `whmcs-client-search` — WHMCS Client Search
- dir: `whmcs-client-search` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `whoop` — WHOOP
- dir: `whoop` · commands: 3 · modes: no-view|view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getProgressIcon (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `wi-fi` — Wi-Fi
- dir: `wi-fi` · commands: 2 · modes: no-view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): wi-fi-signal: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled

### `wifi-password-reveal` — WiFi Password Reveal
- dir: `wifi-password-reveal` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `wifi-share` — Wifi Share QR-Code
- dir: `wifi-share` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `wikipedia` — Wikipedia
- dir: `wikipedia` · commands: 4 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented; declares AI tools[] (1) — AI extensions not supported
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `windmill` — Windmill
- dir: `windmill` · commands: 4 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `window-layouts` — Window Layouts
- dir: `window-layouts` · commands: 27 · modes: no-view|view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/api:WindowManagement (not in Invoke surface — needs review)

### `window-sizer` — Window Sizer
- dir: `window-sizer` · commands: 2 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openCommandPreferences: no-op

### `window-walker` — Window Walker
- dir: `window-walker` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `windows-default-wallpapers` — Windows Default Wallpapers
- dir: `windows-default-wallpapers` · commands: 1 · modes: view
- Needs review: @raycast/utils:runPowerShellScript (not implemented in Invoke)

### `windows-domain` — Windows Domain
- dir: `windows-domain` · commands: 2 · modes: view
- Needs review: @raycast/utils:runPowerShellScript (not implemented in Invoke)

### `windows-environment-variables` — Windows Environment Variables
- dir: `windows-environment-variables` · commands: 3 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `windows-terminal` — Windows Terminal
- dir: `windows-terminal` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `windsurf` — Windsurf Extension
- dir: `windsurf` · commands: 2 · modes: no-view|view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: child_process, fs

### `winget` — WinGet
- dir: `winget` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `winscp` — WinSCP
- dir: `winscp` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `winutils` — Winutils
- dir: `winutils` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `wip` — WIP
- dir: `wip` · commands: 4 · modes: view|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; updateCommandMetadata: menu-bar/command metadata updates not implemented; denied Node built-ins in sandbox: fs
- Degraded: declares background `interval` command(s) — not scheduled

### `wireguard` — Wireguard
- dir: `wireguard` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `wise-accounts` — Wise Accounts
- dir: `wise-accounts` · commands: 4 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): display-balances: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `wise-quotes` — Wise Quotes
- dir: `wise-quotes` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): current-rate: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `wispr-flow` — Wispr Flow
- dir: `wispr-flow` · commands: 8 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw

### `withings-sync` — Withings Sync
- dir: `withings-sync` · commands: 3 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: fs

### `wiz-controller` — Wiz Controller
- dir: `wiz-controller` · commands: 5 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: dgram
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `wol` — Wake-On-LAN
- dir: `wol` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, dgram, net
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `woocommerce-quicker` — WooCommerce Quicker
- dir: `woocommerce-quicker` · commands: 4 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: https
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `word-count` — Word Count
- dir: `word-count` · commands: 3 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: confirmAlert: always returns false (no dialog)

### `word-search` — Word Search
- dir: `word-search` · commands: 8 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `word4you` — Word4you
- dir: `word4you` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, https, child_process
- Degraded: openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `wordle` — Wordle
- dir: `wordle` · commands: 3 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented
- Degraded: confirmAlert: always returns false (no dialog)

### `wordpress-docs` — WordPress Docs
- dir: `wordpress-docs` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `wordreference` — WordReference Dictionary Translation
- dir: `wordreference` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `work-time-countdown` — Work Time Countdown
- dir: `work-time-countdown` · commands: 1 · modes: menu-bar
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; unsupported command mode(s): index: mode "menu-bar"
- Degraded: openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled

### `workouts` — Workouts
- dir: `workouts` · commands: 6 · modes: view|menu-bar
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; unsupported command mode(s): menubar-totals: mode "menu-bar"; declares AI tools[] (6) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: openCommandPreferences: no-op; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:useLocalStorage (not implemented in Invoke)

### `worktrees` — Git Worktrees
- dir: `worktrees` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op

### `world-clock` — World Clock
- dir: `world-clock` · commands: 3 · modes: view|menu-bar
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): query-world-time-menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: net
- Degraded: openCommandPreferences: no-op; openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke); @raycast/utils:getAvatarIcon (not implemented in Invoke)

### `wp-bones` — WP Bones
- dir: `wp-bones` · commands: 5 · modes: menu-bar|view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `wppb` — WPPB
- dir: `wppb` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `wrap-text` — Wrap Text
- dir: `wrap-text` · commands: 6 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `wrap-unwrap` — Wrap Unwrap
- dir: `wrap-unwrap` · commands: 2 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; launchCommand: launchCommand not implemented

### `writersbrew` — Writersbrew
- dir: `writersbrew` · commands: 21 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process

### `wsl-manager` — WSL Manager
- dir: `wsl-manager` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `xcode` — Xcode
- dir: `xcode` · commands: 21 · modes: menu-bar|view|no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; launchCommand: launchCommand not implemented; getApplications: throws — application discovery not wired; unsupported command mode(s): show-recent-projects-in-menu-bar.command: mode "menu-bar", show-recent-builds-in-menu-bar.command: mode "menu-bar"; declares AI tools[] (14) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Navigation (not in Invoke surface — needs review); @raycast/api:Tool (not in Invoke surface — needs review)

### `xcode-cloud` — Xcode Cloud
- dir: `xcode-cloud` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `xcodes` — Xcodes
- dir: `xcodes` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `xecutor` — Xecutor
- dir: `xecutor` · commands: 2 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:clearSearchBar (not in Invoke surface — needs review)

### `xiaohe-query` — Xiaohe Query
- dir: `xiaohe-query` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `y-combinator` — Y Combinator
- dir: `y-combinator` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): demo-day-countdown: mode "menu-bar"
- Degraded: openCommandPreferences: no-op; declares background `interval` command(s) — not scheduled

### `yabai` — Yabai
- dir: `yabai` · commands: 31 · modes: no-view|menu-bar|view
- **Blockers:** unsupported command mode(s): screens-menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `yafw` — YAFW
- dir: `yafw` · commands: 7 · modes: view|no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; getFrontmostApplication: throws — application discovery not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `yandex-smart-home` — Yandex Smart Home
- dir: `yandex-smart-home` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: openExtensionPreferences: no-op

### `yasb` — YASB
- dir: `yasb` · commands: 12 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares command `arguments[]` — not passed by runtime yet

### `yazio-tracker` — Yazio Tracker
- dir: `yazio-tracker` · commands: 3 · modes: view
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `year-in-progress` — Year in Progress
- dir: `year-in-progress` · commands: 3 · modes: no-view|menu-bar|view
- **Blockers:** launchCommand: launchCommand not implemented; updateCommandMetadata: menu-bar/command metadata updates not implemented; unsupported command mode(s): index: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:getProgressIcon (not implemented in Invoke)

### `yoink` — Yoink
- dir: `yoink` · commands: 1 · modes: no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog)

### `yomicast` — Yomicast – Offline Japanese-English Dictionary
- dir: `yomicast` · commands: 2 · modes: view|no-view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: fs
- Degraded: declares background `interval` command(s) — not scheduled

### `youdao-translate` — Youdao Translate
- dir: `youdao-translate` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `your-name-in-landsat` — Your Name in Landsat
- dir: `your-name-in-landsat` · commands: 2 · modes: view
- **Blockers:** launchCommand: launchCommand not implemented; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `yourls` — YOURLS Link Shortener
- dir: `yourls` · commands: 2 · modes: view
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `youtrack` — YouTrack
- dir: `youtrack` · commands: 2 · modes: view
- **Blockers:** declares AI tools[] (7) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openCommandPreferences: no-op; openExtensionPreferences: no-op
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `youtube` — YouTube
- dir: `youtube` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `youtube-highlights` — YouTube Highlights
- dir: `youtube-highlights` · commands: 5 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `youtube-search` — YouTube Search
- dir: `youtube-search` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `youtube-shorts-to-normal-video-page` — YouTube Shorts to Normal Video Page
- dir: `youtube-shorts-to-normal-video-page` · commands: 1 · modes: no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

### `youtube-subscriber-count` — YouTube Subscriber Count
- dir: `youtube-subscriber-count` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): index: mode "menu-bar"
- Degraded: openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled

### `youtube-thumbnail` — YouTube Thumbnail
- dir: `youtube-thumbnail` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `yubikey-code` — YubiKey Code
- dir: `yubikey-code` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `zeabur` — Zeabur
- dir: `zeabur` · commands: 9 · modes: view|menu-bar
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; unsupported command mode(s): menu-bar-projects: mode "menu-bar", menu-bar-deployment: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `zed-recent-projects` — Zed
- dir: `zed-recent-projects` · commands: 3 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:runPowerShellScript (not implemented in Invoke)

### `zen-browser` — Zen Browser
- dir: `zen-browser` · commands: 6 · modes: view|no-view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:runPowerShellScript (not implemented in Invoke); @raycast/utils:getFavicon (not implemented in Invoke)

### `zen-mode` — Zen Mode
- dir: `zen-mode` · commands: 3 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process

### `zenblog` — Zenblog
- dir: `zenblog` · commands: 1 · modes: view
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

### `zenmux-manager` — ZenMux Manager
- dir: `zenmux-manager` · commands: 2 · modes: no-view|view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented; declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:name: "Search tool imports the routing table" (not in Invoke surface — needs review); @raycast/api:passed:
      searchTool.includes('from "../zenmux-doc-routing"') &&
      searchTool.includes("routingMatches") (not in Invoke surface — needs review); @raycast/utils:getProgressIcon (not implemented in Invoke)

### `zeplin-project-raycast-extension` — Zeplin Project Search
- dir: `zeplin-project-search` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired

### `zerion` — Zerion
- dir: `zerion` · commands: 9 · modes: view|menu-bar|no-view
- **Blockers:** launchCommand: launchCommand not implemented; unsupported command mode(s): menu-bar-wallet: mode "menu-bar"; declares AI tools[] (7) — AI extensions not supported
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `zero` — Zero
- dir: `zero` · commands: 1 · modes: no-view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `zerossl` — ZeroSSL
- dir: `zerossl` · commands: 2 · modes: view
- Needs review: @raycast/utils:getFavicon (not implemented in Invoke)

### `zipcodebase` — Zipcodebase
- dir: `zipcodebase` · commands: 8 · modes: view|no-view
- **Blockers:** updateCommandMetadata: menu-bar/command metadata updates not implemented
- Degraded: openExtensionPreferences: no-op; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `zipic` — Zipic
- dir: `zipic` · commands: 3 · modes: no-view|view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; getApplications: throws — application discovery not wired; declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: fs, https, http, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `zipline` — Zipline
- dir: `zipline` · commands: 4 · modes: view|no-view
- **Blockers:** getSelectedFinderItems: throws — Finder selection not wired; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `znotch` — Manage Macbook's Notch
- dir: `znotch` · commands: 3 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired

### `zoo` — Zoo - Ask AIs with Your Prompt Library
- dir: `zoo` · commands: 3 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; getFrontmostApplication: throws — application discovery not wired
- Degraded: openCommandPreferences: no-op; openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:MutatePromise (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `zoom` — Zoom
- dir: `zoom` · commands: 5 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): this-week-meetings: mode "menu-bar"; declares AI tools[] (6) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:MutatePromise (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `zotero` — Search Zotero
- dir: `zotero` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `zoxide-git-projects` — Zoxide Git Projects
- dir: `zoxide-git-projects` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `zread-ai` — Zread.ai
- dir: `zread-ai` · commands: 2 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:BrowserExtension (not in Invoke surface — needs review)

### `zsh-aliases` — Zsh Aliases
- dir: `zsh-aliases` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `zshrc-manager` — Zshrc Manager
- dir: `zshrc-manager` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useFrecencySorting (not implemented in Invoke)

### `zyntra` — Zyntra
- dir: `zyntra` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)
- Needs review: @raycast/utils:useLocalStorage (not implemented in Invoke)

## DEGRADED (475)

### `40-questions` — 40 Questions - Yearly Reflection
- dir: `40-questions` · commands: 3 · modes: view|no-view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `adguard-home` — AdGuard Home
- dir: `adguard-home` · commands: 9 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)

### `ai-by-vercel` — AI by Vercel
- dir: `ai-by-vercel` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `ai-usage-tracker` — AI Usage Tracker
- dir: `ai-usage-tracker` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `algorand` — Algorand
- dir: `algorand` · commands: 8 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `alpaca-trading` — Alpaca Trading
- dir: `alpaca-trading` · commands: 2 · modes: view
- Degraded: captureException: no-op; confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `amazon-search` — Amazon Search
- dir: `amazon-search` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)

### `anki` — Anki
- dir: `anki` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `anna-s-archive` — Anna's Archive
- dir: `anna-s-archive` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `apple-maps-search` — Apple Maps Search
- dir: `apple-maps-search` · commands: 3 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `arc-helper` — Arc Helper
- dir: `arc-helper` · commands: 7 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `area-code-lookup` — Area & Country Codes
- dir: `area-code-lookup` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `asciimath-to-latex-converter` — AsciiMath to LaTeX Converter
- dir: `asciimath-to-latex-converter` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `aspect-raytio` — Aspect Raytio
- dir: `aspect-raytio` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `atomberg-raycast-extension` — Atomberg - Smart Home Control
- dir: `atomberg-raycast-extension` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)

### `attio` — Attio
- dir: `attio` · commands: 6 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `auth0-management` — Auth0 Management
- dir: `auth0-management` · commands: 7 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `beancount-meta` — Beancount Meta
- dir: `beancount-mate` · commands: 1 · modes: view
- Degraded: openCommandPreferences: no-op

### `beardtown` — Beardtown
- dir: `beardtown` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `beat-per-minute` — BPM Calculator
- dir: `beat-per-minute` · commands: 1 · modes: view
- Degraded: openCommandPreferences: no-op

### `bech32-converter` — Bech32 Converter
- dir: `bech32-converter` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `bed-time-calculator` — Bed Time Calculator
- dir: `bed-time-calculator` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `beeminder` — Beeminder
- dir: `beeminder` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `bento` — Bento Email
- dir: `bento` · commands: 13 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `betaseries` — BetaSeries
- dir: `betaseries` · commands: 5 · modes: view
- Degraded: openExtensionPreferences: no-op

### `better-deal` — Better Deal
- dir: `better-deal` · commands: 2 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `betterdiscord-store` — BetterDiscord Store
- dir: `betterdiscord-search` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `bettertouchtool` — BetterTouchTool
- dir: `bettertouchtool` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `bibigpt-summarize-audiovideo-with-ai` — BibiGPT AI Summarize Audio and Video
- dir: `bibigpt-summarize-audiovideo-with-ai` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `bitfinex` — Bitfinex
- dir: `bitfinex` · commands: 4 · modes: view|no-view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled

### `blockchain-explorer-search` — Blockchain Explorer Search
- dir: `blockchain-explorer-search` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `blockchain-gas-tracker` — Blockchain Gas Tracker
- dir: `blockchain-gas-tracker` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `braintick` — Braintick
- dir: `braintick` · commands: 7 · modes: view
- Degraded: openExtensionPreferences: no-op

### `brawlstars` — Brawl Stars Search
- dir: `brawlstars` · commands: 3 · modes: view
- Degraded: openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `bsr-entsorgung` — BSR Entsorgung
- dir: `bsr-entsorgung` · commands: 2 · modes: view
- Degraded: openExtensionPreferences: no-op

### `buddy` — Buddy
- dir: `buddy` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `buildkite` — Buildkite
- dir: `buildkite` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)

### `bundesliga` — Bundesliga
- dir: `bundesliga` · commands: 3 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `bunq` — Bunq
- dir: `bunq` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `caaals` — Caaals Food Tracker
- dir: `caaals` · commands: 2 · modes: view
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `cacher` — Cacher - Code Snippet Organizer
- dir: `cacher` · commands: 2 · modes: view
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `calendar` — Quick Calendar
- dir: `calendar` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `camper-calc` — Camper Van Cost Tracker
- dir: `camper-calc` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)

### `canvascast` — CanvasCast
- dir: `canvascast` · commands: 2 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `capacities` — Capacities
- dir: `capacities` · commands: 5 · modes: view
- Degraded: openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw

### `capture` — Capture
- dir: `capture` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); openCommandPreferences: no-op

### `cardpointers` — CardPointers
- dir: `cardpointers` · commands: 4 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ccfddl` — CCF Conference
- dir: `ccfddl` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `cdnjs` — cdnjs
- dir: `cdnjs` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `center` — Center
- dir: `center` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `chatwith` — Chatwith
- dir: `chatwith` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `chhoto` — Chhoto
- dir: `chhoto` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)

### `china-ip-address` — China IP Address
- dir: `china-ip-address` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `chinese-converter` — Chinese Converter
- dir: `chinese-converter` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cider` — Cider
- dir: `cider` · commands: 12 · modes: view|no-view
- Degraded: openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `cidr` — CIDR Conversion
- dir: `cidr` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `clarify` — Clarify
- dir: `clarify` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `clash` — Clash
- dir: `clash` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `cloudflare-ai` — Cloudflare Workers AI
- dir: `cloudflare-ai` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `cloudflare-email-routing` — Cloudflare Email Routing
- dir: `cloudflare-email-routing` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `cloudinary` — Cloudinary
- dir: `cloudinary` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cnpj-lookup` — CNPJ Lookup
- dir: `cnpj-lookup` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cocoa-core-data-timestamp-converter` — Cocoa Core Data Timestamp Converter
- dir: `cocoa-core-data-timestamp-converter` · commands: 3 · modes: no-view
- Degraded: confirmAlert: always returns false (no dialog)

### `cognimemo` — CogniMemo
- dir: `cognimemo` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op

### `collected-notes` — Collected Notes
- dir: `collected-notes` · commands: 2 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)

### `color-shades` — Color Shades
- dir: `color-shades` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `commit-issue-parser` — Commit Issue Parser
- dir: `commit-issue-parser` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `control-d` — Control D
- dir: `control-d` · commands: 5 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)

### `converter` — Converter
- dir: `converter` · commands: 3 · modes: view
- Degraded: openCommandPreferences: no-op; openExtensionPreferences: no-op

### `convex` — Convex
- dir: `convex` · commands: 10 · modes: view|no-view
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `cookie-string-parser` — Cookie String
- dir: `cookie-string-parser` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `copy-skeet-link` — Copy Skeet Link
- dir: `copy-skeet-link` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `count-numbers` — Count Numbers
- dir: `count-numbers` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `covert-color` — Convert Color
- dir: `covert-color` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cratecast` — crates.io Search
- dir: `cratecast` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `crisp` — Crisp
- dir: `crisp` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `cryptgeon` — cryptgeon
- dir: `cryptgeon` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cuid2-generator` — Cuid2 Generator
- dir: `cuid2-generator` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `curator-bio` — Curator Bio
- dir: `curator-bio` · commands: 3 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `currency-exchange` — Currency Exchange
- dir: `currency-exchange` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `custom-wordle` — Custom Wordle
- dir: `custom-wordle` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `danbooru` — Danbooru
- dir: `danbooru` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `danish-tax-calculator` — Danish Tax Calculator
- dir: `danish-tax-calculator` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `datahub` — Datahub Utility
- dir: `datahub` · commands: 2 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `datawrapper` — Datawrapper
- dir: `datawrapper` · commands: 5 · modes: view|no-view
- Degraded: openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `date-format-converter` — Date Format Converter
- dir: `datetime-format-converter` · commands: 2 · modes: view|no-view
- Degraded: openCommandPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `decimal-2-time` — Decimal 2 Time
- dir: `decimal-2-time` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `defichain-lottery` — Defichain Lottery
- dir: `defichain-lottery` · commands: 4 · modes: view|no-view
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `defly-io` — Defly.io
- dir: `defly-io` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `denmarks-address-web-api` — DAWA - Danish Address Web API
- dir: `dawa` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `designer-news` — Designer News
- dir: `designer-news` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `dev-to` — DEV Community
- dir: `dev-to` · commands: 3 · modes: view
- Degraded: openCommandPreferences: no-op; openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `devcontainer-features` — DevContainer Features
- dir: `devcontainer-features` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `devenv-docs` — DevEnv Docs
- dir: `devenv-docs` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; openExtensionPreferences: no-op

### `devin` — Devin
- dir: `devin` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `devpod` — DevPod
- dir: `devpod` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `dexcom-reader` — Dexcom Reader
- dir: `dexcom-reader` · commands: 1 · modes: view
- Degraded: openCommandPreferences: no-op

### `dia-skills` — Dia Skills
- dir: `dia-skills` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `diff-checker` — Diff Checker
- dir: `diff-checker` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `dig` — Dig - DNS Lookup
- dir: `dig` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `discogs` — Discogs Database Search
- dir: `discogs` · commands: 4 · modes: view
- Degraded: openExtensionPreferences: no-op

### `discordjs-documentation` — Discord.js Documentation
- dir: `discordjs-documentation` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `display-reinitializer` — Display Reinitializer
- dir: `display-reinitializer` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `django-docs` — Django Docs
- dir: `django-docs` · commands: 2 · modes: view|no-view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares background `interval` command(s) — not scheduled

### `dns-lookup` — DNS Lookup
- dir: `dns-lookup` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `dockerhub` — Docker Hub
- dir: `dockerhub` · commands: 5 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)

### `docsearch` — DocSearch
- dir: `docsearch` · commands: 45 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `dodo-payments` — Dodo Payments
- dir: `dodo-payments` · commands: 9 · modes: view
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `dolar-hoy` — Dolar Hoy Argentina
- dir: `dolar-hoy` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `doppler-share-secrets` — Doppler Share Secrets
- dir: `doppler-share-secrets` · commands: 3 · modes: view
- Degraded: openCommandPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `dribbble` — Dribbble
- dir: `dribbble` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `dropstab` — DropsTab
- dir: `dropstab` · commands: 6 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ducat` — Ducat
- dir: `ducat` · commands: 1 · modes: no-view
- Degraded: openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `duden` — Duden
- dir: `duden` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `easings` — Easings
- dir: `easings` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ebird` — eBird
- dir: `ebird` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `email-verifier` — Email Verifier
- dir: `email-verifier` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `end-of-life` — End of Life
- dir: `end-of-life` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `epoch-to-timestamp` — Epoch to Timestamp
- dir: `epoch-to-timestamp` · commands: 1 · modes: no-view
- Degraded: confirmAlert: always returns false (no dialog)

### `esa-search` — esa Search
- dir: `esa-search` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `esv-bible` — ESV Bible
- dir: `esv-bible` · commands: 2 · modes: view
- Degraded: openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw

### `eurovision-song-contest` — Eurovision Song Contest
- dir: `eurovision-song-contest` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw

### `evm-codes` — EVM Codes
- dir: `evm-codes` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `excalidraw` — Excalidraw
- dir: `excalidraw` · commands: 4 · modes: view|no-view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `exivo` — Exivo
- dir: `exivo` · commands: 2 · modes: view
- Degraded: openExtensionPreferences: no-op

### `explain-command` — Explain Command
- dir: `explain-command` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `fantasy-premier-league-rankings` — Fantasy Premier League
- dir: `fantasy-premier-league-rankings` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `fastly` — Fastly
- dir: `fastly` · commands: 10 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `featurebase` — Featurebase
- dir: `featurebase` · commands: 4 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `figma-variables` — Figma Variables
- dir: `figma-variables` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `fingertip` — Fingertip
- dir: `fingertip` · commands: 2 · modes: view
- Degraded: openExtensionPreferences: no-op

### `firefly-iii` — Firefly III
- dir: `firefly-iii` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `footy-report` — Footy Report
- dir: `footy-report` · commands: 3 · modes: view
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `formizee` — Formizee
- dir: `formizee` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `french-verb-conjugation` — French Verb Conjugation
- dir: `french-verb-conjugation` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ftrack` — ftrack
- dir: `ftrack` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `fumadocs` — Fumadocs
- dir: `fumadocs` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `game-scout` — Game Scout
- dir: `game-scout` · commands: 5 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; openExtensionPreferences: no-op

### `gandi` — Gandi
- dir: `gandi` · commands: 3 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `gcp-search` — Google Cloud Platform Search
- dir: `google-cloud-platform-search` · commands: 2 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `gg-deals` — gg.deals
- dir: `gg-deals` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ghost-docs` — Ghost - Docs Search
- dir: `ghost-docs` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `gistly` — Gistly
- dir: `gistly` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `git-commands` — Git Commands
- dir: `git-commands` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; openCommandPreferences: no-op

### `gleam-packages` — Gleam Packages
- dir: `gleam-packages` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `go-to-rewind-timestamp` — Go to Rewind Timestamp
- dir: `go-to-rewind-timestamp` · commands: 2 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `goodreads` — Goodreads
- dir: `goodreads` · commands: 2 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet

### `google-cloud-run` — Google Cloud Run
- dir: `google-cloud-run` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `gotify` — Gotify
- dir: `gotify` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op

### `grafbase` — Grafbase
- dir: `grafbase` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `greip` — Greip
- dir: `greip` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `grist` — Grist
- dir: `grist` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `guerrilla-mail` — Guerrilla Mail
- dir: `guerrilla-mail` · commands: 3 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `guitar-chords` — Guitar Chords
- dir: `guitar-chords` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `hashrate-no` — Hashrate
- dir: `hashrate-no` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `hatena-bookmark` — Hatena Bookmark
- dir: `hatena-bookmark` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `have-i-been-pwned` — Have I Been Pwned
- dir: `have-i-been-pwned` · commands: 3 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `hebrew-date-zmanim` — Hebrew Date & Zmanim
- dir: `hebrew-date-zmanim` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `hephaestus` — Hephaestus - JSON Tools
- dir: `hephaestus` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `heroicons` — Heroicons
- dir: `heroicons` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `hidemyemail` — Hide My Email
- dir: `hidemyemail` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `hipster-ipsum` — Hipster Ipsum
- dir: `hipster-ipsum` · commands: 2 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `holopin` — Holopin
- dir: `holopin` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `homebox` — HomeBox
- dir: `homebox` · commands: 4 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `horoscope` — Horoscope
- dir: `horoscope` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `host-io` — Host.io
- dir: `host-io` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `howlongtobeat` — HowLongToBeat
- dir: `how-long-to-beat` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `hsdecks` — Hearthstone Decks
- dir: `hsdecks` · commands: 2 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `http-dot-cat` — HTTP.cat Status Codes
- dir: `http.cat` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `http-observatory` — HTTP Observatory
- dir: `http-observatory` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `hue-palette` — Hue Palette
- dir: `hue-palette` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `humaans` — Humaans
- dir: `humaans` · commands: 6 · modes: view|no-view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `imdb` — IMDb Search
- dir: `imdb` · commands: 4 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `inbound` — Inbound
- dir: `inbound` · commands: 3 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `indiehackers` — IndieHackers
- dir: `indiehackers` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `inkdrop` — Inkdrop
- dir: `inkdrop` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op

### `inspire-search` — Inspire HEP Search
- dir: `inspire-search` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ionos-sync` — IONOS Sync
- dir: `ionos-sync` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ip-tools` — IP Tools
- dir: `ip-tools` · commands: 9 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ipapi-is` — ipapi.is
- dir: `ipapi-is` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `jalali-date-convertor` — Jalali Date Convertor
- dir: `jalali-date-convertor` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `jira2git` — Jira2Git
- dir: `jira2git` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `job-dojo` — Job Dojo
- dir: `job-dojo` · commands: 5 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `jokes` — Jokes
- dir: `jokes` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `jue-jin` — Juejin
- dir: `juejin` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `kafka-ui` — Kafka UI
- dir: `kafka-ui` · commands: 3 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `kagi-fastgpt` — Kagi FastGPT
- dir: `kagi-fastgpt` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `kaomoji-search` — Kaomoji Search
- dir: `kaomoji-search` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `keeper-security` — Keeper Security
- dir: `keeper-security` · commands: 4 · modes: view
- Degraded: openExtensionPreferences: no-op

### `klu-ai` — Klu
- dir: `klu-ai` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `knowwa` — Knowwa
- dir: `knowwa` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `kusto-reference` — Kusto Reference
- dir: `kusto-reference` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `laby-net` — Laby.net
- dir: `laby-net` · commands: 2 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `laravel-shift` — Laravel Shift for Docker
- dir: `laravel-shift` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `laravel-vapor` — Laravel Vapor
- dir: `laravel-vapor` · commands: 6 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)

### `latest-news` — Latest Local News
- dir: `latest-news` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `lazygit-keybindings` — Lazygit Keybindings
- dir: `lazygit-keybindings` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `lemmy` — Lemmy
- dir: `lemmy` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `let-me-google-that` — LetMeGoogleThat
- dir: `let-me-google-that` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `letterboxd` — Letterboxd
- dir: `letterboxd` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet

### `liba-ro_shortener` — Liba.ro - URL Shortener
- dir: `liba-ro` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `libraries-io` — Libraries.io
- dir: `libraries-io` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `lift-calculator` — Lift Calculator
- dir: `lift-calculator` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `lifx-advanced-controller` — LIFX Advanced Controller
- dir: `lifx-controller` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)

### `lightning-time` — Lightning Time
- dir: `lightning-time` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `linkace` — Linkace
- dir: `linkace` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `lipsum` — Japanese Lorem Ipsum Generator
- dir: `lipsum` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `list-keyboard-maestro-macros` — Keyboard Maestro - List Macros
- dir: `keyboard-maestro` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `literal` — Literal
- dir: `literal` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `liveblocks` — Liveblocks
- dir: `liveblocks` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op

### `loan-calculator` — Loan Calculator
- dir: `loan-calculator` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `logsnag` — LogSnag
- dir: `logsnag` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `logtail` — Logtail
- dir: `logtail` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op

### `looksee` — LookSee - A MAC, OUI, IAB Lookup
- dir: `looksee` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `lorem-picsum` — Lorem Picsum
- dir: `lorem-picsum` · commands: 2 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `lotr` — The Lord of the Rings
- dir: `lotr` · commands: 3 · modes: view
- Degraded: openExtensionPreferences: no-op

### `lume` — Lume
- dir: `lume` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)

### `lunatask` — Lunatask
- dir: `lunatask` · commands: 3 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)

### `lunchmoney` — Lunch Money
- dir: `lunchmoney` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `mailboxlayer` — mailboxlayer
- dir: `mailboxlayer` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `make-dot-com` — Make.com Scenarios
- dir: `make-dot-com` · commands: 2 · modes: view
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)

### `manifest-viewer` — Manifest Viewer
- dir: `manifest-viewer` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `manus` — Manus
- dir: `manus` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `marble` — Marble
- dir: `marble` · commands: 8 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `markdown-preview` — Markdown Preview
- dir: `markdown-preview` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `markdown-reference` — Markdown Reference
- dir: `markdown-reference` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `markdown-table-generator` — Markdown Table Generator
- dir: `markdown-table-generator` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `markprompt` — Markprompt
- dir: `markprompt` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `matter` — Matter
- dir: `matter` · commands: 2 · modes: view|no-view
- Degraded: openExtensionPreferences: no-op

### `maxly-chat` — Maxly.chat
- dir: `maxly-chat` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `mercado-libre` — Mercado Libre
- dir: `mercado-libre` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `metaphorpsum` — Metaphorpsum
- dir: `metaphorpsum` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `meteoblue-lookup` — Meteoblue Lookup
- dir: `meteoblue-lookup` · commands: 4 · modes: view
- Degraded: openExtensionPreferences: no-op

### `mikrus` — Mikrus
- dir: `mikrus` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `minecast` — Minecast
- dir: `minecast` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `minimax-ai` — MiniMax
- dir: `minimax-ai` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op

### `minion-ipsum` — Minion Ipsum
- dir: `minion-ipsum` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `mixpanel` — Mixpanel
- dir: `mixpanel` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `mnemosyne` — Mnemosyne
- dir: `mnemosyne` · commands: 2 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `monday-com` — monday.com
- dir: `monday` · commands: 4 · modes: view|no-view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op

### `moneylover` — MoneyLover
- dir: `moneylover` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `mongodb-objectid` — MongoDB ObjectId
- dir: `mongodb-objectid` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `multi` — Multi
- dir: `multi` · commands: 9 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `musicbrainz` — MusicBrainz
- dir: `musicbrainz` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `nanoid` — Generate Nanoid
- dir: `nanoid` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `nato-phonetic-alphabet` — NATO Phonetic Alphabet
- dir: `nato-phonetic-alphabet` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `near-rewards` — Near Rewards
- dir: `near-rewards` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `nepali-calendar` — Nepali Calendar
- dir: `nepali-calendar` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `nextcloud` — Nextcloud
- dir: `nextcloud` · commands: 5 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ngrok` — Ngrok
- dir: `ngrok` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openCommandPreferences: no-op; confirmAlert: always returns false (no dialog)

### `nhl` — NHL
- dir: `nhl` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `nicnames` — NicNames
- dir: `nicnames` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `niuma-logs` — Niuma Logs
- dir: `niuma-logs` · commands: 3 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `nl-news-headlines` — NL News Headlines
- dir: `nl-news-headlines` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `nmbs-planner` — NMBS Planner
- dir: `nmbs-planner` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `notaday` — Notaday
- dir: `notaday` · commands: 4 · modes: view
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `notion_researcher` — Notion Researcher
- dir: `notion_researcher` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openCommandPreferences: no-op; openExtensionPreferences: no-op

### `notra` — Notra
- dir: `notra` · commands: 6 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw

### `novu` — Novu
- dir: `novu` · commands: 8 · modes: no-view|view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `ns-nl-search` — Netherlands Railways Train Search
- dir: `ns-nl-search` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `number-research` — Number Research
- dir: `number-research` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `octoprint` — OctoPrint
- dir: `octoprint` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ohdear` — Oh Dear
- dir: `ohdear` · commands: 2 · modes: view
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)

### `omni-news` — Omni News
- dir: `omni-news` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `one-tab-group` — One Tab Group
- dir: `one-tab-group` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ones` — ONES
- dir: `ones` · commands: 8 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `open_targets` — Open Targets
- dir: `open-targets-raycast` · commands: 5 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `open-in-json-hero` — Open in JSON Hero
- dir: `open-in-json-hero` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `openrouter-model-search` — OpenRouter Model Search
- dir: `openrouter-model-search` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `package-tracker` — Parcel Tracker - 17track
- dir: `package-tracker` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `palette-colors` — Palette Colors
- dir: `palette-colors` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `pantheon-sites` — Pantheon Sites
- dir: `pantheon-sites` · commands: 2 · modes: view|no-view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `papago-translate` — Papago Translate
- dir: `papago-translate` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `parachord` — Parachord
- dir: `parachord` · commands: 12 · modes: no-view|view
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `password-link` — Password.link
- dir: `password-link` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `pastebin` — Pastebin
- dir: `pastebin` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)

### `pastefy` — Pastefy
- dir: `pastefy` · commands: 2 · modes: view
- Degraded: openExtensionPreferences: no-op

### `paymenter` — Paymenter
- dir: `paymenter` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `paypal-invoices` — PayPal Invoices
- dir: `paypal-invoices` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `pdb-explorer` — PDB Explorer
- dir: `pdb-explorer` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `pdf-tools` — PDF Tools
- dir: `pdf-tools` · commands: 6 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `pdsls` — PDSls
- dir: `pdsls` · commands: 4 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `percentage-calculator` — Percentage Calculator
- dir: `percentage-calculator` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `perchance-generator` — Perchance Generator
- dir: `perchance-generator` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `perplexity` — Perplexity
- dir: `perplexity` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `perry` — Perry
- dir: `perry` · commands: 5 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `personio` — Personio
- dir: `personio` · commands: 4 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw; openCommandPreferences: no-op

### `phare-io-uptime` — Phare.io Uptime
- dir: `phare-io-uptime` · commands: 2 · modes: view
- Degraded: openExtensionPreferences: no-op

### `phind-search` — Phind Search
- dir: `phind-search` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `pick-random-raycast-extension` — Pick Random
- dir: `pick-random` · commands: 3 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `pinch-svg` — Pinch SVG
- dir: `pinch-svg` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `pinia-docs` — Pinia Docs
- dir: `pinia-docs` · commands: 1 · modes: view
- Degraded: captureException: no-op

### `planning-center-api-docs` — Planning Center API Docs
- dir: `planning-center-api-docs` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `playback-duration-calculator` — Playback Duration Calculator
- dir: `playback-duration-calculator` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `playtester` — Playtester
- dir: `playtester` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `pocket` — Pocket
- dir: `pocket` · commands: 6 · modes: view|no-view
- Degraded: openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `pocketbase` — PocketBase
- dir: `pocketbase` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `pokedex` — Pokédex
- dir: `pokedex` · commands: 8 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet

### `port` — Port.io
- dir: `port` · commands: 4 · modes: view
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `portuguese-primeira-liga` — Portuguese Primeira Liga
- dir: `portuguese-primeira-liga` · commands: 3 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `position-size-calculator` — Position Size Calculator
- dir: `position-size-calculator` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `posthog` — PostHog
- dir: `posthog` · commands: 5 · modes: view
- Degraded: openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `postiz` — Postiz
- dir: `postiz` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `postman` — Postman
- dir: `postman` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `primer` — Primer
- dir: `primer` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `prisma-docs-search` — Prisma Docs Search
- dir: `prisma-docs-search` · commands: 1 · modes: view
- Degraded: openCommandPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `prisma-postgres` — Prisma Postgres
- dir: `prisma-postgres` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)

### `project-companion` — Project Companion
- dir: `project-companion` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `prompts-chat` — Prompts.chat
- dir: `prompts-chat` · commands: 5 · modes: view
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `protondb` — ProtonDB
- dir: `protondb` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `prowlarr` — Prowlarr
- dir: `prowlarr` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `pumble` — Pumble
- dir: `pumble` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `pushover` — Pushover
- dir: `pushover` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `query-chatgpt` — Query ChatGPT
- dir: `query-chatgpt` · commands: 2 · modes: view|no-view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet

### `query-domains` — Query.Domains
- dir: `query-domains` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `quick-access-infomaniak` — Quick Access Infomaniak
- dir: `quick-access-infomaniak` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `quick-web` — Quick Web
- dir: `quick-web` · commands: 6 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `quikwallet` — Quikwallet
- dir: `quikwallet` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `r-pkg-search` — Search R Packages
- dir: `r-pkg-search` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `radarr` — Radarr
- dir: `radarr` · commands: 7 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `radicle` — Radicle
- dir: `radicle` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `rails-routes` — Rails Routes
- dir: `rails-routes` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `rain-radars` — Rain Radars
- dir: `rain-radars` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ramda-documentation` — Ramda Documentation
- dir: `ramda-documentation` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `random` — Random Data Generator
- dir: `random-data-generator` · commands: 2 · modes: view|no-view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `random-date-generator` — Random Date Generator
- dir: `random-date-generator` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `rateyourmusic-search` — Rate Your Music Search
- dir: `rateyourmusic-search` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `raycafe` — Raycafé
- dir: `raycafe` · commands: 1 · modes: view
- Degraded: openCommandPreferences: no-op

### `raycast-apple-intelligence` — Apple Intelligence
- dir: `raycast-apple-intelligence` · commands: 13 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `raycast-clip` — Clip - URL Shortener
- dir: `clip` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op

### `raycast-fly` — Fly.io
- dir: `raycast-fly` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `raycast-frc` — Raycast FRC
- dir: `raycast-frc` · commands: 4 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet

### `raycast-lighting-node-search` — Search Lightning Nodes
- dir: `raycast-lighting-node-search` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `raycast-mux` — Mux.com
- dir: `raycast-mux` · commands: 6 · modes: no-view|view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `raycast-notification` — Raycast Notification
- dir: `raycast-notification` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `raycast-timezone-converter` — Timezone Converter
- dir: `timezone-converter` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `raycast-wca` — WCA
- dir: `raycast-wca` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `raycast-weekly-newsletter` — Raycast Weekly Newsletter
- dir: `raycast-weekly-newsletter` · commands: 3 · modes: view|no-view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `rdir` — Rdir
- dir: `rdir` · commands: 2 · modes: view|no-view
- Degraded: openExtensionPreferences: no-op

### `recurly` — Recurly
- dir: `recurly` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `redis` — Redis
- dir: `redis` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `reverso-context` — Reverso Context
- dir: `reverso-context` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `rewardful` — Rewardful
- dir: `rewardful` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `roblox-creator-docs` — Roblox Creator Docs
- dir: `roblox-creator-docs` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `rounding-number` — Rounding Number
- dir: `rounding-number` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `rtl-reader` — RTL Reader
- dir: `rtl-reader` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `sadaqah-box` — Sadaqah Box
- dir: `sadaqah-box` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); Cache: Cache.get returns defaults; Cache.set/remove throw

### `sanity` — Sanity
- dir: `sanity` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `save-to-cubox` — Save to Cubox
- dir: `save-to-cubox` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `saved-items` — Saved Items
- dir: `saved-items` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `sayintentions` — SayIntentions
- dir: `sayintentions` · commands: 4 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `scaleway` — Scaleway
- dir: `scaleway` · commands: 20 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op

### `schoology` — Schoology - Grade Viewer
- dir: `schoology` · commands: 2 · modes: view|no-view
- Degraded: declares background `interval` command(s) — not scheduled

### `seafile` — Seafile
- dir: `seafile` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `search-astro-docs` — Search Astro Documentation
- dir: `search-astro-docs` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `search-blockchain` — Search Blockchain
- dir: `search-blockchain` · commands: 13 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `search-clojuredocs` — Search ClojureDocs Documentation
- dir: `clojuredocs-search` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `search-gule-sider` — Search Gule Sider
- dir: `search-gule-sider` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `search-mdn` — Search MDN
- dir: `search-mdn` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `search-oeis` — Search OEIS
- dir: `search-oeis` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `sefaria` — Sefaria
- dir: `sefaria` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `sendportal` — SendPortal
- dir: `sendportal` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `sharding-tools` — Sharding Tools
- dir: `sharding-tools` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `shell-buddy` — Shell Buddy
- dir: `shell-buddy` · commands: 1 · modes: view
- Degraded: openCommandPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `shelve` — Shelve
- dir: `shelve` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ship24-client` — Ship24 Package Tracker
- dir: `ship24-client` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `shlink` — Shlink
- dir: `shlink` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)

### `shodan` — Shodan
- dir: `shodan` · commands: 9 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `simple-memo` — Simple Memo
- dir: `simple-memo` · commands: 3 · modes: view|no-view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `simplelogin` — SimpleLogin
- dir: `simplelogin` · commands: 3 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)

### `singularityapp` — SingularityApp
- dir: `singularityapp` · commands: 2 · modes: view
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `sitespeakai` — SiteSpeakAI
- dir: `sitespeakai` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `slugify` — Slugify
- dir: `slugify` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `snapask` — SnapAsk
- dir: `snapask` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `sncftraintimes` — SncfTrainTimes
- dir: `sncftraintimes` · commands: 2 · modes: view
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `solana-wallets-generation` — Solana Wallets Generation
- dir: `solana-wallets-generation` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `solidtime` — Solidtime
- dir: `solidtime` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `solusvm-1-client` — SolusVM 1 Client
- dir: `solusvm-1-client` · commands: 5 · modes: view|no-view
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op

### `sonarr` — Sonarr
- dir: `sonarr` · commands: 9 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; openExtensionPreferences: no-op

### `sonu-stream` — Sonu
- dir: `sonu-stream` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `sound-search` — Sound Search
- dir: `sound-search` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `speed-dial` — Speed Dial
- dir: `speed-dial` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `spell` — Spell
- dir: `spell` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `spinupwp` — SpinupWP
- dir: `spinupwp` · commands: 5 · modes: no-view|view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `splitwise` — Splitwise
- dir: `Splitwise` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `stacks` — Stacks
- dir: `stacks` · commands: 2 · modes: view|no-view
- Degraded: openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet

### `starling` — Starling
- dir: `starling` · commands: 6 · modes: view
- Degraded: openExtensionPreferences: no-op; confirmAlert: always returns false (no dialog)

### `stashpad-docs` — Stashpad Docs
- dir: `stashpad-docs` · commands: 2 · modes: no-view|view
- Degraded: openCommandPreferences: no-op

### `statamic-docs` — Statamic Documentation Search
- dir: `statamic-docs` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `storybook-launcher` — Storybook Launcher
- dir: `storybook-launcher` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `storybook-search` — Storybook Search
- dir: `storybook-search` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `subwatch` — Subwatch
- dir: `subwatch` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `supermemory` — Supermemory
- dir: `supermemory` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op

### `surf-check` — Surf Check
- dir: `surf-check` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `surl` — Surl
- dir: `surl` · commands: 2 · modes: no-view|view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `swift-evolution` — Swift Evolution
- dir: `swift-evolution` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `swiss-ov` — Swiss ÖV
- dir: `swiss-ov` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `switch-game-play-history` — Switch Game Play History
- dir: `switch-game-play-history` · commands: 3 · modes: view
- Degraded: openExtensionPreferences: no-op; Cache: Cache.get returns defaults; Cache.set/remove throw

### `t3-chat` — T3 Chat
- dir: `t3-chat` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `tableau-navigator` — Tableau Navigator
- dir: `tableau-navigator` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `tally` — Tally
- dir: `tally` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `tana` — Tana
- dir: `tana` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `taskplane` — Taskplane
- dir: `taskplane` · commands: 3 · modes: view|no-view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `teamgantt` — TeamGantt
- dir: `teamgantt` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `texts` — Texts
- dir: `texts` · commands: 3 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `the-noble-quran` — The Noble Quran
- dir: `the-noble-quran` · commands: 2 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `thesvg` — TheSVG
- dir: `thesvg` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `threads-video-downloader` — Threads Video Downloader
- dir: `threads-video-downloader` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `time-logger` — Google Calendar Epic Time Logger
- dir: `time-logger` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `time-until-i-do` — Time Until I Do
- dir: `time-until-i-do` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `timecrowd-tracker` — TimeCrowd Tracker
- dir: `timecrowd-tracker` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `tip-calculator` — Tip Calculator
- dir: `tip-calculator` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `tldraw` — tldraw
- dir: `tldraw` · commands: 3 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `tmdb` — The Movie Database
- dir: `tmdb` · commands: 5 · modes: view
- Degraded: openCommandPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `toolbox` — ToolBox
- dir: `toolbox` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `trackflight` — Flight Tracker
- dir: `trackflight` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `tradingview-controls` — TradingView Controls
- dir: `tradingview-controls` · commands: 5 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `trello` — Trello
- dir: `trello` · commands: 7 · modes: view
- Degraded: confirmAlert: always returns false (no dialog)

### `tscheck-in` — Tscheck.In
- dir: `tscheck-in` · commands: 1 · modes: no-view
- Degraded: confirmAlert: always returns false (no dialog)

### `tududi` — Tududi
- dir: `tududi` · commands: 5 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `tuneblade` — Tuneblade
- dir: `tuneblade` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `tuple` — Tuple
- dir: `tuple` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `tuya-smart` — Tuya Smart
- dir: `tuya-smart` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `twitch-logs` — Twitch Logs
- dir: `twitch-logs` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `twos` — Twos Post
- dir: `twos` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `unblocked-answers` — Unblocked Answers
- dir: `unblocked-answers` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `unkey` — Unkey
- dir: `unkey` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `unleash-feature-toggle` — Unleash Feature Toggle
- dir: `unleash-feature-toggle` · commands: 1 · modes: view
- Degraded: openCommandPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `unogs` — Unogs
- dir: `unogs` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `uplabs` — UpLabs
- dir: `uplabs` · commands: 1 · modes: view
- Degraded: openExtensionPreferences: no-op

### `urban-dictionary` — Urban Dictionary Search
- dir: `urban-dictionary` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `useless-facts` — Useless Facts
- dir: `useless-facts` · commands: 2 · modes: view
- Degraded: openExtensionPreferences: no-op

### `usememos` — Usememos
- dir: `usememos` · commands: 2 · modes: view|no-view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `utc-workbench` — UTC Workbench
- dir: `utc-workbench` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `utm-campaign-builder` — UTM Campaign Builder
- dir: `utm-campaign-builder` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `uuid-generator` — UUID Generator
- dir: `uuid-generator` · commands: 9 · modes: no-view|view
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `v2ex-viewer` — V2EX
- dir: `v2ex-viewer` · commands: 5 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; confirmAlert: always returns false (no dialog)

### `vaib` — vAIb - Your AI Companion
- dir: `vaib` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `vanguard-backup` — Vanguard Backup
- dir: `vanguard-backup` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `vanishlink` — Vanishlink
- dir: `vanishlink` · commands: 3 · modes: no-view|view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `vartiq` — Vartiq
- dir: `vartiq` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `vat-calculator` — VAT Calculator
- dir: `vat-calculator` · commands: 3 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `vatlayer` — vatlayer
- dir: `vatlayer` · commands: 6 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `verify-number` — Verify Number
- dir: `verify-number` · commands: 2 · modes: view
- Degraded: openExtensionPreferences: no-op; declares command `arguments[]` — not passed by runtime yet

### `vietqr-transfer` — VietQR Transfer Generator
- dir: `vietqr-transfer` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `virtualbox-power-switch` — VirtualBox Power Switch
- dir: `virtualbox-power-switch` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `volumio-control` — Volumio Control
- dir: `volumio-control` · commands: 10 · modes: no-view|view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `vue-router-docs` — Vue Router Docs
- dir: `vue-router-docs` · commands: 1 · modes: view
- Degraded: captureException: no-op

### `vuetify-docs` — Vuetify Docs
- dir: `vuetify-docs` · commands: 3 · modes: view|no-view
- Degraded: captureException: no-op

### `vultr` — Vultr
- dir: `vultr` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `web-audit` — Web Audit
- dir: `web-audit` · commands: 2 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); declares command `arguments[]` — not passed by runtime yet

### `web3-profile` — Web3 Profile
- dir: `web3-profile` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `web3bio` — Web3.bio
- dir: `web3bio` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw

### `webhook-sender` — Webhook Sender
- dir: `webhook-sender` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `websocket-debugging` — Websocket Debugging
- dir: `websocket-debugging` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `whois` — Whois
- dir: `whois` · commands: 1 · modes: view
- Degraded: Cache: Cache.get returns defaults; Cache.set/remove throw; declares command `arguments[]` — not passed by runtime yet

### `whosampled` — WhoSampled
- dir: `whosampled` · commands: 3 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `windows-to-linux-path` — Windows to Linux Path
- dir: `windows-to-linux-path` · commands: 2 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `wled-controller` — WLED Controller
- dir: `wled-controller` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `wolfram-alpha` — Wolfram Alpha
- dir: `wolfram-alpha` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `word-research` — Word Research
- dir: `word-research` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `wordpress-manager` — WordPress Manager
- dir: `wordpress-manager` · commands: 9 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; Cache: Cache.get returns defaults; Cache.set/remove throw

### `workflowy-inbox` — Workflowy Inbox
- dir: `workflowy-inbox` · commands: 2 · modes: view
- Degraded: openExtensionPreferences: no-op

### `world-clock` — Time-Traveling World Clock
- dir: `time-traveling-world-clock` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `wu-bi-bian-ma` — Wubi Code
- dir: `wu-bi-bian-ma` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `xpf-converter` — XPF to EUR Converter
- dir: `xpf-converter` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `yap` — Yap
- dir: `yap` · commands: 1 · modes: view
- Degraded: confirmAlert: always returns false (no dialog); openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `yopass` — Yopass
- dir: `yopass` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `youtube-music` — YouTube Music
- dir: `youtube-music` · commands: 10 · modes: no-view
- Degraded: openExtensionPreferences: no-op

### `zacks-stock-ranking` — Zacks Stock Ranking
- dir: `zacks-stock-ranking` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `zeitraum` — Zeitraum
- dir: `zeitraum` · commands: 5 · modes: view
- Degraded: openExtensionPreferences: no-op; useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `zendesk-admin` — Zendesk — Admin
- dir: `zendesk-admin` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; confirmAlert: always returns false (no dialog)

### `zerodha-portfolio-kite-coin` — Zerodha Portfolio (Kite+Coin)
- dir: `zerodha-portfolio-kite-coin` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `zipper-run` — Run Zipper Applet
- dir: `zipper-run` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `zoom-meeting-control` — Zoom Meeting Control
- dir: `zoom-control` · commands: 11 · modes: no-view
- Degraded: confirmAlert: always returns false (no dialog)

## SUPPORTED (650)

`5devs`, `8-ball`, `active-mississaugua`, `adonisjs-documentation`, `advice-slip`, `affine`, `ai-humanizer`, `aimlab`, `airplane`, `airport`, `airsy`, `airsync`, `aiven`, `aliyun-flow`, `alpinejs`, `analog-film-library`, `android-versions`, `anilist-airing-schedule`, `antisocials`, `anycoffee`, `apify`, `apis-guru-search`, `apple-books`, `apple-developer-docs`, `apple-devices`, `apple-stocks-search`, `arabic-keyboard`, `archisteamfarm`, `array-this`, `ars-technica`, `arxiv`, `asoiaf`, `asyncapi`, `axios-docs`, `background-sounds`, `bahn-info`, `balatro-compendium`, `battery-health`, `bbc-news-headlines`, `berlin-public-transportation`, `big-o`, `bilibili-search`, `bing-search`, `binge-clock`, `bintools`, `bitaxe-status`, `bitbucket`, `bitbucket-search-self-hosted`, `bitrise`, `board-game-geek`, `bookstack`, `bored`, `botpress`, `brasileirao-serie-a`, `brave-search`, `bring`, `bttv-emote`, `bundlephobia-search`, `can-i-php`, `can-i-use`, `carbon-code-screenshot-for-raycast`, `catenary-raycast`, `catppuccin`, `cc0-lib`, `chainscout`, `change-scroll-direction`, `chatbase`, `chatgpt3-prompt`, `cheatsheets`, `check-citi-bike-availability`, `chess-com`, `chinese-character-converter`, `chinese-lottery`, `chinese-numbers`, `choose-a-license`, `chords-and-tabs`, `chuck-norris-facts`, `cilium-docs`, `cinemas-nos`, `citation-generator`, `cl-indicators`, `claude-code-cheatsheet`, `clean-agent-text`, `clear-clipboard`, `climbing-grade-converter`, `clipboard-editor`, `clipboard-formatter`, `clipboard-sequential-paste`, `clipboard-type`, `clipboard-utilities`, `close-finder`, `coda-bookmarks-search`, `code-review-emojis`, `code-smells`, `codesnap`, `coin-caster`, `coingecko`, `coinpaprika`, `comma-separator`, `commercequest`, `commit-message-generator`, `consoledev`, `control-viscosity`, `conventional-commits`, `country-lookup`, `cpf-cnpj-generator`, `cran-e-search`, `cron-description`, `crunchbase`, `crypto-search`, `css-calculations`, `css-tricks`, `cuid-generator`, `cursor`, `cursors`, `curto-io-url-shortener`, `customer-io`, `cypress-docs`, `dad-jokes`, `daisyui`, `daminik`, `dashlane`, `date-converter`, `dbt-documentation`, `dbtcloud`, `decentraland`, `deduplicator`, `defichain-dobby`, `defiscan`, `dekudeals`, `deployhq`, `designer-excuses`, `deutscherwetterdienst`, `developer-excuse`, `dex-screener`, `dice-tiles`, `directus`, `disney`, `djangopackages`, `dog-images`, `dollar-blue`, `donut`, `dotnet-api-browser`, `dotnet-docs-search`, `dotween-eases`, `douban`, `dpm-lol`, `dr-news`, `drug-search`, `drupal-org`, `duckduckgo-email`, `dutch-article`, `dynamic-font-size`, `e18e-module-replacements`, `early-tools-news`, `ecosia-search`, `ekstraklasa`, `elixir`, `elron`, `ember-api-documentation`, `emissions-calculator`, `endel`, `ens-name-lookup`, `envoyer`, `escape-regexp-characters`, `espn`, `esports-pass`, `evil-insult`, `excel-formula-beautifier`, `facetime`, `fake-swedish-personal-number`, `fastmail-masked-email`, `fathom-analytics`, `fbi`, `feedly`, `fhir`, `fibonacci-sequence`, `figma-learn-companion`, `figma-shortcuts`, `filament`, `file-tree-generator`, `fillerama`, `finary`, `finnish-dictionary`, `fluctuation`, `fluent-outdoors`, `flux`, `flypy`, `forgejo`, `format-graphql`, `framer-motion`, `frankerfacez`, `freshrss`, `fuelx`, `geist-ui-components`, `geoconverter`, `geoguesser`, `get-cat-images`, `get-direct-link`, `gift-stardew-valley`, `git-branch-name-generator`, `gitee`, `github-cli-manual`, `github-profile`, `github-spark`, `github-users`, `gitlab-docs`, `glyph-search`, `go-links`, `go-package-search`, `golden-ratio`, `gomander`, `google-advanced-search`, `google-finance`, `google-fonts`, `google-meet`, `google-scholar`, `gradle-plugins`, `graphcdn`, `grokipedia`, `groundhog-day`, `growthbook`, `habr-media`, `hashnode`, `headlines`, `hellonext-changelogs`, `helm-docs`, `hemolog`, `hide-all-apps`, `hide-mail`, `holodex`, `hoogle`, `hostloc`, `html-colors`, `http-mime`, `hugging-face`, `hupu`, `hyper-focus`, `iata-code-decoder`, `icd10-lookup`, `iching-divination`, `icloud-global-pricing-comparison`, `ifanr`, `image-diff-checker`, `image-host`, `in-the-time-zone`, `incognito-clone`, `initium`, `inpost-parcel-lockers`, `instapaper`, `intention-clarifier`, `ios-resolution`, `ipa-translator`, `ipcheck-ing`, `iptv`, `is-it-toxic-to`, `isdown`, `itch-io`, `james-webb-space-telescope`, `jira-time-tracking`, `jisho`, `jitsi`, `jotform`, `json-editor`, `json-to-go`, `json2ts`, `jurassic-ninja-site-generator`, `just-delete-me`, `justcolorpicker-raycast`, `kaalam`, `kagi-news`, `kagi-search`, `keychain-password-gen`, `kimi-for-coding`, `kind-words`, `kindle-paste`, `kubernetes`, `kubernetes-docs`, `laracasts`, `laravel-livewire`, `large-type`, `lark-applink`, `latex-math-symbols`, `leetcode`, `lego-bricks`, `leitnerbox`, `lenscast`, `lgtmeow`, `lichess-org`, `lightdash-navigator`, `ligue-1`, `linguee`, `linux-command`, `liquipedia-matches`, `llm-stats`, `llms-txt`, `lobehub-icons`, `lucide-animated`, `lyrics`, `mac-app-store-search`, `macrumors`, `macstories`, `macupdater`, `magic-home`, `mail-to-self`, `mailtrap`, `make-with-notion-2024`, `mandarin-chinese-dictionary`, `manga-calendar`, `markdown-converter`, `markdown-this`, `markdown-to-plain-text`, `markdown-to-rich-text`, `math-functions`, `md-to-excel`, `mem`, `mem0`, `mempool`, `metacritic`, `metube`, `microblog`, `microsoft-teams-calling`, `midas`, `minecraft-color-codes`, `minecraft-crafting-recipes`, `minisim`, `mittwald`, `mobius-materials`, `mochi`, `modrinth`, `modrinth-search`, `monkeytype`, `monocle`, `multipass`, `multiviewer`, `music-news`, `music-timer`, `musicthread`, `must`, `mynaui-icons`, `namuwiki`, `nano-games`, `nasa`, `nativebase-docs`, `nature-remo`, `navidrome`, `nba-game-viewer`, `neodb`, `netease-music`, `neurooo-translate`, `new-relic`, `new-york-times`, `next-lens`, `next-run`, `nfl-information`, `nft-search`, `nif`, `nif-fresquinho`, `nixpkgs-search`, `no-as-a-service`, `node-js-evaluate`, `nordic-energy-prices`, `nostr`, `notilight-controller`, `nowplaying-cli`, `nsis-reference`, `nts`, `nu-nieuws`, `nuget`, `number-facts`, `numpad`, `nyc-train-tracker`, `nzbget`, `octopus-energy`, `odin`, `odoo-companion`, `office-quotes`, `oh-my-zsh-git-alias`, `ohmyzsh-plugins`, `oklch-color-converter`, `oktasearch`, `ollama-mind-map-generator`, `olympic-games`, `onelook-thesaurus`, `open-gem-documentation`, `open-latest-url-from-clipboard`, `openweathermap`, `orbita`, `osrs-wiki`, `ossinsight`, `owledge-raycast`, `owncloud`, `ozbargain-deals`, `pandas-documentation-search`, `papersize`, `parabol`, `parcel-tracker`, `parse`, `password-generator`, `paste-from-apple-books`, `pbr-assistant`, `penpot`, `phonetic-typing`, `phosphor-icons`, `php-toolbox`, `pitchfork`, `pkg-swap`, `planning-center`, `playwright-docs`, `plex`, `ploi`, `podcasts`, `pokemon-tcg-pocket-binder`, `polars-documentation-search`, `pollen-count`, `polymarket`, `portal-wholesale`, `potter-db`, `prettier`, `prisma-cli-commands`, `protobuf2typescript`, `proton-version`, `pub-dev`, `publico`, `publora`, `pulsemcp`, `px-to-rem-converter`, `qovery`, `qq-music-controls`, `quick-access-for-zeroheight`, `quick-event`, `quickfile`, `quicksnip`, `quicktime`, `quicktype`, `quoterism-raycast`, `rae-dictionary-raycast`, `rainaissance`, `random-password-generator`, `random-us-phone-number`, `ratio-calculator`, `raycast-datadog`, `raycast-ios-hig`, `raycast-manual`, `raycast-nrm`, `raycast-ordbokene`, `raycast-textlint-rule-aws-service-name`, `raycast-translate-ge`, `raycast-wemo`, `raytyping`, `rdw-kentekencheck`, `re-mind`, `react-native-directory`, `reading-time`, `readwise`, `readymetrics`, `recap`, `reddit-search`, `redirect-trace`, `redmine`, `refresh-wifi`, `rehooks`, `reka-ui`, `remove-window-from-set`, `repology-search`, `resmo`, `retool-documentation`, `rewiser`, `rg-adguard-links`, `ricescore`, `rick-and-morty`, `ring-intercom`, `risk-reward-calculator`, `rize-io-sessions`, `rocket-chat`, `roll-d20`, `rollcast`, `rollup-wtf`, `rule-of-three`, `ruler`, `rusbase`, `rust-docs`, `safe-secret`, `sage-hr`, `sat-scorer`, `screen-studio`, `screenocr`, `search-ansible-documentation`, `search-composer-packagist`, `search-github-stars`, `search-justwatch`, `search-npm`, `search-rubygems`, `search-shopify-liquid-documentation`, `sec-filings-search`, `security-search`, `semantic-scholar`, `sendy`, `serie-a`, `serverless-framework-docs`, `shadcn-svelte`, `shadcn-vue`, `shiori`, `shopify-dev-docs-search`, `shopify-developer-changelog`, `shopify-theme-resources`, `sidecar-connect`, `signal`, `simple-login`, `simplebackups`, `smallpdf`, `speedcubing`, `splatoon`, `spoqify`, `spotify-beta`, `spryker-docs`, `sql-reference-search`, `squeeze`, `st-andrews-main-library-occupancy`, `stagehand`, `steam-player-counts`, `stock-lookup`, `stock-tracker`, `stoicquotes`, `storyblok`, `storytime`, `strapi-raycast-extension`, `strftime-cheatsheet`, `string-formatter`, `supabase`, `supabase-docs`, `surfs-up`, `surge-outbound-switcher`, `svga-player`, `swift-package-index`, `swiss-train-times`, `switchhosts`, `syntax-fm`, `table-converter`, `tabletop-dice-roller`, `tabnews`, `tailwind-size-conversion`, `tana-paste`, `tarot`, `tautulli`, `tc-no-generator`, `teamup-rooms`, `techcrunch`, `tempo`, `temporary-email`, `tennis-standings`, `terminal`, `terraform-doc`, `tesla`, `teslamate`, `tex2typst`, `the-matrix-of-destiny`, `the-verge`, `thermoconvert`, `thingiverse`, `thrasher-magazine`, `tibia-helper`, `time`, `time-calculator`, `time-converter`, `tints-and-shades`, `tiny-tycho`, `tinyfaces-nft`, `toggle-fn`, `toggle-grayscale`, `ton-address`, `transform`, `translit`, `truth-or-dare`, `tunnelblick`, `tv-remote`, `tv2---denmark`, `tw-colorpicker`, `twingate`, `twitch-chat`, `twitter-trendscast`, `tyme-3-time-tracker`, `tynyfy`, `type-snob`, `typeform`, `typescript-documentation-search`, `typescript-mock-generator`, `typst-symbols`, `typst-universe`, `udemy-coupons`, `ulid`, `unify-path-separator`, `unirate-currency`, `unitex`, `unix-timestamp`, `unix-timestamp-converter`, `unsure-calc`, `upcoming-holidays`, `url-tools`, `v2raya-control`, `valheim-wiki`, `valkey-commands-search`, `valorant-esports`, `vant-documentation`, `vc-ru-news`, `veganify-application`, `vietnamese-calendar`, `viscosity`, `vision-directory`, `visitor-queue`, `vocab`, `vocabula-lat`, `voicenotes`, `vuejs-documentation`, `vueuse-functions`, `wcag`, `web-converter`, `webkit-developer-docs`, `what-happened-today`, `where-is-my-cursor`, `who-is-off-today`, `wiggle-text`, `wistia`, `woo-marketplace-search`, `wordpress-icon-finder`, `wordpress-plugins`, `world-cup`, `wp-cli-command-explorer`, `wrike`, `xbox-friends`, `xid`, `xkcd`, `xkcd-password-generator`, `xqc`, `yamli`, `yandex-music`, `yield-calculator`, `you-com-search`, `youform`, `youtube-companion`, `youversion-suggest`, `yr-weather-forecast`, `yu-gi-oh-card-lookup`, `za-fake-id-number-generator`, `zalgo-text`, `zefix`, `zendesk`, `zo-raycast`, `zod-documentation`, `zodme`
