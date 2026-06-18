# Invoke v2 — Raycast extension compatibility report

- **Root scanned:** `/Users/test/Documents/code/extensions/extensions`
- **Mode:** trusted (unsandboxed)
- **Extensions found:** 2961

## Summary

| Status | Count | % |
|---|---:|---:|
| SUPPORTED | 1502 | 50.7% |
| DEGRADED | 1452 | 49.0% |
| UNSUPPORTED | 7 | 0.2% |

## Top gaps (extensions blocked/degraded per missing capability)

| Capability | Extensions affected |
|---|---:|
| uses Node built-ins | 1023 |
| declares command `arguments[]` — not passed by runtime yet | 481 |
| launchCommand | 250 |
| BrowserExtension | 47 |
| useExec | 42 |
| runPowerShellScript | 18 |
| namespace import of @raycast/api | 7 |

## UNSUPPORTED (7)

### `apple-passwords` — Apple Password
- dir: `apple-passwords` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, module, fs
- Needs review: namespace import of @raycast/api (member usage unverified)

### `comet` — Comet
- dir: `comet` · commands: 7 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process
- Needs review: namespace import of @raycast/api (member usage unverified)

### `craftdocs` — Craft
- dir: `craftdocs` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs
- Needs review: namespace import of @raycast/api (member usage unverified)

### `google-chrome` — Google Chrome
- dir: `google-chrome` · commands: 10 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process
- Needs review: namespace import of @raycast/api (member usage unverified)

### `invisible-text-detector` — Invisible Text Detector
- dir: `invisible-text-detector` · commands: 3 · modes: view|no-view
- Needs review: namespace import of @raycast/api (member usage unverified)

### `mozilla-vpn` — Mozilla VPN Connect
- dir: `mozilla-vpn` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs, https, http
- Needs review: namespace import of @raycast/api (member usage unverified)

### `obsidian-link-opener` — Obsidian Link Opener
- dir: `obsidian-link-opener` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs
- Needs review: namespace import of @raycast/api (member usage unverified)

## DEGRADED (1452)

### `0x0` — 0x0
- dir: `0x0` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `1-click-confetti` — 1-Click Confetti
- dir: `1-click-confetti` · commands: 2 · modes: menu-bar|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `1bookmark` — 1Bookmark
- dir: `1bookmark` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `1password` — 1Password
- dir: `1password` · commands: 4 · modes: view|no-view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): fs, child_process

### `40-questions` — 40 Questions - Yearly Reflection
- dir: `40-questions` · commands: 3 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `42-api` — 42 Api Tools
- dir: `42-api` · commands: 2 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `ableton-live` — Ableton Live
- dir: `ableton-live` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `abstract-api` — Abstract API
- dir: `abstract-api` · commands: 8 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `accordance` — Accordance
- dir: `accordance` · commands: 6 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `adb` — Android Debug Bridge (Adb) Commands
- dir: `adb` · commands: 20 · modes: no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, fs

### `advanced-speech-to-text` — Advanced Speech to Text
- dir: `advanced-speech-to-text` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `aegis` — Aegis Authenticator
- dir: `aegis` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `aerospace` — Aerospace Tiling Window Manager
- dir: `aerospace` · commands: 5 · modes: view|menu-bar
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, fs

### `ag-audioflow` — AG AudioFlow
- dir: `ag-audioflow` · commands: 11 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs, child_process

### `agent-client-protocol` — Agent Client Protocol
- dir: `agent-client-protocol` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `agent-ecosystem-map` — Agent Ecosystem Map
- dir: `agent-ecosystem-map` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `agent-usage` — Agent Usage
- dir: `agent-usage` · commands: 2 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): fs, module, child_process, http, https

### `ai-agency` — AI Agency
- dir: `ai-agency` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `ai-gen` — OpenAI Generator
- dir: `ai-gen` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `ai-git-assistant` — AI Git Assistant
- dir: `ai-git-assistant` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `ai-screenshot` — AI Screenshot
- dir: `ai-screenshot` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `air-quality` — Air Quality
- dir: `air-quality` · commands: 2 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `akkoma` — Akkoma
- dir: `akkoma` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `alacritty` — Alacritty
- dir: `alacritty` · commands: 4 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `algorand` — Algorand
- dir: `algorand` · commands: 8 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `alice-ai` — Alice AI - Your Daily AI Actions Companion
- dir: `alice-ai` · commands: 5 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `align-rtl` — Align RTL
- dir: `align-rtl` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `alist-downloder` — AList Downloder
- dir: `alist-downloder` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `alt-text-generator` — Alt-Text Generator
- dir: `alt-text-generator` · commands: 3 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `android` — Android
- dir: `android` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `android-adb-input` — Android ADB Input
- dir: `android-adb-input` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `android-screen-capture` — Android Screen Capture
- dir: `android-screen-capture` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `animated-window-manager` — Animated Window Manager
- dir: `animated-window-manager` · commands: 4 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `annotely` — Annotely
- dir: `annotely` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process, http

### `anonaddy` — Addy
- dir: `anonaddy` · commands: 5 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); launchCommand: loads; throws if called (inter-command launch not wired)

### `another-boring-piece` — Art Wallpapers
- dir: `another-boring-piece` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `antd-open-browser` — Antd
- dir: `antd-open-browser` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `antigravity` — Antigravity
- dir: `antigravity` · commands: 6 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process, http

### `antinote` — Antinote
- dir: `antinote` · commands: 3 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `any-website-search` — Universal Website Search
- dir: `any-website-search` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `apfel` — Apfel
- dir: `apfel` · commands: 13 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `app` — App Creator
- dir: `app-creator` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `app-icon-generator` — App Icon Generator
- dir: `app-icon-generator` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `app-keeper-manager` — App Keeper Manager
- dir: `app-keeper-manager` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `app-store-connect` — App Store Connect
- dir: `app-store-connect` · commands: 6 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `app-tag-manager` — App Tag Manager
- dir: `app-tag-manager` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `app-updates` — App Updates
- dir: `app-updates` · commands: 4 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process, fs

### `appcleaner` — App Cleaner
- dir: `appcleaner` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `append-clipboard` — Append Clipboard
- dir: `append-clipboard` · commands: 3 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `append-to-file` — Append Text to File
- dir: `append-to-file` · commands: 5 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `apple-maps-search` — Apple Maps Search
- dir: `apple-maps-search` · commands: 3 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `apple-notes` — Apple Notes
- dir: `apple-notes` · commands: 7 · modes: view|no-view|menu-bar
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `apple-photos` — Apple Photos
- dir: `apple-photos` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `apple-reminders` — Apple Reminders
- dir: `apple-reminders` · commands: 7 · modes: view|menu-bar|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `arc` — Arc
- dir: `arc` · commands: 16 · modes: view|no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `archiver` — Archiver
- dir: `archiver` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `area-code-lookup` — Area & Country Codes
- dir: `area-code-lookup` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ascii-art-wallpaper` — ASCII Art Wallpaper
- dir: `ascii-art-wallpaper` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `aspect-raytio` — Aspect Raytio
- dir: `aspect-raytio` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `asset-catalog-extractor` — Asset Catalog Extractor
- dir: `asset-catalog-extractor` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `at-profile` — @ Profile
- dir: `at-profile` · commands: 6 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, fs

### `atlassian-data-center` — Atlassian Data Center (Self-Hosted)
- dir: `atlassian-data-center` · commands: 8 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `atproto-utilities` — AT Protocol Utilities
- dir: `atproto-utilities` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `audio-device` — Set Audio Device
- dir: `audio-device` · commands: 12 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs, https

### `auto-quit-app` — Auto Quit App
- dir: `auto-quit-app` · commands: 2 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `awesome-mac` — Awesome Mac
- dir: `awesome-mac` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `awork` — awork
- dir: `awork` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `aws` — Amazon AWS
- dir: `amazon-aws` · commands: 19 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): fs, child_process

### `aztu-lms` — AzTU LMS
- dir: `aztu-lms` · commands: 8 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `azure-icons` — Azure Icons
- dir: `azure-icons` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `azure-tts-raycast` — Azure Speech TTS
- dir: `azure-tts-raycast-extension` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `backlog-md-manager` — Backlog.md Manager
- dir: `backlog-md-manager` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `badges` — Badges - Shields.io
- dir: `badges` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `baidu-ocr` — Baidu OCR
- dir: `baidu-ocr` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `bamboo-self-hosted` — Bamboo Search (Self Hosted)
- dir: `bamboo-search-self-hosted` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `bambu-lab` — Bambu Lab Controller
- dir: `bambu-lab` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `barassistant` — Bar Assistant
- dir: `barassistant` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `barcuts-companion` — BarCuts Companion
- dir: `barcuts-companion` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `bark` — Bark
- dir: `bark` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `bartender` — Bartender
- dir: `bartender` · commands: 4 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `base64-to-file` — Base64 to File
- dir: `base64-to-file` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `battery-menubar` — Battery Menu Bar
- dir: `battery-menubar` · commands: 1 · modes: menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `battery-optimizer` — Battery Optimizer
- dir: `battery-optimizer` · commands: 5 · modes: view|no-view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `bear` — Bear Notes
- dir: `bear` · commands: 4 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `bech32-converter` — Bech32 Converter
- dir: `bech32-converter` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `bed-time-calculator` — Bed Time Calculator
- dir: `bed-time-calculator` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `beeper` — Beeper Desktop
- dir: `beeper` · commands: 6 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `bento-me` — Bento
- dir: `bento-me` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `better-aliases` — Better Aliases
- dir: `better-aliases` · commands: 11 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `better-deal` — Better Deal
- dir: `better-deal` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `betteraudio` — BetterAudio
- dir: `betteraudio` · commands: 17 · modes: view|no-view|menu-bar
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, fs

### `betterdisplay` — BetterDisplay
- dir: `betterdisplay` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `bettertouchtool` — BetterTouchTool
- dir: `bettertouchtool` · commands: 2 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `betterzip` — BetterZip
- dir: `betterzip` · commands: 3 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `bible` — Bible
- dir: `bible` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `bibmanager` — Bibmanager
- dir: `bibmanager` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, readline

### `bike` — Bike
- dir: `bike` · commands: 13 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `bilibili` — Bilibili
- dir: `Bilibili` · commands: 5 · modes: view|no-view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads); uses Node built-ins (ok in trusted mode): child_process

### `binance` — Binance Portfolio
- dir: `binance` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `binance-exchange` — Binance
- dir: `binance-exchange` · commands: 3 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `biome` — Biome
- dir: `biome` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `bird` — Bird
- dir: `bird` · commands: 4 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process, fs

### `bitwarden` — Bitwarden Vault
- dir: `bitwarden` · commands: 11 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs, child_process, http, https

### `bj-share` — BJ-Share
- dir: `bj-share` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `blip-raycast` — Blip
- dir: `blip-raycast` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `bluesky` — Bluesky
- dir: `bluesky` · commands: 7 · modes: menu-bar|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `blurhash` — BlurHash
- dir: `blurhash` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `bmw` — BMW
- dir: `bmw` · commands: 12 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `bobcontrol` — Bob - Control Bob Translate
- dir: `bob` · commands: 10 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `bonjour` — Bonjour
- dir: `bonjour` · commands: 2 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `bootstrap-icons` — Bootstrap Icons
- dir: `bootstrap-icons` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `braid` — Braid Design System
- dir: `braid` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `brand-dev` — Brand.dev
- dir: `brand-dev` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `brand-fetch` — Brandfetch
- dir: `brand-fetch` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `brave` — Brave
- dir: `brave` · commands: 5 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `brawlstars` — Brawl Stars Search
- dir: `brawlstars` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `brew` — Brew
- dir: `brew` · commands: 6 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, fs

### `brew-services` — Manage Services
- dir: `brew-services` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `brightness-control` — Brightness Control
- dir: `brightness-control` · commands: 4 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, fs

### `browser-ai` — Browser AI Companion
- dir: `browser-ai` · commands: 5 · modes: no-view|view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `browser-bookmarks` — Browser Bookmarks
- dir: `browser-bookmarks` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `browser-history` — Browser History
- dir: `browser-history` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `browsers-profiles` — Open Browsers Profiles
- dir: `browsers-profiles` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `brreg` — The Brønnøysund Register Centre Search
- dir: `brreg` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `builtbybit` — BuiltByBit
- dir: `builtbybit` · commands: 4 · modes: view|no-view|menu-bar
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `bunch` — Bunch
- dir: `bunch` · commands: 9 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `bundles` — Bundles
- dir: `bundles` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `cache-control-builder` — Cache-Control Builder
- dir: `cache-control-builder` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `calibre-library` — Calibre Library
- dir: `calibre-search` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs, child_process

### `caltask` — CalTask
- dir: `caltask` · commands: 4 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process, fs

### `capture-fullpage-of-website` — Capture Fullpage of Website
- dir: `capture-fullpage-of-website` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `capture-raycast-metadata` — Capture Raycast Metadata
- dir: `capture-raycast-metadata` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `cardpointers` — CardPointers
- dir: `cardpointers` · commands: 4 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `caschys-blog` — Caschys Blog
- dir: `caschys-blog` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `ccusage` — Claude Code Usage (ccusage)
- dir: `ccusage` · commands: 3 · modes: view|menu-bar|no-view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process, fs, http

### `cdnjs` — cdnjs
- dir: `cdnjs` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `center` — Center
- dir: `center` · commands: 4 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cerebras` — Cerebras
- dir: `cerebras` · commands: 8 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): http, fs

### `certificate-viewer` — Certificate Viewer
- dir: `certificate-viewer` · commands: 2 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): tls

### `chakra-ui-docs` — Chakra UI Documentation
- dir: `chakra-ui-docs` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `charged` — Charged: Starknet Shortcuts
- dir: `charged` · commands: 7 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `chatgo` — ChatGo
- dir: `chatgo` · commands: 6 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `chatgpt` — ChatGPT
- dir: `chatgpt` · commands: 10 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): http, fs, child_process

### `chatgpt-atlas` — ChatGPT Atlas
- dir: `chatgpt-atlas` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `chatgpt-quick-actions` — ChatGPT Quick Actions
- dir: `chatgpt-quick-actions` · commands: 8 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `chatgpt-search` — ChatGPT Search
- dir: `chatgpt-search` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `chatwith` — Chatwith
- dir: `chatwith` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `chatwoot` — Chatwoot
- dir: `chatwoot` · commands: 7 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cheatsheets-remastered` — Cheatsheets Remastered
- dir: `cheatsheets-remastered` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `checksum` — Checksum
- dir: `checksum` · commands: 4 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `chiikawa-character` — Chiikawa Characters
- dir: `chiikawa-character` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `chinese-character` — Chinese Character
- dir: `chinese-character` · commands: 3 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `chinese-converter` — Chinese Converter
- dir: `chinese-converter` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cider` — Cider
- dir: `cider` · commands: 12 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cidr` — CIDR Conversion
- dir: `cidr` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `claude-code-config-switcher` — Claude Code Switcher
- dir: `claude-code-config-switcher` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `claude-code-launcher` — Claude Code Launcher
- dir: `claude-code-launcher` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `claude-sessions` — Claude Sessions
- dir: `claude-sessions` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `claudecast` — ClaudeCast
- dir: `claudecast` · commands: 10 · modes: view|no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs, child_process, readline

### `clean-keyboard` — Clean Keyboard
- dir: `clean-keyboard` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `cleanshotx` — CleanShot X
- dir: `cleanshotx` · commands: 23 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `cling` — Cling File Search
- dir: `cling` · commands: 2 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, fs

### `clippyx` — CLIPPyX
- dir: `clippyx` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `clipsign` — Clipsign
- dir: `clipsign` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `clipyai` — Clipyai
- dir: `clipyai` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `clockodo` — Clockodo
- dir: `clockodo` · commands: 8 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `close-apps` — Close All Open Apps
- dir: `close-apps` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `cloud-cli-login-statuses` — Cloud CLI Login Statuses
- dir: `cloud-cli-login-statuses` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `cloudflare-warp` — Cloudflare WARP
- dir: `cloudflare-warp` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `cloudinary` — Cloudinary
- dir: `cloudinary` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cloudstash` — Cloudstash
- dir: `cloudstash` · commands: 2 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cmux` — cmux
- dir: `cmux` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `cnpj-lookup` — CNPJ Lookup
- dir: `cnpj-lookup` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cobalt` — Cobalt
- dir: `cobalt` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `cocktail-db` — Cocktail DB
- dir: `cocktail-db` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `code` — Code Execution
- dir: `code-execution` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `code-quarkus` — Code Quarkus
- dir: `code-quarkus` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `code-runway` — Code Runway
- dir: `code-runway` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `code-saver` — Code Saver
- dir: `code-saver` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, https

### `code-stash` — Code Stash
- dir: `code-stash` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `code-wiki` — Code Wiki
- dir: `code-wiki` · commands: 2 · modes: no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `codeforces-extension` — Codeforces
- dir: `codeforces-extension` · commands: 4 · modes: view|menu-bar
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `codegrepper` — Code Grepper
- dir: `codegrepper` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `codex-manager` — Codex Manager
- dir: `codex-manager` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs, child_process

### `coffee` — Coffee
- dir: `coffee` · commands: 9 · modes: no-view|view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `coinmarketcap-crypto-price-crawler` — Coinmarketcap Crypto Search
- dir: `coinmarketcap-crypto-crawler` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `colima` — Colima
- dir: `colima` · commands: 5 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process, fs

### `color-casket` — Color Casket
- dir: `color-casket` · commands: 2 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `color-hunt` — Color Hunt
- dir: `color-hunt` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `color-picker` — Color Picker
- dir: `color-picker` · commands: 8 · modes: no-view|view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `color-shades` — Color Shades
- dir: `color-shades` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `color-studio-picker` — Color Studio Picker
- dir: `color-studio-picker` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `colorify` — Colorify - Generate Themes From Images
- dir: `colorify` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `colorslurp` — ColorSlurp
- dir: `colorslurp` · commands: 7 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `commit-message-formatter` — Commit Message Formatter
- dir: `commit-message-formatter` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `comodoro` — Comodoro
- dir: `comodoro` · commands: 3 · modes: menu-bar|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `compress-pdf` — Compress PDF
- dir: `compress-pdf` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, https

### `compressx` — Compresto
- dir: `compressx` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `connect-to-vpn` — Connect to VPN
- dir: `connect-to-vpn` · commands: 3 · modes: no-view|view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process

