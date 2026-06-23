# WM-2 — Extension `WindowManagement` API (AX-backed) Design

**Part of the full Window-Management parity effort** (`[[window-management-parity]]`, chunk 2 of 5). Replaces the `unsupported()` stubs (`packages/api/src/index.ts:1166`) with real AX-backed handlers so Raycast `WindowManagement` *extensions* run. Scope + the "model `getDesktops` honestly" caveat are user-approved (2026-06-22).

## Global constraints
- Faithful parity: canonical Raycast `WindowManagement` shapes (below); commit on `main`; relaunch after build; world-class UX.
- **Org security:** window enumeration exposes other apps' window titles/bounds to a (possibly unsandboxed, but already-trusted-to-run) extension — same surface Raycast's identical API exposes; gate it through the existing capability allow-list, don't log window contents.
- No Xcode/XCTest → TS via `npx tsc --noEmit`; Swift logic via standalone `swiftc`; AX via build + relaunch + human visual. Ignore SourceKit false-positives when `swift build` succeeds.
- `WindowManager`/new enumerator stays in `InvokeServices` (no `InvokeShell`/`AppSettings` dep).

## Coordinate convention (decided)
Raycast `Window.bounds` uses **global top-left origin, y-down** — the SAME space AX reports (`kAXPositionAttribute`). So WM-2 reads/writes AX position/size **directly, no Cocoa flip** (the flip in `WindowManager.frame/set` exists only for `NSScreen.visibleFrame` snapping math and is NOT reused here).

## Canonical types (TS — faithful Raycast shapes)
```ts
namespace WindowManagement {
  type Bounds = { position: { x: number; y: number }; size: { width: number; height: number } };
  enum DesktopType { User = "user", FullScreen = "fullScreen" }           // runtime enum (extensions read .User)
  type Desktop = { id: string; screenId: string; size: { width: number; height: number }; active: boolean; type: DesktopType };
  type Window = { id: string; application?: Application; bounds: Bounds; desktopId: string; active?: boolean; fullScreen?: boolean };
  type SetWindowBoundsOptions = { id: string; bounds: Partial<Bounds>; desktopId?: string };
}
```
`Application` = existing `{ name: string; path: string; bundleId?: string }` (reuse the exported type; if absent, `{ name; path; bundleId? }`).

