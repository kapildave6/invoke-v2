# List/Grid Pagination — Design (Chunk C of depth/parity polish)

**Date:** 2026-06-21
**Status:** approved (design); spec under review
**Scope owner:** `@invoke/api` (List/Grid pagination prop) + renderer (`PaletteView`/`AppController` near-bottom → `onLoadMore`) + `@invoke/utils` (`usePromise`/`useFetch`/`useCachedPromise` pagination).

## Goal

Support Raycast's pagination: `<List pagination={{ pageSize, hasMore, onLoadMore }}>` (and Grid) — when the user scrolls near the bottom and `hasMore`, the host calls `onLoadMore`, the extension appends the next page, and the list grows. Plus the hook convenience most extensions actually use: `usePromise`/`useFetch`/`useCachedPromise` that fetch page-by-page, accumulate `data`, and hand back a ready-made `pagination` object.

This is Chunk C of "depth/parity polish". Throttle-during-pagination and exotic cursor strategies are out of scope.

## Background — current state

- **No pagination anywhere** (`RAYCASTVSINVOKE.md`: `List pagination {hasMore,onLoadMore,pageSize}` ⬜ "not wired anywhere").
- **Renderer:** List = virtualized `NSTableView` in `listScroll` (`PaletteView`); Grid = `NSCollectionView`. Neither observes scroll position; there is no near-bottom signal. Extension handlers are invoked from `AppController` via `extHost?.invoke(handler:args:)` (e.g. `onFormFieldChange`, `onChange`, `onAction`).
- **Wire:** `serializeProps` (`runtime/reconciler/src/index.ts`) converts only **top-level** function props to `{__handler}`; a function **nested inside an object prop** (like `pagination.onLoadMore`) is NOT converted and is dropped by the frame's `JSON.stringify`. → pagination must be flattened to top-level props in `@invoke/api` (see Unit 1).
- **Hooks:** `usePromise(fn, deps)` is non-paginated. `useFetch` already accepts `mapResult → { data, hasMore? }` and `useCachedPromise` notes the `{ data, hasMore }` convention — but none accumulate pages, manage page state, or expose a `pagination` object.
- The top `isLoading` sweep bar (Chunk A) already exists and is the loading affordance during page loads.

## Raycast contract (the target; verify against a real extension when one is available — Context7 was unavailable)

- **Prop:** `pagination?: { pageSize: number; hasMore: boolean; onLoadMore: () => void }` on `List` and `Grid`.
- **Paginated hook fn is curried:** `usePromise((...deps) => async (options: { page: number }) => ({ data: T[], hasMore: boolean }), deps)`. The hook detects pagination by calling `fn(...deps)` once and seeing it return a **function** (the outer call is side-effect-free — it just returns the inner async fetcher). It accumulates `data` across pages, resets to page 0 when `deps` change, and returns `pagination: { pageSize, hasMore, onLoadMore }`. Non-curried `fn` keeps today's non-paginated behavior.
- **`useFetch` paginated form:** the `url` argument is a function of `{ page }`; `mapResult` returns `{ data, hasMore }`; `data` accumulates; returns `pagination`.

## Architecture — four units

### Unit 1 — `@invoke/api`: flatten the `pagination` prop

In the `host()` factory (`packages/api/src/index.ts`), after the existing slot-lifting: if `rest.pagination` is an object, hoist it to serializable top-level props and drop the object:
```
rest.onLoadMore = rest.pagination.onLoadMore        // top-level fn → becomes {__handler} via serializeProps
rest.paginationHasMore = rest.pagination.hasMore
rest.paginationPageSize = rest.pagination.pageSize
delete rest.pagination
```
Gated on `rest.pagination` existing, so only List/Grid (the components that take it) are affected. This is the minimal fix for the nested-function wire gap; no reconciler change.

### Unit 2 — Renderer: near-bottom detection + `onLoadMore` control

**`PaletteView` (pure UI signal):** enable bounds notifications on `listScroll.contentView` (`postsBoundsChangedNotifications = true`) and observe `NSView.boundsDidChangeNotification`; for the grid, observe its scroll view's content bounds (or `collectionView(_:willDisplay:forItemAt:)` for the last items). When the viewport's `maxY` comes within a threshold (~2 row/cell heights) of the document height, fire a new callback `var onReachedEnd: (() -> Void)?`. PaletteView holds no pagination policy — it only signals "scrolled near the end."

