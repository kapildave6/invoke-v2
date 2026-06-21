# List/Grid Item Fidelity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Render the full Raycast `List.Item` accessory surface (colored text/tags, icon accessories, relative dates, tooltips, combined entries) and a thin `isLoading` progress bar on List/Grid/Detail.

**Architecture:** Renderer-only. Two new pure, AppKit/Foundation-only helper files (color + relative-date, and a sweep loading bar) plus changes to the one row builder + render dispatch in `PaletteView.swift`. `accessories` and `isLoading` already flow through as node props, so there are no TypeScript/reconciler/`@invoke/api` changes. A new example extension exercises every form for in-app verification.

**Tech Stack:** Swift / AppKit (`apps/macos`), `JSONValue` (InvokeIPC), React/TS extension (fixture).

## Global Constraints

- **Renderer-only.** No changes to `runtime/`, `packages/api`, `packages/utils`, or the reconciler. The only TS is a new *example extension* (a fixture), not a runtime change.
- **`RaycastColor.swift` stays free of project types** (imports only AppKit/Foundation) so it compiles in a standalone `swift` script for unit testing.
- **Named colors map EXACTLY:** `red→.systemRed`, `green→.systemGreen`, `blue→.systemBlue`, `yellow→.systemYellow`, `orange→.systemOrange`, `purple→.systemPurple`, `magenta→.systemPink`, `primary-text→.labelColor`, `secondary-text→.secondaryLabelColor`. Hex: `#RGB`, `#RRGGBB`, `#RRGGBBAA`. Dynamic `{light,dark}` resolved against the view's `effectiveAppearance`.
- **Accessory model = struct** (one entry = optional icon + optional text/tag, rendered together); the array renders left→right on the row's right side.
- **Dates:** the `date` accessory key → `compactRelative`. `tag:Date`/`text:Date` are deferred (a Date arrives as an ISO string and renders as that string).
- **Colored-tag look:** tinted fill `color.withAlphaComponent(0.18)` + text in `color`. Uncolored tag/text unchanged.
- **World-class UI:** the loading bar is a thin (2px) accent **sweep**, never the system barber-pole `NSProgressIndicator`.
- **Environment (CLT-only):** no Xcode → `swift test`/XCTest cannot run. Pure logic is verified with standalone `swift` scripts (cat-combine method, below). AppKit changes are verified with `swift build --package-path apps/macos` (compiles) + the fixture extension in the running app (`scripts/build-app.sh`, then relaunch). Cannot see pixels — confirm renderer behavior via the build + `/tmp/invoke-run.log` + the fixture.
- **Commit on `main`** (no feature branch); push after each task.

---

### Task 1: Pure helpers — `RaycastColor` (color + relative date)

**Files:**
- Create: `apps/macos/Sources/InvokePalette/RaycastColor.swift`
- Test: `/private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad/raycastcolor_tests.swift`

**Interfaces:**
- Produces (used by Task 4):
  - `RaycastColor.colorFromNamed(_ name: String) -> NSColor?`
  - `RaycastColor.colorFromHex(_ hex: String) -> NSColor?`
  - `RaycastColor.compactRelative(_ date: Date, now: Date = Date()) -> String`
  - `RaycastColor.parseISODate(_ s: String) -> Date?`

- [ ] **Step 1: Write the failing test** — create the test file:

```swift
// raycastcolor_tests.swift — top-level assertions; run by cat-combining with RaycastColor.swift.
func approx(_ a: CGFloat, _ b: CGFloat) -> Bool { abs(a - b) < 0.01 }
var failures = 0
func check(_ cond: Bool, _ msg: String) { if cond { print("ok: \(msg)") } else { failures += 1; print("FAIL: \(msg)") } }

// hex
if let c = RaycastColor.colorFromHex("#FF0000")?.usingColorSpace(.sRGB) {
    check(approx(c.redComponent, 1) && approx(c.greenComponent, 0) && approx(c.blueComponent, 0), "#FF0000 → red")
} else { check(false, "#FF0000 parsed") }
if let c = RaycastColor.colorFromHex("0f0")?.usingColorSpace(.sRGB) {
    check(approx(c.greenComponent, 1) && approx(c.redComponent, 0), "#0f0 short → green")
} else { check(false, "#0f0 parsed") }
if let c = RaycastColor.colorFromHex("#80000080")?.usingColorSpace(.sRGB) {
    check(approx(c.alphaComponent, 0.502), "#RRGGBBAA alpha")
} else { check(false, "alpha parsed") }
check(RaycastColor.colorFromHex("#zzz") == nil, "bad hex → nil")
check(RaycastColor.colorFromHex("nothex") == nil, "non-hex → nil")

// named
for name in ["red","green","blue","yellow","orange","purple","magenta","primary-text","secondary-text"] {
    check(RaycastColor.colorFromNamed(name) != nil, "named \(name) maps")
}
check(RaycastColor.colorFromNamed("chartreuse") == nil, "unknown named → nil")

// relative date
let now = Date(timeIntervalSince1970: 1_700_000_000)
func rel(_ d: TimeInterval) -> String { RaycastColor.compactRelative(now.addingTimeInterval(d), now: now) }
check(rel(-2) == "now", "2s ago → now")
check(rel(-90) == "1m", "90s ago → 1m")
check(rel(-3 * 3600) == "3h", "3h ago")
check(rel(-2 * 86_400) == "2d", "2d ago")
check(rel(-3 * 604_800) == "3w", "3w ago")
check(rel(-2 * 2_592_000) == "2mo", "2mo ago")
check(rel(-2 * 31_536_000) == "2y", "2y ago")
check(rel(3 * 86_400) == "in 3d", "in 3d (future)")

// ISO parse
check(RaycastColor.parseISODate("2026-06-21T14:30:00.000Z") != nil, "iso fractional parses")
check(RaycastColor.parseISODate("2026-06-21T14:30:00Z") != nil, "iso plain parses")
check(RaycastColor.parseISODate("not-a-date") == nil, "bad iso → nil")

print(failures == 0 ? "ALL PASS" : "\(failures) FAILED")
exit(Int32(failures == 0 ? 0 : 1))
```

- [ ] **Step 2: Run it to verify it fails**

Run:
```bash
S=/private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad
cat apps/macos/Sources/InvokePalette/RaycastColor.swift "$S/raycastcolor_tests.swift" > "$S/rc_combined.swift" 2>/dev/null; swift "$S/rc_combined.swift"
```
Expected: FAIL — `RaycastColor.swift` does not exist yet (cat error / "cannot find 'RaycastColor' in scope").

- [ ] **Step 3: Write the implementation** — create `RaycastColor.swift`:

```swift
import AppKit

/// Pure mappings for the accessory renderer. Imports ONLY AppKit/Foundation (no project types) so it
/// compiles in a standalone `swift` script for unit testing. The JSONValue dispatch (named/hex/dynamic
/// {light,dark}) lives in PaletteView and calls these.
enum RaycastColor {
    /// Raycast's named Color set (packages/api `Color`) → an adaptive NSColor. nil if unknown.
    static func colorFromNamed(_ name: String) -> NSColor? {
        switch name {
        case "red": return .systemRed
        case "green": return .systemGreen
        case "blue": return .systemBlue
        case "yellow": return .systemYellow
        case "orange": return .systemOrange
        case "purple": return .systemPurple
        case "magenta": return .systemPink
        case "primary-text": return .labelColor
        case "secondary-text": return .secondaryLabelColor
        default: return nil
        }
    }

    /// #RGB / #RRGGBB / #RRGGBBAA (case-insensitive, leading # optional). nil if malformed.
    static func colorFromHex(_ hex: String) -> NSColor? {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard !s.isEmpty, s.allSatisfy({ $0.isHexDigit }) else { return nil }
        if s.count == 3 { s = s.map { "\($0)\($0)" }.joined() } // #RGB → #RRGGBB
        guard s.count == 6 || s.count == 8, let v = UInt64(s, radix: 16) else { return nil }
        let r, g, b, a: CGFloat
        if s.count == 8 {
            r = CGFloat((v >> 24) & 0xFF) / 255; g = CGFloat((v >> 16) & 0xFF) / 255
            b = CGFloat((v >> 8) & 0xFF) / 255;  a = CGFloat(v & 0xFF) / 255
        } else {
            r = CGFloat((v >> 16) & 0xFF) / 255; g = CGFloat((v >> 8) & 0xFF) / 255
            b = CGFloat(v & 0xFF) / 255;         a = 1
        }
        return NSColor(srgbRed: r, green: g, blue: b, alpha: a)
    }

    /// Compact relative date matching Raycast's accessory style: "now", "<n>m/h/d/w/mo/y";
    /// future is prefixed "in ". Past has no suffix.
    static func compactRelative(_ date: Date, now: Date = Date()) -> String {
        let secs = date.timeIntervalSince(now)
        let past = secs <= 0
        let a = abs(secs)
        let n: Int; let unit: String
        switch a {
        case ..<45:          n = max(Int(a), 0);     unit = "s"
        case ..<3600:        n = Int(a / 60);        unit = "m"
        case ..<86_400:      n = Int(a / 3600);      unit = "h"
        case ..<604_800:     n = Int(a / 86_400);    unit = "d"
        case ..<2_592_000:   n = Int(a / 604_800);   unit = "w"
        case ..<31_536_000:  n = Int(a / 2_592_000); unit = "mo"
        default:             n = Int(a / 31_536_000); unit = "y"
        }
        if unit == "s" && n < 5 { return "now" }
        let body = "\(n)\(unit)"
        return past ? body : "in \(body)"
    }

    private static let isoFrac: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]; return f
    }()
    private static let isoPlain: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime]; return f
    }()
    /// Parse a JS Date's wire form (ISO-8601, usually with fractional seconds + Z). nil if unparseable.
    static func parseISODate(_ s: String) -> Date? { isoFrac.date(from: s) ?? isoPlain.date(from: s) }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run:
```bash
S=/private/tmp/claude-501/-Users-test-Documents-code-invoke-v2/c5f783e4-4fa9-4281-83cf-7d811b37c691/scratchpad
cat apps/macos/Sources/InvokePalette/RaycastColor.swift "$S/raycastcolor_tests.swift" > "$S/rc_combined.swift"; swift "$S/rc_combined.swift"
```
Expected: every line `ok: …` then `ALL PASS` (exit 0).

- [ ] **Step 5: Verify the module still builds** (the new file is part of InvokePalette)

Run: `swift build --package-path apps/macos 2>&1 | tail -3`
Expected: `Build complete!` (ignore pre-existing Sendable warnings).

- [ ] **Step 6: Commit**

```bash
git add apps/macos/Sources/InvokePalette/RaycastColor.swift
git commit -m "RaycastColor: pure Color→NSColor + compact relative-date helpers (accessory parity)"
git push origin main
```

---

### Task 2: Fixture extension — `examples/accessory-demo`

**Files:**
- Create: `examples/accessory-demo/package.json`
- Create: `examples/accessory-demo/src/index.tsx`

**Interfaces:**
- Produces: a launchable "Accessory Demo" List command used to visually verify Tasks 3 & 4.

- [ ] **Step 1: Mirror an existing example's manifest shape** — read `examples/calculator/package.json` and create `examples/accessory-demo/package.json` with the same fields (name/title/description/icon handling/`@raycast/api` dep), one `view` command named `index` titled "Accessory Demo":

```json
{
  "name": "accessory-demo",
  "title": "Accessory Demo",
  "description": "Exercises List.Item accessory forms + isLoading (Invoke parity fixture)",
  "commands": [{ "name": "index", "title": "Accessory Demo", "mode": "view" }],
  "dependencies": { "@raycast/api": "*" }
}
```
(If `examples/calculator/package.json` includes an `icon`/`author`/`license` field that the importer requires, add the same fields here.)

- [ ] **Step 2: Write the command** — create `examples/accessory-demo/src/index.tsx`:

```tsx
import { List, Color, Icon } from "@raycast/api";
import { useState, useEffect } from "react";