**API shape (replaces the stub):**
```ts
WindowManagement.getActiveWindow(): Promise<Window>
WindowManagement.getWindowsOnActiveDesktop(): Promise<Window[]>
WindowManagement.setWindowBounds(options: SetWindowBoundsOptions): Promise<Window>   // returns the updated window
WindowManagement.getDesktops(): Promise<Desktop[]>
WindowManagement.DesktopType                                                          // runtime enum value
```
Runtime: a `const WindowManagement` whose methods call `rpc("windowManagement.*", …)` + carries `DesktopType` (real enum object); a `export declare namespace WindowManagement` merge adds the TYPES (`Window`/`Desktop`/`Bounds`/`SetWindowBoundsOptions`) — mirror the established `Form`/`Image` namespace-merge (use `export declare namespace`, extend — don't shadow — and keep the runtime `const`). Throwing `unsupported()` is removed.

## Swift host — a `WindowEnumerator` (in `InvokeServices`)
A new `WindowEnumerator` (or an extension of `WindowManager`) owning AX enumeration + a window-id cache.

**Window identity + cache (the crux).** Enumerated AX windows need stable ids that `setWindowBounds` can resolve back to an `AXUIElement`.
- id = the window's CGWindowID via the private `_AXUIElementGetWindow(_:_:)` (the standard technique; Invoke is notarized/direct-dist like Raycast, not App-Store — acceptable, no org blocker). Resolve the symbol once via `dlsym`; if unavailable, **fall back** to a generated `UUID` id.
- Keep an in-host cache `[String: AXUIElement]` (CFRetained via Swift bridging), repopulated on each `getActiveWindow`/`getWindowsOnActiveDesktop`. `setWindowBounds(id)` looks up the cache; on a stale/missing element (AX call fails) → throw a clear error the api surfaces as a rejected promise.

**Enumeration.** For each `NSWorkspace.shared.runningApplications` with `.activationPolicy == .regular`: `AXUIElementCreateApplication(pid)` → `kAXWindowsAttribute` → `[AXUIElement]`. Per window read `kAXPosition`/`kAXSize` (→ `bounds`), `kAXMinimized` (skip minimized for "on active desktop"), `kAXFullScreen` (→ `fullScreen`), and the owning `NSRunningApplication` (→ `application {name,path,bundleId}`). `active` = the window is the focused window of the frontmost app. `desktopId` = the id of the `Desktop` whose screen contains the window's center.

**Methods → JSON:**
- `getActiveWindow` → frontmost app (`NSWorkspace.frontmostApplication`) → its `kAXFocusedWindow` → one `Window` (cached). If none → reject ("no active window").
- `getWindowsOnActiveDesktop` → all enumerated non-minimized windows → `[Window]`.
- `setWindowBounds {id, bounds, desktopId?}` → resolve `id` → AX-set position/size (only the provided `bounds` components; missing components keep current) via the set-size→set-pos→set-size dance (reuse `WindowManager`'s ordering) → re-read → return the updated `Window`. (`desktopId` move across displays: set position into the target screen's frame; honest best-effort.)
- `getDesktops` → one `Desktop` per `NSScreen`: `id` = stable per-screen (e.g. `NSScreenNumber`), `screenId` = same, `size` = screen `frame.size`, `active` = screen of the active window (or `NSScreen.main`), `type` = `.fullScreen` if the active window on it is AX-fullscreen else `.user`. (macOS Spaces are NOT publicly enumerable → we model one desktop per physical display, documented; we do not fabricate Spaces.)

## Host capability wiring
Add `windowManagement.getActiveWindow|getWindowsOnActiveDesktop|setWindowBounds|getDesktops` to the capability handler (the family that has `clipboard.read`, etc.) + the `supervisor.ts` ALLOWED set + the `ExtensionHost.swift` allow-list. AX requires Accessibility — if `!AXIsProcessTrusted()`, reject with a clear "grant Accessibility" error (the existing `applyWindow` prompt pattern). `run.ts` dev-stub returns empty/benign values.

## Fixture + verify
- `examples/window-management-demo/` (mirror `examples/empty-action-demo`): a `view` command that on mount calls `getActiveWindow`, `getWindowsOnActiveDesktop`, `getDesktops` and renders them in a `Detail` (id, app name, bounds, desktop), plus an Action "Nudge active window" calling `setWindowBounds` to shift the active window +20pt x — proving the round-trip.
- **Verify:** `tsc --noEmit` (types + a type-import usage of `WindowManagement.Window`/`Desktop`/`DesktopType`); standalone `swiftc` test for any PURE helper (e.g. desktop-for-center selection, bounds JSON mapping) if extractable; `swift build`; `build-app.sh` + relaunch + `/tmp/invoke-run.log` clean + command discovered. **HUMAN-REQUIRED:** with Accessibility granted, open the demo → see real windows/bounds/desktops; "Nudge" moves the active window. (No automation can grant AX + observe window moves.)

## Testing strategy
- **Pure (standalone swift):** desktop-selection-by-center + AX-bounds→`Bounds` JSON mapping, if cleanly extractable from AX calls; else covered by the integration check.
- **TS:** `tsc` + a type-import; an rpc-passthrough test (via `__setHostBridge`) asserting each method calls the right `windowManagement.*` method with its params (mirror the Clipboard-offset test).
- **Integration:** build + relaunch + human (AX needs a grant + eyes).

## Out of scope (later WM chunks / explicitly deferred)
- WM-3 custom commands; WM-4 layouts; WM-5 Stage Manager/presets.
- Real macOS Spaces enumeration (not publicly available — one desktop per display, documented).
- Cross-Space window moves; `onWindowsChanged` observers (Raycast has none — N/A).
