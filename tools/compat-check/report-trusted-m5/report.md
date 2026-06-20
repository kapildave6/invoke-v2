# Invoke v2 — Raycast extension compatibility report

- **Root scanned:** `/Users/test/Documents/code/extensions/extensions`
- **Mode:** trusted (unsandboxed)
- **Extensions found:** 2961

## Summary

| Status | Count | % |
|---|---:|---:|
| SUPPORTED | 2323 | 78.5% |
| DEGRADED | 631 | 21.3% |
| UNSUPPORTED | 7 | 0.2% |

## Top gaps (extensions blocked/degraded per missing capability)

| Capability | Extensions affected |
|---|---:|
| uses Node built-ins | 574 |
| BrowserExtension | 47 |
| useExec | 42 |
| runPowerShellScript | 18 |
| namespace import of @raycast/api | 7 |
| Clipboard.types | 1 |
| LocalStorage.removeAllItems | 1 |
| Action.InstallMCPServer | 1 |

## UNSUPPORTED (7)

### `apple-passwords` — Apple Password
- dir: `apple-passwords` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, module
- Needs review: namespace import of @raycast/api (member usage unverified)

### `comet` — Comet
- dir: `comet` · commands: 7 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process
- Needs review: namespace import of @raycast/api (member usage unverified)

### `craftdocs` — Craft
- dir: `craftdocs` · commands: 4 · modes: view
- Needs review: namespace import of @raycast/api (member usage unverified)

### `google-chrome` — Google Chrome
- dir: `google-chrome` · commands: 10 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process
- Needs review: namespace import of @raycast/api (member usage unverified)

### `invisible-text-detector` — Invisible Text Detector
- dir: `invisible-text-detector` · commands: 3 · modes: view|no-view
- Needs review: namespace import of @raycast/api (member usage unverified)

### `mozilla-vpn` — Mozilla VPN Connect
- dir: `mozilla-vpn` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, https, http
- Needs review: namespace import of @raycast/api (member usage unverified)

### `obsidian-link-opener` — Obsidian Link Opener
- dir: `obsidian-link-opener` · commands: 3 · modes: view
- Needs review: namespace import of @raycast/api (member usage unverified)

## DEGRADED (631)

### `1-click-confetti` — 1-Click Confetti
- dir: `1-click-confetti` · commands: 2 · modes: menu-bar|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `1bookmark` — 1Bookmark
- dir: `1bookmark` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `1password` — 1Password
- dir: `1password` · commands: 4 · modes: view|no-view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `ableton-live` — Ableton Live
- dir: `ableton-live` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `adb` — Android Debug Bridge (Adb) Commands
- dir: `adb` · commands: 20 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `advanced-speech-to-text` — Advanced Speech to Text
- dir: `advanced-speech-to-text` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `aerospace` — Aerospace Tiling Window Manager
- dir: `aerospace` · commands: 5 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `ag-audioflow` — AG AudioFlow
- dir: `ag-audioflow` · commands: 11 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `agent-client-protocol` — Agent Client Protocol
- dir: `agent-client-protocol` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `agent-usage` — Agent Usage
- dir: `agent-usage` · commands: 2 · modes: view|menu-bar
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): module, child_process, http, https

### `ai-agency` — AI Agency
- dir: `ai-agency` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `ai-git-assistant` — AI Git Assistant
- dir: `ai-git-assistant` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `alacritty` — Alacritty
- dir: `alacritty` · commands: 4 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `align-rtl` — Align RTL
- dir: `align-rtl` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `alist-downloder` — AList Downloder
- dir: `alist-downloder` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `android` — Android
- dir: `android` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `android-screen-capture` — Android Screen Capture
- dir: `android-screen-capture` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `animated-window-manager` — Animated Window Manager
- dir: `animated-window-manager` · commands: 4 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `annotely` — Annotely
- dir: `annotely` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, http

### `anonaddy` — Addy
- dir: `anonaddy` · commands: 5 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `antigravity` — Antigravity
- dir: `antigravity` · commands: 6 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, http

### `apfel` — Apfel
- dir: `apfel` · commands: 13 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `app-keeper-manager` — App Keeper Manager
- dir: `app-keeper-manager` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `app-tag-manager` — App Tag Manager
- dir: `app-tag-manager` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `app-updates` — App Updates
- dir: `app-updates` · commands: 4 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `appcleaner` — App Cleaner
- dir: `appcleaner` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `append-to-file` — Append Text to File
- dir: `append-to-file` · commands: 5 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `apple-photos` — Apple Photos
- dir: `apple-photos` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `apple-reminders` — Apple Reminders
- dir: `apple-reminders` · commands: 7 · modes: view|menu-bar|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `ascii-art-wallpaper` — ASCII Art Wallpaper
- dir: `ascii-art-wallpaper` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `asset-catalog-extractor` — Asset Catalog Extractor
- dir: `asset-catalog-extractor` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `at-profile` — @ Profile
- dir: `at-profile` · commands: 6 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `audio-device` — Set Audio Device
- dir: `audio-device` · commands: 12 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `awesome-mac` — Awesome Mac
- dir: `awesome-mac` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `aws` — Amazon AWS
- dir: `amazon-aws` · commands: 19 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `azure-tts-raycast` — Azure Speech TTS
- dir: `azure-tts-raycast-extension` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `backlog-md-manager` — Backlog.md Manager
- dir: `backlog-md-manager` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `bamboo-self-hosted` — Bamboo Search (Self Hosted)
- dir: `bamboo-search-self-hosted` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `barcuts-companion` — BarCuts Companion
- dir: `barcuts-companion` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `bark` — Bark
- dir: `bark` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `battery-menubar` — Battery Menu Bar
- dir: `battery-menubar` · commands: 1 · modes: menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `battery-optimizer` — Battery Optimizer
- dir: `battery-optimizer` · commands: 5 · modes: view|no-view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `bento-me` — Bento
- dir: `bento-me` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `betteraudio` — BetterAudio
- dir: `betteraudio` · commands: 17 · modes: view|no-view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `betterdisplay` — BetterDisplay
- dir: `betterdisplay` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `bettertouchtool` — BetterTouchTool
- dir: `bettertouchtool` · commands: 2 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `bibmanager` — Bibmanager
- dir: `bibmanager` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, readline

### `bilibili` — Bilibili
- dir: `Bilibili` · commands: 5 · modes: view|no-view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads); uses Node built-ins (ok in trusted mode): child_process

### `bird` — Bird
- dir: `bird` · commands: 4 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `bitwarden` — Bitwarden Vault
- dir: `bitwarden` · commands: 11 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): child_process, http, https

### `blip-raycast` — Blip
- dir: `blip-raycast` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `blurhash` — BlurHash
- dir: `blurhash` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `bonjour` — Bonjour
- dir: `bonjour` · commands: 2 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `brave` — Brave
- dir: `brave` · commands: 5 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `brew` — Brew
- dir: `brew` · commands: 6 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `brightness-control` — Brightness Control
- dir: `brightness-control` · commands: 4 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `browser-ai` — Browser AI Companion
- dir: `browser-ai` · commands: 5 · modes: no-view|view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `browser-history` — Browser History
- dir: `browser-history` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `browsers-profiles` — Open Browsers Profiles
- dir: `browsers-profiles` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `brreg` — The Brønnøysund Register Centre Search
- dir: `brreg` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `bunch` — Bunch
- dir: `bunch` · commands: 9 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `calibre-library` — Calibre Library
- dir: `calibre-search` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `caltask` — CalTask
- dir: `caltask` · commands: 4 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `capture-raycast-metadata` — Capture Raycast Metadata
- dir: `capture-raycast-metadata` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `caschys-blog` — Caschys Blog
- dir: `caschys-blog` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `ccusage` — Claude Code Usage (ccusage)
- dir: `ccusage` · commands: 3 · modes: view|menu-bar|no-view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process, http

### `cerebras` — Cerebras
- dir: `cerebras` · commands: 8 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): http

### `certificate-viewer` — Certificate Viewer
- dir: `certificate-viewer` · commands: 2 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): tls

### `chatgpt` — ChatGPT
- dir: `chatgpt` · commands: 10 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): http, child_process

### `chiikawa-character` — Chiikawa Characters
- dir: `chiikawa-character` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `claude-code-config-switcher` — Claude Code Switcher
- dir: `claude-code-config-switcher` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `claude-code-launcher` — Claude Code Launcher
- dir: `claude-code-launcher` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `claude-sessions` — Claude Sessions
- dir: `claude-sessions` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `claudecast` — ClaudeCast
- dir: `claudecast` · commands: 10 · modes: view|no-view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process, readline

### `clean-keyboard` — Clean Keyboard
- dir: `clean-keyboard` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `cleanshotx` — CleanShot X
- dir: `cleanshotx` · commands: 23 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `cling` — Cling File Search
- dir: `cling` · commands: 2 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `clippyx` — CLIPPyX
- dir: `clippyx` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `close-apps` — Close All Open Apps
- dir: `close-apps` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `cloudflare-warp` — Cloudflare WARP
- dir: `cloudflare-warp` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `cmux` — cmux
- dir: `cmux` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `code` — Code Execution
- dir: `code-execution` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `code-quarkus` — Code Quarkus
- dir: `code-quarkus` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `code-runway` — Code Runway
- dir: `code-runway` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `code-saver` — Code Saver
- dir: `code-saver` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `code-wiki` — Code Wiki
- dir: `code-wiki` · commands: 2 · modes: no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `codegrepper` — Code Grepper
- dir: `codegrepper` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `codex-manager` — Codex Manager
- dir: `codex-manager` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `coffee` — Coffee
- dir: `coffee` · commands: 9 · modes: no-view|view|menu-bar
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `colima` — Colima
- dir: `colima` · commands: 5 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `comodoro` — Comodoro
- dir: `comodoro` · commands: 3 · modes: menu-bar|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `compress-pdf` — Compress PDF
- dir: `compress-pdf` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `compressx` — Compresto
- dir: `compressx` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `connect-to-vpn` — Connect to VPN
- dir: `connect-to-vpn` · commands: 3 · modes: no-view|view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `convert-3d-models` — Convert 3D Models
- dir: `convert-3d-models` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `copy-text-files` — Copy Text Files
- dir: `copy-text-files` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `copyq-clipboard-manager` — CopyQ Clipboard Manager
- dir: `copyq-clipboard-manager` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `crawldoc` — CrawlDoc - Documentations Search Engine
- dir: `crawldoc` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `create-link` — Create Link
- dir: `create-link` · commands: 5 · modes: no-view|view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `croc-transfer` — Croc Transfer
- dir: `croc-transfer` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `cron-manager` — Cron Manager
- dir: `cron-manager` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `curl` — cURL
- dir: `curl` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `cursor-recent-projects` — Cursor
- dir: `cursor-recent-projects` · commands: 5 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `custom-folder` — Custom Folder
- dir: `custom-folder` · commands: 4 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `custom-icon` — Custom Icon
- dir: `custom-icon` · commands: 2 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `cut-out` — Cut Out
- dir: `cut-out` · commands: 2 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `daily-sites` — Daily Sites - Site Launcher
- dir: `daily-sites` · commands: 4 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `dash` — Dash
- dir: `dash` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `day-one` — Day One
- dir: `day-one` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `deepwiki` — DeepWiki
- dir: `deepwiki` · commands: 3 · modes: no-view|view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `default-web-browser-manager` — Default Web Browser Manager
- dir: `default-web-browser-manager` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `defbro` — Defbro
- dir: `defbro` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `dev-cache-cleaner` — Dev Cache Cleaner
- dir: `dev-cache-cleaner` · commands: 3 · modes: view|no-view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `dev-servers` — Dev Servers
- dir: `dev-servers` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `devpod` — DevPod
- dir: `devpod` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `dia` — Dia
- dir: `dia` · commands: 7 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `dict-cc` — dict.cc
- dir: `dict-cc` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `dictionary` — Web Dictionaries
- dir: `dictionary` · commands: 2 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `diff-view` — Diff View
- dir: `diff-view` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `dig` — Dig - DNS Lookup
- dir: `dig` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `digger` — Digger
- dir: `digger` · commands: 1 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): dns, tls

### `discussite` — Discussite
- dir: `discussite` · commands: 1 · modes: no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `disk-usage` — Disk Usage
- dir: `disk-usage` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, readline