export default function Command() {
  const [isLoading, setIsLoading] = useState(true);
  useEffect(() => {
    const t = setTimeout(() => setIsLoading(false), 4000); // bar shows ~4s, then clears
    return () => clearTimeout(t);
  }, []);
  const now = Date.now();
  return (
    <List isLoading={isLoading}>
      <List.Item title="Colored tag" accessories={[{ tag: { value: "Error", color: Color.Red } }]} />
      <List.Item title="Plain tag" accessories={[{ tag: "v2.1.0" }]} />
      <List.Item title="Numeric tag" accessories={[{ tag: 42 }]} />
      <List.Item title="Colored text" accessories={[{ text: { value: "Pro", color: Color.Green } }]} />
      <List.Item title="Icon only" accessories={[{ icon: Icon.Star }]} />
      <List.Item title="Icon + text combined" accessories={[{ icon: Icon.Person, text: "42" }]} />
      <List.Item title="Tinted icon" accessories={[{ icon: { source: Icon.Circle, tintColor: Color.Orange } }]} />
      <List.Item title="Relative date" accessories={[{ date: new Date(now - 3 * 86_400_000) }]} />
      <List.Item title="Colored date" accessories={[{ date: { value: new Date(now + 2 * 3_600_000), color: Color.Blue } }]} />
      <List.Item title="Tooltip + hex + multi" accessories={[{ icon: Icon.Dot, tooltip: "status: ok" }, { tag: { value: "Live", color: "#22C55E" } }]} />
    </List>
  );
}
```

- [ ] **Step 3: Verify it loads** — build + relaunch, then confirm the command appears and lists rows (rich accessories may not render yet — that's Task 4):

```bash
bash scripts/build-app.sh 2>&1 | tail -3
kill "$(pgrep -f 'MacOS/invoke')" 2>/dev/null; sleep 1
nohup apps/macos/.build/Invoke.app/Contents/MacOS/invoke > /tmp/invoke-run.log 2>&1 &
sleep 3; grep -aiE "accessory-demo|error" /tmp/invoke-run.log | tail -10
```
Expected: no load error for `accessory-demo`. (Manual: summon Invoke, run "Accessory Demo", see 10 rows.)

- [ ] **Step 4: Commit**

```bash
git add examples/accessory-demo
git commit -m "examples/accessory-demo: fixture exercising List accessory forms + isLoading"
git push origin main
```

---

### Task 3: `LoadingBar` view + `isLoading` wiring

**Files:**
- Create: `apps/macos/Sources/InvokePalette/LoadingBar.swift`
- Modify: `apps/macos/Sources/InvokePalette/PaletteView.swift` (add the bar to the content view; read `isLoading` in `render(_:)`)

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: `LoadingBar` (`final class LoadingBar: NSView` with `start()` / `stop()`).

- [ ] **Step 1: Write `LoadingBar.swift`**

```swift
import AppKit

/// A 2px indeterminate loading bar: a faint track with an accent highlight that sweeps left→right on
/// repeat — Raycast's thin loading affordance, NOT the system barber-pole NSProgressIndicator.
final class LoadingBar: NSView {
    private let highlight = CAGradientLayer()
    private var animating = false

    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        layer?.backgroundColor = NSColor.white.withAlphaComponent(0.06).cgColor
        let accent = NSColor.controlAccentColor
        highlight.colors = [accent.withAlphaComponent(0).cgColor,
                            accent.withAlphaComponent(0.9).cgColor,
                            accent.withAlphaComponent(0).cgColor]
        highlight.startPoint = CGPoint(x: 0, y: 0.5)
        highlight.endPoint = CGPoint(x: 1, y: 0.5)
        layer?.addSublayer(highlight)
        isHidden = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    override func layout() {
        super.layout()
        highlight.frame = CGRect(x: 0, y: 0, width: max(bounds.width / 3, 1), height: bounds.height)
    }

    func start() {
        guard !animating, bounds.width > 0 else { isHidden = false; animating = true; return }
        animating = true
        isHidden = false
        let w = bounds.width
        let anim = CABasicAnimation(keyPath: "position.x")
        anim.fromValue = -w / 3
        anim.toValue = w + w / 3
        anim.duration = 1.1
        anim.repeatCount = .infinity
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        highlight.add(anim, forKey: "sweep")
    }
    func stop() {
        guard animating else { return }
        animating = false
        highlight.removeAnimation(forKey: "sweep")
        isHidden = true
    }
}
```

- [ ] **Step 2: Add the bar to the content view** — in `PaletteView.swift`, add a stored property near the other surface views (e.g. by `stack`/`scrollView`):

```swift
    private let loadingBar = LoadingBar()
