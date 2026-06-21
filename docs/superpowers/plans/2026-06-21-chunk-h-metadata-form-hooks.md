# Chunk H — P1 metadata/form/hooks tail Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task.

**Goal:** TagList.Item `onAction` + TagList wrapping; `Form.DatePicker` `min`/`max`/`type`/typed `Date`; `optimisticUpdate`/`rollbackOnError` on `mutate`.

**Architecture:** Item 1 = a `FlowStackView` + clickable chips + a generic `PaletteView.onInvokeHandler` → `extHost.invoke`. Item 2 = NSDatePicker config + an api-side `Form.DatePicker` wrapper that converts ISO→`Date`. Item 3 = `usePromise.mutate` honors the opts (via a `dataRef`); `useCachedPromise` delegates to it.

**Tech Stack:** Swift/AppKit (`apps/macos`), TS (`packages/api`, `packages/utils`), TS fixture.

## Global Constraints
- World-class Raycast UX; commit on `main`; relaunch after build.
- No Xcode/XCTest: `swift build --package-path apps/macos`; TS `npx tsc --noEmit` + `tsx`.
- Ignore SourceKit "cannot find X"/"let binding" false-positives when `swift build` succeeds.

---

### Task 1: TagList.Item `onAction` (clickable) + TagList wrapping

**Files:**
- Create: `apps/macos/Sources/InvokePalette/FlowStackView.swift`
- Modify: `apps/macos/Sources/InvokePalette/PaletteView.swift` (`metadata-taglist` ~766-773; add `onInvokeHandler` member)
- Modify: `apps/macos/Sources/InvokeShell/AppController.swift` (wire `palette.onInvokeHandler`)

**Interfaces:**
- Produces: `FlowStackView` (wrapping container); `PaletteView.onInvokeHandler: ((String) -> Void)?`.

- [ ] **Step 1: Create `FlowStackView.swift`.** A wrapping flow container: lays children left→right, wraps at `bounds.width`, height follows content. (Width comes from the metadata value column; height drives the row via `intrinsicContentSize`.)
```swift
import AppKit

/// A simple wrapping flow layout (Raycast TagList wraps tags to multiple rows on overflow). Children are
/// frame-laid (not autolayout) inside this view; height is reported via intrinsicContentSize so the
/// enclosing autolayout row sizes to the wrapped content. The view itself must be given a definite width.
final class FlowStackView: NSView {
    var hSpacing: CGFloat = 4
    var vSpacing: CGFloat = 4
    private var chips: [NSView] = []
    private var computedHeight: CGFloat = 0

    override var isFlipped: Bool { true }

    func setChips(_ views: [NSView]) {
        chips.forEach { $0.removeFromSuperview() }
        chips = views
        for v in views { v.translatesAutoresizingMaskIntoConstraints = true; addSubview(v) }
        needsLayout = true
        invalidateIntrinsicContentSize()
    }

    override func layout() {
        super.layout()
        let maxW = bounds.width
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0
        for v in chips {
            let s = v.fittingSize
            if x > 0 && x + s.width > maxW { x = 0; y += rowH + vSpacing; rowH = 0 }
            v.frame = NSRect(x: x, y: y, width: s.width, height: s.height)
            x += s.width + hSpacing
            rowH = max(rowH, s.height)
        }
        let h = y + rowH
        if abs(h - computedHeight) > 0.5 { computedHeight = h; invalidateIntrinsicContentSize() }
    }

    override var intrinsicContentSize: NSSize { NSSize(width: NSView.noIntrinsicMetric, height: computedHeight) }
}
```

- [ ] **Step 2: Add the generic invoke callback to PaletteView.** Near `onFormFieldChange` (PaletteView ~1284), add:
```swift
    /// Invoke an arbitrary extension handler ref (e.g. a clickable Detail.Metadata.TagList.Item onAction).
    public var onInvokeHandler: ((String) -> Void)?
```

