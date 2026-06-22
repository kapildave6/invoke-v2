# Chunk Clipboard-offset — `Clipboard.read({ offset })` Design

**Part of the autonomous Raycast-parity push** (`[[autonomous-parity-goal]]`, the P2 micro-residual tail). This is the **last cleanly-tractable autonomous parity item**; after it, only decision-gated work remains (J: AI streaming/MCP/Window/OAuth, plus real-feature items — TagPicker multi-select control, DatePicker type-aware `isFullDay`, useStreamJSON progressive `setData` — which need a UI/subsystem build or a human decision, not a micro-fix).

## Why these other micro-residuals are NOT in scope (verified, not guessed)
- **`DatePicker.isFullDay()`** — our host emits a full ISO timestamp even for a `Form.DatePicker.Type.Date` (date-only) picker (`PaletteView.swift:81/1689` use `ISO8601DateFormatter().string(from: dateValue)`; `.yearMonthDay` elements don't force a midnight time). A midnight-heuristic `isFullDay` would therefore return **wrong** answers — a faithful-parity violation. Correct support needs the picker *type* threaded through the onChange/submit payload (real plumbing). **Defer** — surface as a real item.
- **TagPicker → array typed values** — TagPicker is currently degraded to a single-select `form-dropdown` (`index.ts:258`). A faithful array value needs a real multi-select control (token field); array-wrapping a single-select value is a janky half-measure (violates the world-class-UX standing rule) and the form-values assembly is host-side (no clean api-only wrap). **Defer** — real control, surface it.
- **non-AI `canAccess`** — returning `false` for non-AI APIs is already correct (clipboard/etc. aren't gated through `canAccess`). No real gap. **Skip.**
- **useStreamJSON `dataPath` streaming / progressive mid-stream `setData`** — results are already correct via the whole-parse fallback; progressive UI is a refinement, not a gap. **Defer** — refinement, surface it.

## The feature
Raycast's `Clipboard.read(options?: { offset?: number })` reads an entry from the clipboard **history**: `offset` 0 (default) = the current/latest, `offset` 1 = the previous entry, etc. We already maintain an analogous in-memory history (`InvokeServices/ClipboardHistory`, `clips[0]` = most recent). Today `Clipboard.read()` ignores `offset` and always reads the live `NSPasteboard`.

## Global constraints
- Faithful parity (canonical Raycast shape: `read(options?: { offset?: number }): Promise<{ text: string; file?: string; html?: string }>`).
- World-class UX; commit on `main`; relaunch after build.
- **Security (org):** clipboard history is sensitive. The existing `clipboard.read` gate/allow-list is unchanged; history already **excludes concealed clips** (`ClipboardHistory.poll` skips `org.nspasteboard.ConcealedType`, so password-manager copies are never in history) — offset reads inherit that exclusion. No new exposure beyond what Raycast's identical API provides. Do NOT log clip contents.

## Design (the data path is already wired; only endpoints change)
The `clipboard.read` RPC is already allow-listed in `supervisor.ts:73` and forwards params verbatim to the Swift host — so `offset` rides through with **no supervisor change**.

1. **`packages/api/src/index.ts` (`Clipboard.read`, ~680):** accept `options?: { offset?: number }`; forward `offset` in the rpc payload only when it's a finite number `>= 1` (offset 0 / absent → unchanged call → unchanged behavior). Return shape unchanged.
2. **`InvokeServices/ClipboardHistory.swift`:** add `public func entry(at index: Int) -> Clip?` returning `clips[index]` when `0 <= index < clips.count`, else `nil`. (Pure, bounds-safe — standalone-testable.)
3. **`InvokeShell/AppController.swift` (`clipboard.read` handler, ~2383):**
   - `offset` absent or `== 0` → **unchanged** (read the live `NSPasteboard`, richest: text + file + html).
   - `offset >= 1` → read `clipboard.entry(at: offset)`:
     - `Text`/`Link` clip → `{ text: clip.text }`
     - `File` clip → `{ text: clip.filePath ?? clip.text, file: clip.filePath }`
     - `Image` clip (no text/file) → `{ text: "" }`
     - no entry at that offset → `{ text: "" }` (Raycast returns empty, not an error).
   - (`html` is only available from the live pasteboard, so history reads omit it — faithful: the Clip store doesn't retain html.)
4. **`runtime/node-host/src/run.ts` dev stub (~196):** leave as-is (standalone dev runner returns an empty clip; offset is meaningless without a host history). No change.

## Fixture + verify
- `examples/clipboard-offset-demo/` (manifest mirrors `examples/empty-action-demo`): a `view` command that on mount calls `Clipboard.read()` and `Clipboard.read({ offset: 1 })` and renders both in a `Detail` (e.g. "current: …" / "previous: …"), proving offset selects an older entry. Do NOT render anything that could be a real secret in docs — the fixture just echoes whatever the user copied during the manual test (placeholder copy like "alpha" then "beta").
- **Verify:** `npx tsc --noEmit` (api) clean; standalone swift test for `entry(at:)` bounds (negative, 0, in-range, past-end → nil); `swift build --package-path apps/macos`; `scripts/build-app.sh` + relaunch; manual: copy "alpha", then "beta", open the demo → current="beta", previous="alpha".

## Testing strategy
- **Pure (standalone swift):** `ClipboardHistory.entry(at:)` bounds table.
- **TS:** api offset-passthrough is type-checked + a tiny `tsx`/inline assertion that `read({offset:1})` issues the rpc with `offset:1` and `read()` omits it (stub the `rpc`).
- **Integration (build + relaunch + human):** the live/history selection needs eyes (copy two things, see current vs previous).

## Out of scope (surface after this chunk — the genuine remainder)
- **J (decision-required):** AI token streaming / Tools / MCP / Skills; Window Management API; OAuth provider presets. (Touch real model access / external services / secrets / brand fabrication — need the user's call.)
- **Real-feature residuals:** TagPicker multi-select control; DatePicker type-aware value + correct `isFullDay`; useStreamJSON progressive `setData`.
