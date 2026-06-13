# Invoke v2 — Raycast extension compatibility report

- **Root scanned:** `/Users/test/Documents/code/extensions/extensions`
- **Mode:** sandboxed (default)
- **Extensions found:** 2961

## Summary

| Status | Count | % |
|---|---:|---:|
| SUPPORTED | 889 | 30.0% |
| DEGRADED | 508 | 17.2% |
| UNSUPPORTED | 1564 | 52.8% |

## Top gaps (extensions blocked/degraded per missing capability)

| Capability | Extensions affected |
|---|---:|
| denied Node built-ins in sandbox | 1023 |
| useNavigation | 815 |
| declares command `arguments[]` — not passed by runtime yet | 481 |
| launchCommand | 250 |
| unsupported command mode(s) | 236 |
| declares background `interval` command(s) — not scheduled | 220 |
| getSelectedText | 206 |
| declares AI tools[] | 186 |
| getApplications | 167 |
| declares extension-level `ai` instructions — ignored | 145 |
| getSelectedFinderItems | 127 |
| @raycast/utils | 114 |
| @raycast/api | 112 |
| OAuth | 96 |
| showInFinder | 91 |
| AI | 90 |
| updateCommandMetadata | 88 |
| getFrontmostApplication | 86 |
| BrowserExtension | 47 |
| useExec | 41 |
| trash | 36 |
| runPowerShellScript | 18 |
| getDefaultApplication | 17 |
| namespace import of @raycast/api | 7 |

## UNSUPPORTED (1564)

### `0x0` — 0x0
- dir: `0x0` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `1-click-confetti` — 1-Click Confetti
- dir: `1-click-confetti` · commands: 2 · modes: menu-bar|no-view
- **Blockers:** unsupported command mode(s): confetti-menu: mode "menu-bar"; denied Node built-ins in sandbox: child_process

### `1bookmark` — 1Bookmark
- dir: `1bookmark` · commands: 3 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `1loc` — 1 LOC - JavaScript Utilities in Single Line of Code
- dir: `1loc` · commands: 1 · modes: view
- Needs review: @raycast/utils:getPreferenceValues (not implemented in Invoke); @raycast/utils:List (not implemented in Invoke)

### `1password` — 1Password
- dir: `1password` · commands: 4 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares background `interval` command(s) — not scheduled

### `42-api` — 42 Api Tools
- dir: `42-api` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): today-logtime: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `8-divide` — 8 Divide
- dir: `8-divide` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getSelectedText: throws — selection APIs not wired

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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `acqua` — Acqua
- dir: `acqua` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menubar: mode "menu-bar"
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `adb` — Android Debug Bridge (Adb) Commands
- dir: `adb` · commands: 20 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `adhan-time` — Adhan Time
- dir: `adhan-time` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): adhan: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `ado-search` — Azure DevOps Repositories Search
- dir: `ado-search` · commands: 5 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `advanced-replace` — Advanced Replace
- dir: `advanced-replace` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `advanced-speech-to-text` — Advanced Speech to Text
- dir: `advanced-speech-to-text` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `aegis` — Aegis Authenticator
- dir: `aegis` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `aerospace` — Aerospace Tiling Window Manager
- dir: `aerospace` · commands: 5 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): shortcutsMenubar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ag-audioflow` — AG AudioFlow
- dir: `ag-audioflow` · commands: 11 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); launchCommand: loads; throws if called (inter-command launch not wired)

### `agent-client-protocol` — Agent Client Protocol
- dir: `agent-client-protocol` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `agent-ecosystem-map` — Agent Ecosystem Map
- dir: `agent-ecosystem-map` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `agent-usage` — Agent Usage
- dir: `agent-usage` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): agent-usage-menubar: mode "menu-bar"; denied Node built-ins in sandbox: fs, module, child_process, http, https
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares background `interval` command(s) — not scheduled

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
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `ai-screenshot` — AI Screenshot
- dir: `ai-screenshot` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ai-text-to-calendar` — AI Text to Calendar
- dir: `ai-text-to-calendar` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `air-quality` — Air Quality
- dir: `air-quality` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): air-quality-menu: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `akkoma` — Akkoma
- dir: `akkoma` · commands: 4 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: fs

### `alacritty` — Alacritty
- dir: `alacritty` · commands: 4 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `aleph` — Aleph Tools
- dir: `aleph` · commands: 4 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `alice-ai` — Alice AI - Your Daily AI Actions Companion
- dir: `alice-ai` · commands: 5 · modes: view|menu-bar
- **Blockers:** getSelectedText: throws — selection APIs not wired; unsupported command mode(s): menubar: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

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
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); declares command `arguments[]` — not passed by runtime yet

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
- **Blockers:** denied Node built-ins in sandbox: fs, child_process, http
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `anonaddy` — Addy
- dir: `anonaddy` · commands: 5 · modes: view|no-view
- **Blockers:** getDefaultApplication: throws — application discovery not wired; getFrontmostApplication: throws — application discovery not wired; AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; BrowserExtension: loads; throws if called (browser bridge not wired); launchCommand: loads; throws if called (inter-command launch not wired)

### `another-boring-piece` — Art Wallpapers
- dir: `another-boring-piece` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares background `interval` command(s) — not scheduled

### `antd-open-browser` — Antd
- dir: `antd-open-browser` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `antigravity` — Antigravity
- dir: `antigravity` · commands: 6 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process, http
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `antinote` — Antinote
- dir: `antinote` · commands: 3 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `any-website-search` — Universal Website Search
- dir: `any-website-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `anybox` — Anybox
- dir: `anybox` · commands: 15 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `anytype` — Anytype
- dir: `anytype` · commands: 5 · modes: view
- **Blockers:** declares AI tools[] (12) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `apfel` — Apfel
- dir: `apfel` · commands: 13 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `app` — App Creator
- dir: `app-creator` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `app-icon-generator` — App Icon Generator
- dir: `app-icon-generator` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `app-keeper-manager` — App Keeper Manager
- dir: `app-keeper-manager` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `app-store-connect` — App Store Connect
- dir: `app-store-connect` · commands: 6 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `app-tag-manager` — App Tag Manager
- dir: `app-tag-manager` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `app-updates` — App Updates
- dir: `app-updates` · commands: 4 · modes: view|menu-bar
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; unsupported command mode(s): menu-bar: mode "menu-bar", brew-maintenance: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `appcleaner` — App Cleaner
- dir: `appcleaner` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired)

### `append-clipboard` — Append Clipboard
- dir: `append-clipboard` · commands: 3 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `append-to-file` — Append Text to File
- dir: `append-to-file` · commands: 5 · modes: view|no-view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `appgrid` — AppGrid
- dir: `appgrid` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired

### `apple-notes` — Apple Notes
- dir: `apple-notes` · commands: 7 · modes: view|no-view|menu-bar
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired; unsupported command mode(s): menu-bar: mode "menu-bar"; declares AI tools[] (4) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `apple-passwords` — Apple Password
- dir: `apple-passwords` · commands: 2 · modes: view|no-view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: child_process, module, fs
- Needs review: namespace import of @raycast/api (member usage unverified)

### `apple-photos` — Apple Photos
- dir: `apple-photos` · commands: 2 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs

### `apple-reminders` — Apple Reminders
- dir: `apple-reminders` · commands: 7 · modes: view|menu-bar|no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; unsupported command mode(s): menu-bar: mode "menu-bar"; declares AI tools[] (8) — AI extensions not supported; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `apply-inline-code` — Apply Inline Code
- dir: `apply-inline-code` · commands: 2 · modes: no-view|view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getApplications: throws — application discovery not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `aranet-co2-monitor` — Aranet CO2 Monitor
- dir: `aranet-co2-monitor` · commands: 3 · modes: menu-bar|view
- **Blockers:** unsupported command mode(s): index: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `arc` — Arc
- dir: `arc` · commands: 16 · modes: view|no-view|menu-bar
- **Blockers:** getApplications: throws — application discovery not wired; showInFinder: throws — showInFinder not wired; getSelectedText: throws — selection APIs not wired; unsupported command mode(s): menu-bar: mode "menu-bar"; declares AI tools[] (12) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `archiver` — Archiver
- dir: `archiver` · commands: 4 · modes: view|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `are-na` — Are.na
- dir: `are-na` · commands: 7 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; declares AI tools[] (7) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke)

### `asana` — Asana
- dir: `asana` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `ascii-art-wallpaper` — ASCII Art Wallpaper
- dir: `ascii-art-wallpaper` · commands: 3 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `asset-catalog-extractor` — Asset Catalog Extractor
- dir: `asset-catalog-extractor` · commands: 1 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `at-profile` — @ Profile
- dir: `at-profile` · commands: 6 · modes: view|no-view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired); declares command `arguments[]` — not passed by runtime yet

### `atlassian-data-center` — Atlassian Data Center (Self-Hosted)
- dir: `atlassian-data-center` · commands: 8 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `atomic` — Atomic Data
- dir: `atomic` · commands: 1 · modes: view
- Needs review: @raycast/api:Preferences (not in Invoke surface — needs review)

### `atproto-utilities` — AT Protocol Utilities
- dir: `atproto-utilities` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `audio-device` — Set Audio Device
- dir: `audio-device` · commands: 12 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, https
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `audio-writer` — Audio Writer
- dir: `audio-writer` · commands: 3 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired

### `auto-quit-app` — Auto Quit App
- dir: `auto-quit-app` · commands: 2 · modes: view|menu-bar
- **Blockers:** getApplications: throws — application discovery not wired; getFrontmostApplication: throws — application discovery not wired; unsupported command mode(s): auto-quit-app-menubar: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `avatar` — Avatar
- dir: `avatar` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `awesome-mac` — Awesome Mac
- dir: `awesome-mac` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: https

### `awork` — awork
- dir: `awork` · commands: 3 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; declares AI tools[] (4) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired)

### `aws` — Amazon AWS
- dir: `amazon-aws` · commands: 19 · modes: view
- **Blockers:** declares AI tools[] (10) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares extension-level `ai` instructions — ignored

### `aztu-lms` — AzTU LMS
- dir: `aztu-lms` · commands: 8 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: fs

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

### `bambu-lab` — Bambu Lab Controller
- dir: `bambu-lab` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

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
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `bartender` — Bartender
- dir: `bartender` · commands: 4 · modes: no-view|view
- **Blockers:** declares AI tools[] (4) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:DeeplinkType (not implemented in Invoke)

### `base-stats` — Base Stats
- dir: `base-stats` · commands: 2 · modes: menu-bar
- **Blockers:** unsupported command mode(s): gas-price: mode "menu-bar", gas-price-no-unit: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `base64` — Base64
- dir: `base64` · commands: 3 · modes: view|no-view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported

### `base64-to-file` — Base64 to File
- dir: `base64-to-file` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `battery-menubar` — Battery Menu Bar
- dir: `battery-menubar` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): index: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: declares background `interval` command(s) — not scheduled

### `battery-optimizer` — Battery Optimizer
- dir: `battery-optimizer` · commands: 5 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): battery_optimizer_menu_bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `bear` — Bear Notes
- dir: `bear` · commands: 4 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"; declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `beehiiv` — Beehiiv
- dir: `beehiiv` · commands: 4 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menubar-count-subscribers: mode "menu-bar", menubar-last-email: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `beeper` — Beeper Desktop
- dir: `beeper` · commands: 6 · modes: view|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; declares AI tools[] (6) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `bento-me` — Bento
- dir: `bento-me` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: https

### `beszel` — Beszel
- dir: `beszel-extension` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored

### `better-aliases` — Better Aliases
- dir: `better-aliases` · commands: 11 · modes: view|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `better-uptime` — Better Uptime
- dir: `better-uptime` · commands: 6 · modes: view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `betteraudio` — BetterAudio
- dir: `betteraudio` · commands: 17 · modes: view|no-view|menu-bar
- **Blockers:** getApplications: throws — application discovery not wired; unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `betterdisplay` — BetterDisplay
- dir: `betterdisplay` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (14) — AI extensions not supported; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `betterzip` — BetterZip
- dir: `betterzip` · commands: 3 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `bhagavad-gita-quotes` — Bhagavad Gita Quotes
- dir: `bhagavad-gita-quotes` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired

### `bible` — Bible
- dir: `bible` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `bibmanager` — Bibmanager
- dir: `bibmanager` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, readline

### `bike` — Bike
- dir: `bike` · commands: 13 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `bikeshare-station-status` — Bikeshare Station Status
- dir: `bikeshare-station-status` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): favorite-stations: mode "menu-bar"
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `bilibili` — Bilibili
- dir: `Bilibili` · commands: 5 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads); declares background `interval` command(s) — not scheduled

### `binance` — Binance Portfolio
- dir: `binance` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `binance-exchange` — Binance
- dir: `binance-exchange` · commands: 3 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): my-wallet-menu-bar: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `bing-wallpaper` — Bing Wallpaper
- dir: `bing-wallpaper` · commands: 3 · modes: view|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `biome` — Biome
- dir: `biome` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `bird` — Bird
- dir: `bird` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `bitcoin-price` — Bitcoin Price
- dir: `bitcoin-price` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): bitcoin-menu-bar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `bitly-url-shortener` — Bitly URL Shortener
- dir: `bitly-url-shortener` · commands: 2 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `bitwarden` — Bitwarden Vault
- dir: `bitwarden` · commands: 11 · modes: view|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired; getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process, http, https
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `bj-share` — BJ-Share
- dir: `bj-share` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `bklit-analytics` — Bklit Analytics
- dir: `bklit-analytics` · commands: 2 · modes: menu-bar|view
- **Blockers:** unsupported command mode(s): top-countries-menubar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `blip-raycast` — Blip
- dir: `blip-raycast` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `bluesky` — Bluesky
- dir: `bluesky` · commands: 7 · modes: menu-bar|view
- **Blockers:** unsupported command mode(s): menu-bar-notifications: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `blurhash` — BlurHash
- dir: `blurhash` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `bmw` — BMW
- dir: `bmw` · commands: 12 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): car-overview: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `bobcontrol` — Bob - Control Bob Translate
- dir: `bob` · commands: 10 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `bonjour` — Bonjour
- dir: `bonjour` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu: mode "menu-bar"; denied Node built-ins in sandbox: child_process

### `bonk-price` — BONK Price
- dir: `bonk-price` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): index: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `bootstrap-icons` — Bootstrap Icons
- dir: `bootstrap-icons` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: fs

### `braid` — Braid Design System
- dir: `braid` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `brand-fetch` — Brandfetch
- dir: `brand-fetch` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `brave` — Brave
- dir: `brave` · commands: 5 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `brew` — Brew
- dir: `brew` · commands: 6 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `brew-services` — Manage Services
- dir: `brew-services` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `brightness-control` — Brightness Control
- dir: `brightness-control` · commands: 4 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `browser-bookmarks` — Browser Bookmarks
- dir: `browser-bookmarks` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; getDefaultApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs

### `browser-history` — Browser History
- dir: `browser-history` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `browser-tabs` — Browser Tabs
- dir: `browser-tabs` · commands: 1 · modes: view
- **Blockers:** getDefaultApplication: throws — application discovery not wired; getFrontmostApplication: throws — application discovery not wired; getApplications: throws — application discovery not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `browsers-profiles` — Open Browsers Profiles
- dir: `browsers-profiles` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `brreg` — The Brønnøysund Register Centre Search
- dir: `brreg` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `bugmenot` — BugMeNot
- dir: `bugmenot` · commands: 1 · modes: view
- Needs review: @raycast/api:ListItem (not in Invoke surface — needs review)

### `builtbybit` — BuiltByBit
- dir: `builtbybit` · commands: 4 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): get-notifications: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `bunch` — Bunch
- dir: `bunch` · commands: 9 · modes: view|no-view
- **Blockers:** trash: throws — file trash not wired; getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `bundles` — Bundles
- dir: `bundles` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `cache-control-builder` — Cache-Control Builder
- dir: `cache-control-builder` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `cal-com-share-meeting-links` — Cal.com
- dir: `cal-com-share-meeting-links` · commands: 5 · modes: view
- **Blockers:** declares AI tools[] (33) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `calendly` — Calendly Share Meeting Links
- dir: `calendly` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `calibre-library` — Calibre Library
- dir: `calibre-search` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `caltask` — CalTask
- dir: `caltask` · commands: 4 · modes: view|menu-bar
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

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

### `caschys-blog` — Caschys Blog
- dir: `caschys-blog` · commands: 3 · modes: view|no-view
- **Blockers:** declares AI tools[] (4) — AI extensions not supported; denied Node built-ins in sandbox: https
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `ccusage` — Claude Code Usage (ccusage)
- dir: `ccusage` · commands: 3 · modes: view|menu-bar|no-view
- **Blockers:** unsupported command mode(s): menubar-ccusage: mode "menu-bar"; declares AI tools[] (5) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs, http
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled

### `cerebras` — Cerebras
- dir: `cerebras` · commands: 8 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: http, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; BrowserExtension: loads; throws if called (browser bridge not wired); getSelectedFinderItems: loads; throws if called (Finder selection not wired)
- Needs review: @raycast/api:Navigation (not in Invoke surface — needs review)

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

### `charged` — Charged: Starknet Shortcuts
- dir: `charged` · commands: 7 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `charming-chatgpt` — Charming ChatGPT
- dir: `charming-chatgpt` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `chartmogul` — ChartMogul
- dir: `chartmogul` · commands: 2 · modes: view
- **Blockers:** declares AI tools[] (13) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored

### `chatgo` — ChatGo
- dir: `chatgo` · commands: 6 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `chatgpt` — ChatGPT
- dir: `chatgpt` · commands: 10 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: http, fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; BrowserExtension: loads; throws if called (browser bridge not wired); getSelectedFinderItems: loads; throws if called (Finder selection not wired); declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Navigation (not in Invoke surface — needs review)

### `chatgpt-atlas` — ChatGPT Atlas
- dir: `chatgpt-atlas` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `chatgpt-quick-actions` — ChatGPT Quick Actions
- dir: `chatgpt-quick-actions` · commands: 8 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `chatgpt-search` — ChatGPT Search
- dir: `chatgpt-search` · commands: 1 · modes: view
- **Blockers:** getDefaultApplication: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `chatwork-search` — Chatwork Search
- dir: `search-chatwork` · commands: 3 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Needs review: @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `cheatsheets-remastered` — Cheatsheets Remastered
- dir: `cheatsheets-remastered` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke)

### `checksum` — Checksum
- dir: `checksum` · commands: 4 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menubar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `cheetah` — Cheetah
- dir: `cheetah` · commands: 7 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `chiikawa-character` — Chiikawa Characters
- dir: `chiikawa-character` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `chinese-character` — Chinese Character
- dir: `chinese-character` · commands: 3 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `circle-ci` — CircleCI Workflows
- dir: `circle-ci` · commands: 1 · modes: view
- Needs review: @raycast/api:ImageLike (not in Invoke surface — needs review)

### `circleback` — Circleback
- dir: `circleback` · commands: 3 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Needs review: @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `claude` — Claude
- dir: `claude` · commands: 5 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `claude-code-config-switcher` — Claude Code Switcher
- dir: `claude-code-config-switcher` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `claude-code-launcher` — Claude Code Launcher
- dir: `claude-code-launcher` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `claude-sessions` — Claude Sessions
- dir: `claude-sessions` · commands: 2 · modes: view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: fs, child_process
- Needs review: @raycast/api:useState (not in Invoke surface — needs review); @raycast/api:useEffect (not in Invoke surface — needs review); @raycast/api:readdir (not in Invoke surface — needs review); @raycast/api:stat (not in Invoke surface — needs review); @raycast/utils:useState (not implemented in Invoke); @raycast/utils:useEffect (not implemented in Invoke)

### `claudecast` — ClaudeCast
- dir: `claudecast` · commands: 10 · modes: view|no-view|menu-bar
- **Blockers:** getSelectedText: throws — selection APIs not wired; getFrontmostApplication: throws — application discovery not wired; trash: throws — file trash not wired; unsupported command mode(s): menu-bar-monitor: mode "menu-bar"; denied Node built-ins in sandbox: fs, child_process, readline
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `clean-keyboard` — Clean Keyboard
- dir: `clean-keyboard` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `clean-text` — Clean Text
- dir: `clean-text` · commands: 3 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getSelectedText: throws — selection APIs not wired

### `cleanshotx` — CleanShot X
- dir: `cleanshotx` · commands: 23 · modes: no-view|view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired); declares command `arguments[]` — not passed by runtime yet

### `cling` — Cling File Search
- dir: `cling` · commands: 2 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares command `arguments[]` — not passed by runtime yet

### `clip-swap` — Clip Swap
- dir: `clip-swap` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `clipmate` — Clipmate AI
- dir: `clipmate` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `clipmenu` — ClipMenu
- dir: `clipmenu` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): index: mode "menu-bar"
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `clippyx` — CLIPPyX
- dir: `clippyx` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `clipsign` — Clipsign
- dir: `clipsign` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `clipyai` — Clipyai
- dir: `clipyai` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `clockify` — Clockify
- dir: `clockify` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): clockifymenu: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `clockodo` — Clockodo
- dir: `clockodo` · commands: 8 · modes: view|no-view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored

### `close-apps` — Close All Open Apps
- dir: `close-apps` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `cloud-cli-login-statuses` — Cloud CLI Login Statuses
- dir: `cloud-cli-login-statuses` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

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
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `cocart-docs` — CoCart Docs
- dir: `cocart-docs` · commands: 8 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"

### `code` — Code Execution
- dir: `code-execution` · commands: 1 · modes: no-view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: child_process
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `code-quarkus` — Code Quarkus
- dir: `code-quarkus` · commands: 2 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `code-runway` — Code Runway
- dir: `code-runway` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `code-saver` — Code Saver
- dir: `code-saver` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, https
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `code-stash` — Code Stash
- dir: `code-stash` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

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

### `codex-manager` — Codex Manager
- dir: `codex-manager` · commands: 3 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; trash: throws — file trash not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired)

### `coffee` — Coffee
- dir: `coffee` · commands: 9 · modes: no-view|view|menu-bar
- **Blockers:** unsupported command mode(s): index: mode "menu-bar"; declares AI tools[] (6) — AI extensions not supported; denied Node built-ins in sandbox: child_process
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); launchCommand: loads; throws if called (inter-command launch not wired); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `coinmarketcap-crypto-price-crawler` — Coinmarketcap Crypto Search
- dir: `coinmarketcap-crypto-crawler` · commands: 3 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `colima` — Colima
- dir: `colima` · commands: 5 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `color-casket` — Color Casket
- dir: `color-casket` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `color-hunt` — Color Hunt
- dir: `color-hunt` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `color-picker` — Color Picker
- dir: `color-picker` · commands: 8 · modes: no-view|view|menu-bar
- **Blockers:** getSelectedText: throws — selection APIs not wired; AI: AI.ask throws — Invoke AI not yet wired; getFrontmostApplication: throws — application discovery not wired; unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired); launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet
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
- Degraded: declares extension-level `ai` instructions — ignored
- Needs review: namespace import of @raycast/api (member usage unverified)

### `cometapi` — CometAPI
- dir: `cometapi` · commands: 7 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `commit-message-formatter` — Commit Message Formatter
- dir: `commit-message-formatter` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `common-directory` — Common Directory
- dir: `common-directory` · commands: 3 · modes: view|menu-bar
- **Blockers:** showInFinder: throws — showInFinder not wired; unsupported command mode(s): open-common-directory-menu-bar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired)

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
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `confluence` — Confluence
- dir: `confluence-search` · commands: 8 · modes: view|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `connect-to-vpn` — Connect to VPN
- dir: `connect-to-vpn` · commands: 3 · modes: no-view|view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `contexts` — Contexts
- dir: `contexts` · commands: 2 · modes: no-view|view
- **Blockers:** declares AI tools[] (6) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `conventional-comments` — Conventional Comments
- dir: `conventional-comments` · commands: 2 · modes: view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:FormValue (not in Invoke surface — needs review)

### `convert-3d-models` — Convert 3D Models
- dir: `convert-3d-models` · commands: 4 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs

### `convert-px-to-vw-vh` — Pixels to Viewport Width or Height
- dir: `convert-px-to-vw-vh` · commands: 4 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `convert-typescript-to-javascript` — Convert TypeScript to JavaScript
- dir: `convert-typescript-to-javascript` · commands: 2 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

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

### `copy-notion-markdown-link` — Copy Notion Markdown Link
- dir: `copy-notion-markdown-link` · commands: 1 · modes: no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

### `copy-path` — Copy Path
- dir: `copy-path` · commands: 1 · modes: no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); updateCommandMetadata: loads; no-op (command metadata updates not wired)

### `copy-text-files` — Copy Text Files
- dir: `copy-text-files` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `copymoveto` — CopyMoveTo
- dir: `copymoveto` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); launchCommand: loads; throws if called (inter-command launch not wired)

### `copyq-clipboard-manager` — CopyQ Clipboard Manager
- dir: `copyq-clipboard-manager` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `corcel` — Corcel AI
- dir: `corcel` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `cosmic-bookmarks` — Cosmic Bookmarks
- dir: `cosmic-bookmarks` · commands: 3 · modes: view|no-view|menu-bar
- **Blockers:** getSelectedText: throws — selection APIs not wired; unsupported command mode(s): menubar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `coze` — Coze
- dir: `coze` · commands: 3 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:fetch (not in Invoke surface — needs review)

### `craft-cms-docs` — Craft CMS
- dir: `craft-cms-docs` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `craftdocs` — Craft
- dir: `craftdocs` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: namespace import of @raycast/api (member usage unverified)

### `crawldoc` — CrawlDoc - Documentations Search Engine
- dir: `crawldoc` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: https

### `create-remix` — Create Remix
- dir: `raycast-create-remix` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `create-t3-app` — Create T3 App
- dir: `create-t3-app` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cricketcast` — CricketCast
- dir: `cricketcast` · commands: 3 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): scores-menu-bar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `croc-transfer` — Croc Transfer
- dir: `croc-transfer` · commands: 4 · modes: view|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); declares command `arguments[]` — not passed by runtime yet