### `contentful` — Contentful
- dir: `contentful` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `context7` — Context7
- dir: `context7` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `contexts` — Contexts
- dir: `contexts` · commands: 2 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `convert-3d-models` — Convert 3D Models
- dir: `convert-3d-models` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `convert-px-to-vw-vh` — Pixels to Viewport Width or Height
- dir: `convert-px-to-vw-vh` · commands: 4 · modes: view|no-view|menu-bar
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cookie-string-parser` — Cookie String
- dir: `cookie-string-parser` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `copee` — Copee
- dir: `copee` · commands: 3 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `copilot-workspace` — Copilot Workspace
- dir: `copilot-workspace` · commands: 2 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `copy-gcp-icons` — Copy GCP Icons
- dir: `copy-gcp-icons` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `copy-text-files` — Copy Text Files
- dir: `copy-text-files` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `copymoveto` — CopyMoveTo
- dir: `copymoveto` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `copyq-clipboard-manager` — CopyQ Clipboard Manager
- dir: `copyq-clipboard-manager` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `corcel` — Corcel AI
- dir: `corcel` · commands: 4 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `counter` — Counter
- dir: `counter` · commands: 3 · modes: no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `covert-color` — Convert Color
- dir: `covert-color` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `coze` — Coze
- dir: `coze` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `cpanel` — cPanel
- dir: `cpanel` · commands: 7 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `craft-cms-docs` — Craft CMS
- dir: `craft-cms-docs` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `crawldoc` — CrawlDoc - Documentations Search Engine
- dir: `crawldoc` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `create-link` — Create Link
- dir: `create-link` · commands: 5 · modes: no-view|view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `create-remix` — Create Remix
- dir: `raycast-create-remix` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `create-t3-app` — Create T3 App
- dir: `create-t3-app` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `croc-transfer` — Croc Transfer
- dir: `croc-transfer` · commands: 4 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, fs

### `cron-manager` — Cron Manager
- dir: `cron-manager` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `crossbell` — Crossbell
- dir: `crossbell` · commands: 5 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `cryptgeon` — cryptgeon
- dir: `cryptgeon` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `crypto-portfolio-tracker` — Crypto Portfolio Tracker
- dir: `crypto-portfolio-tracker` · commands: 2 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `csv-to-excel` — Convert CSV to Excel
- dir: `csv-to-excel` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `cta` — CTA - Chicago Transit Authority
- dir: `cta` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `cuid2-generator` — Cuid2 Generator
- dir: `cuid2-generator` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `curl` — cURL
- dir: `curl` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `cursor-agents` — Cursor Agents
- dir: `cursor-agents` · commands: 3 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `cursor-directory` — Cursor Directory
- dir: `cursor-directory` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `cursor-recent-projects` — Cursor
- dir: `cursor-recent-projects` · commands: 5 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `custom-folder` — Custom Folder
- dir: `custom-folder` · commands: 4 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): fs

### `custom-icon` — Custom Icon
- dir: `custom-icon` · commands: 2 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process, fs

### `custom-wordle` — Custom Wordle
- dir: `custom-wordle` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `cut-out` — Cut Out
- dir: `cut-out` · commands: 2 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `cyberduck` — Cyberduck
- dir: `cyberduck` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `cyberpanel` — CyberPanel
- dir: `cyberpanel` · commands: 9 · modes: no-view|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `dagster` — Dagster
- dir: `dagster` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `daily-sites` — Daily Sites - Site Launcher
- dir: `daily-sites` · commands: 4 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): fs

### `danish-tax-calculator` — Danish Tax Calculator
- dir: `danish-tax-calculator` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `dash` — Dash
- dir: `dash` · commands: 3 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, fs

### `dash-off` — Dash Off
- dir: `dash-off` · commands: 2 · modes: no-view|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `datafast` — Datafast
- dir: `datafast` · commands: 7 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `datahub` — Datahub Utility
- dir: `datahub` · commands: 2 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `datawrapper` — Datawrapper
- dir: `datawrapper` · commands: 5 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `date-format-converter` — Date Format Converter
- dir: `datetime-format-converter` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `day-one` — Day One
- dir: `day-one` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `days2` — Days 2 - Google Calendar Countdown
- dir: `days2` · commands: 3 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `db-schema-explorer` — DB Schema Explorer
- dir: `db-schema-explorer` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `decimal-2-time` — Decimal 2 Time
- dir: `decimal-2-time` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `deepcast` — Deepcast
- dir: `deepcast` · commands: 33 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `deepseeker` — Deepseek Quick Actions
- dir: `deepseeker` · commands: 12 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `deepwiki` — DeepWiki
- dir: `deepwiki` · commands: 3 · modes: no-view|view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `default-web-browser-manager` — Default Web Browser Manager
- dir: `default-web-browser-manager` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `defbro` — Defbro
- dir: `defbro` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `defichain-lottery` — Defichain Lottery
- dir: `defichain-lottery` · commands: 4 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `defly-io` — Defly.io
- dir: `defly-io` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `defuddle` — Defuddle
- dir: `defuddle` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `demo-flow` — Demo Flow
- dir: `demo-flow` · commands: 5 · modes: view|no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `denmarks-address-web-api` — DAWA - Danish Address Web API
- dir: `dawa` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `deno-deploy` — Deno Deploy
- dir: `deno-deploy` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `descript-to-youtube-chapters` — Descript to YouTube Chapters
- dir: `descript-to-youtube-chapters` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `desktop-manager` — Desktop Manager
- dir: `desktop-manager` · commands: 6 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `desktoprenamer` — DesktopRenamer
- dir: `desktoprenamer` · commands: 10 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `dev-cache-cleaner` — Dev Cache Cleaner
- dir: `dev-cache-cleaner` · commands: 3 · modes: view|no-view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `dev-servers` — Dev Servers
- dir: `dev-servers` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process, fs

### `devdocs` — DevDocs
- dir: `devdocs` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `devpod` — DevPod
- dir: `devpod` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `dia` — Dia
- dir: `dia` · commands: 7 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs, child_process

### `dia-skills` — Dia Skills
- dir: `dia-skills` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `dict-cc` — dict.cc
- dir: `dict-cc` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, https

### `dictionary` — Web Dictionaries
- dir: `dictionary` · commands: 2 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): fs

### `diff-view` — Diff View
- dir: `diff-view` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `dig` — Dig - DNS Lookup
- dir: `dig` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `digger` — Digger
- dir: `digger` · commands: 1 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): dns, tls

### `directadmin-reseller` — DirectAdmin Reseller
- dir: `directadmin-reseller` · commands: 6 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `discord` — Discord
- dir: `discord` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `discussite` — Discussite
- dir: `discussite` · commands: 1 · modes: no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `disk-usage` — Disk Usage
- dir: `disk-usage` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process, readline

### `diskutil` — Disk Utility
- dir: `diskutil` · commands: 2 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `diskutil-mac` — Diskutil
- dir: `diskutil-mac` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `display-input-switcher` — Display Input Switcher
- dir: `display-input-switcher` · commands: 3 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, fs

### `display-modes` — Display Modes
- dir: `display-modes` · commands: 3 · modes: view|no-view|menu-bar
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `display-reinitializer` — Display Reinitializer
- dir: `display-reinitializer` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `displayplacer` — Display Placer
- dir: `displayplacer` · commands: 7 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `dnb-book-lookup` — DNB Book Lookup
- dir: `dnb-book-lookup` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `do-not-disturb` — Do Not Disturb
- dir: `do-not-disturb` · commands: 4 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `doccheck` — DocCheck
- dir: `doccheck` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `dock` — Dock
- dir: `dock` · commands: 4 · modes: no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `dock-tinker` — Dock Tinker
- dir: `dock-tinker` · commands: 12 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `dockit` — DocKit - Document Toolkit
- dir: `dockit` · commands: 3 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `docklock-plus` — DockLock Plus
- dir: `docklock-plus` · commands: 8 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `docsearch` — DocSearch
- dir: `docsearch` · commands: 45 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `doorstopper` — Doorstopper
- dir: `doorstopper` · commands: 5 · modes: no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process

### `dot-new` — dot-new
- dir: `dot-new` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `dot-underscore-files-cleaner` — Dot Underscore Files Cleaner
- dir: `dot-underscore-files-cleaner` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `dotmate` — Dotmate
- dir: `dotmate` · commands: 5 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `doubao-tts` — Doubao TTS
- dir: `doubao-tts` · commands: 4 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `doutu` — DouTu
- dir: `doutu` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `downloads-manager` — Downloads Manager
- dir: `downloads-manager` · commands: 7 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `drafts` — Drafts
- dir: `drafts` · commands: 18 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `dropover` — Dropover
- dir: `dropover` · commands: 2 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `dropshare` — Dropshare
- dir: `dropshare` · commands: 6 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `dropstab` — DropsTab
- dir: `dropstab` · commands: 6 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `drupal-toolbox` — Drupal Toolbox
- dir: `drupal-toolbox` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `dtf` — DTF
- dir: `dtf` · commands: 8 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `duan-raycast-extension` — Duan: Shorten and Manage Links
- dir: `duan-raycast-extension` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `dub` — Dub
- dir: `dub` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ducat` — Ducat
- dir: `ducat` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `duckduckgo-image-search` — DuckDuckGo Image Search
- dir: `duckduckgo-image-search` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `dungeons-dragons` — Dungeons & Dragons
- dir: `dungeons-and-dragons` · commands: 6 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `dust-tt` — Ask Dust
- dir: `dust-tt` · commands: 6 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `e2b` — E2B Code Interpreter
- dir: `e2b` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `eagle` — Eagle
- dir: `eagle` · commands: 6 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `easy-invoice` — Easy Invoice
- dir: `easy-invoice` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `easy-new-file` — Easy New File
- dir: `easy-new-file` · commands: 3 · modes: no-view|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `easy-ocr` — Easy OCR
- dir: `easy-ocr` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `easydict` — Easy Dictionary
- dir: `easydict` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, fs

### `edgestore-raycast` — EdgeStore
- dir: `edgestore-raycast` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https, fs

### `elevenlabs-tts` — ElevenLabs TTS
- dir: `elevenlabs-tts` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `email-verifier` — Email Verifier
- dir: `email-verifier` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `emoji` — Emoji Search
- dir: `emoji` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `emoji-kitchen` — Emoji Mashups
- dir: `emoji-kitchen` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `emojify` — Emojify
- dir: `emojify` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `emojis-com` — emojis.com
- dir: `emojis-com` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `empty-screenshots` — Empty Screenshot Folder
- dir: `empty-screenshots` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `encoding-tools` — Encoding Tools
- dir: `encoding-tools` · commands: 7 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `ensk-is` — Ensk.is
- dir: `ensk-is` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `ente-auth` — Ente Auth
- dir: `ente-auth` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `envato` — Envato Sales, Purchases and Search
- dir: `envato` · commands: 5 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `epim` — Entra PIM Role
- dir: `epim` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `esa-search` — esa Search
- dir: `esa-search` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `espanso` — Espanso
- dir: `espanso` · commands: 5 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `esse-actions` — Esse Actions
- dir: `esse-actions` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `ets2-ats-profiles` — ETS2/ATS Profiles
- dir: `ets2-ats-profiles` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `eudic` — Eudic
- dir: `eudic` · commands: 3 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `everhour` — Everhour Time Tracking
- dir: `everhour` · commands: 3 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `evernote` — Evernote Instant Search
- dir: `evernote` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `everything-search` — Everything
- dir: `everything-search` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs, https, child_process

### `evm-toolkit` — EVM Toolkit
- dir: `evm-toolkit` · commands: 11 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `exa-search` — Exa
- dir: `exa` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `exif` — Exif Viewer
- dir: `exif` · commands: 2 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `expand-video-canvas` — Expand Video Canvas
- dir: `expand-video-canvas` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `extend-display` — Extend Display
- dir: `extend-display` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `fake-typing-effect` — Fake Typing Effect
- dir: `fake-typing-effect` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `fantastical` — Fantastical
- dir: `fantastical` · commands: 4 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `farrago` — Farrago
- dir: `farrago` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs, dgram

### `fathom` — Fathom
- dir: `fathom` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `feedbin` — Feedbin
- dir: `feedbin` · commands: 6 · modes: view|menu-bar|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `fetch-youtube-transcript` — Fetch YouTube Transcript
- dir: `fetch-youtube-transcript` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs, child_process

### `ffmpeg` — FFmpeg - View, Analyze and Manipulate
- dir: `ffmpeg` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `fifteen-million-merits` — Fifteen Million Merits
- dir: `fifteen-million-merits` · commands: 2 · modes: menu-bar|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs, child_process

### `figlet` — FIGlet
- dir: `figlet` · commands: 2 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `figma-link-cleaner` — Figma Link Cleaner
- dir: `figma-link-cleaner` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `file-info` — File Info
- dir: `file-info` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `file-manager` — File Manager
- dir: `file-manager` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `file-organizer` — File Organizer
- dir: `file-organizer` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `filemaker-snippets` — FileMaker Snippets
- dir: `filemaker-snippets` · commands: 7 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `files-shelf` — Files Shelf
- dir: `files-shelf` · commands: 5 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `filezilla` — FileZilla
- dir: `filezilla` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `find-opengl-enum` — Find OpenGL Enum
- dir: `find-opengl-enum` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `find-website` — Find Website
- dir: `find-website` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `finder-file-actions` — Finder File Actions
- dir: `finder-file-actions` · commands: 5 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `finderutils` — Finder Utilities
- dir: `finderutils` · commands: 2 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `finicky-rule-manager` — Finicky Rule Manager
- dir: `finicky-rule-manager` · commands: 3 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): fs, child_process

### `fip` — Fip
- dir: `fip` · commands: 6 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process

### `firebase-import-export` — Manage Firebase Firestore Collections
- dir: `firebase-import-export` · commands: 2 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `firebase-remote-config-admin` — Firebase - Remote Config
- dir: `firebase-remote-config-admin` · commands: 5 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `firefox-tabs` — Firefox Tabs
- dir: `firefox-tabs` · commands: 2 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process, fs

### `fisher` — Fisher
- dir: `fisher` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `fitdesk` — FitDesk
- dir: `fitdesk` · commands: 4 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process

### `fix-helper` — FIX Helper
- dir: `fix-helper` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): https, fs

### `fix-link-embeds` — Fix Link Embeds
- dir: `fix-link-embeds` · commands: 3 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `fizzy` — Fizzy
- dir: `fizzy` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `flashspace` — FlashSpace
- dir: `flashspace` · commands: 27 · modes: view|no-view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): fs, child_process

### `flaticon` — Flaticon — Search Icons
- dir: `flaticon` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `flibusta-search` — Flibusta Search
- dir: `flibusta-search` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `flighty` — Flighty
- dir: `flighty` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `floaty` — Floaty
- dir: `floaty` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `flow` — Flow Timer
- dir: `flow` · commands: 10 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `flush-dns` — Flush DNS
- dir: `flush-dns` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `flutter-documentation-search` — Flutter Documentation Search
- dir: `flutter-documentation-search` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `flutter-utils` — Flutter Utils
- dir: `flutter-utils` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `focus` — Focus
- dir: `focus` · commands: 9 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `focus-anchor` — Focus Anchor
- dir: `focus-anchor` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `focus-flow` — Focusflow - a Study Clock
- dir: `focus-flow` · commands: 9 · modes: view|menu-bar|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `folder-cleaner` — Folder Cleaner
- dir: `folder-cleaner` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `folder-organizer` — Folder Organizer
- dir: `folder-organizer` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `folder-search` — Folder Search
- dir: `folder-search` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `font-converter` — Font Converter
- dir: `font-converter` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `font-search` — Font Search
- dir: `font-search` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `font-sniper` — Font Sniper
- dir: `font-sniper` · commands: 1 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): fs

### `foodle-recipes` — Foodle Recipes
- dir: `foodle-recipes` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `footy-report` — Footy Report
- dir: `footy-report` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `fork-repositories` — Fork Repositories
- dir: `fork-repositories` · commands: 2 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `forked-extensions` — Forked Extensions
- dir: `forked-extensions` · commands: 1 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `forscore` — forScore
- dir: `forscore` · commands: 6 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `fotmob` — Fotmob
- dir: `fotmob` · commands: 10 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `foundry-cast-cli` — Foundry Cast CLI
- dir: `foundry-cast-cli` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `frame-crop-art` — Frame Crop - Discover Art for Your TV
- dir: `frame-crop` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `freesound` — Freesound
- dir: `freesound` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `french-company-search` — French Company Search
- dir: `french-company-search` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `french-verb-conjugation` — French Verb Conjugation
- dir: `french-verb-conjugation` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `fuelix` — Fuelix
- dir: `fuelix` · commands: 16 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, fs

### `fullscreentext` — Fullscreen Text
- dir: `fullscreentext` · commands: 3 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `fuzzy-file-search` — Fuzzy File Search
- dir: `fuzzy-file-search` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process, readline

### `fvm` — FVM
- dir: `fvm` · commands: 4 · modes: view|no-view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs, child_process

### `g-cloud` — Google Cloud CLI
- dir: `g-cloud` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `gather` — Gather
- dir: `gather` · commands: 4 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `gcp-ip-search` — Google Cloud Platform IP Search
- dir: `gcp-ip-search` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `gemini-cli` — Gemini CLI
- dir: `gemini-cli` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, readline

### `gemini-tts` — Gemini TTS
- dir: `gemini-tts` · commands: 9 · modes: no-view|view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs, child_process

### `genius-lyrics` — Genius Lyrics
- dir: `genius-lyrics` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `geoping` — Geoping
- dir: `geoping` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `gerrit-code-review` — Gerrit Code Review
- dir: `gerrit-code-review` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): http, https

### `get-app-icon` — Get App Icon
- dir: `get-app-icon` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `get-favicon` — Get Favicon
- dir: `get-favicon` · commands: 3 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `get-note` — GetNote
- dir: `get-note` · commands: 5 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `get-ssh-key` — Get SSH Key
- dir: `get-ssh-key` · commands: 2 · modes: no-view|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `getcompress` — GetCompress
- dir: `getcompress` · commands: 3 · modes: no-view|view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `getsound` — GetSound
- dir: `getsound` · commands: 3 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `gh-pic` — GHPic
- dir: `gh-pic` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `ghostty` — Ghostty
- dir: `ghostty` · commands: 7 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `ghq` — ghq
- dir: `ghq` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `gif-search` — GIF Search
- dir: `gif-search` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `gistly` — Gistly
- dir: `gistly` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `git` — Git
- dir: `git` · commands: 6 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs, child_process

### `git-assistant` — Git Assistant
- dir: `git-assistant` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `git-batch-tools` — Git Batch Tools
- dir: `git-batch-tools` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `git-buddy` — Git Buddy
- dir: `git-buddy` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process

### `git-co-authors` — Git Co-Authors
- dir: `git-co-authors` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `git-profile` — Git Profile
- dir: `git-profile` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `git-repos` — Git Repos
- dir: `git-repos` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `git-worktrees` — Git Worktrees
- dir: `git-worktrees` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `gitcdn` — GitCDN
- dir: `gitcdn` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `gitfox` — Gitfox Repositories
- dir: `gitfox` · commands: 3 · modes: view|menu-bar|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `github` — GitHub
- dir: `github` · commands: 20 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process, fs

### `github-copilot` — GitHub Copilot
- dir: `github-copilot` · commands: 5 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `github-for-enterprise` — GitHub Enterprise
- dir: `github-for-enterprise` · commands: 8 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `github-search` — GitHub Search
- dir: `github-search` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `gitignore` — Gitignore
- dir: `gitignore` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `gitlab` — GitLab
- dir: `gitlab` · commands: 24 · modes: view|menu-bar|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): https, fs