```

Then, in the view-setup method where `scrollView`/`listScroll`/`gridScroll` are added as subviews and constrained, add the bar pinned to the top edge, full width, height 2, in front of the results:

```swift
        addSubview(loadingBar)
        loadingBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingBar.topAnchor.constraint(equalTo: topAnchor),
            loadingBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingBar.heightAnchor.constraint(equalToConstant: 2),
        ])
```
(The bar overlays the top of the results area — under the window's search field — with zero layout-height impact, so it never shifts rows or the fixed palette height. If `PaletteView` wraps its content in an inner container view rather than adding `scrollView` directly to `self`, pin to that container's top/leading/trailing instead.)

- [ ] **Step 3: Toggle the bar in `render(_:)`** — in `PaletteView.swift`, after the `InvokeCatchException({ … })` surface-dispatch block (ends ~`:320`), before `render` returns, add:

```swift
        // Raycast's isLoading: thin sweep bar while any active surface is loading.
        if surfaces.contains(where: { Self.isTrue($0.props["isLoading"]) }) { loadingBar.start() } else { loadingBar.stop() }
```
(`surfaces` is `tree.root.children`, already bound at `:282`. `Self.isTrue` is the existing bool-coercion helper used at `:308`.)

- [ ] **Step 4: Build**

Run: `swift build --package-path apps/macos 2>&1 | tail -3`
Expected: `Build complete!`

- [ ] **Step 5: Verify in-app** — full app build + relaunch, run the fixture:

```bash
bash scripts/build-app.sh 2>&1 | tail -3
kill "$(pgrep -f 'MacOS/invoke')" 2>/dev/null; sleep 1
nohup apps/macos/.build/Invoke.app/Contents/MacOS/invoke > /tmp/invoke-run.log 2>&1 &
sleep 3; tail -5 /tmp/invoke-run.log
```
Expected: clean startup. (Manual: run "Accessory Demo" — a thin accent bar sweeps at the top for ~4s, then disappears; no barber-pole, no row shift.)

- [ ] **Step 6: Commit**

```bash
git add apps/macos/Sources/InvokePalette/LoadingBar.swift apps/macos/Sources/InvokePalette/PaletteView.swift
git commit -m "List/Grid/Detail isLoading: thin accent sweep bar (Raycast parity)"
git push origin main
```

---

### Task 4: Accessory struct + parser + renderer

**Files:**
- Modify: `apps/macos/Sources/InvokePalette/PaletteView.swift` (replace `Accessory` enum at `:1966`; rewrite `accessories(_:)` at `:1968`; add `accessoryColor`, `labelAndColor`, `accessoryIcon`, `nonNull`; extend `chip` at `:1945`; replace the accessory render loop at `:1773-1783`)

**Interfaces:**
- Consumes (from Task 1): `RaycastColor.colorFromNamed`, `RaycastColor.colorFromHex`, `RaycastColor.compactRelative`, `RaycastColor.parseISODate`.

- [ ] **Step 1: Replace the `Accessory` type** — change `private enum Accessory { case text(String); case tag(String) }` (`:1966`) to:

```swift
    private struct Accessory {
        var iconValue: JSONValue?   // an Image.ImageLike to render at 15pt
        var iconTint: NSColor?      // tintColor for an SF-symbol icon
        var label: String?          // resolved text/tag/date string
        var isTag: Bool = false     // true → chip; false → plain right-aligned label
        var color: NSColor?         // text color (label) / tint (tag)
        var tooltip: String?        // applied as the accessory view's toolTip
    }