### `cron-manager` — Cron Manager
- dir: `cron-manager` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `crossbell` — Crossbell
- dir: `crossbell` · commands: 5 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `crypto-price` — Crypto Price
- dir: `crypto-price` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `csfd` — ČSFD
- dir: `csfd` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `csv-to-excel` — Convert CSV to Excel
- dir: `csv-to-excel` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `cta` — CTA - Chicago Transit Authority
- dir: `cta` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `curl` — cURL
- dir: `curl` · commands: 2 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Navigation (not in Invoke surface — needs review)

### `cursor-agents` — Cursor Agents
- dir: `cursor-agents` · commands: 3 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"; declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored

### `cursor-costs` — Cursor Costs
- dir: `cursor-costs` · commands: 2 · modes: menu-bar|view
- **Blockers:** unsupported command mode(s): cursor-costs-menu: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `cursor-directory` — Cursor Directory
- dir: `cursor-directory` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `cursor-recent-projects` — Cursor
- dir: `cursor-recent-projects` · commands: 5 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `custom-folder` — Custom Folder
- dir: `custom-folder` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `custom-icon` — Custom Icon
- dir: `custom-icon` · commands: 2 · modes: view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `cut-out` — Cut Out
- dir: `cut-out` · commands: 2 · modes: no-view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `cyberchef` — CyberChef
- dir: `cyberchef` · commands: 62 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `cyberduck` — Cyberduck
- dir: `cyberduck` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs

### `dagster` — Dagster
- dir: `dagster` · commands: 4 · modes: view|no-view
- **Blockers:** declares AI tools[] (7) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `daily-sites` — Daily Sites - Site Launcher
- dir: `daily-sites` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `dash` — Dash
- dir: `dash` · commands: 3 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `dash-off` — Dash Off
- dir: `dash-off` · commands: 2 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired; OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `dashlane-vault` — Dashlane Vault
- dir: `dashlane-vault` · commands: 4 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

### `datafast` — Datafast
- dir: `datafast` · commands: 7 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar-realtime: mode "menu-bar"
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `day-one` — Day One
- dir: `day-one` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `days-until-christmas` — Days Until Christmas
- dir: `days-until-christmas` · commands: 2 · modes: no-view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `days2` — Days 2 - Google Calendar Countdown
- dir: `days2` · commands: 3 · modes: view|no-view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `db-schema-explorer` — DB Schema Explorer
- dir: `db-schema-explorer` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `debank` — debank
- dir: `debank` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:ActionPanelItem (not in Invoke surface — needs review); @raycast/api:AlertActionStyle (not in Invoke surface — needs review); @raycast/api:ListSection (not in Invoke surface — needs review)

### `deepcast` — Deepcast
- dir: `deepcast` · commands: 33 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `deepseeker` — Deepseek Quick Actions
- dir: `deepseeker` · commands: 12 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `deepwiki` — DeepWiki
- dir: `deepwiki` · commands: 3 · modes: no-view|view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:LaunchProps (not implemented in Invoke); @raycast/utils:open (not implemented in Invoke); @raycast/utils:Action (not implemented in Invoke); @raycast/utils:ActionPanel (not implemented in Invoke); @raycast/utils:Icon (not implemented in Invoke); @raycast/utils:launchCommand (not implemented in Invoke); @raycast/utils:LaunchType (not implemented in Invoke); @raycast/utils:List (not implemented in Invoke); @raycast/utils:showToast (not implemented in Invoke); @raycast/utils:Toast (not implemented in Invoke)

### `default-web-browser-manager` — Default Web Browser Manager
- dir: `default-web-browser-manager` · commands: 2 · modes: view|no-view
- **Blockers:** getDefaultApplication: throws — application discovery not wired; denied Node built-ins in sandbox: child_process

### `defbro` — Defbro
- dir: `defbro` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `defuddle` — Defuddle
- dir: `defuddle` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `delivery-tracker` — Delivery Tracker
- dir: `delivery-tracker` · commands: 4 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `demo-flow` — Demo Flow
- dir: `demo-flow` · commands: 5 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired)

### `deno-deploy` — Deno Deploy
- dir: `deno-deploy` · commands: 4 · modes: view|no-view
- **Blockers:** declares AI tools[] (6) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `descript-to-youtube-chapters` — Descript to YouTube Chapters
- dir: `descript-to-youtube-chapters` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `desktop-manager` — Desktop Manager
- dir: `desktop-manager` · commands: 6 · modes: view|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired; trash: throws — file trash not wired; denied Node built-ins in sandbox: fs

### `desktoprenamer` — DesktopRenamer
- dir: `desktoprenamer` · commands: 10 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `deta-space` — Deta Space
- dir: `deta-space` · commands: 5 · modes: view
- Needs review: @raycast/utils:CachedPromiseOptions (not implemented in Invoke)

### `dev-cache-cleaner` — Dev Cache Cleaner
- dir: `dev-cache-cleaner` · commands: 3 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: declares background `interval` command(s) — not scheduled

### `dev-servers` — Dev Servers
- dir: `dev-servers` · commands: 2 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `devdocs` — DevDocs
- dir: `devdocs` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

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

### `dicom` — DICOM
- dir: `dicom` · commands: 1 · modes: view
- Needs review: @raycast/utils:useStreamJSON (not implemented in Invoke)

### `dict-cc` — dict.cc
- dir: `dict-cc` · commands: 3 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs, https

### `dictionary` — Web Dictionaries
- dir: `dictionary` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `diff-view` — Diff View
- dir: `diff-view` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `digger` — Digger
- dir: `digger` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: dns, tls
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `discord` — Discord
- dir: `discord` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `discord-timestamps` — Discord Timestamps
- dir: `discord-timestamps` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

### `disk-usage` — Disk Usage
- dir: `disk-usage` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs, child_process, readline
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `diskutil` — Disk Utility
- dir: `diskutil` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `diskutil-mac` — Diskutil
- dir: `diskutil-mac` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `display-input-switcher` — Display Input Switcher
- dir: `display-input-switcher` · commands: 3 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `display-modes` — Display Modes
- dir: `display-modes` · commands: 3 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): display-modes-status-menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `displayplacer` — Display Placer
- dir: `displayplacer` · commands: 7 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `dlmoji` — DLmoji
- dir: `dlmoji` · commands: 1 · modes: view
- Needs review: @raycast/api:Component (not in Invoke surface — needs review); @raycast/api:Fragment (not in Invoke surface — needs review); @raycast/api:checkEmojiOnly (not in Invoke surface — needs review)

### `dnb-book-lookup` — DNB Book Lookup
- dir: `dnb-book-lookup` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `do-not-disturb` — Do Not Disturb
- dir: `do-not-disturb` · commands: 4 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `dock` — Dock
- dir: `dock` · commands: 4 · modes: no-view|menu-bar
- **Blockers:** unsupported command mode(s): move-dock: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `dock-tinker` — Dock Tinker
- dir: `dock-tinker` · commands: 12 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

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

### `dolar-cripto-ar` — DolarCripto AR
- dir: `dolar-cripto-ar` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): index: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `done-bear` — Done Bear
- dir: `done-bear` · commands: 10 · modes: view|menu-bar
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; unsupported command mode(s): menu-bar-today: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `doorstopper` — Doorstopper
- dir: `doorstopper` · commands: 5 · modes: no-view|menu-bar
- **Blockers:** unsupported command mode(s): statusmenu: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); launchCommand: loads; throws if called (inter-command launch not wired)

### `dot-new` — dot-new
- dir: `dot-new` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `dot-underscore-files-cleaner` — Dot Underscore Files Cleaner
- dir: `dot-underscore-files-cleaner` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `dota-2` — Dota 2
- dir: `dota-2` · commands: 2 · modes: view
- Needs review: @raycast/api:useState (not in Invoke surface — needs review); @raycast/api:useEffect (not in Invoke surface — needs review); @raycast/api:useMemo (not in Invoke surface — needs review)

### `dotmate` — Dotmate
- dir: `dotmate` · commands: 5 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `doubao-tts` — Doubao TTS
- dir: `doubao-tts` · commands: 4 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process, fs

### `doutu` — DouTu
- dir: `doutu` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `downloads-manager` — Downloads Manager
- dir: `downloads-manager` · commands: 7 · modes: view|no-view
- **Blockers:** trash: throws — file trash not wired; showInFinder: throws — showInFinder not wired; declares AI tools[] (6) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `drafts` — Drafts
- dir: `drafts` · commands: 18 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; getApplications: throws — application discovery not wired; declares AI tools[] (9) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `dropover` — Dropover
- dir: `dropover` · commands: 2 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `dropshare` — Dropshare
- dir: `dropshare` · commands: 6 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `drupal-toolbox` — Drupal Toolbox
- dir: `drupal-toolbox` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `dtf` — DTF
- dir: `dtf` · commands: 8 · modes: view|menu-bar
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; unsupported command mode(s): menu-bar: mode "menu-bar"; declares AI tools[] (6) — AI extensions not supported
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `dub` — Dub
- dir: `dub` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; getSelectedText: throws — selection APIs not wired; declares AI tools[] (6) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `duck-facts` — Duck Facts
- dir: `duck-facts` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored

### `duckduckgo-image-search` — DuckDuckGo Image Search
- dir: `duckduckgo-image-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `dungeons-dragons` — Dungeons & Dragons
- dir: `dungeons-and-dragons` · commands: 6 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `dust-tt` — Ask Dust
- dir: `dust-tt` · commands: 6 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); updateCommandMetadata: loads; no-op (command metadata updates not wired); declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `e2b` — E2B Code Interpreter
- dir: `e2b` · commands: 1 · modes: no-view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `eagle` — Eagle
- dir: `eagle` · commands: 6 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `easy-invoice` — Easy Invoice
- dir: `easy-invoice` · commands: 4 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; trash: throws — file trash not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `easy-new-file` — Easy New File
- dir: `easy-new-file` · commands: 3 · modes: no-view|view
- **Blockers:** showInFinder: throws — showInFinder not wired; getSelectedText: throws — selection APIs not wired
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); getSelectedFinderItems: loads; throws if called (Finder selection not wired); declares command `arguments[]` — not passed by runtime yet

### `easy-ocr` — Easy OCR
- dir: `easy-ocr` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `easydict` — Easy Dictionary
- dir: `easydict` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `easyvariable` — Easy Variable
- dir: `easyvariable` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired

### `edgestore-raycast` — EdgeStore
- dir: `edgestore-raycast` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: https, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `effect-docs` — Effect Docs
- dir: `effect-docs` · commands: 2 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (2) — AI extensions not supported
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `element` — Element
- dir: `element` · commands: 2 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired

### `elevenlabs-tts` — ElevenLabs TTS
- dir: `elevenlabs-tts` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process, fs

### `elgato-key-light` — Elgato Key Light
- dir: `elgato-key-light` · commands: 7 · modes: no-view|view
- **Blockers:** declares AI tools[] (7) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

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

### `epim` — Entra PIM Role
- dir: `epim` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `espanso` — Espanso
- dir: `espanso` · commands: 5 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

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

### `ets2-ats-profiles` — ETS2/ATS Profiles
- dir: `ets2-ats-profiles` · commands: 3 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; trash: throws — file trash not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `eudic` — Eudic
- dir: `eudic` · commands: 3 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `evaluate-math-expression` — Evaluate Math Expression
- dir: `evaluate-math-expression` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `evernote` — Evernote Instant Search
- dir: `evernote` · commands: 2 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs

### `everything-search` — Everything
- dir: `everything-search` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, https, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `exa-search` — Exa
- dir: `exa` · commands: 2 · modes: view|no-view
- **Blockers:** declares AI tools[] (5) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `exif` — Exif Viewer
- dir: `exif` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; BrowserExtension: loads; throws if called (browser bridge not wired); launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `expand-video-canvas` — Expand Video Canvas
- dir: `expand-video-canvas` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

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

### `fancy-text` — Fancy Text
- dir: `fancy-text` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `fantastical` — Fantastical
- dir: `fantastical` · commands: 4 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `farrago` — Farrago
- dir: `farrago` · commands: 3 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs, dgram

### `fathom` — Fathom
- dir: `fathom` · commands: 2 · modes: view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `fathom-analytics-stats` — Fathom Analytics Stats
- dir: `fathom-analytics-stats` · commands: 9 · modes: view|menu-bar|no-view
- **Blockers:** unsupported command mode(s): current-visitors-menu-bar: mode "menu-bar"
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `favoro` — FAVORO
- dir: `favoro` · commands: 3 · modes: view|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `feedbin` — Feedbin
- dir: `feedbin` · commands: 6 · modes: view|menu-bar|no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired; unsupported command mode(s): unread-menu-bar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useAI (not implemented in Invoke); @raycast/utils:CachedPromiseOptions (not implemented in Invoke)

### `feishu-document-creator` — Feishu Document Creator
- dir: `feishu-document-creator` · commands: 4 · modes: no-view
- **Blockers:** getDefaultApplication: throws — application discovery not wired

### `fetch-youtube-transcript` — Fetch YouTube Transcript
- dir: `fetch-youtube-transcript` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ffmpeg` — FFmpeg - View, Analyze and Manipulate
- dir: `ffmpeg` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired); declares extension-level `ai` instructions — ignored

### `fifteen-million-merits` — Fifteen Million Merits
- dir: `fifteen-million-merits` · commands: 2 · modes: menu-bar|no-view
- **Blockers:** unsupported command mode(s): show-ai-agent-sessions-counter: mode "menu-bar"; denied Node built-ins in sandbox: fs, child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

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
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `file-manager` — File Manager
- dir: `file-manager` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `file-organizer` — File Organizer
- dir: `file-organizer` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `filemaker-snippets` — FileMaker Snippets
- dir: `filemaker-snippets` · commands: 7 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `files-shelf` — Files Shelf
- dir: `files-shelf` · commands: 5 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

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
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

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
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `fip` — Fip
- dir: `fip` · commands: 6 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `firebase-import-export` — Manage Firebase Firestore Collections
- dir: `firebase-import-export` · commands: 2 · modes: no-view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `firebase-remote-config-admin` — Firebase - Remote Config
- dir: `firebase-remote-config-admin` · commands: 5 · modes: view
- **Blockers:** declares AI tools[] (10) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `firecrawl` — Firecrawl
- dir: `firecrawl` · commands: 2 · modes: no-view|view
- **Blockers:** declares AI tools[] (4) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `firefox-tabs` — Firefox Tabs
- dir: `firefox-tabs` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `fisher` — Fisher
- dir: `fisher` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `fitdesk` — FitDesk
- dir: `fitdesk` · commands: 4 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): exercise-reminder: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired)

### `fix-helper` — FIX Helper
- dir: `fix-helper` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: https, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `fix-language` — Fix Language
- dir: `fix-language` · commands: 3 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `fix-link-embeds` — Fix Link Embeds
- dir: `fix-link-embeds` · commands: 3 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `fizzy` — Fizzy
- dir: `fizzy` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `flashspace` — FlashSpace
- dir: `flashspace` · commands: 27 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `flaticon` — Flaticon — Search Icons
- dir: `flaticon` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `flibusta-search` — Flibusta Search
- dir: `flibusta-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

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
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `flush-dns` — Flush DNS
- dir: `flush-dns` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `flutter-documentation-search` — Flutter Documentation Search
- dir: `flutter-documentation-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `flutter-utils` — Flutter Utils
- dir: `flutter-utils` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired)

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
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `focustask` — FocusTask
- dir: `focustask` · commands: 3 · modes: menu-bar|view
- **Blockers:** unsupported command mode(s): current-menubar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:Action (not implemented in Invoke); @raycast/utils:ActionPanel (not implemented in Invoke); @raycast/utils:Form (not implemented in Invoke); @raycast/utils:Icon (not implemented in Invoke); @raycast/utils:popToRoot (not implemented in Invoke); @raycast/utils:showToast (not implemented in Invoke); @raycast/utils:Toast (not implemented in Invoke); @raycast/utils:open (not implemented in Invoke)

### `folder-cleaner` — Folder Cleaner
- dir: `folder-cleaner` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `folder-organizer` — Folder Organizer
- dir: `folder-organizer` · commands: 3 · modes: no-view|view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `folder-search` — Folder Search
- dir: `folder-search` · commands: 2 · modes: view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `font-converter` — Font Converter
- dir: `font-converter` · commands: 3 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `font-search` — Font Search
- dir: `font-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `font-sniper` — Font Sniper
- dir: `font-sniper` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `fork-repositories` — Fork Repositories
- dir: `fork-repositories` · commands: 2 · modes: view|menu-bar
- **Blockers:** getApplications: throws — application discovery not wired; unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: fs

### `forked-extensions` — Forked Extensions
- dir: `forked-extensions` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `forscore` — forScore
- dir: `forscore` · commands: 6 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `foundry-cast-cli` — Foundry Cast CLI
- dir: `foundry-cast-cli` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `frame-crop-art` — Frame Crop - Discover Art for Your TV
- dir: `frame-crop` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `freeagent` — FreeAgent
- dir: `freeagent` · commands: 8 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; declares AI tools[] (25) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `freesound` — Freesound
- dir: `freesound` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `french-company-search` — French Company Search
- dir: `french-company-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `fronius-inverter` — Fronius Inverter
- dir: `fronius-inverter` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): watch: mode "menu-bar"

### `fuelix` — Fuelix
- dir: `fuelix` · commands: 16 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `gemini-tts` — Gemini TTS
- dir: `gemini-tts` · commands: 9 · modes: no-view|view|menu-bar
- **Blockers:** getSelectedText: throws — selection APIs not wired; unsupported command mode(s): playback-status: mode "menu-bar"; denied Node built-ins in sandbox: fs, child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `geoping` — Geoping
- dir: `geoping` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `gerrit-code-review` — Gerrit Code Review
- dir: `gerrit-code-review` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: http, https

### `get-app-icon` — Get App Icon
- dir: `get-app-icon` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process, fs

### `get-favicon` — Get Favicon
- dir: `get-favicon` · commands: 3 · modes: no-view
- **Blockers:** showInFinder: throws — showInFinder not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `get-note` — GetNote
- dir: `get-note` · commands: 5 · modes: view
- **Blockers:** declares AI tools[] (14) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `get-ssh-key` — Get SSH Key
- dir: `get-ssh-key` · commands: 2 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `getcompress` — GetCompress
- dir: `getcompress` · commands: 3 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); runPowerShellScript: Windows-only; throws on macOS (import loads); declares command `arguments[]` — not passed by runtime yet

### `getsound` — GetSound
- dir: `getsound` · commands: 3 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `gh-pic` — GHPic
- dir: `gh-pic` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `ghostty` — Ghostty
- dir: `ghostty` · commands: 7 · modes: no-view|view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `ghq` — ghq
- dir: `ghq` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `gif-search` — GIF Search
- dir: `gif-search` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `git` — Git
- dir: `git` · commands: 6 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `git-assistant` — Git Assistant
- dir: `git-assistant` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (21) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `git-batch-tools` — Git Batch Tools
- dir: `git-batch-tools` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `git-buddy` — Git Buddy
- dir: `git-buddy` · commands: 3 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `git-co-authors` — Git Co-Authors
- dir: `git-co-authors` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `git-profile` — Git Profile
- dir: `git-profile` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `git-repos` — Git Repos
- dir: `git-repos` · commands: 3 · modes: view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: child_process, fs

### `git-worktrees` — Git Worktrees
- dir: `git-worktrees` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `gitcdn` — GitCDN
- dir: `gitcdn` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `gitfox` — Gitfox Repositories
- dir: `gitfox` · commands: 3 · modes: view|menu-bar|no-view
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `github` — GitHub
- dir: `github` · commands: 20 · modes: view|menu-bar
- **Blockers:** showInFinder: throws — showInFinder not wired; unsupported command mode(s): unread-notifications: mode "menu-bar", my-issues-menu: mode "menu-bar", my-stats-menu: mode "menu-bar", my-pull-requests-menu: mode "menu-bar"; declares AI tools[] (15) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:Preferences (not in Invoke surface — needs review); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `github-codespaces` — GitHub Codespaces
- dir: `github-codespaces` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): active-codespaces: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `github-copilot` — GitHub Copilot
- dir: `github-copilot` · commands: 5 · modes: view|menu-bar
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; unsupported command mode(s): github-copilot-tasks: mode "menu-bar"; declares AI tools[] (2) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke)

### `github-for-enterprise` — GitHub Enterprise
- dir: `github-for-enterprise` · commands: 8 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): unread-notifications: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:FormValues (not in Invoke surface — needs review); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `github-gist` — GitHub Gist
- dir: `github-gist` · commands: 2 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getSelectedText: throws — selection APIs not wired
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `github-menu-bar` — GitHub Commits Menu
- dir: `github-menu-bar` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): menu: mode "menu-bar"
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `github-repository-search` — GitHub Repository Search
- dir: `github-repository-search` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `github-review-requests` — GitHub Review Requests
- dir: `github-review-requests` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): actionablePullRequests: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `github-search` — GitHub Search
- dir: `github-search` · commands: 2 · modes: view
- **Blockers:** getDefaultApplication: throws — application discovery not wired
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `github-status` — GitHub Status
- dir: `github-status` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored

### `github-trending` — GitHub Trending
- dir: `github-trending` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:KeyEquivalent (not in Invoke surface — needs review); @raycast/utils:Action (not implemented in Invoke); @raycast/utils:ActionPanel (not implemented in Invoke); @raycast/utils:Detail (not implemented in Invoke); @raycast/utils:Icon (not implemented in Invoke)

### `gitignore` — Gitignore
- dir: `gitignore` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `gitlab` — GitLab
- dir: `gitlab` · commands: 24 · modes: view|menu-bar|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; unsupported command mode(s): todomenubar: mode "menu-bar", mrmenu: mode "menu-bar", issuemenu: mode "menu-bar"; declares AI tools[] (12) — AI extensions not supported; denied Node built-ins in sandbox: https, fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `gitpod` — Gitpod
- dir: `gitpod` · commands: 4 · modes: view|menu-bar
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; getApplications: throws — application discovery not wired; unsupported command mode(s): menubar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `gles-to-malioc` — GLES to MaliOC
- dir: `gles-to-malioc` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `global-media-key` — Media Key Emulate
- dir: `global-media-key` · commands: 5 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `globalping` — Globalping
- dir: `globalping` · commands: 5 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `gmail` — Gmail
- dir: `gmail` · commands: 9 · modes: view|no-view|menu-bar
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; unsupported command mode(s): unreadmailsmenu: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `gmail-accounts` — Gmail Accounts
- dir: `gmail-accounts` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `gokapi` — Gokapi
- dir: `gokapi` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `goodlinks` — GoodLinks
- dir: `goodlinks` · commands: 3 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired

### `google-books` — Google Books
- dir: `google-books` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `google-calendar` — Google Calendar
- dir: `google-calendar` · commands: 5 · modes: view
- **Blockers:** declares AI tools[] (9) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired)
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `google-calendar-quickadd` — Google Calendar Events Quick Add
- dir: `google-calendar-quickadd` · commands: 2 · modes: no-view|view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `google-chrome` — Google Chrome
- dir: `google-chrome` · commands: 10 · modes: view|no-view
- **Blockers:** declares AI tools[] (7) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: declares extension-level `ai` instructions — ignored
- Needs review: namespace import of @raycast/api (member usage unverified)

### `google-chrome-profiles` — Google Chrome Profiles
- dir: `google-chrome-profiles` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `google-contacts` — Google Contacts
- dir: `google-contacts` · commands: 3 · modes: view|no-view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `google-drive` — Google Drive
- dir: `google-drive` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `google-lens` — Google Lens
- dir: `google-lens` · commands: 1 · modes: no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `google-maps-search` — Google Maps Search
- dir: `google-maps-search` · commands: 4 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `google-search` — Google Search
- dir: `google-search` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `google-tasks` — Google Tasks
- dir: `google-tasks` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `google-workspace` — Google Workspace
- dir: `google-workspace` · commands: 7 · modes: no-view|view|menu-bar
- **Blockers:** unsupported command mode(s): starred-google-drive-files-menubar: mode "menu-bar"; declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:WithAccessTokenComponentOrFn (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `gopass` — Gopass
- dir: `gopass` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `gpu-fleet-monitor` — GPU Fleet Monitor
- dir: `gpu-fleet-monitor` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `gradient-generator` — Gradient Generator
- dir: `gradient-generator` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `gram` — Gram
- dir: `gram` · commands: 3 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `grammari-x` — Grammarix
- dir: `grammari-x` · commands: 4 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `grammaring` — Grammaring
- dir: `grammaring` · commands: 2 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `granola` — Granola
- dir: `granola` · commands: 7 · modes: view|no-view
- **Blockers:** declares AI tools[] (7) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `grok-ai` — Grok AI
- dir: `grok-ai` · commands: 3 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `groq` — Groq
- dir: `groq` · commands: 14 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `groq-tools` — GROQ Tools
- dir: `groq-tools` · commands: 3 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:ComponentType (not in Invoke surface — needs review); @raycast/api:SetStateAction (not in Invoke surface — needs review); @raycast/api:Dispatch (not in Invoke surface — needs review); @raycast/api:useState (not in Invoke surface — needs review); @raycast/api:useEffect (not in Invoke surface — needs review); @raycast/api:readFile (not in Invoke surface — needs review)

### `grpcui` — gRPC UI
- dir: `grpcui` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

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

### `hacker-news` — Hacker News
- dir: `hacker-news` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored

### `hacker-news-top-stories` — Hacker News Top Stories
- dir: `hacker-news-top-stories` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): view-top-stories: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: declares background `interval` command(s) — not scheduled