- [ ] **Step 3: Rewrite the `metadata-taglist` case** (`PaletteView.swift:766-773`) to wrap + make tags with `onAction` clickable:
```swift
        case "metadata-taglist":
            let flow = FlowStackView()
            flow.translatesAutoresizingMaskIntoConstraints = false
            var chips: [NSView] = []
            for item in child.children where item.type == "metadata-taglist-item" {
                let txt = item.props["text"]?.stringValue ?? item.props["title"]?.stringValue ?? ""
                guard !txt.isEmpty else { continue }
                let pill = chip(txt, color: accessoryColor(item.props["color"]))
                if let h = item.props["onAction"]?.handlerRef {
                    let click = ClickableContainer(); click.translatesAutoresizingMaskIntoConstraints = false
                    click.onClick = { [weak self] in self?.onInvokeHandler?(h) }
                    pill.translatesAutoresizingMaskIntoConstraints = false
                    click.addSubview(pill)
                    NSLayoutConstraint.activate([
                        click.leadingAnchor.constraint(equalTo: pill.leadingAnchor),
                        click.trailingAnchor.constraint(equalTo: pill.trailingAnchor),
                        click.topAnchor.constraint(equalTo: pill.topAnchor),
                        click.bottomAnchor.constraint(equalTo: pill.bottomAnchor),
                    ])
                    chips.append(click)
                } else {
                    chips.append(pill)
                }
            }
            guard !chips.isEmpty else { return nil }
            flow.setChips(chips)
            return metaRow(title, flow)
```
And add a small clickable wrapper (top of `FlowStackView.swift` or near the taglist code):
```swift
/// A view that runs a closure on click (used to make a Detail.Metadata tag chip actionable).
final class ClickableContainer: NSView {
    var onClick: (() -> Void)?
    override func mouseUp(with event: NSEvent) { onClick?() }
    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
}
```
(NOTE for the implementer: `chip(_:color:)` returns the pill view — confirm its signature. The clickable wrapper hugs the pill so its `fittingSize` equals the pill's, keeping flow layout correct. Verify the `metaRow(title, flow)` gives `flow` a definite width so `FlowStackView.layout()` can wrap + report height — if the row doesn't constrain width, add a width constraint tying `flow` to the value column.)

- [ ] **Step 4: Wire `onInvokeHandler` in AppController.** Near `palette.onFormFieldChange = ...` (~212), add:
```swift
        palette.onInvokeHandler = { [weak self] handler in self?.extHost?.invoke(handler: handler) }
```

- [ ] **Step 5: Build.** `swift build --package-path apps/macos 2>&1 | tail -10` → `Build complete!`.

- [ ] **Step 6: Commit.**
```bash
git add apps/macos/Sources/InvokePalette/FlowStackView.swift apps/macos/Sources/InvokePalette/PaletteView.swift apps/macos/Sources/InvokeShell/AppController.swift
git commit -m "feat(metadata): TagList wraps on overflow (FlowStackView) + clickable TagList.Item onAction"
```

---

### Task 2: `Form.DatePicker` `min`/`max` + `type` + typed `Date` value

**Files:**
- Modify: `apps/macos/Sources/InvokePalette/PaletteView.swift` (`form-datepicker` ~1609-1617)
- Modify: `packages/api/src/index.ts` (`Form.DatePicker` definition)

**Interfaces:**
- Consumes: `RaycastColor.parseISODate`.