### `gitpod` — Gitpod
- dir: `gitpod` · commands: 4 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `gles-to-malioc` — GLES to MaliOC
- dir: `gles-to-malioc` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `global-media-key` — Media Key Emulate
- dir: `global-media-key` · commands: 5 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `globalping` — Globalping
- dir: `globalping` · commands: 5 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `glossary` — Glossary
- dir: `glossary` · commands: 4 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `gmail` — Gmail
- dir: `gmail` · commands: 9 · modes: view|no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `gmail-accounts` — Gmail Accounts
- dir: `gmail-accounts` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `go-to-rewind-timestamp` — Go to Rewind Timestamp
- dir: `go-to-rewind-timestamp` · commands: 2 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `gokapi` — Gokapi
- dir: `gokapi` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `goodreads` — Goodreads
- dir: `goodreads` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `google-books` — Google Books
- dir: `google-books` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `google-calendar` — Google Calendar
- dir: `google-calendar` · commands: 5 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `google-calendar-quickadd` — Google Calendar Events Quick Add
- dir: `google-calendar-quickadd` · commands: 2 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `google-chrome-profiles` — Google Chrome Profiles
- dir: `google-chrome-profiles` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `google-cloud-run` — Google Cloud Run
- dir: `google-cloud-run` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `google-contacts` — Google Contacts
- dir: `google-contacts` · commands: 3 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `google-drive` — Google Drive
- dir: `google-drive` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `google-lens` — Google Lens
- dir: `google-lens` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `google-maps-search` — Google Maps Search
- dir: `google-maps-search` · commands: 4 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `google-maven-repository` — Google Maven Repository
- dir: `google-maven-repository` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `google-workspace` — Google Workspace
- dir: `google-workspace` · commands: 7 · modes: no-view|view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `gopass` — Gopass
- dir: `gopass` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `gpu-fleet-monitor` — GPU Fleet Monitor
- dir: `gpu-fleet-monitor` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `gradient-generator` — Gradient Generator
- dir: `gradient-generator` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `gram` — Gram
- dir: `gram` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `grammari-x` — Grammarix
- dir: `grammari-x` · commands: 4 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `granola` — Granola
- dir: `granola` · commands: 7 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `graphcalc` — GraphCalc
- dir: `graphcalc` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `grok-ai` — Grok AI
- dir: `grok-ai` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `groq` — Groq
- dir: `groq` · commands: 14 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `groq-tools` — GROQ Tools
- dir: `groq-tools` · commands: 3 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `grpcui` — gRPC UI
- dir: `grpcui` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `guerrilla-mail` — Guerrilla Mail
- dir: `guerrilla-mail` · commands: 3 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `guitar-chords` — Guitar Chords
- dir: `guitar-chords` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `guitar-tools` — Guitar Tools
- dir: `guitar-tools` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `gyazo-uploader` — Gyazo Uploader
- dir: `gyazo-uploader` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `habitica-todos` — Habitica ToDos
- dir: `habitica-todos` · commands: 7 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `habits` — SupaHabits
- dir: `supahabits` · commands: 5 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `hacker-news-top-stories` — Hacker News Top Stories
- dir: `hacker-news-top-stories` · commands: 1 · modes: menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `hakuna` — Hakuna
- dir: `hakuna` · commands: 9 · modes: view|menu-bar|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `hammerspoon` — Hammerspoon
- dir: `hammerspoon` · commands: 10 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `handoff-toggle` — Handoff Toggle
- dir: `handoff-toggle` · commands: 2 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `handy` — Handy
- dir: `handy` · commands: 9 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `harmonic` — Harmonic
- dir: `harmonic` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `harpoon` — Harpoon
- dir: `harpoon` · commands: 6 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `harvest` — Harvest
- dir: `harvest` · commands: 6 · modes: view|no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process, fs

### `hashrate-no` — Hashrate
- dir: `hashrate-no` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `have-i-been-pwned` — Have I Been Pwned
- dir: `have-i-been-pwned` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `haystack` — Haystack
- dir: `haystack` · commands: 4 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `hdri-library` — HDRI Library
- dir: `hdri-library` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `height` — Height
- dir: `height` · commands: 5 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `helium` — Helium
- dir: `helium` · commands: 6 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): fs

### `hellonext-wallpapers` — Hellonext Wallpapers
- dir: `hellonext-wallpapers` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `heptabase` — Heptabase
- dir: `heptabase` · commands: 6 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `hermes-agent` — Hermes Agent
- dir: `hermes-agent` · commands: 6 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, net

### `heroku` — Heroku
- dir: `heroku` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `hetzner` — Hetzner
- dir: `hetzner` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `heyclaude` — HeyClaude
- dir: `heyclaude` · commands: 14 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `hidden-icons` — Hidden Icons
- dir: `hidden-icons` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `hide-files` — Hide Files
- dir: `hide-files` · commands: 4 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `hiit` — HIIT
- dir: `hiit` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `hijri-converter` — Hijri Converter
- dir: `hijri-converter` · commands: 5 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `himalaya` — Himalaya
- dir: `himalaya` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `hipster-ipsum` — Hipster Ipsum
- dir: `hipster-ipsum` · commands: 2 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `hole-sandbox-launcher` — Hole Sandbox Launcher
- dir: `hole-sandbox-launcher` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `homeassistant` — Home Assistant
- dir: `homeassistant` · commands: 43 · modes: view|no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs, https, child_process

### `hop` — Hop
- dir: `hop` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `horoscope` — Horoscope
- dir: `horoscope` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `host-io` — Host.io
- dir: `host-io` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `hotcorner` — HotCorner
- dir: `hotcorner` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `hotel-manager` — Hotel Manager
- dir: `hotel-manager` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `houdahspot-search` — Search HoudahSpot
- dir: `houdahspot-search` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `http-observatory` — HTTP Observatory
- dir: `http-observatory` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `http-status-codes` — HTTP Status Codes
- dir: `http-status-codes` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): http

### `httpperf` — HTTP Performance Analyzer
- dir: `httpperf` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `hubspot-portal-launcher` — HubSpot Portal Launcher
- dir: `hubspot-portal-launcher` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `hue` — Hue
- dir: `hue` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): tls, https, net, fs, http2, dns

### `hue-palette` — Hue Palette
- dir: `hue-palette` · commands: 4 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `hugeicons-ui` — Hugeicons UI
- dir: `hugeicons-ui` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `huggingcast` — Huggingcast
- dir: `huggingcast` · commands: 6 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `hypersonic` — Hypersonic
- dir: `hypersonic` · commands: 2 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `hyrule-compendium-search` — Hyrule Compendium Search
- dir: `hyrule-compendium-search` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `iconify` — Iconify — Search Icons
- dir: `iconify` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `iconpark` — IconPark
- dir: `iconpark` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `icons8` — Icons8
- dir: `icons8` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `icy-veins-quicklinks` — Icy Veins Quicklinks
- dir: `icy-veins-quicklinks` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `ideate` — Ideate
- dir: `ideate` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `idonthavespotify` — I Don't Have Spotify
- dir: `idonthavespotify` · commands: 10 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, https, child_process

### `ihosts` — iHosts
- dir: `ihosts` · commands: 3 · modes: view|menu-bar|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process, https

### `ilovepdf` — iLovePDF
- dir: `ilovepdf` · commands: 16 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `image-base64` — Image Base64 Converter
- dir: `image-base64` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `image-flow` — Imageflow
- dir: `image-flow` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `image-hash-rename` — Image Hash Rename
- dir: `image-hash-rename` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `image-search` — Image Web Search
- dir: `image-search` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `image-shield` — Image Shield
- dir: `image-shield` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `image-to-ascii` — Image to Ascii
- dir: `image-to-ascii` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `image-wallet` — Image Wallet
- dir: `image-wallet` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `imagekit-uploader` — ImageKit Uploader
- dir: `imagekit-uploader` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `imageoptim` — ImageOptim
- dir: `imageoptim` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `imdb` — IMDb Search
- dir: `imdb` · commands: 4 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `imgur` — Imgur
- dir: `imgur` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `immich` — Immich
- dir: `immich` · commands: 3 · modes: view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `improvmx` — ImprovMX
- dir: `improvmx` · commands: 6 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `inbox-ai` — Inbox AI
- dir: `inbox-ai` · commands: 7 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): child_process

### `indiehackers` — IndieHackers
- dir: `indiehackers` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `infakt` — InFakt
- dir: `infakt` · commands: 5 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `infisical` — Infisical
- dir: `infisical` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `ingredients-lister` — Ingredients Lister
- dir: `ingredients-lister` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `inkeep` — Inkeep
- dir: `inkeep` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `inoreader` — Inoreader
- dir: `inoreader` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `input-switcher` — Keyboard Layout Switcher
- dir: `keyboard-layout-switcher` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `instagram-media-downloader` — Instagram Media Downloader
- dir: `instagram-media-downloader` · commands: 3 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `installed-extensions` — Installed Extensions
- dir: `installed-extensions` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `intermittent-fasting` — Intermittent Fasting
- dir: `intermittent-fasting` · commands: 2 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `internet-radio` — Internet Radio
- dir: `internet-radio` · commands: 11 · modes: view|no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `invoice-generator` — Invoice Generator
- dir: `invoice-generator` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `ip-finder` — Ip Finder - Network Scanner
- dir: `ip-finder` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, dns

### `ip-geolocation` — IP Geolocation
- dir: `ip-geolocation` · commands: 3 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): net

### `ip-tools` — IP Tools
- dir: `ip-tools` · commands: 9 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ipapi-is` — ipapi.is
- dir: `ipapi-is` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ipinfo` — IP Info
- dir: `ipinfo` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `iridium` — Iridium
- dir: `iridium` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `irish-rail` — Irish Rail
- dir: `irish-rail` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `ishader` — iShader
- dir: `ishader` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `iterm` — iTerm
- dir: `iterm` · commands: 11 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `itranslate` — iTranslate
- dir: `itranslate` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `ivpn` — IVPN
- dir: `ivpn` · commands: 12 · modes: no-view|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `iwork` — iWork
- dir: `iwork` · commands: 19 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `jellyamp` — Jellyamp
- dir: `jellyamp` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `jenkins` — Jenkins
- dir: `jenkins` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): http, https

### `jetbrains` — JetBrains Toolbox Recent Projects
- dir: `jetbrains` · commands: 2 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `jira` — Jira
- dir: `jira` · commands: 9 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `jira-search` — Jira Search
- dir: `jira-search` · commands: 5 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `jira-search-self-hosted` — Jira Search (Self-Hosted)
- dir: `jira-search-self-hosted` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, https

### `jira-self-hosted` — Jira (Self-Hosted)
- dir: `jira-self-hosted` · commands: 9 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `jira2git` — Jira2Git
- dir: `jira2git` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `job-dojo` — Job Dojo
- dir: `job-dojo` · commands: 5 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `joey-vocab` — Joey Vocab
- dir: `joey-vocab` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `johnny-decimal` — Johnny.Decimal
- dir: `johnny-decimal` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `jokes` — Jokes
- dir: `jokes` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `jotoba` — Jotoba — Japanese Dictionary
- dir: `jotoba` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `json-resume` — JSON Resume
- dir: `json-resume` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `jules-agents` — Jules Agents
- dir: `jules-agents` · commands: 4 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `jump` — Jump
- dir: `jump` · commands: 4 · modes: no-view|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `just-breathe` — Just Breathe
- dir: `just-breathe` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `just-focus` — Just Focus
- dir: `just-focus` · commands: 4 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `jwt-decoder` — JWT Decoder
- dir: `jwt-decoder` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `kafka` — Kafka
- dir: `kafka` · commands: 2 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `kagi-fastgpt` — Kagi FastGPT
- dir: `kagi-fastgpt` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `kaleidoscope` — Kaleidoscope
- dir: `kaleidoscope` · commands: 4 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `karabiner-profile-switcher` — Karabiner Profile Switcher
- dir: `karabiner-profile-switcher` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `karakeep` — Karakeep
- dir: `karakeep` · commands: 11 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `kaset-control` — Kaset Control
- dir: `kaset-control` · commands: 12 · modes: menu-bar|view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `kde-connect` — KDE Connect
- dir: `kde-connect` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs, child_process

### `keepassxc` — KeePassXC
- dir: `keepassxc` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `keka` — Keka
- dir: `keka` · commands: 3 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `key-value` — Key Value
- dir: `key-value` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `keyboard-brightness` — Keyboard Brightness
- dir: `keyboard-brightness` · commands: 4 · modes: no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `keyboard-shortcut-sequences` — Keyboard Shortcut Sequences
- dir: `keyboard-shortcut-sequences` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `keyboard-win-mac-switch` — Keyboard Win Mac Switch
- dir: `keyboard-win-mac-switch` · commands: 2 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `keyraycast` — KeyRaycast
- dir: `keyraycast` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `kill-mcp` — Kill MCP Servers
- dir: `kill-mcp` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `kill-node-modules` — Kill Node Modules
- dir: `kill-node-modules` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `kill-process` — Kill Process
- dir: `kill-process` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `kimai` — Kimai
- dir: `kimai` · commands: 4 · modes: view|menu-bar|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `kiro` — Kiro
- dir: `kiro` · commands: 5 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `kitty` — Kitty
- dir: `kitty` · commands: 5 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `klack` — Klack
- dir: `klack` · commands: 10 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `knowyourmeme` — KnowYourMeme
- dir: `knowyourmeme` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `kommand` — Kommand
- dir: `kommand` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `korean-add-calendar` — Korean Add Calendar
- dir: `korean-add-calendar` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `kubectx` — kubectx
- dir: `kubectx` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `kubens` — kubens
- dir: `kubens` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `kurslog` — Kurslog
- dir: `kurslog` · commands: 5 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `kusto-reference` — Kusto Reference
- dir: `kusto-reference` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `language-detector` — Language Detector
- dir: `language-detector` · commands: 3 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `lapack-blas-documentation-search` — LAPACK/BLAS Documentation Search
- dir: `lapack-blas-documentation-search` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `laravel-docs` — Laravel Docs
- dir: `laravel-docs` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `laravel-forge` — Laravel Forge
- dir: `laravel-forge` · commands: 2 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `laravel-herd` — Laravel Herd
- dir: `laravel-herd` · commands: 17 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `laravel-tips` — Laravel Tips
- dir: `laravel-tips` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `laravel-valet` — Laravel Valet
- dir: `laravel-valet` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `lastfm` — Last.fm
- dir: `lastfm` · commands: 7 · modes: menu-bar|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `lastpass` — LastPass Credentials Search
- dir: `lastpass` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `later` — Read Later
- dir: `later` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `latex-board` — LaTeX Board
- dir: `latex-board` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `lattice-scholar-extension` — Lattice Scholar Extension
- dir: `lattice-scholar-extension` · commands: 3 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): fs

### `launch-agents` — Launch Agents
- dir: `launch-agents` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `launchd-monitor` — Launchd Monitor
- dir: `launchd-monitor` · commands: 1 · modes: menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `launchpad-plus` — Launchpad+
- dir: `launchpad-plus` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `leader-key` — Leader Key
- dir: `leader-key` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `leafcast` — Leafcast
- dir: `leafcast` · commands: 8 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `leave-time-calculator` — Leave Time Calculator
- dir: `leave-time-calculator` · commands: 2 · modes: no-view|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `lemniscate-system-monitor` — Lemniscate | System Monitor
- dir: `lemniscate-system-monitor` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `let-me-google-that` — LetMeGoogleThat
- dir: `let-me-google-that` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `letterboxd` — Letterboxd
- dir: `letterboxd` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `libraries-io` — Libraries.io
- dir: `libraries-io` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `library-genesis` — Library Genesis
- dir: `library-genesis` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `lift-calculator` — Lift Calculator
- dir: `lift-calculator` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `linak-desk-controller` — Linak Desk Controller
- dir: `linak-controller` · commands: 4 · modes: no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `linak-desk-controller` — Linak Desk Controller
- dir: `linak-desk-controller` · commands: 4 · modes: no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `linear` — Linear
- dir: `linear` · commands: 14 · modes: view|menu-bar|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `link-bundles` — Link Bundles
- dir: `link-bundles` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `link-transformer` — Link Transformer
- dir: `link-transformer` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `linkace` — Linkace
- dir: `linkace` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `linkace-search` — LinkAce Search
- dir: `linkace-search` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `linkinize` — Linkinize
- dir: `linkinize` · commands: 3 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `linkwarden` — Linkwarden
- dir: `linkwarden` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `lipsum` — Japanese Lorem Ipsum Generator
- dir: `lipsum` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `list-keyboard-maestro-macros` — Keyboard Maestro - List Macros
- dir: `keyboard-maestro` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `list-randomizer` — List Randomizer
- dir: `list-randomizer` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `litterbox` — Litterbox
- dir: `litterbox` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `localcan` — LocalCan
- dir: `localcan` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `localsend` — LocalSend
- dir: `localsend` · commands: 9 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): fs, dgram, http

### `lock-time` — Lock Time
- dir: `lock-time` · commands: 3 · modes: view|no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process, fs

### `lodash` — Lodash
- dir: `lodash` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `logitech-litra` — Logitech Litra
- dir: `logitech-litra` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `logos-launcher` — Logos Launcher
- dir: `logos-launcher` · commands: 10 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs, child_process

### `logseq` — Logseq
- dir: `logseq` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `lokalise` — Lokalise
- dir: `lokalise` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `looksee` — LookSee - A MAC, OUI, IAB Lookup
- dir: `looksee` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `looma-fm` — Looma.fm
- dir: `looma-fm` · commands: 4 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `looped` — Looped
- dir: `looped` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `lorem-ipsum` — Lorem Ipsum
- dir: `lorem-ipsum` · commands: 4 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `lorem-picsum` — Lorem Picsum
- dir: `lorem-picsum` · commands: 2 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `lotus-mtg-companion` — Lotus - MTG Companion
- dir: `lotus-mtg-companion` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `lucky-surf` — Lucky Surf
- dir: `lucky-surf` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `luna-search` — Luna Search
- dir: `luna-search` · commands: 2 · modes: view|menu-bar
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `lunaris` — Lunaris
- dir: `lunaris` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `lyric-fever-control` — Lyric Fever Control
- dir: `lyric-fever-control` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `m3o` — M3O
- dir: `m3o` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `mac-mouse-fix` — Mac Mouse Fix
- dir: `mac-mouse-fix` · commands: 8 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

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
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, fs

### `magic-ingest` — Magic Ingest
- dir: `magic-ingest` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs, child_process

### `mail` — Apple Mail
- dir: `mail` · commands: 11 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `mail-finder` — Mail Finder
- dir: `email-finder` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `mailboxlayer` — mailboxlayer
- dir: `mailboxlayer` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `mailsy` — Mailsy
- dir: `mailsy` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `mailwip` — Mailwip
- dir: `mailwip` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `mamp-utility` — MAMP Utility
- dir: `mamp-utility` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `man-pages` — Man Pages
- dir: `man-pages` · commands: 3 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, fs