### `hackmd` — HackMD
- dir: `hackmd` · commands: 4 · modes: view
- **Blockers:** declares AI tools[] (8) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `hakuna` — Hakuna
- dir: `hakuna` · commands: 9 · modes: view|menu-bar|no-view
- **Blockers:** unsupported command mode(s): menubar: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

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

### `harmonic` — Harmonic
- dir: `harmonic` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `harpoon` — Harpoon
- dir: `harpoon` · commands: 6 · modes: no-view|view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `harvest` — Harvest
- dir: `harvest` · commands: 6 · modes: view|no-view|menu-bar
- **Blockers:** getApplications: throws — application discovery not wired; unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `haystack` — Haystack
- dir: `haystack` · commands: 4 · modes: view|no-view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:useStreamJSON (not implemented in Invoke)

### `hdri-library` — HDRI Library
- dir: `hdri-library` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `height` — Height
- dir: `height` · commands: 5 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; getApplications: throws — application discovery not wired
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:CachedPromiseOptions (not implemented in Invoke)

### `helium` — Helium
- dir: `helium` · commands: 6 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `hellonext-wallpapers` — Hellonext Wallpapers
- dir: `hellonext-wallpapers` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `helm-chart` — Helm Chart
- dir: `helm-chart` · commands: 1 · modes: view
- Needs review: @raycast/utils:Response (not implemented in Invoke)

### `heptabase` — Heptabase
- dir: `heptabase` · commands: 6 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `hermes-agent` — Hermes Agent
- dir: `hermes-agent` · commands: 6 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process, net
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `heroku` — Heroku
- dir: `heroku` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: https
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `hevy` — Hevy
- dir: `hevy` · commands: 2 · modes: view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored

### `heyclaude` — HeyClaude
- dir: `heyclaude` · commands: 14 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `hidden-icons` — Hidden Icons
- dir: `hidden-icons` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `hide-files` — Hide Files
- dir: `hide-files` · commands: 4 · modes: no-view|view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `hiit` — HIIT
- dir: `hiit` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `hijri-converter` — Hijri Converter
- dir: `hijri-converter` · commands: 5 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `himalaya` — Himalaya
- dir: `himalaya` · commands: 3 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `hole-sandbox-launcher` — Hole Sandbox Launcher
- dir: `hole-sandbox-launcher` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process

### `homeassistant` — Home Assistant
- dir: `homeassistant` · commands: 43 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): notificationmenu: mode "menu-bar", weathermenu: mode "menu-bar", mediaplayermenu: mode "menu-bar", lightsmenu: mode "menu-bar", coversmenu: mode "menu-bar", batteriesmenu: mode "menu-bar", entitiesmenu: mode "menu-bar", entitymenu01: mode "menu-bar", entitymenu02: mode "menu-bar", entitymenu03: mode "menu-bar", calendarmenu: mode "menu-bar"; declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: fs, https, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `homey` — Homey
- dir: `homey` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `hop` — Hop
- dir: `hop` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `host-switch` — Host Switch
- dir: `host-switch` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

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

### `hubspot-portal-launcher` — HubSpot Portal Launcher
- dir: `hubspot-portal-launcher` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `hue` — Hue
- dir: `hue` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: tls, https, net, fs, http2, dns
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `hugeicons-ui` — Hugeicons UI
- dir: `hugeicons-ui` · commands: 4 · modes: view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `huggingcast` — Huggingcast
- dir: `huggingcast` · commands: 6 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `hypersonic` — Hypersonic
- dir: `hypersonic` · commands: 2 · modes: view|menu-bar
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; getApplications: throws — application discovery not wired; unsupported command mode(s): active-todos: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:TransparentEmpty (not in Invoke surface — needs review); @raycast/api:useDatabases (not in Invoke surface — needs review); @raycast/api:useFilter (not in Invoke surface — needs review); @raycast/api:useAuth (not in Invoke surface — needs review); @raycast/api:Tag (not in Invoke surface — needs review); @raycast/api:AuthorizationAction (not in Invoke surface — needs review); @raycast/api:OpenPreferencesAction (not in Invoke surface — needs review); @raycast/api:discord (not in Invoke surface — needs review); @raycast/api:figma (not in Invoke surface — needs review); @raycast/api:github (not in Invoke surface — needs review); @raycast/api:gitlab (not in Invoke surface — needs review); @raycast/api:linear (not in Invoke surface — needs review); @raycast/api:notion (not in Invoke surface — needs review); @raycast/api:slack (not in Invoke surface — needs review); @raycast/api:x (not in Invoke surface — needs review); @raycast/api:youtube (not in Invoke surface — needs review); @raycast/api:reauthorize (not in Invoke surface — needs review); @raycast/api:Project (not in Invoke surface — needs review); @raycast/api:useMemo (not in Invoke surface — needs review); @raycast/api:useState (not in Invoke surface — needs review); @raycast/api:getTodos (not in Invoke surface — needs review); @raycast/api:Filter (not in Invoke surface — needs review); @raycast/utils:useDatabases (not implemented in Invoke); @raycast/utils:useFilter (not implemented in Invoke); @raycast/utils:Tag (not implemented in Invoke); @raycast/utils:Project (not implemented in Invoke); @raycast/utils:Action (not implemented in Invoke); @raycast/utils:ActionPanel (not implemented in Invoke); @raycast/utils:Color (not implemented in Invoke); @raycast/utils:Icon (not implemented in Invoke); @raycast/utils:Image (not implemented in Invoke); @raycast/utils:Filter (not implemented in Invoke); @raycast/utils:loadPreferences (not implemented in Invoke); @raycast/utils:parseTodosToDoneWorkString (not implemented in Invoke); @raycast/utils:getTodos (not implemented in Invoke)

### `iconify` — Iconify — Search Icons
- dir: `iconify` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `iconpark` — IconPark
- dir: `iconpark` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `icons8` — Icons8
- dir: `icons8` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `icy-veins-quicklinks` — Icy Veins Quicklinks
- dir: `icy-veins-quicklinks` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ideate` — Ideate
- dir: `ideate` · commands: 3 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `idonthavespotify` — I Don't Have Spotify
- dir: `idonthavespotify` · commands: 10 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, https, child_process

### `ihosts` — iHosts
- dir: `ihosts` · commands: 3 · modes: view|menu-bar|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired; unsupported command mode(s): switch: mode "menu-bar"; denied Node built-ins in sandbox: fs, child_process, https
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ilovepdf` — iLovePDF
- dir: `ilovepdf` · commands: 16 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `image-base64` — Image Base64 Converter
- dir: `image-base64` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `image-flow` — Imageflow
- dir: `image-flow` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `image-hash-rename` — Image Hash Rename
- dir: `image-hash-rename` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `image-search` — Image Web Search
- dir: `image-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `image-shield` — Image Shield
- dir: `image-shield` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `image-to-ascii` — Image to Ascii
- dir: `image-to-ascii` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `image-wallet` — Image Wallet
- dir: `image-wallet` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `imagekit-uploader` — ImageKit Uploader
- dir: `imagekit-uploader` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `imageoptim` — ImageOptim
- dir: `imageoptim` · commands: 1 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `imessage-2fa` — 2FA Code Finder
- dir: `imessage-2fa` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `imgur` — Imgur
- dir: `imgur` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `immich` — Immich
- dir: `immich` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; runPowerShellScript: Windows-only; throws on macOS (import loads); declares command `arguments[]` — not passed by runtime yet

### `inbox-ai` — Inbox AI
- dir: `inbox-ai` · commands: 7 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `incident-io` — Incident.io
- dir: `incident-io` · commands: 4 · modes: view|menu-bar
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; unsupported command mode(s): live-incidents: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `infisical` — Infisical
- dir: `infisical` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

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

### `instant-domain-search` — Instant Domain Search
- dir: `instant-domain-search` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored

### `intermittent-fasting` — Intermittent Fasting
- dir: `intermittent-fasting` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menubar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; updateCommandMetadata: loads; no-op (command metadata updates not wired); launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `internet-radio` — Internet Radio
- dir: `internet-radio` · commands: 11 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): menubar-radio: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; updateCommandMetadata: loads; no-op (command metadata updates not wired); launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ip-geolocation` — IP Geolocation
- dir: `ip-geolocation` · commands: 3 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: net
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `iridium` — Iridium
- dir: `iridium` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `irish-rail` — Irish Rail
- dir: `irish-rail` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: https

### `ishader` — iShader
- dir: `ishader` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `iterm` — iTerm
- dir: `iterm` · commands: 11 · modes: view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `itranslate` — iTranslate
- dir: `itranslate` · commands: 4 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process, fs

### `ivpn` — IVPN
- dir: `ivpn` · commands: 12 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Environment (not in Invoke surface — needs review)

### `iwork` — iWork
- dir: `iwork` · commands: 19 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `jellyamp` — Jellyamp
- dir: `jellyamp` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `jenkins` — Jenkins
- dir: `jenkins` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: http, https
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `jetbrains` — JetBrains Toolbox Recent Projects
- dir: `jetbrains` · commands: 2 · modes: view|menu-bar
- **Blockers:** getApplications: throws — application discovery not wired; unsupported command mode(s): recentMenu: mode "menu-bar"; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `jetpack-commands` — Jetpack Commands
- dir: `jetpack-commands` · commands: 46 · modes: no-view|view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired)

### `jira` — Jira
- dir: `jira` · commands: 9 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; declares AI tools[] (11) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `jira-search` — Jira Search
- dir: `jira-search` · commands: 5 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:ResultItem (not in Invoke surface — needs review); @raycast/api:SearchCommand (not in Invoke surface — needs review); @raycast/api:jiraFetchObject (not in Invoke surface — needs review); @raycast/api:jiraUrl (not in Invoke surface — needs review)

### `jira-search-self-hosted` — Jira Search (Self-Hosted)
- dir: `jira-search-self-hosted` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, https

### `jira-self-hosted` — Jira (Self-Hosted)
- dir: `jira-self-hosted` · commands: 9 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; declares AI tools[] (10) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:withAccessToken (not implemented in Invoke)

### `joey-vocab` — Joey Vocab
- dir: `joey-vocab` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process, fs

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

### `json-resume` — JSON Resume
- dir: `json-resume` · commands: 2 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored

### `json-to-toon-converter` — JSON to TOON Converter
- dir: `json-to-toon-converter` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `jsr` — JSR
- dir: `jsr` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (11) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `jules-agents` — Jules Agents
- dir: `jules-agents` · commands: 4 · modes: view|menu-bar
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; showInFinder: throws — showInFinder not wired; unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired)

### `jump` — Jump
- dir: `jump` · commands: 4 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

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

### `jwt-decoder` — JWT Decoder
- dir: `jwt-decoder` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `kafka` — Kafka
- dir: `kafka` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): kafka-menubar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: declares background `interval` command(s) — not scheduled

### `kaleidoscope` — Kaleidoscope
- dir: `kaleidoscope` · commands: 4 · modes: no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); declares command `arguments[]` — not passed by runtime yet

### `karabiner-profile-switcher` — Karabiner Profile Switcher
- dir: `karabiner-profile-switcher` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `karakeep` — Karakeep
- dir: `karakeep` · commands: 11 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; BrowserExtension: loads; throws if called (browser bridge not wired)

### `kaset-control` — Kaset Control
- dir: `kaset-control` · commands: 12 · modes: menu-bar|view|no-view
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `kde-connect` — KDE Connect
- dir: `kde-connect` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired); declares command `arguments[]` — not passed by runtime yet

### `keepassxc` — KeePassXC
- dir: `keepassxc` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process

### `keeply` — Keeply
- dir: `keeply` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `kef-control` — Control Kef
- dir: `kef-control` · commands: 3 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): set-volume-menubar: mode "menu-bar"; declares AI tools[] (3) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `keka` — Keka
- dir: `keka` · commands: 3 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `key-value` — Key Value
- dir: `key-value` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `keyboard-brightness` — Keyboard Brightness
- dir: `keyboard-brightness` · commands: 4 · modes: no-view|menu-bar
- **Blockers:** unsupported command mode(s): menubar-keyboard-brightness: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `keyboard-shortcut-sequences` — Keyboard Shortcut Sequences
- dir: `keyboard-shortcut-sequences` · commands: 2 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `keyboard-win-mac-switch` — Keyboard Win Mac Switch
- dir: `keyboard-win-mac-switch` · commands: 2 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `keyraycast` — KeyRaycast
- dir: `keyraycast` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `kill-mcp` — Kill MCP Servers
- dir: `kill-mcp` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `kill-node-modules` — Kill Node Modules
- dir: `kill-node-modules` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `kill-process` — Kill Process
- dir: `kill-process` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `kimai` — Kimai
- dir: `kimai` · commands: 4 · modes: view|menu-bar|no-view
- **Blockers:** unsupported command mode(s): logged-hours: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `kimi` — Kimi
- dir: `kimi` · commands: 5 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `kinopio-inbox` — Kinopio Inbox
- dir: `kinopio-inbox` · commands: 2 · modes: view|no-view
- Needs review: @raycast/api:Preferences (not in Invoke surface — needs review)

### `kiro` — Kiro
- dir: `kiro` · commands: 5 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `kitty` — Kitty
- dir: `kitty` · commands: 5 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `klack` — Klack
- dir: `klack` · commands: 10 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; declares AI tools[] (7) — AI extensions not supported; denied Node built-ins in sandbox: child_process

### `knowyourmeme` — KnowYourMeme
- dir: `knowyourmeme` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

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

