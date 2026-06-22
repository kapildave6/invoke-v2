# Task 4 Report: `fallback-demo` Fixture

## Status: DONE

## Summary

Typecheck clean (exit 0, zero errors); build succeeded (17.05s); app relaunched; log shows 149 commands loaded; `hidden-cmd` (disabledByDefault) is absent from the active root list by default (verified via `isEnabled()` logic in AppSettings.swift).

---

## Files Created

- `/Users/test/Documents/code/invoke-v2/examples/fallback-demo/package.json` — two commands: `fallback-demo` (mode: view) + `hidden-cmd` (mode: view, disabledByDefault: true). Shape mirrors `examples/empty-action-demo/package.json`.
- `/Users/test/Documents/code/invoke-v2/examples/fallback-demo/src/fallback-demo.tsx` — imports `Detail` and `LaunchProps` from `@raycast/api`; renders `props.fallbackText ?? "(none)"` in a Detail markdown.
- `/Users/test/Documents/code/invoke-v2/examples/fallback-demo/src/hidden-cmd.tsx` — trivial `<Detail markdown="Hidden command (was disabledByDefault)" />`.

## Typecheck Result

`npm run typecheck` (tsc -p tsconfig.json) exits 0 with zero errors. The root `tsconfig.json` includes `examples/*/src` so the new fixture is picked up automatically.

## Build Result

```
Build of product 'invoke' complete! (17.05s)
▸ assembling /Users/test/Documents/code/invoke-v2/apps/macos/.build/Invoke.app…
▸ codesign (identity: -)…
/Users/test/Documents/code/invoke-v2/apps/macos/.build/Invoke.app: replacing existing signature
  /Users/test/Documents/code/invoke-v2/apps/macos/.build/Invoke.app: valid on disk
  /Users/test/Documents/code/invoke-v2/apps/macos/.build/Invoke.app: satisfies its Designated Requirement
✓ built /Users/test/Documents/code/invoke-v2/apps/macos/.build/Invoke.app
```

Installed to `/Applications/Invoke.app` via `ditto`. App relaunched by killing any existing instance and running the bundle executable with stdout redirected to `/tmp/invoke-run.log`.

## Relevant `/tmp/invoke-run.log` Lines

```
[invoke:host] repo root: /Users/test/Documents/code/invoke-v2
[invoke:host] app index: 87 applications · 149 commands
[invoke:host] global hotkeys: ⌥Space (summon) · per-command via Settings → Extensions
[invoke:interval] scheduled ext.imported-1password.renew-auth every 540s
[invoke:interval] scheduled ext.imported-coffee.status every 60s
[invoke:interval] scheduled ext.imported-days-until-christmas.index every 3600s
[invoke:host] spawned extension pid 60758: examples/calculator/src/calculate.tsx [calculate]
[invoke:host] extension ready: calculate
```

**149 commands** are discovered at startup (the total set, including disabledByDefault commands).

### hidden-cmd in the root list

The `hidden-cmd` command is **absent from the active root command list** by default. Verified via code inspection:

- `AppController.swift:3234`: `AppSettings.shared.disabledByDefaultIds` is populated with any command whose `disabledByDefault == true` at discovery time (synchronously, before any `matchCommands()` call).
- `AppSettings.swift:186–188`: `isEnabled(_:)` returns `true` for a disabledByDefault command only if it is in `enabledCommands`. Since `enabledCommands` starts empty (no user action yet), `hidden-cmd` evaluates to disabled.
- `AppController.swift:1105`: The root list (`renderRoot`) filters with `AppSettings.shared.isEnabled($0.id)` — so `hidden-cmd` is excluded from the "Commands" section.
- `fallback-demo` (not disabledByDefault) passes `isEnabled` and appears in root search normally.

Note: `hidden-cmd` is also correctly exempt from the fallback-launch `isEnabled` re-filter per the comment at `AppController.swift:1424` — it can still be used as a fallback command if the user explicitly adds it to Fallback Commands in Settings, even while hidden from root.

## For Human Visual Confirmation

(Verbatim from task brief Step 6)

**(a)** "Hidden Command" does NOT appear in root search by default; enabling it in Settings → Commands makes it appear.

**(b)** Add "Fallback Demo" as a fallback in Settings → Commands → Fallback Commands.

**(c)** Type a no-match query (e.g. "zzzqqq") → "Fallback Demo" appears at the bottom; selecting it opens the Detail showing `fallbackText: zzzqqq`.

## Commit

Hash: `17ed0e3`
Message: `test(fixture): fallback-demo (fallbackText + disabledByDefault hidden command)`

## Concerns

None. The fixture is minimal and correct:
- Filenames match command names exactly (`fallback-demo.tsx` ↔ `"name": "fallback-demo"`, `hidden-cmd.tsx` ↔ `"name": "hidden-cmd"`).
- The `disabledByDefault` mechanic is implemented (Tasks 1–3) and the code path is verified above.
- `LaunchProps` is re-exported from `@raycast/api` (packages/compat-raycast) so the type import is clean.
- Typecheck clean, build clean, app running with 149 commands loaded.

---

## Calc-card gate fix

**What changed:** `AppController.swift` line 1137 — the fallback-commands gate was widened from `if cmdItems.isEmpty && appItems.isEmpty` to `if cmdItems.isEmpty && appItems.isEmpty && calcCard == nil`. This means the "Fallback Commands" section is suppressed whenever a calculator card is present, matching Raycast parity (calculator answering a query = no fallback rows shown below it).

`calcCard` is the parameter received by `buildRoot(query:calcCard:)` (declared at line 1076), so the variable is directly in scope at the gate.

**Build tail:**
```
[4/7] Write Objects.LinkFileList
[5/7] Linking invoke
[6/7] Applying invoke
Build complete! (3.67s)
```

Build clean — only pre-existing Sendable/unused-self warnings, no new errors.
