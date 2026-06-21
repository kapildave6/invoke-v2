# Chunk G — Alert.Options + Clipboard.read full / clear Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Honor `Alert.Options` `icon`/`rememberUserChoice`/`dismissAction.style` in the confirm modal, and make `Clipboard.read()` return the full `{text,html,file}` + add `Clipboard.clear()`.

**Architecture:** Clipboard is an api-shim change + a one-line host capability + allow-list entries. Alert.Options threads `icon`/`rememberUserChoice`/`dismissStyle` through `confirmAlert` (api) → `presentConfirmAlert` (AppController, with persist/skip) → `PaletteWindow.presentConfirm` → `ConfirmModal` (icon + checkbox + a `(confirmed, remember)` result).

**Tech Stack:** Swift 6 / AppKit (`apps/macos`), TS (`packages/api`, `runtime/node-host`), TS fixture importing `@raycast/api`.

## Global Constraints
- World-class Raycast-quality UX; never ship system-default/janky UI.
- Faithful parity; do NOT fabricate third-party brands. Fixture imports `@raycast/api`.
- Commit on `main`. Relaunch `Invoke.app` after build+install.
- Never echo secrets; the clipboard fixture uses only placeholder data and never logs real clipboard contents.
- No Xcode/XCTest: AppKit verified by `swift build --package-path apps/macos` + fixture build/relaunch/log; TS by typecheck.
- Build: `swift build --package-path apps/macos` (cwd resets — always `--package-path`). Ignore SourceKit "cannot find X in scope" / "let binding" false-positives when the build succeeds.

---

### Task 1: `Clipboard.read` full `{text,html,file}` + `Clipboard.clear`

**Files:**
- Modify: `packages/api/src/index.ts` (`Clipboard` object ~508-517)
- Modify: `apps/macos/Sources/InvokeShell/AppController.swift` (add a `clipboard.clear` capability case near `clipboard.read` ~2252)
- Modify: `apps/macos/Sources/InvokeShell/ExtensionHost.swift` (allow-list ~62-84)
- Modify: `runtime/node-host/src/supervisor.ts` (ALLOWED_RPC ~32)

**Interfaces:**
- Consumes: host `clipboard.read` (already returns `{text,file,html}`, `AppController.swift:2252`).
- Produces: `Clipboard.read()` returning `{text,file?,html?}`; `Clipboard.clear()`.

- [ ] **Step 1: api — full `read()` + `clear()`.** In `packages/api/src/index.ts`, replace the `read:` member (lines ~513-516) and add `clear`:
```ts
  // Raycast's Clipboard.read() returns { text, file?, html? } from the general pasteboard.
  read: async (): Promise<{ text: string; file?: string; html?: string }> => {
    const r = (await rpc("clipboard.read", {})) as { text?: string; file?: string; html?: string } | undefined;
    return { text: r?.text ?? "", file: r?.file, html: r?.html };
  },
  clear: () => rpc("clipboard.clear", {}) as Promise<void>,
```
(Keep `copy`, `paste`, `readText` unchanged.)

- [ ] **Step 2: host — `clipboard.clear` capability.** In `AppController.swift`, immediately after the `case "clipboard.read":` block (ends `return .object(cb)`, ~2260), add:
```swift
        case "clipboard.clear":
            NSPasteboard.general.clearContents()
            return .null
```