### `kubectx` — kubectx
- dir: `kubectx` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `kubens` — kubens
- dir: `kubens` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `kurslog` — Kurslog
- dir: `kurslog` · commands: 5 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `lacinka` — Lacinka
- dir: `lacinka` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `language-detector` — Language Detector
- dir: `language-detector` · commands: 3 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired; AI: AI.ask throws — Invoke AI not yet wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `lapack-blas-documentation-search` — LAPACK/BLAS Documentation Search
- dir: `lapack-blas-documentation-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `larajobs-search` — Search LaraJobs
- dir: `larajobs-search` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `laravel-artisan` — Laravel Artisan
- dir: `laravel-artisan` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `laravel-cloud` — Laravel Cloud
- dir: `laravel-cloud` · commands: 10 · modes: view
- **Blockers:** declares AI tools[] (15) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `laravel-docs` — Laravel Docs
- dir: `laravel-docs` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `laravel-forge` — Laravel Forge
- dir: `laravel-forge` · commands: 2 · modes: view|menu-bar
- **Blockers:** trash: throws — file trash not wired; unsupported command mode(s): check-deploy-status: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); updateCommandMetadata: loads; no-op (command metadata updates not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `laravel-herd` — Laravel Herd
- dir: `laravel-herd` · commands: 17 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `laravel-tips` — Laravel Tips
- dir: `laravel-tips` · commands: 3 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `laravel-valet` — Laravel Valet
- dir: `laravel-valet` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `lastfm` — Last.fm
- dir: `lastfm` · commands: 7 · modes: menu-bar|view
- **Blockers:** unsupported command mode(s): menubar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `lastpass` — LastPass Credentials Search
- dir: `lastpass` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `later` — Read Later
- dir: `later` · commands: 3 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `latex-board` — LaTeX Board
- dir: `latex-board` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `lattice-scholar-extension` — Lattice Scholar Extension
- dir: `lattice-scholar-extension` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `launch-agents` — Launch Agents
- dir: `launch-agents` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `launchd-monitor` — Launchd Monitor
- dir: `launchd-monitor` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): menubar: mode "menu-bar"; denied Node built-ins in sandbox: fs, child_process
- Degraded: declares background `interval` command(s) — not scheduled

### `launchpad-plus` — Launchpad+
- dir: `launchpad-plus` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `lavinprognoser` — Lavinprognoser
- dir: `lavinprognoser` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored

### `leader-key` — Leader Key
- dir: `leader-key` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `leafcast` — Leafcast
- dir: `leafcast` · commands: 8 · modes: view|no-view
- **Blockers:** declares AI tools[] (7) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored

### `leap-new` — Leap.new
- dir: `leap-new` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"

### `learning-snacks` — Learning Snacks
- dir: `learning-snacks` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired

### `lemniscate-system-monitor` — Lemniscate | System Monitor
- dir: `lemniscate-system-monitor` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `library-genesis` — Library Genesis
- dir: `library-genesis` · commands: 2 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: https

### `life-progress` — Life Progress
- dir: `life-progress` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): life-progress-menubar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `lightshot-gallery` — Lightshot Gallery
- dir: `lightshot-gallery` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

### `linak-desk-controller` — Linak Desk Controller
- dir: `linak-controller` · commands: 4 · modes: no-view|menu-bar
- **Blockers:** unsupported command mode(s): menubar-move: mode "menu-bar"; declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `linak-desk-controller` — Linak Desk Controller
- dir: `linak-desk-controller` · commands: 4 · modes: no-view|menu-bar
- **Blockers:** unsupported command mode(s): menubar-move: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `linear` — Linear
- dir: `linear` · commands: 14 · modes: view|menu-bar|no-view
- **Blockers:** getApplications: throws — application discovery not wired; unsupported command mode(s): unread-notifications: mode "menu-bar"; declares AI tools[] (22) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:useAI (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `lingo-rep-raycast` — Lingorep - Translate, Repeat, Memorize
- dir: `lingo-rep-raycast` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `link-bundles` — Link Bundles
- dir: `link-bundles` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `link-cleaner` — Link Cleaner
- dir: `link-cleaner` · commands: 2 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; getFrontmostApplication: throws — application discovery not wired

### `link-transformer` — Link Transformer
- dir: `link-transformer` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `linkace-search` — LinkAce Search
- dir: `linkace-search` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `linkding` — Linkding
- dir: `linkding` · commands: 3 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

### `linkwarden` — Linkwarden
- dir: `linkwarden` · commands: 2 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `list-randomizer` — List Randomizer
- dir: `list-randomizer` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `litterbox` — Litterbox
- dir: `litterbox` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `localcan` — LocalCan
- dir: `localcan` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `localsend` — LocalSend
- dir: `localsend` · commands: 9 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): localsend-status: mode "menu-bar"; denied Node built-ins in sandbox: fs, dgram, http
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `lock-time` — Lock Time
- dir: `lock-time` · commands: 3 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled
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

### `lucide-icons` — Lucide Icons Search
- dir: `lucide-icons` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired
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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `lunaris` — Lunaris
- dir: `lunaris` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `luxafor-controller` — Luxafor Controller
- dir: `luxafor-controller` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): luxafor-status: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

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

### `macosicons` — macOSIcons.com
- dir: `macosicons` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `macports` — MacPorts
- dir: `macports` · commands: 2 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `magic-ingest` — Magic Ingest
- dir: `magic-ingest` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); updateCommandMetadata: loads; no-op (command metadata updates not wired)

### `mail` — Apple Mail
- dir: `mail` · commands: 11 · modes: no-view|view
- **Blockers:** showInFinder: throws — showInFinder not wired; declares AI tools[] (6) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `mailsy` — Mailsy
- dir: `mailsy` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `mamp-utility` — MAMP Utility
- dir: `mamp-utility` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `man-pages` — Man Pages
- dir: `man-pages` · commands: 3 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `manage-clickup-tasks` — ClickUp - Tasks & Docs Explorer
- dir: `clickup` · commands: 6 · modes: view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `mantine-documentation` — Mantine UI Documentation
- dir: `mantine` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `marginnote` — MarginNote
- dir: `marginnote` · commands: 3 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; getApplications: throws — application discovery not wired

### `markdown-blog` — Markdown Blog Manager
- dir: `markdown-blog-manager` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `markdown-codeblock` — Markdown Codeblock
- dir: `markdown-codeblock` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getSelectedText: throws — selection APIs not wired

### `markdown-docs` — Markdown Documents
- dir: `markdown-docs` · commands: 3 · modes: view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `markdown-image-to-html` — Markdown Image to HTML
- dir: `markdown-image-to-html` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `markdown-navigator` — Markdown Navigator
- dir: `markdown-navigator` · commands: 1 · modes: view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `markdown-slides` — Markdown Slides
- dir: `markdown-slides` · commands: 4 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getDefaultApplication: throws — application discovery not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet
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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `masked-link-generator` — Masked Link Generator
- dir: `masked-link-generator` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:Response (not implemented in Invoke)

### `masscode` — massCode
- dir: `masscode` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired

### `mastodon` — Mastodon
- dir: `mastodon` · commands: 6 · modes: view|menu-bar
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; unsupported command mode(s): menu-bar-notifications: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `mastodon-search` — Mastodon Search
- dir: `mastodon-search` · commands: 1 · modes: view
- Needs review: @raycast/api:useMemo (not in Invoke surface — needs review); @raycast/api:useState (not in Invoke surface — needs review); @raycast/utils:useMemo (not implemented in Invoke)

### `material-icons` — Material Icons
- dir: `material-icons` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `mayar` — Mayar
- dir: `mayar` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): mayar-balance-recent-transaction: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `mcp` — Model Context Protocol
- dir: `mcp` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `media-converter` — Media Converter
- dir: `media-converter` · commands: 4 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process, module
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired); launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `medialister-marketplace-helper` — Medialister Marketplace Helper
- dir: `medialister-marketplace-helper` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; AI: AI.ask throws — Invoke AI not yet wired

### `meduza` — Meduza
- dir: `meduza` · commands: 2 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `meme-generator` — Meme Generator
- dir: `meme-generator` · commands: 2 · modes: view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `memo` — Memo
- dir: `memo` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Needs review: @raycast/api:Page (not in Invoke surface — needs review); @raycast/api:Api (not in Invoke surface — needs review); @raycast/api:OAuthClient (not in Invoke surface — needs review); @raycast/api:RaycastAdapter (not in Invoke surface — needs review); @raycast/api:useEffect (not in Invoke surface — needs review); @raycast/api:useState (not in Invoke surface — needs review); @raycast/api:Saver (not in Invoke surface — needs review)

### `memorable-generate-password` — Memorable Password Generator
- dir: `memorable-generate-password` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `memory` — Memory
- dir: `memory` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (9) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: declares extension-level `ai` instructions — ignored

### `memos` — Memos
- dir: `memos` · commands: 4 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `menubar-calendar` — Menubar Calendar
- dir: `menubar-calendar` · commands: 2 · modes: menu-bar|view
- **Blockers:** unsupported command mode(s): index: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `menubar-weather` — Menubar Weather
- dir: `menubar-weather` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): menubar-weather: mode "menu-bar"
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `mercury` — Mercury
- dir: `mercury` · commands: 2 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (3) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `mermaid-to-image` — Mermaid to Image
- dir: `mermaid-to-image` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: declares extension-level `ai` instructions — ignored

### `messages` — Messages
- dir: `messages` · commands: 5 · modes: view|menu-bar|no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; unsupported command mode(s): unread-messages: mode "menu-bar"; declares AI tools[] (3) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `meta-music` — Meta Music
- dir: `meta-music` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired); declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `metabase` — Metabase
- dir: `metabase` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (4) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

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

### `microsoft-office` — Microsoft Office
- dir: `microsoft-office` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `microsoft-onedrive` — Microsoft OneDrive
- dir: `microsoft-onedrive` · commands: 2 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `microsoft-teams` — Microsoft Teams
- dir: `microsoft-teams` · commands: 3 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `midjourney` — Midjourney
- dir: `midjourney` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `migros` — Migros
- dir: `migros` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: https, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `mindnode` — MindNode
- dir: `mindnode` · commands: 3 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs

### `minimax-tts` — MiniMax TTS
- dir: `minimax-tts` · commands: 10 · modes: no-view|view|menu-bar
- **Blockers:** getSelectedText: throws — selection APIs not wired; unsupported command mode(s): playback-status: mode "menu-bar"; denied Node built-ins in sandbox: fs, child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `minio-manager` — Minio Manager
- dir: `minio-manager` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, http, https
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); declares command `arguments[]` — not passed by runtime yet

### `minttr` — Minttr
- dir: `minttr` · commands: 3 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

### `miraie-ac-control` — MirAIe AC Control
- dir: `miraie-ac-control` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"

### `miro` — Miro
- dir: `miro` · commands: 3 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired)

### `mirror-displays` — Mirror Displays
- dir: `mirror-displays` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `mlb-scores` — MLB Scores
- dir: `mlb-scores` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `mldocs` — MLDocs
- dir: `mldocs` · commands: 8 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

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

### `models-dev` — Models Dev
- dir: `models-dev` · commands: 7 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs, v8
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `modify-hash` — Modify Hash
- dir: `modify-hash` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `mole` — Mole
- dir: `mole` · commands: 10 · modes: view|menu-bar
- **Blockers:** trash: throws — file trash not wired; unsupported command mode(s): health-menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares background `interval` command(s) — not scheduled

### `mollie-for-raycast` — Mollie
- dir: `mollie-for-raycast` · commands: 4 · modes: menu-bar|view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; unsupported command mode(s): transactionsMenuBar: mode "menu-bar"

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
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `monitor-mate` — MonitorMate
- dir: `monitor-mate` · commands: 3 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: net, child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `monorepo-manager` — Manage Monorepo Projects/Workspaces
- dir: `monorepo-manager` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `monzo` — Monzo
- dir: `monzo` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `mood` — Mood Tracker
- dir: `mood` · commands: 3 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `moodist` — Moodist
- dir: `moodist` · commands: 7 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `moon-phrase` — Moon Phrase
- dir: `moon-phrase` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `morning-coffee` — Morning Coffee
- dir: `morning-coffee` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `mound-for-pile` — Mound
- dir: `mound-for-pile` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `mouse-jiggle` — Mouse Jiggle
- dir: `mouse-jiggle` · commands: 2 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `mozeidon` — Mozeidon
- dir: `mozeidon` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: readline, child_process

### `mozilla-firefox` — Mozilla Firefox
- dir: `mozilla-firefox` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `mozilla-vpn` — Mozilla VPN Connect
- dir: `mozilla-vpn` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs, https, http
- Needs review: namespace import of @raycast/api (member usage unverified)

### `mullvad` — Mullvad VPN
- dir: `mullvad` · commands: 5 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `multi-force` — MultiForce
- dir: `multi-force` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `multi-links` — Open Multiple Links
- dir: `multi-links` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `multilinks` — Multilinks
- dir: `multilinks` · commands: 3 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `music` — Music
- dir: `music` · commands: 26 · modes: no-view|view|menu-bar
- **Blockers:** unsupported command mode(s): currently-playing-menu-bar: mode "menu-bar"; declares AI tools[] (21) — AI extensions not supported; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; updateCommandMetadata: loads; no-op (command metadata updates not wired); declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:ArgumentsLaunchProps (not in Invoke surface — needs review)

### `music-assistant-controls` — Music Assistant Controls
- dir: `music-assistant-controls` · commands: 12 · modes: menu-bar|no-view|view
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `music-link-converter` — Music Link Converter
- dir: `music-link-converter` · commands: 2 · modes: view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `music-recognition` — Music Recognition
- dir: `music-recognition` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `mute-microphone` — Toggle Audio Input (Microphone)
- dir: `mute-microphone` · commands: 3 · modes: menu-bar|no-view
- **Blockers:** unsupported command mode(s): mute-menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `my-daily-log` — My Daily Log
- dir: `my-daily-log` · commands: 6 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `myanimelist-search` — Myanimelist Search
- dir: `myanimelist-search` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `myip` — MyIP
- dir: `myip` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menubar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `n8n` — n8n
- dir: `n8n` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `name-com` — Name.com
- dir: `name-com` · commands: 2 · modes: no-view|view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `namespaces` — NameSpaces
- dir: `namespaces` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `napkin` — Napkin
- dir: `napkin` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `naver-search` — Naver Search
- dir: `naver-search` · commands: 6 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `nerd-font-picker` — Nerd Font Picker
- dir: `nerd-font-picker` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `netbird` — NetBird
- dir: `netbird` · commands: 7 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `netlify` — Netlify
- dir: `netlify` · commands: 7 · modes: view
- **Blockers:** getDefaultApplication: throws — application discovery not wired; declares AI tools[] (7) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `network-diagnostics` — Network Diagnostics
- dir: `network-diagnostics` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: dns

### `network-drive` — Network Drive
- dir: `network-drive` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `network-menubar-monitor` — Network Menubar Monitor
- dir: `network-menubar-monitor` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): index: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: declares background `interval` command(s) — not scheduled

### `network-proxy` — Network Proxy
- dir: `network-proxy` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `network-speed` — Network Speed
- dir: `network-speed` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `next-up` — Next Up
- dir: `next-up` · commands: 5 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired)

### `nextjs-docs` — Next.js Documentation
- dir: `nextjs-docs` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `night-light` — Night Light
- dir: `night-light` · commands: 4 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `nightscout` — Nightscout
- dir: `nightscout` · commands: 6 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): glucoseMenuBar: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `nippon-colors` — Nippon Colors
- dir: `nippon-colors` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `nix-flake-templates` — Nix Flake Templates
- dir: `nix-flake-templates` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process

### `no-more-caffeine` — No More Caffeine
- dir: `no-more-caffeine` · commands: 4 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `nocal` — nocal
- dir: `nocal` · commands: 4 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `node-release-notes` — Node Release Notes
- dir: `node-release-notes` · commands: 1 · modes: view
- Needs review: @raycast/utils:AsyncState (not implemented in Invoke)

### `node-version-manager` — Node Version Manager
- dir: `node-version-manager` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `not-diamond` — Not Diamond
- dir: `not-diamond` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `note-in-google-doc` — Notes in Google Docs
- dir: `note-in-google-doc` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `noteman` — Noteman
- dir: `noteman` · commands: 4 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; trash: throws — file trash not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `noteplan-3` — NotePlan 3
- dir: `noteplan-3` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `notion` — Notion
- dir: `notion` · commands: 4 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; AI: AI.ask throws — Invoke AI not yet wired; OAuth: OAuth.PKCEClient throws — OAuth not yet wired; declares AI tools[] (6) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `notion-url-to-id` — Notion URL to ID
- dir: `notion-url-to-id` · commands: 2 · modes: no-view|view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `notis` — Ask Notis
- dir: `notis` · commands: 3 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar-command: mode "menu-bar"; denied Node built-ins in sandbox: fs, child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

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
- Degraded: declares background `interval` command(s) — not scheduled

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

### `nusmods` — NUSMods
- dir: `nusmods` · commands: 1 · modes: view
- Needs review: @raycast/utils:useStreamJSON (not implemented in Invoke)

### `nuxt` — Nuxt
- dir: `nuxt` · commands: 6 · modes: no-view|view|menu-bar
- **Blockers:** getSelectedText: throws — selection APIs not wired; unsupported command mode(s): nuxt-dev-server: mode "menu-bar"; declares AI tools[] (8) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `oblique-strategies` — Oblique Strategies
- dir: `oblique-strategies` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `obs-clippings` — Obsidian Clippings
- dir: `obs-clippings` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: fs

### `obs-control` — OBS Control
- dir: `obs-control` · commands: 8 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired

### `obsidian` — Obsidian
- dir: `obsidian` · commands: 12 · modes: view|menu-bar
- **Blockers:** getSelectedText: throws — selection APIs not wired; getDefaultApplication: throws — application discovery not wired; unsupported command mode(s): obsidianMenuBar: mode "menu-bar"; declares AI tools[] (7) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `obsidian-bookmarks` — Obsidian Bookmarks
- dir: `obsidian-bookmarks` · commands: 3 · modes: view|no-view
- **Blockers:** trash: throws — file trash not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)
- Needs review: @raycast/api:FileIcon (not in Invoke surface — needs review)

### `obsidian-link-opener` — Obsidian Link Opener
- dir: `obsidian-link-opener` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)
- Needs review: namespace import of @raycast/api (member usage unverified)

### `obsidian-smart-capture` — Obsidian Smart Capture
- dir: `obsidian-smart-capture` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `obsidian-tasks` — Obsidian Tasks
- dir: `obsidian-tasks` · commands: 5 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menubar-item: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired)

### `oci` — Oracle Cloud
- dir: `oci` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `odesli` — Odesli
- dir: `odesli` · commands: 2 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `office2pdf` — Office2PDF
- dir: `office2pdf` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, https
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `ok-json` — OK JSON
- dir: `ok-json` · commands: 7 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired; showInFinder: throws — showInFinder not wired; getApplications: throws — application discovery not wired

### `okta-app-manager` — Okta Manager
- dir: `okta-app-manager` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `one-thing` — One Thing
- dir: `one-thing` · commands: 3 · modes: menu-bar|view|no-view
- **Blockers:** unsupported command mode(s): show-one-thing: mode "menu-bar"; declares AI tools[] (2) — AI extensions not supported
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `one-time-password` — One Time Password
- dir: `one-time-password` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; runPowerShellScript: Windows-only; throws on macOS (import loads)

### `one-time-secret` — One-Time Secret
- dir: `one-time-secret` · commands: 3 · modes: view|no-view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored

### `onenote` — OneNote
- dir: `onenote` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

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

### `open-in-android-studio` — Open in Android Studio
- dir: `open-in-android-studio` · commands: 3 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `open-in-cursor` — Open in Cursor
- dir: `open-in-cursor` · commands: 1 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `open-in-shopify-admin` — Open in Shopify Admin
- dir: `open-in-shopify-admin` · commands: 1 · modes: no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

### `open-in-sublime-text` — Open in Sublime Text
- dir: `open-in-sublime-text` · commands: 2 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `open-in-textmate` — Open in TextMate
- dir: `open-in-textmate` · commands: 1 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `open-in-trae` — Open in Trae
- dir: `open-in-trae` · commands: 1 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `open-in-visual-studio-code` — Open in Visual Studio Code
- dir: `open-in-visual-studio-code` · commands: 1 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); runPowerShellScript: Windows-only; throws on macOS (import loads)

### `open-laravel-herd-site` — Open Laravel Herd Site
- dir: `open-laravel-herd-site` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `open-link-in-specific-browser` — Open Link in Specific Browser
- dir: `open-link-in-specific-browser` · commands: 3 · modes: view|menu-bar|no-view
- **Blockers:** getApplications: throws — application discovery not wired; getDefaultApplication: throws — application discovery not wired; getSelectedText: throws — selection APIs not wired; getFrontmostApplication: throws — application discovery not wired; unsupported command mode(s): open-link-from-menubar: mode "menu-bar"; denied Node built-ins in sandbox: net

### `open-path` — Open Path
- dir: `open-path` · commands: 1 · modes: no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getSelectedText: throws — selection APIs not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares command `arguments[]` — not passed by runtime yet

### `open-with-app` — Open With App
- dir: `open-with-app` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getApplications: throws — application discovery not wired
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `openai-gpt` — OpenAI GPT
- dir: `openai-gpt` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `openai-speak` — OpenAI Speak
- dir: `openai-speak` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs, child_process

### `openai-translator` — OpenAI Translator
- dir: `openai-translator` · commands: 8 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); updateCommandMetadata: loads; no-op (command metadata updates not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `openclaw` — OpenClaw
- dir: `openclaw` · commands: 6 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `opencode-sessions` — OpenCode Sessions
- dir: `opencode-sessions` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `openfortivpn` — Openfortivpn
- dir: `openfortivpn` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `openhue` — OpenHue
- dir: `openhue` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: https, fs

### `openrouter-models-finder` — OpenRouter Models Finder
- dir: `openrouter-models-finder` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

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
- **Blockers:** declares AI tools[] (7) — AI extensions not supported
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `otp-auth` — OTP Auth
- dir: `otp-auth` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `otp-inbox` — OTP Inbox
- dir: `otp-inbox` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired
- Needs review: @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke)

### `otter` — Otter Bookmarks
- dir: `otter` · commands: 4 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menubar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:useCachedPromise (not in Invoke surface — needs review); @raycast/utils:List (not implemented in Invoke); @raycast/utils:ActionPanel (not implemented in Invoke); @raycast/utils:Action (not implemented in Invoke); @raycast/utils:Icon (not implemented in Invoke); @raycast/utils:Detail (not implemented in Invoke); @raycast/utils:getPreferenceValues (not implemented in Invoke); @raycast/utils:Image (not implemented in Invoke); @raycast/utils:MenuBarExtra (not implemented in Invoke); @raycast/utils:open (not implemented in Invoke); @raycast/utils:Keyboard (not implemented in Invoke); @raycast/utils:openExtensionPreferences (not implemented in Invoke); @raycast/utils:useFetchRecentItems (not implemented in Invoke)

### `ottomatic` — Ottomatic
- dir: `ottomatic` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `oura` — Oura
- dir: `oura` · commands: 9 · modes: view|no-view|menu-bar
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `outline-page` — Outline Page
- dir: `outline-page` · commands: 1 · modes: no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

### `owl` — Owl
- dir: `owl` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `oxford-collocation-dictionary` — Oxford Collocation Dictionary
- dir: `oxford-collocation-dictionary` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `palette-picker` — Color Palette Picker
- dir: `palette-picker` · commands: 2 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `pangu-for-raycast` — Pangu for Raycast
- dir: `pangu-for-raycast` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `paper` — Paper
- dir: `paper` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

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

### `papra` — Papra
- dir: `papra` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `parallels-virtual-machines` — Parallels Virtual Machines
- dir: `parallels-virtual-machines` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `parcel` — Parcel
- dir: `parcel` · commands: 2 · modes: view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored

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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `password-strength` — Password Strength
- dir: `password-strength` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `paste-safely` — Paste Safely
- dir: `paste-safely` · commands: 2 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `paste-to-markdown` — Paste to Markdown
- dir: `paste-to-markdown` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `paynow` — Paynow.gg
- dir: `paynow` · commands: 5 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:CachedPromiseOptions (not implemented in Invoke); @raycast/utils:PaginationOptions (not implemented in Invoke)

### `paystack` — Paystack
- dir: `paystack` · commands: 8 · modes: view
- Needs review: @raycast/utils:showToast (not implemented in Invoke); @raycast/utils:Toast (not implemented in Invoke); @raycast/utils:List (not implemented in Invoke); @raycast/utils:ActionPanel (not implemented in Invoke); @raycast/utils:Action (not implemented in Invoke); @raycast/utils:openExtensionPreferences (not implemented in Invoke); @raycast/utils:Icon (not implemented in Invoke); @raycast/utils:Form (not implemented in Invoke); @raycast/utils:Clipboard (not implemented in Invoke); @raycast/utils:confirmAlert (not implemented in Invoke); @raycast/utils:Alert (not implemented in Invoke)

### `pcloud` — pCloud
- dir: `pcloud` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Needs review: @raycast/utils:Response (not implemented in Invoke)

### `pdf-compression` — PDF Compression
- dir: `pdf-compression` · commands: 1 · modes: no-view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `pdfsearch` — PDFSearch
- dir: `pdfsearch` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `petal` — Petal - Offline Voice to Text
- dir: `petal` · commands: 5 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process

### `pexels` — Pexels
- dir: `pexels` · commands: 4 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired

### `phonenumber-in-im` — Fast Chat With Phone Number in IM Apps
- dir: `phonenumber-in-im` · commands: 2 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `photoroom-image-editing` — Photoroom Image Editing
- dir: `photoroom-image-editing` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `php-monitor` — PHP Monitor
- dir: `phpmon` · commands: 11 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `pi-drill` — Pi Drill
- dir: `pi-drill` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `pia-controls` — Private Internet Access Controls
- dir: `pia-controls` · commands: 4 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process

### `picgo` — PicGo
- dir: `picgo` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `pick-your-wallpaper` — Pick Your Wallpaper
- dir: `pick-your-wallpaper` · commands: 2 · modes: view|no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `pie-for-pi-hole` — Pie for Pi-Hole
- dir: `pie-for-pihole` · commands: 16 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: http, https, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `pieces-raycast` — Pieces for Raycast
- dir: `pieces-raycast` · commands: 9 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); BrowserExtension: loads; throws if called (browser bridge not wired); getSelectedFinderItems: loads; throws if called (Finder selection not wired)
- Needs review: @raycast/api:Preferences (not in Invoke surface — needs review)

### `pika` — Pika
- dir: `pika` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `pin` — Pin
- dir: `pin-raycast` · commands: 5 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: fs

### `pinata` — Pinata
- dir: `pinata` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

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
- **Blockers:** getApplications: throws — application discovery not wired; getSelectedText: throws — selection APIs not wired; getFrontmostApplication: throws — application discovery not wired; AI: AI.ask throws — Invoke AI not yet wired; unsupported command mode(s): index: mode "menu-bar"; denied Node built-ins in sandbox: fs, vm, child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `pinwork` — Pinwork
- dir: `pinwork` · commands: 6 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired

### `pip` — PiP
- dir: `pip` · commands: 2 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; getDefaultApplication: throws — application discovery not wired; getFrontmostApplication: throws — application discovery not wired

### `pipe-commands` — Pipe Commands
- dir: `pipe-commands` · commands: 4 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `pipedrive` — Pipedrive Search
- dir: `pipedrive` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `pitchcast` — Pitchcast - Pitchfork Reviews Search
- dir: `pitchcast` · commands: 1 · modes: view
- Needs review: @raycast/utils:Response (not implemented in Invoke)

### `pivot` — Pivot
- dir: `pivot` · commands: 3 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `pixabay` — Pixabay
- dir: `pixabay` · commands: 2 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `placeholder` — Placeholder
- dir: `placeholder` · commands: 2 · modes: view|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `plane` — Plane
- dir: `plane` · commands: 3 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:PaginationOptions (not implemented in Invoke)

### `planetscale` — PlanetScale
- dir: `planetscale` · commands: 5 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `planwell` — PlanWell
- dir: `planwell` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `playnite-launcher` — Playnite Launcher
- dir: `playnite-launcher` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `plexamp` — Plexamp
- dir: `plexamp` · commands: 8 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): now-playing-menubar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `plexus` — Plexus - Localhost Search
- dir: `plexus` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, net, fs

### `podcasts-now` — Podcasts Now
- dir: `podcasts-now` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): podcasts-menubar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:Navigation (not in Invoke surface — needs review)

### `polar` — Polar
- dir: `polar` · commands: 3 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `polidict` — Polidict
- dir: `polidict` · commands: 6 · modes: view|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `pomo` — Pomo
- dir: `pomo` · commands: 8 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired

### `pomodoro` — Pomodoro
- dir: `pomodoro` · commands: 5 · modes: menu-bar|view
- **Blockers:** unsupported command mode(s): pomodoro-menu-bar: mode "menu-bar", slack-pomodoro-menu-bar: mode "menu-bar"; declares AI tools[] (4) — AI extensions not supported; denied Node built-ins in sandbox: child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `popcorn` — Popcorn - Explore Stremio Streams
- dir: `popcorn` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `popicons` — Popicons
- dir: `popicons` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: dns, fs

### `port-manager` — Port Manager
- dir: `port-manager` · commands: 4 · modes: no-view|view|menu-bar
- **Blockers:** unsupported command mode(s): open-ports-menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `portfolio-tracker` — Portfolio Tracker
- dir: `portfolio-tracker` · commands: 3 · modes: view
- **Blockers:** declares AI tools[] (6) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; updateCommandMetadata: loads; no-op (command metadata updates not wired); declares extension-level `ai` instructions — ignored

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
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `postey` — Postey
- dir: `postey` · commands: 5 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (4) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `power-management` — Power Management
- dir: `power-management` · commands: 5 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): lowpower-menubar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `printer-status` — Printer Status
- dir: `printer-status` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored

### `prism-launcher` — Prism Launcher
- dir: `prism-launcher` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `pritunl` — Connect Pritunl Vpn Tunnel
- dir: `pritunl` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `privatebin` — PrivateBin
- dir: `privatebin` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `privileges` — Privileges
- dir: `privileges` · commands: 3 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process

### `producthunt` — Product Hunt
- dir: `producthunt` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `productlane` — Productlane
- dir: `productlane` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `project-code-to-text` — Project Code to Text
- dir: `project-code-to-text` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)
- Needs review: @raycast/api:// Keep LaunchProps
  Clipboard (not in Invoke surface — needs review)

### `projects` — Projects
- dir: `projects` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `prompt-builder` — Prompt Builder
- dir: `prompt-builder` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `prompt-stash` — Prompt Stash
- dir: `prompt-stash` · commands: 3 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `promptlab` — PromptLab
- dir: `promptlab` · commands: 7 · modes: view|menu-bar
- **Blockers:** showInFinder: throws — showInFinder not wired; AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired; unsupported command mode(s): menubar-item: mode "menu-bar"; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `promptnote` — PromptNote
- dir: `promptnote` · commands: 6 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `pronounce-the-word` — Pronounce the Word
- dir: `pronounce-the-word` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `proton-authenticator` — Proton Authenticator
- dir: `proton-authenticator` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `proton-mail` — Proton Mail
- dir: `proton-mail` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `proton-pass` — Proton Pass
- dir: `proton-pass` · commands: 5 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `proxyman` — Proxyman
- dir: `proxyman` · commands: 13 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired

### `prusa` — Prusa Printer Control
- dir: `prusa` · commands: 4 · modes: view|menu-bar|no-view
- **Blockers:** unsupported command mode(s): printer-progress: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `punto` — Punto Switcher
- dir: `punto` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `putio` — put.io
- dir: `putio` · commands: 5 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `python` — Python
- dir: `python` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `qalc` — Qalccast
- dir: `qalc` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `qbitorrent` — qBittorrent
- dir: `qbittorrent` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); launchCommand: loads; throws if called (inter-command launch not wired)

### `qmd` — QMD
- dir: `qmd` · commands: 13 · modes: view|no-view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired)

### `qoder` — Qoder
- dir: `qoder` · commands: 5 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `qq-mail` — QQ Mail
- dir: `qq-mail` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `qr-code-scanner` — QR Code Scanner
- dir: `qr-code-scanner` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `qrcode-generator` — QR Code Generator
- dir: `qrcode-generator` · commands: 3 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs

### `qrcp` — QRCP
- dir: `qrcp` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: http, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `quarantine-manager` — Quarantine Manager
- dir: `quarantine-manager` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `quick-access` — Quick Access
- dir: `quick-access` · commands: 3 · modes: view|menu-bar
- **Blockers:** showInFinder: throws — showInFinder not wired; getFrontmostApplication: throws — application discovery not wired; unsupported command mode(s): search-pins-menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `quick-call` — Quick Phone Call
- dir: `quick-call` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `quick-git` — Quick Git
- dir: `quick-git` · commands: 2 · modes: view
- **Blockers:** getDefaultApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `quick-open-project` — Quick Open Project
- dir: `quick-open-project` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `quick-quit` — Quick Quit
- dir: `quick-quit` · commands: 4 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `quip` — Quip
- dir: `quip` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `quit-applications` — Quit Applications
- dir: `quit-applications` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `qutebrowser-tabs` — Qutebrowser Tabs
- dir: `qutebrowser-tabs` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `r2-uploader` — Cloudflare R2 File Uploader
- dir: `r2-uploader` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `rabbit-hole` — Rabbit Hole
- dir: `rabbit-hole` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs, https
- Degraded: declares background `interval` command(s) — not scheduled

### `radix` — Radix
- dir: `radix` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `raindrop-io` — Raindrop.io
- dir: `raindrop-io` · commands: 5 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; declares AI tools[] (4) — AI extensions not supported
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `ram-prices` — RAM Prices
- dir: `ram-prices` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): market-trends-menu-bar: mode "menu-bar"

### `random-color` — Random Color
- dir: `random-color` · commands: 2 · modes: no-view|view
- Needs review: @raycast/api:randomColor (not in Invoke surface — needs review)

### `random-fart` — Random Fart
- dir: `random-fart` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `random-text-picker` — Random Text Picker
- dir: `random-text-picker` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

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

### `ray-code` — Ray Code
- dir: `ray-code` · commands: 1 · modes: view
- **Blockers:** trash: throws — file trash not wired; declares AI tools[] (9) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process

### `ray-so` — ray.so
- dir: `ray-so` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `raycast-ai-custom-providers` — Raycast AI Custom Providers
- dir: `raycast-ai-custom-providers` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `raycast-airtable-extension` — Airtable
- dir: `airtable` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `raycast-bard-ai` — Google Bard
- dir: `raycast-bard-ai` · commands: 11 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `raycast-explorer` — Raycast Explorer
- dir: `raycast-explorer` · commands: 5 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; AI: AI.ask throws — Invoke AI not yet wired

### `raycast-focus-stats` — Raycast Focus Stats
- dir: `raycast-focus-stats` · commands: 3 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs, https
- Degraded: declares background `interval` command(s) — not scheduled

### `raycast-gemini` — Google Gemini
- dir: `raycast-gemini` · commands: 16 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

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

### `raycast-language-tool` — Language Tool - Spell & Grammar Checker
- dir: `language-tool` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `raycast-link-lock` — Link Lock - Password Locked Links
- dir: `raycast-link-lock` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `raycast-monkeytype-theme` — Raycast MonkeyType Theme Explorer
- dir: `raycast-monkeytype-theme` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired

### `raycast-motion-preview` — Motion Preview
- dir: `raycast-motion-preview` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `raycast-new-instance` — New Instance
- dir: `raycast-new-instance` · commands: 2 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process

### `raycast-ollama` — Ollama AI
- dir: `raycast-ollama` · commands: 21 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); getSelectedFinderItems: loads; throws if called (Finder selection not wired); BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `raycast-port` — Raycast Port
- dir: `raycast-port` · commands: 3 · modes: no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: child_process
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)
- Needs review: @raycast/api:WindowManagement (not in Invoke surface — needs review)

### `raycast-rsync-extension` — Rsync File Transfer
- dir: `raycast-rsync-extension` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `raycast-store-updates` — Raycast Store Updates
- dir: `raycast-store-updates` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `raycast-surge` — Surge
- dir: `surge` · commands: 5 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: https

### `raycast-svg64` — SVG64 - Convert SVGs to Base64 Strings
- dir: `raycast-svg64` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `raycast-svgo` — SVGO
- dir: `svgo` · commands: 3 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `raycast-system-monitor` — System Monitor
- dir: `system-monitor` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menubar-system-monitor: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: declares background `interval` command(s) — not scheduled

### `raycast-tapo-smart-devices` — Tapo Smart Devices
- dir: `tapo-smart-devices` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"

### `raycast-transistorfm` — TransistorFM
- dir: `raycast-transistorfm` · commands: 4 · modes: menu-bar|view
- **Blockers:** unsupported command mode(s): menu: mode "menu-bar"

### `raycast-wallpaper` — Raycast Wallpaper
- dir: `raycast-wallpaper` · commands: 2 · modes: view|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; runPowerShellScript: Windows-only; throws on macOS (import loads); declares background `interval` command(s) — not scheduled

### `raycast-zoxide` — Zoxide
- dir: `raycast-zoxide` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `raycaster` — Raycaster
- dir: `raycaster` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `raydocs` — Raycast API Documentation
- dir: `raydocs` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported

### `raydoom` — RayDoom
- dir: `raydoom` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `raylog-markdown-tasks` — Raylog - Markdown Tasks
- dir: `raylog-markdown-tasks` · commands: 3 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar-task: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `raynab` — Raynab — Manage Your Budgets
- dir: `raynab` · commands: 7 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): unreviewed: mode "menu-bar"; declares AI tools[] (6) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

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
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `react-devtools` — React DevTools
- dir: `react-devtools` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `react-docs` — React Documentation
- dir: `react-docs` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `react-icons` — React Icons
- dir: `react-icons` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `read-ai` — Read AI - Text to Speech
- dir: `read-ai` · commands: 3 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs, child_process

### `readeck` — Readeck
- dir: `readeck` · commands: 2 · modes: view
- Needs review: @raycast/utils:Action (not implemented in Invoke); @raycast/utils:ActionPanel (not implemented in Invoke); @raycast/utils:Icon (not implemented in Invoke); @raycast/utils:Form (not implemented in Invoke); @raycast/utils:showToast (not implemented in Invoke); @raycast/utils:Toast (not implemented in Invoke); @raycast/utils:getPreferenceValues (not implemented in Invoke); @raycast/utils:List (not implemented in Invoke)

### `reader-mode` — Reader Mode
- dir: `reader-mode` · commands: 3 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `readwise-reader` — Readwise Reader
- dir: `readwise-reader` · commands: 11 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

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
- **Blockers:** denied Node built-ins in sandbox: fs, child_process, https
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `recent-excel` — Recent Excel - Show Recent Excel Files
- dir: `recent-excel` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `recents` — Recents
- dir: `recents` · commands: 5 · modes: view
- **Blockers:** trash: throws — file trash not wired

### `reclaim-ai` — Reclaim
- dir: `reclaim-ai` · commands: 6 · modes: menu-bar|view
- **Blockers:** unsupported command mode(s): notifications: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `rectangle` — Rectangle
- dir: `rectangle` · commands: 42 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs

### `rednote-viewer` — RedNote Viewer
- dir: `rednote-viewer` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `reflect` — Reflect
- dir: `reflect` · commands: 6 · modes: view|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; getApplications: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `refresh-browsers` — Refresh Browsers
- dir: `refresh-browsers` · commands: 1 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; getFrontmostApplication: throws — application discovery not wired

### `regex-batch-renamer` — Regex Batch Renamer
- dir: `regex-batch-renamer` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `relagit` — RelaGit
- dir: `relagit` · commands: 2 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs

### `remember-the-date` — Remember the Date
- dir: `remember-the-date` · commands: 4 · modes: view|menu-bar|no-view
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"; declares AI tools[] (4) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); updateCommandMetadata: loads; no-op (command metadata updates not wired); declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled

### `remember-this` — Remember This
- dir: `remember-this` · commands: 3 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:ListItem (not in Invoke surface — needs review)

### `remix-icon` — Remix Icon
- dir: `remix-icon` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `remo-notes` — Remo
- dir: `remo-notes` · commands: 8 · modes: no-view|menu-bar|view
- **Blockers:** unsupported command mode(s): pinned-notes: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `remote-desktop` — Remote Desktop
- dir: `remote-desktop` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `remove-background` — Remove Background
- dir: `remove-background` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `remove-background---replicate-api` — Remove Background
- dir: `remove-background---replicate-api` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `remove-background-powered-by-mac` — Remove Background - Powered by Mac
- dir: `remove-background-powered-by-mac` · commands: 1 · modes: no-view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `remove-paywall` — Remove Paywall
- dir: `remove-paywall` · commands: 3 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `rename-images-with-ai` — Rename Images with AI
- dir: `rename-images-with-ai` · commands: 2 · modes: view|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `renaming` — Renaming
- dir: `renaming` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `replicate` — Replicate
- dir: `replicate` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `repo-launcher` — Repo Launcher
- dir: `repo-launcher` · commands: 2 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `repository-manager` — Repository Manager
- dir: `repository-manager` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:useMemo (not in Invoke surface — needs review); @raycast/api:useCallback (not in Invoke surface — needs review); @raycast/api:useEffect (not in Invoke surface — needs review); @raycast/api:useRef (not in Invoke surface — needs review); @raycast/api:useState (not in Invoke surface — needs review); @raycast/api:existsSync (not in Invoke surface — needs review); @raycast/api:readFileSync (not in Invoke surface — needs review); @raycast/utils:Action (not implemented in Invoke); @raycast/utils:ActionPanel (not implemented in Invoke); @raycast/utils:AI (not implemented in Invoke); @raycast/utils:Detail (not implemented in Invoke); @raycast/utils:Icon (not implemented in Invoke); @raycast/utils:environment (not implemented in Invoke); @raycast/utils:useNavigation (not implemented in Invoke); @raycast/utils:Color (not implemented in Invoke); @raycast/utils:Image (not implemented in Invoke); @raycast/utils:List (not implemented in Invoke); @raycast/utils:Clipboard (not implemented in Invoke); @raycast/utils:Toast (not implemented in Invoke); @raycast/utils:showToast (not implemented in Invoke); @raycast/utils:confirmAlert (not implemented in Invoke); @raycast/utils:useEffect (not implemented in Invoke); @raycast/utils:useMemo (not implemented in Invoke); @raycast/utils:useRef (not implemented in Invoke); @raycast/utils:useState (not implemented in Invoke)

### `research` — Deep Research
- dir: `deep-research` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: declares extension-level `ai` instructions — ignored

### `resend` — Resend
- dir: `resend` · commands: 4 · modes: view
- **Blockers:** declares AI tools[] (12) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `resend-wallpaper` — Resend Wallpaper
- dir: `resend-wallpaper` · commands: 2 · modes: view|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `respace` — Respace
- dir: `respace` · commands: 3 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `restart-system-processes` — Restart System Processes
- dir: `restart-system-processes` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `restore-photos` — Restore Photos
- dir: `restore-photo` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `retrac` — Retrac
- dir: `retrac` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `retrace` — Retrace Quick Actions
- dir: `retrace` · commands: 3 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `rhttp` — rhttp
- dir: `rhttp` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, https
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `roblox` — Roblox
- dir: `roblox` · commands: 9 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): favourite-game-players: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `roblox-games` — Roblox
- dir: `roblox-games` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `rss-reader` — RSS Reader
- dir: `rss-reader` · commands: 3 · modes: view
- **Blockers:** declares AI tools[] (7) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; BrowserExtension: loads; throws if called (browser bridge not wired); declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `rsync-commands` — Rsync Commands
- dir: `rsync-commands` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:FC (not in Invoke surface — needs review); @raycast/api:useCallback (not in Invoke surface — needs review); @raycast/api:memo (not in Invoke surface — needs review); @raycast/api:useState (not in Invoke surface — needs review); @raycast/api:useEffect (not in Invoke surface — needs review)

### `ruby-evaluate` — Ruby Evaluate
- dir: `ruby-evaluate` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `running-page` — Running Page
- dir: `running-page` · commands: 3 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menubar-totals: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `safari` — Safari
- dir: `safari` · commands: 8 · modes: view|no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (9) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares extension-level `ai` instructions — ignored

### `salesforce` — Salesforce Search
- dir: `salesforce-search` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: fs

### `sap-logon` — SAP GUI Connector
- dir: `sap-logon` · commands: 4 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `saucenao` — SauceNAO - Reverse Image Search
- dir: `saucenao` · commands: 3 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); declares command `arguments[]` — not passed by runtime yet

### `save-clipboard` — Save Clipboard
- dir: `save-clipboard` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `save-link` — Save Link
- dir: `save-link` · commands: 3 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `say` — Say - Text to Speech
- dir: `say` · commands: 5 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `say-no-to-notch` — Say No to Notch
- dir: `say-no-to-notch` · commands: 3 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired

### `scira` — Scira
- dir: `scira` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `scoop` — Scoop
- dir: `scoop` · commands: 5 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

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

### `screenshot` — Screenshot
- dir: `screenshot` · commands: 8 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `script-commands` — Script Commands Store – Find and manage your Raycast Script Commands
- dir: `script-commands` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Needs review: @raycast/api:OpenWithAction (not in Invoke surface — needs review); @raycast/api:ImageLike (not in Invoke surface — needs review); @raycast/api:KeyboardShortcut (not in Invoke surface — needs review)

### `script-kit` — Run Script Kit Command
- dir: `script-kit` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `scrycast` — Scrycast
- dir: `scrycast` · commands: 5 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `scss-compile` — SCSS Compile
- dir: `scss-compile` · commands: 2 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `sdotee` — S.EE
- dir: `sdotee` · commands: 5 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `search-hookmark` — Hookmark Search
- dir: `search-hookmark` · commands: 4 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs

### `search-joplin-notes` — Search Joplin Notes
- dir: `search-joplin-notes` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired

### `search-notion` — Notion Page Search
- dir: `search-notion` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired

### `search-private-npm-packages` — Private npm Packages Search
- dir: `search-private-npm-packages` · commands: 2 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

### `search-router` — Search Router
- dir: `search-router` · commands: 3 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `searchcaster` — Searchcaster
- dir: `searchcaster` · commands: 2 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired

### `secret-browser-commands` — Secret Browser Commands
- dir: `secret-browser-commands` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review); @raycast/utils:withAccessToken (not implemented in Invoke)

### `send-to-e-reader` — Send to E-Reader
- dir: `send-to-e-reader` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `send-to-flomo` — Send to flomo
- dir: `send-to-flomo` · commands: 1 · modes: view
- Needs review: @raycast/api:FormValue (not in Invoke surface — needs review)

### `send-to-kindle` — Send to Kindle
- dir: `send-to-kindle` · commands: 6 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: net, tls, fs, child_process
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired)

### `sendme` — Sendme File Share
- dir: `sendme` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `sensible` — Sensible - Document Data Extraction
- dir: `sensible` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `seo-lighthouse` — SEO Lighthouse
- dir: `seo-lighthouse` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `sequel-ace` — Sequel Ace
- dir: `sequel-ace` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `serialcast` — SerialCast
- dir: `serialcast` · commands: 3 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired

### `series-rating-graphs` — Series Rating Graphs
- dir: `series-rating-graphs` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `servicenow` — ServiceNow
- dir: `servicenow` · commands: 15 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `sesh` — Sesh
- dir: `sesh` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `session` — Session - Pomodoro Focus Timer
- dir: `session` · commands: 7 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired

### `setapp` — Setapp
- dir: `setapp` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `setlist-fm` — setlist.fm
- dir: `setlist-fm` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported

### `seventv-search` — 7TV Emotes Search
- dir: `seventv-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `sf-symbols-search` — SF Symbols Search
- dir: `sf-symbols-search` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `shape-calendar` — Shape Calendar
- dir: `shape-calendar` · commands: 3 · modes: view|no-view
- **Blockers:** declares AI tools[] (10) — AI extensions not supported
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `share-a-quote` — Share a Quote
- dir: `share-a-quote` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `sharex` — ShareX
- dir: `sharex` · commands: 9 · modes: view|no-view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

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