### `diskutil` — Disk Utility
- dir: `diskutil` · commands: 2 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `diskutil-mac` — Diskutil
- dir: `diskutil-mac` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `display-input-switcher` — Display Input Switcher
- dir: `display-input-switcher` · commands: 3 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `displayplacer` — Display Placer
- dir: `displayplacer` · commands: 7 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `do-not-disturb` — Do Not Disturb
- dir: `do-not-disturb` · commands: 4 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `dock-tinker` — Dock Tinker
- dir: `dock-tinker` · commands: 12 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `dockit` — DocKit - Document Toolkit
- dir: `dockit` · commands: 3 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `docklock-plus` — DockLock Plus
- dir: `docklock-plus` · commands: 8 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `doorstopper` — Doorstopper
- dir: `doorstopper` · commands: 5 · modes: no-view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `dot-underscore-files-cleaner` — Dot Underscore Files Cleaner
- dir: `dot-underscore-files-cleaner` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `doubao-tts` — Doubao TTS
- dir: `doubao-tts` · commands: 4 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `downloads-manager` — Downloads Manager
- dir: `downloads-manager` · commands: 7 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `dropover` — Dropover
- dir: `dropover` · commands: 2 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `drupal-toolbox` — Drupal Toolbox
- dir: `drupal-toolbox` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `easy-ocr` — Easy OCR
- dir: `easy-ocr` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `easydict` — Easy Dictionary
- dir: `easydict` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `edgestore-raycast` — EdgeStore
- dir: `edgestore-raycast` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `elevenlabs-tts` — ElevenLabs TTS
- dir: `elevenlabs-tts` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `encoding-tools` — Encoding Tools
- dir: `encoding-tools` · commands: 7 · modes: no-view
- Degraded: Clipboard.types: missing @raycast/api method (TypeError)

### `ente-auth` — Ente Auth
- dir: `ente-auth` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `epim` — Entra PIM Role
- dir: `epim` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `espanso` — Espanso
- dir: `espanso` · commands: 5 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `esse-actions` — Esse Actions
- dir: `esse-actions` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `everything-search` — Everything
- dir: `everything-search` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https, child_process

### `exif` — Exif Viewer
- dir: `exif` · commands: 2 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `expand-video-canvas` — Expand Video Canvas
- dir: `expand-video-canvas` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `extend-display` — Extend Display
- dir: `extend-display` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `fake-typing-effect` — Fake Typing Effect
- dir: `fake-typing-effect` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `farrago` — Farrago
- dir: `farrago` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, dgram

### `fetch-youtube-transcript` — Fetch YouTube Transcript
- dir: `fetch-youtube-transcript` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `ffmpeg` — FFmpeg - View, Analyze and Manipulate
- dir: `ffmpeg` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `fifteen-million-merits` — Fifteen Million Merits
- dir: `fifteen-million-merits` · commands: 2 · modes: menu-bar|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `figma-link-cleaner` — Figma Link Cleaner
- dir: `figma-link-cleaner` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `file-info` — File Info
- dir: `file-info` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `file-manager` — File Manager
- dir: `file-manager` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `filemaker-snippets` — FileMaker Snippets
- dir: `filemaker-snippets` · commands: 7 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `files-shelf` — Files Shelf
- dir: `files-shelf` · commands: 5 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `filezilla` — FileZilla
- dir: `filezilla` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `finder-file-actions` — Finder File Actions
- dir: `finder-file-actions` · commands: 5 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `finderutils` — Finder Utilities
- dir: `finderutils` · commands: 2 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `finicky-rule-manager` — Finicky Rule Manager
- dir: `finicky-rule-manager` · commands: 3 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): child_process

### `fip` — Fip
- dir: `fip` · commands: 6 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `firefox-tabs` — Firefox Tabs
- dir: `firefox-tabs` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `fisher` — Fisher
- dir: `fisher` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `fitdesk` — FitDesk
- dir: `fitdesk` · commands: 4 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `fix-helper` — FIX Helper
- dir: `fix-helper` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `flashspace` — FlashSpace
- dir: `flashspace` · commands: 27 · modes: view|no-view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `flush-dns` — Flush DNS
- dir: `flush-dns` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `flutter-utils` — Flutter Utils
- dir: `flutter-utils` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `folder-organizer` — Folder Organizer
- dir: `folder-organizer` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `folder-search` — Folder Search
- dir: `folder-search` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `font-search` — Font Search
- dir: `font-search` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `font-sniper` — Font Sniper
- dir: `font-sniper` · commands: 1 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `foundry-cast-cli` — Foundry Cast CLI
- dir: `foundry-cast-cli` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `frame-crop-art` — Frame Crop - Discover Art for Your TV
- dir: `frame-crop` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `french-company-search` — French Company Search
- dir: `french-company-search` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `fuelix` — Fuelix
- dir: `fuelix` · commands: 16 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `fuzzy-file-search` — Fuzzy File Search
- dir: `fuzzy-file-search` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, readline

### `fvm` — FVM
- dir: `fvm` · commands: 4 · modes: view|no-view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `g-cloud` — Google Cloud CLI
- dir: `g-cloud` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `gcp-ip-search` — Google Cloud Platform IP Search
- dir: `gcp-ip-search` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `gemini-cli` — Gemini CLI
- dir: `gemini-cli` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): readline

### `gemini-tts` — Gemini TTS
- dir: `gemini-tts` · commands: 9 · modes: no-view|view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `geoping` — Geoping
- dir: `geoping` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `gerrit-code-review` — Gerrit Code Review
- dir: `gerrit-code-review` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): http, https

### `get-app-icon` — Get App Icon
- dir: `get-app-icon` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `getcompress` — GetCompress
- dir: `getcompress` · commands: 3 · modes: no-view|view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `getsound` — GetSound
- dir: `getsound` · commands: 3 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `ghostty` — Ghostty
- dir: `ghostty` · commands: 7 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `git` — Git
- dir: `git` · commands: 6 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `git-assistant` — Git Assistant
- dir: `git-assistant` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `git-batch-tools` — Git Batch Tools
- dir: `git-batch-tools` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `git-buddy` — Git Buddy
- dir: `git-buddy` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `git-co-authors` — Git Co-Authors
- dir: `git-co-authors` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `git-profile` — Git Profile
- dir: `git-profile` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `git-repos` — Git Repos
- dir: `git-repos` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `gitfox` — Gitfox Repositories
- dir: `gitfox` · commands: 3 · modes: view|menu-bar|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `github` — GitHub
- dir: `github` · commands: 20 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `gitignore` — Gitignore
- dir: `gitignore` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `gitlab` — GitLab
- dir: `gitlab` · commands: 24 · modes: view|menu-bar|no-view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `gles-to-malioc` — GLES to MaliOC
- dir: `gles-to-malioc` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `global-media-key` — Media Key Emulate
- dir: `global-media-key` · commands: 5 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `gmail-accounts` — Gmail Accounts
- dir: `gmail-accounts` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `google-chrome-profiles` — Google Chrome Profiles
- dir: `google-chrome-profiles` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `google-cloud-run` — Google Cloud Run
- dir: `google-cloud-run` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `google-drive` — Google Drive
- dir: `google-drive` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `google-lens` — Google Lens
- dir: `google-lens` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `gopass` — Gopass
- dir: `gopass` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `gpu-fleet-monitor` — GPU Fleet Monitor
- dir: `gpu-fleet-monitor` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `gram` — Gram
- dir: `gram` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `grpcui` — gRPC UI
- dir: `grpcui` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `guitar-tools` — Guitar Tools
- dir: `guitar-tools` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `hacker-news-top-stories` — Hacker News Top Stories
- dir: `hacker-news-top-stories` · commands: 1 · modes: menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `handoff-toggle` — Handoff Toggle
- dir: `handoff-toggle` · commands: 2 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `handy` — Handy
- dir: `handy` · commands: 9 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `harmonic` — Harmonic
- dir: `harmonic` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `harvest` — Harvest
- dir: `harvest` · commands: 6 · modes: view|no-view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `helium` — Helium
- dir: `helium` · commands: 6 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `hermes-agent` — Hermes Agent
- dir: `hermes-agent` · commands: 6 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, net

### `heroku` — Heroku
- dir: `heroku` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `hidden-icons` — Hidden Icons
- dir: `hidden-icons` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `hide-files` — Hide Files
- dir: `hide-files` · commands: 4 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `hiit` — HIIT
- dir: `hiit` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `hole-sandbox-launcher` — Hole Sandbox Launcher
- dir: `hole-sandbox-launcher` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `homeassistant` — Home Assistant
- dir: `homeassistant` · commands: 43 · modes: view|no-view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): https, child_process

### `hotcorner` — HotCorner
- dir: `hotcorner` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `http-status-codes` — HTTP Status Codes
- dir: `http-status-codes` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): http

### `httpperf` — HTTP Performance Analyzer
- dir: `httpperf` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `hue` — Hue
- dir: `hue` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): tls, https, net, http2, dns

### `hugeicons-ui` — Hugeicons UI
- dir: `hugeicons-ui` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `ideate` — Ideate
- dir: `ideate` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `idonthavespotify` — I Don't Have Spotify
- dir: `idonthavespotify` · commands: 10 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): https, child_process

### `ihosts` — iHosts
- dir: `ihosts` · commands: 3 · modes: view|menu-bar|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, https

### `imageoptim` — ImageOptim
- dir: `imageoptim` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `immich` — Immich
- dir: `immich` · commands: 3 · modes: view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `inbox-ai` — Inbox AI
- dir: `inbox-ai` · commands: 7 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): child_process

### `inoreader` — Inoreader
- dir: `inoreader` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `input-switcher` — Keyboard Layout Switcher
- dir: `keyboard-layout-switcher` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `ip-finder` — Ip Finder - Network Scanner
- dir: `ip-finder` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, dns

### `ip-geolocation` — IP Geolocation
- dir: `ip-geolocation` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): net

### `irish-rail` — Irish Rail
- dir: `irish-rail` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `iterm` — iTerm
- dir: `iterm` · commands: 11 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `itranslate` — iTranslate
- dir: `itranslate` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `ivpn` — IVPN
- dir: `ivpn` · commands: 12 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `iwork` — iWork
- dir: `iwork` · commands: 19 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `jellyamp` — Jellyamp
- dir: `jellyamp` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `jenkins` — Jenkins
- dir: `jenkins` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): http, https

### `jetbrains` — JetBrains Toolbox Recent Projects
- dir: `jetbrains` · commands: 2 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `jira-search-self-hosted` — Jira Search (Self-Hosted)
- dir: `jira-search-self-hosted` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `joey-vocab` — Joey Vocab
- dir: `joey-vocab` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `jump` — Jump
- dir: `jump` · commands: 4 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `karabiner-profile-switcher` — Karabiner Profile Switcher
- dir: `karabiner-profile-switcher` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `karakeep` — Karakeep
- dir: `karakeep` · commands: 11 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `kde-connect` — KDE Connect
- dir: `kde-connect` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `keepassxc` — KeePassXC
- dir: `keepassxc` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `keyboard-win-mac-switch` — Keyboard Win Mac Switch
- dir: `keyboard-win-mac-switch` · commands: 2 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `keyraycast` — KeyRaycast
- dir: `keyraycast` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `kill-mcp` — Kill MCP Servers
- dir: `kill-mcp` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `kill-process` — Kill Process
- dir: `kill-process` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `kiro` — Kiro
- dir: `kiro` · commands: 5 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `kitty` — Kitty
- dir: `kitty` · commands: 5 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `klack` — Klack
- dir: `klack` · commands: 10 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `kommand` — Kommand
- dir: `kommand` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `korean-add-calendar` — Korean Add Calendar
- dir: `korean-add-calendar` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `kubectx` — kubectx
- dir: `kubectx` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `kubens` — kubens
- dir: `kubens` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `laravel-tips` — Laravel Tips
- dir: `laravel-tips` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `laravel-valet` — Laravel Valet
- dir: `laravel-valet` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `lastpass` — LastPass Credentials Search
- dir: `lastpass` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `later` — Read Later
- dir: `later` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `lattice-scholar-extension` — Lattice Scholar Extension
- dir: `lattice-scholar-extension` · commands: 3 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `launch-agents` — Launch Agents
- dir: `launch-agents` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `launchd-monitor` — Launchd Monitor
- dir: `launchd-monitor` · commands: 1 · modes: menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `launchpad-plus` — Launchpad+
- dir: `launchpad-plus` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `leader-key` — Leader Key
- dir: `leader-key` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `lemniscate-system-monitor` — Lemniscate | System Monitor
- dir: `lemniscate-system-monitor` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `library-genesis` — Library Genesis
- dir: `library-genesis` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `linak-desk-controller` — Linak Desk Controller
- dir: `linak-controller` · commands: 4 · modes: no-view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `linak-desk-controller` — Linak Desk Controller
- dir: `linak-desk-controller` · commands: 4 · modes: no-view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `link-bundles` — Link Bundles
- dir: `link-bundles` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `linkace-search` — LinkAce Search
- dir: `linkace-search` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `localsend` — LocalSend
- dir: `localsend` · commands: 9 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): dgram, http

