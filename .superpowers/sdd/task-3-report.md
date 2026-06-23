# Task 3 Report: Host WindowManagement Capability Wiring

## Status: DONE

---

## Files Changed

| File | Change |
|------|--------|
| `apps/macos/Sources/InvokeShell/AppController.swift` | Added `windowEnumerator` instance (~line 26); added `windowJSON`/`desktopJSON` mappers (near `applicationJSON`); added four `windowManagement.*` cases in `handleAsyncCapability` (before `default:`) |
| `apps/macos/Sources/InvokeShell/ExtensionHost.swift` | Added four `windowManagement.*` strings to `allowedRPC` set (~line 85) |
| `runtime/node-host/src/supervisor.ts` | Added four `windowManagement.*` strings to `ALLOWED_RPC` set (before closing `]);`) |
| `runtime/node-host/src/run.ts` | Added four dev-stub cases after `date.pick` |
| `examples/window-management-demo/package.json` | Created fixture (mirrors `empty-action-demo` shape; one `view` command named `windows`) |
| `examples/window-management-demo/src/windows.tsx` | Created fixture (Detail view: active window + window list + desktops + Nudge action) |

---

## Build Results

### `swift build --package-path apps/macos`

```
[9/12] Emitting module InvokeApp
[9/12] Write Objects.LinkFileList
[10/12] Linking invoke
[11/12] Applying invoke
Build complete! (5.42s)
```

Exit 0. No errors.

### `cd runtime/node-host && npx tsc --noEmit`

Clean — no output (zero errors).

### `bash scripts/build-app.sh`

```
▸ assembling /Users/test/Documents/code/invoke-v2/apps/macos/.build/Invoke.app…
▸ codesign (identity: -)…
/Users/test/Documents/code/invoke-v2/apps/macos/.build/Invoke.app: replacing existing signature
  /Users/test/Documents/code/invoke-v2/apps/macos/.build/Invoke.app: valid on disk
  /Users/test/Documents/code/invoke-v2/apps/macos/.build/Invoke.app: satisfies its Designated Requirement
✓ built /Users/test/Documents/code/invoke-v2/apps/macos/.build/Invoke.app
```

Exit 0. App bundle assembled and signed clean.

---

## Relaunch + `/tmp/invoke-run.log`

App relaunched cleanly. Log shows normal startup + background interval extension cycling (coffee/status). No errors or crashes. The `[invoke:host] global hotkeys` line confirmed successful boot.

The registration directory `~/Library/Application Support/com.invoke.app/extensions/ext.window-management-demo/` was created by the app on scan, confirming the `windows` command was discovered from `examples/window-management-demo/`. Extension content lives in the source tree; stub dirs are the app's registration mechanism.

---

## HUMAN-REQUIRED Verification (not performed)

With Accessibility granted to Invoke.app, open "Window Management Demo" → the `windows` command should:

1. Show real active window name + bounds JSON.
2. Show list of windows on the active desktop (up to 8).
3. Show desktop IDs with "(active)" marker.
4. "Nudge Active Window +20" action should shift the active window +20pt on X.

These checks cannot be automated: granting AX permission and observing window position require a human at the display.

---

## Concerns

None. All three gate points (Swift host `allowedRPC`, Node `ALLOWED_RPC`, four capability handlers) are in sync. `windowManagement.getDesktops` intentionally omits the `hasAccessibility` guard (desktops only calls `NSScreen.screens`, no AX). The `arg` helper is safely captured from outer scope by the `DispatchQueue.main.async` closures. `JSONValue.doubleValue` accessor confirmed present in `InvokeIPC/JSONValue.swift`.