### `manifest-viewer` — Manifest Viewer
- dir: `manifest-viewer` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `mantine-documentation` — Mantine UI Documentation
- dir: `mantine` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `maplestory-gg` — MapleStory.gg
- dir: `maplestory-gg` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `markdown-blog` — Markdown Blog Manager
- dir: `markdown-blog-manager` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `markdown-docs` — Markdown Documents
- dir: `markdown-docs` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `markdown-image-to-html` — Markdown Image to HTML
- dir: `markdown-image-to-html` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `markdown-navigator` — Markdown Navigator
- dir: `markdown-navigator` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `markdown-slides` — Markdown Slides
- dir: `markdown-slides` · commands: 4 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `markdown-styler` — Markdown Styler
- dir: `markdown-styler` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `markdown-table-generator` — Markdown Table Generator
- dir: `markdown-table-generator` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `markmarks` — MarkMarks
- dir: `markmarks` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `masked-link-generator` — Masked Link Generator
- dir: `masked-link-generator` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `mastodon` — Mastodon
- dir: `mastodon` · commands: 6 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `material-icons` — Material Icons
- dir: `material-icons` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `maven-central-repository` — Maven Central Repository
- dir: `maven-central-repository` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `maxly-chat` — Maxly.chat
- dir: `maxly-chat` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `mcp` — Model Context Protocol
- dir: `mcp` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `media-converter` — Media Converter
- dir: `media-converter` · commands: 4 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs, child_process, module

### `memorable-generate-password` — Memorable Password Generator
- dir: `memorable-generate-password` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `memory` — Memory
- dir: `memory` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `memos` — Memos
- dir: `memos` · commands: 4 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `menubar-calendar` — Menubar Calendar
- dir: `menubar-calendar` · commands: 2 · modes: menu-bar|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `mermaid-to-image` — Mermaid to Image
- dir: `mermaid-to-image` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `messages` — Messages
- dir: `messages` · commands: 5 · modes: view|menu-bar|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `meta-music` — Meta Music
- dir: `meta-music` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `metaphorpsum` — Metaphorpsum
- dir: `metaphorpsum` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `metronome` — Metronome
- dir: `metronome` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `micro-snitch-logs` — Micro Snitch Logs
- dir: `micro-snitch-logs` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `microsoft-azure` — Microsoft Azure
- dir: `microsoft-azure` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `microsoft-edge` — Microsoft Edge
- dir: `microsoft-edge` · commands: 7 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `microsoft-office` — Microsoft Office
- dir: `microsoft-office` · commands: 3 · modes: view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads); uses Node built-ins (ok in trusted mode): fs, child_process

### `microsoft-onedrive` — Microsoft OneDrive
- dir: `microsoft-onedrive` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `midjourney` — Midjourney
- dir: `midjourney` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `migros` — Migros
- dir: `migros` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https, fs

### `mindnode` — MindNode
- dir: `mindnode` · commands: 3 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `minimax-tts` — MiniMax TTS
- dir: `minimax-tts` · commands: 10 · modes: no-view|view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs, child_process

### `minio-manager` — Minio Manager
- dir: `minio-manager` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs, http, https

### `minion-ipsum` — Minion Ipsum
- dir: `minion-ipsum` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `miro` — Miro
- dir: `miro` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `mirror-displays` — Mirror Displays
- dir: `mirror-displays` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `mlb-scores` — MLB Scores
- dir: `mlb-scores` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `mldocs` — MLDocs
- dir: `mldocs` · commands: 8 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `mnemosyne` — Mnemosyne
- dir: `mnemosyne` · commands: 2 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `mobile-provisions` — Mobile Provisions
- dir: `mobile-provisions` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `moco` — MOCO
- dir: `moco` · commands: 3 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): http

### `model-context-protocol-registry` — Model Context Protocol Registry
- dir: `model-context-protocol-registry` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `models-dev` — Models Dev
- dir: `models-dev` · commands: 7 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs, v8

### `modify-hash` — Modify Hash
- dir: `modify-hash` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `mole` — Mole
- dir: `mole` · commands: 10 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process, fs

### `momentum` — Momentum
- dir: `momentum` · commands: 5 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `moneytree` — Moneytree
- dir: `moneytree` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `mongodb-objectid` — MongoDB ObjectId
- dir: `mongodb-objectid` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `monitor-mate` — MonitorMate
- dir: `monitor-mate` · commands: 3 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): net, child_process

### `monorepo-manager` — Manage Monorepo Projects/Workspaces
- dir: `monorepo-manager` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `mood` — Mood Tracker
- dir: `mood` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `moodist` — Moodist
- dir: `moodist` · commands: 7 · modes: view|no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process, fs

### `morning-coffee` — Morning Coffee
- dir: `morning-coffee` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `mound-for-pile` — Mound
- dir: `mound-for-pile` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `mouse-jiggle` — Mouse Jiggle
- dir: `mouse-jiggle` · commands: 2 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `mozeidon` — Mozeidon
- dir: `mozeidon` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): readline, child_process

### `mozilla-firefox` — Mozilla Firefox
- dir: `mozilla-firefox` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `mullvad` — Mullvad VPN
- dir: `mullvad` · commands: 5 · modes: view|no-view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `multi` — Multi
- dir: `multi` · commands: 9 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `multi-force` — MultiForce
- dir: `multi-force` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `music` — Music
- dir: `music` · commands: 26 · modes: no-view|view|menu-bar
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `music-assistant-controls` — Music Assistant Controls
- dir: `music-assistant-controls` · commands: 12 · modes: menu-bar|no-view|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `music-link-converter` — Music Link Converter
- dir: `music-link-converter` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `music-recognition` — Music Recognition
- dir: `music-recognition` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `mute-microphone` — Toggle Audio Input (Microphone)
- dir: `mute-microphone` · commands: 3 · modes: menu-bar|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `my-daily-log` — My Daily Log
- dir: `my-daily-log` · commands: 6 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `myidlers` — MyIdlers
- dir: `my-idlers` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `n8n` — n8n
- dir: `n8n` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `namesilo` — NameSilo
- dir: `namesilo` · commands: 7 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `namespaces` — NameSpaces
- dir: `namespaces` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `nanoid` — Generate Nanoid
- dir: `nanoid` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `napkin` — Napkin
- dir: `napkin` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `nato-phonetic-alphabet` — NATO Phonetic Alphabet
- dir: `nato-phonetic-alphabet` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `nerd-font-picker` — Nerd Font Picker
- dir: `nerd-font-picker` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `netbird` — NetBird
- dir: `netbird` · commands: 7 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `netlify` — Netlify
- dir: `netlify` · commands: 7 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

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

### `next-up` — Next Up
- dir: `next-up` · commands: 5 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `nextjs-docs` — Next.js Documentation
- dir: `nextjs-docs` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `nhk-program-search` — NHK Program Search
- dir: `nhk-program-search` · commands: 4 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `nhl` — NHL
- dir: `nhl` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `nicnames` — NicNames
- dir: `nicnames` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `night-light` — Night Light
- dir: `night-light` · commands: 4 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `nightscout` — Nightscout
- dir: `nightscout` · commands: 6 · modes: view|no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `nippon-colors` — Nippon Colors
- dir: `nippon-colors` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `niuma-logs` — Niuma Logs
- dir: `niuma-logs` · commands: 3 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `nix-flake-templates` — Nix Flake Templates
- dir: `nix-flake-templates` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `nmbs-planner` — NMBS Planner
- dir: `nmbs-planner` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `no-more-caffeine` — No More Caffeine
- dir: `no-more-caffeine` · commands: 4 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `node-version-manager` — Node Version Manager
- dir: `node-version-manager` · commands: 4 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `noteman` — Noteman
- dir: `noteman` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `noteplan-3` — NotePlan 3
- dir: `noteplan-3` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `notion` — Notion
- dir: `notion` · commands: 4 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `notion-url-to-id` — Notion URL to ID
- dir: `notion-url-to-id` · commands: 2 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `notis` — Ask Notis
- dir: `notis` · commands: 3 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs, child_process

### `noun-project` — Noun Project
- dir: `noun-project` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `now-playing` — Now Playing
- dir: `now-playing` · commands: 1 · modes: menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `nowledge-mem` — Nowledge Mem
- dir: `nowledge-mem` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `npm-claimer` — npm Claimer
- dir: `npm-claimer` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `ntfy` — Ntfy
- dir: `ntfy` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `nts-radio` — NTS Radio
- dir: `nts-radio` · commands: 7 · modes: no-view|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `nuget-package-explorer` — NuGet Package Explorer
- dir: `nuget-package-explorer` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `number-research` — Number Research
- dir: `number-research` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `numi` — Numi
- dir: `numi` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, http

### `numpy-documentation-search` — Numpy Documentation Search
- dir: `numpy-documentation-search` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `nuxt` — Nuxt
- dir: `nuxt` · commands: 6 · modes: no-view|view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, fs

### `oblique-strategies` — Oblique Strategies
- dir: `oblique-strategies` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `obs-clippings` — Obsidian Clippings
- dir: `obs-clippings` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `obsidian` — Obsidian
- dir: `obsidian` · commands: 12 · modes: view|menu-bar
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs, child_process

### `obsidian-bookmarks` — Obsidian Bookmarks
- dir: `obsidian-bookmarks` · commands: 3 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): fs

### `obsidian-smart-capture` — Obsidian Smart Capture
- dir: `obsidian-smart-capture` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `obsidian-tasks` — Obsidian Tasks
- dir: `obsidian-tasks` · commands: 5 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `oci` — Oracle Cloud
- dir: `oci` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `octoprint` — OctoPrint
- dir: `octoprint` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `odesli` — Odesli
- dir: `odesli` · commands: 2 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `office2pdf` — Office2PDF
- dir: `office2pdf` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, https

### `okta-app-manager` — Okta Manager
- dir: `okta-app-manager` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `omnifocus` — OmniFocus
- dir: `omnifocus` · commands: 3 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `omnivore` — Omnivore
- dir: `omnivore` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `onbo` — Onbo: New Grad & Internship Tracker
- dir: `onbo` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `one-thing` — One Thing
- dir: `one-thing` · commands: 3 · modes: menu-bar|view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `one-time-password` — One Time Password
- dir: `one-time-password` · commands: 1 · modes: view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads); uses Node built-ins (ok in trusted mode): child_process, fs

### `onenote` — OneNote
- dir: `onenote` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `open_targets` — Open Targets
- dir: `open-targets-raycast` · commands: 5 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `open-folders` — Open Folders
- dir: `open-folders` · commands: 11 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `open-graph` — Open Graph
- dir: `open-graph` · commands: 2 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `open-in-android-studio` — Open in Android Studio
- dir: `open-in-android-studio` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `open-in-cursor` — Open in Cursor
- dir: `open-in-cursor` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `open-in-json-hero` — Open in JSON Hero
- dir: `open-in-json-hero` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `open-in-sublime-text` — Open in Sublime Text
- dir: `open-in-sublime-text` · commands: 2 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `open-in-textmate` — Open in TextMate
- dir: `open-in-textmate` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `open-in-trae` — Open in Trae
- dir: `open-in-trae` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `open-in-visual-studio-code` — Open in Visual Studio Code
- dir: `open-in-visual-studio-code` · commands: 1 · modes: no-view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `open-laravel-herd-site` — Open Laravel Herd Site
- dir: `open-laravel-herd-site` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `open-link-in-specific-browser` — Open Link in Specific Browser
- dir: `open-link-in-specific-browser` · commands: 3 · modes: view|menu-bar|no-view
- Degraded: uses Node built-ins (ok in trusted mode): net

### `open-path` — Open Path
- dir: `open-path` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `openai-gpt` — OpenAI GPT
- dir: `openai-gpt` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `openai-speak` — OpenAI Speak
- dir: `openai-speak` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `openai-translator` — OpenAI Translator
- dir: `openai-translator` · commands: 8 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs, child_process

### `openclaw` — OpenClaw
- dir: `openclaw` · commands: 6 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `opencode-sessions` — OpenCode Sessions
- dir: `opencode-sessions` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `openfortivpn` — Openfortivpn
- dir: `openfortivpn` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `openhue` — OpenHue
- dir: `openhue` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https, fs

### `openrouter-manager` — OpenRouter Manager
- dir: `openrouter-manager` · commands: 4 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `openstreetmap-search` — OpenStreetMap Search
- dir: `openstreetmap-search` · commands: 3 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `openverse` — Openverse
- dir: `openverse` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `openvpn` — OpenVPN
- dir: `openvpn` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `opera` — Opera
- dir: `opera` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `opslevel` — OpsLevel
- dir: `opslevel` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `orbit` — Orbit
- dir: `orbit` · commands: 3 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `orbstack` — OrbStack
- dir: `orbstack` · commands: 2 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `origami` — Origami
- dir: `origami` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `orshot` — Orshot
- dir: `orshot` · commands: 2 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `osint-web-check` — OSINT Web Check
- dir: `osint-web-check` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): dns, net, tls

### `osquery` — Osquery
- dir: `osquery` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `oss` — OSS
- dir: `aliyun-oss` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `oss-browser` — OSS Browser
- dir: `oss-browser` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `otp-auth` — OTP Auth
- dir: `otp-auth` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `oura` — Oura
- dir: `oura` · commands: 9 · modes: view|no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `outline-document-search` — Outline Document Search
- dir: `outline-document-search` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `owl` — Owl
- dir: `owl` · commands: 2 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): fs

### `oxford-collocation-dictionary` — Oxford Collocation Dictionary
- dir: `oxford-collocation-dictionary` · commands: 2 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `package-tracker` — Parcel Tracker - 17track
- dir: `package-tracker` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `pagespeed` — Pagespeed
- dir: `pagespeed` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `palette-picker` — Color Palette Picker
- dir: `palette-picker` · commands: 2 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `pantheon-sites` — Pantheon Sites
- dir: `pantheon-sites` · commands: 2 · modes: view|no-view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `papago-translate` — Papago Translate
- dir: `papago-translate` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `paper` — Paper
- dir: `paper` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `paper-agent` — Paper Agent
- dir: `paper-agent` · commands: 11 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `paperless-ngx` — Paperless-ngx
- dir: `paperless-ngx` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `papermatch` — PaperMatch
- dir: `papermatch` · commands: 2 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `papra` — Papra
- dir: `papra` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `parachord` — Parachord
- dir: `parachord` · commands: 12 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `parallels-virtual-machines` — Parallels Virtual Machines
- dir: `parallels-virtual-machines` · commands: 2 · modes: view|no-view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `parcel` — Parcel
- dir: `parcel` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `parrot-translate` — Parrot Translate
- dir: `parrot-translate` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `parse-logs` — Parse Logs
- dir: `parse-logs` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `party-parrot` — Party Parrot
- dir: `party-parrot` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `pass` — Pass
- dir: `pass` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `passbolt` — Passbolt
- dir: `passbolt` · commands: 5 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `passphrase-generator` — Passphrase Generator
- dir: `passphrase-generator` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `password-link` — Password.link
- dir: `password-link` · commands: 4 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `password-store` — Password Store
- dir: `password-store` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `password-strength` — Password Strength
- dir: `password-strength` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `paste-as-plain-text` — Paste as Plain Text
- dir: `paste-as-plain-text` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `paste-safely` — Paste Safely
- dir: `paste-safely` · commands: 2 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): fs

### `paste-to-markdown` — Paste to Markdown
- dir: `paste-to-markdown` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `pdb-explorer` — PDB Explorer
- dir: `pdb-explorer` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `pdf-compression` — PDF Compression
- dir: `pdf-compression` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `pdf-tools` — PDF Tools
- dir: `pdf-tools` · commands: 6 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `pdfsearch` — PDFSearch
- dir: `pdfsearch` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `pdsls` — PDSls
- dir: `pdsls` · commands: 4 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `percentage-calculator` — Percentage Calculator
- dir: `percentage-calculator` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `perchance-generator` — Perchance Generator
- dir: `perchance-generator` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `performance-hud` — Metal Performance HUD
- dir: `performance-hud` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `perplexity` — Perplexity
- dir: `perplexity` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `perplexity-api` — Perplexity API
- dir: `perplexity-api` · commands: 15 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `petal` — Petal - Offline Voice to Text
- dir: `petal` · commands: 5 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `phonenumber-in-im` — Fast Chat With Phone Number in IM Apps
- dir: `phonenumber-in-im` · commands: 2 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `photoroom-image-editing` — Photoroom Image Editing
- dir: `photoroom-image-editing` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `php-monitor` — PHP Monitor
- dir: `phpmon` · commands: 11 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `pi-drill` — Pi Drill
- dir: `pi-drill` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `pia-controls` — Private Internet Access Controls
- dir: `pia-controls` · commands: 4 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `pianoman` — Pianoman
- dir: `pianoman` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `picgo` — PicGo
- dir: `picgo` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `pick-random-raycast-extension` — Pick Random
- dir: `pick-random` · commands: 3 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `pick-your-wallpaper` — Pick Your Wallpaper
- dir: `pick-your-wallpaper` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `pie-for-pi-hole` — Pie for Pi-Hole
- dir: `pie-for-pihole` · commands: 16 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): http, https, fs

### `pieces-raycast` — Pieces for Raycast
- dir: `pieces-raycast` · commands: 9 · modes: no-view|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): fs, child_process

