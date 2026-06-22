# Chunk Clipboard-offset — `Clipboard.read({ offset })` Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development.

**Goal:** `Clipboard.read({ offset })` reads the Nth-back entry from the in-memory clipboard history; `offset` 0/absent keeps today's live-pasteboard read.

**Architecture:** The `clipboard.read` RPC is already allow-listed and forwards params verbatim to the Swift host (no supervisor change). Only two endpoints change: the api forwards `offset`, and the host handler branches to `ClipboardHistory.entry(at:)` for `offset >= 1`.

**Tech Stack:** TS (`packages/api`), Swift (`apps/macos`); `tsx` + standalone build/relaunch verify.

## Global Constraints
- Faithful parity: `read(options?: { offset?: number }): Promise<{ text: string; file?: string; html?: string }>`.
- World-class UX; commit on `main`; relaunch after build.
- **Security (org):** unchanged gate; history already excludes concealed clips (`ClipboardHistory.poll` skips `org.nspasteboard.ConcealedType`) — offset reads inherit that. Never log clip contents.
- No Xcode/XCTest: `npx tsc --noEmit` + `tsx`; `swift build --package-path apps/macos`. Ignore SourceKit false-positives when `swift build` succeeds.

---

### Task 1: api — `Clipboard.read({ offset })` passthrough

**Files:** Modify `packages/api/src/index.ts` (`Clipboard.read`, ~680). Test: `<scratchpad>/clipboard-offset-test.ts`.

**Interfaces:**
- Consumes: existing internal `rpc(method, params)` (reads the bridge from `globalThis`); the exported `__setHostBridge(send)` (line 644) to install a fake bridge in the test.
- Produces: `Clipboard.read` now accepts `options?: { offset?: number }` and includes `offset` in the rpc params only when it is a finite number `>= 1` (floored).

- [ ] **Step 1: Write the failing tsx test FIRST.** `<scratchpad>/clipboard-offset-test.ts` (import from the ABS path to `packages/api/src/index.ts`):
```ts
import { Clipboard, __setHostBridge } from "/Users/test/Documents/code/invoke-v2/packages/api/src/index.ts";
const calls: { method: string; params: any }[] = [];
__setHostBridge(async (method: string, params: unknown) => { calls.push({ method, params }); return { text: "x" }; });
function expectParams(label: string, actual: any, expected: any) {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) { console.error(`FAIL ${label}:`, actual, "!=", expected); process.exit(1); }
  console.log("ok:", label);
}
await Clipboard.read();                 expectParams("no-arg → {}", calls.at(-1)!.params, {});
await Clipboard.read({});               expectParams("empty → {}", calls.at(-1)!.params, {});
await Clipboard.read({ offset: 0 });    expectParams("offset 0 → {} (live)", calls.at(-1)!.params, {});
await Clipboard.read({ offset: 1 });    expectParams("offset 1", calls.at(-1)!.params, { offset: 1 });
await Clipboard.read({ offset: 3.7 });  expectParams("offset 3.7 → floor 3", calls.at(-1)!.params, { offset: 3 });
await Clipboard.read({ offset: -2 });   expectParams("offset -2 → {} (omit)", calls.at(-1)!.params, {});
await Clipboard.read({ offset: NaN });  expectParams("offset NaN → {} (omit)", calls.at(-1)!.params, {});
console.log("ALL PASS");
```

- [ ] **Step 2: Run it to fail.** `cd packages/api && npx tsx <scratchpad>/clipboard-offset-test.ts` → FAIL (offset ignored: `offset 1` gets `{}`).

- [ ] **Step 3: Implement the passthrough.** Replace the `read:` member (~680):
```ts
  // Raycast's Clipboard.read() returns { text, file?, html? } from the general pasteboard. With
  // { offset }, it reads an OLDER entry from the clipboard history: offset 0 (default) = the latest /
  // current pasteboard (the richest read — includes html/file); offset 1 = the previous entry, etc.
  read: async (options?: { offset?: number }): Promise<{ text: string; file?: string; html?: string }> => {
    const offset = options?.offset;
    const params =
      typeof offset === "number" && Number.isFinite(offset) && offset >= 1 ? { offset: Math.floor(offset) } : {};
    const r = (await rpc("clipboard.read", params)) as { text?: string; file?: string; html?: string } | undefined;
    return { text: r?.text ?? "", file: r?.file, html: r?.html };
  },
```

- [ ] **Step 4: Run the test → ALL PASS.** `cd packages/api && npx tsx <scratchpad>/clipboard-offset-test.ts`.

- [ ] **Step 5: typecheck + Commit.** `cd packages/api && npx tsc --noEmit 2>&1 | tail -8` (pre-existing `accessory-demo` error, if present, is OK — no NEW errors). Then:
```bash
git add packages/api/src/index.ts
git commit -m "feat(clipboard): Clipboard.read({ offset }) forwards offset for history reads"
```

---

### Task 2: Swift host — history accessor + handler branch + fixture

**Files:** Modify `apps/macos/Sources/InvokeServices/ClipboardHistory.swift`; `apps/macos/Sources/InvokeShell/AppController.swift` (`clipboard.read` handler, ~2383). Create `examples/clipboard-offset-demo/{package.json,read-clipboard.tsx}`.

**Interfaces:**
- Consumes: `ClipboardHistory.Clip` (fields `kind`, `text`, `filePath`); the `clipboard` instance on `AppController` (line 24); the handler's `arg(_:)` accessor and `JSONValue` (`.doubleValue`, `.string`, `.object`, `.null`).
- Produces: `ClipboardHistory.entry(at index: Int) -> Clip?` (bounds-safe).

