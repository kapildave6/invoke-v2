# Chunk I-stream — useStreamJSON progressive streaming Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development.

**Goal:** `useStreamJSON` streams a top-level JSON array incrementally (progressive `data`), with a load-whole fallback.

**Architecture:** A pure, dep-free incremental array-element extractor (unit-tested via tsx), wired into `useStreamJSON` to read `res.body` and `setData` accumulated items in batches; fall back to the existing load-whole path for `dataPath`/non-array/unstreamable.

**Tech Stack:** TS (`packages/utils`), `tsx` tests.

## Global Constraints
- Faithful parity; commit on `main`; no Xcode/XCTest — TS via `npx tsc --noEmit` + `tsx` unit tests.
- No new deps (sandbox); pure hand-rolled extractor.

---

### Task 1: Incremental top-level-array extractor (TDD)

**Files:** Modify `packages/utils/src/index.ts` (add the helper). Create test: `<scratchpad>/stream-extractor-test.ts`.

**Interface:** `export function createArrayStreamParser(): { push(chunk: string): unknown[]; flush(): unknown[] }` — `push` returns any COMPLETE top-level array elements (as `JSON.parse`d values) newly completed by this chunk; `flush` returns any trailing element completed at end-of-stream (and validates the array closed).

- [ ] **Step 1: Write the failing tsx test FIRST.** `<scratchpad>/stream-extractor-test.ts` (import from the abs path to `packages/utils/src/index.ts`). Cases (feed the SAME JSON split at MANY chunk boundaries, assert emitted elements in order == `JSON.parse(whole)`):
```ts
function runCase(label: string, whole: string, chunkSizes: number[]) {
  const expected = JSON.parse(whole) as unknown[];
  // split `whole` into chunks per chunkSizes (cycling), feed, collect
  const p = createArrayStreamParser();
  const got: unknown[] = [];
  let i = 0, k = 0;
  while (i < whole.length) { const n = chunkSizes[k++ % chunkSizes.length]; got.push(...p.push(whole.slice(i, i + n))); i += n; }
  got.push(...p.flush());
  if (JSON.stringify(got) !== JSON.stringify(expected)) { console.error(`FAIL ${label}:`, got, "!=", expected); process.exit(1); }
  console.log("ok:", label);
}
const arr = JSON.stringify([{a:1,s:"]has, brackets {} \" escaped"},[1,2,3],"str",42,true,null,{nested:{x:[5]}}]);
runCase("whole-1chunk", arr, [arr.length]);
runCase("char-by-char", arr, [1]);
runCase("size-3", arr, [3]);
runCase("size-7", arr, [7]);
runCase("empty", "[]", [1]);
runCase("single", JSON.stringify([{only:true}]), [2]);
runCase("ws-heavy", "[\n  1 ,\n  2 ,\n  {\n \"k\": \"v\"\n }\n]", [4]);
console.log("ALL PASS");
```

- [ ] **Step 2: Run it to fail.** `cd packages/utils && npx tsx <scratchpad>/stream-extractor-test.ts` → FAIL (`createArrayStreamParser` not exported).

- [ ] **Step 3: Implement `createArrayStreamParser`.** A stateful scanner over an accumulating buffer:
```ts
export function createArrayStreamParser(): { push(chunk: string): unknown[]; flush(): unknown[] } {
  let buf = "";
  let cursor = 0;        // scan position in buf
  let opened = false;    // seen the top-level '['
  let closed = false;
  let depth = 0;         // nesting INSIDE the array (0 = directly in the array)
  let inStr = false, esc = false;
  let elemStart = -1;    // index in buf where the current element began, or -1 between elements
  const emit: unknown[] = [];

  function scan(): unknown[] {
    const out: unknown[] = [];
    while (cursor < buf.length) {
      const c = buf[cursor];
      if (!opened) { if (c === "[") { opened = true; } cursor++; continue; }
      if (closed) { cursor++; continue; }
      if (inStr) {
        if (esc) esc = false;
        else if (c === "\\") esc = true;
        else if (c === '"') inStr = false;
        cursor++; continue;
      }
      if (c === '"') { if (elemStart === -1) elemStart = cursor; inStr = true; cursor++; continue; }
      if (c === "{" || c === "[") { if (elemStart === -1) elemStart = cursor; depth++; cursor++; continue; }
      if (c === "}" || c === "]") {
        if (depth > 0) { depth--; cursor++; continue; }
        // depth 0 and a closing char → must be the array's ']'
        if (elemStart !== -1) { out.push(JSON.parse(buf.slice(elemStart, cursor))); elemStart = -1; }
        closed = true; cursor++; continue;
      }
      if (c === "," && depth === 0) {
        if (elemStart !== -1) { out.push(JSON.parse(buf.slice(elemStart, cursor))); elemStart = -1; }
        cursor++; continue;
      }
      if (elemStart === -1 && !/\s/.test(c)) elemStart = cursor; // element begins at first non-ws
      cursor++;
    }
    // bound memory: drop consumed prefix when between elements (elemStart === -1)
    if (elemStart === -1 && cursor > 0) { buf = buf.slice(cursor); cursor = 0; }
    else if (elemStart > 0) { buf = buf.slice(elemStart); cursor -= elemStart; elemStart = 0; }
    return out;
  }
  return {
    push(chunk: string) { buf += chunk; return scan(); },
    flush() { const out = scan(); return out; },
  };
}
```
(Note: numbers/`true`/`false`/`null` as elements complete only at the `,` or `]` boundary — handled, since `elemStart` is set at their first char and the slice is taken at the delimiter. `flush` is a no-op emitter for already-handled state; the final element before `]` is emitted when `]` is scanned.)