### `pika` — Pika
- dir: `pika` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `pin` — Pin
- dir: `pin-raycast` · commands: 5 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `pinata` — Pinata
- dir: `pinata` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `pinch-svg` — Pinch SVG
- dir: `pinch-svg` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ping` — Ping
- dir: `ping` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `ping-menu` — Ping Menu
- dir: `ping-menu` · commands: 1 · modes: menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `pins` — Pins
- dir: `pins` · commands: 8 · modes: menu-bar|view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs, vm, child_process

### `pipe-commands` — Pipe Commands
- dir: `pipe-commands` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `pipedrive` — Pipedrive Search
- dir: `pipedrive` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `pixabay` — Pixabay
- dir: `pixabay` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `placeholder` — Placeholder
- dir: `placeholder` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `planning-center-api-docs` — Planning Center API Docs
- dir: `planning-center-api-docs` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `planwell` — PlanWell
- dir: `planwell` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `playback-duration-calculator` — Playback Duration Calculator
- dir: `playback-duration-calculator` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `playnite-launcher` — Playnite Launcher
- dir: `playnite-launcher` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `plexamp` — Plexamp
- dir: `plexamp` · commands: 8 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `plexus` — Plexus - Localhost Search
- dir: `plexus` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, net, fs

### `pocket` — Pocket
- dir: `pocket` · commands: 6 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `podcasts-now` — Podcasts Now
- dir: `podcasts-now` · commands: 2 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `pokedex` — Pokédex
- dir: `pokedex` · commands: 8 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `polidict` — Polidict
- dir: `polidict` · commands: 6 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `pomodoro` — Pomodoro
- dir: `pomodoro` · commands: 5 · modes: menu-bar|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process

### `popicons` — Popicons
- dir: `popicons` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): dns, fs

### `porkbun` — Porkbun
- dir: `porkbun` · commands: 8 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `port-from-project-name` — Port from Project Name
- dir: `port-from-project-name` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `port-manager` — Port Manager
- dir: `port-manager` · commands: 4 · modes: no-view|view|menu-bar
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `portfolio-tracker` — Portfolio Tracker
- dir: `portfolio-tracker` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `portless` — Portless Active Routes
- dir: `portless` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): fs

### `ports` — Port Manager
- dir: `ports` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `positron` — Positron
- dir: `positron` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `posthog` — PostHog
- dir: `posthog` · commands: 5 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `power-management` — Power Management
- dir: `power-management` · commands: 5 · modes: view|no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process, fs

### `powertoys-tool-runner` — PowerToys Tool Runner
- dir: `powertoys-tool-runner` · commands: 13 · modes: no-view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `pretty-pr-link` — Pretty PR Link
- dir: `pretty-pr-link` · commands: 2 · modes: no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `prism-launcher` — Prism Launcher
- dir: `prism-launcher` · commands: 3 · modes: view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads); uses Node built-ins (ok in trusted mode): child_process

### `prisma-docs-search` — Prisma Docs Search
- dir: `prisma-docs-search` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `pritunl` — Connect Pritunl Vpn Tunnel
- dir: `pritunl` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `privatebin` — PrivateBin
- dir: `privatebin` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `privileges` — Privileges
- dir: `privileges` · commands: 3 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `producthunt` — Product Hunt
- dir: `producthunt` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `project-code-to-text` — Project Code to Text
- dir: `project-code-to-text` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `projects` — Projects
- dir: `projects` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `prompt-builder` — Prompt Builder
- dir: `prompt-builder` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `prompt-stash` — Prompt Stash
- dir: `prompt-stash` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `promptlab` — PromptLab
- dir: `promptlab` · commands: 7 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs, child_process

### `pronounce-the-word` — Pronounce the Word
- dir: `pronounce-the-word` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `proton-authenticator` — Proton Authenticator
- dir: `proton-authenticator` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `proton-mail` — Proton Mail
- dir: `proton-mail` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `proton-pass` — Proton Pass
- dir: `proton-pass` · commands: 5 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): fs, child_process

### `prusa` — Prusa Printer Control
- dir: `prusa` · commands: 4 · modes: view|menu-bar|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `purelymail` — Purelymail
- dir: `purelymail` · commands: 11 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `pushover` — Pushover
- dir: `pushover` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `putio` — put.io
- dir: `putio` · commands: 5 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `python` — Python
- dir: `python` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `qalc` — Qalccast
- dir: `qalc` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `qbitorrent` — qBittorrent
- dir: `qbittorrent` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `qmd` — QMD
- dir: `qmd` · commands: 13 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs, child_process

### `qoder` — Qoder
- dir: `qoder` · commands: 5 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `qq-mail` — QQ Mail
- dir: `qq-mail` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `qr-code-scanner` — QR Code Scanner
- dir: `qr-code-scanner` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `qrcode-generator` — QR Code Generator
- dir: `qrcode-generator` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `qrcp` — QRCP
- dir: `qrcp` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): http, fs

### `quarantine-manager` — Quarantine Manager
- dir: `quarantine-manager` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `query-chatgpt` — Query ChatGPT
- dir: `query-chatgpt` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `quick-access` — Quick Access
- dir: `quick-access` · commands: 3 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process

### `quick-call` — Quick Phone Call
- dir: `quick-call` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `quick-git` — Quick Git
- dir: `quick-git` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): fs

### `quick-jump` — Quick Jump
- dir: `quick-jump` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `quick-latex` — LaTeX to Image
- dir: `quick-latex` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `quick-notes` — Quick Notes
- dir: `quick-notes` · commands: 6 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `quick-open-project` — Quick Open Project
- dir: `quick-open-project` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `quick-references` — Quick References
- dir: `quick-references` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `quick-toshl` — Quick Toshl
- dir: `quick-toshl` · commands: 12 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `quick-web` — Quick Web
- dir: `quick-web` · commands: 6 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `quicklinker` — QuickLinker
- dir: `quicklinker` · commands: 2 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `quip` — Quip
- dir: `quip` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `quit-applications` — Quit Applications
- dir: `quit-applications` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `qutebrowser-tabs` — Qutebrowser Tabs
- dir: `qutebrowser-tabs` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `r2-uploader` — Cloudflare R2 File Uploader
- dir: `r2-uploader` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `rabbit-hole` — Rabbit Hole
- dir: `rabbit-hole` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs, https

### `radarr` — Radarr
- dir: `radarr` · commands: 7 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `radix` — Radix
- dir: `radix` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `raindrop-io` — Raindrop.io
- dir: `raindrop-io` · commands: 5 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `random-fart` — Random Fart
- dir: `random-fart` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `random-text-picker` — Random Text Picker
- dir: `random-text-picker` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `rapidcap` — RapidCap
- dir: `rapidcap` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `rateyourmusic-search` — Rate Your Music Search
- dir: `rateyourmusic-search` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ratingsdb` — RatingsDB
- dir: `ratingsdb` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ray-clicker` — Ray Clicker
- dir: `ray-clicker` · commands: 1 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `ray-code` — Ray Code
- dir: `ray-code` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `raycast-ai-custom-providers` — Raycast AI Custom Providers
- dir: `raycast-ai-custom-providers` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `raycast-apple-intelligence` — Apple Intelligence
- dir: `raycast-apple-intelligence` · commands: 13 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `raycast-arcade` — Raycast Arcade
- dir: `raycast-arcade` · commands: 6 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `raycast-focus-stats` — Raycast Focus Stats
- dir: `raycast-focus-stats` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs, https

### `raycast-frc` — Raycast FRC
- dir: `raycast-frc` · commands: 4 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `raycast-gemini` — Google Gemini
- dir: `raycast-gemini` · commands: 16 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs, child_process

### `raycast-google-palm` — Google PaLM
- dir: `raycast-google-palm` · commands: 10 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `raycast-ia-writer` — iA Writer
- dir: `raycast-ia-writer` · commands: 3 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `raycast-jq` — Jq
- dir: `raycast-jq` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process, fs

### `raycast-lighting-node-search` — Search Lightning Nodes
- dir: `raycast-lighting-node-search` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `raycast-motion-preview` — Motion Preview
- dir: `raycast-motion-preview` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `raycast-mux` — Mux.com
- dir: `raycast-mux` · commands: 6 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `raycast-new-instance` — New Instance
- dir: `raycast-new-instance` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `raycast-notification` — Raycast Notification
- dir: `raycast-notification` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `raycast-ollama` — Ollama AI
- dir: `raycast-ollama` · commands: 21 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `raycast-port` — Raycast Port
- dir: `raycast-port` · commands: 3 · modes: no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): child_process

### `raycast-rsync-extension` — Rsync File Transfer
- dir: `raycast-rsync-extension` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `raycast-sink` — Sink Short Links Manager
- dir: `raycast-sink` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `raycast-store-updates` — Raycast Store Updates
- dir: `raycast-store-updates` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `raycast-surge` — Surge
- dir: `surge` · commands: 5 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `raycast-svg64` — SVG64 - Convert SVGs to Base64 Strings
- dir: `raycast-svg64` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `raycast-svgo` — SVGO
- dir: `svgo` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `raycast-system-monitor` — System Monitor
- dir: `system-monitor` · commands: 2 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `raycast-wallpaper` — Raycast Wallpaper
- dir: `raycast-wallpaper` · commands: 2 · modes: view|no-view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `raycast-wca` — WCA
- dir: `raycast-wca` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `raycast-zoxide` — Zoxide
- dir: `raycast-zoxide` · commands: 2 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `raycaster` — Raycaster
- dir: `raycaster` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `raydoom` — RayDoom
- dir: `raydoom` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `raylog-markdown-tasks` — Raylog - Markdown Tasks
- dir: `raylog-markdown-tasks` · commands: 3 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `raynab` — Raynab — Manage Your Budgets
- dir: `raynab` · commands: 7 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `raytaskwarrior` — Taskwarrior
- dir: `raytaskwarrior` · commands: 3 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `razuna` — Razuna - Add and Browse Files in Razuna
- dir: `razuna` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `rclone-raycast` — rclone
- dir: `rclone-raycast` · commands: 4 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process

### `react-devtools` — React DevTools
- dir: `react-devtools` · commands: 1 · modes: no-view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `react-docs` — React Documentation
- dir: `react-docs` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `react-icons` — React Icons
- dir: `react-icons` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `read-ai` — Read AI - Text to Speech
- dir: `read-ai` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `reader-mode` — Reader Mode
- dir: `reader-mode` · commands: 3 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `readwise-reader` — Readwise Reader
- dir: `readwise-reader` · commands: 11 · modes: no-view|view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `real-calc` — Real Calc
- dir: `real-calc` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `real-debrid-manager` — Real-Debrid Manager
- dir: `real-debrid-manager` · commands: 5 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `rebaptize` — Rebaptize - Rename
- dir: `rebaptize` · commands: 40 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process, https

### `recent-excel` — Recent Excel - Show Recent Excel Files
- dir: `recent-excel` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `reclaim-ai` — Reclaim
- dir: `reclaim-ai` · commands: 6 · modes: menu-bar|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `rectangle` — Rectangle
- dir: `rectangle` · commands: 42 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `rednote-viewer` — RedNote Viewer
- dir: `rednote-viewer` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `reflect` — Reflect
- dir: `reflect` · commands: 6 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `regex-batch-renamer` — Regex Batch Renamer
- dir: `regex-batch-renamer` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `relagit` — RelaGit
- dir: `relagit` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `remember-the-date` — Remember the Date
- dir: `remember-the-date` · commands: 4 · modes: view|menu-bar|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `remember-this` — Remember This
- dir: `remember-this` · commands: 3 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `remix-icon` — Remix Icon
- dir: `remix-icon` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `remote-desktop` — Remote Desktop
- dir: `remote-desktop` · commands: 1 · modes: view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads); uses Node built-ins (ok in trusted mode): child_process

### `remove-background` — Remove Background
- dir: `remove-background` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `remove-background---replicate-api` — Remove Background
- dir: `remove-background---replicate-api` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `remove-background-powered-by-mac` — Remove Background - Powered by Mac
- dir: `remove-background-powered-by-mac` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `remove-paywall` — Remove Paywall
- dir: `remove-paywall` · commands: 3 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `rename-images-with-ai` — Rename Images with AI
- dir: `rename-images-with-ai` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `renaming` — Renaming
- dir: `renaming` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `replicate` — Replicate
- dir: `replicate` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `repo-launcher` — Repo Launcher
- dir: `repo-launcher` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `repository-manager` — Repository Manager
- dir: `repository-manager` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process, fs

### `research` — Deep Research
- dir: `deep-research` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `resend` — Resend
- dir: `resend` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `respace` — Respace
- dir: `respace` · commands: 3 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, fs

### `restart-system-processes` — Restart System Processes
- dir: `restart-system-processes` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `restore-photos` — Restore Photos
- dir: `restore-photo` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `retrace` — Retrace Quick Actions
- dir: `retrace` · commands: 3 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `reverso-context` — Reverso Context
- dir: `reverso-context` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `rhttp` — rhttp
- dir: `rhttp` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, https

### `roam-research` — Roam Research
- dir: `roam-research` · commands: 10 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `roblox` — Roblox
- dir: `roblox` · commands: 9 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `roblox-games` — Roblox
- dir: `roblox-games` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `rounding-number` — Rounding Number
- dir: `rounding-number` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `rss-reader` — RSS Reader
- dir: `rss-reader` · commands: 3 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `rsync-commands` — Rsync Commands
- dir: `rsync-commands` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `ruby-evaluate` — Ruby Evaluate
- dir: `ruby-evaluate` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `running-page` — Running Page
- dir: `running-page` · commands: 3 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `sabnzbd` — SABnzbd
- dir: `sabnzbd` · commands: 8 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `safari` — Safari
- dir: `safari` · commands: 8 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `salesforce` — Salesforce Search
- dir: `salesforce-search` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `sap-logon` — SAP GUI Connector
- dir: `sap-logon` · commands: 4 · modes: view|no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `saucenao` — SauceNAO - Reverse Image Search
- dir: `saucenao` · commands: 3 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs, child_process

### `save-clipboard` — Save Clipboard
- dir: `save-clipboard` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `save-link` — Save Link
- dir: `save-link` · commands: 3 · modes: no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `say` — Say - Text to Speech
- dir: `say` · commands: 5 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `sayintentions` — SayIntentions
- dir: `sayintentions` · commands: 4 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `scheduler` — Command Scheduler
- dir: `scheduler` · commands: 4 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `scoop` — Scoop
- dir: `scoop` · commands: 5 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `scrapbook` — Scrapbook
- dir: `scrapbook` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `scrcpy` — Scrcpy
- dir: `scrcpy` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `screen-math` — Screen Math
- dir: `screen-math` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `screen-saver` — Screen Saver
- dir: `screen-saver` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `screen-sharing-recents` — Screen Sharing Recents
- dir: `screen-sharing-recents` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `screenshot` — Screenshot
- dir: `screenshot` · commands: 8 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `script-commands` — Script Commands Store – Find and manage your Raycast Script Commands
- dir: `script-commands` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `script-kit` — Run Script Kit Command
- dir: `script-kit` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `scrycast` — Scrycast
- dir: `scrycast` · commands: 5 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `scss-compile` — SCSS Compile
- dir: `scss-compile` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `sdotee` — S.EE
- dir: `sdotee` · commands: 5 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `search-blockchain` — Search Blockchain
- dir: `search-blockchain` · commands: 13 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `search-domain` — Search Domain
- dir: `search-domain` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `search-gule-sider` — Search Gule Sider
- dir: `search-gule-sider` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `search-hookmark` — Hookmark Search
- dir: `search-hookmark` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `search-router` — Search Router
- dir: `search-router` · commands: 3 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `secret-browser-commands` — Secret Browser Commands
- dir: `secret-browser-commands` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `securecrt-sessions` — SecureCRT Sessions
- dir: `securecrt-sessions` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `seedsnote` — Seedsnote
- dir: `seedsnote` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `sefaria` — Sefaria
- dir: `sefaria` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `selfh-st-icons` — Selfh.st Icons
- dir: `selfh-st-icons` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `send-ai` — SendAI
- dir: `send-ai` · commands: 13 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `send-to-e-reader` — Send to E-Reader
- dir: `send-to-e-reader` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `send-to-kindle` — Send to Kindle
- dir: `send-to-kindle` · commands: 6 · modes: no-view|view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): net, tls, fs, child_process

### `sendme` — Sendme File Share
- dir: `sendme` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `sensible` — Sensible - Document Data Extraction
- dir: `sensible` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `seo-lighthouse` — SEO Lighthouse
- dir: `seo-lighthouse` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `sequel-ace` — Sequel Ace
- dir: `sequel-ace` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `sequoia-tiling` — Sequoia Window Tiling
- dir: `sequoia-tiling` · commands: 23 · modes: no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `series-rating-graphs` — Series Rating Graphs
- dir: `series-rating-graphs` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `servicenow` — ServiceNow
- dir: `servicenow` · commands: 15 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `sesh` — Sesh
- dir: `sesh` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `setapp` — Setapp
- dir: `setapp` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `seventv-search` — 7TV Emotes Search
- dir: `seventv-search` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `sf-symbols-search` — SF Symbols Search
- dir: `sf-symbols-search` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `share-a-quote` — Share a Quote
- dir: `share-a-quote` · commands: 1 · modes: no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `share-my-code` — Share My Code
- dir: `share-my-code` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `sharex` — ShareX
- dir: `sharex` · commands: 9 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs, child_process

### `shell` — Shell
- dir: `shell` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, fs

### `shell-alias` — Shell Alias
- dir: `shell-alias` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `shell-buddy` — Shell Buddy
- dir: `shell-buddy` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `shell-history` — Shell History
- dir: `shell-history` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `shiftplus` — ShiftPlus
- dir: `shiftplus` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `shiori-sh` — Shiori
- dir: `shiori-sh` · commands: 4 · modes: view|no-view|menu-bar
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `shodan` — Shodan
- dir: `shodan` · commands: 9 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `shopify-polaris-docs` — Shopify Polaris Docs
- dir: `shopify-polaris-docs` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `shortcuts-search` — Shortcuts Search
- dir: `shortcuts-search` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `shottr` — Shottr
- dir: `shottr` · commands: 14 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `shutdown-timer` — Shutdown Timer
- dir: `shutdown-timer` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `sidecar` — Sidecar
- dir: `sidecar` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `silent-mention` — Silent Mention
- dir: `silent-mention` · commands: 2 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `silent-mode` — Silent Mode
- dir: `silent-mode` · commands: 4 · modes: no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `similarweb` — Similarweb
- dir: `similarweb` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `simon` — Simon
- dir: `simon` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `simple-dictionary` — Simple Dictionary
- dir: `simple-dictionary` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `simple-http` — Simple Http
- dir: `simple-http` · commands: 2 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process

### `simple-icons` — Brand Icons - simpleicons.org
- dir: `simple-icons` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `simple-memo` — Simple Memo
- dir: `simple-memo` · commands: 3 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `simple-reminder` — Simple Reminder
- dir: `simple-reminder` · commands: 3 · modes: view|no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process

### `simple-youdao` — Simple Youdao Translate
- dir: `simple-youdao` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `simpletexocr` — SimpleTexOCR
- dir: `simpletexocr` · commands: 2 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `simpread` — SimpRead
- dir: `simpread` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `simulator-control` — Simulator Control
- dir: `simctl` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `simulator-manager` — Simulator Manager
- dir: `simulator-manager` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `single-disk-eject` — Single Disk Eject
- dir: `single-disk-eject` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `sips` — Image Modification
- dir: `sips` · commands: 12 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs, child_process, https

### `siri` — Siri
- dir: `siri` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `sitespeakai` — SiteSpeakAI
- dir: `sitespeakai` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `skills` — Skills
- dir: `skills` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `slack` — Slack
- dir: `slack` · commands: 9 · modes: view|no-view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `slack-status` — Slack Status
- dir: `slack-status` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `slack-summarizer` — Slack Summarizer
- dir: `slack-summarizer` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `slack-templated-message` — Slack Templated Message
- dir: `slack-templated-message` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `slackmojis` — Slackmojis
- dir: `slackmojis` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `sleep-timer` — Sleep Timer
- dir: `sleep-timer` · commands: 8 · modes: no-view|view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, fs

### `slowed-reverb` — Slowed + Reverb
- dir: `slowed-reverb` · commands: 4 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `slugify` — Slugify
- dir: `slugify` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `slugify-file-folder-names` — Slugify File / Folder Names
- dir: `slugify-file-folder-names` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `smallweb` — Smallweb
- dir: `smallweb` · commands: 2 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): fs

### `smart-calendars-ai-create-events-using-ai` — Smart Calendars AI – Create Events / Reminders Using AI
- dir: `smart-calendars-ai-create-events-using-ai` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `snap-jot` — SnapJot
- dir: `snap-jot` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `snapask` — SnapAsk
- dir: `snapask` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `snapocr-via-paddle` — SnapOCR Via Paddle
- dir: `snapocr-via-paddle` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `snippetslab` — SnippetsLab
- dir: `snippetslab` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `snippetsurfer` — Snippet Surfer
- dir: `snippetsurfer` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `solana_nodes` — Solana Nodes
- dir: `nodes` · commands: 2 · modes: menu-bar|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `somafm` — SomaFM
- dir: `somafm` · commands: 2 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process

### `sonos` — Sonos
- dir: `sonos` · commands: 7 · modes: no-view|view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `sort-mentions` — Sort Mentions
- dir: `sort-mentions` · commands: 2 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `soundboard` — Soundboard
- dir: `soundboard` · commands: 11 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process

### `sourcegraph` — Sourcegraph
- dir: `sourcegraph` · commands: 7 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): http

### `sourcegraph-amp-dash-x` — Amp Dash X
- dir: `sourcegraph-amp-dash-x` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `sourcetree` — Sourcetree
- dir: `sourcetree` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `spacer` — Spacer
- dir: `spacer` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `spaces` — Spaces
- dir: `spaces` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `spaceship` — Spaceship
- dir: `spaceship` · commands: 2 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `spanish-tv-guide` — Spanish TV Guide
- dir: `spanish-tv-guide` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `specify` — Specify
- dir: `specify` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `speech-to-text` — Speech to Text
- dir: `speech-to-text` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process

### `speed-dial` — Speed Dial
- dir: `speed-dial` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `speedtest` — Speedtest
- dir: `speedtest` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `spiceblow-database` — Spiceblow - Sql Database Management
- dir: `spiceblow-database` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `spirii-go` — Spirii Go
- dir: `spirii-go` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `split-video-scenes` — Split Video Scenes
- dir: `split-video-scenes` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `spotify-controls` — Spotify Controls
- dir: `spotify-controls` · commands: 22 · modes: no-view|menu-bar
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `spotify-player` — Spotify Player
- dir: `spotify-player` · commands: 35 · modes: view|menu-bar|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); runPowerShellScript: Windows-only; throws on macOS (import loads); declares command `arguments[]` — not passed by runtime yet

### `spring-initializr` — Spring Initializr
- dir: `spring-initializr` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `ssh-manager` — SSH Connection Manager
- dir: `ssh-manager` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `ssh-tunnel-manager` — SSH Tunnel Manager
- dir: `ssh-tunnel-manager` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process

### `stablecog` — Stablecog
- dir: `stablecog` · commands: 5 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `stackoverflow` — Search Stack Exchange Sites
- dir: `stackoverflow` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `stacks` — Stacks
- dir: `stacks` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `stardew-valley-wiki` — Stardew Vally Character Search
- dir: `stardew-valley-wiki` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `stashit` — Stashit
- dir: `stashit` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `static-marks` — Static Marks - Bookmark Search
- dir: `static-marks-bookmarks` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `stealth-ai-tool` — Stealth AI
- dir: `stealth-ai-tool` · commands: 10 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process, https

### `steam` — Steam
- dir: `steam` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `steamgriddb` — SteamGridDB
- dir: `steamgriddb` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `stickies` — Stickies
- dir: `stickies` · commands: 7 · modes: view|menu-bar|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process

### `storybook-sandboxes` — Storybook Sandboxes
- dir: `storybook-sandboxes` · commands: 2 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `streamshare-uploader` — Streamshare Uploader
- dir: `to-streamshare` · commands: 4 · modes: no-view|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `stretchly` — Stretchly
- dir: `stretchly` · commands: 2 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `stripe` — Stripe
- dir: `stripe` · commands: 16 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `sublime` — Sublime
- dir: `sublime` · commands: 7 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `subnoto` — Subnoto - Confidential Electronic Signature
- dir: `subnoto` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `summarize-youtube-video-with-ai` — Summarize YouTube Videos with AI
- dir: `summarize-youtube-video-with-ai` · commands: 5 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `supabase-cron-monitor` — Supabase Cron Monitor
- dir: `supabase-cron-monitor` · commands: 3 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `supernotes` — Supernotes
- dir: `supernotes` · commands: 4 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `supernova` — Supernova
- dir: `supernova` · commands: 6 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `superwhisper` — Superwhisper - Offline Voice to Text
- dir: `superwhisper` · commands: 6 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `surfed` — Surfed
- dir: `surfed` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `surl` — Surl
- dir: `surl` · commands: 2 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `svg-studio` — SVG Studio
- dir: `svg-studio` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `svgl` — Svgl
- dir: `svgl` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `svgr` — SVGR
- dir: `svgr` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `swift-command` — Swift Command
- dir: `swift-command` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `swift-repl` — Swift REPL
- dir: `swift-repl` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `swipe-photo-cleaner` — Swipe Photo Cleaner
- dir: `swipe-photo-cleaner` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `sync-folders` — Sync Folders
- dir: `sync-folders` · commands: 6 · modes: menu-bar|view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs, child_process

### `synonyms` — Synonyms
- dir: `synonyms` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `system-information` — System Information
- dir: `system-information` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `t3-chat` — T3 Chat
- dir: `t3-chat` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `tabby` — Tabby
- dir: `tabby` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `tableplus` — TablePlus
- dir: `tableplus` · commands: 2 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `tablepro` — TablePro
- dir: `tablepro` · commands: 9 · modes: view|no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `tabler` — Tabler
- dir: `tabler` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `tabstash` — TabStash
- dir: `tabstash` · commands: 2 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `tails` — Tails
- dir: `tails` · commands: 4 · modes: view|no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `tailscale` — Tailscale
- dir: `tailscale` · commands: 11 · modes: view|no-view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `tailwindcss` — Tailwind CSS
- dir: `tailwindcss` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `teak-raycast` — Teak
- dir: `teak-raycast` · commands: 8 · modes: view|no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `team-time` — Team Time
- dir: `team-time` · commands: 4 · modes: view|no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `telegram` — Telegram
- dir: `telegram` · commands: 5 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `teleport` — Teleport
- dir: `teleport` · commands: 6 · modes: no-view|view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `tempmail` — TempMail
- dir: `tempmail` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `terminal-image-paste` — Terminal Image Paste
- dir: `terminal-image-paste` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `terminalfinder` — Terminal Finder
- dir: `terminalfinder` · commands: 22 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `tesla-energy` — Tesla Energy
- dir: `tesla-energy` · commands: 2 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `text-decorator` — Text Decorator
- dir: `text-decorator` · commands: 3 · modes: no-view|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `text-differ` — Text Differ
- dir: `text-differ` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `text-replacements` — Text Replacements
- dir: `text-replacements` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `textream` — Textream
- dir: `textream` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `texts` — Texts
- dir: `texts` · commands: 3 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `tflink-tmpfile` — Tflink Tmpfile
- dir: `tflink-tmpfile` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `the-blue-cloud` — The Blue Cloud
- dir: `the-blue-cloud` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `the-nobel-prize` — The Nobel Prize
- dir: `the-nobel-prize` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `thesvg` — TheSVG
- dir: `thesvg` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `things` — Things
- dir: `things` · commands: 10 · modes: view|menu-bar|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, fs

### `thock` — Thock
- dir: `thock` · commands: 2 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `threads` — Threads
- dir: `threads` · commands: 9 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `ticktick` — TickTick
- dir: `ticktick` · commands: 6 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `tidal` — Tidal
- dir: `tidal` · commands: 12 · modes: menu-bar|view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process, fs, http

### `tidyread---streamline-your-daily-reading` — TidyRead - Streamline Your Daily Reading
- dir: `tidyread---streamline-your-daily-reading` · commands: 5 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs, http, child_process

### `tikz` — TikZ
- dir: `tikz` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `tim` — Tim
- dir: `tim` · commands: 7 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `time-awareness` — Time Awareness
- dir: `time-awareness` · commands: 1 · modes: menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `time-logs` — Time Logs
- dir: `time-logs` · commands: 6 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `time-machine` — Time Machine
- dir: `time-machine` · commands: 4 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `time-tracking` — Time Tracking
- dir: `time-tracking` · commands: 5 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `timers` — Timers
- dir: `timers` · commands: 19 · modes: no-view|view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, fs

### `tinyimg` — TinyIMG
- dir: `tinyimg` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `tinypng` — TinyPNG
- dir: `tinypng` · commands: 2 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `tip-calculator` — Tip Calculator
- dir: `tip-calculator` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `tl-dr-ai-summary-tool` — TL;DR (Too Long; Didn't Read)
- dir: `tl-dr-ai-summary-tool` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `tldraw` — tldraw
- dir: `tldraw` · commands: 3 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `tldv` — Tldv Meetings
- dir: `tldv` · commands: 4 · modes: view|menu-bar|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `tmux-cheatsheet` — Tmux Cheatsheet
- dir: `tmux-cheatsheet` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `tmux-sessioner` — Tmux Sessioner
- dir: `tmux-sessioner` · commands: 4 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process, fs

### `todo-list` — Todo List
- dir: `todo-list` · commands: 2 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `todoist` — Todoist
- dir: `todoist` · commands: 11 · modes: view|no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `toggl-track` — Toggl Track
- dir: `toggl-track` · commands: 7 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process

### `toggle-desktop-visibility` — Toggle Desktop Visibility
- dir: `toggle-desktop-visibility` · commands: 6 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `toggle-menu-bar` — Toggle Menu Bar
- dir: `toggle-menu-bar` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `toggle-proxy` — Toggle Proxy
- dir: `toggle-proxy` · commands: 6 · modes: menu-bar|view
- Degraded: uses Node built-ins (ok in trusted mode): fs, net

### `toggle-scroll-bars-visibility` — Toggle Scroll Bars Visibility
- dir: `toggle-scroll-bars-visibility` · commands: 5 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `toneclone` — ToneClone
- dir: `toneclone` · commands: 7 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): fs

### `toothpick` — Toothpick
- dir: `toothpick` · commands: 19 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs, child_process

### `torbox` — TorBox
- dir: `torbox` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `torr-manager` — Torr Manager
- dir: `torr-manager` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `tourbox` — TourBox
- dir: `tourbox` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `tower` — Tower Repositories
- dir: `tower` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `trackflight` — Flight Tracker
- dir: `trackflight` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `tradingview-controls` — TradingView Controls
- dir: `tradingview-controls` · commands: 5 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `trakt-manager` — Trakt Manager
- dir: `trakt-manager` · commands: 7 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `transfer-sh_upload` — Transfer.sh Uploader
- dir: `transfer-sh_upload` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `translate` — Google Translate
- dir: `google-translate` · commands: 6 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): https, child_process, fs

### `translate-send-webpage-to-reader` — Translate and Send Webpage to Reader
- dir: `translate-send-webpage-to-reader` · commands: 1 · modes: no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired)

### `transmission` — Transmission
- dir: `transmission` · commands: 3 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `transport-nsw` — Transport NSW
- dir: `transport-nsw` · commands: 2 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `trek` — Trek
- dir: `trek` · commands: 6 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `trovu` — Trovu - Web Search Command Line
- dir: `trovu` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `try` — Try
- dir: `try` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `turso` — Turso
- dir: `turso` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): http

### `twitch` — Twitch
- dir: `twitch` · commands: 4 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process

### `twitch-logs` — Twitch Logs
- dir: `twitch-logs` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `twitter-video-downloader` — X/Twitter Video Downloader
- dir: `twitter-video-downloader` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `two-factor-authentication-code-generator` — Two-Factor Authentication Code Generator
- dir: `two-factor-authentication-code-generator` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `typewhisper` — TypeWhisper
- dir: `typewhisper` · commands: 5 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `typora-note-creator` — Typora Note Creator
- dir: `typora-note-creator` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `u301-url-shortener` — U301 URL Shortener
- dir: `u301-url-shortener` · commands: 3 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `ugly-face` — Ugly Face
- dir: `ugly-face` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `unblocked-answers` — Unblocked Answers
- dir: `unblocked-answers` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `unicode-symbols` — Unicode Symbols Search
- dir: `unicode-symbols` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `unifi` — Unifi
- dir: `unifi` · commands: 4 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): https

### `universal-commands` — Universal Commands
- dir: `universal-commands` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `unpackr` — Unpackr
- dir: `unpackr` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `unsplash` — Unsplash
- dir: `unsplash` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `update-clash-subscription` — Update Clash Subscription
- dir: `update-clash-subscription` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `uploaderx` — UploaderX
- dir: `uploaderx` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, https

### `uploadthing` — UploadThing
- dir: `uploadthing` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `upnote` — UpNote
- dir: `upnote` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `upset-dev` — Upset.dev
- dir: `upset-dev` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `uptime` — Uptime
- dir: `uptime` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `uranium-raycast-plugin` — NFT Primitive Tools
- dir: `uranium-raycast-plugin` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `urban-dictionary` — Urban Dictionary Search
- dir: `urban-dictionary` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `url-editor-pro` — URL Editor Pro
- dir: `url-editor-pro` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `url-shortener` — URL Shortener
- dir: `url-shortener` · commands: 2 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `userplane` — Userplane
- dir: `userplane` · commands: 4 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `utm-campaign-builder` — UTM Campaign Builder
- dir: `utm-campaign-builder` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `utm-virtual-machines` — UTM Virtual Machines
- dir: `utm-virtual-machines` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `uuid-generator` — UUID Generator
- dir: `uuid-generator` · commands: 9 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `v0-by-vercel` — v0 by Vercel
- dir: `v0-by-vercel` · commands: 6 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `v2box-control` — V2BOX VPN
- dir: `v2box-control` · commands: 4 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `vaib` — vAIb - Your AI Companion
- dir: `vaib` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `vat-calculator` — VAT Calculator
- dir: `vat-calculator` · commands: 3 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `vatlayer` — vatlayer
- dir: `vatlayer` · commands: 6 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `vault-manager` — Vault Manager
- dir: `vault` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): http, fs

### `vercast` — Vercel
- dir: `vercast` · commands: 9 · modes: view|menu-bar|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `verify-number` — Verify Number
- dir: `verify-number` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `vesslo` — Vesslo
- dir: `vesslo` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `viacep` — ViaCEP
- dir: `viacep` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `video-call-reactions` — Video Call Reactions
- dir: `video-call-reactions` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `video-converter` — Video Converter
- dir: `video-converter` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `video-downloader` — Video Downloader
- dir: `video-downloader` · commands: 1 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): child_process, fs

### `vikunja` — Vikunja Task Manager
- dir: `vikunja` · commands: 4 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `vim-leader-key` — Vim Leader Key - Keyboard Shortcut Sequences
- dir: `vim-leader-key` · commands: 4 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): child_process, fs

### `virtual-desktop-manager` — Virtual Desktop Manager
- dir: `virtual-desktop-manager` · commands: 35 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `virtualbox-power-switch` — VirtualBox Power Switch
- dir: `virtualbox-power-switch` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox

### `virustotal` — VirusTotal
- dir: `virustotal` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): net, fs

### `visual-studio-code` — Visual Studio Code
- dir: `visual-studio-code-recent-projects` · commands: 6 · modes: view|no-view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads); uses Node built-ins (ok in trusted mode): fs, child_process

### `vivaldi` — Vivaldi
- dir: `vivaldi` · commands: 5 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `vivapb` — VivaPB
- dir: `vivapb` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `vixai` — Vixai
- dir: `vixai` · commands: 5 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `vlc` — VLC
- dir: `vlc` · commands: 22 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `vmware-vcenter` — VMware VCenter
- dir: `vmware-vcenter` · commands: 4 · modes: view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `vocabuilder` — VocaBuilder
- dir: `vocabuilder` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `voice-to-text-windows` — Voice-to-Text for Windows
- dir: `voice-to-text-windows` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `voiceink` — VoiceInk
- dir: `voiceink` · commands: 1 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): fs

### `voicemeeter-raycast` — Voicemeeter Control
- dir: `voicemeeter-raycast` · commands: 5 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `vortex` — Vortex
- dir: `vortex` · commands: 4 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `vps-explorer` — VPS Explorer
- dir: `vps-explorer` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `vscode-project-manager` — Visual Studio Code - Project Manager
- dir: `visual-studio-code-project-manager` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `waktu-solat` — Waktu Solat
- dir: `waktu-solat` · commands: 2 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `wallhaven` — Wallhaven
- dir: `wallhaven` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `warp` — Warp
- dir: `warp` · commands: 5 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `watchkey` — Watchkey
- dir: `watchkey` · commands: 5 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `wayback-machine` — Wayback Machine
- dir: `wayback-machine` · commands: 4 · modes: no-view|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `weather` — Weather
- dir: `weather` · commands: 2 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `web-audit` — Web Audit
- dir: `web-audit` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `web-blocker` — Web Blocker
- dir: `web-blocker` · commands: 5 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `webbites` — WebBites
- dir: `webbites` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `webdav-uploader` — WebDAV Uploader
- dir: `webdav-uploader` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `webpage-to-markdown` — Webpage to Markdown
- dir: `webpage-to-markdown` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `website-blocker` — Website Blocker
- dir: `website-blocker` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `wechat` — WeChat
- dir: `wechat` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process, fs

### `wechat-devtool` — WeChat DevTool
- dir: `wechat-devtool` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `week-number` — Week Number
- dir: `week-number` · commands: 2 · modes: menu-bar|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `weread-sync` — WeRead Sync
- dir: `weread-sync` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): https

### `wezterm-navigator` — WezTerm Navigator
- dir: `wezterm-navigator` · commands: 4 · modes: view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; uses Node built-ins (ok in trusted mode): child_process, fs

### `whatsapp` — WhatsApp
- dir: `whatsapp` · commands: 4 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `whisper` — Whisper - Share Secrets
- dir: `whisper` · commands: 2 · modes: no-view|view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `whisper-dictation` — Whisper Dictation
- dir: `whisper-dictation` · commands: 5 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process, fs, https

### `whitebit` — WhiteBIT Exchange
- dir: `whitebit` · commands: 7 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `whmcs-client-search` — WHMCS Client Search
- dir: `whmcs-client-search` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `whois` — Whois
- dir: `whois` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `whosampled` — WhoSampled
- dir: `whosampled` · commands: 3 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `wi-fi` — Wi-Fi
- dir: `wi-fi` · commands: 2 · modes: no-view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process

### `wifi-password-reveal` — WiFi Password Reveal
- dir: `wifi-password-reveal` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `wifi-share` — Wifi Share QR-Code
- dir: `wifi-share` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `wikipedia` — Wikipedia
- dir: `wikipedia` · commands: 4 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `windmill` — Windmill
- dir: `windmill` · commands: 4 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `window-walker` — Window Walker
- dir: `window-walker` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `windows-default-wallpapers` — Windows Default Wallpapers
- dir: `windows-default-wallpapers` · commands: 1 · modes: view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `windows-domain` — Windows Domain
- dir: `windows-domain` · commands: 2 · modes: view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads)

### `windows-environment-variables` — Windows Environment Variables
- dir: `windows-environment-variables` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): child_process, fs

### `windows-terminal` — Windows Terminal
- dir: `windows-terminal` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `windows-to-linux-path` — Windows to Linux Path
- dir: `windows-to-linux-path` · commands: 2 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `windsurf` — Windsurf Extension
- dir: `windsurf` · commands: 2 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `winget` — WinGet
- dir: `winget` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `winscp` — WinSCP
- dir: `winscp` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `winutils` — Winutils
- dir: `winutils` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `wip` — WIP
- dir: `wip` · commands: 4 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `wireguard` — Wireguard
- dir: `wireguard` · commands: 2 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `wise-accounts` — Wise Accounts
- dir: `wise-accounts` · commands: 4 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `wise-quotes` — Wise Quotes
- dir: `wise-quotes` · commands: 2 · modes: view|menu-bar
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `wispr-flow` — Wispr Flow
- dir: `wispr-flow` · commands: 8 · modes: view|no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `withings-sync` — Withings Sync
- dir: `withings-sync` · commands: 3 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `wiz-controller` — Wiz Controller
- dir: `wiz-controller` · commands: 5 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): dgram

### `wol` — Wake-On-LAN
- dir: `wol` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, dgram, net

### `woocommerce-quicker` — WooCommerce Quicker
- dir: `woocommerce-quicker` · commands: 4 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): https

### `word-research` — Word Research
- dir: `word-research` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `word4you` — Word4you
- dir: `word4you` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs, https, child_process

### `wordle` — Wordle
- dir: `wordle` · commands: 3 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `wordreference` — WordReference Dictionary Translation
- dir: `wordreference` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `workouts` — Workouts
- dir: `workouts` · commands: 6 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `worktrees` — Git Worktrees
- dir: `worktrees` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `world-clock` — World Clock
- dir: `world-clock` · commands: 3 · modes: view|menu-bar
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): net

### `wp-bones` — WP Bones
- dir: `wp-bones` · commands: 5 · modes: menu-bar|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `wppb` — WPPB
- dir: `wppb` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `wrap-text` — Wrap Text
- dir: `wrap-text` · commands: 6 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `wrap-unwrap` — Wrap Unwrap
- dir: `wrap-unwrap` · commands: 2 · modes: no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `writersbrew` — Writersbrew
- dir: `writersbrew` · commands: 21 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `wsl-manager` — WSL Manager
- dir: `wsl-manager` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `wu-bi-bian-ma` — Wubi Code
- dir: `wu-bi-bian-ma` · commands: 2 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `xcode` — Xcode
- dir: `xcode` · commands: 21 · modes: menu-bar|view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs, child_process

### `xcode-cloud` — Xcode Cloud
- dir: `xcode-cloud` · commands: 2 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `xcodes` — Xcodes
- dir: `xcodes` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `xecutor` — Xecutor
- dir: `xecutor` · commands: 2 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `xiaohe-query` — Xiaohe Query
- dir: `xiaohe-query` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `xpf-converter` — XPF to EUR Converter
- dir: `xpf-converter` · commands: 1 · modes: no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `yabai` — Yabai
- dir: `yabai` · commands: 31 · modes: no-view|menu-bar|view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `yafw` — YAFW
- dir: `yafw` · commands: 7 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process, fs

### `yasb` — YASB
- dir: `yasb` · commands: 12 · modes: no-view|view
- Degraded: useExec: only runs in trusted (unsandboxed) extensions; throws in sandbox; declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): child_process

### `year-in-progress` — Year in Progress
- dir: `year-in-progress` · commands: 3 · modes: no-view|menu-bar|view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired)

### `yoink` — Yoink
- dir: `yoink` · commands: 1 · modes: no-view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `yomicast` — Yomicast – Offline Japanese-English Dictionary
- dir: `yomicast` · commands: 2 · modes: view|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); uses Node built-ins (ok in trusted mode): fs

### `your-name-in-landsat` — Your Name in Landsat
- dir: `your-name-in-landsat` · commands: 2 · modes: view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `youtube` — YouTube
- dir: `youtube` · commands: 4 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `youtube-highlights` — YouTube Highlights
- dir: `youtube-highlights` · commands: 5 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): child_process, fs

### `youtube-thumbnail` — YouTube Thumbnail
- dir: `youtube-thumbnail` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `yubikey-code` — YubiKey Code
- dir: `yubikey-code` · commands: 1 · modes: view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); uses Node built-ins (ok in trusted mode): child_process, fs

### `zacks-stock-ranking` — Zacks Stock Ranking
- dir: `zacks-stock-ranking` · commands: 3 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `zeabur` — Zeabur
- dir: `zeabur` · commands: 9 · modes: view|menu-bar
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `zed-recent-projects` — Zed
- dir: `zed-recent-projects` · commands: 3 · modes: no-view|view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads); uses Node built-ins (ok in trusted mode): fs, child_process

### `zen-browser` — Zen Browser
- dir: `zen-browser` · commands: 6 · modes: view|no-view
- Degraded: runPowerShellScript: Windows-only; throws on macOS (import loads); uses Node built-ins (ok in trusted mode): child_process, fs

### `zen-mode` — Zen Mode
- dir: `zen-mode` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): child_process

### `zenmux-manager` — ZenMux Manager
- dir: `zenmux-manager` · commands: 2 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): fs, child_process

### `zerion` — Zerion
- dir: `zerion` · commands: 9 · modes: view|menu-bar|no-view
- Degraded: launchCommand: loads; throws if called (inter-command launch not wired); declares command `arguments[]` — not passed by runtime yet

### `zipcodebase` — Zipcodebase
- dir: `zipcodebase` · commands: 8 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `zipic` — Zipic
- dir: `zipic` · commands: 3 · modes: no-view|view
- Degraded: uses Node built-ins (ok in trusted mode): fs, https, http, child_process

### `zipline` — Zipline
- dir: `zipline` · commands: 4 · modes: view|no-view
- Degraded: declares command `arguments[]` — not passed by runtime yet; uses Node built-ins (ok in trusted mode): fs

### `zipper-run` — Run Zipper Applet
- dir: `zipper-run` · commands: 1 · modes: view
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `zoom` — Zoom
- dir: `zoom` · commands: 5 · modes: view|no-view|menu-bar
- Degraded: declares command `arguments[]` — not passed by runtime yet

### `zotero` — Search Zotero
- dir: `zotero` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `zoxide-git-projects` — Zoxide Git Projects
- dir: `zoxide-git-projects` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `zread-ai` — Zread.ai
- dir: `zread-ai` · commands: 2 · modes: no-view
- Degraded: BrowserExtension: loads; throws if called (browser bridge not wired); declares command `arguments[]` — not passed by runtime yet

### `zsh-aliases` — Zsh Aliases
- dir: `zsh-aliases` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

### `zshrc-manager` — Zshrc Manager
- dir: `zshrc-manager` · commands: 1 · modes: view
- Degraded: uses Node built-ins (ok in trusted mode): fs

## SUPPORTED (1502)

`1loc`, `2fa-directory`, `5devs`, `8-ball`, `8-divide`, `aave-search`, `acqua`, `active-mississaugua`, `adguard-home`, `adhan-time`, `ado-search`, `adonisjs-documentation`, `advanced-replace`, `advice-slip`, `affine`, `ai-by-vercel`, `ai-code-namer`, `ai-humanizer`, `ai-stats`, `ai-text-to-calendar`, `ai-usage-tracker`, `aimlab`, `airplane`, `airpods-noise-control`, `airport`, `airsy`, `airsync`, `aiven`, `aleph`, `aliyun-flow`, `alloy`, `alpaca-trading`, `alpinejs`, `alwaysdata`, `amazon-search`, `amphetamine`, `analog-film-library`, `android-versions`, `anilist-airing-schedule`, `anki`, `anna-s-archive`, `antisocials`, `anybox`, `anycoffee`, `anytype`, `apify`, `apis-guru-search`, `appgrid`, `apple-books`, `apple-developer-docs`, `apple-devices`, `apple-stocks-search`, `apply-inline-code`, `appwrite`, `arabic-keyboard`, `aranet-co2-monitor`, `arc-helper`, `arca`, `archisteamfarm`, `are-na`, `array-this`, `ars-technica`, `arxiv`, `asana`, `asciimath-to-latex-converter`, `asoiaf`, `asyncapi`, `atomberg-raycast-extension`, `atomic`, `attio`, `audio-writer`, `auth0-management`, `autumn`, `avatar`, `axios-docs`, `background-sounds`, `backstage`, `bahn-info`, `balatro-compendium`, `bamboohr`, `banca-d-italia-currency-converter`, `base-stats`, `base-ui-docs`, `base64`, `bash-commands`, `battery-health`, `bazinga-tools`, `bbc-news-headlines`, `beancount-meta`, `beardtown`, `beat-per-minute`, `beehiiv`, `beeminder`, `bento`, `berlin-public-transportation`, `beszel`, `betaseries`, `better-uptime`, `betterdiscord-store`, `bhagavad-gita-quotes`, `biaodian`, `bibigpt-summarize-audiovideo-with-ai`, `big-o`, `bikeshare-station-status`, `bilibili-search`, `bing-search`, `bing-wallpaper`, `binge-clock`, `bintools`, `bitaxe-status`, `bitbucket`, `bitbucket-search-self-hosted`, `bitcoin-price`, `bitfinex`, `bitly-url-shortener`, `bitrise`, `bklit-analytics`, `blockchain-explorer-search`, `blockchain-gas-tracker`, `bmrks`, `board-game-geek`, `bonk-price`, `bookstack`, `bored`, `botpress`, `braintick`, `brasileirao-serie-a`, `brave-search`, `brave-search-with-results`, `bring`, `browser-tabs`, `bsr-entsorgung`, `bttv-emote`, `buddy`, `bugmenot`, `buildkite`, `bundesliga`, `bundlephobia-search`, `bunq`, `caaals`, `cacher`, `cal-com-share-meeting-links`, `calendar`, `calendly`, `camper-calc`, `can-i-php`, `can-i-use`, `cangjie`, `canva`, `canvascast`, `capacities`, `capture`, `carbon-code-screenshot-for-raycast`, `catenary-raycast`, `catppuccin`, `cc0-lib`, `ccf-what`, `ccfddl`, `chainscout`, `change-case`, `change-scroll-direction`, `changedetection-io`, `charming-chatgpt`, `chartmogul`, `chatbase`, `chatgpt3-prompt`, `chatwork-search`, `cheatsheets`, `check-citi-bike-availability`, `checklist`, `cheetah`, `chess-com`, `chhoto`, `china-ip-address`, `chinese-character-converter`, `chinese-lottery`, `chinese-numbers`, `choose-a-license`, `chords-and-tabs`, `chronometer`, `chuck-norris-facts`, `cilium-docs`, `cinemas-nos`, `circle-ci`, `circleback`, `citation-generator`, `cl-indicators`, `clarify`, `clash`, `claude`, `claude-code-cheatsheet`, `clean-agent-text`, `clean-text`, `clear-clipboard`, `climbing-grade-converter`, `clip-swap`, `clipboard-editor`, `clipboard-formatter`, `clipboard-sequential-paste`, `clipboard-type`, `clipboard-utilities`, `clipmate`, `clipmenu`, `clockify`, `close-finder`, `cloudflare`, `cloudflare-ai`, `cloudflare-email-routing`, `cocart-docs`, `cocoa-core-data-timestamp-converter`, `coda-bookmarks-search`, `code-review-emojis`, `code-smells`, `codeblocks`, `codegeex`, `codemagic`, `codesnap`, `cognimemo`, `coin-caster`, `coinbase-pro`, `coingecko`, `coinpaprika`, `collected-notes`, `cometapi`, `comma-separator`, `commercequest`, `commit-issue-parser`, `commit-message-generator`, `commitlint`, `common-directory`, `composerize`, `confluence`, `consoledev`, `control-d`, `control-viscosity`, `conventional-comments`, `conventional-commits`, `convert-typescript-to-javascript`, `converter`, `convex`, `coolify`, `copy-notion-markdown-link`, `copy-path`, `copy-skeet-link`, `cosmic-bookmarks`, `count-numbers`, `country-lookup`, `cpf-cnpj-generator`, `cran-e-search`, `cratecast`, `creem`, `cricketcast`, `crisp`, `cron`, `cron-description`, `crunchbase`, `crypto-price`, `crypto-search`, `csfd`, `css-calculations`, `css-gg`, `css-tricks`, `cuid-generator`, `curator-bio`, `currency-exchange`, `cursor`, `cursor-costs`, `cursors`, `curto-io-url-shortener`, `customer-io`, `cyberchef`, `cypress-docs`, `dad-jokes`, `daisyui`, `daminik`, `danbooru`, `dashlane`, `dashlane-vault`, `databuddy`, `date-converter`, `days-until-christmas`, `dbt-documentation`, `dbtcloud`, `debank`, `decentraland`, `deduplicator`, `deepl-api-usage`, `defichain-dobby`, `definitelytyped`, `defiscan`, `dekudeals`, `delivery-tracker`, `deployhq`, `design-skills`, `designer-excuses`, `designer-news`, `deta-space`, `deutscherwetterdienst`, `dev-to`, `devcontainer-features`, `developer-excuse`, `devenv-docs`, `devin`, `devonthink`, `devutils`, `dex-screener`, `dexcom-reader`, `dice-and-coin`, `dice-tiles`, `dicom`, `diff-checker`, `digitalocean`, `directus`, `discogs`, `discord-timestamps`, `discordjs-documentation`, `disney`, `distraction-tracker`, `django-docs`, `djangopackages`, `dlmoji`, `dns-lookup`, `docker`, `dockerhub`, `dodo-payments`, `dog-images`, `doge-tracker`, `dokploy`, `dolar-cripto-ar`, `dolar-hoy`, `dollar-blue`, `domainr`, `done-bear`, `donut`, `doppler-share-secrets`, `dota-2`, `dotnet-api-browser`, `dotnet-docs-search`, `dotween-eases`, `douban`, `dovetail`, `dpm-lol`, `dr-news`, `dreamhost`, `dribbble`, `drug-search`, `drupal-org`, `duck-duck-go-search`, `duck-facts`, `duckduckgo-email`, `duden`, `dutch-article`, `dynamic-font-size`, `e18e-module-replacements`, `early-tools-news`, `easings`, `easyvariable`, `ebird`, `ecosia-search`, `effect-docs`, `ekstraklasa`, `element`, `elgato-key-light`, `elixir`, `elm-search`, `elron`, `ember-api-documentation`, `emissions-calculator`, `end-of-life`, `endel`, `ens-name-lookup`, `envoyer`, `epoch-to-timestamp`, `escape-regexp-characters`, `espn`, `esports-pass`, `essay`, `esv-bible`, `ethereum-gas-tracker`, `ethereum-price`, `ethereum-utils`, `eurovision-song-contest`, `evaluate-math-expression`, `evil-insult`, `evm-codes`, `excalidraw`, `excel-formula-beautifier`, `exivo`, `explain-command`, `expo`, `f1-standings`, `fabric`, `facetime`, `fake-financial-data`, `fake-swedish-personal-number`, `fakecrime-upload`, `fancy-text`, `fantasy-premier-league-rankings`, `farcaster`, `fastly`, `fastmail-masked-email`, `fathom-analytics`, `fathom-analytics-stats`, `favoro`, `fbi`, `featurebase`, `feedly`, `feishu-document-creator`, `fhir`, `fibonacci-sequence`, `figma-files-raycast-extension`, `figma-learn-companion`, `figma-shortcuts`, `figma-variables`, `filament`, `file-tree-generator`, `fillerama`, `finary`, `findnearby`, `fingertip`, `finnish-dictionary`, `firecrawl`, `firefly-iii`, `fix-language`, `flight-miles-calculator`, `fluctuation`, `fluent-outdoors`, `flux`, `flycheck-raycast`, `flypy`, `focustask`, `font-awesome`, `forgejo`, `format-graphql`, `formizee`, `framer-motion`, `frankerfacez`, `freeagent`, `freedns`, `freshrss`, `frill`, `fronius-inverter`, `ftrack`, `fuelx`, `fumadocs`, `game-scout`, `gandi`, `gcp-search`, `geist-ui-components`, `geoconverter`, `geoguesser`, `geohash-encode-decode`, `get-cat-images`, `get-direct-link`, `gg-deals`, `ghost-docs`, `gift-stardew-valley`, `git-branch-name-generator`, `git-commands`, `gitee`, `github-cli-manual`, `github-codespaces`, `github-gist`, `github-menu-bar`, `github-profile`, `github-repository-search`, `github-review-requests`, `github-spark`, `github-status`, `github-trending`, `github-users`, `gitlab-docs`, `gitmoji`, `gleam-packages`, `glide`, `glyph-search`, `go-links`, `go-package-search`, `golden-ratio`, `gomander`, `goodlinks`, `google-advanced-search`, `google-finance`, `google-fonts`, `google-meet`, `google-scholar`, `google-search`, `google-tasks`, `google-trends`, `gotify`, `govee`, `gradle-plugins`, `grafana`, `grafbase`, `grammaring`, `graphcdn`, `greip`, `grist`, `grokipedia`, `groundhog-day`, `growthbook`, `gumroad`, `habr-media`, `hacker-news`, `hackmd`, `hardcover`, `hashnode`, `hatena-bookmark`, `hazeover`, `headlines`, `hebrew-date-zmanim`, `helldivers2`, `hellonext-changelogs`, `helm-chart`, `helm-docs`, `hemolog`, `hephaestus`, `heroicons`, `hestiacp-admin`, `hetrixtools`, `hevy`, `hexlify`, `hide-all-apps`, `hide-mail`, `hidemyemail`, `holodex`, `holopin`, `homebox`, `homepage`, `homey`, `hoogle`, `host-switch`, `hostloc`, `howlongtobeat`, `hsdecks`, `html-colors`, `http-dot-cat`, `http-mime`, `hubspot`, `hugging-face`, `humaans`, `hupu`, `hyper-focus`, `iata-code-decoder`, `icd10-lookup`, `iching-divination`, `icloud-global-pricing-comparison`, `ifanr`, `image-diff-checker`, `image-host`, `imessage-2fa`, `in-the-time-zone`, `inbound`, `incident-io`, `incognito-clone`, `inertiajs-documentation`, `infomaniak`, `initium`, `inkdrop`, `inpost-parcel-lockers`, `input-source-switcher`, `inspire-search`, `instant-domain-search`, `instapaper`, `intention-clarifier`, `ionos-sync`, `ios-resolution`, `ipa-translator`, `ipcheck-ing`, `iptv`, `is-it-toxic-to`, `isdown`, `itch-io`, `jalali-date-convertor`, `james-webb-space-telescope`, `jellyfin`, `jetpack-commands`, `jira-time-tracking`, `jisho`, `jitsi`, `jotform`, `json-editor`, `json-format`, `json-to-go`, `json-to-toon-converter`, `json2ts`, `jsr`, `jsrepo`, `jue-jin`, `jup-agg`, `jurassic-ninja-site-generator`, `just-delete-me`, `justcolorpicker-raycast`, `kaalam`, `kafka-ui`, `kagi-news`, `kagi-search`, `kalshi`, `kaneo-for-raycast`, `kaomoji-search`, `keeper-security`, `keeply`, `kef-control`, `keychain-password-gen`, `keygen`, `kimi`, `kimi-for-coding`, `kind-words`, `kindle-paste`, `kinopio-inbox`, `kinopoisk`, `klu-ai`, `knowwa`, `korean-date-converter`, `korean-spell-checker`, `koyeb`, `kubernetes`, `kubernetes-docs`, `kutt`, `laby-net`, `lacinka`, `laliga`, `laracasts`, `larajobs-search`, `laravel-artisan`, `laravel-cloud`, `laravel-livewire`, `laravel-nova`, `laravel-shift`, `laravel-vapor`, `large-type`, `lark`, `lark-applink`, `latest-news`, `latex-math-symbols`, `launchdarkly`, `lavinprognoser`, `lazygit-keybindings`, `leap-new`, `learning-snacks`, `leetcode`, `lego-bricks`, `leitnerbox`, `lemmy`, `lemon-squeezy`, `lenscast`, `letta`, `lgtmeow`, `liba-ro_shortener`, `lichess-org`, `life-progress`, `lifx`, `lifx-advanced-controller`, `lightdash-navigator`, `lightning-time`, `lightshot-gallery`, `ligue-1`, `lingo-rep-raycast`, `linguee`, `link-cleaner`, `linkding`, `linux-command`, `liquipedia-matches`, `literal`, `liveblocks`, `llm-stats`, `llms-txt`, `loan-calculator`, `lobehub-icons`, `lobsters`, `logsnag`, `logtail`, `lol-esports`, `lookaway`, `lotr`, `lucide-animated`, `lucide-icons`, `luma`, `lume`, `lunatask`, `lunchmoney`, `luxafor-controller`, `lyne`, `lyrics`, `mac-app-store-search`, `macrumors`, `macstories`, `macupdater`, `magic-home`, `mail-to-self`, `mailerlite-stats`, `mailersend`, `mailtrap`, `make-dot-com`, `make-with-notion-2024`, `manage-clickup-tasks`, `mandarin-chinese-dictionary`, `manga-calendar`, `manotori`, `manus`, `manus-manager`, `marble`, `marginnote`, `markdown-codeblock`, `markdown-converter`, `markdown-preview`, `markdown-reference`, `markdown-this`, `markdown-to-jira`, `markdown-to-plain-text`, `markdown-to-rich-text`, `markprompt`, `masscode`, `mastodon-search`, `math-functions`, `matter`, `mattermost`, `mayar`, `maybe`, `mbta-tracker`, `md-to-excel`, `medialister-marketplace-helper`, `meduza`, `mem`, `mem0`, `memberstack`, `meme-generator`, `memo`, `mempool`, `menubar-weather`, `mercado-libre`, `mercury`, `metabase`, `metacritic`, `metaphor`, `meteoblue-lookup`, `metube`, `microblog`, `microsoft-teams`, `microsoft-teams-calling`, `midas`, `migadu`, `mikrus`, `minecast`, `minecraft-color-codes`, `minecraft-crafting-recipes`, `miniflux`, `minimax-ai`, `minisim`, `minttr`, `miraie-ac-control`, `mistral`, `mite`, `mittwald`, `mixpanel`, `mobius-materials`, `mochi`, `modrinth`, `modrinth-search`, `moji`, `mollie-for-raycast`, `monday-com`, `moneybird`, `moneylover`, `monkeytype`, `monobank`, `monocle`, `monse`, `monzo`, `moon-phrase`, `mousehunt-helper`, `mui-documentation`, `multi-links`, `multilinks`, `multipass`, `multiviewer`, `music-news`, `music-timer`, `musicbrainz`, `musicthread`, `must`, `mutedeck`, `mxroute`, `myanimelist-search`, `myip`, `mymind`, `mynaui-icons`, `name-com`, `namecheap`, `namuwiki`, `nano-games`, `nasa`, `nativebase-docs`, `nature-remo`, `naver-search`, `navidrome`, `nba-game-viewer`, `near-rewards`, `neodb`, `neon`, `nepali-calendar`, `nepali-date-converter`, `netease-music`, `netnewswire`, `neurooo-translate`, `new-relic`, `new-york-times`, `next-lens`, `next-run`, `nextcloud`, `nextdns`, `nfl-information`, `nft-search`, `ngrok`, `nif`, `nif-fresquinho`, `nixpkgs-search`, `nl-news-headlines`, `no-as-a-service`, `nocal`, `node-js-evaluate`, `node-release-notes`, `nordic-energy-prices`, `nos-nieuws`, `nostr`, `not-diamond`, `notaday`, `note-in-google-doc`, `notilight-controller`, `notion_researcher`, `notra`, `nouns`, `novu`, `nowplaying-cli`, `ns-nl-search`, `nsis-reference`, `nts`, `nu-nieuws`, `nuget`, `number-facts`, `numpad`, `nusmods`, `nyc-train-tracker`, `nzbget`, `obs-control`, `octopus-energy`, `odin`, `odoo-companion`, `office-quotes`, `oh-my-zsh-git-alias`, `ohdear`, `ohmyzsh-plugins`, `ok-json`, `oklch-color-converter`, `oktasearch`, `olacv`, `ollama-mind-map-generator`, `olympic-games`, `omg-lol`, `omni-news`, `one-tab-group`, `one-time-secret`, `onelook-thesaurus`, `ones`, `open-camera-menu-bar`, `open-docker`, `open-gem-documentation`, `open-in-shopify-admin`, `open-latest-url-from-clipboard`, `open-props`, `open-with-app`, `openrouter-model-search`, `openrouter-models-finder`, `openrouter-quick-actions`, `openstatus`, `openweathermap`, `opsgenie`, `orbita`, `orion`, `osrs-wiki`, `ossinsight`, `otp-inbox`, `otter`, `ottomatic`, `outline-page`, `ovhcloud`, `owledge-raycast`, `owncloud`, `ozbargain-deals`, `pagerduty`, `palette-colors`, `pandas-documentation-search`, `pangu-for-raycast`, `paperform`, `papersize`, `paperspace`, `parabol`, `parcel-tracker`, `parse`, `password-generator`, `paste-from-apple-books`, `pastebin`, `pastefy`, `pastery`, `paymenter`, `paynow`, `paypal-invoices`, `paystack`, `pbr-assistant`, `pcloud`, `penflow-ai`, `penpot`, `pera-explorer`, `perry`, `personio`, `pestphp-documentation`, `pexels`, `phare-io-uptime`, `phind-search`, `phonetic-typing`, `phosphor-icons`, `php-docs`, `php-toolbox`, `pinboard`, `pinia-docs`, `pinwork`, `pip`, `pitchcast`, `pitchfork`, `pivot`, `pkg-swap`, `plane`, `planetscale`, `planning-center`, `plausible-analytics`, `playtester`, `playwright-docs`, `plex`, `ploi`, `pm2`, `pocketbase`, `podcasts`, `pokemon-tcg-pocket-binder`, `polar`, `polars-documentation-search`, `polished`, `pollen-count`, `polymarket`, `pomo`, `popcorn`, `port`, `portal-wholesale`, `portuguese-primeira-liga`, `position-size-calculator`, `postey`, `postiz`, `postman`, `potter-db`, `premier-league`, `prettier`, `primer`, `printer-status`, `prisma-cli-commands`, `prisma-postgres`, `productboard`, `productlane`, `project-companion`, `project-hub`, `promptnote`, `prompts-chat`, `protobuf2typescript`, `proton-version`, `protondb`, `prowlarr`, `proxmox`, `proxyman`, `psn`, `pub-dev`, `public-bug-bounty-and-vulnerability-disclosure-programs`, `publico`, `publora`, `pubme`, `pulsemcp`, `pumble`, `punto`, `purpleair`, `px-to-rem-converter`, `qonto`, `qotp`, `qovery`, `qq-music-controls`, `query-domains`, `quick-access-for-zeroheight`, `quick-access-infomaniak`, `quick-event`, `quick-quit`, `quick-search`, `quickfile`, `quicksnip`, `quicktime`, `quicktype`, `quikwallet`, `quoterism-raycast`, `r-pkg-search`, `radicle`, `rae-dictionary-raycast`, `rails-routes`, `railway`, `rain-radars`, `rainaissance`, `ram-prices`, `ramda-documentation`, `random`, `random-color`, `random-date-generator`, `random-email`, `random-password-generator`, `random-us-phone-number`, `ratio-calculator`, `ray-boop`, `ray-so`, `raycafe`, `raycast-airtable-extension`, `raycast-bard-ai`, `raycast-clip`, `raycast-datadog`, `raycast-diki`, `raycast-explorer`, `raycast-fly`, `raycast-icons`, `raycast-ios-hig`, `raycast-kozip-extension`, `raycast-language-tool`, `raycast-link-lock`, `raycast-manual`, `raycast-monkeytype-theme`, `raycast-norwegian-public-transport`, `raycast-nrm`, `raycast-ordbokene`, `raycast-tapo-smart-devices`, `raycast-textlint-rule-aws-service-name`, `raycast-timeular`, `raycast-timezone-converter`, `raycast-transistorfm`, `raycast-translate-ge`, `raycast-urbandictionary-word-of-the-day`, `raycast-weekly-newsletter`, `raycast-wemo`, `raydocs`, `raytyping`, `rdir`, `rdw-kentekencheck`, `re-mind`, `react-native-directory`, `readeck`, `reading-time`, `readwise`, `readwise-to-tana`, `readymetrics`, `rebrandly`, `recap`, `recents`, `recurly`, `reddit-search`, `redirect-trace`, `redis`, `redmine`, `refresh-browsers`, `refresh-wifi`, `regex-repl`, `regex-tester`, `rehooks`, `reka-ui`, `remo-notes`, `remove-window-from-set`, `render`, `repology-search`, `rescuetime-focus-session-trigger`, `resend-wallpaper`, `resmo`, `retool-documentation`, `retrac`, `rewardful`, `rewiser`, `rg-adguard-links`, `ricescore`, `rick-and-morty`, `ring-intercom`, `risk-reward-calculator`, `rize-io-sessions`, `roblox-creator-docs`, `rocket-chat`, `roll-d20`, `rollcast`, `rollup-wtf`, `rtl-reader`, `rule-of-three`, `ruler`, `runcloud`, `rusbase`, `rust-docs`, `sadaqah-box`, `safe-secret`, `sage-hr`, `sanity`, `sat-scorer`, `sav`, `save-to-cubox`, `saved-items`, `savvycal`, `say-no-to-notch`, `scaleway`, `schoology`, `scira`, `scrapbox-search`, `scratchpad`, `screen-studio`, `screenocr`, `screenpipe`, `seafile`, `search-ansible-documentation`, `search-astro-docs`, `search-clojuredocs`, `search-composer-packagist`, `search-github-stars`, `search-hex`, `search-joplin-notes`, `search-justwatch`, `search-mdn`, `search-notion`, `search-npm`, `search-oeis`, `search-private-npm-packages`, `search-regexp`, `search-rubygems`, `search-shopify-liquid-documentation`, `search-with-algolia`, `searchcaster`, `sec-filings-search`, `security-search`, `semantic-scholar`, `send-to-flomo`, `sendportal`, `sendy`, `sentry`, `serialcast`, `serie-a`, `serverless-framework-docs`, `session`, `setlist-fm`, `sevalla`, `shadcn-svelte`, `shadcn-ui`, `shadcn-vue`, `shakespearify`, `shape-calendar`, `sharding-tools`, `shelve`, `shiori`, `ship24-client`, `shlink`, `shopify-dev-docs-search`, `shopify-developer-changelog`, `shopify-theme-resources`, `shopinfo-app`, `short-io`, `shortcut`, `shroud-email`, `sidecar-connect`, `signal`, `simple-login`, `simplebackups`, `simplelogin`, `single-focus`, `singularityapp`, `sip`, `sketch`, `skyscanner-flights`, `sm-ms`, `smallpdf`, `smart-reply`, `smartthings-connector`, `smultron`, `snake`, `sncftraintimes`, `sniffer`, `social-network-trends`, `solana-explorer`, `solana-wallets-generation`, `solidtime`, `solusvm-1-client`, `solusvm-2`, `sonarr`, `sonu-stream`, `sound-search`, `spatie-documentation`, `speedcubing`, `spell`, `spike`, `spinupwp`, `splatoon`, `splitwise`, `splix`, `spoiler-converter`, `spoqify`, `sportssync`, `spotify-beta`, `spryker-docs`, `sql-format`, `sql-reference-search`, `squeeze`, `st-andrews-main-library-occupancy`, `stagehand`, `standing-desk-tracker`, `starling`, `stashpad-docs`, `statamic-docs`, `steam-player-counts`, `stock-lookup`, `stock-tracker`, `stockholm-public-transport`, `stoicquotes`, `storyblok`, `storybook-launcher`, `storybook-search`, `storytime`, `strapi-raycast-extension`, `strftime-cheatsheet`, `string-formatter`, `subflow`, `substack`, `subwatch`, `summation`, `sun-moon-times`, `supabase`, `supabase-docs`, `supergenpass`, `superhuman`, `supermemory`, `surf-check`, `surfs-up`, `surge-outbound-switcher`, `svelte-docs`, `svga-player`, `swap-commas-dots`, `swift-evolution`, `swift-package-index`, `swiss-ov`, `swiss-train-times`, `switch-game-play-history`, `switchhosts`, `synology-download-station`, `syntax-fm`, `table-converter`, `tableau-navigator`, `tabletop-dice-roller`, `tabnews`, `tailwind-size-conversion`, `tallinn-transport`, `tally`, `tana`, `tana-paste`, `tarot`, `tasklink`, `taskplane`, `tategaki`, `tautulli`, `tc-no-generator`, `teamgantt`, `teamup-rooms`, `techcrunch`, `tella`, `tembo`, `tempo`, `temporary-email`, `tennis-standings`, `terminal`, `terminaldotshop`, `terraform-doc`, `tesla`, `teslamate`, `tex2typst`, `text-enhance`, `text-format-improver`, `text-rewrap`, `text-shortcuts`, `tfl`, `thaw`, `the-matrix-of-destiny`, `the-noble-quran`, `the-verge`, `thermoconvert`, `thesaurus`, `thingiverse`, `thrasher-magazine`, `threads-video-downloader`, `tibia-helper`, `tidal-controller`, `tiktoken`, `time`, `time-calculator`, `time-converter`, `time-logger`, `time-teller`, `time-until-i-do`, `timecamp`, `timecrowd-tracker`, `timely`, `timezone-buddy`, `tints-and-shades`, `tiny-tycho`, `tinyfaces-nft`, `tldr`, `tmdb`, `tny`, `toggle-fn`, `toggle-grayscale`, `tokenizer`, `tomito-controls`, `ton-address`, `toncoin-price`, `toolbox`, `transform`, `translit`, `transmit`, `trello`, `trenit`, `trimmy`, `trustmrr`, `truth-or-dare`, `tscheck-in`, `tududi`, `tuneblade`, `tunnelblick`, `tuple`, `tuya-smart`, `tv-remote`, `tv2---denmark`, `tw-colorpicker`, `twenty`, `twingate`, `twitch-chat`, `twitter`, `twitter-trendscast`, `twos`, `tyme-3-time-tracker`, `tynyfy`, `type-snob`, `type-the-alphabet`, `typeform`, `typefully`, `typer`, `typescript-documentation-search`, `typescript-mock-generator`, `typographer`, `typst-symbols`, `typst-universe`, `udemy-coupons`, `uk-bank-holidays`, `ulid`, `ultrahuman`, `ulysses`, `umami`, `unify-path-separator`, `unirate-currency`, `united-nations`, `unitex`, `universal-inbox`, `universities`, `unix-timestamp`, `unix-timestamp-converter`, `unkey`, `unleash-feature-toggle`, `unogs`, `unsure-calc`, `untis`, `upcoming-holidays`, `uplabs`, `upstash`, `uptime-kuma`, `uptime-robot`, `url-parse`, `url-tools`, `url-unshortener`, `useless-facts`, `usememos`, `user-agent`, `utc-workbench`, `v2ex`, `v2ex-viewer`, `v2raya-control`, `vade-mecum`, `val-town`, `valheim-wiki`, `valkey-commands-search`, `valorant-esports`, `vanguard-backup`, `vanishlink`, `vant-documentation`, `vartiq`, `vc-ru-news`, `veganify-application`, `vietnamese-calendar`, `vietqr-transfer`, `vim-bro`, `virtfusion`, `virtual-pet`, `virtualizor-enduser`, `viscosity`, `vision-directory`, `visitor-queue`, `vn-textify`, `vocab`, `vocabula-lat`, `voicenotes`, `volumio-control`, `vue-router-docs`, `vuejobs`, `vuejs-documentation`, `vuetify-docs`, `vueuse-functions`, `vultr`, `wakatime`, `wave`, `wcag`, `web-converter`, `web-page-design-mode`, `web3-profile`, `web3bio`, `webflow-sites`, `webhook-sender`, `webkit-developer-docs`, `websocket-debugging`, `what-happened-today`, `whentomeet`, `where-is-my-cursor`, `whimsical`, `who-is-off-today`, `whoop`, `wiggle-text`, `window-layouts`, `window-sizer`, `wistia`, `wled-controller`, `wolfram-alpha`, `woo-marketplace-search`, `word-count`, `word-search`, `wordpress-docs`, `wordpress-icon-finder`, `wordpress-manager`, `wordpress-plugins`, `work-time-countdown`, `workflowy-inbox`, `world-clock`, `world-cup`, `wp-cli-command-explorer`, `wrike`, `xbox-friends`, `xid`, `xkcd`, `xkcd-password-generator`, `xqc`, `y-combinator`, `yamli`, `yandex-music`, `yandex-smart-home`, `yap`, `yazio-tracker`, `yield-calculator`, `yopass`, `you-com-search`, `youdao-translate`, `youform`, `yourls`, `youtrack`, `youtube-companion`, `youtube-music`, `youtube-search`, `youtube-shorts-to-normal-video-page`, `youtube-subscriber-count`, `youversion-suggest`, `yr-weather-forecast`, `yu-gi-oh-card-lookup`, `za-fake-id-number-generator`, `zalgo-text`, `zefix`, `zeitraum`, `zenblog`, `zendesk`, `zendesk-admin`, `zeplin-project-raycast-extension`, `zero`, `zerodha-portfolio-kite-coin`, `zerossl`, `znotch`, `zo-raycast`, `zod-documentation`, `zodme`, `zoo`, `zoom-meeting-control`, `zyntra`