### `lock-time` — Lock Time
- dir: `lock-time` · commands: 3 · modes: view|no-view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `logitech-litra` — Logitech Litra
- dir: `logitech-litra` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `logos-launcher` — Logos Launcher
- dir: `logos-launcher` · commands: 10 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `looma-fm` — Looma.fm
- dir: `looma-fm` · commands: 4 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `looped` — Looped
- dir: `looped` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `lyric-fever-control` — Lyric Fever Control
- dir: `lyric-fever-control` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `mac-mouse-fix` — Mac Mouse Fix
- dir: `mac-mouse-fix` · commands: 8 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `mac-network-location-changer` — Mac Network Location Changer
- dir: `mac-network-location-changer` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `macos-tweaks` — macOS Tweaks
- dir: `macos-tweaks` · commands: 3 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `macosicons` — macOSIcons.com
- dir: `macosicons` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `macports` — MacPorts
- dir: `macports` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `magic-ingest` — Magic Ingest
- dir: `magic-ingest` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `mamp-utility` — MAMP Utility
- dir: `mamp-utility` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `man-pages` — Man Pages
- dir: `man-pages` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `markdown-navigator` — Markdown Navigator
- dir: `markdown-navigator` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `mcp` — Model Context Protocol
- dir: `mcp` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `media-converter` — Media Converter
- dir: `media-converter` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, module

### `memory` — Memory
- dir: `memory` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `mermaid-to-image` — Mermaid to Image
- dir: `mermaid-to-image` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `microsoft-edge` — Microsoft Edge
- dir: `microsoft-edge` · commands: 7 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `microsoft-office` — Microsoft Office
- dir: `microsoft-office` · commands: 3 · modes: view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads); uses Node built-ins (ok in trusted mode): child_process

### `migros` — Migros
- dir: `migros` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `minimax-tts` — MiniMax TTS
- dir: `minimax-tts` · commands: 10 · modes: no-view|view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `minio-manager` — Minio Manager
- dir: `minio-manager` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): http, https

### `mirror-displays` — Mirror Displays
- dir: `mirror-displays` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `mochi` — Mochi
- dir: `mochi` · commands: 1 · modes: view
- Degraded: LocalStorage.removeAllItems: missing @raycast/api method (TypeError)

### `moco` — MOCO
- dir: `moco` · commands: 3 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): http

### `model-context-protocol-registry` — Model Context Protocol Registry
- dir: `model-context-protocol-registry` · commands: 1 · modes: view
- Degraded: Action.InstallMCPServer: missing @raycast/api member (renders undefined → view crash); uses Node built-ins (ok in trusted mode): child_process

### `models-dev` — Models Dev
- dir: `models-dev` · commands: 7 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, v8

### `mole` — Mole
- dir: `mole` · commands: 10 · modes: view|menu-bar
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `monitor-mate` — MonitorMate
- dir: `monitor-mate` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): net, child_process

### `moodist` — Moodist
- dir: `moodist` · commands: 7 · modes: view|no-view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `morning-coffee` — Morning Coffee
- dir: `morning-coffee` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `mouse-jiggle` — Mouse Jiggle
- dir: `mouse-jiggle` · commands: 2 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `mozeidon` — Mozeidon
- dir: `mozeidon` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): readline, child_process

### `mozilla-firefox` — Mozilla Firefox
- dir: `mozilla-firefox` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `mullvad` — Mullvad VPN
- dir: `mullvad` · commands: 5 · modes: view|no-view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `multi-force` — MultiForce
- dir: `multi-force` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `music` — Music
- dir: `music` · commands: 26 · modes: no-view|view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `music-recognition` — Music Recognition
- dir: `music-recognition` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `mute-microphone` — Toggle Audio Input (Microphone)
- dir: `mute-microphone` · commands: 3 · modes: menu-bar|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `n8n` — n8n
- dir: `n8n` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `namespaces` — NameSpaces
- dir: `namespaces` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `netbird` — NetBird
- dir: `netbird` · commands: 7 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `netlify` — Netlify
- dir: `netlify` · commands: 7 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `network-diagnostics` — Network Diagnostics
- dir: `network-diagnostics` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): dns

### `network-drive` — Network Drive
- dir: `network-drive` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `network-menubar-monitor` — Network Menubar Monitor
- dir: `network-menubar-monitor` · commands: 1 · modes: menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `network-proxy` — Network Proxy
- dir: `network-proxy` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `network-speed` — Network Speed
- dir: `network-speed` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `night-light` — Night Light
- dir: `night-light` · commands: 4 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `nix-flake-templates` — Nix Flake Templates
- dir: `nix-flake-templates` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `node-version-manager` — Node Version Manager
- dir: `node-version-manager` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `notion-url-to-id` — Notion URL to ID
- dir: `notion-url-to-id` · commands: 2 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `notis` — Ask Notis
- dir: `notis` · commands: 3 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `now-playing` — Now Playing
- dir: `now-playing` · commands: 1 · modes: menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `npm-claimer` — npm Claimer
- dir: `npm-claimer` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `numi` — Numi
- dir: `numi` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, http

### `nuxt` — Nuxt
- dir: `nuxt` · commands: 6 · modes: no-view|view|menu-bar
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `obsidian` — Obsidian
- dir: `obsidian` · commands: 12 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `obsidian-bookmarks` — Obsidian Bookmarks
- dir: `obsidian-bookmarks` · commands: 3 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `office2pdf` — Office2PDF
- dir: `office2pdf` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `one-time-password` — One Time Password
- dir: `one-time-password` · commands: 1 · modes: view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads); uses Node built-ins (ok in trusted mode): child_process

### `onenote` — OneNote
- dir: `onenote` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `open-graph` — Open Graph
- dir: `open-graph` · commands: 2 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `open-in-android-studio` — Open in Android Studio
- dir: `open-in-android-studio` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `open-in-cursor` — Open in Cursor
- dir: `open-in-cursor` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `open-in-sublime-text` — Open in Sublime Text
- dir: `open-in-sublime-text` · commands: 2 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `open-in-textmate` — Open in TextMate
- dir: `open-in-textmate` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `open-in-trae` — Open in Trae
- dir: `open-in-trae` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `open-in-visual-studio-code` — Open in Visual Studio Code
- dir: `open-in-visual-studio-code` · commands: 1 · modes: no-view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `open-link-in-specific-browser` — Open Link in Specific Browser
- dir: `open-link-in-specific-browser` · commands: 3 · modes: view|menu-bar|no-view
- Degraded: uses Node built-ins (ok in trusted mode): net

### `open-path` — Open Path
- dir: `open-path` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `openai-speak` — OpenAI Speak
- dir: `openai-speak` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `openai-translator` — OpenAI Translator
- dir: `openai-translator` · commands: 8 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `opencode-sessions` — OpenCode Sessions
- dir: `opencode-sessions` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `openfortivpn` — Openfortivpn
- dir: `openfortivpn` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `openhue` — OpenHue
- dir: `openhue` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `openstreetmap-search` — OpenStreetMap Search
- dir: `openstreetmap-search` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `openvpn` — OpenVPN
- dir: `openvpn` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `opera` — Opera
- dir: `opera` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `orbstack` — OrbStack
- dir: `orbstack` · commands: 2 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `osint-web-check` — OSINT Web Check
- dir: `osint-web-check` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): dns, net, tls

### `owl` — Owl
- dir: `owl` · commands: 2 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `pantheon-sites` — Pantheon Sites
- dir: `pantheon-sites` · commands: 2 · modes: view|no-view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `paper-agent` — Paper Agent
- dir: `paper-agent` · commands: 11 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `parallels-virtual-machines` — Parallels Virtual Machines
- dir: `parallels-virtual-machines` · commands: 2 · modes: view|no-view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `parrot-translate` — Parrot Translate
- dir: `parrot-translate` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `pass` — Pass
- dir: `pass` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `password-store` — Password Store
- dir: `password-store` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `paste-safely` — Paste Safely
- dir: `paste-safely` · commands: 2 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `paste-to-markdown` — Paste to Markdown
- dir: `paste-to-markdown` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `performance-hud` — Metal Performance HUD
- dir: `performance-hud` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `petal` — Petal - Offline Voice to Text
- dir: `petal` · commands: 5 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `php-monitor` — PHP Monitor
- dir: `phpmon` · commands: 11 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `pia-controls` — Private Internet Access Controls
- dir: `pia-controls` · commands: 4 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `pick-your-wallpaper` — Pick Your Wallpaper
- dir: `pick-your-wallpaper` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `pie-for-pi-hole` — Pie for Pi-Hole
- dir: `pie-for-pihole` · commands: 16 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): http, https

### `pieces-raycast` — Pieces for Raycast
- dir: `pieces-raycast` · commands: 9 · modes: no-view|view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): child_process

### `ping` — Ping
- dir: `ping` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `ping-menu` — Ping Menu
- dir: `ping-menu` · commands: 1 · modes: menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `pins` — Pins
- dir: `pins` · commands: 8 · modes: menu-bar|view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): vm, child_process

### `pipe-commands` — Pipe Commands
- dir: `pipe-commands` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `playnite-launcher` — Playnite Launcher
- dir: `playnite-launcher` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `plexus` — Plexus - Localhost Search
- dir: `plexus` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, net

### `polidict` — Polidict
- dir: `polidict` · commands: 6 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `pomodoro` — Pomodoro
- dir: `pomodoro` · commands: 5 · modes: menu-bar|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `popicons` — Popicons
- dir: `popicons` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): dns

### `port-manager` — Port Manager
- dir: `port-manager` · commands: 4 · modes: no-view|view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `portless` — Portless Active Routes
- dir: `portless` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `ports` — Port Manager
- dir: `ports` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `positron` — Positron
- dir: `positron` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `power-management` — Power Management
- dir: `power-management` · commands: 5 · modes: view|no-view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `powertoys-tool-runner` — PowerToys Tool Runner
- dir: `powertoys-tool-runner` · commands: 13 · modes: no-view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `pretty-pr-link` — Pretty PR Link
- dir: `pretty-pr-link` · commands: 2 · modes: no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `prism-launcher` — Prism Launcher
- dir: `prism-launcher` · commands: 3 · modes: view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads); uses Node built-ins (ok in trusted mode): child_process

### `pritunl` — Connect Pritunl Vpn Tunnel
- dir: `pritunl` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `privileges` — Privileges
- dir: `privileges` · commands: 3 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `producthunt` — Product Hunt
- dir: `producthunt` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `projects` — Projects
- dir: `projects` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `promptlab` — PromptLab
- dir: `promptlab` · commands: 7 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `pronounce-the-word` — Pronounce the Word
- dir: `pronounce-the-word` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `proton-authenticator` — Proton Authenticator
- dir: `proton-authenticator` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `proton-pass` — Proton Pass
- dir: `proton-pass` · commands: 5 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): child_process

### `python` — Python
- dir: `python` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `qalc` — Qalccast
- dir: `qalc` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `qmd` — QMD
- dir: `qmd` · commands: 13 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `qoder` — Qoder
- dir: `qoder` · commands: 5 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `qr-code-scanner` — QR Code Scanner
- dir: `qr-code-scanner` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `qrcp` — QRCP
- dir: `qrcp` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): http

### `quarantine-manager` — Quarantine Manager
- dir: `quarantine-manager` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `quick-access` — Quick Access
- dir: `quick-access` · commands: 3 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `quick-git` — Quick Git
- dir: `quick-git` · commands: 2 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `quick-open-project` — Quick Open Project
- dir: `quick-open-project` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `quick-toshl` — Quick Toshl
- dir: `quick-toshl` · commands: 12 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `quit-applications` — Quit Applications
- dir: `quit-applications` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `qutebrowser-tabs` — Qutebrowser Tabs
- dir: `qutebrowser-tabs` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `r2-uploader` — Cloudflare R2 File Uploader
- dir: `r2-uploader` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `rabbit-hole` — Rabbit Hole
- dir: `rabbit-hole` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, https

### `radix` — Radix
- dir: `radix` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `raindrop-io` — Raindrop.io
- dir: `raindrop-io` · commands: 5 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `random-fart` — Random Fart
- dir: `random-fart` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `random-text-picker` — Random Text Picker
- dir: `random-text-picker` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `ray-code` — Ray Code
- dir: `ray-code` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `raycast-focus-stats` — Raycast Focus Stats
- dir: `raycast-focus-stats` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, https

### `raycast-gemini` — Google Gemini
- dir: `raycast-gemini` · commands: 16 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `raycast-ia-writer` — iA Writer
- dir: `raycast-ia-writer` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `raycast-jq` — Jq
- dir: `raycast-jq` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `raycast-new-instance` — New Instance
- dir: `raycast-new-instance` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `raycast-ollama` — Ollama AI
- dir: `raycast-ollama` · commands: 21 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `raycast-port` — Raycast Port
- dir: `raycast-port` · commands: 3 · modes: no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): child_process