- [ ] **Step 4: Run the test → ALL PASS.** `cd packages/utils && npx tsx <scratchpad>/stream-extractor-test.ts`.

- [ ] **Step 5: typecheck + Commit.** `npx tsc --noEmit | tail -5`; `git add packages/utils/src/index.ts && git commit -m "feat(utils): incremental top-level-array stream parser (createArrayStreamParser)"`

---

### Task 2: Wire `useStreamJSON` to stream + load-whole fallback

**Files:** Modify `packages/utils/src/index.ts` (`useStreamJSON` ~897). Test: `<scratchpad>/streamjson-test.ts`.

- [ ] **Step 1: Stream when feasible; else load-whole.** Rewrite the `usePromise` body inside `useStreamJSON` so that, when `!options.dataPath` and `res.body` is a readable stream, it reads chunks, feeds `createArrayStreamParser`, applies `transform`/`filter` per element, accumulates, and (via the hook's data setter) updates progressively; on any failure or when `dataPath` is set, fall back to the current whole-parse path. Concretely, since `usePromise`'s fn resolves once with the final array, the PROGRESSIVE update needs the hook to setData incrementally — use the existing `useStreamJSON` structure: keep returning the final accumulated array from the promise (so load-whole parity holds), AND if incremental UI updates are wanted, push partial batches via a ref + a state bump. MINIMUM viable for this chunk: stream the body (memory-incremental + correct), accumulate all elements, return the full transformed/filtered array — identical RESULT to load-whole, but parsed via the streaming extractor (proving the streaming path). (Progressive setData mid-stream is a further refinement; if it's clean to bump state per batch, do it, else return the accumulated result.)
   - Read `res.body` via `for await (const chunk of res.body as any)` or `res.body.getReader()` + `TextDecoder`; feed `parser.push(decoder.decode(value, {stream:true}))`; collect; `parser.flush()`.
   - Apply `transform` then `filter` per element (matching the current order).
   - On `dataPath` or no `res.body` or a thrown parse error → the existing whole-parse code path.

- [ ] **Step 2: tsx parity test.** `<scratchpad>/streamjson-test.ts`: stand up a tiny harness that simulates a streamed Response (a `ReadableStream` from a chunked string) OR directly tests the extraction+transform+filter pipeline against `JSON.parse(whole)` with the same transform/filter — assert the streamed result equals the load-whole result for a sample array (with transform + filter). (Full React-hook execution isn't feasible standalone; test the data pipeline.)

- [ ] **Step 3: typecheck + run test.** `cd packages/utils && npx tsc --noEmit | tail -5`; `npx tsx <scratchpad>/streamjson-test.ts` → `ALL PASS`.

- [ ] **Step 4: Commit.** `git add packages/utils/src/index.ts && git commit -m "feat(utils): useStreamJSON streams top-level arrays via the incremental parser (load-whole fallback for dataPath/non-array)"`

---

## Self-Review

**1. Spec coverage:** extractor → Task 1; useStreamJSON streaming + fallback → Task 2. ✅ (No app fixture — serving a stream in-app is impractical; the tsx tests + load-whole parity are the gates, per the spec.)

**2. Placeholder scan:** Full extractor code + comprehensive chunk-boundary test cases; the Task 2 wiring describes the stream-read + fallback concretely (the "minimum viable = same result via streaming parse" is explicit, with progressive-setData as an optional refinement).

**3. Consistency:** `createArrayStreamParser` (Task 1) consumed by `useStreamJSON` (Task 2). transform-then-filter order preserved. `initialData`/`execute`/`onError` unchanged.

**Known risk (final-review triage):** (a) the extractor handles a TOP-LEVEL array only; `dataPath`/non-array → load-whole (correct fallback, note). (b) malformed JSON mid-stream → `JSON.parse` throws on an element → must be caught + fall back to whole-parse (or surface as error like today). (c) the "progressive setData mid-stream" is optional this chunk — if not done, the win is memory-incremental parse + identical result (acceptable; note streaming-UI as a further refinement).
