# Task 2 Report: `useStreamJSON` Streaming Path

## Status: DONE

## What Changed

`packages/utils/src/index.ts` — `useStreamJSON` rewritten (46 lines added, 9 replaced):

### New: `applyPipeline<T>()` helper
Extracted the transform-then-filter logic into a shared private helper so both the streaming and whole-parse paths use exactly the same pipeline (no order drift possible).

### Streaming path (activated when `!options.dataPath && res.body`)
Reads the response body incrementally via `res.body.getReader()` + `TextDecoder({ stream: true })`. Each decoded chunk is fed to `createArrayStreamParser().push()`, which returns any complete top-level elements; those are immediately run through `applyPipeline` (transform → filter) and accumulated. After the reader signals `done`, `parser.flush()` is called to extract any element that terminated right at the last byte. The final accumulated array is returned — **identical result to whole-parse** but with O(max-element-size) rather than O(full-body-size) memory.

### Fallback conditions (whole-parse path)
The fallback fires in three cases (per spec):
1. `options.dataPath` is set — streaming can't extract a nested key.
2. `res.body` is null/absent — no stream available.
3. The streaming try-block throws (e.g. non-array top-level JSON, `JSON.parse` error on an element) — `catch {}` falls through. If the body was already consumed in the failing streaming attempt, `res.bodyUsed` is checked and a fresh `fetch(url)` is issued before calling `res.json()`.

### Progressive setData
Not implemented in this chunk (acceptable per spec minimum). The promise resolves once with the fully-accumulated array. The result is memory-incremental at the parse level; progressive UI updates are a further refinement.

### `initialData` / `execute` / `onError` semantics
Unchanged — the `!execute` early-return still fires first, `useEffect` for `onError` is untouched, and `state.data ?? options.initialData ?? []` fallback is preserved.

---

## Test: ALL PASS

`npx tsx <scratchpad>/streamjson-test.ts` — 11 assertions, 0 failures:

```
11 tests: 11 passed, 0 failed
ALL PASS
```

Covered:
- chunk-by-1, chunk-by-10, chunk-by-50, single-chunk (full string in one push)
- No transform/filter
- Transform + filter (including tricky strings with brackets/commas, nested objects)
- Empty array
- Single-element array
- **Transform-before-filter order proof**: transform adds `{ transformed: true }`, filter checks for it — if order were reversed the filter would eliminate everything

---

## Typecheck

`cd packages/utils && npx tsc --noEmit` — no output (zero errors, clean).

---

## Concerns

None blocking. Two notes:

1. **Re-fetch on streaming parse error**: If streaming fails mid-body (rare — only malformed JSON that `JSON.parse` throws on inside an element), the fallback re-fetches the URL. This is correct and matches the spec's guidance, but it means a double-fetch in that error scenario. In practice the parser only calls `JSON.parse` on complete element strings; partial chunks are accumulated internally until a top-level comma or `]` is seen, so the risk surface is real malformed JSON in the source data (not chunking artifacts).

2. **Progressive setData**: Not wired. The streaming path returns the full accumulated array, so from the hook consumer's perspective it behaves identically to whole-parse (state updates once when the promise resolves). The memory win is real; the UI win (progressive rendering) is deferred.

---

## C1+I1 parity fix

### What changed (`packages/utils/src/index.ts`)

**C1 (Critical) — non-top-level-array divergence fix** in `createArrayStreamParser`'s `scan()`:

Old: the `!opened` branch matched ANY `[` anywhere in the buffer (including ones nested inside objects), so `{"items":[1,2]}` (a valid non-array response) was incorrectly streamed as `[1,2]` while the load-whole path returned `[]`.

New: leading whitespace is explicitly skipped; the first non-whitespace char is checked — if it's `[` the array is opened, otherwise a `SyntaxError` is thrown immediately. This bubbles out of `push()`/`flush()`, is caught by `useStreamJSON`'s existing `try/catch`, and the fallback re-fetches → `res.json()` → `Array.isArray` check → `[]` for a non-array response — exactly matching load-whole.

```ts
      if (!opened) {
        if (/\s/.test(c)) { cursor++; continue; }
        if (c === "[") { opened = true; cursor++; continue; }
        throw new SyntaxError("useStreamJSON: stream is not a top-level JSON array");
      }
```

**I1 (Important) — unterminated array silently returns partial data** in `flush()`:

Old: `flush()` called `scan()` and returned whatever partial elements were accumulated; a truncated body like `[1,2,` or `[1,2` returned `[1, 2]` silently, masking the error that load-whole would have surfaced (JSON.parse throws for malformed JSON).

New: after `scan()`, if the array was `opened` but never `closed`, a `SyntaxError` is thrown. This propagates out of `flush()`, is caught by `useStreamJSON`'s `try/catch`, and the fallback calls `fetch(url)` + `res.json()` on the raw (still-truncated) body — which throws the real SyntaxError, surfaced via `usePromise → onError`, matching old load-whole behavior.

```ts
    flush() {
      const out = scan();
      if (opened && !closed) throw new SyntaxError("useStreamJSON: array not terminated");
      return out;
    },
```

**Hook catch scope**: confirmed already sufficient — the `try` block in `useStreamJSON`'s streaming path wraps both the `reader.read()` loop (covering all `parser.push()` calls) and the `parser.flush()` call. No widening required.

### New test cases

**stream-extractor-test.ts** (7 original cases unchanged + 4 new):
- `non-array-object throws (push)`: feeds `{"items":[1,2]}` whole → expects SyntaxError on `push`
- `non-array-object throws (flush after partial push)`: feeds `{` → expects SyntaxError on `push`
- `unterminated array throws on flush`: pushes `[1,2` then flushes → expects SyntaxError
- `opened-only flush throws`: pushes `[` then flushes → expects SyntaxError

**streamjson-test.ts** (11 original assertions + 7 new):
- `C1a`: `{"items":[1,2,3]}` → streaming throws → fallback → `[]` (matches load-whole)
- `C1b`: valid `[1,2,3,4,5]` still streams correctly (C1 fix is non-destructive)
- `C1c`: leading whitespace `"  \n  [1,2,3]"` still opens correctly (whitespace skip path)
- `I1a`: `[1,2,` → flush throws → fallback `JSON.parse` also throws SyntaxError (propagated)
- `I1b`: direct `flush()` on unterminated array throws `SyntaxError`

### Test + tsc results

```
stream-extractor-test.ts: 11/11 PASS (7 original + 4 new)
streamjson-test.ts:       18/18 PASS (11 original + 7 new)
cd packages/utils && npx tsc --noEmit: no output (clean)
```