### `raycast-rsync-extension` — Rsync File Transfer
- dir: `raycast-rsync-extension` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `raycast-surge` — Surge
- dir: `surge` · commands: 5 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `raycast-system-monitor` — System Monitor
- dir: `system-monitor` · commands: 2 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `raycast-wallpaper` — Raycast Wallpaper
- dir: `raycast-wallpaper` · commands: 2 · modes: view|no-view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `raycast-zoxide` — Zoxide
- dir: `raycast-zoxide` · commands: 2 · modes: view|no-view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `raytaskwarrior` — Taskwarrior
- dir: `raytaskwarrior` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `rclone-raycast` — rclone
- dir: `rclone-raycast` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `react-devtools` — React DevTools
- dir: `react-devtools` · commands: 1 · modes: no-view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `read-ai` — Read AI - Text to Speech
- dir: `read-ai` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `reader-mode` — Reader Mode
- dir: `reader-mode` · commands: 3 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `readwise-reader` — Readwise Reader
- dir: `readwise-reader` · commands: 11 · modes: no-view|view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `rebaptize` — Rebaptize - Rename
- dir: `rebaptize` · commands: 40 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, https

### `recent-excel` — Recent Excel - Show Recent Excel Files
- dir: `recent-excel` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `relagit` — RelaGit
- dir: `relagit` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `remote-desktop` — Remote Desktop
- dir: `remote-desktop` · commands: 1 · modes: view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads); uses Node built-ins (ok in trusted mode): child_process

### `remove-background-powered-by-mac` — Remove Background - Powered by Mac
- dir: `remove-background-powered-by-mac` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `repo-launcher` — Repo Launcher
- dir: `repo-launcher` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `repository-manager` — Repository Manager
- dir: `repository-manager` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `respace` — Respace
- dir: `respace` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `restart-system-processes` — Restart System Processes
- dir: `restart-system-processes` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `rhttp` — rhttp
- dir: `rhttp` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `roblox-games` — Roblox
- dir: `roblox-games` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `rss-reader` — RSS Reader
- dir: `rss-reader` · commands: 3 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `rsync-commands` — Rsync Commands
- dir: `rsync-commands` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `ruby-evaluate` — Ruby Evaluate
- dir: `ruby-evaluate` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `safari` — Safari
- dir: `safari` · commands: 8 · modes: view|no-view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `saucenao` — SauceNAO - Reverse Image Search
- dir: `saucenao` · commands: 3 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `save-clipboard` — Save Clipboard
- dir: `save-clipboard` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `save-link` — Save Link
- dir: `save-link` · commands: 3 · modes: no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `scoop` — Scoop
- dir: `scoop` · commands: 5 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `scrcpy` — Scrcpy
- dir: `scrcpy` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `screen-math` — Screen Math
- dir: `screen-math` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `screen-saver` — Screen Saver
- dir: `screen-saver` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `screenshot` — Screenshot
- dir: `screenshot` · commands: 8 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `scss-compile` — SCSS Compile
- dir: `scss-compile` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `search-hookmark` — Hookmark Search
- dir: `search-hookmark` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `secret-browser-commands` — Secret Browser Commands
- dir: `secret-browser-commands` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `securecrt-sessions` — SecureCRT Sessions
- dir: `securecrt-sessions` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `send-to-kindle` — Send to Kindle
- dir: `send-to-kindle` · commands: 6 · modes: no-view|view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): net, tls, child_process

### `sendme` — Sendme File Share
- dir: `sendme` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `seo-lighthouse` — SEO Lighthouse
- dir: `seo-lighthouse` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `servicenow` — ServiceNow
- dir: `servicenow` · commands: 15 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `sesh` — Sesh
- dir: `sesh` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `share-a-quote` — Share a Quote
- dir: `share-a-quote` · commands: 1 · modes: no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `sharex` — ShareX
- dir: `sharex` · commands: 9 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `shell` — Shell
- dir: `shell` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `shell-history` — Shell History
- dir: `shell-history` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `shiori-sh` — Shiori
- dir: `shiori-sh` · commands: 4 · modes: view|no-view|menu-bar
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `shortcuts-search` — Shortcuts Search
- dir: `shortcuts-search` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `shutdown-timer` — Shutdown Timer
- dir: `shutdown-timer` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `sidecar` — Sidecar
- dir: `sidecar` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `similarweb` — Similarweb
- dir: `similarweb` · commands: 2 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `simon` — Simon
- dir: `simon` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `simple-http` — Simple Http
- dir: `simple-http` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `simple-reminder` — Simple Reminder
- dir: `simple-reminder` · commands: 3 · modes: view|no-view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `simpletexocr` — SimpleTexOCR
- dir: `simpletexocr` · commands: 2 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `simulator-control` — Simulator Control
- dir: `simctl` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `simulator-manager` — Simulator Manager
- dir: `simulator-manager` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `single-disk-eject` — Single Disk Eject
- dir: `single-disk-eject` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `sips` — Image Modification
- dir: `sips` · commands: 12 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, https

### `skills` — Skills
- dir: `skills` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `slack` — Slack
- dir: `slack` · commands: 9 · modes: view|no-view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `sleep-timer` — Sleep Timer
- dir: `sleep-timer` · commands: 8 · modes: no-view|view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `slowed-reverb` — Slowed + Reverb
- dir: `slowed-reverb` · commands: 4 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `smallweb` — Smallweb
- dir: `smallweb` · commands: 2 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `snapocr-via-paddle` — SnapOCR Via Paddle
- dir: `snapocr-via-paddle` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `somafm` — SomaFM
- dir: `somafm` · commands: 2 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `sort-mentions` — Sort Mentions
- dir: `sort-mentions` · commands: 2 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `soundboard` — Soundboard
- dir: `soundboard` · commands: 11 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `sourcegraph` — Sourcegraph
- dir: `sourcegraph` · commands: 7 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): http

### `sourcetree` — Sourcetree
- dir: `sourcetree` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `spaces` — Spaces
- dir: `spaces` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `spanish-tv-guide` — Spanish TV Guide
- dir: `spanish-tv-guide` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `speech-to-text` — Speech to Text
- dir: `speech-to-text` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `speedtest` — Speedtest
- dir: `speedtest` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `spirii-go` — Spirii Go
- dir: `spirii-go` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `split-video-scenes` — Split Video Scenes
- dir: `split-video-scenes` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `spotify-player` — Spotify Player
- dir: `spotify-player` · commands: 35 · modes: view|menu-bar|no-view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `ssh-tunnel-manager` — SSH Tunnel Manager
- dir: `ssh-tunnel-manager` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `stealth-ai-tool` — Stealth AI
- dir: `stealth-ai-tool` · commands: 10 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, https

### `stickies` — Stickies
- dir: `stickies` · commands: 7 · modes: view|menu-bar|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `storybook-sandboxes` — Storybook Sandboxes
- dir: `storybook-sandboxes` · commands: 2 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `stretchly` — Stretchly
- dir: `stretchly` · commands: 2 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `summarize-youtube-video-with-ai` — Summarize YouTube Videos with AI
- dir: `summarize-youtube-video-with-ai` · commands: 5 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `supernova` — Supernova
- dir: `supernova` · commands: 6 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `surfed` — Surfed
- dir: `surfed` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `swift-repl` — Swift REPL
- dir: `swift-repl` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `swipe-photo-cleaner` — Swipe Photo Cleaner
- dir: `swipe-photo-cleaner` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `sync-folders` — Sync Folders
- dir: `sync-folders` · commands: 6 · modes: menu-bar|view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `system-information` — System Information
- dir: `system-information` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `tabby` — Tabby
- dir: `tabby` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `tabstash` — TabStash
- dir: `tabstash` · commands: 2 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `tailscale` — Tailscale
- dir: `tailscale` · commands: 11 · modes: view|no-view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `teak-raycast` — Teak
- dir: `teak-raycast` · commands: 8 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `teleport` — Teleport
- dir: `teleport` · commands: 6 · modes: no-view|view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `terminal-image-paste` — Terminal Image Paste
- dir: `terminal-image-paste` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `terminalfinder` — Terminal Finder
- dir: `terminalfinder` · commands: 22 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `text-differ` — Text Differ
- dir: `text-differ` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `text-replacements` — Text Replacements
- dir: `text-replacements` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `things` — Things
- dir: `things` · commands: 10 · modes: view|menu-bar|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `thock` — Thock
- dir: `thock` · commands: 2 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `tidal` — Tidal
- dir: `tidal` · commands: 12 · modes: menu-bar|view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, http

### `tidyread---streamline-your-daily-reading` — TidyRead - Streamline Your Daily Reading
- dir: `tidyread---streamline-your-daily-reading` · commands: 5 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): http, child_process

### `tikz` — TikZ
- dir: `tikz` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `tim` — Tim
- dir: `tim` · commands: 7 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `time-awareness` — Time Awareness
- dir: `time-awareness` · commands: 1 · modes: menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `time-machine` — Time Machine
- dir: `time-machine` · commands: 4 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `timers` — Timers
- dir: `timers` · commands: 19 · modes: no-view|view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `tl-dr-ai-summary-tool` — TL;DR (Too Long; Didn't Read)
- dir: `tl-dr-ai-summary-tool` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `tmux-cheatsheet` — Tmux Cheatsheet
- dir: `tmux-cheatsheet` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `tmux-sessioner` — Tmux Sessioner
- dir: `tmux-sessioner` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `toggl-track` — Toggl Track
- dir: `toggl-track` · commands: 7 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `toggle-desktop-visibility` — Toggle Desktop Visibility
- dir: `toggle-desktop-visibility` · commands: 6 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `toggle-menu-bar` — Toggle Menu Bar
- dir: `toggle-menu-bar` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `toggle-proxy` — Toggle Proxy
- dir: `toggle-proxy` · commands: 6 · modes: menu-bar|view
- Degraded: uses Node built-ins (ok in trusted mode): net

### `toggle-scroll-bars-visibility` — Toggle Scroll Bars Visibility
- dir: `toggle-scroll-bars-visibility` · commands: 5 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `toneclone` — ToneClone
- dir: `toneclone` · commands: 7 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `toothpick` — Toothpick
- dir: `toothpick` · commands: 19 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `tower` — Tower Repositories
- dir: `tower` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `translate` — Google Translate
- dir: `google-translate` · commands: 6 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): https, child_process

### `translate-send-webpage-to-reader` — Translate and Send Webpage to Reader
- dir: `translate-send-webpage-to-reader` · commands: 1 · modes: no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `try` — Try
- dir: `try` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `turso` — Turso
- dir: `turso` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): http

### `twitch` — Twitch
- dir: `twitch` · commands: 4 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `typora-note-creator` — Typora Note Creator
- dir: `typora-note-creator` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `unifi` — Unifi
- dir: `unifi` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `update-clash-subscription` — Update Clash Subscription
- dir: `update-clash-subscription` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `uploaderx` — UploaderX
- dir: `uploaderx` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `upnote` — UpNote
- dir: `upnote` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `uptime` — Uptime
- dir: `uptime` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `utm-virtual-machines` — UTM Virtual Machines
- dir: `utm-virtual-machines` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `v2box-control` — V2BOX VPN
- dir: `v2box-control` · commands: 4 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `vault-manager` — Vault Manager
- dir: `vault` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): http

### `vesslo` — Vesslo
- dir: `vesslo` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `video-call-reactions` — Video Call Reactions
- dir: `video-call-reactions` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `video-downloader` — Video Downloader
- dir: `video-downloader` · commands: 1 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): child_process

### `vim-leader-key` — Vim Leader Key - Keyboard Shortcut Sequences
- dir: `vim-leader-key` · commands: 4 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): child_process

### `virtual-desktop-manager` — Virtual Desktop Manager
- dir: `virtual-desktop-manager` · commands: 35 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `virtualbox-power-switch` — VirtualBox Power Switch
- dir: `virtualbox-power-switch` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `virustotal` — VirusTotal
- dir: `virustotal` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): net

### `visual-studio-code` — Visual Studio Code
- dir: `visual-studio-code-recent-projects` · commands: 6 · modes: view|no-view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads); uses Node built-ins (ok in trusted mode): child_process

### `vivaldi` — Vivaldi
- dir: `vivaldi` · commands: 5 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `vivapb` — VivaPB
- dir: `vivapb` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `vlc` — VLC
- dir: `vlc` · commands: 22 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `vmware-vcenter` — VMware VCenter
- dir: `vmware-vcenter` · commands: 4 · modes: view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `vocabuilder` — VocaBuilder
- dir: `vocabuilder` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `voice-to-text-windows` — Voice-to-Text for Windows
- dir: `voice-to-text-windows` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `voiceink` — VoiceInk
- dir: `voiceink` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `voicemeeter-raycast` — Voicemeeter Control
- dir: `voicemeeter-raycast` · commands: 5 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `vps-explorer` — VPS Explorer
- dir: `vps-explorer` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `vscode-project-manager` — Visual Studio Code - Project Manager
- dir: `visual-studio-code-project-manager` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `warp` — Warp
- dir: `warp` · commands: 5 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `watchkey` — Watchkey
- dir: `watchkey` · commands: 5 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `wayback-machine` — Wayback Machine
- dir: `wayback-machine` · commands: 4 · modes: no-view|view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `web-blocker` — Web Blocker
- dir: `web-blocker` · commands: 5 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `wechat` — WeChat
- dir: `wechat` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `wechat-devtool` — WeChat DevTool
- dir: `wechat-devtool` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `weread-sync` — WeRead Sync
- dir: `weread-sync` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `wezterm-navigator` — WezTerm Navigator
- dir: `wezterm-navigator` · commands: 4 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `whatsapp` — WhatsApp
- dir: `whatsapp` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `whisper-dictation` — Whisper Dictation
- dir: `whisper-dictation` · commands: 5 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, https

