# Chunk H — P1 metadata/form/hooks tail Design

**Part of the autonomous Raycast-parity push** (`[[autonomous-parity-goal]]`). Closes the remaining P1 depth items in `RAYCASTVSINVOKE.md`:
- `Detail.Metadata.TagList.Item` `onAction` (clickable tag) + TagList **wrapping** on overflow (§2 row).
- `Form.DatePicker` `min`/`max` + date-vs-datetime `type` + **typed `Date`** `onChange` value (§Form).
- `optimisticUpdate` / `rollbackOnError` on `mutate` (§hooks).

## Global constraints
- World-class Raycast-quality UX; never ship system-default/janky UI.
- Faithful parity; don't fabricate third-party brands. Fixture imports `@raycast/api`.
- Commit on `main`. Relaunch after build+install.
- No Xcode/XCTest → TS via tsc + `tsx`; AppKit via build + fixture/relaunch/log.

---

## Item 1 — `Detail.Metadata.TagList.Item` `onAction` + TagList wrapping

**Current:** `metadata-taglist` (`PaletteView.swift:766-773`) renders `metadata-taglist-item` children as colored chips in a single horizontal `NSStackView` — clips on overflow, and the chips aren't clickable (no `onAction`).

**Design:**
- **Wrapping:** replace the horizontal `NSStackView` with a lightweight `FlowStackView: NSView` (new, in `InvokePalette`) that lays its arranged subviews left-to-right and wraps to a new row when the next chip would exceed `bounds.width`, reporting an intrinsic/fitting height. Used for the TagList so many tags wrap instead of clipping. (Self-contained custom-layout view; `layout()` packs rows by each chip's `fittingSize.width` + spacing.)
- **`onAction` (clickable tag):** each `metadata-taglist-item` may carry an `onAction` handler ref (it's a React node, so the reconciler registers it — no new channel needed). Make the chip clickable: a `ClickableChip` (or attach a click target to the chip view) that, on click, calls a new `PaletteView.onInvokeHandler: ((String) -> Void)?` with the item's `onAction` handlerRef. `AppController` wires `palette.onInvokeHandler = { [weak self] h in self?.extHost?.invoke(handler: h) }` (the standard invoke round-trip; re-renders via the next commit). A tag without `onAction` stays a plain (non-clickable) chip.

## Item 2 — `Form.DatePicker` `min`/`max` + `type` + typed `Date` value

**Current:** `form-datepicker` (`PaletteView.swift:1609-1631`) is an `NSDatePicker` with `.yearMonthDay` only; `min`/`max` ignored; the value goes out as an ISO string (the extension's `onChange` receives a string, not a `Date`).

**Design:**
- **min/max:** `dp.minDate`/`dp.maxDate` from `f.props["min"]`/`f.props["max"]` (ISO → `Date` via `RaycastColor.parseISODate`).
- **type (date vs datetime):** Raycast `Form.DatePicker` `type` is `DatePicker.Type.Date` (date-only) or `DatePicker.Type.DateTime`. Map `f.props["type"]`: `"date"`/absent → `dp.datePickerElements = .yearMonthDay`; `"date_time"`/`"datetime"` → `[.yearMonthDay, .hourMinute]`. (Confirm the exact string the shim's `DatePicker.Type` serializes to and match it.)
- **typed `Date` value:** Raycast's `onChange(date: Date | null)` receives a `Date`. The host sends an ISO string. Fix in the **api**: make `Form.DatePicker` a thin wrapper that converts — `Form.DatePicker = (props) => host(T.FormDatePicker)({ ...props, onChange: props.onChange ? (v: unknown) => props.onChange(v ? new Date(String(v)) : null) : undefined })`. The reconciler then registers the WRAPPER's onChange (which converts ISO→Date), so the extension's handler gets a real `Date`. (Same approach option as Checkbox→bool, but done api-side since the value is a string in transit.) Keep `value`/`defaultValue` as ISO strings on the wire.

## Item 3 — `optimisticUpdate` / `rollbackOnError` on `mutate`

**Current:** `usePromise`'s `mutate` (`packages/utils/src/index.ts:88-92`) runs the async update + `revalidate()`, ignoring `_opts`. `useCachedPromise`'s `mutate` (`:391-395`) is a separate minimal copy. The `MutatePromise` type (`:492-499`) already declares `optimisticUpdate` / `rollbackOnError` / `shouldRevalidateAfter`.

**Design:**
- Add `const dataRef = useRef(data); dataRef.current = data;` in `usePromise` (so `mutate`, defined once, reads the LATEST data, not its render's stale closure).
- Rewrite `usePromise.mutate`:
  ```ts
  const mutate: MutatePromise<T> = async (asyncUpdate, opts) => {
    const rollback = dataRef.current;
    if (opts?.optimisticUpdate) setData(opts.optimisticUpdate(dataRef.current as T));
    try {
      const r = asyncUpdate ? await asyncUpdate : undefined;
      if (opts?.shouldRevalidateAfter !== false) revalidate();
      return r as never;
    } catch (e) {
      if (opts?.rollbackOnError) {
        setData(typeof opts.rollbackOnError === "function" ? opts.rollbackOnError(rollback as T) : rollback);
      }
      throw e;
    }
  };
  ```
- `useCachedPromise.mutate`: drop its custom minimal copy and **delegate to the inner `state.mutate`** (now capable) — i.e. `return { ...state, data, pagination: state.pagination };` (the spread already carries `state.mutate`; just stop overriding it). (Optimistic cache-write is a deeper Raycast feature — note as a follow-up; in-memory optimistic + rollback is the win here.)

## Item 4 — Fixture + verify

- `examples/metadata-form-demo/` (manifest mirrors `examples/empty-action-demo`, imports `@raycast/api`):
  - A `Detail` with `Detail.Metadata.TagList` of several tags (enough to wrap) where a couple have `onAction` (showToast on click) — proves wrapping + clickable tags.
  - A `Form` with a `Form.DatePicker` (`type={DatePicker.Type.Date}`, `min`/`max`) whose `onChange` pushes a `Detail` showing `value instanceof Date` + the ISO — proves typed `Date` + min/max.
  - (mutate optimisticUpdate is awkward to fixture visually; cover it with the `tsx` unit test in Item 3's task instead.)
- Verify: typecheck clean; `scripts/build-app.sh`; relaunch; `/tmp/invoke-run.log` shows the fixture loaded, no error. Human visual: tags wrap to multiple rows + clicking a tagged one fires its toast; the DatePicker honors min/max + the pushed Detail shows `instanceof Date = true`.

## Testing strategy
- **Pure/standalone (`tsx`):** `mutate` optimisticUpdate applies immediately + rollbackOnError reverts on a rejecting `asyncUpdate` (a standalone `tsx` test with a tiny fake of `setData`/`dataRef`, or a focused test of the mutate logic extracted as a pure helper).
- **AppKit/integration:** TagList wrap + clickable tag, DatePicker min/max/type, typed Date → via build + fixture + relaunch + log + human visual.

## Out of scope (tracked elsewhere)
- `useCachedPromise` optimistic CACHE write (deeper) — follow-up.
- Other typed field values beyond Checkbox(bool)/DatePicker(Date) — TagPicker→array etc. remain.
- TagList per-item `icon` is already rendered via `chip`/`accessoryColor`; no change needed beyond onAction + wrap.