- [ ] **Step 1: min/max + type in the datepicker.** In the `form-datepicker` case, after `dp.datePickerStyle = .textFieldAndStepper` and BEFORE the value seed, replace the fixed `dp.datePickerElements = .yearMonthDay` with type-driven elements + min/max:
```swift
            let dtType = (f.props["type"]?.stringValue ?? "date").lowercased()
            dp.datePickerElements = (dtType == "date_time" || dtType == "datetime") ? [.yearMonthDay, .hourMinute] : .yearMonthDay
            if let isoMin = f.props["min"]?.stringValue, let dMin = RaycastColor.parseISODate(isoMin) { dp.minDate = dMin }
            if let isoMax = f.props["max"]?.stringValue, let dMax = RaycastColor.parseISODate(isoMax) { dp.maxDate = dMax }
```
(Confirm the exact lowercased string `DatePicker.Type.DateTime` serializes to in the shim — if it's `"date_time"` keep both spellings as above; if different, match it.)

- [ ] **Step 2: typed `Date` onChange in the api.** In `packages/api/src/index.ts`, find the `Form.DatePicker = host(T.FormDatePicker)` definition. Replace it with a wrapper that converts the ISO string the host sends into a `Date` before calling the extension's `onChange`:
```ts
Form.DatePicker = ((props: Record<string, unknown> & { onChange?: (d: Date | null) => void }) =>
  createElement(T.FormDatePicker, {
    ...props,
    onChange: props.onChange ? (v: unknown) => props.onChange!(v ? new Date(String(v)) : null) : undefined,
  })) as typeof Form.DatePicker;
```
(Match the existing `host(...)`/`createElement` idiom used by the other `Form.*` members — read how `Form.PasswordField`/`Form.TextField` are defined and mirror the wrapper shape + the type cast so it stays assignable to the declared `Form.DatePicker` type. `value`/`defaultValue` stay ISO strings; only `onChange`'s argument is converted.)

- [ ] **Step 3: typecheck + build.** `cd packages/api && npx tsc --noEmit 2>&1 | tail -5`; `swift build --package-path apps/macos 2>&1 | tail -10`.

- [ ] **Step 4: Commit.**
```bash
git add apps/macos/Sources/InvokePalette/PaletteView.swift packages/api/src/index.ts
git commit -m "feat(form): DatePicker min/max + date/datetime type + typed Date onChange value"
```

---

### Task 3: `optimisticUpdate` / `rollbackOnError` on `mutate`

**Files:**
- Modify: `packages/utils/src/index.ts` (`usePromise` ~32-92; `useCachedPromise` ~391-396)
- Create (test): `/private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad/mutate-test.ts`

**Interfaces:**
- Consumes: the existing `MutatePromise<T>` type (`:492`, declares `optimisticUpdate`/`rollbackOnError`/`shouldRevalidateAfter`).

- [ ] **Step 1: Add a `dataRef` to `usePromise`** so `mutate` reads the latest data. After `const [data, setData] = useState...` (~32), add:
```ts
  const dataRef = useRef(data);
  dataRef.current = data;
```

- [ ] **Step 2: Rewrite `usePromise.mutate`** (~88-92):
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
        setData(typeof opts.rollbackOnError === "function" ? (opts.rollbackOnError as (d: T) => T)(rollback as T) : rollback);
      }
      throw e;
    }
  };
```

- [ ] **Step 3: `useCachedPromise` delegates to the inner mutate.** Replace its custom `mutate` (~391-395) + the return (~396): delete the custom `mutate` const and change the return to `return { ...state, data, pagination: state.pagination };` (the `...state` spread already carries `state.mutate`, now opts-aware). (Leave the `useEffect(onError)` line intact.)

- [ ] **Step 4: Standalone test of the mutate logic.** Create `scratchpad/mutate-test.ts` exercising the optimistic/rollback semantics with a tiny harness (no React — model `data`/`setData`/`revalidate` as closures, copy the mutate logic, or import if feasible). Minimal version:
```ts
// Models usePromise.mutate semantics. Asserts optimistic apply + rollback on rejection.
function makeMutate(initial: number) {
  let data = initial; let revalidated = 0;
  const setData = (v: number) => { data = v; };
  const revalidate = () => { revalidated++; };
  const mutate = async (asyncUpdate: Promise<void> | undefined, opts?: { optimisticUpdate?: (d: number) => number; rollbackOnError?: boolean | ((d: number) => number); shouldRevalidateAfter?: boolean }) => {
    const rollback = data;
    if (opts?.optimisticUpdate) setData(opts.optimisticUpdate(data));
    try { if (asyncUpdate) await asyncUpdate; if (opts?.shouldRevalidateAfter !== false) revalidate(); }
    catch (e) { if (opts?.rollbackOnError) setData(typeof opts.rollbackOnError === "function" ? opts.rollbackOnError(rollback) : rollback); throw e; }
  };
  return { get data() { return data; }, get revalidated() { return revalidated; }, mutate };
}
(async () => {
  // optimistic apply + revalidate on success
  const a = makeMutate(1);
  await a.mutate(Promise.resolve(), { optimisticUpdate: (d) => d + 10 });
  if (a.data !== 11 || a.revalidated !== 1) { console.error("FAIL success", a.data, a.revalidated); process.exit(1); }
  // optimistic apply then rollback on rejection
  const b = makeMutate(5);
  try { await b.mutate(Promise.reject(new Error("x")), { optimisticUpdate: (d) => d + 100, rollbackOnError: true }); console.error("FAIL no throw"); process.exit(1); }
  catch { /* expected */ }
  if (b.data !== 5) { console.error("FAIL rollback", b.data); process.exit(1); }
  console.log("ALL PASS");
})();
```

- [ ] **Step 5: Run typecheck + test.** `cd packages/utils && npx tsc --noEmit 2>&1 | tail -5`; `npx tsx /private/tmp/.../scratchpad/mutate-test.ts` → `ALL PASS`.

- [ ] **Step 6: Commit.**
```bash
git add packages/utils/src/index.ts
git commit -m "feat(hooks): mutate optimisticUpdate + rollbackOnError (usePromise; useCachedPromise delegates)"
```

---

### Task 4: Fixture (`metadata-form-demo`) + verify

**Files:** Create `examples/metadata-form-demo/package.json`, `examples/metadata-form-demo/src/metadata-form.tsx` (filename = command name).

- [ ] **Step 1: Read `examples/empty-action-demo/package.json`** and mirror (one `view` command `metadata-form`).
- [ ] **Step 2: `package.json`** (mirror; command `metadata-form` mode view).
- [ ] **Step 3: `src/metadata-form.tsx`** — a Detail with a wrapping, partly-clickable TagList + a Form.DatePicker (type Date, min/max) proving typed Date:
```tsx
import { Detail, Form, ActionPanel, Action, DatePicker, showToast, useNavigation } from "@raycast/api";