```

- [ ] **Step 2: Rewrite `accessories(_:)`** — replace the body (`:1968-1977`) with the full parser plus its helpers:

```swift
    /// Drop nil / JSON null.
    private func nonNull(_ v: JSONValue?) -> JSONValue? {
        guard let v = v else { return nil }
        if case .null = v { return nil }
        return v
    }

    /// Map a Color.ColorLike JSONValue (named | hex | { light, dark }) to an NSColor.
    private func accessoryColor(_ v: JSONValue?) -> NSColor? {
        guard let v = nonNull(v) else { return nil }
        switch v {
        case .string(let s):
            return s.hasPrefix("#") ? RaycastColor.colorFromHex(s)
                                    : (RaycastColor.colorFromNamed(s) ?? RaycastColor.colorFromHex(s))
        case .object(let o): // { light, dark }
            let dark = effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            return accessoryColor(o[dark ? "dark" : "light"]) ?? accessoryColor(o["light"]) ?? accessoryColor(o["dark"])
        default:
            return nil
        }
    }

    /// Resolve a text/tag/date value (String | number | { value, color }) to a display string + color.
    private func labelAndColor(_ v: JSONValue, isDate: Bool) -> (String?, NSColor?) {
        if case .object(let o) = v, let inner = nonNull(o["value"]) {
            return (labelAndColor(inner, isDate: isDate).0, accessoryColor(o["color"]))
        }
        switch v {
        case .string(let s):
            if isDate { return (RaycastColor.parseISODate(s).map { RaycastColor.compactRelative($0) } ?? s, nil) }
            return (s, nil)
        case .number(let n):
            return (n == n.rounded() ? String(Int(n)) : String(n), nil)
        default:
            return (nil, nil)
        }
    }

    private func accessories(_ node: ViewNode) -> [Accessory] {
        guard let acc = node.props["accessories"], case .array(let arr) = acc else { return [] }
        var out: [Accessory] = []
        for item in arr {
            guard case .object(let o) = item else { continue }
            var a = Accessory()
            a.tooltip = o["tooltip"]?.stringValue
            // icon: ImageLike | { value, tooltip }
            if let icon = nonNull(o["icon"]) {
                if case .object(let io) = icon, let v = nonNull(io["value"]) {
                    a.iconValue = v
                    if a.tooltip == nil { a.tooltip = io["tooltip"]?.stringValue }
                } else {
                    a.iconValue = icon
                }
                if case .object(let io)? = a.iconValue { a.iconTint = accessoryColor(io["tintColor"]) }
            }
            // label: tag | date | text, each String | number | { value, color }
            if let tag = nonNull(o["tag"]) {
                let (s, c) = labelAndColor(tag, isDate: false); a.label = s; a.color = c; a.isTag = true
            } else if let date = nonNull(o["date"]) {
                let (s, c) = labelAndColor(date, isDate: true); a.label = s; a.color = c
            } else if let text = nonNull(o["text"]) {
                let (s, c) = labelAndColor(text, isDate: false); a.label = s; a.color = c
            }
            if a.iconValue != nil || a.label != nil { out.append(a) }
        }
        return out
    }

    /// Accessory icon (15pt) — same ImageLike resolution as `iconView`, minus the node-specific
    /// app/file/manifest branches.
    private func accessoryIcon(_ value: JSONValue, tint: NSColor?) -> NSView? {
        let size: CGFloat = 15
        if let src = imageSource(value), loadLocalImage(src) != nil || src.hasPrefix("http://") || src.hasPrefix("https://") {
            let iv = NSImageView(); iv.imageScaling = .scaleProportionallyUpOrDown
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.widthAnchor.constraint(equalToConstant: size).isActive = true
            iv.heightAnchor.constraint(equalToConstant: size).isActive = true
            if let img = loadLocalImage(src) { iv.image = img } else { loadRemoteImage(src, into: iv) }
            return iv
        }
        let name = value.stringValue ?? imageSource(value) ?? ""
        guard !name.isEmpty,
              let img = NSImage(systemSymbolName: name, accessibilityDescription: nil)
                ?? NSImage(systemSymbolName: sfSymbol(for: name), accessibilityDescription: nil) else { return nil }
        let iv = NSImageView(image: img)
        iv.contentTintColor = tint ?? .secondaryLabelColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.widthAnchor.constraint(equalToConstant: size).isActive = true
        iv.heightAnchor.constraint(equalToConstant: size).isActive = true
        return iv
    }