**`AppController` (policy):** wire `palette.onReachedEnd = { self.handleReachedEnd() }`. `handleReachedEnd` finds the active list/grid surface node and, if it has an `onLoadMore` handler **and** `paginationHasMore` is true **and** no load is in flight, calls `extHost?.invoke(handler:)` and sets `loadMoreInFlight = true`, recording the current item count. The guard is cleared on the next commit when the item count grows or `paginationHasMore` flips false (prevents spamming `onLoadMore` during a fetch). The top `isLoading` sweep bar covers the visible "loading" state (the hook/extension sets `isLoading` while fetching).

### Unit 3 — `usePromise` pagination (`packages/utils`)

Extend `usePromise(fn, deps, options?)` to detect the curried/paginated form. Factor the page bookkeeping into a small **pure** helper so it's unit-testable without a React renderer:
```
mergePages(existing: T[], pageData: T[], page: number): T[]   // page 0 replaces; page>0 appends
```
The hook, in paginated mode: holds `page` + accumulated `data` + `hasMore` state; on mount/deps-change resets to page 0 and runs the inner fetcher with `{ page: 0 }`; `pagination.onLoadMore` increments `page` (guarded by `hasMore` and not-loading), runs the fetcher with the new page, and `mergePages`-es the result. Returns `{ data (accumulated), isLoading, error, revalidate, mutate, pagination: { pageSize, hasMore, onLoadMore } }`. Non-paginated `fn` is unchanged (returns today's shape, `pagination` absent/undefined).

### Unit 4 — `useFetch` + `useCachedPromise` pagination

Both delegate to Unit 3's core. `useFetch`: when `url` is a function of `{ page }`, build the paginated fetcher (`mapResult → { data, hasMore }` feeds `mergePages`); expose `pagination`. `useCachedPromise`: same curried-fn detection as `usePromise`, sharing the pagination core. Non-paginated calls of both are unchanged.

## Data flow

`extension <List pagination={p}>` (p from a hook or hand-rolled) → `@invoke/api` flattens to `onLoadMore`/`paginationHasMore`/`paginationPageSize` → reconciler (`onLoadMore` → `{__handler}`) → host list node props → `PaletteView` near-bottom → `onReachedEnd` → `AppController.handleReachedEnd` → `extHost.invoke(onLoadMore)` → hook increments page, fetches, `mergePages`, re-renders with more items + new `hasMore`.

## Error handling

- A page fetch that rejects sets the hook's `error` (existing usePromise error path) and leaves accumulated `data` intact; `loadMoreInFlight` clears on the next commit so the user can retry by scrolling.
- `onLoadMore` invoked with no handler, `paginationHasMore` false, or in-flight → no-op.
- A `pagination` object missing `onLoadMore` (hand-rolled, malformed) → the list renders without pagination (no crash).
- Deps change mid-pagination → reset to page 0 (the hook discards stale pages).

## Testing (CLT-only — no Xcode/pixels; JS tests are standalone `tsx`)

- **Pure `mergePages`** via a standalone `tsx` test: page 0 replaces; page>0 appends; out-of-order guard.
- **Renderer** via `swift build` + a paginated fixture (`examples/` — a List whose `onLoadMore` appends another page of items until a cap, with `hasMore` flipping false) in the running app: scrolling near the bottom grows the list, the top bar shows during the load, and it stops at the cap (no infinite `onLoadMore`).
- Hook integration (page state, reset-on-deps) is exercised by the same fixture if it uses `usePromise` pagination.

## Files

- **Modify** `packages/api/src/index.ts`: flatten `pagination` in `host()`.
- **Modify** `apps/macos/Sources/InvokePalette/PaletteView.swift`: bounds observation + `onReachedEnd`.
- **Modify** `apps/macos/Sources/InvokeShell/AppController.swift`: `onReachedEnd` wiring + `handleReachedEnd` (hasMore + in-flight guard + invoke).
- **Modify** `packages/utils/src/index.ts`: `mergePages` + pagination in `usePromise`/`useFetch`/`useCachedPromise`.
- **Create** `examples/pagination-demo/` (or extend a fixture): a paginated List.
