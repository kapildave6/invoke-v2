# Chunk I-stream — useStreamJSON progressive streaming Design

**Part of the autonomous Raycast-parity push** (`[[autonomous-parity-goal]]`, P2 breadth tail). Closes `RAYCASTVSINVOKE.md` §12 P2: "`useStreamJSON` true progressive streaming".

## Current
`useStreamJSON` (`packages/utils/src/index.ts:897`) fetches the WHOLE resource, `await res.json()`, then filter/transform/return. Functionally correct, but not progressive (no incremental `data`, whole file in memory) — the parity gap is the streaming UX + memory behavior.

## Design (bounded — streams a top-level JSON array incrementally; falls back to load-whole otherwise)
- **New pure helper `streamJSONArray`** (or an incremental extractor) in `packages/utils`: given a `ReadableStream`/async chunk source of text, incrementally emit COMPLETE top-level array elements as bytes arrive. Track bracket/brace depth + string state (+ escape) to find element boundaries within the outer `[ … ]`. AppKit/dep-free, pure → unit-testable via `tsx` (feed chunked input, assert elements emitted incrementally + correctly).
- **`useStreamJSON` wiring:** when streaming is feasible (no `dataPath`, response body is a stream, top-level array), read `res.body` via a reader, feed the incremental extractor, and `setData` the accumulated (transform/filter-applied) items in batches as they arrive (so the UI updates progressively); `isLoading` stays true until the stream ends. When `dataPath` is set OR the body isn't streamable OR parsing the top-level array fails, FALL BACK to the existing load-whole path (no regression). `pageSize` (if Raycast's option) caps the per-batch emit.
- Keep `initialData`/`filter`/`transform`/`execute`/`onError` semantics identical.

## Verification
- **tsx unit test (primary):** the incremental extractor — feed a JSON array split across arbitrary chunk boundaries (incl. boundaries mid-string, mid-number, mid-element); assert it emits each complete element exactly once, in order, and the full set equals `JSON.parse(whole)`. Edge: empty array, single element, strings containing `]`/`{`/`,`, nested objects/arrays, escaped quotes.
- **Integration (light):** `useStreamJSON` against a small bundled/`data:` JSON resolves to the same result as before (load-whole parity) — verified via the existing typecheck + a tsx harness if feasible; no app fixture (serving a stream in-app is impractical; the extractor test + load-whole-parity are the gates).

## Out of scope
- Streaming a NESTED array via `dataPath` (loads whole — the extractor only streams a top-level array). Note as residual.
- True backpressure / temp-file caching (Raycast caches to a temp file) — deferred.