- [ ] **Step 3: allow-list `clipboard.read` + `clipboard.clear` in BOTH gates.**
  - `ExtensionHost.swift` (~line 63): the line currently is `"clipboard.copy", "clipboard.paste", "clipboard.readText",`. Change to `"clipboard.copy", "clipboard.paste", "clipboard.readText", "clipboard.clear",`. (`"clipboard.read"` is already present at ~line 83 — leave it.)
  - `runtime/node-host/src/supervisor.ts` (~line 35): after `"clipboard.readText",` add two entries: `"clipboard.read",` and `"clipboard.clear",`. (Confirm `clipboard.read` was missing from the supervisor list — it must be present now that the api calls it; if it's already there, just add `clipboard.clear`.)

- [ ] **Step 4: typecheck + build.** Run `cd packages/api && npx tsc --noEmit 2>&1 | tail -5` (expect clean) and `swift build --package-path apps/macos 2>&1 | tail -10` (expect `Build complete!`).

- [ ] **Step 5: Commit.**
```bash
git add packages/api/src/index.ts apps/macos/Sources/InvokeShell/AppController.swift apps/macos/Sources/InvokeShell/ExtensionHost.swift runtime/node-host/src/supervisor.ts
git commit -m "feat(clipboard): Clipboard.read full {text,html,file} + Clipboard.clear"
```

---

### Task 2: `ConfirmModal` — icon + "Don't ask again" checkbox + `(confirmed, remember)` result

**Files:**
- Modify: `apps/macos/Sources/InvokeShell/ConfirmModal.swift`
- Modify: `apps/macos/Sources/InvokeShell/PaletteWindow.swift` (`presentConfirm` ~544)
- Modify: all `presentConfirm` call sites (AppController snippet/quicklink deletes + `presentConfirmAlert`) to the new closure arity.

**Interfaces:**
- Produces: `ConfirmModal.present(in:title:message:primaryTitle:destructive:dismissTitle:icon:rememberable:dismissDestructive:then:)` where `then: (_ confirmed: Bool, _ remember: Bool) -> Void`; `PaletteWindow.presentConfirm(...)` mirrors it. Consumed by Task 3.

- [ ] **Step 1: ConfirmModal — add icon view + checkbox + new result.** In `ConfirmModal.swift`:
  - Add members: `private let iconView = NSImageView()`, `private let rememberCheck = NSButton(checkboxWithTitle: "Don't ask again", target: nil, action: nil)`.
  - Change `onResult` to `private var onResult: ((Bool, Bool) -> Void)?`.
  - In `build()`: configure `iconView` (translatesAutoresizingMaskIntoConstraints=false, contentTintColor `.secondaryLabelColor`, a 32×32 size); add it as the FIRST arranged subview of the vertical stack `v` (above `titleLabel`); configure `rememberCheck` (font systemFont(11), `translatesAutoresizingMaskIntoConstraints=false`) and insert it into `v` between `messageLabel` and `buttons`. Both `iconView` and `rememberCheck` start `isHidden = true`.
  - Update `present(...)` signature to add (defaulted) `icon: NSImage? = nil, rememberable: Bool = false, dismissDestructive: Bool = false` and change `then` to `(Bool, Bool) -> Void`. In the body: `iconView.image = icon; iconView.isHidden = (icon == nil)`; size the image to 32pt; `rememberCheck.state = .off; rememberCheck.isHidden = !rememberable`; `cancelButton.contentTintColor = dismissDestructive ? .systemRed : nil`.
  - Update `resolve(_ value: Bool)` to capture the remember state: `let cb = onResult; onResult = nil; cb?(value, rememberCheck.state == .on)`.
  - `@objc cancelTapped`/`primaryTapped` and `cancel()`/`confirm()` still call `resolve(false)`/`resolve(true)` (now forwarding the checkbox state). For a click-outside cancel (backdrop) and Esc, remember should be false regardless — that's fine since the user didn't confirm; but to be safe, only HONOR `remember` on the path AppController persists (it persists the chosen bool, and a click-outside is a dismiss=false; persisting "don't ask again → false" is acceptable Raycast behavior). Leave `resolve` reading the checkbox uniformly.

- [ ] **Step 2: PaletteWindow.presentConfirm — thread the new params + result.** Update its signature to add `icon: NSImage? = nil, rememberable: Bool = false, dismissDestructive: Bool = false` and change `then` to `(Bool, Bool) -> Void`; pass all through to `confirmModal.present(...)`.

- [ ] **Step 3: Update existing `presentConfirm` callers.** Grep `presentConfirm(` in `AppController.swift`. For every caller whose closure is `{ result in ... }` or `{ ok in ... }` (snippet delete, quicklink delete, and `presentConfirmAlert`), change the closure to `{ confirmed, _ in ... }` (they don't use remember). (Task 3 rewrites `presentConfirmAlert` fully, so you only need the others to compile here — but updating all keeps the build green after Task 2.)

- [ ] **Step 4: Build.** `swift build --package-path apps/macos 2>&1 | tail -10` → `Build complete!`.

- [ ] **Step 5: Commit.**
```bash
git add apps/macos/Sources/InvokeShell/ConfirmModal.swift apps/macos/Sources/InvokeShell/PaletteWindow.swift apps/macos/Sources/InvokeShell/AppController.swift
git commit -m "feat(alert): ConfirmModal icon + Don't-ask-again checkbox + (confirmed,remember) result"
```

---

### Task 3: `Alert.Options` wiring — `icon` + `rememberUserChoice` (persist/skip) + `dismissStyle`

**Files:**
- Modify: `packages/api/src/index.ts` (`confirmAlert` ~853-873)
- Modify: `apps/macos/Sources/InvokeShell/AppController.swift` (`presentConfirmAlert` ~2027-2036)

**Interfaces:**
- Consumes: `PaletteWindow.presentConfirm(... icon: rememberable: dismissDestructive: then: (Bool,Bool)->Void)` (Task 2); `currentExtId`.

- [ ] **Step 1: api — send icon/rememberUserChoice/dismissStyle.** In `confirmAlert` (`index.ts:861`), extend the rpc payload:
```ts
  const confirmed = (await rpc("confirmAlert", {
    title: options?.title ?? "",
    message: options?.message,
    icon: typeof options?.icon === "string" ? options.icon : (options?.icon as { source?: string } | undefined)?.source,
    primaryTitle: options?.primaryAction?.title,
    primaryStyle: options?.primaryAction?.style,
    dismissTitle: options?.dismissAction?.title,
    dismissStyle: (options?.dismissAction as { style?: string } | undefined)?.style,
    rememberUserChoice: options?.rememberUserChoice ?? false,
  })) as boolean;
```
(Add `style?: string` to the `dismissAction` type in the signature so `dismissStyle` typechecks: `dismissAction?: { title?: string; style?: string; onAction?: () => void };`. Keep the existing onAction round-trip below.)

- [ ] **Step 2: host — icon resolution + rememberUserChoice persist/skip + dismissStyle.** Replace `presentConfirmAlert` (`AppController.swift:2027`):
```swift
    private func presentConfirmAlert(_ params: JSONValue?, reply: @escaping (JSONValue) -> Void) {
        func arg(_ key: String) -> JSONValue? { if case .object(let o)? = params { return o[key] }; return nil }
        let title = arg("title")?.stringValue ?? ""
        let message = arg("message")?.stringValue
        let remember = Self.isTrue(arg("rememberUserChoice"))
        // rememberUserChoice: skip the modal if the user previously ticked "Don't ask again" for this alert.
        let rememberKey = "alertRemember.\(currentExtId).\(title)\u{1}\(message ?? "")"
        if remember, UserDefaults.standard.object(forKey: rememberKey) != nil {
            reply(.bool(UserDefaults.standard.bool(forKey: rememberKey))); return
        }
        // Icon: an SF-symbol name or asset string → NSImage (best-effort).
        var icon: NSImage? = nil
        if let src = arg("icon")?.stringValue, !src.isEmpty {
            icon = NSImage(systemSymbolName: src, accessibilityDescription: nil)
                ?? NSImage(systemSymbolName: palette.sfSymbolName(for: src), accessibilityDescription: nil)
        }
        palette.presentConfirm(
            title: title,
            message: message,
            primaryTitle: arg("primaryTitle")?.stringValue ?? "OK",
            destructive: arg("primaryStyle")?.stringValue == "destructive",
            dismissTitle: arg("dismissTitle")?.stringValue ?? "Cancel",
            icon: icon,
            rememberable: remember,
            dismissDestructive: arg("dismissStyle")?.stringValue == "destructive"
        ) { [weak self] result, rememberChoice in
            if remember, rememberChoice { UserDefaults.standard.set(result, forKey: rememberKey) }
            reply(.bool(result))
        }
    }
```
NOTE: `Self.isTrue(_:)` is an existing helper (used in PaletteView for bool props — confirm the AppController/Palette equivalent; if `isTrue` is only on PaletteView, decode inline: `if case .bool(let b)? = arg("rememberUserChoice") { ... }`). For the icon SF-symbol fallback, use the renderer's existing symbol-name mapper; if `palette.sfSymbolName(for:)` does not exist, expose a tiny mapper or just use `NSImage(systemSymbolName: src, ...)` alone (the `Icon.*` ids mostly aren't raw SF names, so prefer reusing the existing `sfSymbol(for:)` mapping — wire whichever symbol mapper the renderer already exposes; if none is reachable from AppController, pass the raw string and let `NSImage(systemSymbolName:)` resolve common cases, leaving unknown icons nil).

- [ ] **Step 3: typecheck + build.** `cd packages/api && npx tsc --noEmit 2>&1 | tail -5`; `swift build --package-path apps/macos 2>&1 | tail -10` → `Build complete!`.

- [ ] **Step 4: Commit.**
```bash
git add packages/api/src/index.ts apps/macos/Sources/InvokeShell/AppController.swift
git commit -m "feat(alert): Alert.Options icon + rememberUserChoice (persist/skip) + dismissAction.style"
```

---

### Task 4: Fixture (`alert-clipboard-demo`) + verify

**Files:** Create `examples/alert-clipboard-demo/package.json`, `examples/alert-clipboard-demo/src/demo.tsx`.

- [ ] **Step 1: Read the reference manifest.** `cat examples/empty-action-demo/package.json` — mirror its shape exactly (one `view` command).

- [ ] **Step 2: `package.json`** (mirror empty-action-demo; one command `alert-clipboard` mode view; title/description per the demo).

- [ ] **Step 3: `src/demo.tsx`.** A List with three actions (uses ONLY placeholder data; never logs real clipboard contents):
```tsx
import { List, ActionPanel, Action, Icon, Alert, Clipboard, confirmAlert, showToast, useNavigation, Detail } from "@raycast/api";
import { useState } from "react";

function Result({ text }: { text: string }) {
  return <Detail markdown={text} />;
}

export default function Demo() {
  const { push } = useNavigation();
  return (
    <List>
      <List.Item
        title="Confirm Alert (icon + remember)"
        actions={
          <ActionPanel>
            <Action
              title="Delete…"
              style={Action.Style.Destructive}
              onAction={async () => {
                const ok = await confirmAlert({
                  icon: Icon.Trash,
                  title: "Delete item?",
                  message: "This cannot be undone.",
                  primaryAction: { title: "Delete", style: Alert.ActionStyle.Destructive },
                  rememberUserChoice: true,
                });
                await showToast({ title: ok ? "Confirmed" : "Cancelled" });
              }}
            />
          </ActionPanel>
        }
      />
      <List.Item
        title="Clipboard.read (full)"
        actions={
          <ActionPanel>
            <Action
              title="Read Clipboard"
              onAction={async () => {
                await Clipboard.copy("placeholder text");
                const r = await Clipboard.read();
                push(<Result text={`# Clipboard\n\ntext: \`${r.text}\`\n\nhtml: \`${r.html ?? "—"}\`\n\nfile: \`${r.file ?? "—"}\``} />);
              }}
            />
          </ActionPanel>
        }
      />
      <List.Item
        title="Clipboard.clear"
        actions={
          <ActionPanel>
            <Action title="Clear Clipboard" onAction={async () => { await Clipboard.clear(); await showToast({ title: "Clipboard cleared" }); }} />
          </ActionPanel>
        }
      />
    </List>
  );
}
```
(If `Alert.ActionStyle.Destructive` isn't exported by the shim, use `Action.Style.Destructive` or the raw string `"destructive"` for `primaryAction.style`; confirm against the shim and use what exists.)

- [ ] **Step 4: Typecheck** the fixture the way the other `examples/` are typechecked. Add any missing prop/type to the shim only if needed (mirroring Chunk E's `CommonActionProps.style` precedent).

- [ ] **Step 5: Build + relaunch + log.** `scripts/build-app.sh 2>&1 | tail -5`; relaunch `Invoke.app`; `tail -40 /tmp/invoke-run.log` → fixture command discovered (+1), no load error.

- [ ] **Step 6: Human visual checklist (record, don't assert):** the alert shows the trash icon + a "Don't ask again" checkbox; ticking it + confirming, then re-running the action, skips the dialog and returns the remembered choice; "Read Clipboard" shows `text: placeholder text`; "Clear Clipboard" empties it (a subsequent read shows empty text).

- [ ] **Step 7: Commit.**
```bash
git add examples/alert-clipboard-demo
git commit -m "test(fixture): alert-clipboard-demo exercises Alert.Options icon/remember + Clipboard.read full/clear"
```

---

## Self-Review

**1. Spec coverage:** Alert icon/rememberUserChoice/dismissStyle → Tasks 2+3. Clipboard.read full + clear → Task 1. Fixture → Task 4. ✅ (Toast actions explicitly deferred to Chunk G′.)

**2. Placeholder scan:** Concrete code in each step. The two `NOTE:` blocks (Task 3 `isTrue`/symbol-mapper) flag real codebase-fit decisions the implementer must resolve by reading the actual helpers — not placeholders for logic, but instructions to match existing APIs; acceptable and explicit.

**3. Type/identifier consistency:** `ConfirmModal.present` + `PaletteWindow.presentConfirm` both gain `icon`/`rememberable`/`dismissDestructive` and the `(Bool,Bool)` result (Task 2), consumed by `presentConfirmAlert` (Task 3). All existing `presentConfirm` callers updated to the new arity in Task 2 Step 3 (build-green before Task 3). `clipboard.read`/`clipboard.clear` added to both allow-lists (Task 1 Step 3). api `confirmAlert` `dismissAction` type gains `style?` (Task 3 Step 1).

**Known nuances (final-review triage):** the `rememberUserChoice` key uses `title+message` (Raycast keys by content); a click-outside/Esc dismiss persists `false` if "Don't ask again" was ticked (acceptable). Icon resolution is best-effort (unknown `Icon.*` ids that don't map to an SF symbol render no icon rather than a wrong one).
