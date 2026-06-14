import AppKit
import InvokeIPC
import InvokeRenderer
import InvokeObjC // InvokeCatchException — guard the render path from Obj-C exceptions (no app crash)

/// Flipped so an NSScrollView lays its document out top-down (AppKit default is bottom-up).
private final class FlippedDocView: NSView {
    override var isFlipped: Bool { true }
}

/// A result row that reports clicks (single = select, double = activate) by item index. Overrides
/// `mouseDownCanMoveWindow` to false so the click lands on the row instead of starting a window drag
/// (the window is movable-by-background, so empty chrome still drags, but rows stay clickable).
private final class ClickableRow: NSView {
    var onClick: ((_ clickCount: Int) -> Void)?
    override var mouseDownCanMoveWindow: Bool { false }
    override func mouseDown(with event: NSEvent) { onClick?(event.clickCount) }
}

/// The results list (PLAN.md §4.3/§6). Renders the view-model tree into:
///   • section headers,
///   • a rich result **card** (a `list-item` with `display: "card"` — used by the Calculator's
///     conversion result: big left value → arrow → big right value, with name chips), and
///   • polished, selectable item rows (icon · title · subtitle · accessory chips).
/// A virtualized custom list + the full theme-token system are the next visual pass; this
/// establishes the reusable row/card patterns every feature renders through.
public final class PaletteView: NSView {
    private let stack = NSStackView()
    private let scrollView = NSScrollView()
    private var itemCounter = 0
    private var selectedRowView: NSView?

    /// Single-click a row → select that item index. Double-click → activate it.
    public var onSelect: ((Int) -> Void)?
    public var onActivate: ((Int) -> Void)?
    /// Return pressed inside a Form field → submit the form (run the primary action).
    public var onSubmit: (() -> Void)?
    @objc private func formFieldEnter() { onSubmit?() }

    private func wireClick(_ row: ClickableRow, index: Int) {
        row.onClick = { [weak self] count in
            if count >= 2 { self?.onActivate?(index) } else { self?.onSelect?(index) }
        }
    }

    /// Max content height before the list scrolls (window caps near this + chrome).
    private let maxContentHeight: CGFloat = 460

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 3
        stack.translatesAutoresizingMaskIntoConstraints = false