### `shiftplus` — ShiftPlus
- dir: `shiftplus` · commands: 3 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `shiori-sh` — Shiori
- dir: `shiori-sh` · commands: 4 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `shopify-polaris-docs` — Shopify Polaris Docs
- dir: `shopify-polaris-docs` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `shopinfo-app` — Shopinfo.app
- dir: `shopinfo-app` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

### `short-io` — Short.io
- dir: `short-io` · commands: 4 · modes: view|menu-bar
- **Blockers:** getSelectedText: throws — selection APIs not wired; unsupported command mode(s): search-links-menu-bar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `shortcuts-search` — Shortcuts Search
- dir: `shortcuts-search` · commands: 4 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: child_process

### `shottr` — Shottr
- dir: `shottr` · commands: 14 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `shutdown-timer` — Shutdown Timer
- dir: `shutdown-timer` · commands: 3 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `sidecar` — Sidecar
- dir: `sidecar` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `silent-mention` — Silent Mention
- dir: `silent-mention` · commands: 2 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `silent-mode` — Silent Mode
- dir: `silent-mode` · commands: 4 · modes: no-view|menu-bar
- **Blockers:** unsupported command mode(s): silent-mode-menu-bar: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `simon` — Simon
- dir: `simon` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `simple-http` — Simple Http
- dir: `simple-http` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); launchCommand: loads; throws if called (inter-command launch not wired)

### `simple-icons` — Brand Icons - simpleicons.org
- dir: `simple-icons` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: fs
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `simple-reminder` — Simple Reminder
- dir: `simple-reminder` · commands: 3 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): reminderMenuBar: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

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

### `simulator-control` — Simulator Control
- dir: `simctl` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `simulator-manager` — Simulator Manager
- dir: `simulator-manager` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `single-disk-eject` — Single Disk Eject
- dir: `single-disk-eject` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `single-focus` — Single Focus
- dir: `single-focus` · commands: 1 · modes: no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

### `sip` — Sip
- dir: `sip` · commands: 5 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired

### `sips` — Image Modification
- dir: `sips` · commands: 12 · modes: no-view|view
- **Blockers:** showInFinder: throws — showInFinder not wired; getFrontmostApplication: throws — application discovery not wired; declares AI tools[] (11) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process, https
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `siri` — Siri
- dir: `siri` · commands: 1 · modes: no-view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `sketch` — Sketch
- dir: `sketch` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:KeyEquivalent (not in Invoke surface — needs review)

### `skills` — Skills
- dir: `skills` · commands: 2 · modes: view
- **Blockers:** declares AI tools[] (5) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `skyscanner-flights` — Flight Search
- dir: `skyscanner-flights` · commands: 2 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired

### `slack` — Slack
- dir: `slack` · commands: 9 · modes: view|no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getApplications: throws — application discovery not wired; declares AI tools[] (6) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; runPowerShellScript: Windows-only; throws on macOS (import loads); declares extension-level `ai` instructions — ignored
- Needs review: @raycast/utils:useAI (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:WithAccessTokenComponentOrFn (not implemented in Invoke)

### `slack-status` — Slack Status
- dir: `slack-status` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke)

### `slack-summarizer` — Slack Summarizer
- dir: `slack-summarizer` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke)

### `slack-templated-message` — Slack Templated Message
- dir: `slack-templated-message` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `slackmojis` — Slackmojis
- dir: `slackmojis` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `sleep-timer` — Sleep Timer
- dir: `sleep-timer` · commands: 8 · modes: no-view|view|menu-bar
- **Blockers:** unsupported command mode(s): timersMenuBar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `slowed-reverb` — Slowed + Reverb
- dir: `slowed-reverb` · commands: 4 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `slugify-file-folder-names` — Slugify File / Folder Names
- dir: `slugify-file-folder-names` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `sm-ms` — SM.MS
- dir: `sm-ms` · commands: 5 · modes: view|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired

### `smallweb` — Smallweb
- dir: `smallweb` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `smart-calendars-ai-create-events-using-ai` — Smart Calendars AI – Create Events / Reminders Using AI
- dir: `smart-calendars-ai-create-events-using-ai` · commands: 3 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `smart-reply` — Smart Reply - AI-Powered Multilingual Response Generator
- dir: `smart-reply` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `smartthings-connector` — SmartThings Connector
- dir: `smartthings-connector` · commands: 5 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:// useNavigation (not in Invoke surface — needs review); @raycast/api:// Entfernen Sie diesen Import
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

### `snapocr-via-paddle` — SnapOCR Via Paddle
- dir: `snapocr-via-paddle` · commands: 3 · modes: no-view|view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `snippetslab` — SnippetsLab
- dir: `snippetslab` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs

### `snippetsurfer` — Snippet Surfer
- dir: `snippetsurfer` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `social-network-trends` — Social Network Trends
- dir: `social-network-trends` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): search-trends-of-social-network-menu-bar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `solana_nodes` — Solana Nodes
- dir: `nodes` · commands: 2 · modes: menu-bar|view
- **Blockers:** unsupported command mode(s): menuBarStats: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `somafm` — SomaFM
- dir: `somafm` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar-player: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `sonos` — Sonos
- dir: `sonos` · commands: 7 · modes: no-view|view|menu-bar
- **Blockers:** unsupported command mode(s): now-playing: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `sort-mentions` — Sort Mentions
- dir: `sort-mentions` · commands: 2 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process

### `soundboard` — Soundboard
- dir: `soundboard` · commands: 11 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); updateCommandMetadata: loads; no-op (command metadata updates not wired)

### `sourcegraph` — Sourcegraph
- dir: `sourcegraph` · commands: 7 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: http
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; updateCommandMetadata: loads; no-op (command metadata updates not wired); launchCommand: loads; throws if called (inter-command launch not wired)
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke)

### `sourcegraph-amp-dash-x` — Amp Dash X
- dir: `sourcegraph-amp-dash-x` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `sourcetree` — Sourcetree
- dir: `sourcetree` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `spaces` — Spaces
- dir: `spaces` · commands: 3 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process