- [ ] **Step 1: Add the bounds-safe accessor.** In `ClipboardHistory.swift`, next to `clip(forKey:)` (~86):
```swift
    /// Nth-most-recent clip (0 = latest). Bounds-safe → nil when out of range. Used by Clipboard.read({offset}).
    public func entry(at index: Int) -> Clip? { index >= 0 && index < clips.count ? clips[index] : nil }
```

- [ ] **Step 2: Branch the handler on offset.** Confirm `arg(_:)` and `self.clipboard` are in scope at the `clipboard.read` case (~2383) — they are (same handler family as `clipboard.copy`/`executeSQL`). Replace the case body:
```swift
        case "clipboard.read":
            // Clipboard.read() → { text, file, html }. With offset >= 1, read an OLDER entry from the
            // in-memory clipboard history (offset 0 / absent = the live pasteboard — the richest read).
            // History excludes concealed clips (ClipboardHistory.poll), so password-manager copies never appear.
            let offset = Int(arg("offset")?.doubleValue ?? 0)
            if offset >= 1 {
                guard let clip = clipboard.entry(at: offset) else { return .object(["text": .string("")]) }
                var cb: [String: JSONValue] = [:]
                switch clip.kind {
                case "File":
                    cb["text"] = .string(clip.filePath ?? clip.text)
                    if let p = clip.filePath { cb["file"] = .string(p) }
                case "Image":
                    cb["text"] = .string("") // image clips carry no text/file path
                default: // "Text" / "Link"
                    cb["text"] = .string(clip.text)
                }
                return .object(cb)
            }
            let pb = NSPasteboard.general
            var cb: [String: JSONValue] = [:]
            if let t = pb.string(forType: .string) { cb["text"] = .string(t) }
            if let urls = pb.readObjects(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) as? [URL],
               let f = urls.first { cb["file"] = .string(f.path) }
            if let html = pb.string(forType: .html) { cb["html"] = .string(html) }
            return .object(cb)
```

- [ ] **Step 3: Build.** `swift build --package-path apps/macos 2>&1 | tail -10` → `Build complete!`.

- [ ] **Step 4: Fixture.** `examples/clipboard-offset-demo/package.json` (mirror `examples/empty-action-demo/package.json` shape — same `$schema`/`engines`/deps; one `view` command named `read-clipboard`, title e.g. "Read Clipboard Offset"). Then `examples/clipboard-offset-demo/read-clipboard.tsx`:
```tsx
import { Detail, Clipboard } from "@raycast/api";
import { useEffect, useState } from "react";

export default function Command() {
  const [md, setMd] = useState("Reading clipboard…");
  useEffect(() => {
    (async () => {
      const current = await Clipboard.read();
      const previous = await Clipboard.read({ offset: 1 });
      const older = await Clipboard.read({ offset: 99 }); // past end → empty
      setMd(
        `# Clipboard History\n\n` +
          `**Current (offset 0):** ${current.text || "_(empty)_"}\n\n` +
          `**Previous (offset 1):** ${previous.text || "_(empty)_"}\n\n` +
          `**Offset 99 (past end):** ${older.text || "_(empty)_"}`,
      );
    })();
  }, []);
  return <Detail markdown={md} />;
}
```
(Do NOT hardcode any real/sensitive string — the fixture only echoes whatever placeholder the tester copies, e.g. "alpha"/"beta".)

- [ ] **Step 5: Build the app + relaunch.** `bash scripts/build-app.sh 2>&1 | tail -5` then relaunch Invoke.app (durably authorized). Confirm `/tmp/invoke-run.log` shows the command discovered (no crash). **Manual visual** (note in the report as human-required): copy "alpha", then copy "beta", open "Read Clipboard Offset" → Current="beta", Previous="alpha", Offset 99="(empty)".

- [ ] **Step 6: Commit.**
```bash
git add apps/macos/Sources/InvokeServices/ClipboardHistory.swift apps/macos/Sources/InvokeShell/AppController.swift examples/clipboard-offset-demo/
git commit -m "feat(clipboard): host reads Nth clipboard-history entry for Clipboard.read({offset}) + fixture"
```

---

## Self-Review

**1. Spec coverage:** api offset passthrough → Task 1; host history read + `entry(at:)` + fixture → Task 2. ✅ The spec's deferred items (isFullDay, TagPicker multi-select, non-AI canAccess, streaming progressive) are explicitly OUT of scope (surface after).

**2. Placeholder scan:** Concrete code for every step. `entry(at:)` is trivial bounds-checking deliberately verified via the integration fixture (in-range + past-end) rather than an artificial unit seam (seeding the private `clips` would be test-pollution); the TS conditional (the real logic) gets a real unit test via the clean `__setHostBridge` seam.

**3. Consistency:** `entry(at:)` (Task 2 Step 1) consumed by the handler (Step 2). api `offset >= 1 → {offset}` mirrors host `offset >= 1 → history` (both treat 0/absent/negative as the live read). Return shape `{text, file?, html?}` unchanged.

**Known risks (final-review triage):**
- (a) `clips[0]` vs the live pasteboard can momentarily differ (0.6s poll); offset 0 reads live (freshest), offset >= 1 reads `clips[offset]` — so offset 1 is "the entry before the current," which is correct even if `clips[0]` hasn't captured a brand-new copy yet. Acceptable timing edge.
- (b) `arg("offset")?.doubleValue` — if a client ever sends offset as a JSON string, `doubleValue` is nil → 0 → live read (safe default). api always sends a number, so fine.
- (c) Image/empty clips return `{text:""}` (no crash, faithful — the Clip store has no html and an image has no text/file path).