```

- [ ] **Step 3: Add a color to `chip`** — change the signature of `chip(_:)` (`:1945`) to `chip(_ text: String, color: NSColor? = nil)` and replace its `label.textColor` line and `bg.layer?.backgroundColor` line with:

```swift
        label.textColor = color ?? .secondaryLabelColor
```
```swift
        bg.layer?.backgroundColor = (color?.withAlphaComponent(0.18) ?? NSColor.white.withAlphaComponent(0.09)).cgColor
```
(Leave the rest of `chip` unchanged.)

- [ ] **Step 4: Replace the accessory render loop** — in `itemRowContent`, replace the loop (`:1772-1783`, the comment + `for acc in accessories(node) { switch acc { … } }`) with:

```swift
        // Accessories: each entry = optional icon + optional text/tag (+ tooltip), rendered together.
        for acc in accessories(node) {
            let sub = NSStackView()
            sub.orientation = .horizontal; sub.alignment = .centerY; sub.spacing = 4
            sub.translatesAutoresizingMaskIntoConstraints = false
            if let iv = acc.iconValue, let icon = accessoryIcon(iv, tint: acc.iconTint) { sub.addArrangedSubview(icon) }
            if let label = acc.label {
                if acc.isTag {
                    sub.addArrangedSubview(chip(label, color: acc.color))
                } else {
                    let l = NSTextField(labelWithString: label)
                    l.font = .systemFont(ofSize: 13)
                    l.textColor = acc.color ?? .tertiaryLabelColor
                    sub.addArrangedSubview(l)
                }
            }
            if let tip = acc.tooltip { sub.toolTip = tip }
            h.addArrangedSubview(sub)
        }
```

- [ ] **Step 5: Build**

Run: `swift build --package-path apps/macos 2>&1 | tail -3`
Expected: `Build complete!` (ignore pre-existing Sendable warnings; if SourceKit shows stale "cannot find …" errors, trust the build).

- [ ] **Step 6: Verify in-app with the fixture** — full app build + relaunch, run "Accessory Demo":

```bash
bash scripts/build-app.sh 2>&1 | tail -3
kill "$(pgrep -f 'MacOS/invoke')" 2>/dev/null; sleep 1
nohup apps/macos/.build/Invoke.app/Contents/MacOS/invoke > /tmp/invoke-run.log 2>&1 &
sleep 3; tail -5 /tmp/invoke-run.log
```
Expected: clean startup. Manual checks in "Accessory Demo":
  - "Colored tag" → red-tinted "Error" chip; "Plain tag" → subtle "v2.1.0"; "Numeric tag" → "42".
  - "Colored text" → green "Pro" (no chip).
  - "Icon only" → a star; "Icon + text combined" → person icon then "42"; "Tinted icon" → orange circle.
  - "Relative date" → "3d"; "Colored date" → blue "in 2h".
  - "Tooltip + hex + multi" → a dot (hover shows "status: ok") then a green ("#22C55E") "Live" chip.
  - Existing extensions' lists still render their old text/tag accessories unchanged.

- [ ] **Step 7: Commit**

```bash
git add apps/macos/Sources/InvokePalette/PaletteView.swift
git commit -m "List accessories: full Raycast surface (colored text/tags, icon, date, tooltip, combined)"
git push origin main
```

---

## Notes for the implementer

- The shared row builder `itemRowContent` (`:1728`) feeds both the stack fallback (`addItemRow`) and the virtualized table cell (`makeItemCell`), so the Task-4 loop change covers plain and virtualized lists in one place. The master–detail (`renderSplitVirtualized`) left rows may build differently; rich accessories there are a follow-up, not part of this chunk.
- `imageSource`, `loadLocalImage`, `loadRemoteImage`, `sfSymbol` already exist in `PaletteView.swift` (see `iconView`, `:1979-2024`) — reuse them; do not reimplement icon loading.
- Do not touch `runtime/node-host/src/viewmodel.ts`'s `renderTree` (the ASCII debug view) — it is unrelated to native rendering.