### `wi-fi` — Wi-Fi
- dir: `wi-fi` · commands: 2 · modes: no-view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `wifi-password-reveal` — WiFi Password Reveal
- dir: `wifi-password-reveal` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `wifi-share` — Wifi Share QR-Code
- dir: `wifi-share` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `window-walker` — Window Walker
- dir: `window-walker` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `windows-default-wallpapers` — Windows Default Wallpapers
- dir: `windows-default-wallpapers` · commands: 1 · modes: view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `windows-domain` — Windows Domain
- dir: `windows-domain` · commands: 2 · modes: view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `windows-environment-variables` — Windows Environment Variables
- dir: `windows-environment-variables` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `windows-terminal` — Windows Terminal
- dir: `windows-terminal` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `windsurf` — Windsurf Extension
- dir: `windsurf` · commands: 2 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `winget` — WinGet
- dir: `winget` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `winscp` — WinSCP
- dir: `winscp` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `winutils` — Winutils
- dir: `winutils` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `wireguard` — Wireguard
- dir: `wireguard` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `wispr-flow` — Wispr Flow
- dir: `wispr-flow` · commands: 8 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `wiz-controller` — Wiz Controller
- dir: `wiz-controller` · commands: 5 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): dgram

### `wol` — Wake-On-LAN
- dir: `wol` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, dgram, net

### `woocommerce-quicker` — WooCommerce Quicker
- dir: `woocommerce-quicker` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `word4you` — Word4you
- dir: `word4you` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https, child_process

### `worktrees` — Git Worktrees
- dir: `worktrees` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `world-clock` — World Clock
- dir: `world-clock` · commands: 3 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): net

### `writersbrew` — Writersbrew
- dir: `writersbrew` · commands: 21 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `wsl-manager` — WSL Manager
- dir: `wsl-manager` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `xcode` — Xcode
- dir: `xcode` · commands: 21 · modes: menu-bar|view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `xcodes` — Xcodes
- dir: `xcodes` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `yafw` — YAFW
- dir: `yafw` · commands: 7 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `yasb` — YASB
- dir: `yasb` · commands: 12 · modes: no-view|view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `youtube-highlights` — YouTube Highlights
- dir: `youtube-highlights` · commands: 5 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `yubikey-code` — YubiKey Code
- dir: `yubikey-code` · commands: 1 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): child_process

### `zed-recent-projects` — Zed
- dir: `zed-recent-projects` · commands: 3 · modes: no-view|view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads); uses Node built-ins (ok in trusted mode): child_process

### `zen-browser` — Zen Browser
- dir: `zen-browser` · commands: 6 · modes: view|no-view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads); uses Node built-ins (ok in trusted mode): child_process

### `zen-mode` — Zen Mode
- dir: `zen-mode` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `zenmux-manager` — ZenMux Manager
- dir: `zenmux-manager` · commands: 2 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `zipic` — Zipic
- dir: `zipic` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): https, http, child_process

### `zread-ai` — Zread.ai
- dir: `zread-ai` · commands: 2 · modes: no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

## SUPPORTED (2323)