function Tags() {
  return (
    <Detail
      markdown="# Tags + DatePicker demo"
      metadata={
        <Detail.Metadata>
          <Detail.Metadata.TagList title="Labels">
            {["alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta"].map((t) => (
              <Detail.Metadata.TagList.Item key={t} text={t} onAction={t === "beta" ? () => showToast({ title: `Tag ${t} clicked` }) : undefined} />
            ))}
          </Detail.Metadata.TagList>
        </Detail.Metadata>
      }
    />
  );
}

export default function MetadataForm() {
  const { push } = useNavigation();
  return (
    <Form
      actions={<ActionPanel><Action title="Show Tags" onAction={() => push(<Tags />)} /></ActionPanel>}
    >
      <Form.DatePicker
        id="when"
        title="When"
        type={DatePicker.Type.Date}
        min={new Date(2020, 0, 1)}
        max={new Date(2030, 11, 31)}
        onChange={(d) => showToast({ title: `Date: ${d instanceof Date ? d.toISOString() : "not a Date!"}` })}
      />
    </Form>
  );
}
```
(Confirm `DatePicker.Type.Date` + `Form.DatePicker` `min`/`max` accept `Date` in the shim types; if `min`/`max` expect a string, pass ISO — match the shim. Add a shim type only if genuinely missing.)

- [ ] **Step 4: Typecheck** the fixture per the other examples.
- [ ] **Step 5: Build + relaunch + log.** `scripts/build-app.sh 2>&1 | tail -5`; relaunch; `tail -40 /tmp/invoke-run.log` → fixture loaded (+1), no error.
- [ ] **Step 6: Human visual checklist (record, don't assert):** the "Labels" TagList wraps to ≥2 rows; clicking the "beta" tag fires its toast (others inert); the DatePicker shows a date-only field honoring 2020–2030; changing it shows a toast with `Date: <ISO>` (proving `instanceof Date`, not "not a Date!").
- [ ] **Step 7: Commit.**
```bash
git add examples/metadata-form-demo
git commit -m "test(fixture): metadata-form-demo exercises TagList wrap/onAction + DatePicker typed Date/min/max"
```

---

## Self-Review

**1. Spec coverage:** TagList wrap+onAction → Task 1; DatePicker min/max/type/typed-Date → Task 2; mutate optimistic/rollback → Task 3; fixture → Task 4. ✅

**2. Placeholder scan:** Concrete code for `FlowStackView`, `ClickableContainer`, the taglist rewrite, the datepicker config, the api wrapper, the mutate rewrite, and a real assertion test. The `NOTE`s (chip signature, metaRow width, DatePicker.Type string, Form.DatePicker idiom, fixture Date types) are codebase-fit checks the implementer resolves by reading the actual code — explicit, not vague.

**3. Type/identifier consistency:** `FlowStackView`/`ClickableContainer` (Task 1) used in the taglist rewrite; `PaletteView.onInvokeHandler` defined Task 1 Step 2, wired Task 1 Step 4. `dataRef` defined Task 3 Step 1, used Step 2. `useCachedPromise` delegation (Step 3) relies on `usePromise.mutate` (Step 2). `Form.DatePicker` wrapper (Task 2) preserves the declared type.

**Known risk (final-review triage):** `FlowStackView` height-from-width in autolayout — the value column must give it a definite width or wrapping/height won't compute. If the metadata row doesn't constrain the flow width, the reviewer/implementer must add a width constraint (or pin flow leading+trailing in `metaRow`). Flag this seam for the broad review + the fixture's visual confirm (does the TagList actually wrap?).
