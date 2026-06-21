# List/Grid Pagination Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Support Raycast pagination: `<List pagination={{ pageSize, hasMore, onLoadMore }}>` (+ Grid) with scroll-to-load-more, and page-accumulating `usePromise`/`useFetch`/`useCachedPromise`.

**Architecture:** `@invoke/api` flattens the `pagination` prop (a nested `onLoadMore` fn isn't serialized otherwise). The renderer signals near-bottom (`PaletteView.onReachedEnd`); `AppController` invokes `onLoadMore` on the extension host, guarded against in-flight repeats. The hooks detect Raycast's curried paginated fn, accumulate `data` across pages via a pure `mergePages`, and expose a `pagination` object. Loading reuses the Chunk-A top sweep bar.

**Tech Stack:** TypeScript (`@invoke/api`, `@invoke/utils`, React hooks), Swift/AppKit (`apps/macos`).

## Global Constraints

- **Non-paginated callers are unchanged.** `usePromise`/`useFetch`/`useCachedPromise` keep today's behavior when the fn isn't curried/paginated; `pagination` is then `undefined`.
- **`pagination.onLoadMore` must be flattened to a top-level prop** in `@invoke/api` — `serializeProps` only converts top-level functions to `{__handler}`, so a nested fn is dropped by `JSON.stringify`.
- **In-flight guard:** the host invokes `onLoadMore` at most once per page — re-armed only after the next commit (the appended page) lands.
- **Raycast contract (target; Context7 was unavailable — cross-check against a real paginated extension if one appears):** prop `{ pageSize: number, hasMore: boolean, onLoadMore: () => void }`; paginated hook fn is **curried** `(...deps) => async ({ page }) => ({ data, hasMore })`; the hook accumulates `data`, resets to page 0 on deps change, returns `pagination: { pageSize, hasMore, onLoadMore }`.
- **Loading affordance = the existing top sweep bar** (Chunk A); no separate bottom row.
- **CLT-only:** pure logic (`mergePages`) via standalone `tsx`; Swift via `swift build`; the pipeline via a fixture in the running app. Commit on `main`; push after each task.

---

### Task 1: `mergePages` + `usePromise` pagination

**Files:**
- Modify: `packages/utils/src/index.ts` (`usePromise`; add `mergePages`, `PaginationOptions`)
- Test: `/private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad/mergepages.test.ts`

**Interfaces:**
- Produces: `mergePages<T>(existing: T[], pageData: T[], page: number): T[]`; `interface PaginationOptions { pageSize: number; hasMore: boolean; onLoadMore: () => void }`; `usePromise(...)` now also returns optional `pagination?: PaginationOptions`.

- [ ] **Step 1: Write the failing test** — create the test file:

```ts
import { mergePages } from "/Users/test/Documents/code/invoke-v2/packages/utils/src/index.ts";
let fails = 0;
const eq = (a: unknown, b: unknown, m: string) => { if (JSON.stringify(a) === JSON.stringify(b)) console.log("ok:", m); else { fails++; console.log("FAIL:", m, "got", JSON.stringify(a)); } };
eq(mergePages([], [1, 2], 0), [1, 2], "page 0 sets");
eq(mergePages([1, 2], [3, 4], 1), [1, 2, 3, 4], "page>0 appends");
eq(mergePages([1, 2, 3], [9], 0), [9], "page 0 replaces (deps reset)");
eq(mergePages([1, 2], [], 1), [1, 2], "empty page keeps existing");
console.log(fails === 0 ? "ALL PASS" : `${fails} FAILED`);
process.exit(fails === 0 ? 0 : 1);
```

- [ ] **Step 2: Run it to verify it fails**

Run: `npx tsx "/private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad/mergepages.test.ts"`
Expected: FAIL — `mergePages` is not exported yet.

- [ ] **Step 3: Add `mergePages` + `PaginationOptions`** — in `packages/utils/src/index.ts`, just above `usePromise` (line ~17):

```ts
export interface PaginationOptions {
  pageSize: number;
  hasMore: boolean;
  onLoadMore: () => void;
}

/** Merge a freshly-fetched page into the accumulated list: page 0 replaces (a deps reset), later pages append. */
export function mergePages<T>(existing: T[], pageData: T[], page: number): T[] {
  return page === 0 ? pageData : existing.concat(pageData);
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `npx tsx "/private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad/mergepages.test.ts"`
Expected: `ALL PASS`.

- [ ] **Step 5: Add pagination to `usePromise`** — replace the whole `usePromise` function (lines ~17-57) with:

```ts
export function usePromise<T>(
  fn: (...args: unknown[]) => Promise<T> | ((opts: { page: number }) => Promise<{ data: T; hasMore?: boolean }>),
  deps: unknown[] = [],
): AsyncState<T> & { mutate: MutatePromise<T>; pagination?: PaginationOptions } {
  const [data, setData] = useState<T | undefined>(undefined);
  const [isLoading, setLoading] = useState(true);
  const [error, setError] = useState<Error | undefined>(undefined);
  const [nonce, setNonce] = useState(0);
  const [hasMore, setHasMore] = useState(false);
  const [paginated, setPaginated] = useState(false);
  const [pageSize, setPageSize] = useState(0);
  const page = useRef(0);
  const acc = useRef<unknown[]>([]);
  const latest = useRef(0);

  const runPage = useCallback((p: number, run: number) => {
    Promise.resolve()
      .then(() => fn(...deps))
      .then((maybe) => {
        if (typeof maybe === "function") {
          // Raycast paginated form: fn(...deps) returns an async fetcher of { page }.
          if (run === latest.current) setPaginated(true);
          return Promise.resolve((maybe as (o: { page: number }) => Promise<{ data: T; hasMore?: boolean }>)({ page: p })).then((res) => {
            if (run !== latest.current) return;
            const pageData = (res?.data ?? []) as unknown[];
            if (p === 0) setPageSize(Array.isArray(pageData) ? pageData.length : 0);
            acc.current = mergePages(acc.current, pageData, p);
            setData(acc.current as unknown as T);
            setHasMore(!!res?.hasMore);
            setLoading(false);
          });
        }
        // Non-paginated (today's behavior): fn(...deps) is the value/Promise itself.
        if (run === latest.current) setPaginated(false);
        return Promise.resolve(maybe as Promise<T>).then((d) => {
          if (run === latest.current) { setData(d); setLoading(false); }
        });
      })
      .catch((e: unknown) => {
        if (run === latest.current) { setError(e instanceof Error ? e : new Error(String(e))); setLoading(false); }
      });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps);

  useEffect(() => {
    const run = ++latest.current;
    setLoading(true); setError(undefined);
    page.current = 0; acc.current = [];
    runPage(0, run);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [nonce, ...deps]);

  const onLoadMore = useCallback(() => {
    if (!hasMore || isLoading) return;
    page.current += 1;
    setLoading(true);
    runPage(page.current, latest.current);
  }, [hasMore, isLoading, runPage]);

  const revalidate = useCallback(() => setNonce((n) => n + 1), []);
  const mutate: MutatePromise<T> = async (asyncUpdate, _opts) => {
    const r = asyncUpdate ? await asyncUpdate : undefined;
    revalidate();
    return r as never;
  };
  const pagination = paginated ? { pageSize: pageSize || 50, hasMore, onLoadMore } : undefined;
  return { data, isLoading, error, revalidate, mutate, pagination };
}
```

(Note: the non-paginated path now calls `fn(...deps)` instead of `fn()`; existing 0-arg fns ignore the extra args, so behavior is unchanged.)

- [ ] **Step 6: Typecheck**

Run: `npm run typecheck 2>&1 | tail -8`
Expected: no errors. (If a pre-existing unrelated error appears, confirm it predates this change with `git stash` + re-run; otherwise fix yours.)

- [ ] **Step 7: Commit**

```bash
git add packages/utils/src/index.ts
git commit -m "usePromise: pagination (curried fn → page accumulation via mergePages → pagination object)"
git push origin main
```

---

### Task 2: `useFetch` + `useCachedPromise` pagination

**Files:**
- Modify: `packages/utils/src/index.ts` (`useFetch`, `useCachedPromise`)

**Interfaces:**
- Consumes (Task 1): `usePromise` pagination, `mergePages`, `PaginationOptions`.
- Produces: `useFetch`/`useCachedPromise` also return optional `pagination?: PaginationOptions`.

- [ ] **Step 1: Paginate `useCachedPromise`** — it already delegates to `usePromise`. Locate its `usePromise<T>(async () => { … }, deps)` call (search `useCachedPromise`). Change it to forward the curried/paginated fn through to `usePromise` unchanged (so `usePromise`'s detection handles both), and include `pagination` in what it returns. Concretely, where `useCachedPromise` builds its inner fn and returns `state`, pass the user's `fn` straight to `usePromise` (it already keys deps as args) and spread `pagination`:

```ts
  const state = usePromise(fn as never, deps);
  // … existing cached-data handling …
  return { ...state, pagination: state.pagination };
```
(Keep the existing `{ data, hasMore }` unwrap for the non-paginated cached path; do not double-unwrap when `state.pagination` is present — paginated `data` is already the accumulated array.)

- [ ] **Step 2: Paginate `useFetch`** — when `url` is a function (Raycast's paginated form), build a curried fetcher so `usePromise` accumulates pages. Locate `useFetch`'s `usePromise<U>(async () => { … }, …)` body and wrap:

```ts
  const paginated = typeof url === "function";
  const state = usePromise(
    paginated
      ? (() => async ({ page }: { page: number }) => {
          const res = await fetch((url as (o: { page: number }) => string)({ page }), { method, headers, body, signal });
          const parsed = (parseResponse ? await parseResponse(res) : await res.json()) as T;
          const mapped = mapResult ? mapResult(parsed) : { data: parsed as unknown as U, hasMore: false };
          return { data: mapped.data, hasMore: mapped.hasMore };
        })
      : (async () => { /* the existing non-paginated body, unchanged */ }),
    [/* existing deps */],
  );
  return { ...state, pagination: state.pagination };
```
(Use the file's existing `method`/`headers`/`body`/`signal`/`parseResponse`/`mapResult` locals; keep the existing non-paginated branch byte-for-byte.)

- [ ] **Step 3: Typecheck**

Run: `npm run typecheck 2>&1 | tail -8`
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add packages/utils/src/index.ts
git commit -m "useFetch/useCachedPromise: pagination via usePromise's paginated core"
git push origin main
```

---

### Task 3: `@invoke/api` flatten + renderer near-bottom → `onLoadMore`

**Files:**
- Modify: `packages/api/src/index.ts` (`host()` — flatten `pagination`)
- Modify: `apps/macos/Sources/InvokePalette/PaletteView.swift` (bounds observation + `onReachedEnd`)
- Modify: `apps/macos/Sources/InvokeShell/AppController.swift` (`onReachedEnd` wiring + `handleReachedEnd`)

**Interfaces:**
- Produces: list/grid node props `onLoadMore` (handler), `paginationHasMore` (bool), `paginationPageSize` (number); `PaletteView.onReachedEnd: (() -> Void)?`.

- [ ] **Step 1: Flatten `pagination` in `host()`** — in `packages/api/src/index.ts`, inside the `host()` factory's returned component, after the slot-lifting loop and before `createElement`, add:

```ts
    // pagination.onLoadMore is a nested function; serializeProps only converts TOP-LEVEL functions to
    // handlers, so hoist it (and the scalars) to top-level props. Only List/Grid pass `pagination`.
    if (rest.pagination && typeof rest.pagination === "object") {
      const p = rest.pagination as { pageSize?: number; hasMore?: boolean; onLoadMore?: () => void };
      if (typeof p.onLoadMore === "function") rest.onLoadMore = p.onLoadMore;
      rest.paginationHasMore = !!p.hasMore;
      rest.paginationPageSize = p.pageSize;
      delete rest.pagination;
    }
```

- [ ] **Step 2: Typecheck**

Run: `npm run typecheck 2>&1 | tail -5`
Expected: no errors.

- [ ] **Step 3: Add near-bottom detection to `PaletteView`** — add the callback property near the other `on*` callbacks:

```swift
    public var onReachedEnd: (() -> Void)?
```
In the view-setup method, after `listScroll` and `gridScroll` are configured (their `documentView` set), enable + observe bounds changes on each scroll view's content view:

```swift
        for sv in [listScroll, gridScroll] {
            sv.contentView.postsBoundsChangedNotifications = true
            NotificationCenter.default.addObserver(self, selector: #selector(paletteDidScroll(_:)),
                                                   name: NSView.boundsDidChangeNotification, object: sv.contentView)
        }
```
Add the handler (anywhere in the class):

```swift
    @objc private func paletteDidScroll(_ note: Notification) {
        guard let clip = note.object as? NSClipView, let doc = clip.documentView, doc.bounds.height > 0 else { return }
        // Near the bottom: the visible region's max-Y is within half a viewport of the document end.
        if clip.bounds.maxY >= doc.bounds.height - clip.bounds.height * 0.5 { onReachedEnd?() }
    }
```

- [ ] **Step 4: Build the package**

Run: `swift build --package-path apps/macos 2>&1 | tail -3`
Expected: `Build complete!`

- [ ] **Step 5: Wire `onReachedEnd` + `handleReachedEnd` in `AppController`** — where the other `palette.on*` callbacks are assigned (search `palette.onActivate =`), add:

```swift
        palette.onReachedEnd = { [weak self] in self?.handleReachedEnd() }
```
Add the policy + guard (near the other extension-action helpers). `extensionSurfaceNode()` and `extHost` already exist:

```swift
    private var loadMoreInFlight = false
    /// The renderer reports the user scrolled near the end; if the active list/grid declares more pages and
    /// none is loading, invoke its onLoadMore handler on the extension. Re-armed on the next commit.
    private func handleReachedEnd() {
        guard mode == .extensionView, !loadMoreInFlight,
              let surface = extensionSurfaceNode(),
              surface.type == "list" || surface.type == "grid",
              Self.isTrue(surface.props["paginationHasMore"]),
              let handler = surface.props["onLoadMore"]?.handlerRef else { return }
        loadMoreInFlight = true
        extHost?.invoke(handler: handler)
    }
```
Re-arm the guard on each extension commit — in `onExtensionCommit()` (search for it), add at the top:

```swift
        loadMoreInFlight = false
```
(`Self.isTrue` is the existing bool-coercion helper; `extensionSurfaceNode()` returns the active extension surface node.)

- [ ] **Step 6: Build**

Run: `swift build --package-path apps/macos 2>&1 | tail -3`
Expected: `Build complete!` (ignore stale SourceKit "cannot find …" errors if the build succeeds).

- [ ] **Step 7: Commit**

```bash
git add packages/api/src/index.ts apps/macos/Sources/InvokePalette/PaletteView.swift apps/macos/Sources/InvokeShell/AppController.swift
git commit -m "pagination: @invoke/api flattens the prop; renderer near-bottom invokes onLoadMore (in-flight guarded)"
git push origin main
```

---

### Task 4: Paginated fixture + in-app verification

**Files:**
- Create: `examples/pagination-demo/package.json`, `examples/pagination-demo/src/index.tsx`

**Interfaces:**
- Consumes: the full pipeline (Tasks 1-3).

- [ ] **Step 1: Mirror an example manifest** — read `examples/calculator/package.json` and create `examples/pagination-demo/package.json` with the same shape, one `view` command `index` titled "Pagination Demo", depending on `@raycast/api` + `@raycast/utils`.

- [ ] **Step 2: Write the command** — `examples/pagination-demo/src/index.tsx`:

```tsx
import { List } from "@raycast/api";
import { usePromise } from "@raycast/utils";

const TOTAL = 120; // 6 pages of 20
export default function Command() {
  const { data, isLoading, pagination } = usePromise(
    () => async ({ page }: { page: number }) => {
      await new Promise((r) => setTimeout(r, 400)); // simulate a fetch
      const start = page * 20;
      const items = Array.from({ length: 20 }, (_, i) => start + i).filter((n) => n < TOTAL);
      return { data: items, hasMore: start + 20 < TOTAL };
    },
    [],
  );
  return (
    <List isLoading={isLoading} pagination={pagination}>
      {(data ?? []).map((n: number) => (
        <List.Item key={n} title={`Item ${n + 1}`} subtitle={`page ${Math.floor(n / 20) + 1}`} />
      ))}
    </List>
  );
}
```

- [ ] **Step 3: Build + relaunch**

```bash
bash scripts/build-app.sh 2>&1 | tail -3
kill "$(pgrep -f 'MacOS/invoke')" 2>/dev/null; sleep 1
nohup apps/macos/.build/Invoke.app/Contents/MacOS/invoke > /tmp/invoke-run.log 2>&1 &
sleep 3; grep -aiE "pagination-demo|error" /tmp/invoke-run.log | tail -5
```
Expected: no `pagination-demo` load error.

- [ ] **Step 4: Manual verification** (running app)

Summon Invoke → run "Pagination Demo". Verify: the list starts with ~20 items; scrolling to the bottom shows the top sweep bar briefly and appends the next 20; it keeps loading on scroll up to 120 items, then stops (no further loads, no infinite loop); the bar clears when idle.

- [ ] **Step 5: Commit**

```bash
git add examples/pagination-demo
git commit -m "examples/pagination-demo: usePromise pagination + List pagination prop (Chunk C fixture)"
git push origin main
```

---

## Notes for the implementer

- `serializeProps` keys deps as args already; `usePromise`'s `fn(...deps)` is consistent with that. Detection is by return type: a returned **function** = paginated; a returned **Promise/value** = non-paginated.
- Do not touch the bottom action bar or `currentActions()`.
- Master-detail (split) and the grid's collection view share `gridScroll`/`listScroll` content-view observation; split-pane pagination is a follow-up, not in scope.
- If a pre-existing `npm run typecheck` error is unrelated to your change, note it and proceed; do not fix unrelated code.