`0x0`, `1loc`, `2fa-directory`, `40-questions`, `42-api`, `5devs`, `8-ball`, `8-divide`, `aave-search`, `abstract-api`, `accordance`, `acqua`, `active-mississaugua`, `adguard-home`, `adhan-time`, `ado-search`, `adonisjs-documentation`, `advanced-replace`, `advice-slip`, `aegis`, `affine`, `agent-ecosystem-map`, `ai-by-vercel`, `ai-code-namer`, `ai-gen`, `ai-humanizer`, `ai-screenshot`, `ai-stats`, `ai-text-to-calendar`, `ai-usage-tracker`, `aimlab`, `air-quality`, `airplane`, `airpods-noise-control`, `airport`, `airsy`, `airsync`, `aiven`, `akkoma`, `aleph`, `algorand`, `alice-ai`, `aliyun-flow`, `alloy`, `alpaca-trading`, `alpinejs`, `alt-text-generator`, `alwaysdata`, `amazon-search`, `amphetamine`, `analog-film-library`, `android-adb-input`, `android-versions`, `anilist-airing-schedule`, `anki`, `anna-s-archive`, `another-boring-piece`, `antd-open-browser`, `antinote`, `antisocials`, `any-website-search`, `anybox`, `anycoffee`, `anytype`, `apify`, `apis-guru-search`, `app`, `app-icon-generator`, `app-store-connect`, `append-clipboard`, `appgrid`, `apple-books`, `apple-developer-docs`, `apple-devices`, `apple-maps-search`, `apple-notes`, `apple-stocks-search`, `apply-inline-code`, `appwrite`, `arabic-keyboard`, `aranet-co2-monitor`, `arc`, `arc-helper`, `arca`, `archisteamfarm`, `archiver`, `are-na`, `area-code-lookup`, `array-this`, `ars-technica`, `arxiv`, `asana`, `asciimath-to-latex-converter`, `asoiaf`, `aspect-raytio`, `asyncapi`, `atlassian-data-center`, `atomberg-raycast-extension`, `atomic`, `atproto-utilities`, `attio`, `audio-writer`, `auth0-management`, `auto-quit-app`, `autumn`, `avatar`, `awork`, `axios-docs`, `aztu-lms`, `azure-icons`, `background-sounds`, `backstage`, `badges`, `bahn-info`, `baidu-ocr`, `balatro-compendium`, `bamboohr`, `bambu-lab`, `banca-d-italia-currency-converter`, `barassistant`, `bartender`, `base-stats`, `base-ui-docs`, `base64`, `base64-to-file`, `bash-commands`, `battery-health`, `bazinga-tools`, `bbc-news-headlines`, `beancount-meta`, `bear`, `beardtown`, `beat-per-minute`, `bech32-converter`, `bed-time-calculator`, `beehiiv`, `beeminder`, `beeper`, `bento`, `berlin-public-transportation`, `beszel`, `betaseries`, `better-aliases`, `better-deal`, `better-uptime`, `betterdiscord-store`, `betterzip`, `bhagavad-gita-quotes`, `biaodian`, `bibigpt-summarize-audiovideo-with-ai`, `bible`, `big-o`, `bike`, `bikeshare-station-status`, `bilibili-search`, `binance`, `binance-exchange`, `bing-search`, `bing-wallpaper`, `binge-clock`, `bintools`, `biome`, `bitaxe-status`, `bitbucket`, `bitbucket-search-self-hosted`, `bitcoin-price`, `bitfinex`, `bitly-url-shortener`, `bitrise`, `bj-share`, `bklit-analytics`, `blockchain-explorer-search`, `blockchain-gas-tracker`, `bluesky`, `bmrks`, `bmw`, `board-game-geek`, `bobcontrol`, `bonk-price`, `bookstack`, `bootstrap-icons`, `bored`, `botpress`, `braid`, `braintick`, `brand-dev`, `brand-fetch`, `brasileirao-serie-a`, `brave-search`, `brave-search-with-results`, `brawlstars`, `brew-services`, `bring`, `browser-bookmarks`, `browser-tabs`, `bsr-entsorgung`, `bttv-emote`, `buddy`, `bugmenot`, `buildkite`, `builtbybit`, `bundesliga`, `bundlephobia-search`, `bundles`, `bunq`, `caaals`, `cache-control-builder`, `cacher`, `cal-com-share-meeting-links`, `calendar`, `calendly`, `camper-calc`, `can-i-php`, `can-i-use`, `cangjie`, `canva`, `canvascast`, `capacities`, `capture`, `capture-fullpage-of-website`, `carbon-code-screenshot-for-raycast`, `cardpointers`, `catenary-raycast`, `catppuccin`, `cc0-lib`, `ccf-what`, `ccfddl`, `cdnjs`, `center`, `chainscout`, `chakra-ui-docs`, `change-case`, `change-scroll-direction`, `changedetection-io`, `charged`, `charming-chatgpt`, `chartmogul`, `chatbase`, `chatgo`, `chatgpt-atlas`, `chatgpt-quick-actions`, `chatgpt-search`, `chatgpt3-prompt`, `chatwith`, `chatwoot`, `chatwork-search`, `cheatsheets`, `cheatsheets-remastered`, `check-citi-bike-availability`, `checklist`, `checksum`, `cheetah`, `chess-com`, `chhoto`, `china-ip-address`, `chinese-character`, `chinese-character-converter`, `chinese-converter`, `chinese-lottery`, `chinese-numbers`, `choose-a-license`, `chords-and-tabs`, `chronometer`, `chuck-norris-facts`, `cider`, `cidr`, `cilium-docs`, `cinemas-nos`, `circle-ci`, `circleback`, `citation-generator`, `cl-indicators`, `clarify`, `clash`, `claude`, `claude-code-cheatsheet`, `clean-agent-text`, `clean-text`, `clear-clipboard`, `climbing-grade-converter`, `clip-swap`, `clipboard-editor`, `clipboard-formatter`, `clipboard-sequential-paste`, `clipboard-type`, `clipboard-utilities`, `clipmate`, `clipmenu`, `clipsign`, `clipyai`, `clockify`, `clockodo`, `close-finder`, `cloud-cli-login-statuses`, `cloudflare`, `cloudflare-ai`, `cloudflare-email-routing`, `cloudinary`, `cloudstash`, `cnpj-lookup`, `cobalt`, `cocart-docs`, `cocktail-db`, `cocoa-core-data-timestamp-converter`, `coda-bookmarks-search`, `code-review-emojis`, `code-smells`, `code-stash`, `codeblocks`, `codeforces-extension`, `codegeex`, `codemagic`, `codesnap`, `cognimemo`, `coin-caster`, `coinbase-pro`, `coingecko`, `coinmarketcap-crypto-price-crawler`, `coinpaprika`, `collected-notes`, `color-casket`, `color-hunt`, `color-picker`, `color-shades`, `color-studio-picker`, `colorify`, `colorslurp`, `cometapi`, `comma-separator`, `commercequest`, `commit-issue-parser`, `commit-message-formatter`, `commit-message-generator`, `commitlint`, `common-directory`, `composerize`, `confluence`, `consoledev`, `contentful`, `context7`, `contexts`, `control-d`, `control-viscosity`, `conventional-comments`, `conventional-commits`, `convert-px-to-vw-vh`, `convert-typescript-to-javascript`, `converter`, `convex`, `cookie-string-parser`, `coolify`, `copee`, `copilot-workspace`, `copy-gcp-icons`, `copy-notion-markdown-link`, `copy-path`, `copy-skeet-link`, `copymoveto`, `corcel`, `cosmic-bookmarks`, `count-numbers`, `counter`, `country-lookup`, `covert-color`, `coze`, `cpanel`, `cpf-cnpj-generator`, `craft-cms-docs`, `cran-e-search`, `cratecast`, `create-remix`, `create-t3-app`, `creem`, `cricketcast`, `crisp`, `cron`, `cron-description`, `crossbell`, `crunchbase`, `cryptgeon`, `crypto-portfolio-tracker`, `crypto-price`, `crypto-search`, `csfd`, `css-calculations`, `css-gg`, `css-tricks`, `csv-to-excel`, `cta`, `cuid-generator`, `cuid2-generator`, `curator-bio`, `currency-exchange`, `cursor`, `cursor-agents`, `cursor-costs`, `cursor-directory`, `cursors`, `curto-io-url-shortener`, `custom-wordle`, `customer-io`, `cyberchef`, `cyberduck`, `cyberpanel`, `cypress-docs`, `dad-jokes`, `dagster`, `daisyui`, `daminik`, `danbooru`, `danish-tax-calculator`, `dash-off`, `dashlane`, `dashlane-vault`, `databuddy`, `datafast`, `datahub`, `datawrapper`, `date-converter`, `date-format-converter`, `days-until-christmas`, `days2`, `db-schema-explorer`, `dbt-documentation`, `dbtcloud`, `debank`, `decentraland`, `decimal-2-time`, `deduplicator`, `deepcast`, `deepl-api-usage`, `deepseeker`, `defichain-dobby`, `defichain-lottery`, `definitelytyped`, `defiscan`, `defly-io`, `defuddle`, `dekudeals`, `delivery-tracker`, `demo-flow`, `denmarks-address-web-api`, `deno-deploy`, `deployhq`, `descript-to-youtube-chapters`, `design-skills`, `designer-excuses`, `designer-news`, `desktop-manager`, `desktoprenamer`, `deta-space`, `deutscherwetterdienst`, `dev-to`, `devcontainer-features`, `devdocs`, `developer-excuse`, `devenv-docs`, `devin`, `devonthink`, `devutils`, `dex-screener`, `dexcom-reader`, `dia-skills`, `dice-and-coin`, `dice-tiles`, `dicom`, `diff-checker`, `digitalocean`, `directadmin-reseller`, `directus`, `discogs`, `discord`, `discord-timestamps`, `discordjs-documentation`, `disney`, `display-modes`, `display-reinitializer`, `distraction-tracker`, `django-docs`, `djangopackages`, `dlmoji`, `dnb-book-lookup`, `dns-lookup`, `doccheck`, `dock`, `docker`, `dockerhub`, `docsearch`, `dodo-payments`, `dog-images`, `doge-tracker`, `dokploy`, `dolar-cripto-ar`, `dolar-hoy`, `dollar-blue`, `domainr`, `done-bear`, `donut`, `doppler-share-secrets`, `dot-new`, `dota-2`, `dotmate`, `dotnet-api-browser`, `dotnet-docs-search`, `dotween-eases`, `douban`, `doutu`, `dovetail`, `dpm-lol`, `dr-news`, `drafts`, `dreamhost`, `dribbble`, `dropshare`, `dropstab`, `drug-search`, `drupal-org`, `dtf`, `duan-raycast-extension`, `dub`, `ducat`, `duck-duck-go-search`, `duck-facts`, `duckduckgo-email`, `duckduckgo-image-search`, `duden`, `dungeons-dragons`, `dust-tt`, `dutch-article`, `dynamic-font-size`, `e18e-module-replacements`, `e2b`, `eagle`, `early-tools-news`, `easings`, `easy-invoice`, `easy-new-file`, `easyvariable`, `ebird`, `ecosia-search`, `effect-docs`, `ekstraklasa`, `element`, `elgato-key-light`, `elixir`, `elm-search`, `elron`, `email-verifier`, `ember-api-documentation`, `emissions-calculator`, `emoji`, `emoji-kitchen`, `emojify`, `emojis-com`, `empty-screenshots`, `end-of-life`, `endel`, `ens-name-lookup`, `ensk-is`, `envato`, `envoyer`, `epoch-to-timestamp`, `esa-search`, `escape-regexp-characters`, `espn`, `esports-pass`, `essay`, `esv-bible`, `ethereum-gas-tracker`, `ethereum-price`, `ethereum-utils`, `ets2-ats-profiles`, `eudic`, `eurovision-song-contest`, `evaluate-math-expression`, `everhour`, `evernote`, `evil-insult`, `evm-codes`, `evm-toolkit`, `exa-search`, `excalidraw`, `excel-formula-beautifier`, `exivo`, `explain-command`, `expo`, `f1-standings`, `fabric`, `facetime`, `fake-financial-data`, `fake-swedish-personal-number`, `fakecrime-upload`, `fancy-text`, `fantastical`, `fantasy-premier-league-rankings`, `farcaster`, `fastly`, `fastmail-masked-email`, `fathom`, `fathom-analytics`, `fathom-analytics-stats`, `favoro`, `fbi`, `featurebase`, `feedbin`, `feedly`, `feishu-document-creator`, `fhir`, `fibonacci-sequence`, `figlet`, `figma-files-raycast-extension`, `figma-learn-companion`, `figma-shortcuts`, `figma-variables`, `filament`, `file-organizer`, `file-tree-generator`, `fillerama`, `finary`, `find-opengl-enum`, `find-website`, `findnearby`, `fingertip`, `finnish-dictionary`, `firebase-import-export`, `firebase-remote-config-admin`, `firecrawl`, `firefly-iii`, `fix-language`, `fix-link-embeds`, `fizzy`, `flaticon`, `flibusta-search`, `flight-miles-calculator`, `flighty`, `floaty`, `flow`, `fluctuation`, `fluent-outdoors`, `flutter-documentation-search`, `flux`, `flycheck-raycast`, `flypy`, `focus`, `focus-anchor`, `focus-flow`, `focustask`, `folder-cleaner`, `font-awesome`, `font-converter`, `foodle-recipes`, `footy-report`, `forgejo`, `fork-repositories`, `forked-extensions`, `format-graphql`, `formizee`, `forscore`, `fotmob`, `framer-motion`, `frankerfacez`, `freeagent`, `freedns`, `freesound`, `french-verb-conjugation`, `freshrss`, `frill`, `fronius-inverter`, `ftrack`, `fuelx`, `fullscreentext`, `fumadocs`, `game-scout`, `gandi`, `gather`, `gcp-search`, `geist-ui-components`, `genius-lyrics`, `geoconverter`, `geoguesser`, `geohash-encode-decode`, `get-cat-images`, `get-direct-link`, `get-favicon`, `get-note`, `get-ssh-key`, `gg-deals`, `gh-pic`, `ghost-docs`, `ghq`, `gif-search`, `gift-stardew-valley`, `gistly`, `git-branch-name-generator`, `git-commands`, `git-worktrees`, `gitcdn`, `gitee`, `github-cli-manual`, `github-codespaces`, `github-copilot`, `github-for-enterprise`, `github-gist`, `github-menu-bar`, `github-profile`, `github-repository-search`, `github-review-requests`, `github-search`, `github-spark`, `github-status`, `github-trending`, `github-users`, `gitlab-docs`, `gitmoji`, `gitpod`, `gleam-packages`, `glide`, `globalping`, `glossary`, `glyph-search`, `gmail`, `go-links`, `go-package-search`, `go-to-rewind-timestamp`, `gokapi`, `golden-ratio`, `gomander`, `goodlinks`, `goodreads`, `google-advanced-search`, `google-books`, `google-calendar`, `google-calendar-quickadd`, `google-contacts`, `google-finance`, `google-fonts`, `google-maps-search`, `google-maven-repository`, `google-meet`, `google-scholar`, `google-search`, `google-tasks`, `google-trends`, `google-workspace`, `gotify`, `govee`, `gradient-generator`, `gradle-plugins`, `grafana`, `grafbase`, `grammari-x`, `grammaring`, `granola`, `graphcalc`, `graphcdn`, `greip`, `grist`, `grok-ai`, `grokipedia`, `groq`, `groq-tools`, `groundhog-day`, `growthbook`, `guerrilla-mail`, `guitar-chords`, `gumroad`, `gyazo-uploader`, `habitica-todos`, `habits`, `habr-media`, `hacker-news`, `hackmd`, `hakuna`, `hammerspoon`, `hardcover`, `harpoon`, `hashnode`, `hashrate-no`, `hatena-bookmark`, `have-i-been-pwned`, `haystack`, `hazeover`, `hdri-library`, `headlines`, `hebrew-date-zmanim`, `height`, `helldivers2`, `hellonext-changelogs`, `hellonext-wallpapers`, `helm-chart`, `helm-docs`, `hemolog`, `hephaestus`, `heptabase`, `heroicons`, `hestiacp-admin`, `hetrixtools`, `hetzner`, `hevy`, `hexlify`, `heyclaude`, `hide-all-apps`, `hide-mail`, `hidemyemail`, `hijri-converter`, `himalaya`, `hipster-ipsum`, `holodex`, `holopin`, `homebox`, `homepage`, `homey`, `hoogle`, `hop`, `horoscope`, `host-io`, `host-switch`, `hostloc`, `hotel-manager`, `houdahspot-search`, `howlongtobeat`, `hsdecks`, `html-colors`, `http-dot-cat`, `http-mime`, `http-observatory`, `hubspot`, `hubspot-portal-launcher`, `hue-palette`, `hugging-face`, `huggingcast`, `humaans`, `hupu`, `hyper-focus`, `hypersonic`, `hyrule-compendium-search`, `iata-code-decoder`, `icd10-lookup`, `iching-divination`, `icloud-global-pricing-comparison`, `iconify`, `iconpark`, `icons8`, `icy-veins-quicklinks`, `ifanr`, `ilovepdf`, `image-base64`, `image-diff-checker`, `image-flow`, `image-hash-rename`, `image-host`, `image-search`, `image-shield`, `image-to-ascii`, `image-wallet`, `imagekit-uploader`, `imdb`, `imessage-2fa`, `imgur`, `improvmx`, `in-the-time-zone`, `inbound`, `incident-io`, `incognito-clone`, `indiehackers`, `inertiajs-documentation`, `infakt`, `infisical`, `infomaniak`, `ingredients-lister`, `initium`, `inkdrop`, `inkeep`, `inpost-parcel-lockers`, `input-source-switcher`, `inspire-search`, `instagram-media-downloader`, `installed-extensions`, `instant-domain-search`, `instapaper`, `intention-clarifier`, `intermittent-fasting`, `internet-radio`, `invoice-generator`, `ionos-sync`, `ios-resolution`, `ip-tools`, `ipa-translator`, `ipapi-is`, `ipcheck-ing`, `ipinfo`, `iptv`, `iridium`, `is-it-toxic-to`, `isdown`, `ishader`, `itch-io`, `jalali-date-convertor`, `james-webb-space-telescope`, `jellyfin`, `jetpack-commands`, `jira`, `jira-search`, `jira-self-hosted`, `jira-time-tracking`, `jira2git`, `jisho`, `jitsi`, `job-dojo`, `johnny-decimal`, `jokes`, `jotform`, `jotoba`, `json-editor`, `json-format`, `json-resume`, `json-to-go`, `json-to-toon-converter`, `json2ts`, `jsr`, `jsrepo`, `jue-jin`, `jules-agents`, `jup-agg`, `jurassic-ninja-site-generator`, `just-breathe`, `just-delete-me`, `just-focus`, `justcolorpicker-raycast`, `jwt-decoder`, `kaalam`, `kafka`, `kafka-ui`, `kagi-fastgpt`, `kagi-news`, `kagi-search`, `kaleidoscope`, `kalshi`, `kaneo-for-raycast`, `kaomoji-search`, `kaset-control`, `keeper-security`, `keeply`, `kef-control`, `keka`, `key-value`, `keyboard-brightness`, `keyboard-shortcut-sequences`, `keychain-password-gen`, `keygen`, `kill-node-modules`, `kimai`, `kimi`, `kimi-for-coding`, `kind-words`, `kindle-paste`, `kinopio-inbox`, `kinopoisk`, `klu-ai`, `knowwa`, `knowyourmeme`, `korean-date-converter`, `korean-spell-checker`, `koyeb`, `kubernetes`, `kubernetes-docs`, `kurslog`, `kusto-reference`, `kutt`, `laby-net`, `lacinka`, `laliga`, `language-detector`, `lapack-blas-documentation-search`, `laracasts`, `larajobs-search`, `laravel-artisan`, `laravel-cloud`, `laravel-docs`, `laravel-forge`, `laravel-herd`, `laravel-livewire`, `laravel-nova`, `laravel-shift`, `laravel-vapor`, `large-type`, `lark`, `lark-applink`, `lastfm`, `latest-news`, `latex-board`, `latex-math-symbols`, `launchdarkly`, `lavinprognoser`, `lazygit-keybindings`, `leafcast`, `leap-new`, `learning-snacks`, `leave-time-calculator`, `leetcode`, `lego-bricks`, `leitnerbox`, `lemmy`, `lemon-squeezy`, `lenscast`, `let-me-google-that`, `letta`, `letterboxd`, `lgtmeow`, `liba-ro_shortener`, `libraries-io`, `lichess-org`, `life-progress`, `lift-calculator`, `lifx`, `lifx-advanced-controller`, `lightdash-navigator`, `lightning-time`, `lightshot-gallery`, `ligue-1`, `linear`, `lingo-rep-raycast`, `linguee`, `link-cleaner`, `link-transformer`, `linkace`, `linkding`, `linkinize`, `linkwarden`, `linux-command`, `lipsum`, `liquipedia-matches`, `list-keyboard-maestro-macros`, `list-randomizer`, `literal`, `litterbox`, `liveblocks`, `llm-stats`, `llms-txt`, `loan-calculator`, `lobehub-icons`, `lobsters`, `localcan`, `lodash`, `logseq`, `logsnag`, `logtail`, `lokalise`, `lol-esports`, `lookaway`, `looksee`, `lorem-ipsum`, `lorem-picsum`, `lotr`, `lotus-mtg-companion`, `lucide-animated`, `lucide-icons`, `lucky-surf`, `luma`, `lume`, `luna-search`, `lunaris`, `lunatask`, `lunchmoney`, `luxafor-controller`, `lyne`, `lyrics`, `m3o`, `mac-app-store-search`, `macrumors`, `macstories`, `macupdater`, `magic-home`, `mail`, `mail-finder`, `mail-to-self`, `mailboxlayer`, `mailerlite-stats`, `mailersend`, `mailsy`, `mailtrap`, `mailwip`, `make-dot-com`, `make-with-notion-2024`, `manage-clickup-tasks`, `mandarin-chinese-dictionary`, `manga-calendar`, `manifest-viewer`, `manotori`, `mantine-documentation`, `manus`, `manus-manager`, `maplestory-gg`, `marble`, `marginnote`, `markdown-blog`, `markdown-codeblock`, `markdown-converter`, `markdown-docs`, `markdown-image-to-html`, `markdown-preview`, `markdown-reference`, `markdown-slides`, `markdown-styler`, `markdown-table-generator`, `markdown-this`, `markdown-to-jira`, `markdown-to-plain-text`, `markdown-to-rich-text`, `markmarks`, `markprompt`, `masked-link-generator`, `masscode`, `mastodon`, `mastodon-search`, `material-icons`, `math-functions`, `matter`, `mattermost`, `maven-central-repository`, `maxly-chat`, `mayar`, `maybe`, `mbta-tracker`, `md-to-excel`, `medialister-marketplace-helper`, `meduza`, `mem`, `mem0`, `memberstack`, `meme-generator`, `memo`, `memorable-generate-password`, `memos`, `mempool`, `menubar-calendar`, `menubar-weather`, `mercado-libre`, `mercury`, `messages`, `meta-music`, `metabase`, `metacritic`, `metaphor`, `metaphorpsum`, `meteoblue-lookup`, `metronome`, `metube`, `micro-snitch-logs`, `microblog`, `microsoft-azure`, `microsoft-onedrive`, `microsoft-teams`, `microsoft-teams-calling`, `midas`, `midjourney`, `migadu`, `mikrus`, `mindnode`, `minecast`, `minecraft-color-codes`, `minecraft-crafting-recipes`, `miniflux`, `minimax-ai`, `minion-ipsum`, `minisim`, `minttr`, `miraie-ac-control`, `miro`, `mistral`, `mite`, `mittwald`, `mixpanel`, `mlb-scores`, `mldocs`, `mnemosyne`, `mobile-provisions`, `mobius-materials`, `modify-hash`, `modrinth`, `modrinth-search`, `moji`, `mollie-for-raycast`, `momentum`, `monday-com`, `moneybird`, `moneylover`, `moneytree`, `mongodb-objectid`, `monkeytype`, `monobank`, `monocle`, `monorepo-manager`, `monse`, `monzo`, `mood`, `moon-phrase`, `mound-for-pile`, `mousehunt-helper`, `mui-documentation`, `multi`, `multi-links`, `multilinks`, `multipass`, `multiviewer`, `music-assistant-controls`, `music-link-converter`, `music-news`, `music-timer`, `musicbrainz`, `musicthread`, `must`, `mutedeck`, `mxroute`, `my-daily-log`, `myanimelist-search`, `myidlers`, `myip`, `mymind`, `mynaui-icons`, `name-com`, `namecheap`, `namesilo`, `namuwiki`, `nano-games`, `nanoid`, `napkin`, `nasa`, `nativebase-docs`, `nato-phonetic-alphabet`, `nature-remo`, `naver-search`, `navidrome`, `nba-game-viewer`, `near-rewards`, `neodb`, `neon`, `nepali-calendar`, `nepali-date-converter`, `nerd-font-picker`, `netease-music`, `netnewswire`, `neurooo-translate`, `new-relic`, `new-york-times`, `next-lens`, `next-run`, `next-up`, `nextcloud`, `nextdns`, `nextjs-docs`, `nfl-information`, `nft-search`, `ngrok`, `nhk-program-search`, `nhl`, `nicnames`, `nif`, `nif-fresquinho`, `nightscout`, `nippon-colors`, `niuma-logs`, `nixpkgs-search`, `nl-news-headlines`, `nmbs-planner`, `no-as-a-service`, `no-more-caffeine`, `nocal`, `node-js-evaluate`, `node-release-notes`, `nordic-energy-prices`, `nos-nieuws`, `nostr`, `not-diamond`, `notaday`, `note-in-google-doc`, `noteman`, `noteplan-3`, `notilight-controller`, `notion`, `notion_researcher`, `notra`, `noun-project`, `nouns`, `novu`, `nowledge-mem`, `nowplaying-cli`, `ns-nl-search`, `nsis-reference`, `ntfy`, `nts`, `nts-radio`, `nu-nieuws`, `nuget`, `nuget-package-explorer`, `number-facts`, `number-research`, `numpad`, `numpy-documentation-search`, `nusmods`, `nyc-train-tracker`, `nzbget`, `oblique-strategies`, `obs-clippings`, `obs-control`, `obsidian-smart-capture`, `obsidian-tasks`, `oci`, `octoprint`, `octopus-energy`, `odesli`, `odin`, `odoo-companion`, `office-quotes`, `oh-my-zsh-git-alias`, `ohdear`, `ohmyzsh-plugins`, `ok-json`, `oklch-color-converter`, `okta-app-manager`, `oktasearch`, `olacv`, `ollama-mind-map-generator`, `olympic-games`, `omg-lol`, `omni-news`, `omnifocus`, `omnivore`, `onbo`, `one-tab-group`, `one-thing`, `one-time-secret`, `onelook-thesaurus`, `ones`, `open_targets`, `open-camera-menu-bar`, `open-docker`, `open-folders`, `open-gem-documentation`, `open-in-json-hero`, `open-in-shopify-admin`, `open-laravel-herd-site`, `open-latest-url-from-clipboard`, `open-props`, `open-with-app`, `openai-gpt`, `openclaw`, `openrouter-manager`, `openrouter-model-search`, `openrouter-models-finder`, `openrouter-quick-actions`, `openstatus`, `openverse`, `openweathermap`, `opsgenie`, `opslevel`, `orbit`, `orbita`, `origami`, `orion`, `orshot`, `osquery`, `osrs-wiki`, `oss`, `oss-browser`, `ossinsight`, `otp-auth`, `otp-inbox`, `otter`, `ottomatic`, `oura`, `outline-document-search`, `outline-page`, `ovhcloud`, `owledge-raycast`, `owncloud`, `oxford-collocation-dictionary`, `ozbargain-deals`, `package-tracker`, `pagerduty`, `pagespeed`, `palette-colors`, `palette-picker`, `pandas-documentation-search`, `pangu-for-raycast`, `papago-translate`, `paper`, `paperform`, `paperless-ngx`, `papermatch`, `papersize`, `paperspace`, `papra`, `parabol`, `parachord`, `parcel`, `parcel-tracker`, `parse`, `parse-logs`, `party-parrot`, `passbolt`, `passphrase-generator`, `password-generator`, `password-link`, `password-strength`, `paste-as-plain-text`, `paste-from-apple-books`, `pastebin`, `pastefy`, `pastery`, `paymenter`, `paynow`, `paypal-invoices`, `paystack`, `pbr-assistant`, `pcloud`, `pdb-explorer`, `pdf-compression`, `pdf-tools`, `pdfsearch`, `pdsls`, `penflow-ai`, `penpot`, `pera-explorer`, `percentage-calculator`, `perchance-generator`, `perplexity`, `perplexity-api`, `perry`, `personio`, `pestphp-documentation`, `pexels`, `phare-io-uptime`, `phind-search`, `phonenumber-in-im`, `phonetic-typing`, `phosphor-icons`, `photoroom-image-editing`, `php-docs`, `php-toolbox`, `pi-drill`, `pianoman`, `picgo`, `pick-random-raycast-extension`, `pika`, `pin`, `pinata`, `pinboard`, `pinch-svg`, `pinia-docs`, `pinwork`, `pip`, `pipedrive`, `pitchcast`, `pitchfork`, `pivot`, `pixabay`, `pkg-swap`, `placeholder`, `plane`, `planetscale`, `planning-center`, `planning-center-api-docs`, `planwell`, `plausible-analytics`, `playback-duration-calculator`, `playtester`, `playwright-docs`, `plex`, `plexamp`, `ploi`, `pm2`, `pocket`, `pocketbase`, `podcasts`, `podcasts-now`, `pokedex`, `pokemon-tcg-pocket-binder`, `polar`, `polars-documentation-search`, `polished`, `pollen-count`, `polymarket`, `pomo`, `popcorn`, `porkbun`, `port`, `port-from-project-name`, `portal-wholesale`, `portfolio-tracker`, `portuguese-primeira-liga`, `position-size-calculator`, `postey`, `posthog`, `postiz`, `postman`, `potter-db`, `premier-league`, `prettier`, `primer`, `printer-status`, `prisma-cli-commands`, `prisma-docs-search`, `prisma-postgres`, `privatebin`, `productboard`, `productlane`, `project-code-to-text`, `project-companion`, `project-hub`, `prompt-builder`, `prompt-stash`, `promptnote`, `prompts-chat`, `protobuf2typescript`, `proton-mail`, `proton-version`, `protondb`, `prowlarr`, `proxmox`, `proxyman`, `prusa`, `psn`, `pub-dev`, `public-bug-bounty-and-vulnerability-disclosure-programs`, `publico`, `publora`, `pubme`, `pulsemcp`, `pumble`, `punto`, `purelymail`, `purpleair`, `pushover`, `putio`, `px-to-rem-converter`, `qbitorrent`, `qonto`, `qotp`, `qovery`, `qq-mail`, `qq-music-controls`, `qrcode-generator`, `query-chatgpt`, `query-domains`, `quick-access-for-zeroheight`, `quick-access-infomaniak`, `quick-call`, `quick-event`, `quick-jump`, `quick-latex`, `quick-notes`, `quick-quit`, `quick-references`, `quick-search`, `quick-web`, `quickfile`, `quicklinker`, `quicksnip`, `quicktime`, `quicktype`, `quikwallet`, `quip`, `quoterism-raycast`, `r-pkg-search`, `radarr`, `radicle`, `rae-dictionary-raycast`, `rails-routes`, `railway`, `rain-radars`, `rainaissance`, `ram-prices`, `ramda-documentation`, `random`, `random-color`, `random-date-generator`, `random-email`, `random-password-generator`, `random-us-phone-number`, `rapidcap`, `rateyourmusic-search`, `ratingsdb`, `ratio-calculator`, `ray-boop`, `ray-clicker`, `ray-so`, `raycafe`, `raycast-ai-custom-providers`, `raycast-airtable-extension`, `raycast-apple-intelligence`, `raycast-arcade`, `raycast-bard-ai`, `raycast-clip`, `raycast-datadog`, `raycast-diki`, `raycast-explorer`, `raycast-fly`, `raycast-frc`, `raycast-google-palm`, `raycast-icons`, `raycast-ios-hig`, `raycast-kozip-extension`, `raycast-language-tool`, `raycast-lighting-node-search`, `raycast-link-lock`, `raycast-manual`, `raycast-monkeytype-theme`, `raycast-motion-preview`, `raycast-mux`, `raycast-norwegian-public-transport`, `raycast-notification`, `raycast-nrm`, `raycast-ordbokene`, `raycast-sink`, `raycast-store-updates`, `raycast-svg64`, `raycast-svgo`, `raycast-tapo-smart-devices`, `raycast-textlint-rule-aws-service-name`, `raycast-timeular`, `raycast-timezone-converter`, `raycast-transistorfm`, `raycast-translate-ge`, `raycast-urbandictionary-word-of-the-day`, `raycast-wca`, `raycast-weekly-newsletter`, `raycast-wemo`, `raycaster`, `raydocs`, `raydoom`, `raylog-markdown-tasks`, `raynab`, `raytyping`, `razuna`, `rdir`, `rdw-kentekencheck`, `re-mind`, `react-docs`, `react-icons`, `react-native-directory`, `readeck`, `reading-time`, `readwise`, `readwise-to-tana`, `readymetrics`, `real-calc`, `real-debrid-manager`, `rebrandly`, `recap`, `recents`, `reclaim-ai`, `rectangle`, `recurly`, `reddit-search`, `redirect-trace`, `redis`, `redmine`, `rednote-viewer`, `reflect`, `refresh-browsers`, `refresh-wifi`, `regex-batch-renamer`, `regex-repl`, `regex-tester`, `rehooks`, `reka-ui`, `remember-the-date`, `remember-this`, `remix-icon`, `remo-notes`, `remove-background`, `remove-background---replicate-api`, `remove-paywall`, `remove-window-from-set`, `rename-images-with-ai`, `renaming`, `render`, `replicate`, `repology-search`, `rescuetime-focus-session-trigger`, `research`, `resend`, `resend-wallpaper`, `resmo`, `restore-photos`, `retool-documentation`, `retrac`, `retrace`, `reverso-context`, `rewardful`, `rewiser`, `rg-adguard-links`, `ricescore`, `rick-and-morty`, `ring-intercom`, `risk-reward-calculator`, `rize-io-sessions`, `roam-research`, `roblox`, `roblox-creator-docs`, `rocket-chat`, `roll-d20`, `rollcast`, `rollup-wtf`, `rounding-number`, `rtl-reader`, `rule-of-three`, `ruler`, `runcloud`, `running-page`, `rusbase`, `rust-docs`, `sabnzbd`, `sadaqah-box`, `safe-secret`, `sage-hr`, `salesforce`, `sanity`, `sap-logon`, `sat-scorer`, `sav`, `save-to-cubox`, `saved-items`, `savvycal`, `say`, `say-no-to-notch`, `sayintentions`, `scaleway`, `scheduler`, `schoology`, `scira`, `scrapbook`, `scrapbox-search`, `scratchpad`, `screen-sharing-recents`, `screen-studio`, `screenocr`, `screenpipe`, `script-commands`, `script-kit`, `scrycast`, `sdotee`, `seafile`, `search-ansible-documentation`, `search-astro-docs`, `search-blockchain`, `search-clojuredocs`, `search-composer-packagist`, `search-domain`, `search-github-stars`, `search-gule-sider`, `search-hex`, `search-joplin-notes`, `search-justwatch`, `search-mdn`, `search-notion`, `search-npm`, `search-oeis`, `search-private-npm-packages`, `search-regexp`, `search-router`, `search-rubygems`, `search-shopify-liquid-documentation`, `search-with-algolia`, `searchcaster`, `sec-filings-search`, `security-search`, `seedsnote`, `sefaria`, `selfh-st-icons`, `semantic-scholar`, `send-ai`, `send-to-e-reader`, `send-to-flomo`, `sendportal`, `sendy`, `sensible`, `sentry`, `sequel-ace`, `sequoia-tiling`, `serialcast`, `serie-a`, `series-rating-graphs`, `serverless-framework-docs`, `session`, `setapp`, `setlist-fm`, `sevalla`, `seventv-search`, `sf-symbols-search`, `shadcn-svelte`, `shadcn-ui`, `shadcn-vue`, `shakespearify`, `shape-calendar`, `sharding-tools`, `share-my-code`, `shell-alias`, `shell-buddy`, `shelve`, `shiftplus`, `shiori`, `ship24-client`, `shlink`, `shodan`, `shopify-dev-docs-search`, `shopify-developer-changelog`, `shopify-polaris-docs`, `shopify-theme-resources`, `shopinfo-app`, `short-io`, `shortcut`, `shottr`, `shroud-email`, `sidecar-connect`, `signal`, `silent-mention`, `silent-mode`, `simple-dictionary`, `simple-icons`, `simple-login`, `simple-memo`, `simple-youdao`, `simplebackups`, `simplelogin`, `simpread`, `single-focus`, `singularityapp`, `sip`, `siri`, `sitespeakai`, `sketch`, `skyscanner-flights`, `slack-status`, `slack-summarizer`, `slack-templated-message`, `slackmojis`, `slugify`, `slugify-file-folder-names`, `sm-ms`, `smallpdf`, `smart-calendars-ai-create-events-using-ai`, `smart-reply`, `smartthings-connector`, `smultron`, `snake`, `snap-jot`, `snapask`, `sncftraintimes`, `sniffer`, `snippetslab`, `snippetsurfer`, `social-network-trends`, `solana_nodes`, `solana-explorer`, `solana-wallets-generation`, `solidtime`, `solusvm-1-client`, `solusvm-2`, `sonarr`, `sonos`, `sonu-stream`, `sound-search`, `sourcegraph-amp-dash-x`, `spacer`, `spaceship`, `spatie-documentation`, `specify`, `speed-dial`, `speedcubing`, `spell`, `spiceblow-database`, `spike`, `spinupwp`, `splatoon`, `splitwise`, `splix`, `spoiler-converter`, `spoqify`, `sportssync`, `spotify-beta`, `spotify-controls`, `spring-initializr`, `spryker-docs`, `sql-format`, `sql-reference-search`, `squeeze`, `ssh-manager`, `st-andrews-main-library-occupancy`, `stablecog`, `stackoverflow`, `stacks`, `stagehand`, `standing-desk-tracker`, `stardew-valley-wiki`, `starling`, `stashit`, `stashpad-docs`, `statamic-docs`, `static-marks`, `steam`, `steam-player-counts`, `steamgriddb`, `stock-lookup`, `stock-tracker`, `stockholm-public-transport`, `stoicquotes`, `storyblok`, `storybook-launcher`, `storybook-search`, `storytime`, `strapi-raycast-extension`, `streamshare-uploader`, `strftime-cheatsheet`, `string-formatter`, `stripe`, `subflow`, `sublime`, `subnoto`, `substack`, `subwatch`, `summation`, `sun-moon-times`, `supabase`, `supabase-cron-monitor`, `supabase-docs`, `supergenpass`, `superhuman`, `supermemory`, `supernotes`, `superwhisper`, `surf-check`, `surfs-up`, `surge-outbound-switcher`, `surl`, `svelte-docs`, `svg-studio`, `svga-player`, `svgl`, `svgr`, `swap-commas-dots`, `swift-command`, `swift-evolution`, `swift-package-index`, `swiss-ov`, `swiss-train-times`, `switch-game-play-history`, `switchhosts`, `synology-download-station`, `synonyms`, `syntax-fm`, `t3-chat`, `table-converter`, `tableau-navigator`, `tableplus`, `tablepro`, `tabler`, `tabletop-dice-roller`, `tabnews`, `tails`, `tailwind-size-conversion`, `tailwindcss`, `tallinn-transport`, `tally`, `tana`, `tana-paste`, `tarot`, `tasklink`, `taskplane`, `tategaki`, `tautulli`, `tc-no-generator`, `team-time`, `teamgantt`, `teamup-rooms`, `techcrunch`, `telegram`, `tella`, `tembo`, `tempmail`, `tempo`, `temporary-email`, `tennis-standings`, `terminal`, `terminaldotshop`, `terraform-doc`, `tesla`, `tesla-energy`, `teslamate`, `tex2typst`, `text-decorator`, `text-enhance`, `text-format-improver`, `text-rewrap`, `text-shortcuts`, `textream`, `texts`, `tfl`, `tflink-tmpfile`, `thaw`, `the-blue-cloud`, `the-matrix-of-destiny`, `the-nobel-prize`, `the-noble-quran`, `the-verge`, `thermoconvert`, `thesaurus`, `thesvg`, `thingiverse`, `thrasher-magazine`, `threads`, `threads-video-downloader`, `tibia-helper`, `ticktick`, `tidal-controller`, `tiktoken`, `time`, `time-calculator`, `time-converter`, `time-logger`, `time-logs`, `time-teller`, `time-tracking`, `time-until-i-do`, `timecamp`, `timecrowd-tracker`, `timely`, `timezone-buddy`, `tints-and-shades`, `tiny-tycho`, `tinyfaces-nft`, `tinyimg`, `tinypng`, `tip-calculator`, `tldr`, `tldraw`, `tldv`, `tmdb`, `tny`, `todo-list`, `todoist`, `toggle-fn`, `toggle-grayscale`, `tokenizer`, `tomito-controls`, `ton-address`, `toncoin-price`, `toolbox`, `torbox`, `torr-manager`, `tourbox`, `trackflight`, `tradingview-controls`, `trakt-manager`, `transfer-sh_upload`, `transform`, `translit`, `transmission`, `transmit`, `transport-nsw`, `trek`, `trello`, `trenit`, `trimmy`, `trovu`, `trustmrr`, `truth-or-dare`, `tscheck-in`, `tududi`, `tuneblade`, `tunnelblick`, `tuple`, `tuya-smart`, `tv-remote`, `tv2---denmark`, `tw-colorpicker`, `twenty`, `twingate`, `twitch-chat`, `twitch-logs`, `twitter`, `twitter-trendscast`, `twitter-video-downloader`, `two-factor-authentication-code-generator`, `twos`, `tyme-3-time-tracker`, `tynyfy`, `type-snob`, `type-the-alphabet`, `typeform`, `typefully`, `typer`, `typescript-documentation-search`, `typescript-mock-generator`, `typewhisper`, `typographer`, `typst-symbols`, `typst-universe`, `u301-url-shortener`, `udemy-coupons`, `ugly-face`, `uk-bank-holidays`, `ulid`, `ultrahuman`, `ulysses`, `umami`, `unblocked-answers`, `unicode-symbols`, `unify-path-separator`, `unirate-currency`, `united-nations`, `unitex`, `universal-commands`, `universal-inbox`, `universities`, `unix-timestamp`, `unix-timestamp-converter`, `unkey`, `unleash-feature-toggle`, `unogs`, `unpackr`, `unsplash`, `unsure-calc`, `untis`, `upcoming-holidays`, `uplabs`, `uploadthing`, `upset-dev`, `upstash`, `uptime-kuma`, `uptime-robot`, `uranium-raycast-plugin`, `urban-dictionary`, `url-editor-pro`, `url-parse`, `url-shortener`, `url-tools`, `url-unshortener`, `useless-facts`, `usememos`, `user-agent`, `userplane`, `utc-workbench`, `utm-campaign-builder`, `uuid-generator`, `v0-by-vercel`, `v2ex`, `v2ex-viewer`, `v2raya-control`, `vade-mecum`, `vaib`, `val-town`, `valheim-wiki`, `valkey-commands-search`, `valorant-esports`, `vanguard-backup`, `vanishlink`, `vant-documentation`, `vartiq`, `vat-calculator`, `vatlayer`, `vc-ru-news`, `veganify-application`, `vercast`, `verify-number`, `viacep`, `video-converter`, `vietnamese-calendar`, `vietqr-transfer`, `vikunja`, `vim-bro`, `virtfusion`, `virtual-pet`, `virtualizor-enduser`, `viscosity`, `vision-directory`, `visitor-queue`, `vixai`, `vn-textify`, `vocab`, `vocabula-lat`, `voicenotes`, `volumio-control`, `vortex`, `vue-router-docs`, `vuejobs`, `vuejs-documentation`, `vuetify-docs`, `vueuse-functions`, `vultr`, `wakatime`, `waktu-solat`, `wallhaven`, `wave`, `wcag`, `weather`, `web-audit`, `web-converter`, `web-page-design-mode`, `web3-profile`, `web3bio`, `webbites`, `webdav-uploader`, `webflow-sites`, `webhook-sender`, `webkit-developer-docs`, `webpage-to-markdown`, `website-blocker`, `websocket-debugging`, `week-number`, `what-happened-today`, `whentomeet`, `where-is-my-cursor`, `whimsical`, `whisper`, `whitebit`, `whmcs-client-search`, `who-is-off-today`, `whois`, `whoop`, `whosampled`, `wiggle-text`, `wikipedia`, `windmill`, `window-layouts`, `window-sizer`, `windows-to-linux-path`, `wip`, `wise-accounts`, `wise-quotes`, `wistia`, `withings-sync`, `wled-controller`, `wolfram-alpha`, `woo-marketplace-search`, `word-count`, `word-research`, `word-search`, `wordle`, `wordpress-docs`, `wordpress-icon-finder`, `wordpress-manager`, `wordpress-plugins`, `wordreference`, `work-time-countdown`, `workflowy-inbox`, `workouts`, `world-clock`, `world-cup`, `wp-bones`, `wp-cli-command-explorer`, `wppb`, `wrap-text`, `wrap-unwrap`, `wrike`, `wu-bi-bian-ma`, `xbox-friends`, `xcode-cloud`, `xecutor`, `xiaohe-query`, `xid`, `xkcd`, `xkcd-password-generator`, `xpf-converter`, `xqc`, `y-combinator`, `yabai`, `yamli`, `yandex-music`, `yandex-smart-home`, `yap`, `yazio-tracker`, `year-in-progress`, `yield-calculator`, `yoink`, `yomicast`, `yopass`, `you-com-search`, `youdao-translate`, `youform`, `your-name-in-landsat`, `yourls`, `youtrack`, `youtube`, `youtube-companion`, `youtube-music`, `youtube-search`, `youtube-shorts-to-normal-video-page`, `youtube-subscriber-count`, `youtube-thumbnail`, `youversion-suggest`, `yr-weather-forecast`, `yu-gi-oh-card-lookup`, `za-fake-id-number-generator`, `zacks-stock-ranking`, `zalgo-text`, `zeabur`, `zefix`, `zeitraum`, `zenblog`, `zendesk`, `zendesk-admin`, `zeplin-project-raycast-extension`, `zerion`, `zero`, `zerodha-portfolio-kite-coin`, `zerossl`, `zipcodebase`, `zipline`, `zipper-run`, `znotch`, `zo-raycast`, `zod-documentation`, `zodme`, `zoo`, `zoom`, `zoom-meeting-control`, `zotero`, `zoxide-git-projects`, `zsh-aliases`, `zshrc-manager`, `zyntra`