### `spanish-tv-guide` — Spanish TV Guide
- dir: `spanish-tv-guide` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `specify` — Specify
- dir: `specify` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `speech-to-text` — Speech to Text
- dir: `speech-to-text` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; trash: throws — file trash not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `speedtest` — Speedtest
- dir: `speedtest` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `spiceblow-database` — Spiceblow - Sql Database Management
- dir: `spiceblow-database` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:DeeplinkType (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `spike` — Spike
- dir: `spike` · commands: 6 · modes: view|menu-bar
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; unsupported command mode(s): openIncidents: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `spirii-go` — Spirii Go
- dir: `spirii-go` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `split-video-scenes` — Split Video Scenes
- dir: `split-video-scenes` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

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
- Degraded: declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `spotify-player` — Spotify Player
- dir: `spotify-player` · commands: 35 · modes: view|menu-bar|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; AI: AI.ask throws — Invoke AI not yet wired; getApplications: throws — application discovery not wired; unsupported command mode(s): nowPlayingMenuBar: mode "menu-bar"; declares AI tools[] (7) — AI extensions not supported
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; updateCommandMetadata: loads; no-op (command metadata updates not wired); runPowerShellScript: Windows-only; throws on macOS (import loads); declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ssh-tunnel-manager` — SSH Tunnel Manager
- dir: `ssh-tunnel-manager` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `stablecog` — Stablecog
- dir: `stablecog` · commands: 5 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `stackoverflow` — Search Stack Exchange Sites
- dir: `stackoverflow` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `standing-desk-tracker` — Standing Desk Tracker
- dir: `standing-desk-tracker` · commands: 4 · modes: view|menu-bar|no-view
- **Blockers:** unsupported command mode(s): standing-desk-menubar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `stardew-valley-wiki` — Stardew Vally Character Search
- dir: `stardew-valley-wiki` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `stashit` — Stashit
- dir: `stashit` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `static-marks` — Static Marks - Bookmark Search
- dir: `static-marks-bookmarks` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `stealth-ai-tool` — Stealth AI
- dir: `stealth-ai-tool` · commands: 10 · modes: view|no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: child_process, https
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored

### `steam` — Steam
- dir: `steam` · commands: 1 · modes: view
- **Blockers:** trash: throws — file trash not wired; AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `steamgriddb` — SteamGridDB
- dir: `steamgriddb` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `stickies` — Stickies
- dir: `stickies` · commands: 7 · modes: view|menu-bar|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; unsupported command mode(s): menubar-stickies: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `storybook-sandboxes` — Storybook Sandboxes
- dir: `storybook-sandboxes` · commands: 2 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; getDefaultApplication: throws — application discovery not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `streamshare-uploader` — Streamshare Uploader
- dir: `to-streamshare` · commands: 4 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); launchCommand: loads; throws if called (inter-command launch not wired)

### `stretchly` — Stretchly
- dir: `stretchly` · commands: 2 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `subflow` — Subflow
- dir: `subflow` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `sublime` — Sublime
- dir: `sublime` · commands: 7 · modes: view|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `subnoto` — Subnoto - Confidential Electronic Signature
- dir: `subnoto` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `summarize-youtube-video-with-ai` — Summarize YouTube Videos with AI
- dir: `summarize-youtube-video-with-ai` · commands: 5 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (1) — AI extensions not supported
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `summation` — Summation - Sum Calculator
- dir: `summation` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `sun-moon-times` — Sun/Moon Times
- dir: `sun-moon-times` · commands: 1 · modes: view
- Needs review: @raycast/utils:List (not implemented in Invoke)

### `supabase-cron-monitor` — Supabase Cron Monitor
- dir: `supabase-cron-monitor` · commands: 3 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menubar-cron-monitor: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `svgr` — SVGR
- dir: `svgr` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `swap-commas-dots` — Swap Commas & Dots
- dir: `swap-commas-dots` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `swift-command` — Swift Command
- dir: `swift-command` · commands: 2 · modes: view
- **Blockers:** getDefaultApplication: throws — application discovery not wired; getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `swipe-photo-cleaner` — Swipe Photo Cleaner
- dir: `swipe-photo-cleaner` · commands: 2 · modes: view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `sync-folders` — Sync Folders
- dir: `sync-folders` · commands: 6 · modes: menu-bar|view|no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `synonyms` — Synonyms
- dir: `synonyms` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

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
- Degraded: declares extension-level `ai` instructions — ignored

### `tablepro` — TablePro
- dir: `tablepro` · commands: 9 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar-connections: mode "menu-bar"; declares AI tools[] (12) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `tabler` — Tabler
- dir: `tabler` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `tabstash` — TabStash
- dir: `tabstash` · commands: 2 · modes: view|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `tails` — Tails
- dir: `tails` · commands: 4 · modes: view|no-view|menu-bar
- **Blockers:** getSelectedText: throws — selection APIs not wired; unsupported command mode(s): menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `tailscale` — Tailscale
- dir: `tailscale` · commands: 11 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): menubar: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `tailwindcss` — Tailwind CSS
- dir: `tailwindcss` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `tasklink` — Tasklink
- dir: `tasklink` · commands: 2 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `tategaki` — Tategaki
- dir: `tategaki` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `teak-raycast` — Teak
- dir: `teak-raycast` · commands: 8 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; declares AI tools[] (6) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; BrowserExtension: loads; throws if called (browser bridge not wired); declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `team-time` — Team Time
- dir: `team-time` · commands: 4 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): teamTimeMenuBar: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `tembo` — Tembo
- dir: `tembo` · commands: 3 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menubar-tasks: mode "menu-bar"; declares AI tools[] (2) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled

### `tempmail` — TempMail
- dir: `tempmail` · commands: 2 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

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
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; AI: AI.ask throws — Invoke AI not yet wired; unsupported command mode(s): menu-bar-status: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke)

### `text-decorator` — Text Decorator
- dir: `text-decorator` · commands: 3 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); updateCommandMetadata: loads; no-op (command metadata updates not wired); declares command `arguments[]` — not passed by runtime yet

### `text-differ` — Text Differ
- dir: `text-differ` · commands: 1 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `text-enhance` — Text Enhance
- dir: `text-enhance` · commands: 2 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `text-format-improver` — CJK Text Format Improver
- dir: `text-format-improver` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `text-replacements` — Text Replacements
- dir: `text-replacements` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `text-rewrap` — Text Rewrap
- dir: `text-rewrap` · commands: 3 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `text-shortcuts` — Text Shortcuts
- dir: `text-shortcuts` · commands: 4 · modes: view|menu-bar
- **Blockers:** getSelectedText: throws — selection APIs not wired; unsupported command mode(s): shortcut-library-menu-bar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `textream` — Textream
- dir: `textream` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs

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
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `thesaurus` — Thesaurus
- dir: `thesaurus` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `things` — Things
- dir: `things` · commands: 10 · modes: view|menu-bar|no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; unsupported command mode(s): show-today-in-menu-bar: mode "menu-bar"; declares AI tools[] (12) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
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
- **Blockers:** unsupported command mode(s): menubar: mode "menu-bar"; denied Node built-ins in sandbox: child_process, fs, http
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `tidal-controller` — Tidal Controller
- dir: `tidal-controller` · commands: 10 · modes: no-view|menu-bar
- **Blockers:** unsupported command mode(s): now-playing-menu-bar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `tidyread---streamline-your-daily-reading` — TidyRead - Streamline Your Daily Reading
- dir: `tidyread---streamline-your-daily-reading` · commands: 5 · modes: view|no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: fs, http, child_process
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `tiktoken` — Tiktoken
- dir: `tiktoken` · commands: 2 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `tikz` — TikZ
- dir: `tikz` · commands: 1 · modes: view
- **Blockers:** trash: throws — file trash not wired; declares AI tools[] (1) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs

### `tim` — Tim
- dir: `tim` · commands: 7 · modes: no-view|view
- **Blockers:** showInFinder: throws — showInFinder not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `time-awareness` — Time Awareness
- dir: `time-awareness` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): time-awareness-menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: declares background `interval` command(s) — not scheduled

### `time-logs` — Time Logs
- dir: `time-logs` · commands: 6 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menuBarTimer: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `time-machine` — Time Machine
- dir: `time-machine` · commands: 4 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `time-teller` — Time Teller
- dir: `time-teller` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired

### `time-tracking` — Time Tracking
- dir: `time-tracking` · commands: 5 · modes: view|no-view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `timely` — Timely
- dir: `timely` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `timers` — Timers
- dir: `timers` · commands: 19 · modes: no-view|view|menu-bar
- **Blockers:** unsupported command mode(s): timersMenuBar: mode "menu-bar", stopwatchMenuBar: mode "menu-bar"; declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `timezone-buddy` — Timezone Buddy
- dir: `timezone-buddy` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): timezone-buddy-menubar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `tinyimg` — TinyIMG
- dir: `tinyimg` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `tinypng` — TinyPNG
- dir: `tinypng` · commands: 2 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); declares command `arguments[]` — not passed by runtime yet

### `tl-dr-ai-summary-tool` — TL;DR (Too Long; Didn't Read)
- dir: `tl-dr-ai-summary-tool` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: https

### `tldv` — Tldv Meetings
- dir: `tldv` · commands: 4 · modes: view|menu-bar|no-view
- **Blockers:** unsupported command mode(s): recent-meetings: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `tmux-cheatsheet` — Tmux Cheatsheet
- dir: `tmux-cheatsheet` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `tmux-sessioner` — Tmux Sessioner
- dir: `tmux-sessioner` · commands: 4 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired)

### `tny` — Tny
- dir: `tny` · commands: 3 · modes: view|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; getSelectedText: throws — selection APIs not wired

### `todo-list` — Todo List
- dir: `todo-list` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu_bar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `todoist` — Todoist
- dir: `todoist` · commands: 11 · modes: view|no-view|menu-bar
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; getApplications: throws — application discovery not wired; unsupported command mode(s): menu-bar: mode "menu-bar"; declares AI tools[] (29) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `toggl-track` — Toggl Track
- dir: `toggl-track` · commands: 7 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menuBar: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:CachedPromiseOptions (not implemented in Invoke)

### `toggle-desktop-visibility` — Toggle Desktop Visibility
- dir: `toggle-desktop-visibility` · commands: 6 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `toggle-menu-bar` — Toggle Menu Bar
- dir: `toggle-menu-bar` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired)

### `toggle-proxy` — Toggle Proxy
- dir: `toggle-proxy` · commands: 6 · modes: menu-bar|view
- **Blockers:** unsupported command mode(s): menu-bar-proxy: mode "menu-bar"; denied Node built-ins in sandbox: fs, net
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

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

### `toneclone` — ToneClone
- dir: `toneclone` · commands: 7 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; BrowserExtension: loads; throws if called (browser bridge not wired)
- Needs review: @raycast/api:KeyEquivalent (not in Invoke surface — needs review)

### `toothpick` — Toothpick
- dir: `toothpick` · commands: 19 · modes: view|no-view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `torbox` — TorBox
- dir: `torbox` · commands: 3 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `torr-manager` — Torr Manager
- dir: `torr-manager` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `tourbox` — TourBox
- dir: `tourbox` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs

### `tower` — Tower Repositories
- dir: `tower` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `trakt-manager` — Trakt Manager
- dir: `trakt-manager` · commands: 7 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: fs

### `transfer-sh_upload` — Transfer.sh Uploader
- dir: `transfer-sh_upload` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `translate` — Google Translate
- dir: `google-translate` · commands: 6 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: https, child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `translate-send-webpage-to-reader` — Translate and Send Webpage to Reader
- dir: `translate-send-webpage-to-reader` · commands: 1 · modes: no-view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `transmission` — Transmission
- dir: `transmission` · commands: 3 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `transport-nsw` — Transport NSW
- dir: `transport-nsw` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar-trips: mode "menu-bar"; declares AI tools[] (5) — AI extensions not supported
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled

### `trek` — Trek
- dir: `trek` · commands: 6 · modes: view|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `trimmy` — Trimmy
- dir: `trimmy` · commands: 3 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `trovu` — Trovu - Web Search Command Line
- dir: `trovu` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `try` — Try
- dir: `try` · commands: 1 · modes: view
- **Blockers:** trash: throws — file trash not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `turso` — Turso
- dir: `turso` · commands: 3 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: http
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `twenty` — Twenty
- dir: `twenty` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:ItemProps (not in Invoke surface — needs review); @raycast/api:FormItemRef (not in Invoke surface — needs review)

### `twitch` — Twitch
- dir: `twitch` · commands: 4 · modes: view|menu-bar
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; unsupported command mode(s): live: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `twitter` — Twitter
- dir: `twitter` · commands: 4 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `twitter-video-downloader` — X/Twitter Video Downloader
- dir: `twitter-video-downloader` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `two-factor-authentication-code-generator` — Two-Factor Authentication Code Generator
- dir: `two-factor-authentication-code-generator` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `typefully` — Typefully
- dir: `typefully` · commands: 5 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (4) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `typewhisper` — TypeWhisper
- dir: `typewhisper` · commands: 5 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `typographer` — Typographer: Make Text Pretty
- dir: `typographer` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `typora-note-creator` — Typora Note Creator
- dir: `typora-note-creator` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

### `u301-url-shortener` — U301 URL Shortener
- dir: `u301-url-shortener` · commands: 3 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired; AI: AI.ask throws — Invoke AI not yet wired; declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `ugly-face` — Ugly Face
- dir: `ugly-face` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:render (not in Invoke surface — needs review)

### `ulysses` — Ulysses
- dir: `ulysses` · commands: 5 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired

### `umami` — Umami
- dir: `umami` · commands: 4 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): view-websites-menu-bar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `unicode-symbols` — Unicode Symbols Search
- dir: `unicode-symbols` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs

### `unifi` — Unifi
- dir: `unifi` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: https
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `united-nations` — United Nations
- dir: `united-nations` · commands: 5 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired

### `universal-commands` — Universal Commands
- dir: `universal-commands` · commands: 3 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; getFrontmostApplication: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `unpackr` — Unpackr
- dir: `unpackr` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `unsplash` — Unsplash
- dir: `unsplash` · commands: 4 · modes: view|no-view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: fs
- Degraded: declares background `interval` command(s) — not scheduled

### `update-clash-subscription` — Update Clash Subscription
- dir: `update-clash-subscription` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `uploaderx` — UploaderX
- dir: `uploaderx` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, https
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `uploadthing` — UploadThing
- dir: `uploadthing` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `upnote` — UpNote
- dir: `upnote` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `upset-dev` — Upset.dev
- dir: `upset-dev` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `uptime` — Uptime
- dir: `uptime` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `uranium-raycast-plugin` — NFT Primitive Tools
- dir: `uranium-raycast-plugin` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `url-editor-pro` — URL Editor Pro
- dir: `url-editor-pro` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `url-shortener` — URL Shortener
- dir: `url-shortener` · commands: 2 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `url-unshortener` — URL Unshortener
- dir: `url-unshortener` · commands: 2 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `user-agent` — User-Agent Parser
- dir: `user-agent` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `userplane` — Userplane
- dir: `userplane` · commands: 4 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired)

### `utm-virtual-machines` — UTM Virtual Machines
- dir: `utm-virtual-machines` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `v0-by-vercel` — v0 by Vercel
- dir: `v0-by-vercel` · commands: 6 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `v2box-control` — V2BOX VPN
- dir: `v2box-control` · commands: 4 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `vade-mecum` — Vade Mecum
- dir: `vade-mecum` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

### `vault-manager` — Vault Manager
- dir: `vault` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: http, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `vercast` — Vercel
- dir: `vercast` · commands: 9 · modes: view|menu-bar|no-view
- **Blockers:** unsupported command mode(s): menu-bar-deployments: mode "menu-bar"; declares AI tools[] (9) — AI extensions not supported
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `vesslo` — Vesslo
- dir: `vesslo` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `viacep` — ViaCEP
- dir: `viacep` · commands: 2 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `video-call-reactions` — Video Call Reactions
- dir: `video-call-reactions` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `video-converter` — Video Converter
- dir: `video-converter` · commands: 2 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `video-downloader` — Video Downloader
- dir: `video-downloader` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `vikunja` — Vikunja Task Manager
- dir: `vikunja` · commands: 4 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `vim-leader-key` — Vim Leader Key - Keyboard Shortcut Sequences
- dir: `vim-leader-key` · commands: 4 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getSelectedText: throws — selection APIs not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); getSelectedFinderItems: loads; throws if called (Finder selection not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `virtual-desktop-manager` — Virtual Desktop Manager
- dir: `virtual-desktop-manager` · commands: 35 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `virtual-pet` — Virtual Pet
- dir: `virtual-pet` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `virustotal` — VirusTotal
- dir: `virustotal` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: net, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); declares command `arguments[]` — not passed by runtime yet

### `visual-studio-code` — Visual Studio Code
- dir: `visual-studio-code-recent-projects` · commands: 6 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); runPowerShellScript: Windows-only; throws on macOS (import loads)

### `vivaldi` — Vivaldi
- dir: `vivaldi` · commands: 5 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process

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
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads); declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `vn-textify` — VN Textify
- dir: `vn-textify` · commands: 1 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `vocabuilder` — VocaBuilder
- dir: `vocabuilder` · commands: 3 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `voice-to-text-windows` — Voice-to-Text for Windows
- dir: `voice-to-text-windows` · commands: 3 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: child_process, fs

### `voiceink` — VoiceInk
- dir: `voiceink` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `voicemeeter-raycast` — Voicemeeter Control
- dir: `voicemeeter-raycast` · commands: 5 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `vortex` — Vortex
- dir: `vortex` · commands: 4 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `vps-explorer` — VPS Explorer
- dir: `vps-explorer` · commands: 1 · modes: view
- **Blockers:** showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `vscode-project-manager` — Visual Studio Code - Project Manager
- dir: `visual-studio-code-project-manager` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `vuejobs` — VueJobs
- dir: `vuejobs` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"

### `wakatime` — Wakatime
- dir: `wakatime` · commands: 4 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): today-summary: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `waktu-solat` — Waktu Solat
- dir: `waktu-solat` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `wallhaven` — Wallhaven
- dir: `wallhaven` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `warp` — Warp
- dir: `warp` · commands: 5 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `watchkey` — Watchkey
- dir: `watchkey` · commands: 5 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `wave` — Wave
- dir: `wave` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `wayback-machine` — Wayback Machine
- dir: `wayback-machine` · commands: 4 · modes: no-view|view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `weather` — Weather
- dir: `weather` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menubar: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `web-blocker` — Web Blocker
- dir: `web-blocker` · commands: 5 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `web-page-design-mode` — Web Page Design Mode
- dir: `web-page-design-mode` · commands: 1 · modes: no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

### `webdav-uploader` — WebDAV Uploader
- dir: `webdav-uploader` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `webflow-sites` — Webflow
- dir: `webflow-sites` · commands: 1 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Needs review: @raycast/utils:withAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke)

### `webpage-to-markdown` — Webpage to Markdown
- dir: `webpage-to-markdown` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `website-blocker` — Website Blocker
- dir: `website-blocker` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; updateCommandMetadata: loads; no-op (command metadata updates not wired)

### `wechat` — WeChat
- dir: `wechat` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `wechat-devtool` — WeChat DevTool
- dir: `wechat-devtool` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `week-number` — Week Number
- dir: `week-number` · commands: 2 · modes: menu-bar|view
- **Blockers:** unsupported command mode(s): week-number: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `weread-sync` — WeRead Sync
- dir: `weread-sync` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: https

### `wezterm-navigator` — WezTerm Navigator
- dir: `wezterm-navigator` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `whatsapp` — WhatsApp
- dir: `whatsapp` · commands: 4 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired; declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: declares extension-level `ai` instructions — ignored
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
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; denied Node built-ins in sandbox: child_process, fs, https
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `whmcs-client-search` — WHMCS Client Search
- dir: `whmcs-client-search` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs

### `whoop` — WHOOP
- dir: `whoop` · commands: 3 · modes: no-view|view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `wi-fi` — Wi-Fi
- dir: `wi-fi` · commands: 2 · modes: no-view|menu-bar
- **Blockers:** unsupported command mode(s): wi-fi-signal: mode "menu-bar"; denied Node built-ins in sandbox: child_process
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `wifi-password-reveal` — WiFi Password Reveal
- dir: `wifi-password-reveal` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `wifi-share` — Wifi Share QR-Code
- dir: `wifi-share` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `wikipedia` — Wikipedia
- dir: `wikipedia` · commands: 4 · modes: view|no-view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet

### `window-layouts` — Window Layouts
- dir: `window-layouts` · commands: 27 · modes: no-view|view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:WindowManagement (not in Invoke surface — needs review)

### `window-sizer` — Window Sizer
- dir: `window-sizer` · commands: 2 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `window-walker` — Window Walker
- dir: `window-walker` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `windows-environment-variables` — Windows Environment Variables
- dir: `windows-environment-variables` · commands: 3 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired)

### `windows-terminal` — Windows Terminal
- dir: `windows-terminal` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs

### `windsurf` — Windsurf Extension
- dir: `windsurf` · commands: 2 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: child_process, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

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
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: fs
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `wireguard` — Wireguard
- dir: `wireguard` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `wise-accounts` — Wise Accounts
- dir: `wise-accounts` · commands: 4 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): display-balances: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `wise-quotes` — Wise Quotes
- dir: `wise-quotes` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): current-rate: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `wispr-flow` — Wispr Flow
- dir: `wispr-flow` · commands: 8 · modes: view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

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

### `woocommerce-quicker` — WooCommerce Quicker
- dir: `woocommerce-quicker` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: https
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `word-count` — Word Count
- dir: `word-count` · commands: 3 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `word-search` — Word Search
- dir: `word-search` · commands: 8 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `word4you` — Word4you
- dir: `word4you` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs, https, child_process
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `wordpress-docs` — WordPress Docs
- dir: `wordpress-docs` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired
- Needs review: @raycast/utils:useAI (not implemented in Invoke)

### `wordreference` — WordReference Dictionary Translation
- dir: `wordreference` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `work-time-countdown` — Work Time Countdown
- dir: `work-time-countdown` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): index: mode "menu-bar"
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `workouts` — Workouts
- dir: `workouts` · commands: 6 · modes: view|menu-bar
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired; unsupported command mode(s): menubar-totals: mode "menu-bar"; declares AI tools[] (6) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `worktrees` — Git Worktrees
- dir: `worktrees` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `world-clock` — World Clock
- dir: `world-clock` · commands: 3 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): query-world-time-menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: net
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `wp-bones` — WP Bones
- dir: `wp-bones` · commands: 5 · modes: menu-bar|view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; unsupported command mode(s): menu-bar: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `wppb` — WPPB
- dir: `wppb` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `wrap-text` — Wrap Text
- dir: `wrap-text` · commands: 6 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `wrap-unwrap` — Wrap Unwrap
- dir: `wrap-unwrap` · commands: 2 · modes: no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `writersbrew` — Writersbrew
- dir: `writersbrew` · commands: 21 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process

### `wsl-manager` — WSL Manager
- dir: `wsl-manager` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: child_process

### `xcode` — Xcode
- dir: `xcode` · commands: 21 · modes: menu-bar|view|no-view
- **Blockers:** getApplications: throws — application discovery not wired; unsupported command mode(s): show-recent-projects-in-menu-bar.command: mode "menu-bar", show-recent-builds-in-menu-bar.command: mode "menu-bar"; declares AI tools[] (14) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired); launchCommand: loads; throws if called (inter-command launch not wired); declares extension-level `ai` instructions — ignored; declares command `arguments[]` — not passed by runtime yet
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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `xiaohe-query` — Xiaohe Query
- dir: `xiaohe-query` · commands: 1 · modes: view
- **Blockers:** AI: AI.ask throws — Invoke AI not yet wired; getSelectedText: throws — selection APIs not wired; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `y-combinator` — Y Combinator
- dir: `y-combinator` · commands: 2 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): demo-day-countdown: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `yabai` — Yabai
- dir: `yabai` · commands: 31 · modes: no-view|menu-bar|view
- **Blockers:** unsupported command mode(s): screens-menu-bar: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `yafw` — YAFW
- dir: `yafw` · commands: 7 · modes: view|no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; showInFinder: throws — showInFinder not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `yandex-smart-home` — Yandex Smart Home
- dir: `yandex-smart-home` · commands: 2 · modes: view
- **Blockers:** OAuth: OAuth.PKCEClient throws — OAuth not yet wired

### `yasb` — YASB
- dir: `yasb` · commands: 12 · modes: no-view|view
- **Blockers:** denied Node built-ins in sandbox: child_process
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares command `arguments[]` — not passed by runtime yet

### `year-in-progress` — Year in Progress
- dir: `year-in-progress` · commands: 3 · modes: no-view|menu-bar|view
- **Blockers:** unsupported command mode(s): index: mode "menu-bar"
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `yoink` — Yoink
- dir: `yoink` · commands: 1 · modes: no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `yomicast` — Yomicast – Offline Japanese-English Dictionary
- dir: `yomicast` · commands: 2 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `youdao-translate` — Youdao Translate
- dir: `youdao-translate` · commands: 1 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `your-name-in-landsat` — Your Name in Landsat
- dir: `your-name-in-landsat` · commands: 2 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `youtrack` — YouTrack
- dir: `youtrack` · commands: 2 · modes: view
- **Blockers:** declares AI tools[] (7) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `youtube` — YouTube
- dir: `youtube` · commands: 4 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `youtube-highlights` — YouTube Highlights
- dir: `youtube-highlights` · commands: 5 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; OAuth: OAuth.PKCEClient throws — OAuth not yet wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `youtube-search` — YouTube Search
- dir: `youtube-search` · commands: 2 · modes: view|no-view
- **Blockers:** getSelectedText: throws — selection APIs not wired

### `youtube-shorts-to-normal-video-page` — YouTube Shorts to Normal Video Page
- dir: `youtube-shorts-to-normal-video-page` · commands: 1 · modes: no-view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired

### `youtube-subscriber-count` — YouTube Subscriber Count
- dir: `youtube-subscriber-count` · commands: 1 · modes: menu-bar
- **Blockers:** unsupported command mode(s): index: mode "menu-bar"
- Degraded: declares background `interval` command(s) — not scheduled

### `youtube-thumbnail` — YouTube Thumbnail
- dir: `youtube-thumbnail` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `yubikey-code` — YubiKey Code
- dir: `yubikey-code` · commands: 1 · modes: view
- **Blockers:** getFrontmostApplication: throws — application discovery not wired; denied Node built-ins in sandbox: child_process, fs
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `zeabur` — Zeabur
- dir: `zeabur` · commands: 9 · modes: view|menu-bar
- **Blockers:** unsupported command mode(s): menu-bar-projects: mode "menu-bar", menu-bar-deployment: mode "menu-bar"; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `zed-recent-projects` — Zed
- dir: `zed-recent-projects` · commands: 3 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: fs, child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); runPowerShellScript: Windows-only; throws on macOS (import loads)

### `zen-browser` — Zen Browser
- dir: `zen-browser` · commands: 6 · modes: view|no-view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: child_process, fs
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads); declares extension-level `ai` instructions — ignored

### `zen-mode` — Zen Mode
- dir: `zen-mode` · commands: 3 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; denied Node built-ins in sandbox: child_process

### `zenmux-manager` — ZenMux Manager
- dir: `zenmux-manager` · commands: 2 · modes: no-view|view
- **Blockers:** declares AI tools[] (2) — AI extensions not supported; denied Node built-ins in sandbox: fs, child_process
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled
- Needs review: @raycast/api:name: "Search tool imports the routing table" (not in Invoke surface — needs review); @raycast/api:passed:
      searchTool.includes('from "../zenmux-doc-routing"') &&
      searchTool.includes("routingMatches") (not in Invoke surface — needs review)

### `zeplin-project-raycast-extension` — Zeplin Project Search
- dir: `zeplin-project-search` · commands: 1 · modes: view
- **Blockers:** getApplications: throws — application discovery not wired

### `zerion` — Zerion
- dir: `zerion` · commands: 9 · modes: view|menu-bar|no-view
- **Blockers:** unsupported command mode(s): menu-bar-wallet: mode "menu-bar"; declares AI tools[] (7) — AI extensions not supported
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `zero` — Zero
- dir: `zero` · commands: 1 · modes: no-view
- **Blockers:** declares AI tools[] (1) — AI extensions not supported
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `zipic` — Zipic
- dir: `zipic` · commands: 3 · modes: no-view|view
- **Blockers:** getApplications: throws — application discovery not wired; declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: fs, https, http, child_process
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored

### `zipline` — Zipline
- dir: `zipline` · commands: 4 · modes: view|no-view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired); declares command `arguments[]` — not passed by runtime yet

### `znotch` — Manage Macbook's Notch
- dir: `znotch` · commands: 3 · modes: no-view
- **Blockers:** getApplications: throws — application discovery not wired

### `zoo` — Zoo - Ask AIs with Your Prompt Library
- dir: `zoo` · commands: 3 · modes: view
- **Blockers:** getSelectedText: throws — selection APIs not wired; getFrontmostApplication: throws — application discovery not wired
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `zoom` — Zoom
- dir: `zoom` · commands: 5 · modes: view|no-view|menu-bar
- **Blockers:** unsupported command mode(s): this-week-meetings: mode "menu-bar"; declares AI tools[] (6) — AI extensions not supported
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet
- Needs review: @raycast/utils:OAuthService (not implemented in Invoke); @raycast/utils:getAccessToken (not implemented in Invoke); @raycast/utils:withAccessToken (not implemented in Invoke)

### `zotero` — Search Zotero
- dir: `zotero` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `zoxide-git-projects` — Zoxide Git Projects
- dir: `zoxide-git-projects` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs

### `zsh-aliases` — Zsh Aliases
- dir: `zsh-aliases` · commands: 1 · modes: view
- **Blockers:** declares AI tools[] (3) — AI extensions not supported; denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares extension-level `ai` instructions — ignored
- Needs review: @raycast/api:Tool (not in Invoke surface — needs review)

### `zshrc-manager` — Zshrc Manager
- dir: `zshrc-manager` · commands: 1 · modes: view
- **Blockers:** denied Node built-ins in sandbox: fs
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

## DEGRADED (508)

### `40-questions` — 40 Questions - Yearly Reflection
- dir: `40-questions` · commands: 3 · modes: view|no-view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `ai-by-vercel` — AI by Vercel
- dir: `ai-by-vercel` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ai-stats` — AI Stats
- dir: `ai-stats` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ai-usage-tracker` — AI Usage Tracker
- dir: `ai-usage-tracker` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `airpods-noise-control` — AirPods Noise Control
- dir: `airpods-noise-control` · commands: 2 · modes: no-view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired)

### `algorand` — Algorand
- dir: `algorand` · commands: 8 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `alpaca-trading` — Alpaca Trading
- dir: `alpaca-trading` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `alwaysdata` — alwaysdata
- dir: `alwaysdata` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `anki` — Anki
- dir: `anki` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `anna-s-archive` — Anna's Archive
- dir: `anna-s-archive` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `apple-maps-search` — Apple Maps Search
- dir: `apple-maps-search` · commands: 3 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `appwrite` — Appwrite
- dir: `appwrite` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `attio` — Attio
- dir: `attio` · commands: 6 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `auth0-management` — Auth0 Management
- dir: `auth0-management` · commands: 7 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `autumn` — Autumn
- dir: `autumn` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `bamboohr` — BambooHR
- dir: `bamboohr` · commands: 4 · modes: view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `beardtown` — Beardtown
- dir: `beardtown` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `bech32-converter` — Bech32 Converter
- dir: `bech32-converter` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `bed-time-calculator` — Bed Time Calculator
- dir: `bed-time-calculator` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `beeminder` — Beeminder
- dir: `beeminder` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `bento` — Bento Email
- dir: `bento` · commands: 13 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `better-deal` — Better Deal
- dir: `better-deal` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled

### `blockchain-explorer-search` — Blockchain Explorer Search
- dir: `blockchain-explorer-search` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `bmrks` — (Basic) Bookmarks
- dir: `bmrks` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `brand-dev` — Brand.dev
- dir: `brand-dev` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `brawlstars` — Brawl Stars Search
- dir: `brawlstars` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `browser-ai` — Browser AI Companion
- dir: `browser-ai` · commands: 5 · modes: no-view|view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `buddy` — Buddy
- dir: `buddy` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `bunq` — Bunq
- dir: `bunq` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `caaals` — Caaals Food Tracker
- dir: `caaals` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `cacher` — Cacher - Code Snippet Organizer
- dir: `cacher` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `cardpointers` — CardPointers
- dir: `cardpointers` · commands: 4 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cdnjs` — cdnjs
- dir: `cdnjs` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `center` — Center
- dir: `center` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `changedetection-io` — ChangeDetection.io
- dir: `changedetection-io` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `chatwith` — Chatwith
- dir: `chatwith` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `chatwoot` — Chatwoot
- dir: `chatwoot` · commands: 7 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `checklist` — Checklist
- dir: `checklist` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `china-ip-address` — China IP Address
- dir: `china-ip-address` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `chinese-converter` — Chinese Converter
- dir: `chinese-converter` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `chronometer` — Chronometer
- dir: `chronometer` · commands: 4 · modes: view|no-view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired)

### `cider` — Cider
- dir: `cider` · commands: 12 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cidr` — CIDR Conversion
- dir: `cidr` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `clash` — Clash
- dir: `clash` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `cloudflare` — Cloudflare
- dir: `cloudflare` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `cloudflare-ai` — Cloudflare Workers AI
- dir: `cloudflare-ai` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `cloudflare-email-routing` — Cloudflare Email Routing
- dir: `cloudflare-email-routing` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `cloudinary` — Cloudinary
- dir: `cloudinary` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cnpj-lookup` — CNPJ Lookup
- dir: `cnpj-lookup` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cocktail-db` — Cocktail DB
- dir: `cocktail-db` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `code-wiki` — Code Wiki
- dir: `code-wiki` · commands: 2 · modes: no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `cognimemo` — CogniMemo
- dir: `cognimemo` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `color-shades` — Color Shades
- dir: `color-shades` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `contentful` — Contentful
- dir: `contentful` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `context7` — Context7
- dir: `context7` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `convex` — Convex
- dir: `convex` · commands: 10 · modes: view|no-view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `cookie-string-parser` — Cookie String
- dir: `cookie-string-parser` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `coolify` — Coolify
- dir: `coolify` · commands: 5 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `count-numbers` — Count Numbers
- dir: `count-numbers` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `counter` — Counter
- dir: `counter` · commands: 3 · modes: no-view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); launchCommand: loads; throws if called (inter-command launch not wired)

### `covert-color` — Convert Color
- dir: `covert-color` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cpanel` — cPanel
- dir: `cpanel` · commands: 7 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `create-link` — Create Link
- dir: `create-link` · commands: 5 · modes: no-view|view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `creem` — Creem
- dir: `creem` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `cron` — Cron
- dir: `cron` · commands: 2 · modes: view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired)