        let doc = FlippedDocView()
        doc.translatesAutoresizingMaskIntoConstraints = false
        doc.addSubview(stack)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.scrollerStyle = .overlay
        scrollView.documentView = doc
        addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            doc.topAnchor.constraint(equalTo: scrollView.contentView.topAnchor),
            doc.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor),
            doc.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor),
            doc.widthAnchor.constraint(equalTo: scrollView.contentView.widthAnchor),

            stack.topAnchor.constraint(equalTo: doc.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: doc.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: doc.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: doc.bottomAnchor, constant: -8),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("not used") }

    /// Set false only for the few compact root states (no query → just the search field + a couple of
    /// suggestion rows) where Raycast itself stays compact. Every browsing/extension surface keeps the
    /// CONSTANT full height (see fittingHeight) so the window never resizes between states.
    private var fixedHeightSurface = false
    /// When true, the palette uses the full constant height regardless of content (set for extension
    /// views, lists, grids, detail, forms, loading, and pushed views — i.e. essentially always).
    public var forceConstantHeight = true

    /// Height the rendered content wants. The palette keeps a CONSTANT height across every surface and
    /// state (root, extension List/Grid/Detail/Form, pushed views, loading, "No Results") — Raycast
    /// parity: the window never resizes between states. Content beyond this scrolls.
    public func fittingHeight() -> CGFloat {
        layoutSubtreeIfNeeded()
        if forceConstantHeight || fixedHeightSurface { return maxContentHeight }
        return min(stack.fittingSize.height + 16, maxContentHeight)
    }

    /// Re-render rows from the current view-model tree, highlighting the item at `selectedIndex`
    /// (item indices are assigned in pre-order, matching the host's selection model). Returns true if it
    /// did a full rebuild (so the window should resize); false on the selection-only fast path.
    @discardableResult
    public func render(_ tree: ViewTree, selectedIndex: Int) -> Bool {
        // Fast path: same grid tree, only the selection changed → just move the highlight (no rebuild,
        // no layout churn), keeping arrow navigation snappy on large screenshot grids.
        if lastSurfaceWasGrid, tree === lastRenderedTree, !gridCells.isEmpty {
            for (i, c) in gridCells.enumerated() { applyGridSelection(c, selected: i == selectedIndex) }
            selectedRowView = gridCells.indices.contains(selectedIndex) ? gridCells[selectedIndex] : nil
            scrollSelectedIntoView()
            return false
        }
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        gridCells.removeAll()
        itemCounter = 0
        selectedRowView = nil
        let surfaces = tree.root.children
        lastRenderedTree = tree
        lastSurfaceWasGrid = surfaces.contains { $0.type == "grid" }
        // Dispatch on the top-level surface the extension rendered (PLAN.md §5 component set). The whole
        // dispatch runs inside an Obj-C exception guard: a malformed view tree or an AppKit exception
        // (bad constraint, unknown selector, …) must NOT abort Invoke — it degrades to an error surface.
        if let reason = InvokeCatchException({
            if let detail = surfaces.first(where: { $0.type == "detail" }) {
                self.fixedHeightSurface = false
                self.renderDetailSurface(detail)
            } else if let form = surfaces.first(where: { $0.type == "form" }) {
                self.fixedHeightSurface = false
                self.renderFormSurface(form)
            } else if let grid = surfaces.first(where: { $0.type == "grid" }) {
                self.fixedHeightSurface = true
                self.renderGrid(grid, selectedIndex: selectedIndex)
                self.scrollSelectedIntoView()
            } else if let list = surfaces.first(where: { $0.type == "list" }),
                      Self.isTrue(list.props["showDetail"]) || Self.isTrue(list.props["isShowingDetail"]) {
                self.fixedHeightSurface = true
                self.renderSplit(list: list, selectedIndex: selectedIndex) // master–detail (Clipboard, List.Item.Detail)
            } else {
                // Root list + extension Lists: a constant height (don't shrink for "No Results").
                self.fixedHeightSurface = surfaces.contains { $0.type == "list" } || tree.root.children.contains { $0.type == "list" }
                self.appendRows(for: tree.root, selectedIndex: selectedIndex)
                self.scrollSelectedIntoView()
            }
        }) {
            renderErrorSurface(reason)
        }
        return true
    }

    /// Fallback surface shown when rendering the extension's view threw — keeps Invoke alive and tells
    /// the user (and us) what happened instead of crashing the whole app.
    private func renderErrorSurface(_ reason: String) {
        NSLog("[invoke] render failed, showing error surface: %@", reason)
        // The partial render may have left views/state behind; reset to a clean single-message surface.
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        gridCells.removeAll()
        itemCounter = 0
        selectedRowView = nil
        let md = "## ⚠️ This view couldn’t be displayed\n\nThe extension’s screen failed to render, so Invoke stopped it instead of crashing.\n\n```\n\(reason)\n```"
        // markdownScroll is itself guarded below, but a plain label is the safest last resort.
        if let guarded = InvokeCatchException({ self.stack.addArrangedSubview(self.markdownScroll(md)) }) {
            NSLog("[invoke] error surface also failed: %@", guarded)
            let lbl = NSTextField(labelWithString: "This view couldn’t be displayed.")
            lbl.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview(lbl)
        }
    }

    private func scrollSelectedIntoView() {
        guard let row = selectedRowView else { return }
        DispatchQueue.main.async { [weak self, weak row] in
            self?.layoutSubtreeIfNeeded()
            if let row { row.scrollToVisible(row.bounds) }
        }
    }

    /// Scroll the content to the bottom — used by AI Chat so the streaming answer stays in view.
    public func scrollContentToBottom() {
        DispatchQueue.main.async { [weak self] in
            guard let self, let doc = self.scrollView.documentView else { return }
            self.layoutSubtreeIfNeeded()
            let maxY = max(0, doc.bounds.height - self.scrollView.contentView.bounds.height)
            self.scrollView.contentView.scroll(to: NSPoint(x: 0, y: maxY))
            self.scrollView.reflectScrolledClipView(self.scrollView.contentView)
        }
    }

    // MARK: - Master–detail (list + detail pane)

    private func renderSplit(list: ViewNode, selectedIndex: Int) {
        var rows: [ViewNode] = []
        func collect(_ n: ViewNode) { if n.type == "list-item" { rows.append(n) }; n.children.forEach(collect) }
        collect(list)
        let sel = rows.isEmpty ? -1 : max(0, min(selectedIndex, rows.count - 1))

        // Left: scrollable compact list.
        let leftStack = NSStackView()
        leftStack.orientation = .vertical
        leftStack.alignment = .leading
        leftStack.spacing = 2
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        if let section = list.children.first(where: { $0.type == "list-section" }), let t = section.title, !t.isEmpty {
            leftStack.addArrangedSubview(sectionLabel(t, width: 300))
        }
        var selectedRow: NSView?
        for (i, node) in rows.enumerated() {
            let r = compactRow(node, selected: i == sel, width: 300, index: i)
            if i == sel { selectedRow = r }
            leftStack.addArrangedSubview(r)
        }
        let doc = FlippedDocView()
        doc.translatesAutoresizingMaskIntoConstraints = false
        doc.addSubview(leftStack)
        let leftScroll = NSScrollView()
        leftScroll.translatesAutoresizingMaskIntoConstraints = false
        leftScroll.drawsBackground = false
        leftScroll.hasVerticalScroller = true
        leftScroll.scrollerStyle = .overlay
        leftScroll.documentView = doc

        let divider = NSBox()
        divider.boxType = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false

        let detail = detailPane(sel >= 0 ? rows[sel] : nil)
        detail.setContentHuggingPriority(.init(1), for: .horizontal) // fill the remaining width

        let h = NSStackView()
        h.orientation = .horizontal
        h.alignment = .top
        h.distribution = .fill
        h.spacing = 0
        h.translatesAutoresizingMaskIntoConstraints = false
        h.addArrangedSubview(leftScroll)
        h.addArrangedSubview(divider)
        h.addArrangedSubview(detail)

        stack.addArrangedSubview(h)
        NSLayoutConstraint.activate([
            h.widthAnchor.constraint(equalTo: stack.widthAnchor),
            h.heightAnchor.constraint(equalToConstant: 360),
            divider.widthAnchor.constraint(equalToConstant: 1),
            leftScroll.widthAnchor.constraint(equalToConstant: 300),
            detail.widthAnchor.constraint(greaterThanOrEqualToConstant: 280), // don't let it collapse
            leftStack.topAnchor.constraint(equalTo: doc.topAnchor, constant: 2),
            leftStack.leadingAnchor.constraint(equalTo: doc.leadingAnchor),
            leftStack.trailingAnchor.constraint(equalTo: doc.trailingAnchor),
            leftStack.bottomAnchor.constraint(equalTo: doc.bottomAnchor),
            doc.widthAnchor.constraint(equalToConstant: 300),
        ])

        // Keep the selected clip visible as you arrow through a long list.
        if let selectedRow {
            DispatchQueue.main.async { [weak self, weak selectedRow] in
                self?.layoutSubtreeIfNeeded()
                if let selectedRow { selectedRow.scrollToVisible(selectedRow.bounds) }
            }
        }
    }

    private func sectionLabel(_ text: String, width: CGFloat) -> NSView {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        let v = NSView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(label)
        NSLayoutConstraint.activate([
            v.widthAnchor.constraint(equalToConstant: width),
            label.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 8),
            label.topAnchor.constraint(equalTo: v.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -6),
        ])
        return v
    }

    private func compactRow(_ node: ViewNode, selected: Bool, width: CGFloat, index: Int) -> NSView {
        let row = ClickableRow()
        wireClick(row, index: index)
        row.translatesAutoresizingMaskIntoConstraints = false
        row.wantsLayer = true
        row.layer?.cornerRadius = 6
        // Accent tint reads in both Light and Dark (the old white-alpha was invisible in Light mode).
        row.layer?.backgroundColor = selected ? NSColor.controlAccentColor.withAlphaComponent(0.20).cgColor : NSColor.clear.cgColor
        let h = NSStackView()
        h.orientation = .horizontal
        h.alignment = .centerY
        h.spacing = 8
        h.translatesAutoresizingMaskIntoConstraints = false
        if let icon = iconView(for: node, selected: selected) { h.addArrangedSubview(icon) }
        let title = NSTextField(labelWithString: node.title ?? "")
        title.font = .systemFont(ofSize: 13)
        title.textColor = .labelColor
        title.lineBreakMode = .byTruncatingTail
        h.addArrangedSubview(title)
        row.addSubview(h)
        NSLayoutConstraint.activate([
            row.widthAnchor.constraint(equalToConstant: width),
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 32),
            h.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 8),
            h.trailingAnchor.constraint(lessThanOrEqualTo: row.trailingAnchor, constant: -8),
            h.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        return row
    }

    static func isTrue(_ v: JSONValue?) -> Bool { if case .bool(true)? = v { return true }; return false }

    /// Render an extension's `list-item-detail` (markdown + a `metadata` child) into the split's right pane.
    private func extensionDetailPane(_ node: ViewNode) -> NSView {
        let pane = NSView()
        pane.translatesAutoresizingMaskIntoConstraints = false
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .width
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        if let md = node.props["markdown"]?.stringValue, !md.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let scroll = markdownScroll(md)
            stack.addArrangedSubview(scroll)
            scroll.heightAnchor.constraint(equalToConstant: 160).isActive = true
            scroll.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        }
        if let meta = node.children.first(where: { $0.type == "metadata" }) {
            for child in meta.children {
                switch child.type {
                case "metadata-label", "metadata-link":
                    let value = child.props["text"]?.stringValue ?? child.props["target"]?.stringValue ?? "—"
                    stack.addArrangedSubview(metadataRow(label: child.props["title"]?.stringValue ?? "", value: value))
                case "metadata-taglist":
                    let tags = child.children.compactMap { $0.props["text"]?.stringValue ?? $0.title }.joined(separator: ", ")
                    stack.addArrangedSubview(metadataRow(label: child.props["title"]?.stringValue ?? "", value: tags))
                case "metadata-separator":
                    let sep = NSBox(); sep.boxType = .separator; sep.translatesAutoresizingMaskIntoConstraints = false
                    stack.addArrangedSubview(sep)
                    sep.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
                default: break
                }
            }
        }
        pane.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: pane.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: pane.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: pane.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: pane.bottomAnchor, constant: -12),
        ])
        return pane
    }

    /// Right pane of the master–detail split. An extension's `List.Item.Detail` (markdown + a `metadata`
    /// child of label/separator/link/taglist nodes) renders like a Detail; otherwise the built-in
    /// clipboard/snippet format (thumb / detailText / metadata prop-array).
    private func detailPane(_ node: ViewNode?) -> NSView {
        let pane = NSView()
        pane.translatesAutoresizingMaskIntoConstraints = false
        guard let node else { return pane }

        // Extension List.Item.Detail child → render its markdown + metadata children.
        if let lid = node.children.first(where: { $0.type == "list-item-detail" }) {
            return extensionDetailPane(lid)
        }

        let contentView: NSView
        if let b64 = node.props["thumb"]?.stringValue,
           let data = Data(base64Encoded: b64), let img = NSImage(data: data) {
            let iv = NSImageView(image: img)
            iv.imageScaling = .scaleProportionallyUpOrDown
            iv.imageAlignment = .alignTopLeft
            iv.heightAnchor.constraint(lessThanOrEqualToConstant: 170).isActive = true
            iv.setContentHuggingPriority(.required, for: .vertical)
            contentView = iv
        } else {
            let label = NSTextField(wrappingLabelWithString: node.props["detailText"]?.stringValue ?? (node.title ?? ""))
            label.font = .systemFont(ofSize: 13)
            label.textColor = .labelColor
            label.isSelectable = true
            label.maximumNumberOfLines = 8 // truncate within the fixed preview height
            contentView = label
        }
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // Fixed-height preview region (Raycast parity): the content sits top-aligned in a constant-
        // height box, so the "Information" block below stays put as you arrow through clips instead
        // of sliding up/down with each item's content height.
        let preview = NSView()
        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.addSubview(contentView)
        pane.addSubview(preview)

        // Horizontal divider separating the content preview from the Information block (Raycast parity).
        let infoDivider = NSBox()
        infoDivider.boxType = .separator
        infoDivider.translatesAutoresizingMaskIntoConstraints = false
        pane.addSubview(infoDivider)

        let info = NSStackView()
        info.orientation = .vertical
        info.alignment = .width // rows fill the pane width so values right-align
        info.distribution = .fill
        info.spacing = 8
        info.translatesAutoresizingMaskIntoConstraints = false
        let header = NSTextField(labelWithString: "Information")
        header.font = .systemFont(ofSize: 11, weight: .semibold)
        header.textColor = .secondaryLabelColor
        info.addArrangedSubview(header)
        if let md = node.props["metadata"], case .array(let mdRows) = md {
            for r in mdRows {
                guard case .object(let o) = r, let label = o["label"]?.stringValue, let value = o["value"]?.stringValue else { continue }
                info.addArrangedSubview(metadataRow(label: label, value: value))
            }
        }
        pane.addSubview(info)

        let previewH: CGFloat = 180
        NSLayoutConstraint.activate([
            preview.topAnchor.constraint(equalTo: pane.topAnchor, constant: 12),
            preview.leadingAnchor.constraint(equalTo: pane.leadingAnchor, constant: 16),
            preview.trailingAnchor.constraint(equalTo: pane.trailingAnchor, constant: -16),
            preview.heightAnchor.constraint(equalToConstant: previewH),

            // Content top-aligned inside the fixed box (image scales down, text truncates).
            contentView.topAnchor.constraint(equalTo: preview.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: preview.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: preview.trailingAnchor),
            contentView.bottomAnchor.constraint(lessThanOrEqualTo: preview.bottomAnchor),

            // A divider under the fixed-height preview, then the Information block at a constant Y.
            infoDivider.topAnchor.constraint(equalTo: preview.bottomAnchor, constant: 12),
            infoDivider.leadingAnchor.constraint(equalTo: pane.leadingAnchor, constant: 16),
            infoDivider.trailingAnchor.constraint(equalTo: pane.trailingAnchor, constant: -16),
            info.topAnchor.constraint(equalTo: infoDivider.bottomAnchor, constant: 12),
            info.leadingAnchor.constraint(equalTo: pane.leadingAnchor, constant: 16),
            info.trailingAnchor.constraint(equalTo: pane.trailingAnchor, constant: -16),
            info.bottomAnchor.constraint(lessThanOrEqualTo: pane.bottomAnchor, constant: -14),
        ])
        return pane
    }

    private func metadataRow(label: String, value: String) -> NSView {
        let l = NSTextField(labelWithString: label)
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabelColor
        l.translatesAutoresizingMaskIntoConstraints = false
        let v = NSTextField(labelWithString: value)
        v.font = .systemFont(ofSize: 12)
        v.textColor = .labelColor
        v.alignment = .right
        v.lineBreakMode = .byTruncatingTail
        v.translatesAutoresizingMaskIntoConstraints = false
        let row = NSView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(l)
        row.addSubview(v)
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 18),
            l.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            l.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            v.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            v.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            v.leadingAnchor.constraint(greaterThanOrEqualTo: l.trailingAnchor, constant: 12),
        ])
        return row
    }

    // MARK: - Detail / Form / Grid surfaces (PLAN.md §5)

    /// Render markdown to an attributed string, mapping the parser's semantic intents to fonts
    /// (Foundation gives intents, not concrete fonts) — headings larger/bold, **bold**, *italic*,
    /// `code`, and links coloured.
    private static func attributedMarkdown(_ md: String, baseSize: CGFloat = 13) -> NSAttributedString {
        let opts = AttributedString.MarkdownParsingOptions(interpretedSyntax: .full, failurePolicy: .returnPartiallyParsedIfPossible)
        guard let parsed = try? AttributedString(markdown: md, options: opts) else {
            return NSAttributedString(string: md, attributes: [.font: NSFont.systemFont(ofSize: baseSize), .foregroundColor: NSColor.labelColor])
        }
        let out = NSMutableAttributedString()
        var lastBlock: PresentationIntent? = nil
        for run in parsed.runs {
            let text = String(parsed[run.range].characters)
            var size = baseSize, bold = false, italic = false, mono = false
            var separator = ""
            if let block = run.presentationIntent {
                let isList = block.components.contains { if case .listItem = $0.kind { return true }; return false }
                for comp in block.components { if case .header(let level) = comp.kind { bold = true; size = baseSize + CGFloat(max(0, 7 - level) * 2) } }
                // Foundation strips the newlines between blocks — reinsert them on each block change.
                if block != lastBlock {
                    if lastBlock != nil { separator = isList ? "\n" : "\n\n" }
                    if isList { separator += "•  " }
                    lastBlock = block
                }
            }
            if let inline = run.inlinePresentationIntent {
                if inline.contains(.stronglyEmphasized) { bold = true }
                if inline.contains(.emphasized) { italic = true }
                if inline.contains(.code) { mono = true; size = baseSize - 1 }
            }
            var font = mono ? NSFont.monospacedSystemFont(ofSize: size, weight: bold ? .semibold : .regular)
                            : NSFont.systemFont(ofSize: size, weight: bold ? .semibold : .regular)
            if italic { font = NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask) }
            if !separator.isEmpty {
                out.append(NSAttributedString(string: separator, attributes: [.font: NSFont.systemFont(ofSize: baseSize), .foregroundColor: NSColor.labelColor]))
            }
            var attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.labelColor]
            if let link = run.link { attrs[.foregroundColor] = NSColor.linkColor; attrs[.link] = link }
            out.append(NSAttributedString(string: text, attributes: attrs))
        }
        return out
    }

    /// A scrollable rendering of markdown: text blocks become wrapping attributed labels, and image
    /// syntax (`![alt](url)`) becomes an actual NSImageView (local path / file:// / data: load
    /// synchronously; http(s) loads async). Foundation's AttributedString(markdown:) drops images
    /// entirely, so we split them out and render them ourselves (Raycast's Detail shows them inline).
    private func markdownScroll(_ md: String) -> NSScrollView {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false

        for seg in Self.splitMarkdownImages(md) {
            switch seg {
            case .text(let t):
                if t.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { continue }
                let body = NSTextField(labelWithAttributedString: Self.attributedMarkdown(t))
                body.isSelectable = true
                body.lineBreakMode = .byWordWrapping
                body.maximumNumberOfLines = 0
                body.translatesAutoresizingMaskIntoConstraints = false
                body.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                stack.addArrangedSubview(body)
                body.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
            case .image(let url, let alt):
                appendDetailImage(url: url, alt: alt, to: stack)
            }
        }

        let doc = FlippedDocView()
        doc.translatesAutoresizingMaskIntoConstraints = false
        doc.addSubview(stack)
        let scroll = NSScrollView()
        scroll.drawsBackground = false
        scroll.hasVerticalScroller = true
        scroll.scrollerStyle = .overlay
        scroll.documentView = doc
        scroll.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            doc.widthAnchor.constraint(equalTo: scroll.contentView.widthAnchor),
            stack.leadingAnchor.constraint(equalTo: doc.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: doc.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: doc.topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: doc.bottomAnchor, constant: -14),
        ])
        return scroll
    }

    private enum MDSegment { case text(String); case image(url: String, alt: String) }

    /// Split markdown into ordered text / image segments. Image URLs that contain spaces aren't matched
    /// (CommonMark requires `<...>` for those); the common case — `![alt](/abs/path.png)` — is handled.
    private static func splitMarkdownImages(_ md: String) -> [MDSegment] {
        guard let re = try? NSRegularExpression(pattern: "!\\[([^\\]]*)\\]\\(([^)\\s]+)(?:\\s+\"[^\"]*\")?\\)") else {
            return [.text(md)]
        }
        let ns = md as NSString
        var segs: [MDSegment] = []
        var last = 0
        for m in re.matches(in: md, range: NSRange(location: 0, length: ns.length)) {
            if m.range.location > last {
                segs.append(.text(ns.substring(with: NSRange(location: last, length: m.range.location - last))))
            }
            let altR = m.range(at: 1)
            let alt = altR.location != NSNotFound ? ns.substring(with: altR) : ""
            segs.append(.image(url: ns.substring(with: m.range(at: 2)), alt: alt))
            last = m.range.location + m.range.length
        }
        if last < ns.length { segs.append(.text(ns.substring(from: last))) }
        return segs.isEmpty ? [.text(md)] : segs
    }

    /// Append an image (or an alt-text fallback) to the markdown stack, filling the available width up to
    /// the image's natural size, preserving aspect. The view is added to `stack` BEFORE any stack-relative
    /// constraint is activated — activating a constraint between two views with no common ancestor throws
    /// an NSException and aborts the app, so insertion must come first.
    private func appendDetailImage(url: String, alt: String, to stack: NSStackView) {
        func addFallback() {
            let lbl = NSTextField(labelWithString: alt.isEmpty ? "🖼 (image unavailable)" : "🖼 \(alt)")
            lbl.textColor = .secondaryLabelColor
            lbl.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview(lbl)
            lbl.widthAnchor.constraint(lessThanOrEqualTo: stack.widthAnchor).isActive = true
        }

        let iv = NSImageView()
        iv.imageScaling = .scaleProportionallyUpOrDown
        iv.imageAlignment = .alignTopLeft
        iv.animates = true // animate GIFs — without this only the (often blank) first frame shows
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.setContentHuggingPriority(.defaultLow, for: .horizontal)
        iv.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Precondition: `iv` is already an arranged subview of `stack` (shares it as a common ancestor).
        func apply(_ image: NSImage) {
            guard iv.superview != nil else { return } // detached before the async image arrived
            iv.image = image
            let w = max(1, image.size.width), h = max(1, image.size.height)
            let fill = iv.widthAnchor.constraint(equalTo: stack.widthAnchor)
            fill.priority = .defaultHigh // fill the width when allowed…
            NSLayoutConstraint.activate([
                iv.heightAnchor.constraint(equalTo: iv.widthAnchor, multiplier: h / w),     // keep aspect
                iv.widthAnchor.constraint(lessThanOrEqualToConstant: w),                     // …never upscale
                iv.widthAnchor.constraint(lessThanOrEqualTo: stack.widthAnchor),             // …never overflow
                iv.widthAnchor.constraint(lessThanOrEqualToConstant: 660),                   // hard backstop (palette is 750-wide)
                iv.heightAnchor.constraint(lessThanOrEqualToConstant: 340),                  // …and never taller than the viewport
                fill,
            ])
        }

        if let image = loadLocalImage(url) {
            stack.addArrangedSubview(iv) // in the hierarchy BEFORE stack-relative constraints
            apply(image)
            return
        }
        if let u = URL(string: url), u.scheme == "http" || u.scheme == "https" {
            stack.addArrangedSubview(iv) // attach now; the image arrives later and grows the row
            URLSession.shared.dataTask(with: u) { data, _, _ in
                guard let data, let image = NSImage(data: data) else { return }
                DispatchQueue.main.async { apply(image) }
            }.resume()
            return
        }
        addFallback()
    }

    private func renderDetailSurface(_ node: ViewNode) {
        let md = node.props["markdown"]?.stringValue ?? node.props["detailText"]?.stringValue ?? (node.title ?? "")
        let h = NSStackView()
        h.orientation = .horizontal
        h.alignment = .top
        h.spacing = 0
        h.translatesAutoresizingMaskIntoConstraints = false
        let mdScroll = markdownScroll(md)
        h.addArrangedSubview(mdScroll)
        var sidebarReserve: CGFloat = 0
        if let metaNode = node.children.first(where: { $0.type == "metadata" }), !metaNode.children.isEmpty {
            let divider = NSBox(); divider.boxType = .separator; divider.translatesAutoresizingMaskIntoConstraints = false
            let side = detailMetadataSidebar(metaNode)
            h.addArrangedSubview(divider)
            h.addArrangedSubview(side)
            NSLayoutConstraint.activate([divider.widthAnchor.constraint(equalToConstant: 1), side.widthAnchor.constraint(equalToConstant: 240)])
            sidebarReserve = 241 // divider + sidebar
        }
        stack.addArrangedSubview(h)
        NSLayoutConstraint.activate([
            h.widthAnchor.constraint(equalTo: stack.widthAnchor),
            h.heightAnchor.constraint(equalToConstant: 420),
            // Pin the markdown column's width to the available space so its content (esp. images) is
            // bounded by the palette — otherwise a large image makes the scroll grow to its natural size
            // and spill off-screen instead of scaling down to fit.
            mdScroll.widthAnchor.constraint(equalTo: stack.widthAnchor, constant: -sidebarReserve),
            // Pin the scroll's HEIGHT to the detail viewport too. With the stack's .top alignment the
            // scroll otherwise grows to its content height (a tall image), overflowing the window instead
            // of clipping + scrolling within the 420 viewport.
            mdScroll.heightAnchor.constraint(equalTo: h.heightAnchor),
        ])
    }

    private func detailMetadataSidebar(_ metaNode: ViewNode) -> NSView {
        let v = NSStackView()
        v.orientation = .vertical
        v.alignment = .width
        v.spacing = 7
        v.translatesAutoresizingMaskIntoConstraints = false
        let header = NSTextField(labelWithString: "Information")
        header.font = .systemFont(ofSize: 11, weight: .semibold)
        header.textColor = .tertiaryLabelColor
        v.addArrangedSubview(header)
        for child in metaNode.children where child.type == "metadata-label" {
            v.addArrangedSubview(metadataRow(label: child.props["title"]?.stringValue ?? "", value: child.props["text"]?.stringValue ?? ""))
        }
        let wrap = NSView()
        wrap.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(v)
        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: wrap.topAnchor, constant: 14),
            v.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 14),
            v.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -14),
            v.bottomAnchor.constraint(lessThanOrEqualTo: wrap.bottomAnchor, constant: -14), // define wrap's height
        ])
        return wrap
    }

    // MARK: Grid

    private func renderGrid(_ grid: ViewNode, selectedIndex: Int) {
        var columns = 5
        if case .number(let n)? = grid.props["columns"] { columns = max(1, Int(n)) }
        var itemHeight: CGFloat = 72
        if case .number(let h)? = grid.props["itemHeight"] { itemHeight = CGFloat(h) }
        var gridItems: [ViewNode] = []
        func collect(_ n: ViewNode) { if n.type == "grid-item" { gridItems.append(n) }; n.children.forEach(collect) }
        collect(grid)
        var idx = 0
        var i = 0
        while i < gridItems.count {
            let rowItems = Array(gridItems[i..<min(i + columns, gridItems.count)])
            let rowStack = NSStackView()
            rowStack.orientation = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 8
            rowStack.translatesAutoresizingMaskIntoConstraints = false
            for node in rowItems {
                let cell = gridCell(node, selected: idx == selectedIndex, index: idx, thumbHeight: itemHeight)
                if idx == selectedIndex { selectedRowView = cell }
                gridCells.append(cell) // index-aligned, for the selection fast-path
                rowStack.addArrangedSubview(cell)
                idx += 1
            }
            for _ in 0..<(columns - rowItems.count) { rowStack.addArrangedSubview(NSView()) } // pad for equal cells
            stack.addArrangedSubview(rowStack)
            NSLayoutConstraint.activate([rowStack.widthAnchor.constraint(equalTo: stack.widthAnchor)])
            i += columns
        }
        itemCounter = gridItems.count
    }

    private func gridCell(_ node: ViewNode, selected: Bool, index: Int, thumbHeight: CGFloat = 72) -> NSView {
        let cell = ClickableRow()
        wireClick(cell, index: index)
        cell.translatesAutoresizingMaskIntoConstraints = false
        cell.wantsLayer = true
        cell.layer?.cornerRadius = 8
        applyGridSelection(cell, selected: selected) // accent ring + fill so keyboard nav is visible
        let v = NSStackView()
        v.orientation = .vertical
        v.alignment = .centerX
        v.spacing = 6
        v.translatesAutoresizingMaskIntoConstraints = false
        let thumb = NSView()
        thumb.wantsLayer = true
        thumb.layer?.cornerRadius = 6
        thumb.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.06).cgColor
        thumb.translatesAutoresizingMaskIntoConstraints = false
        if let b64 = node.props["thumb"]?.stringValue, let img = cachedImage(b64) {
            let iv = NSImageView(image: img); iv.imageScaling = .scaleProportionallyUpOrDown; iv.translatesAutoresizingMaskIntoConstraints = false
            // The image must NOT resist compression, or its intrinsic size pushes the whole window wider.
            iv.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            iv.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            iv.setContentHuggingPriority(.defaultLow, for: .horizontal)
            thumb.addSubview(iv)
            iv.layer?.cornerRadius = 6; iv.wantsLayer = true; iv.layer?.masksToBounds = true
            NSLayoutConstraint.activate([iv.leadingAnchor.constraint(equalTo: thumb.leadingAnchor), iv.trailingAnchor.constraint(equalTo: thumb.trailingAnchor), iv.topAnchor.constraint(equalTo: thumb.topAnchor), iv.bottomAnchor.constraint(equalTo: thumb.bottomAnchor)])
        } else if let src = imageSource(node.props["content"] ?? node.props["icon"]),
                  loadLocalImage(src) != nil || src.hasPrefix("http://") || src.hasPrefix("https://") {
            // A real image asset: data:/file/relative-to-assetsPath (sync), or a remote http(s) URL
            // (loaded async — e.g. glyph-search's remote SVGs, getFavicon URLs).
            let iv = NSImageView(); iv.imageScaling = .scaleProportionallyUpOrDown; iv.animates = true
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            iv.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            iv.setContentHuggingPriority(.defaultLow, for: .horizontal)
            thumb.addSubview(iv)
            iv.layer?.cornerRadius = 6; iv.wantsLayer = true; iv.layer?.masksToBounds = true
            NSLayoutConstraint.activate([iv.leadingAnchor.constraint(equalTo: thumb.leadingAnchor), iv.trailingAnchor.constraint(equalTo: thumb.trailingAnchor), iv.topAnchor.constraint(equalTo: thumb.topAnchor), iv.bottomAnchor.constraint(equalTo: thumb.bottomAnchor)])
            if let img = loadLocalImage(src) { iv.image = img } else { loadRemoteImage(src, into: iv) }
        } else if let sym = node.props["icon"]?.stringValue ?? node.props["content"]?.stringValue,
                  let img = NSImage(systemSymbolName: sym, accessibilityDescription: nil) ?? NSImage(systemSymbolName: sfSymbol(for: sym), accessibilityDescription: nil) {
            let iv = NSImageView(image: img); iv.contentTintColor = .secondaryLabelColor; iv.imageScaling = .scaleProportionallyDown; iv.translatesAutoresizingMaskIntoConstraints = false
            thumb.addSubview(iv)
            NSLayoutConstraint.activate([iv.centerXAnchor.constraint(equalTo: thumb.centerXAnchor), iv.centerYAnchor.constraint(equalTo: thumb.centerYAnchor), iv.widthAnchor.constraint(equalToConstant: 30), iv.heightAnchor.constraint(equalToConstant: 30)])
        }
        v.addArrangedSubview(thumb)
        let title = NSTextField(labelWithString: node.title ?? "")
        title.font = .systemFont(ofSize: 12)
        title.alignment = .center
        title.lineBreakMode = .byTruncatingTail
        title.maximumNumberOfLines = 2
        v.addArrangedSubview(title)
        cell.addSubview(v)
        NSLayoutConstraint.activate([
            thumb.heightAnchor.constraint(equalToConstant: thumbHeight),
            thumb.widthAnchor.constraint(equalTo: v.widthAnchor),
            v.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 6),
            v.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -6),
            v.topAnchor.constraint(equalTo: cell.topAnchor, constant: 6),
            v.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -6),
        ])
        return cell
    }

    // MARK: Form

    // Grid fast-path state: when only the selection changes on the SAME grid tree, re-highlight the
    // existing cells instead of rebuilding ~dozens of cell views per keypress (the screenshot-nav lag).
    private var gridCells: [NSView] = []
    private weak var lastRenderedTree: ViewTree?
    private var lastSurfaceWasGrid = false

    private func applyGridSelection(_ cell: NSView, selected: Bool) {
        cell.layer?.backgroundColor = (selected ? NSColor.controlAccentColor.withAlphaComponent(0.18) : NSColor.gray.withAlphaComponent(0.10)).cgColor
        cell.layer?.borderWidth = selected ? 2 : 0
        cell.layer?.borderColor = NSColor.controlAccentColor.cgColor
    }

    /// Decoded thumbnail cache keyed by base64 — so re-rendering a grid (e.g. on every arrow keypress)
    /// reuses images instead of re-decoding ~dozens of PNGs each time (the screenshot-nav lag).
    private var imageCache: [String: NSImage] = [:]
    private func cachedImage(_ b64: String) -> NSImage? {
        if let c = imageCache[b64] { return c }
        guard let data = Data(base64Encoded: b64), let img = NSImage(data: data) else { return nil }
        if imageCache.count > 400 { imageCache.removeAll() } // bound memory across many grids
        imageCache[b64] = img
        return img
    }

    /// The current extension's assets/ directory — set by the shell when an extension is shown, so
    /// relative image sources (Raycast's `{ source: "icon.png" }`) resolve against it. "" otherwise.
    public var assetsPath = ""

    /// Extract an image source string from an Image.ImageLike value (a bare string, or `{ source }`).
    private func imageSource(_ v: JSONValue?) -> String? {
        if case .string(let s)? = v { return s }
        if case .object(let o)? = v, case .string(let s)? = o["source"] { return s }
        return nil
    }

    /// Load a local image from a data: URI, file:// URL, absolute path, or a path RELATIVE to the
    /// current extension's assetsPath. Returns nil for http(s) (caller loads async) or unreadable input.
    private func loadLocalImage(_ source: String) -> NSImage? {
        if source.hasPrefix("data:") {
            guard let comma = source.firstIndex(of: ","), source[..<comma].contains("base64"),
                  let data = Data(base64Encoded: String(source[source.index(after: comma)...])) else { return nil }
            return NSImage(data: data)
        }
        if source.hasPrefix("http://") || source.hasPrefix("https://") { return nil }
        var path = source
        if source.hasPrefix("file://") {
            path = URL(string: source)?.path ?? source
        } else if !source.hasPrefix("/") { // relative → the extension's assets dir
            guard !assetsPath.isEmpty else { return nil }
            path = (assetsPath as NSString).appendingPathComponent(source)
        }
        return NSImage(contentsOfFile: path)
    }

    /// Load a remote http(s) image into an image view asynchronously, caching by URL (grids re-render on
    /// every arrow keypress — don't refetch). Used for grid thumbnails, list icons (getFavicon), etc.
    private func loadRemoteImage(_ url: String, into iv: NSImageView) {
        if let cached = imageCache[url] { iv.image = cached; return }
        guard let u = URL(string: url) else { return }
        URLSession.shared.dataTask(with: u) { [weak self, weak iv] data, _, _ in
            guard let data, let img = NSImage(data: data) else { return }
            DispatchQueue.main.async {
                if self?.imageCache.count ?? 0 > 400 { self?.imageCache.removeAll() }
                self?.imageCache[url] = img
                if let iv, iv.superview != nil { iv.image = img }
            }
        }.resume()
    }

    /// Live value readers for the currently-rendered form, by field id (read at submit time).
    private var formControls: [(id: String, value: () -> String)] = []
    private weak var firstFormResponder: NSView? // focus this when a form renders (the first field)
    private var formResponderViews: [NSView] = []  // form controls in order, for the Tab key-view loop
    // Live onChange: control → (field id, onChange handler id); and field id → control (to restore focus
    // after a controlled re-render). Cleared and rebuilt each renderFormSurface.
    private var formFieldInfo: [ObjectIdentifier: (id: String, onChange: String?)] = [:]
    private var formFieldViewById: [String: NSView] = [:]
    // The last field the user edited. render() clears the old field views (resigning first responder)
    // BEFORE renderFormSurface runs, so the live first responder is gone by then — this survives the
    // clear and is the field to re-focus after a controlled re-render.
    private var lastEditedFieldId: String?
    /// Fired live as a Form field's value changes (args: onChange handler id, new value). The shell
    /// invokes the handler in the extension so controlled forms (e.g. live-computed results) update.
    public var onFormFieldChange: ((String, String) -> Void)?

    /// The field id of the form field that currently has focus (so a re-render can restore it instead of
    /// jumping back to the first field). For an NSTextField, the first responder is its field editor.
    private func focusedFormFieldId() -> String? {
        guard let fr = window?.firstResponder else { return nil }
        if let tv = fr as? NSTextView { return formFieldInfo[ObjectIdentifier(tv)]?.id }
        if let editor = fr as? NSText, let d = editor.delegate as AnyObject? {
            return formFieldInfo[ObjectIdentifier(d)]?.id
        }
        return nil
    }
    public func currentFormValues() -> [String: String] {
        var out: [String: String] = [:]
        for c in formControls { out[c.id] = c.value() }
        return out
    }

    /// Cycle focus among the current form's fields (Tab / Shift-Tab). Returns false if there's no form,
    /// so the caller can let the event pass through. Handled here (not via nextKeyView) so Tab can't
    /// escape the borderless panel and make it resign key.
    public func moveFormFocus(reverse: Bool) -> Bool {
        guard !formResponderViews.isEmpty, let win = window else { return false }
        let fr = win.firstResponder
        var idx = formResponderViews.firstIndex { $0 === fr }
        if idx == nil, let editor = fr as? NSText { // a focused NSTextField's responder is its field editor
            idx = formResponderViews.firstIndex { ($0 as? NSTextField) != nil && (editor.delegate as AnyObject?) === ($0 as AnyObject) }
        }
        let count = formResponderViews.count
        let next = ((idx ?? (reverse ? 0 : -1)) + (reverse ? -1 : 1) + count) % count
        win.makeFirstResponder(formResponderViews[next])
        return true
    }

    /// Live field values captured before the last form rebuild, by id. A controlled form re-renders on
    /// the extension's state changes; Invoke doesn't echo per-keystroke edits back to React, so the
    /// node's `value` lags behind what the user typed. Re-seeding the rebuilt field from this snapshot
    /// preserves the user's input instead of wiping it (the "fields empty on save" bug).
    private var preservedFormValues: [String: String] = [:]

    private func renderFormSurface(_ node: ViewNode) {
        // render() already cleared the old fields (resigning first responder), so prefer the last-edited
        // field id, falling back to the live first responder if somehow still set.
        let prevFocusId = lastEditedFieldId ?? focusedFormFieldId()
        preservedFormValues = currentFormValues() // snapshot before we tear the controls down
        formControls.removeAll()
        formFieldInfo.removeAll()
        formFieldViewById.removeAll()
        firstFormResponder = nil
        formResponderViews.removeAll()
        let form = NSStackView()
        form.orientation = .vertical
        form.alignment = .leading
        form.spacing = 12
        form.translatesAutoresizingMaskIntoConstraints = false
        var fields: [ViewNode] = []
        // Includes form-description / form-separator so they render in document order (they're not
        // interactive fields, but they're part of the form's visual layout — Raycast parity).
        let fieldTypes: Set<String> = ["form-textfield", "form-textarea", "form-checkbox", "form-dropdown", "form-description", "form-separator"]
        func collect(_ n: ViewNode) {
            // A field owns its own children (e.g. a dropdown's items) — don't treat those as fields.
            if fieldTypes.contains(n.type) { fields.append(n); return }
            n.children.forEach(collect)
        }
        collect(node)
        for f in fields {
            guard let row = formFieldRow(f) else { continue }
            form.addArrangedSubview(row)
            NSLayoutConstraint.activate([row.widthAnchor.constraint(equalTo: form.widthAnchor)])
        }
        let doc = FlippedDocView()
        doc.translatesAutoresizingMaskIntoConstraints = false
        doc.addSubview(form)
        let scroll = NSScrollView()
        scroll.drawsBackground = false
        scroll.hasVerticalScroller = true
        scroll.scrollerStyle = .overlay
        scroll.documentView = doc
        scroll.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.widthAnchor.constraint(equalTo: stack.widthAnchor),
            scroll.heightAnchor.constraint(equalToConstant: 360),
            doc.widthAnchor.constraint(equalTo: scroll.contentView.widthAnchor),
            form.topAnchor.constraint(equalTo: doc.topAnchor, constant: 16),
            form.leadingAnchor.constraint(equalTo: doc.leadingAnchor, constant: 16),
            form.trailingAnchor.constraint(equalTo: doc.trailingAnchor, constant: -16),
            form.bottomAnchor.constraint(equalTo: doc.bottomAnchor, constant: -16),
        ])
        // Tab key-view loop between fields (forward only — a wrap can let focus escape the borderless
        // panel, which then resigns key and auto-hides).
        for i in 0..<max(0, formResponderViews.count - 1) {
            formResponderViews[i].nextKeyView = formResponderViews[i + 1]
        }
        // Restore focus to the field being edited (so a live-onChange re-render doesn't yank focus back
        // to the first field), caret at end; otherwise focus the first field for immediate typing.
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let fid = prevFocusId, let v = self.formFieldViewById[fid] {
                self.window?.makeFirstResponder(v)
                if let tf = v as? NSTextField {
                    tf.currentEditor()?.selectedRange = NSRange(location: (tf.stringValue as NSString).length, length: 0)
                }
            } else if let v = self.firstFormResponder {
                self.window?.makeFirstResponder(v)
            }
        }
    }

    private func formFieldRow(_ f: ViewNode) -> NSView? {
        // Form.Description: a label-gutter row (title on the left, description text on the right) — same
        // 150px gutter as the fields, so it aligns like Raycast's "Edit search / Specify the title…".
        if f.type == "form-description" {
            let r = NSStackView(); r.orientation = .horizontal; r.spacing = 12; r.alignment = .firstBaseline
            r.translatesAutoresizingMaskIntoConstraints = false
            let gutter = NSTextField(labelWithString: f.props["title"]?.stringValue ?? "")
            gutter.alignment = .right; gutter.font = .systemFont(ofSize: 13); gutter.textColor = .secondaryLabelColor
            gutter.translatesAutoresizingMaskIntoConstraints = false
            gutter.setContentHuggingPriority(.required, for: .horizontal)
            let text = NSTextField(wrappingLabelWithString: f.props["text"]?.stringValue ?? "")
            text.font = .systemFont(ofSize: 13); text.textColor = .secondaryLabelColor
            text.translatesAutoresizingMaskIntoConstraints = false
            r.addArrangedSubview(gutter); r.addArrangedSubview(text)
            gutter.widthAnchor.constraint(equalToConstant: 150).isActive = true
            return r
        }
        if f.type == "form-separator" {
            let box = NSBox(); box.boxType = .separator
            box.translatesAutoresizingMaskIntoConstraints = false
            box.heightAnchor.constraint(equalToConstant: 1).isActive = true
            return box
        }
        let id = f.props["id"]?.stringValue ?? ""
        // Raycast-style row: a fixed-width, right-aligned label gutter on the left and the control
        // filling the rest on the right (vs. the old stacked, left-aligned layout).
        let row = NSStackView()
        row.orientation = .horizontal
        row.spacing = 12
        row.distribution = .fill // fixed label gutter; control fills the rest
        row.translatesAutoresizingMaskIntoConstraints = false

        let label = NSTextField(labelWithString: f.props["title"]?.stringValue ?? "")
        label.alignment = .right
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabelColor
        label.lineBreakMode = .byWordWrapping // wrap long preference titles instead of truncating to "…"
        label.maximumNumberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        row.addArrangedSubview(label)
        NSLayoutConstraint.activate([label.widthAnchor.constraint(equalToConstant: 150)])

        let control: NSView
        switch f.type {
        case "form-textfield":
            // Seed from the node value, falling back to the value the user had typed before a re-render
            // (controlled forms don't echo edits back, so the node value can lag — preserve user input).
            let seeded = f.props["value"]?.stringValue ?? f.props["defaultValue"]?.stringValue ?? ""
            let tf = NSTextField(string: seeded.isEmpty ? (preservedFormValues[id] ?? "") : seeded)
            tf.placeholderString = f.props["placeholder"]?.stringValue
            tf.bezelStyle = .roundedBezel // rounded bordered field (Raycast)
            tf.isBezeled = true
            tf.font = .systemFont(ofSize: 13)
            tf.target = self
            tf.action = #selector(formFieldEnter) // Return in a single-line field submits the form
            // Only Return fires the action — NOT Tab/click-away (end-editing), which would otherwise
            // submit the form and dismiss the palette when moving between fields.
            tf.cell?.sendsActionOnEndEditing = false
            formControls.append((id, { [weak tf] in tf?.stringValue ?? "" }))
            tf.delegate = self // controlTextDidChange → live onChange
            formFieldInfo[ObjectIdentifier(tf)] = (id, f.props["onChange"]?.handlerRef)
            formFieldViewById[id] = tf
            if firstFormResponder == nil { firstFormResponder = tf }
            formResponderViews.append(tf)
            control = tf
            row.alignment = .firstBaseline
        case "form-textarea":
            let tv = NSTextView()
            tv.string = f.props["value"]?.stringValue ?? f.props["defaultValue"]?.stringValue ?? ""
            tv.isEditable = true
            tv.font = .systemFont(ofSize: 13)
            tv.textColor = .labelColor
            tv.backgroundColor = NSColor.white.withAlphaComponent(0.08) // subtle dark fill, not stark white
            tv.insertionPointColor = .labelColor
            // Standard document-view-in-scrollview wiring so text wraps + scrolls correctly.
            tv.isVerticallyResizable = true
            tv.isHorizontallyResizable = false
            tv.autoresizingMask = [.width]
            tv.minSize = NSSize(width: 0, height: 0)
            tv.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            tv.textContainerInset = NSSize(width: 4, height: 6)
            tv.textContainer?.widthTracksTextView = true
            let s = NSScrollView()
            s.borderType = .lineBorder
            s.drawsBackground = false
            s.hasVerticalScroller = true
            s.documentView = tv
            s.wantsLayer = true
            s.layer?.cornerRadius = 6
            s.layer?.borderWidth = 1
            s.layer?.borderColor = NSColor.separatorColor.cgColor
            s.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([s.heightAnchor.constraint(equalToConstant: 96)])
            formControls.append((id, { [weak tv] in tv?.string ?? "" }))
            tv.delegate = self // textDidChange → live onChange
            formFieldInfo[ObjectIdentifier(tv)] = (id, f.props["onChange"]?.handlerRef)
            formFieldViewById[id] = tv
            if firstFormResponder == nil { firstFormResponder = tv }
            formResponderViews.append(tv)
            control = s
            row.alignment = .top
        case "form-checkbox":
            // The checkbox carries its own label; the gutter title is usually empty (Raycast parity).
            let cb = NSButton(checkboxWithTitle: f.props["label"]?.stringValue ?? "", target: nil, action: nil)
            if case .bool(true)? = (f.props["value"] ?? f.props["defaultValue"]) { cb.state = .on } // honor defaultValue
            formControls.append((id, { [weak cb] in cb?.state == .on ? "true" : "false" }))
            control = cb
            row.alignment = .firstBaseline
        case "form-dropdown":
            let pop = NSPopUpButton(frame: .zero, pullsDown: false)
            // Populate from Form.Dropdown.Item children (possibly grouped in Form.Dropdown.Section).
            // The visible title is the item's `title`; the SUBMITTED value is its `value`
            // (carried on the menu item's representedObject), not the title.
            var values: [String] = []
            func addItems(_ n: ViewNode) {
                for c in n.children {
                    if c.type == "form-dropdown-item" {
                        let title = c.props["title"]?.stringValue ?? c.props["value"]?.stringValue ?? ""
                        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
                        item.representedObject = c.props["value"]?.stringValue ?? title
                        if let iconPath = c.props["iconPath"]?.stringValue, !iconPath.isEmpty {
                            let img = NSWorkspace.shared.icon(forFile: iconPath)
                            img.size = NSSize(width: 16, height: 16)
                            item.image = img
                        }
                        pop.menu?.addItem(item)
                        values.append(item.representedObject as? String ?? title)
                    } else if c.type == "form-dropdown-section" {
                        if let t = c.props["title"]?.stringValue, !t.isEmpty {
                            pop.menu?.addItem(.sectionHeader(title: t))
                        }
                        addItems(c)
                    }
                }
            }
            addItems(f)
            if let current = (f.props["value"] ?? f.props["defaultValue"])?.stringValue,
               let idx = values.firstIndex(of: current) {
                // selectItem(at:) indexes menu items, which may include section headers — find the menu row.
                if let mi = pop.menu?.items.first(where: { ($0.representedObject as? String) == current }) {
                    pop.select(mi)
                }
                _ = idx
            }
            formControls.append((id, { [weak pop] in (pop?.selectedItem?.representedObject as? String) ?? pop?.titleOfSelectedItem ?? "" }))
            control = pop
            row.alignment = .firstBaseline
        default:
            return nil
        }
        control.translatesAutoresizingMaskIntoConstraints = false
        control.setContentHuggingPriority(.defaultLow, for: .horizontal) // let the control fill the row
        // Inline validation error (Raycast shows it in red under the field). useForm sets this on a
        // failed submit; without rendering it, Save "does nothing" with no feedback.
        if let err = f.props["error"]?.stringValue, !err.isEmpty {
            let col = NSStackView(views: [control])
            col.orientation = .vertical; col.alignment = .leading; col.spacing = 4
            col.translatesAutoresizingMaskIntoConstraints = false
            let errLabel = NSTextField(wrappingLabelWithString: err)
            errLabel.font = .systemFont(ofSize: 11); errLabel.textColor = .systemRed
            errLabel.translatesAutoresizingMaskIntoConstraints = false
            col.addArrangedSubview(errLabel)
            control.widthAnchor.constraint(equalTo: col.widthAnchor).isActive = true
            errLabel.widthAnchor.constraint(lessThanOrEqualTo: col.widthAnchor).isActive = true
            row.addArrangedSubview(col)
        } else {
            row.addArrangedSubview(control)
        }
        return row
    }

    private func appendRows(for node: ViewNode, selectedIndex: Int) {
        switch node.type {
        case "list-section":
            if let title = node.title, !title.isEmpty { addSectionHeader(title) }
            for child in node.children { appendRows(for: child, selectedIndex: selectedIndex) }
        case "list-item":
            let idx = itemCounter
            let selected = (idx == selectedIndex)
            itemCounter += 1
            if let cardVal = node.props["card"], case .object(let card) = cardVal,
               node.props["display"]?.stringValue == "card" {
                addCard(card, selected: selected, index: idx)
            } else {
                addItemRow(node, selected: selected, index: idx)
            }
            // an item is a visual leaf — its ActionPanel children are not rows
        default:
            for child in node.children { appendRows(for: child, selectedIndex: selectedIndex) }
        }
    }

    // MARK: - Section header

    private func addSectionHeader(_ title: String) {
        let label = NSTextField(labelWithString: title)
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabelColor
        let row = NSView()
        row.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(label)
        stack.addArrangedSubview(row)
        NSLayoutConstraint.activate([
            row.widthAnchor.constraint(equalTo: stack.widthAnchor),
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 10),
            label.topAnchor.constraint(equalTo: row.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -8), // breathing room before the list
        ])
    }

    // MARK: - Result card

    private func addCard(_ card: [String: JSONValue], selected: Bool, index: Int) {
        let left = card["left"]?.stringValue ?? ""
        let right = card["right"]?.stringValue ?? ""
        let leftLabel = card["leftLabel"]?.stringValue ?? ""
        let rightLabel = card["rightLabel"]?.stringValue ?? ""
        let note = card["note"]?.stringValue ?? ""

        let cardView = ClickableRow()
        wireClick(cardView, index: index)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.wantsLayer = true
        cardView.layer?.cornerRadius = 12
        cardView.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.06).cgColor

        let leftCol = valueColumn(value: left, label: leftLabel)
        let rightCol = valueColumn(value: right, label: rightLabel)
        let centerCol = centerColumn(note: note)

        let h = NSStackView()
        h.orientation = .horizontal
        h.alignment = .centerY
        h.distribution = .fill
        h.spacing = 12
        h.translatesAutoresizingMaskIntoConstraints = false
        h.addArrangedSubview(leftCol)
        h.addArrangedSubview(centerCol)
        h.addArrangedSubview(rightCol)
        cardView.addSubview(h)

        stack.addArrangedSubview(cardView)
        if selected { selectedRowView = cardView }
        NSLayoutConstraint.activate([
            cardView.widthAnchor.constraint(equalTo: stack.widthAnchor),
            h.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            h.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            h.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            h.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
            leftCol.widthAnchor.constraint(equalTo: rightCol.widthAnchor),
        ])
    }

    private func valueColumn(value: String, label: String) -> NSView {
        let v = NSTextField(labelWithString: value)
        v.font = .systemFont(ofSize: 28, weight: .medium)
        v.alignment = .center
        v.lineBreakMode = .byTruncatingTail
        v.maximumNumberOfLines = 1
        let col = NSStackView()
        col.orientation = .vertical
        col.alignment = .centerX
        col.spacing = 12
        col.translatesAutoresizingMaskIntoConstraints = false
        col.addArrangedSubview(v)
        if !label.isEmpty { col.addArrangedSubview(chip(label)) }
        return col
    }

    private func centerColumn(note: String) -> NSView {
        let arrow = NSTextField(labelWithString: "→")
        arrow.font = .systemFont(ofSize: 20, weight: .regular)
        arrow.textColor = .secondaryLabelColor
        let col = NSStackView()
        col.orientation = .vertical
        col.alignment = .centerX
        col.spacing = 4
        col.translatesAutoresizingMaskIntoConstraints = false
        col.addArrangedSubview(arrow)
        if !note.isEmpty {
            let n = NSTextField(labelWithString: note)
            n.font = .systemFont(ofSize: 10, weight: .regular)
            n.textColor = .tertiaryLabelColor
            col.addArrangedSubview(n)
        }
        col.setContentHuggingPriority(.required, for: .horizontal)
        return col
    }

    // MARK: - Item row

    private func addItemRow(_ node: ViewNode, selected: Bool, index: Int) {
        let row = ClickableRow()
        wireClick(row, index: index)
        row.translatesAutoresizingMaskIntoConstraints = false
        row.wantsLayer = true
        row.layer?.cornerRadius = 7
        // Subtle translucent highlight (not saturated accent), text colors unchanged — matches the
        // Raycast row selection.
        row.layer?.backgroundColor = selected ? NSColor.white.withAlphaComponent(0.13).cgColor : NSColor.clear.cgColor

        let h = NSStackView()
        h.orientation = .horizontal
        h.alignment = .centerY
        h.spacing = 8
        h.translatesAutoresizingMaskIntoConstraints = false

        if let glyph = node.props["glyph"]?.stringValue {
            let g = NSTextField(labelWithString: glyph) // emoji
            g.font = .systemFont(ofSize: 18)
            g.translatesAutoresizingMaskIntoConstraints = false
            h.addArrangedSubview(g)
        } else if let icon = iconView(for: node, selected: selected) {
            h.addArrangedSubview(icon)
        }

        let title = NSTextField(labelWithString: node.title ?? "")
        title.font = .systemFont(ofSize: 14)
        title.textColor = .labelColor
        title.lineBreakMode = .byTruncatingTail
        title.maximumNumberOfLines = 1
        // Let a long title TRUNCATE within the fixed palette width rather than stretch the row (and the
        // window) past the edge — e.g. office-quotes' very long quotes. Kept above the subtitle (.defaultLow)
        // so when both exist the subtitle truncates first.
        title.setContentCompressionResistancePriority(.init(490), for: .horizontal)
        h.addArrangedSubview(title)

        if let sub = node.props["subtitle"]?.stringValue, !sub.isEmpty {
            let s = NSTextField(labelWithString: sub)
            s.font = .systemFont(ofSize: 13)
            s.textColor = .secondaryLabelColor
            s.lineBreakMode = .byTruncatingTail
            // Truncate the subtitle FIRST (lower than the title) so a long description (e.g. a verbose
            // GitHub repo blurb) shrinks instead of stretching the row past the window edge.
            s.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            s.setContentHuggingPriority(.init(10), for: .horizontal)
            h.addArrangedSubview(s)
        }

        let spacer = NSView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.init(1), for: .horizontal)
        h.addArrangedSubview(spacer)

        // Accessories: { text } → plain right-aligned type label (Raycast style); { tag } → chip.
        for acc in accessories(node) {
            switch acc {
            case .text(let t):
                let l = NSTextField(labelWithString: t)
                l.font = .systemFont(ofSize: 13)
                l.textColor = .tertiaryLabelColor
                h.addArrangedSubview(l)
            case .tag(let t):
                h.addArrangedSubview(chip(t))
            }
        }

        row.addSubview(h)
        stack.addArrangedSubview(row)
        if selected { selectedRowView = row }
        NSLayoutConstraint.activate([
            row.widthAnchor.constraint(equalTo: stack.widthAnchor),
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 38),
            h.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 10),
            h.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -10),
            h.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
    }

    // MARK: - Helpers

    private func chip(_ text: String) -> NSView {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = .secondaryLabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        let bg = NSView()
        bg.wantsLayer = true
        bg.layer?.cornerRadius = 6
        bg.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.09).cgColor
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        bg.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: bg.topAnchor, constant: 3),
            label.bottomAnchor.constraint(equalTo: bg.bottomAnchor, constant: -3),
        ])
        return bg
    }

    private enum Accessory { case text(String); case tag(String) }

    private func accessories(_ node: ViewNode) -> [Accessory] {
        guard let acc = node.props["accessories"], case .array(let arr) = acc else { return [] }
        var out: [Accessory] = []
        for item in arr {
            guard case .object(let o) = item else { continue }
            if let tag = o["tag"]?.stringValue { out.append(.tag(tag)) }
            else if let text = o["text"]?.stringValue { out.append(.text(text)) }
        }
        return out
    }

    private func iconView(for node: ViewNode, selected: Bool) -> NSView? {
        // Manifest image icon (full color) for extension commands — loaded from the extension's assets.
        if let p = node.props["iconImagePath"]?.stringValue, let img = NSImage(contentsOfFile: p) {
            let iv = NSImageView(image: img)
            iv.imageScaling = .scaleProportionallyUpOrDown
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.widthAnchor.constraint(equalToConstant: 20).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 20).isActive = true
            return iv
        }
        // Real app/file icon (full color) for application and file rows.
        if let path = node.props["appPath"]?.stringValue ?? node.props["fileIcon"]?.stringValue {
            let iv = NSImageView(image: NSWorkspace.shared.icon(forFile: path))
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.widthAnchor.constraint(equalToConstant: 20).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 20).isActive = true
            return iv
        }
        // Image icon — an Image.ImageLike (`{ source }`, data:/file/relative, or remote http(s)), e.g.
        // getFavicon / getAvatarIcon. Loaded sync when local, async when remote.
        if let src = imageSource(node.props["icon"]),
           loadLocalImage(src) != nil || src.hasPrefix("http://") || src.hasPrefix("https://") {
            let iv = NSImageView(); iv.imageScaling = .scaleProportionallyUpOrDown
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.widthAnchor.constraint(equalToConstant: 18).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 18).isActive = true
            if let img = loadLocalImage(src) { iv.image = img } else { loadRemoteImage(src, into: iv) }
            return iv
        }
        // SF Symbol: try the name directly (e.g. "house"), else map the Icon enum.
        guard let name = node.props["icon"]?.stringValue,
              let img = NSImage(systemSymbolName: name, accessibilityDescription: nil)
                ?? NSImage(systemSymbolName: sfSymbol(for: name), accessibilityDescription: nil) else { return nil }
        // Command/AI rows render the glyph white on a colored rounded tile (Raycast-style).
        if let key = node.props["iconTileKey"]?.stringValue {
            return Self.commandTile(symbol: img, key: key)
        }
        let iv = NSImageView(image: img)
        iv.contentTintColor = selected ? .white : .secondaryLabelColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.widthAnchor.constraint(equalToConstant: 16).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 16).isActive = true
        return iv
    }

    /// Curated tile colors (white glyph reads on all of them). Keyed stably by group so a whole
    /// extension shares one color, like Raycast.
    private static let tilePalette: [NSColor] = [
        .systemBlue, .systemRed, .systemOrange, .systemPurple, .systemGreen,
        .systemTeal, .systemPink, .systemIndigo, .systemBrown,
    ]
    private static func tileColor(_ key: String) -> NSColor {
        var h: UInt64 = 5381
        for b in key.utf8 { h = (h &* 33) &+ UInt64(b) } // djb2 — stable across runs (Swift hashValue isn't)
        return tilePalette[Int(h % UInt64(tilePalette.count))]
    }
    private static func commandTile(symbol: NSImage, key: String) -> NSView {
        let tile = NSView()
        tile.wantsLayer = true
        tile.layer?.cornerRadius = 5
        tile.layer?.backgroundColor = tileColor(key).cgColor
        tile.translatesAutoresizingMaskIntoConstraints = false
        let conf = NSImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        let glyph = symbol.withSymbolConfiguration(conf) ?? symbol
        let iv = NSImageView(image: glyph)
        iv.contentTintColor = .white
        iv.imageScaling = .scaleProportionallyDown
        iv.translatesAutoresizingMaskIntoConstraints = false
        tile.addSubview(iv)
        NSLayoutConstraint.activate([
            tile.widthAnchor.constraint(equalToConstant: 20),
            tile.heightAnchor.constraint(equalToConstant: 20),
            iv.centerXAnchor.constraint(equalTo: tile.centerXAnchor),
            iv.centerYAnchor.constraint(equalTo: tile.centerYAnchor),
            iv.widthAnchor.constraint(equalToConstant: 13),
            iv.heightAnchor.constraint(equalToConstant: 13),
        ])
        return tile
    }

    private func sfSymbol(for icon: String) -> String {
        switch icon {
        case "circle": return "circle.fill"
        case "star": return "star.fill"
        case "clipboard": return "doc.on.clipboard"
        case "globe": return "globe"
        case "window": return "macwindow"
        case "calendar": return "calendar"
        case "magnifying-glass": return "magnifyingglass"
        case "app-window-grid-3x3": return "square.grid.3x3"
        case "car": return "car"
        case "code": return "chevron.left.forwardslash.chevron.right"
        case "code-block": return "curlybraces"
        case "credit-card": return "creditcard"
        case "crypto": return "bitcoinsign.circle"
        case "envelope": return "envelope"
        case "fingerprint": return "touchid"
        case "gift": return "gift"
        case "hard-drive": return "internaldrive"
        case "heartbeat": return "waveform.path.ecg"
        case "key": return "key"
        case "paperclip": return "paperclip"
        case "repeat": return "repeat"
        case "shield": return "shield"
        case "star-circle": return "star.circle"
        case "switch": return "switch.2"
        case "terminal": return "terminal"
        case "text": return "text.alignleft"
        case "tree": return "leaf"
        case "wallet": return "wallet.pass"
        case "wifi": return "wifi"
        case "wifi-disabled": return "wifi.slash"
        default: return "app"
        }
    }
}

// Live Form onChange: forward each keystroke to the extension's onChange handler (controlled forms,
// e.g. a live-computed result, depend on this). The shell invokes the handler in the child.
extension PaletteView: NSTextFieldDelegate {
    public func controlTextDidChange(_ obj: Notification) {
        guard let tf = obj.object as? NSTextField, let info = formFieldInfo[ObjectIdentifier(tf)] else { return }
        lastEditedFieldId = info.id // re-focus this field after the controlled re-render
        if let h = info.onChange { onFormFieldChange?(h, tf.stringValue) }
    }
}

extension PaletteView: NSTextViewDelegate {
    public func textDidChange(_ notification: Notification) {
        guard let tv = notification.object as? NSTextView, let info = formFieldInfo[ObjectIdentifier(tv)] else { return }
        lastEditedFieldId = info.id
        if let h = info.onChange { onFormFieldChange?(h, tv.string) }
    }
}
