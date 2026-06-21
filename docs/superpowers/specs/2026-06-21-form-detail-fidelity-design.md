# Form/Detail Fidelity — Design (Chunk D of depth/parity polish)

**Date:** 2026-06-21
**Status:** approved (design); spec under review
**Scope owner:** `@invoke/api` (2 form types) + `PaletteView` (form fields + Detail.Metadata rendering).

## Goal

Render Form and Detail.Metadata members natively instead of degrading them: `Form.PasswordField` → masked input; `Form.DatePicker` → native date picker; `Detail.Metadata.Label` → colored text + icon; `Detail.Metadata.Link` → clickable; `Detail.Metadata.TagList` → per-tag colored/icon chips — across **both** metadata render paths.

This is Chunk D (final) of "depth/parity polish".

## Background — current state

- `@invoke/api` (`packages/api/src/index.ts:213-214`): `Form.PasswordField = host(T.FormTextField)` and `Form.DatePicker = host(T.FormTextField)` — both render as plain text fields (no masking, no picker).
- Form renderer `formFieldRow` (`PaletteView.swift:1415`) dispatches by type (`form-textfield`/`textarea`/`checkbox`/`dropdown`/`description`/`separator`). Each case builds a control and registers value collection via `formControls.append((id, { () -> String }))`, plus `formFieldInfo` (live `onChange`), `formFieldViewById`, and `formApply` (reconcile value update). `form-textfield` (`:1445`) is the template.
- Detail.Metadata has TWO render paths, both producing plain text:
  - master-detail right pane `renderExtensionDetail` (`~:586`): `metadata-label`/`metadata-link` → `metadataRow(label, value)` (plain text); `metadata-taglist` → comma-joined text.
  - standalone Detail sidebar `detailMetadataSidebar` (`~:934`): loops `where child.type == "metadata-label"` only — **Link and TagList are dropped**.
- Node types + leaves all exist in `@invoke/api`: `MetadataLink`, `MetadataTagList` + `TagList.Item` (`metadata-taglist-item`, lifts `onAction`).
- Chunk-A building blocks exist and are reused: `chip(_:color:)`, `RaycastColor` (named/hex/dynamic colors + `parseISODate`), `accessoryIcon(_:tint:)`, and `openTarget(_:)`.

## Architecture — three units

### Unit 1 — `@invoke/api`: distinct form types

Add `FormPassword: "form-password"` and `FormDatePicker: "form-datepicker"` to the `T` map; change `Form.PasswordField = host(T.FormPassword)` and `Form.DatePicker = host(T.FormDatePicker)`. (Non-renderer-flow change; the new types pass through the generic reconciler.)

### Unit 2 — Form renderer: PasswordField + DatePicker

In `formFieldRow`, add the two field types to **both** `fieldTypes` sets (the reconcile fast-path `~:1262` and `renderFormSurface` `~:1362` — a field missing from either renders-but-won't-reconcile or vice versa), and add two new `case`s, each mirroring `form-textfield`'s registration pattern:

- **`form-password`:** an `NSSecureTextField` in the shared `styledFieldBox()`. Seed from `value`/`defaultValue`/`preservedFormValues[id]`. Register `formControls.append((id, { secure?.stringValue ?? "" }))`, `formFieldInfo` (onChange), `formFieldViewById`, `formApply`. Submit/Enter wiring identical to `form-textfield`. Masking is automatic.
- **`form-datepicker`:** an `NSDatePicker` (`.textFieldAndStepper`, date-only) in the styled box. Seed `dateValue` from `RaycastColor.parseISODate(value)` (falls back to now). Register `formControls.append((id, { ISO8601 string of datePicker.dateValue }))` — the wire value is an ISO-8601 string (matching Chunk-A's date convention), so the extension's submit handler receives a parseable date string. `formApply` updates `dateValue` from a new ISO `value`. (DatePicker has no free-text caret, so no `onChange`-on-typing; fire `onChange` on `NSDatePicker` action if the field declares one.)

Value collection, reconcile, and submit already iterate `formControls`/`formFieldSignature`, so both fields integrate with no changes to the form machinery.

### Unit 3 — shared `renderMetadataNode`

Add `private func renderMetadataNode(_ child: ViewNode) -> NSView?` returning a row view per metadata child type, and route BOTH `renderExtensionDetail` and `detailMetadataSidebar` through it (replacing their per-type branches). This unifies the two paths — the standalone sidebar gains Link/TagList — and upgrades rendering:

- **`metadata-label`:** `title` + value text; value colored via `RaycastColor.nsColor(child.props["color"])` when present; optional leading icon via `accessoryIcon(child.props["icon"], tint:)`.
- **`metadata-link`:** `title` + the link text rendered as a clickable control (accent color, pointing-hand cursor) that calls `openTarget(child.props["target"]?.stringValue)` on click.
- **`metadata-taglist`:** `title` + a horizontal flow of `chip(text, color:)` — one per `metadata-taglist-item` child, color via `RaycastColor.nsColor(item.props["color"])`, optional icon via `accessoryIcon`; a tag with an `onAction` handler is clickable (invokes the handler via the existing extension-action path).
- **`metadata-separator`:** a thin `NSBox` separator.

`metadataRow(label:value:)` stays for the built-in clipboard/snippet prop-array path (`~:673`) — that's not extension metadata nodes, out of scope.

## Data flow

`extension <Form.PasswordField/DatePicker> / <Detail.Metadata.{Label,Link,TagList}>` → reconciler → host nodes (`form-password`/`form-datepicker`; `metadata-*`) → `PaletteView` form/metadata renderers → AppKit (NSSecureTextField/NSDatePicker; colored text/clickable link/chips). DatePicker value ↔ wire as ISO-8601 string.

## Error handling

- Malformed/empty metadata children are skipped by `renderMetadataNode` (returns nil); a bad child never aborts the pane.
- A Link with no `target` renders as non-clickable text. A TagList with no items renders nothing. Unparseable DatePicker `value` → seed today.
- Form value collection for a never-touched DatePicker returns its seeded date's ISO string (deterministic).

## Testing (CLT-only — no Xcode/pixels)

`swift build` + a fixture (`examples/form-detail-demo` or extend an existing example): a Form with a `PasswordField` + `DatePicker` whose submit action surfaces the collected values (e.g. via `showToast`), and a `Detail` (both standalone and as a `List.Item.Detail`) with `Metadata` containing a colored `Label`, a `Link`, and a `TagList` of colored tags. Verified in the running app: password masks; date picker is native + its value submits; the link opens; tags are colored chips; the standalone sidebar now shows Link/TagList. The pure bits (color/date parsing) are already covered by Chunk-A's `RaycastColor` tests.

## Files

- **Modify** `packages/api/src/index.ts`: `form-password`/`form-datepicker` types.
- **Modify** `apps/macos/Sources/InvokePalette/PaletteView.swift`: two form-field cases (+ `fieldTypes`/signature); `renderMetadataNode` + route both metadata paths through it.
- **Create** a fixture exercising the fields + metadata.