### `cryptgeon` — cryptgeon
- dir: `cryptgeon` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `crypto-portfolio-tracker` — Crypto Portfolio Tracker
- dir: `crypto-portfolio-tracker` · commands: 2 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cuid2-generator` — Cuid2 Generator
- dir: `cuid2-generator` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `currency-exchange` — Currency Exchange
- dir: `currency-exchange` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `custom-wordle` — Custom Wordle
- dir: `custom-wordle` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cyberpanel` — CyberPanel
- dir: `cyberpanel` · commands: 9 · modes: no-view|view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `danbooru` — Danbooru
- dir: `danbooru` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `danish-tax-calculator` — Danish Tax Calculator
- dir: `danish-tax-calculator` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `databuddy` — Databuddy
- dir: `databuddy` · commands: 7 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `datahub` — Datahub Utility
- dir: `datahub` · commands: 2 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `datawrapper` — Datawrapper
- dir: `datawrapper` · commands: 5 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `date-format-converter` — Date Format Converter
- dir: `datetime-format-converter` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `decimal-2-time` — Decimal 2 Time
- dir: `decimal-2-time` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `deepl-api-usage` — DeepL API Usage
- dir: `deepl-api-usage` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `defichain-lottery` — Defichain Lottery
- dir: `defichain-lottery` · commands: 4 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `defly-io` — Defly.io
- dir: `defly-io` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `denmarks-address-web-api` — DAWA - Danish Address Web API
- dir: `dawa` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `dev-to` — DEV Community
- dir: `dev-to` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `devin` — Devin
- dir: `devin` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `devpod` — DevPod
- dir: `devpod` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `dia-skills` — Dia Skills
- dir: `dia-skills` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `dice-and-coin` — Dice & Coin
- dir: `dice-and-coin` · commands: 3 · modes: no-view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired)

### `diff-checker` — Diff Checker
- dir: `diff-checker` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `dig` — Dig - DNS Lookup
- dir: `dig` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `directadmin-reseller` — DirectAdmin Reseller
- dir: `directadmin-reseller` · commands: 6 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `discordjs-documentation` — Discord.js Documentation
- dir: `discordjs-documentation` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `discussite` — Discussite
- dir: `discussite` · commands: 1 · modes: no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `display-reinitializer` — Display Reinitializer
- dir: `display-reinitializer` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `django-docs` — Django Docs
- dir: `django-docs` · commands: 2 · modes: view|no-view
- Degraded: declares background `interval` command(s) — not scheduled

### `doccheck` — DocCheck
- dir: `doccheck` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `docsearch` — DocSearch
- dir: `docsearch` · commands: 45 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `dodo-payments` — Dodo Payments
- dir: `dodo-payments` · commands: 9 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `doge-tracker` — Department of Government Efficiency Tracker
- dir: `doge-tracker` · commands: 4 · modes: view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired)

### `dokploy` — Dokploy
- dir: `dokploy` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `dolar-hoy` — Dolar Hoy Argentina
- dir: `dolar-hoy` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `doppler-share-secrets` — Doppler Share Secrets
- dir: `doppler-share-secrets` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `dovetail` — Dovetail
- dir: `dovetail` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `dreamhost` — DreamHost
- dir: `dreamhost` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `dropstab` — DropsTab
- dir: `dropstab` · commands: 6 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `duan-raycast-extension` — Duan: Shorten and Manage Links
- dir: `duan-raycast-extension` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired)

### `ducat` — Ducat
- dir: `ducat` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `duden` — Duden
- dir: `duden` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `easings` — Easings
- dir: `easings` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `email-verifier` — Email Verifier
- dir: `email-verifier` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `end-of-life` — End of Life
- dir: `end-of-life` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `envato` — Envato Sales, Purchases and Search
- dir: `envato` · commands: 5 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `esa-search` — esa Search
- dir: `esa-search` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `essay` — Essay
- dir: `essay` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `eurovision-song-contest` — Eurovision Song Contest
- dir: `eurovision-song-contest` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `everhour` — Everhour Time Tracking
- dir: `everhour` · commands: 3 · modes: view|no-view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `evm-toolkit` — EVM Toolkit
- dir: `evm-toolkit` · commands: 11 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `excalidraw` — Excalidraw
- dir: `excalidraw` · commands: 4 · modes: view|no-view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `explain-command` — Explain Command
- dir: `explain-command` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `expo` — Expo
- dir: `expo` · commands: 5 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `fakecrime-upload` — Fakecrime Upload
- dir: `fakecrime-upload` · commands: 1 · modes: no-view
- Degraded: getSelectedFinderItems: loads; throws if called (Finder selection not wired)

### `fastly` — Fastly
- dir: `fastly` · commands: 10 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `featurebase` — Featurebase
- dir: `featurebase` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `figma-variables` — Figma Variables
- dir: `figma-variables` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `firefly-iii` — Firefly III
- dir: `firefly-iii` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `foodle-recipes` — Foodle Recipes
- dir: `foodle-recipes` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `footy-report` — Footy Report
- dir: `footy-report` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `formizee` — Formizee
- dir: `formizee` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `fotmob` — Fotmob
- dir: `fotmob` · commands: 10 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `freedns` — FreeDNS
- dir: `freedns` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `french-verb-conjugation` — French Verb Conjugation
- dir: `french-verb-conjugation` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `frill` — Frill
- dir: `frill` · commands: 5 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ftrack` — ftrack
- dir: `ftrack` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `fumadocs` — Fumadocs
- dir: `fumadocs` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `gandi` — Gandi
- dir: `gandi` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `genius-lyrics` — Genius Lyrics
- dir: `genius-lyrics` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `gg-deals` — gg.deals
- dir: `gg-deals` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `gistly` — Gistly
- dir: `gistly` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `glossary` — Glossary
- dir: `glossary` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `go-to-rewind-timestamp` — Go to Rewind Timestamp
- dir: `go-to-rewind-timestamp` · commands: 2 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `goodreads` — Goodreads
- dir: `goodreads` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `google-cloud-run` — Google Cloud Run
- dir: `google-cloud-run` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `google-maven-repository` — Google Maven Repository
- dir: `google-maven-repository` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `govee` — Govee
- dir: `govee` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `grafbase` — Grafbase
- dir: `grafbase` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `graphcalc` — GraphCalc
- dir: `graphcalc` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `greip` — Greip
- dir: `greip` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `grist` — Grist
- dir: `grist` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `guerrilla-mail` — Guerrilla Mail
- dir: `guerrilla-mail` · commands: 3 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `guitar-chords` — Guitar Chords
- dir: `guitar-chords` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `habitica-todos` — Habitica ToDos
- dir: `habitica-todos` · commands: 7 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired)

### `habits` — SupaHabits
- dir: `supahabits` · commands: 5 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired)

### `hardcover` — Hardcover
- dir: `hardcover` · commands: 7 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `hashrate-no` — Hashrate
- dir: `hashrate-no` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `have-i-been-pwned` — Have I Been Pwned
- dir: `have-i-been-pwned` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `hebrew-date-zmanim` — Hebrew Date & Zmanim
- dir: `hebrew-date-zmanim` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `hephaestus` — Hephaestus - JSON Tools
- dir: `hephaestus` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `hestiacp-admin` — HestiaCP Admin
- dir: `hestiacp-admin` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `hetzner` — Hetzner
- dir: `hetzner` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `hidemyemail` — Hide My Email
- dir: `hidemyemail` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `hipster-ipsum` — Hipster Ipsum
- dir: `hipster-ipsum` · commands: 2 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `holopin` — Holopin
- dir: `holopin` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `homebox` — HomeBox
- dir: `homebox` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `horoscope` — Horoscope
- dir: `horoscope` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `host-io` — Host.io
- dir: `host-io` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `howlongtobeat` — HowLongToBeat
- dir: `how-long-to-beat` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `http-observatory` — HTTP Observatory
- dir: `http-observatory` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `hue-palette` — Hue Palette
- dir: `hue-palette` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `hyrule-compendium-search` — Hyrule Compendium Search
- dir: `hyrule-compendium-search` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `imdb` — IMDb Search
- dir: `imdb` · commands: 4 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `improvmx` — ImprovMX
- dir: `improvmx` · commands: 6 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `inbound` — Inbound
- dir: `inbound` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `indiehackers` — IndieHackers
- dir: `indiehackers` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `infakt` — InFakt
- dir: `infakt` · commands: 5 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `infomaniak` — Infomaniak
- dir: `infomaniak` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `inkdrop` — Inkdrop
- dir: `inkdrop` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `inspire-search` — Inspire HEP Search
- dir: `inspire-search` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ionos-sync` — IONOS Sync
- dir: `ionos-sync` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ip-tools` — IP Tools
- dir: `ip-tools` · commands: 9 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ipapi-is` — ipapi.is
- dir: `ipapi-is` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ipinfo` — IP Info
- dir: `ipinfo` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `jalali-date-convertor` — Jalali Date Convertor
- dir: `jalali-date-convertor` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `jellyfin` — Jellyfin
- dir: `jellyfin` · commands: 4 · modes: view
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

### `jsrepo` — jsrepo
- dir: `jsrepo` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `kafka-ui` — Kafka UI
- dir: `kafka-ui` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `kagi-fastgpt` — Kagi FastGPT
- dir: `kagi-fastgpt` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `kaneo-for-raycast` — Kaneo
- dir: `kaneo-for-raycast` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `keygen` — Keygen
- dir: `keygen` · commands: 7 · modes: view|no-view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `klu-ai` — Klu
- dir: `klu-ai` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `knowwa` — Knowwa
- dir: `knowwa` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `koyeb` — Koyeb
- dir: `koyeb` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `kusto-reference` — Kusto Reference
- dir: `kusto-reference` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `kutt` — Kutt
- dir: `kutt` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `latest-news` — Latest Local News
- dir: `latest-news` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `leave-time-calculator` — Leave Time Calculator
- dir: `leave-time-calculator` · commands: 2 · modes: no-view|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `lemmy` — Lemmy
- dir: `lemmy` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `let-me-google-that` — LetMeGoogleThat
- dir: `let-me-google-that` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `letterboxd` — Letterboxd
- dir: `letterboxd` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `libraries-io` — Libraries.io
- dir: `libraries-io` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `lift-calculator` — Lift Calculator
- dir: `lift-calculator` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `lightning-time` — Lightning Time
- dir: `lightning-time` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `linkace` — Linkace
- dir: `linkace` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `linkinize` — Linkinize
- dir: `linkinize` · commands: 3 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `lipsum` — Japanese Lorem Ipsum Generator
- dir: `lipsum` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `list-keyboard-maestro-macros` — Keyboard Maestro - List Macros
- dir: `keyboard-maestro` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `literal` — Literal
- dir: `literal` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `liveblocks` — Liveblocks
- dir: `liveblocks` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `loan-calculator` — Loan Calculator
- dir: `loan-calculator` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `logsnag` — LogSnag
- dir: `logsnag` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `logtail` — Logtail
- dir: `logtail` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `looksee` — LookSee - A MAC, OUI, IAB Lookup
- dir: `looksee` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `lorem-picsum` — Lorem Picsum
- dir: `lorem-picsum` · commands: 2 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `lotus-mtg-companion` — Lotus - MTG Companion
- dir: `lotus-mtg-companion` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `lunchmoney` — Lunch Money
- dir: `lunchmoney` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `mail-finder` — Mail Finder
- dir: `email-finder` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `mailboxlayer` — mailboxlayer
- dir: `mailboxlayer` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `mailersend` — MailerSend
- dir: `mailersend` · commands: 5 · modes: no-view|view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `mailwip` — Mailwip
- dir: `mailwip` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired)

### `manifest-viewer` — Manifest Viewer
- dir: `manifest-viewer` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `manotori` — Manotori
- dir: `manotori` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `maplestory-gg` — MapleStory.gg
- dir: `maplestory-gg` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `marble` — Marble
- dir: `marble` · commands: 8 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `markdown-preview` — Markdown Preview
- dir: `markdown-preview` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `markdown-reference` — Markdown Reference
- dir: `markdown-reference` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `markdown-table-generator` — Markdown Table Generator
- dir: `markdown-table-generator` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `mattermost` — Mattermost
- dir: `mattermost` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `maven-central-repository` — Maven Central Repository
- dir: `maven-central-repository` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `maxly-chat` — Maxly.chat
- dir: `maxly-chat` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `maybe` — Maybe
- dir: `maybe` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `memberstack` — Memberstack
- dir: `memberstack` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `metaphorpsum` — Metaphorpsum
- dir: `metaphorpsum` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `migadu` — Migadu
- dir: `migadu` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `mikrus` — Mikrus
- dir: `mikrus` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `minecast` — Minecast
- dir: `minecast` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `miniflux` — Miniflux
- dir: `miniflux` · commands: 5 · modes: view|no-view
- Degraded: declares background `interval` command(s) — not scheduled

### `minimax-ai` — MiniMax
- dir: `minimax-ai` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `minion-ipsum` — Minion Ipsum
- dir: `minion-ipsum` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `mistral` — Mistral
- dir: `mistral` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `mite` — Mite
- dir: `mite` · commands: 4 · modes: view|no-view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `mixpanel` — Mixpanel
- dir: `mixpanel` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `mnemosyne` — Mnemosyne
- dir: `mnemosyne` · commands: 2 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `monday-com` — monday.com
- dir: `monday` · commands: 4 · modes: view|no-view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `moneylover` — MoneyLover
- dir: `moneylover` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `mongodb-objectid` — MongoDB ObjectId
- dir: `mongodb-objectid` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `monobank` — monobank
- dir: `monobank` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `monse` — Monse - Banking In Raycast
- dir: `monse` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `multi` — Multi
- dir: `multi` · commands: 9 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `mutedeck` — MuteDeck
- dir: `mutedeck` · commands: 4 · modes: view|no-view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired)

### `mxroute` — MXroute
- dir: `mxroute` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `myidlers` — MyIdlers
- dir: `my-idlers` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `namesilo` — NameSilo
- dir: `namesilo` · commands: 7 · modes: view|no-view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `nanoid` — Generate Nanoid
- dir: `nanoid` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `nato-phonetic-alphabet` — NATO Phonetic Alphabet
- dir: `nato-phonetic-alphabet` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `near-rewards` — Near Rewards
- dir: `near-rewards` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `neon` — Neon
- dir: `neon` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `nepali-date-converter` — Nepali Date Converter
- dir: `nepali-date-converter` · commands: 1 · modes: no-view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `nextcloud` — Nextcloud
- dir: `nextcloud` · commands: 5 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `nextdns` — NextDNS
- dir: `nextdns` · commands: 4 · modes: view|no-view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `ngrok` — Ngrok
- dir: `ngrok` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `nhk-program-search` — NHK Program Search
- dir: `nhk-program-search` · commands: 4 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `nhl` — NHL
- dir: `nhl` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `nicnames` — NicNames
- dir: `nicnames` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `niuma-logs` — Niuma Logs
- dir: `niuma-logs` · commands: 3 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `nmbs-planner` — NMBS Planner
- dir: `nmbs-planner` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `nos-nieuws` — NOS Nieuws
- dir: `nos-news` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `notaday` — Notaday
- dir: `notaday` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `notion_researcher` — Notion Researcher
- dir: `notion_researcher` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `notra` — Notra
- dir: `notra` · commands: 6 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ns-nl-search` — Netherlands Railways Train Search
- dir: `ns-nl-search` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `nts-radio` — NTS Radio
- dir: `nts-radio` · commands: 7 · modes: no-view|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `number-research` — Number Research
- dir: `number-research` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `octoprint` — OctoPrint
- dir: `octoprint` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `olacv` — OlaCV
- dir: `olacv` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `one-tab-group` — One Tab Group
- dir: `one-tab-group` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ones` — ONES
- dir: `ones` · commands: 8 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `open_targets` — Open Targets
- dir: `open-targets-raycast` · commands: 5 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `open-graph` — Open Graph
- dir: `open-graph` · commands: 2 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `open-in-json-hero` — Open in JSON Hero
- dir: `open-in-json-hero` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `openrouter-manager` — OpenRouter Manager
- dir: `openrouter-manager` · commands: 4 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `outline-document-search` — Outline Document Search
- dir: `outline-document-search` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired)

### `ovhcloud` — OVHcloud
- dir: `ovh` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `package-tracker` — Parcel Tracker - 17track
- dir: `package-tracker` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `pagespeed` — Pagespeed
- dir: `pagespeed` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `pantheon-sites` — Pantheon Sites
- dir: `pantheon-sites` · commands: 2 · modes: view|no-view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `papago-translate` — Papago Translate
- dir: `papago-translate` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `parachord` — Parachord
- dir: `parachord` · commands: 12 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `password-link` — Password.link
- dir: `password-link` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `paste-as-plain-text` — Paste as Plain Text
- dir: `paste-as-plain-text` · commands: 1 · modes: no-view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares command `arguments[]` — not passed by runtime yet

### `pastery` — Pastery
- dir: `pastery` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `paymenter` — Paymenter
- dir: `paymenter` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `paypal-invoices` — PayPal Invoices
- dir: `paypal-invoices` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `phind-search` — Phind Search
- dir: `phind-search` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `pianoman` — Pianoman
- dir: `pianoman` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `pick-random-raycast-extension` — Pick Random
- dir: `pick-random` · commands: 3 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `pinch-svg` — Pinch SVG
- dir: `pinch-svg` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `planning-center-api-docs` — Planning Center API Docs
- dir: `planning-center-api-docs` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `plausible-analytics` — Plausible Analytics
- dir: `plausible-analytics` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `playback-duration-calculator` — Playback Duration Calculator
- dir: `playback-duration-calculator` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `playtester` — Playtester
- dir: `playtester` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `pocket` — Pocket
- dir: `pocket` · commands: 6 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `pocketbase` — PocketBase
- dir: `pocketbase` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `pokedex` — Pokédex
- dir: `pokedex` · commands: 8 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `polished` — Polished
- dir: `polished` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `porkbun` — Porkbun
- dir: `porkbun` · commands: 8 · modes: view|no-view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `port` — Port.io
- dir: `port` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `port-from-project-name` — Port from Project Name
- dir: `port-from-project-name` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `position-size-calculator` — Position Size Calculator
- dir: `position-size-calculator` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `posthog` — PostHog
- dir: `posthog` · commands: 5 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `postiz` — Postiz
- dir: `postiz` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `postman` — Postman
- dir: `postman` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `powertoys-tool-runner` — PowerToys Tool Runner
- dir: `powertoys-tool-runner` · commands: 13 · modes: no-view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `pretty-pr-link` — Pretty PR Link
- dir: `pretty-pr-link` · commands: 2 · modes: no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `primer` — Primer
- dir: `primer` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `prisma-docs-search` — Prisma Docs Search
- dir: `prisma-docs-search` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `productboard` — Productboard
- dir: `productboard` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `project-companion` — Project Companion
- dir: `project-companion` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `project-hub` — Project Hub
- dir: `project-hub` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `prompts-chat` — Prompts.chat
- dir: `prompts-chat` · commands: 5 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `prowlarr` — Prowlarr
- dir: `prowlarr` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `psn` — PSN
- dir: `psn` · commands: 3 · modes: no-view|view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; updateCommandMetadata: loads; no-op (command metadata updates not wired)

### `pubme` — PubMe Search
- dir: `pubme` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `pumble` — Pumble
- dir: `pumble` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `purelymail` — Purelymail
- dir: `purelymail` · commands: 11 · modes: view|no-view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `purpleair` — PurpleAir
- dir: `purpleair` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `pushover` — Pushover
- dir: `pushover` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `qonto` — Qonto
- dir: `qonto` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `query-chatgpt` — Query ChatGPT
- dir: `query-chatgpt` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `quick-web` — Quick Web
- dir: `quick-web` · commands: 6 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `quicklinker` — QuickLinker
- dir: `quicklinker` · commands: 2 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `quikwallet` — Quikwallet
- dir: `quikwallet` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `r-pkg-search` — Search R Packages
- dir: `r-pkg-search` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `radarr` — Radarr
- dir: `radarr` · commands: 7 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `rain-radars` — Rain Radars
- dir: `rain-radars` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `rateyourmusic-search` — Rate Your Music Search
- dir: `rateyourmusic-search` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ray-clicker` — Ray Clicker
- dir: `ray-clicker` · commands: 1 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `raycast-apple-intelligence` — Apple Intelligence
- dir: `raycast-apple-intelligence` · commands: 13 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `raycast-arcade` — Raycast Arcade
- dir: `raycast-arcade` · commands: 6 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `raycast-frc` — Raycast FRC
- dir: `raycast-frc` · commands: 4 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `raycast-lighting-node-search` — Search Lightning Nodes
- dir: `raycast-lighting-node-search` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `raycast-mux` — Mux.com
- dir: `raycast-mux` · commands: 6 · modes: no-view|view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `raycast-norwegian-public-transport` — Norwegian Public Transport
- dir: `norwegian-public-transport` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `raycast-notification` — Raycast Notification
- dir: `raycast-notification` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `raycast-sink` — Sink Short Links Manager
- dir: `raycast-sink` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired)

### `raycast-timeular` — Timeular
- dir: `timeular` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `raycast-timezone-converter` — Timezone Converter
- dir: `timezone-converter` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `raycast-urbandictionary-word-of-the-day` — Urban Dictionary Word of the Day
- dir: `raycast-urbandictionary-word-of-the-day` · commands: 3 · modes: no-view|view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `raycast-wca` — WCA
- dir: `raycast-wca` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `rebrandly` — Rebrandly
- dir: `rebrandly` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `recurly` — Recurly
- dir: `recurly` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `redis` — Redis
- dir: `redis` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `regex-repl` — RegEx REPL
- dir: `regex-repl` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `regex-tester` — Regex Tester
- dir: `regex-tester` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `rescuetime-focus-session-trigger` — RescueTime
- dir: `rescuetime-focus-session-trigger` · commands: 8 · modes: view|no-view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired)

### `reverso-context` — Reverso Context
- dir: `reverso-context` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `rewardful` — Rewardful
- dir: `rewardful` · commands: 4 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `roam-research` — Roam Research
- dir: `roam-research` · commands: 10 · modes: view|no-view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `rounding-number` — Rounding Number
- dir: `rounding-number` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `rtl-reader` — RTL Reader
- dir: `rtl-reader` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `runcloud` — RunCloud
- dir: `runcloud` · commands: 3 · modes: view|no-view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `sabnzbd` — SABnzbd
- dir: `sabnzbd` · commands: 8 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `sadaqah-box` — Sadaqah Box
- dir: `sadaqah-box` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `sav` — Sav
- dir: `sav` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `saved-items` — Saved Items
- dir: `saved-items` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `sayintentions` — SayIntentions
- dir: `sayintentions` · commands: 4 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `scheduler` — Command Scheduler
- dir: `scheduler` · commands: 4 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares background `interval` command(s) — not scheduled

### `schoology` — Schoology - Grade Viewer
- dir: `schoology` · commands: 2 · modes: view|no-view
- Degraded: declares background `interval` command(s) — not scheduled

### `scrapbook` — Scrapbook
- dir: `scrapbook` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `search-blockchain` — Search Blockchain
- dir: `search-blockchain` · commands: 13 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `search-domain` — Search Domain
- dir: `search-domain` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `search-gule-sider` — Search Gule Sider
- dir: `search-gule-sider` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `search-oeis` — Search OEIS
- dir: `search-oeis` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `sefaria` — Sefaria
- dir: `sefaria` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `sendportal` — SendPortal
- dir: `sendportal` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `sequoia-tiling` — Sequoia Window Tiling
- dir: `sequoia-tiling` · commands: 23 · modes: no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `sevalla` — Sevalla
- dir: `sevalla` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `sharding-tools` — Sharding Tools
- dir: `sharding-tools` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `share-my-code` — Share My Code
- dir: `share-my-code` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `shell-buddy` — Shell Buddy
- dir: `shell-buddy` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `shelve` — Shelve
- dir: `shelve` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `ship24-client` — Ship24 Package Tracker
- dir: `ship24-client` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `shodan` — Shodan
- dir: `shodan` · commands: 9 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `shortcut` — Shortcut
- dir: `shortcut` · commands: 5 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `shroud-email` — Shroud.email
- dir: `shroud-email` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `similarweb` — Similarweb
- dir: `similarweb` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `simple-dictionary` — Simple Dictionary
- dir: `simple-dictionary` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `simple-memo` — Simple Memo
- dir: `simple-memo` · commands: 3 · modes: view|no-view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `singularityapp` — SingularityApp
- dir: `singularityapp` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `solana-explorer` — Solana Explorer
- dir: `solana-explorer` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `solana-wallets-generation` — Solana Wallets Generation
- dir: `solana-wallets-generation` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `solidtime` — Solidtime
- dir: `solidtime` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `solusvm-2` — SolusVM 2
- dir: `solusvm-2` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `sonarr` — Sonarr
- dir: `sonarr` · commands: 9 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `spacer` — Spacer
- dir: `spacer` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; launchCommand: loads; throws if called (inter-command launch not wired)

