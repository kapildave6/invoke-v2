# Form/Detail Fidelity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Render `Form.PasswordField`/`DatePicker` natively and `Detail.Metadata` `Label`/`Link`/`TagList` faithfully (colored, clickable, chips) across both metadata render paths.

**Architecture:** Give the two Form members their own host types and render them as `NSSecureTextField`/`NSDatePicker` via the existing form-field registration pattern. Add one shared `renderMetadataNode` (colored Label+icon, clickable Link, colored-tag chips, Separator) and route both `renderExtensionDetail` and `detailMetadataSidebar` through it. Reuses Chunk-A `chip`/`RaycastColor`/`accessoryIcon`.

**Tech Stack:** TypeScript (`@invoke/api`), Swift/AppKit (`apps/macos`).

## Global Constraints

- **Non-changed surfaces unchanged:** existing form fields (textfield/textarea/checkbox/dropdown) and the built-in clipboard/snippet metadata prop-array path (`metadataRow`, `~:673`) are untouched.
- DatePicker value crosses the wire as an **ISO-8601 string** (matching Chunk-A's date convention); parse with `RaycastColor.parseISODate`.
- New form types must be added to **both** `fieldTypes` sets (reconcile fast-path `~:1262` and `renderFormSurface` `~:1362`).
- The shared `renderMetadataNode` is used by BOTH `renderExtensionDetail` (master-detail pane) and `detailMetadataSidebar` (standalone Detail) — the sidebar currently drops Link/TagList; routing it through the shared renderer fixes that.
- Reuse existing helpers: `chip(_:color:)`, `accessoryColor(_:)` (PaletteView's JSONValue→NSColor dispatch, `~:2033`), `RaycastColor.parseISODate`, `accessoryIcon(_:tint:)`, `nonNull`, `styledFieldBox()`, the form `formControls`/`formFieldInfo`/`formFieldViewById`/`formApply`/`preservedFormValues`/`firstFormResponder`/`formResponderViews` machinery, and `onFormFieldChange`. Do not reimplement them.
- CLT-only: `swift build` + a fixture in the running app (no XCTest/pixels; color/date parsing already covered by Chunk-A `RaycastColor` tests). Commit on `main`; push after each task.

---

### Task 1: Form PasswordField + DatePicker

**Files:**
- Modify: `packages/api/src/index.ts` (add `form-password`/`form-datepicker` types; point `Form.PasswordField`/`DatePicker` at them)
- Modify: `apps/macos/Sources/InvokePalette/PaletteView.swift` (two field cases + both `fieldTypes` sets + `formDatePickerChanged`)

**Interfaces:**
- Produces: form nodes of type `form-password` / `form-datepicker`, collected into form values like other fields.

- [ ] **Step 1: `@invoke/api` types** — in `packages/api/src/index.ts`, add to the `T` map (after `FormDropdownSection`):

```ts
  FormPassword: "form-password",
  FormDatePicker: "form-datepicker",
```
Then change the two aliases (currently `host(T.FormTextField)`):

```ts
Form.PasswordField = host(T.FormPassword);
Form.DatePicker = host(T.FormDatePicker);
```

- [ ] **Step 2: Typecheck**

Run: `npm run typecheck 2>&1 | tail -5`
Expected: no new errors (the known pre-existing `accessory-demo` `Icon.ArrowRight` error is unrelated).

- [ ] **Step 3: Add the two field types to both `fieldTypes` sets** — in `PaletteView.swift`, both `let fieldTypes: Set<String> = [...]` literals (the reconcile fast-path `~:1262` and `renderFormSurface` `~:1362`) gain `"form-password", "form-datepicker"`.

- [ ] **Step 4: Add the `form-password` case** — in `formFieldRow`, after the `form-textfield` case, add (mirrors `form-textfield` exactly, with a secure field):

```swift
        case "form-password":
            let seeded = f.props["value"]?.stringValue ?? f.props["defaultValue"]?.stringValue ?? ""
            let sf = NSSecureTextField(string: seeded.isEmpty ? (preservedFormValues[id] ?? "") : seeded)
            sf.placeholderString = f.props["placeholder"]?.stringValue
            sf.isBezeled = false; sf.drawsBackground = false; sf.focusRingType = .none
            sf.font = .systemFont(ofSize: 13); sf.textColor = .labelColor
            sf.translatesAutoresizingMaskIntoConstraints = false
            sf.target = self; sf.action = #selector(formFieldEnter)
            sf.cell?.sendsActionOnEndEditing = false
            let box = Self.styledFieldBox(); box.addSubview(sf)
            NSLayoutConstraint.activate([
                box.heightAnchor.constraint(equalToConstant: 28),
                sf.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 9),
                sf.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -9),
                sf.centerYAnchor.constraint(equalTo: box.centerYAnchor),
            ])
            formControls.append((id, { [weak sf] in sf?.stringValue ?? "" }))
            sf.delegate = self
            formFieldInfo[ObjectIdentifier(sf)] = (id, f.props["onChange"]?.handlerRef)
            formFieldViewById[id] = sf
            if firstFormResponder == nil { firstFormResponder = sf }
            formResponderViews.append(sf)
            formApply[id] = { [weak sf] n in if let v = n.props["value"]?.stringValue, sf?.stringValue != v { sf?.stringValue = v } }
            control = box
            rowAlignment = .centerY
```

- [ ] **Step 5: Add the `form-datepicker` case** — after the `form-password` case:

```swift
        case "form-datepicker":
            let dp = NSDatePicker()
            dp.datePickerStyle = .textFieldAndStepper
            dp.datePickerElements = .yearMonthDay
            dp.isBezeled = false; dp.drawsBackground = false
            dp.font = .systemFont(ofSize: 13)
            dp.translatesAutoresizingMaskIntoConstraints = false
            if let iso = f.props["value"]?.stringValue ?? f.props["defaultValue"]?.stringValue,
               let d = RaycastColor.parseISODate(iso) { dp.dateValue = d }
            dp.target = self; dp.action = #selector(formDatePickerChanged(_:))
            let box = Self.styledFieldBox(); box.addSubview(dp)
            NSLayoutConstraint.activate([
                box.heightAnchor.constraint(equalToConstant: 28),
                dp.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 9),
                dp.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -9),
                dp.centerYAnchor.constraint(equalTo: box.centerYAnchor),
            ])
            let isoOut = ISO8601DateFormatter()
            formControls.append((id, { [weak dp] in dp.map { isoOut.string(from: $0.dateValue) } ?? "" }))
            formFieldInfo[ObjectIdentifier(dp)] = (id, f.props["onChange"]?.handlerRef)
            formFieldViewById[id] = dp
            formResponderViews.append(dp)
            formApply[id] = { [weak dp] n in if let iso = n.props["value"]?.stringValue, let d = RaycastColor.parseISODate(iso) { dp?.dateValue = d } }
            control = box
            rowAlignment = .centerY
```

- [ ] **Step 6: Add the date-picker change handler** — add near `formFieldEnter` (`~:75`):

```swift
    @objc private func formDatePickerChanged(_ sender: NSDatePicker) {
        guard let info = formFieldInfo[ObjectIdentifier(sender)], let h = info.onChange else { return }
        onFormFieldChange?(h, ISO8601DateFormatter().string(from: sender.dateValue))
    }
```
(`onFormFieldChange` is the same callback `controlTextDidChange` uses for live `onChange`; AppController wires it to `extHost.invoke(handler:args:)`.)

- [ ] **Step 7: Build**

Run: `swift build --package-path apps/macos 2>&1 | tail -3`
Expected: `Build complete!` (ignore stale SourceKit "cannot find …" errors if the build succeeds).

- [ ] **Step 8: Commit**

```bash
git add packages/api/src/index.ts apps/macos/Sources/InvokePalette/PaletteView.swift
git commit -m "Form: native PasswordField (NSSecureTextField) + DatePicker (NSDatePicker, ISO value)"
git push origin main
```

---

### Task 2: shared `renderMetadataNode` (Label colored/icon · Link clickable · TagList chips)

**Files:**
- Modify: `apps/macos/Sources/InvokePalette/PaletteView.swift` (`metaRow` helper, `metadataLink` helper, `renderMetadataNode`; route `renderExtensionDetail` + `detailMetadataSidebar` through it)

**Interfaces:**
- Consumes: `chip(_:color:)`, `accessoryColor(_:)`, `accessoryIcon(_:tint:)`, `nonNull`.
- Produces: `renderMetadataNode(_ child: ViewNode) -> NSView?`.

- [ ] **Step 1: Add a generalized row + a link control + the node renderer** — add near `metadataRow` (`~:706`):

```swift
    /// A metadata row: secondary title on the left, an arbitrary value view on the right.
    private func metaRow(_ label: String, _ valueView: NSView) -> NSView {
        let l = NSTextField(labelWithString: label)
        l.font = .systemFont(ofSize: 12); l.textColor = .secondaryLabelColor
        l.translatesAutoresizingMaskIntoConstraints = false
        valueView.translatesAutoresizingMaskIntoConstraints = false
        let row = NSView(); row.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(l); row.addSubview(valueView)
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 18),
            l.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            l.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            l.topAnchor.constraint(greaterThanOrEqualTo: row.topAnchor),
            valueView.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            valueView.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            valueView.leadingAnchor.constraint(greaterThanOrEqualTo: l.trailingAnchor, constant: 12),
            valueView.topAnchor.constraint(greaterThanOrEqualTo: row.topAnchor),
            valueView.bottomAnchor.constraint(lessThanOrEqualTo: row.bottomAnchor),
        ])
        return row
    }

    /// A clickable metadata link — accent-colored text that opens `target` on click.
    private func metadataLink(_ text: String, target: String) -> NSView {
        let b = NSButton(title: text, target: self, action: #selector(openMetadataLink(_:)))
        b.isBordered = false
        b.contentTintColor = .linkColor
        b.font = .systemFont(ofSize: 12)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.identifier = NSUserInterfaceItemIdentifier(target)
        return b
    }
    @objc private func openMetadataLink(_ sender: NSButton) {
        guard let t = sender.identifier?.rawValue, let url = URL(string: t) else { return }
        NSWorkspace.shared.open(url)
    }

    /// Render one extension Detail.Metadata child (Label/Link/TagList/Separator). nil if unsupported/empty.
    private func renderMetadataNode(_ child: ViewNode) -> NSView? {
        let title = child.props["title"]?.stringValue ?? ""
        switch child.type {
        case "metadata-label":
            let value = child.props["text"]?.stringValue ?? child.props["value"]?.stringValue ?? ""
            let lbl = NSTextField(labelWithString: value)
            lbl.font = .systemFont(ofSize: 12)
            lbl.textColor = accessoryColor(child.props["color"]) ?? .labelColor
            lbl.alignment = .right; lbl.lineBreakMode = .byTruncatingTail
            if let icon = nonNull(child.props["icon"]), let iv = accessoryIcon(icon, tint: nil) {
                let h = NSStackView(views: [iv, lbl]); h.spacing = 4; h.alignment = .centerY
                return metaRow(title, h)
            }
            return metaRow(title, lbl)
        case "metadata-link":
            let text = child.props["text"]?.stringValue ?? title
            guard let target = child.props["target"]?.stringValue, !target.isEmpty else {
                let lbl = NSTextField(labelWithString: text); lbl.font = .systemFont(ofSize: 12); lbl.alignment = .right
                return metaRow(title, lbl)
            }
            return metaRow(title, metadataLink(text, target: target))
        case "metadata-taglist":
            let flow = NSStackView(); flow.orientation = .horizontal; flow.spacing = 4; flow.alignment = .centerY
            for item in child.children where item.type == "metadata-taglist-item" {
                let txt = item.props["text"]?.stringValue ?? item.props["title"]?.stringValue ?? ""
                guard !txt.isEmpty else { continue }
                flow.addArrangedSubview(chip(txt, color: accessoryColor(item.props["color"])))
            }
            return flow.arrangedSubviews.isEmpty ? nil : metaRow(title, flow)
        case "metadata-separator":
            let box = NSBox(); box.boxType = .separator; box.translatesAutoresizingMaskIntoConstraints = false
            box.heightAnchor.constraint(equalToConstant: 1).isActive = true
            return box
        default:
            return nil
        }
    }
```

- [ ] **Step 2: Route `renderExtensionDetail` through it** — in `renderExtensionDetail` (`~:586`), replace the `switch child.type { case "metadata-label", "metadata-link": …; case "metadata-taglist": …; case "metadata-separator": … }` block (which builds plain `metadataRow`s) with:

```swift
                if let row = renderMetadataNode(child) { stack.addArrangedSubview(row) }
```
(applied for every child of the `metadata` node, replacing the per-type branches).

- [ ] **Step 3: Route `detailMetadataSidebar` through it** — in `detailMetadataSidebar` (`~:934`), replace the `for child in metaNode.children where child.type == "metadata-label" { … }` loop (which renders Label only) with:

```swift
        for child in metaNode.children {
            if let row = renderMetadataNode(child) { stack.addArrangedSubview(row) }
        }
```
(use the sidebar's existing stack variable name; the loop now handles Label/Link/TagList/Separator.)

- [ ] **Step 4: Build**

Run: `swift build --package-path apps/macos 2>&1 | tail -3`
Expected: `Build complete!`

- [ ] **Step 5: Commit**

```bash
git add apps/macos/Sources/InvokePalette/PaletteView.swift
git commit -m "Detail.Metadata: shared renderMetadataNode (colored Label+icon, clickable Link, colored-tag chips) on both paths"
git push origin main
```

---

### Task 3: Fixture + in-app verification

**Files:**
- Create: `examples/form-detail-demo/package.json`, `examples/form-detail-demo/src/index.tsx`

**Interfaces:**
- Consumes: the full pipeline (Tasks 1-2).

- [ ] **Step 1: Mirror an example manifest** — read `examples/calculator/package.json` and create `examples/form-detail-demo/package.json` with the same shape; one `view` command `index` titled "Form Detail Demo"; depend on `@raycast/api`.

- [ ] **Step 2: Write the command** — `examples/form-detail-demo/src/index.tsx` (a Form whose submit pushes a Detail showing the values + a metadata block):

```tsx
import { Form, Detail, ActionPanel, Action, Color, Icon, useNavigation } from "@raycast/api";

function Result({ pwLen, date }: { pwLen: number; date: string }) {
  const md = `# Submitted\n\nPassword length: **${pwLen}**\n\nDate: **${date}**`;
  return (
    <Detail
      markdown={md}
      metadata={
        <Detail.Metadata>
          <Detail.Metadata.Label title="Status" text={{ value: "Active", color: Color.Green }} icon={Icon.Check} />
          <Detail.Metadata.Link title="Docs" target="https://developers.raycast.com" text="developers.raycast.com" />
          <Detail.Metadata.Separator />
          <Detail.Metadata.TagList title="Tags">
            <Detail.Metadata.TagList.Item text="urgent" color={Color.Red} />
            <Detail.Metadata.TagList.Item text="review" color={Color.Blue} />
            <Detail.Metadata.TagList.Item text="ok" color="#22C55E" />
          </Detail.Metadata.TagList>
        </Detail.Metadata>
      }
    />
  );
}

export default function Command() {
  const { push } = useNavigation();
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit" onSubmit={(v) => push(<Result pwLen={(v.password ?? "").length} date={String(v.when ?? "")} />)} />
        </ActionPanel>
      }
    >
      <Form.PasswordField id="password" title="Password" placeholder="secret" />
      <Form.DatePicker id="when" title="When" />
    </Form>
  );
}
```

- [ ] **Step 3: Build + relaunch**

```bash
bash scripts/build-app.sh 2>&1 | tail -3
kill "$(pgrep -f 'MacOS/invoke')" 2>/dev/null; sleep 1
nohup apps/macos/.build/Invoke.app/Contents/MacOS/invoke > /tmp/invoke-run.log 2>&1 &
sleep 3; grep -aiE "form-detail-demo|error" /tmp/invoke-run.log | tail -5
```
Expected: no `form-detail-demo` load error.

- [ ] **Step 4: Manual verification** (running app)

Run "Form Detail Demo". Verify: the Password field masks input (dots); the DatePicker is a native date stepper; submitting pushes a Detail whose metadata shows a green "Active" Label with a check icon, a clickable "developers.raycast.com" Link (opens the browser), a separator, and three colored tag chips (red/blue/green). Confirm the same metadata renders on a standalone Detail (this command's pushed Detail IS standalone — so it exercises the sidebar path).

- [ ] **Step 5: Commit**

```bash
git add examples/form-detail-demo
git commit -m "examples/form-detail-demo: PasswordField + DatePicker + Detail.Metadata Label/Link/TagList (Chunk D fixture)"
git push origin main
```

---

## Notes for the implementer

- `PaletteView.swift` line numbers have drifted across earlier chunks — locate every anchor by the QUOTED code, not line number.
- The `metadata` node's children are the `metadata-*` leaves; `renderExtensionDetail` and `detailMetadataSidebar` each iterate them — both must now call `renderMetadataNode`.
- Keep `metadataRow(label:value:)` — it still serves the built-in clipboard/snippet prop-array path; only the EXTENSION metadata-node paths change.
- Do not touch the other form-field cases or the form value/submit machinery beyond adding the two cases.