### `spaceship` — Spaceship
- dir: `spaceship` · commands: 2 · modes: no-view|view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `speed-dial` — Speed Dial
- dir: `speed-dial` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `spinupwp` — SpinupWP
- dir: `spinupwp` · commands: 5 · modes: no-view|view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `splitwise` — Splitwise
- dir: `Splitwise` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `stacks` — Stacks
- dir: `stacks` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `stockholm-public-transport` — Stockholm Public Transport
- dir: `stockholm-public-transport` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `storybook-launcher` — Storybook Launcher
- dir: `storybook-launcher` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `stripe` — Stripe
- dir: `stripe` · commands: 16 · modes: view|no-view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `subwatch` — Subwatch
- dir: `subwatch` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `supermemory` — Supermemory
- dir: `supermemory` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `surf-check` — Surf Check
- dir: `surf-check` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `surl` — Surl
- dir: `surl` · commands: 2 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `swift-evolution` — Swift Evolution
- dir: `swift-evolution` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `swift-repl` — Swift REPL
- dir: `swift-repl` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `swiss-ov` — Swiss ÖV
- dir: `swiss-ov` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `synology-download-station` — Synology Download Station
- dir: `synology-download-station` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `t3-chat` — T3 Chat
- dir: `t3-chat` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `tally` — Tally
- dir: `tally` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `tana` — Tana
- dir: `tana` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `taskplane` — Taskplane
- dir: `taskplane` · commands: 3 · modes: view|no-view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `teamgantt` — TeamGantt
- dir: `teamgantt` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `texts` — Texts
- dir: `texts` · commands: 3 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `the-nobel-prize` — The Nobel Prize
- dir: `the-nobel-prize` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `thesvg` — TheSVG
- dir: `thesvg` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `time-logger` — Google Calendar Epic Time Logger
- dir: `time-logger` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `timecamp` — TimeCamp
- dir: `timecamp` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `toolbox` — ToolBox
- dir: `toolbox` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `trackflight` — Flight Tracker
- dir: `trackflight` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `tradingview-controls` — TradingView Controls
- dir: `tradingview-controls` · commands: 5 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `trenit` — Trenit
- dir: `trenit` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `tududi` — Tududi
- dir: `tududi` · commands: 5 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `tuneblade` — Tuneblade
- dir: `tuneblade` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `tuya-smart` — Tuya Smart
- dir: `tuya-smart` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `twitch-logs` — Twitch Logs
- dir: `twitch-logs` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `type-the-alphabet` — Type the Alphabet
- dir: `type-the-alphabet` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `typer` — Typer - Custom Text Hotkey
- dir: `typer` · commands: 5 · modes: no-view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired)

### `uk-bank-holidays` — UK Bank Holidays
- dir: `uk-bank-holidays` · commands: 2 · modes: view|no-view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled

### `ultrahuman` — Ultrahuman
- dir: `ultrahuman` · commands: 3 · modes: view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired)

### `unblocked-answers` — Unblocked Answers
- dir: `unblocked-answers` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `universal-inbox` — Universal Inbox
- dir: `universal-inbox` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `unkey` — Unkey
- dir: `unkey` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `unleash-feature-toggle` — Unleash Feature Toggle
- dir: `unleash-feature-toggle` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `unogs` — Unogs
- dir: `unogs` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `upstash` — Upstash
- dir: `upstash` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `uptime-robot` — UptimeRobot
- dir: `uptime-robot` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `urban-dictionary` — Urban Dictionary Search
- dir: `urban-dictionary` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `utc-workbench` — UTC Workbench
- dir: `utc-workbench` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `utm-campaign-builder` — UTM Campaign Builder
- dir: `utm-campaign-builder` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `uuid-generator` — UUID Generator
- dir: `uuid-generator` · commands: 9 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `vaib` — vAIb - Your AI Companion
- dir: `vaib` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `val-town` — Val Town
- dir: `val-town` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `vanguard-backup` — Vanguard Backup
- dir: `vanguard-backup` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `vanishlink` — Vanishlink
- dir: `vanishlink` · commands: 3 · modes: no-view|view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `vartiq` — Vartiq
- dir: `vartiq` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `vat-calculator` — VAT Calculator
- dir: `vat-calculator` · commands: 3 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `vatlayer` — vatlayer
- dir: `vatlayer` · commands: 6 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `verify-number` — Verify Number
- dir: `verify-number` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `vietqr-transfer` — VietQR Transfer Generator
- dir: `vietqr-transfer` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `virtualbox-power-switch` — VirtualBox Power Switch
- dir: `virtualbox-power-switch` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `volumio-control` — Volumio Control
- dir: `volumio-control` · commands: 10 · modes: no-view|view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `vultr` — Vultr
- dir: `vultr` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `web-audit` — Web Audit
- dir: `web-audit` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `web3-profile` — Web3 Profile
- dir: `web3-profile` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `webbites` — WebBites
- dir: `webbites` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `webhook-sender` — Webhook Sender
- dir: `webhook-sender` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `websocket-debugging` — Websocket Debugging
- dir: `websocket-debugging` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `whitebit` — WhiteBIT Exchange
- dir: `whitebit` · commands: 7 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `whois` — Whois
- dir: `whois` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `whosampled` — WhoSampled
- dir: `whosampled` · commands: 3 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `windmill` — Windmill
- dir: `windmill` · commands: 4 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `windows-default-wallpapers` — Windows Default Wallpapers
- dir: `windows-default-wallpapers` · commands: 1 · modes: view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `windows-domain` — Windows Domain
- dir: `windows-domain` · commands: 2 · modes: view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `windows-to-linux-path` — Windows to Linux Path
- dir: `windows-to-linux-path` · commands: 2 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `wled-controller` — WLED Controller
- dir: `wled-controller` · commands: 3 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `wolfram-alpha` — Wolfram Alpha
- dir: `wolfram-alpha` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `word-research` — Word Research
- dir: `word-research` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `wordle` — Wordle
- dir: `wordle` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `wordpress-manager` — WordPress Manager
- dir: `wordpress-manager` · commands: 9 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

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
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `yopass` — Yopass
- dir: `yopass` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `zacks-stock-ranking` — Zacks Stock Ranking
- dir: `zacks-stock-ranking` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `zeitraum` — Zeitraum
- dir: `zeitraum` · commands: 5 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `zendesk-admin` — Zendesk — Admin
- dir: `zendesk-admin` · commands: 2 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `zerodha-portfolio-kite-coin` — Zerodha Portfolio (Kite+Coin)
- dir: `zerodha-portfolio-kite-coin` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push

### `zipcodebase` — Zipcodebase
- dir: `zipcodebase` · commands: 8 · modes: view|no-view
- Degraded: updateCommandMetadata: loads; no-op (command metadata updates not wired); declares background `interval` command(s) — not scheduled; declares command `arguments[]` — not passed by runtime yet

### `zipper-run` — Run Zipper Applet
- dir: `zipper-run` · commands: 1 · modes: view
- Degraded: useNavigation: useNavigation().push/pop are no-ops; use declarative Action.Push; declares command `arguments[]` — not passed by runtime yet

### `zread-ai` — Zread.ai
- dir: `zread-ai` · commands: 2 · modes: no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

## SUPPORTED (889)

`2fa-directory`, `5devs`, `8-ball`, `aave-search`, `active-mississaugua`, `adguard-home`, `adonisjs-documentation`, `advice-slip`, `affine`, `ai-humanizer`, `aimlab`, `airplane`, `airport`, `airsy`, `airsync`, `aiven`, `aliyun-flow`, `alpinejs`, `amazon-search`, `analog-film-library`, `android-versions`, `anilist-airing-schedule`, `antisocials`, `anycoffee`, `apify`, `apis-guru-search`, `apple-books`, `apple-developer-docs`, `apple-devices`, `apple-stocks-search`, `arabic-keyboard`, `arc-helper`, `arca`, `archisteamfarm`, `array-this`, `ars-technica`, `arxiv`, `asoiaf`, `asyncapi`, `axios-docs`, `background-sounds`, `bahn-info`, `balatro-compendium`, `banca-d-italia-currency-converter`, `base-ui-docs`, `bash-commands`, `battery-health`, `bazinga-tools`, `bbc-news-headlines`, `beancount-meta`, `beat-per-minute`, `berlin-public-transportation`, `betaseries`, `biaodian`, `big-o`, `bilibili-search`, `bing-search`, `binge-clock`, `bintools`, `bitaxe-status`, `bitbucket`, `bitbucket-search-self-hosted`, `bitrise`, `blockchain-gas-tracker`, `board-game-geek`, `bookstack`, `bored`, `botpress`, `braintick`, `brasileirao-serie-a`, `brave-search`, `brave-search-with-results`, `bring`, `bsr-entsorgung`, `bttv-emote`, `buildkite`, `bundesliga`, `bundlephobia-search`, `calendar`, `camper-calc`, `can-i-php`, `can-i-use`, `canvascast`, `capacities`, `capture`, `carbon-code-screenshot-for-raycast`, `catenary-raycast`, `catppuccin`, `cc0-lib`, `ccf-what`, `ccfddl`, `chainscout`, `change-scroll-direction`, `chatbase`, `chatgpt3-prompt`, `cheatsheets`, `check-citi-bike-availability`, `chess-com`, `chhoto`, `chinese-character-converter`, `chinese-lottery`, `chinese-numbers`, `choose-a-license`, `chords-and-tabs`, `chuck-norris-facts`, `cilium-docs`, `cinemas-nos`, `citation-generator`, `cl-indicators`, `clarify`, `claude-code-cheatsheet`, `clean-agent-text`, `clear-clipboard`, `climbing-grade-converter`, `clipboard-editor`, `clipboard-formatter`, `clipboard-sequential-paste`, `clipboard-type`, `clipboard-utilities`, `close-finder`, `cocoa-core-data-timestamp-converter`, `coda-bookmarks-search`, `code-review-emojis`, `code-smells`, `codemagic`, `codesnap`, `coin-caster`, `coinbase-pro`, `coingecko`, `coinpaprika`, `collected-notes`, `comma-separator`, `commercequest`, `commit-issue-parser`, `commit-message-generator`, `commitlint`, `consoledev`, `control-d`, `control-viscosity`, `conventional-commits`, `converter`, `copy-skeet-link`, `country-lookup`, `cpf-cnpj-generator`, `cran-e-search`, `cratecast`, `crisp`, `cron-description`, `crunchbase`, `crypto-search`, `css-calculations`, `css-gg`, `css-tricks`, `cuid-generator`, `curator-bio`, `cursor`, `cursors`, `curto-io-url-shortener`, `customer-io`, `cypress-docs`, `dad-jokes`, `daisyui`, `daminik`, `dashlane`, `date-converter`, `dbt-documentation`, `dbtcloud`, `decentraland`, `deduplicator`, `defichain-dobby`, `definitelytyped`, `defiscan`, `dekudeals`, `deployhq`, `design-skills`, `designer-excuses`, `designer-news`, `deutscherwetterdienst`, `devcontainer-features`, `developer-excuse`, `devenv-docs`, `dex-screener`, `dexcom-reader`, `dice-tiles`, `digitalocean`, `directus`, `discogs`, `disney`, `distraction-tracker`, `djangopackages`, `dns-lookup`, `dockerhub`, `dog-images`, `dollar-blue`, `domainr`, `donut`, `dotnet-api-browser`, `dotnet-docs-search`, `dotween-eases`, `douban`, `dpm-lol`, `dr-news`, `dribbble`, `drug-search`, `drupal-org`, `duck-duck-go-search`, `duckduckgo-email`, `dutch-article`, `dynamic-font-size`, `e18e-module-replacements`, `early-tools-news`, `ebird`, `ecosia-search`, `ekstraklasa`, `elixir`, `elm-search`, `elron`, `ember-api-documentation`, `emissions-calculator`, `endel`, `ens-name-lookup`, `envoyer`, `epoch-to-timestamp`, `escape-regexp-characters`, `espn`, `esports-pass`, `esv-bible`, `evil-insult`, `evm-codes`, `excel-formula-beautifier`, `exivo`, `facetime`, `fake-swedish-personal-number`, `fantasy-premier-league-rankings`, `farcaster`, `fastmail-masked-email`, `fathom-analytics`, `fbi`, `feedly`, `fhir`, `fibonacci-sequence`, `figma-learn-companion`, `figma-shortcuts`, `filament`, `file-tree-generator`, `fillerama`, `finary`, `fingertip`, `finnish-dictionary`, `fluctuation`, `fluent-outdoors`, `flux`, `flycheck-raycast`, `flypy`, `font-awesome`, `forgejo`, `format-graphql`, `framer-motion`, `frankerfacez`, `freshrss`, `fuelx`, `game-scout`, `gcp-search`, `geist-ui-components`, `geoconverter`, `geoguesser`, `geohash-encode-decode`, `get-cat-images`, `get-direct-link`, `ghost-docs`, `gift-stardew-valley`, `git-branch-name-generator`, `git-commands`, `gitee`, `github-cli-manual`, `github-profile`, `github-spark`, `github-users`, `gitlab-docs`, `gitmoji`, `gleam-packages`, `glide`, `glyph-search`, `go-links`, `go-package-search`, `golden-ratio`, `gomander`, `google-advanced-search`, `google-finance`, `google-fonts`, `google-meet`, `google-scholar`, `google-trends`, `gotify`, `gradle-plugins`, `grafana`, `graphcdn`, `grokipedia`, `groundhog-day`, `growthbook`, `habr-media`, `hashnode`, `hatena-bookmark`, `hazeover`, `headlines`, `helldivers2`, `hellonext-changelogs`, `helm-docs`, `hemolog`, `heroicons`, `hetrixtools`, `hexlify`, `hide-all-apps`, `hide-mail`, `holodex`, `homepage`, `hoogle`, `hostloc`, `hsdecks`, `html-colors`, `http-dot-cat`, `http-mime`, `hubspot`, `hugging-face`, `humaans`, `hupu`, `hyper-focus`, `iata-code-decoder`, `icd10-lookup`, `iching-divination`, `icloud-global-pricing-comparison`, `ifanr`, `image-diff-checker`, `image-host`, `in-the-time-zone`, `incognito-clone`, `inertiajs-documentation`, `initium`, `inpost-parcel-lockers`, `instapaper`, `intention-clarifier`, `ios-resolution`, `ipa-translator`, `ipcheck-ing`, `iptv`, `is-it-toxic-to`, `isdown`, `itch-io`, `james-webb-space-telescope`, `jira-time-tracking`, `jisho`, `jitsi`, `jotform`, `json-editor`, `json-to-go`, `json2ts`, `jue-jin`, `jurassic-ninja-site-generator`, `just-delete-me`, `justcolorpicker-raycast`, `kaalam`, `kagi-news`, `kagi-search`, `kalshi`, `kaomoji-search`, `keeper-security`, `keychain-password-gen`, `kimi-for-coding`, `kind-words`, `kindle-paste`, `kinopoisk`, `kubernetes`, `kubernetes-docs`, `laby-net`, `laliga`, `laracasts`, `laravel-livewire`, `laravel-nova`, `laravel-shift`, `laravel-vapor`, `large-type`, `lark`, `lark-applink`, `latex-math-symbols`, `launchdarkly`, `lazygit-keybindings`, `leetcode`, `lego-bricks`, `leitnerbox`, `lemon-squeezy`, `lenscast`, `letta`, `lgtmeow`, `liba-ro_shortener`, `lichess-org`, `lifx`, `lifx-advanced-controller`, `lightdash-navigator`, `ligue-1`, `linguee`, `linux-command`, `liquipedia-matches`, `llm-stats`, `llms-txt`, `lobehub-icons`, `lobsters`, `lotr`, `lucide-animated`, `lume`, `lunatask`, `lyrics`, `mac-app-store-search`, `macrumors`, `macstories`, `macupdater`, `magic-home`, `mail-to-self`, `mailerlite-stats`, `mailtrap`, `make-dot-com`, `make-with-notion-2024`, `mandarin-chinese-dictionary`, `manga-calendar`, `manus`, `manus-manager`, `markdown-converter`, `markdown-this`, `markdown-to-plain-text`, `markdown-to-rich-text`, `markprompt`, `math-functions`, `matter`, `mbta-tracker`, `md-to-excel`, `mem`, `mem0`, `mempool`, `mercado-libre`, `metacritic`, `metaphor`, `meteoblue-lookup`, `metube`, `microblog`, `microsoft-teams-calling`, `midas`, `minecraft-color-codes`, `minecraft-crafting-recipes`, `minisim`, `mittwald`, `mobius-materials`, `mochi`, `modrinth`, `modrinth-search`, `moji`, `monkeytype`, `monocle`, `mousehunt-helper`, `mui-documentation`, `multipass`, `multiviewer`, `music-news`, `music-timer`, `musicbrainz`, `musicthread`, `must`, `mymind`, `mynaui-icons`, `namecheap`, `namuwiki`, `nano-games`, `nasa`, `nativebase-docs`, `nature-remo`, `navidrome`, `nba-game-viewer`, `neodb`, `nepali-calendar`, `netease-music`, `netnewswire`, `neurooo-translate`, `new-relic`, `new-york-times`, `next-lens`, `next-run`, `nfl-information`, `nft-search`, `nif`, `nif-fresquinho`, `nixpkgs-search`, `nl-news-headlines`, `no-as-a-service`, `node-js-evaluate`, `nordic-energy-prices`, `nostr`, `notilight-controller`, `novu`, `nowplaying-cli`, `nsis-reference`, `nts`, `nu-nieuws`, `nuget`, `number-facts`, `numpad`, `nyc-train-tracker`, `nzbget`, `octopus-energy`, `odin`, `odoo-companion`, `office-quotes`, `oh-my-zsh-git-alias`, `ohdear`, `ohmyzsh-plugins`, `oklch-color-converter`, `oktasearch`, `ollama-mind-map-generator`, `olympic-games`, `omni-news`, `onelook-thesaurus`, `open-gem-documentation`, `open-latest-url-from-clipboard`, `open-props`, `openrouter-model-search`, `openweathermap`, `opsgenie`, `orbita`, `orion`, `osrs-wiki`, `ossinsight`, `owledge-raycast`, `owncloud`, `ozbargain-deals`, `pagerduty`, `palette-colors`, `pandas-documentation-search`, `papersize`, `paperspace`, `parabol`, `parcel-tracker`, `parse`, `password-generator`, `paste-from-apple-books`, `pastebin`, `pastefy`, `pbr-assistant`, `penpot`, `personio`, `pestphp-documentation`, `phare-io-uptime`, `phonetic-typing`, `phosphor-icons`, `php-docs`, `php-toolbox`, `pinia-docs`, `pitchfork`, `pkg-swap`, `planning-center`, `playwright-docs`, `plex`, `ploi`, `pm2`, `podcasts`, `pokemon-tcg-pocket-binder`, `polars-documentation-search`, `pollen-count`, `polymarket`, `portal-wholesale`, `portuguese-primeira-liga`, `potter-db`, `premier-league`, `prettier`, `prisma-cli-commands`, `prisma-postgres`, `protobuf2typescript`, `proton-version`, `protondb`, `proxmox`, `pub-dev`, `public-bug-bounty-and-vulnerability-disclosure-programs`, `publico`, `publora`, `pulsemcp`, `px-to-rem-converter`, `qotp`, `qovery`, `qq-music-controls`, `query-domains`, `quick-access-for-zeroheight`, `quick-access-infomaniak`, `quick-event`, `quickfile`, `quicksnip`, `quicktime`, `quicktype`, `quoterism-raycast`, `radicle`, `rae-dictionary-raycast`, `rails-routes`, `railway`, `rainaissance`, `ramda-documentation`, `random`, `random-date-generator`, `random-email`, `random-password-generator`, `random-us-phone-number`, `ratio-calculator`, `raycafe`, `raycast-clip`, `raycast-datadog`, `raycast-diki`, `raycast-fly`, `raycast-ios-hig`, `raycast-kozip-extension`, `raycast-manual`, `raycast-nrm`, `raycast-ordbokene`, `raycast-textlint-rule-aws-service-name`, `raycast-translate-ge`, `raycast-weekly-newsletter`, `raycast-wemo`, `raytyping`, `rdir`, `rdw-kentekencheck`, `re-mind`, `react-native-directory`, `reading-time`, `readwise`, `readymetrics`, `recap`, `reddit-search`, `redirect-trace`, `redmine`, `refresh-wifi`, `rehooks`, `reka-ui`, `remove-window-from-set`, `render`, `repology-search`, `resmo`, `retool-documentation`, `rewiser`, `rg-adguard-links`, `ricescore`, `rick-and-morty`, `ring-intercom`, `risk-reward-calculator`, `rize-io-sessions`, `roblox-creator-docs`, `rocket-chat`, `roll-d20`, `rollcast`, `rollup-wtf`, `rule-of-three`, `ruler`, `rusbase`, `rust-docs`, `safe-secret`, `sage-hr`, `sanity`, `sat-scorer`, `save-to-cubox`, `savvycal`, `scaleway`, `screen-studio`, `screenocr`, `screenpipe`, `seafile`, `search-ansible-documentation`, `search-astro-docs`, `search-clojuredocs`, `search-composer-packagist`, `search-github-stars`, `search-hex`, `search-justwatch`, `search-mdn`, `search-npm`, `search-regexp`, `search-rubygems`, `search-shopify-liquid-documentation`, `search-with-algolia`, `sec-filings-search`, `security-search`, `semantic-scholar`, `sendy`, `sentry`, `serie-a`, `serverless-framework-docs`, `shadcn-svelte`, `shadcn-ui`, `shadcn-vue`, `shakespearify`, `shiori`, `shlink`, `shopify-dev-docs-search`, `shopify-developer-changelog`, `shopify-theme-resources`, `sidecar-connect`, `signal`, `simple-login`, `simplebackups`, `simplelogin`, `smallpdf`, `sniffer`, `solusvm-1-client`, `sonu-stream`, `sound-search`, `spatie-documentation`, `speedcubing`, `spell`, `splatoon`, `splix`, `spoqify`, `spotify-beta`, `spryker-docs`, `sql-reference-search`, `squeeze`, `st-andrews-main-library-occupancy`, `stagehand`, `starling`, `stashpad-docs`, `statamic-docs`, `steam-player-counts`, `stock-lookup`, `stock-tracker`, `stoicquotes`, `storyblok`, `storybook-search`, `storytime`, `strapi-raycast-extension`, `strftime-cheatsheet`, `string-formatter`, `substack`, `supabase`, `supabase-docs`, `surfs-up`, `surge-outbound-switcher`, `svga-player`, `swift-package-index`, `swiss-train-times`, `switch-game-play-history`, `switchhosts`, `syntax-fm`, `table-converter`, `tableau-navigator`, `tabletop-dice-roller`, `tabnews`, `tailwind-size-conversion`, `tallinn-transport`, `tana-paste`, `tarot`, `tautulli`, `tc-no-generator`, `teamup-rooms`, `techcrunch`, `tempo`, `temporary-email`, `tennis-standings`, `terminal`, `terraform-doc`, `tesla`, `teslamate`, `tex2typst`, `the-matrix-of-destiny`, `the-noble-quran`, `the-verge`, `thermoconvert`, `thingiverse`, `thrasher-magazine`, `threads-video-downloader`, `tibia-helper`, `time`, `time-calculator`, `time-converter`, `time-until-i-do`, `tints-and-shades`, `tiny-tycho`, `tinyfaces-nft`, `tldr`, `toggle-fn`, `toggle-grayscale`, `ton-address`, `transform`, `translit`, `transmit`, `trello`, `trustmrr`, `truth-or-dare`, `tscheck-in`, `tunnelblick`, `tuple`, `tv-remote`, `tv2---denmark`, `tw-colorpicker`, `twingate`, `twitch-chat`, `twitter-trendscast`, `twos`, `tyme-3-time-tracker`, `tynyfy`, `type-snob`, `typeform`, `typescript-documentation-search`, `typescript-mock-generator`, `typst-symbols`, `typst-universe`, `udemy-coupons`, `ulid`, `unify-path-separator`, `unirate-currency`, `unitex`, `universities`, `unix-timestamp`, `unix-timestamp-converter`, `unsure-calc`, `untis`, `upcoming-holidays`, `uplabs`, `uptime-kuma`, `url-parse`, `url-tools`, `useless-facts`, `usememos`, `v2ex`, `v2ex-viewer`, `v2raya-control`, `valheim-wiki`, `valkey-commands-search`, `valorant-esports`, `vant-documentation`, `vc-ru-news`, `veganify-application`, `vietnamese-calendar`, `vim-bro`, `virtfusion`, `virtualizor-enduser`, `viscosity`, `vision-directory`, `visitor-queue`, `vocab`, `vocabula-lat`, `voicenotes`, `vue-router-docs`, `vuejs-documentation`, `vuetify-docs`, `vueuse-functions`, `wcag`, `web-converter`, `web3bio`, `webkit-developer-docs`, `what-happened-today`, `where-is-my-cursor`, `who-is-off-today`, `wiggle-text`, `wistia`, `woo-marketplace-search`, `wordpress-icon-finder`, `wordpress-plugins`, `workflowy-inbox`, `world-cup`, `wp-cli-command-explorer`, `wrike`, `xbox-friends`, `xid`, `xkcd`, `xkcd-password-generator`, `xqc`, `yamli`, `yandex-music`, `yazio-tracker`, `yield-calculator`, `you-com-search`, `youform`, `yourls`, `youtube-companion`, `youtube-music`, `youversion-suggest`, `yr-weather-forecast`, `yu-gi-oh-card-lookup`, `za-fake-id-number-generator`, `zalgo-text`, `zefix`, `zenblog`, `zendesk`, `zerossl`, `zo-raycast`, `zod-documentation`, `zodme`, `zoom-meeting-control`, `zyntra`
