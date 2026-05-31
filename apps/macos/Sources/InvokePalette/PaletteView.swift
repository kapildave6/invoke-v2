import AppKit
import InvokeIPC
import InvokeRenderer

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

    /// Height the rendered content wants (capped — beyond it the list scrolls). Drives the window.
    public func fittingHeight() -> CGFloat {
        layoutSubtreeIfNeeded()
        return min(stack.fittingSize.height + 16, maxContentHeight)
    }

    /// Re-render rows from the current view-model tree, highlighting the item at `selectedIndex`
    /// (item indices are assigned in pre-order, matching the host's selection model).
    public func render(_ tree: ViewTree, selectedIndex: Int) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        itemCounter = 0
        selectedRowView = nil
        let surfaces = tree.root.children
        // Dispatch on the top-level surface the extension rendered (PLAN.md §5 component set).
        if let detail = surfaces.first(where: { $0.type == "detail" }) {
            renderDetailSurface(detail)
        } else if let form = surfaces.first(where: { $0.type == "form" }) {
            renderFormSurface(form)
        } else if let grid = surfaces.first(where: { $0.type == "grid" }) {
            renderGrid(grid, selectedIndex: selectedIndex)
            scrollSelectedIntoView()
        } else if let list = surfaces.first(where: { $0.type == "list" }),
                  case .bool(true)? = list.props["showDetail"] {
            renderSplit(list: list, selectedIndex: selectedIndex) // master–detail (e.g. Clipboard History)
        } else {
            appendRows(for: tree.root, selectedIndex: selectedIndex)
            scrollSelectedIntoView()
        }
    }

    private func scrollSelectedIntoView() {
        guard let row = selectedRowView else { return }
        DispatchQueue.main.async { [weak self, weak row] in
            self?.layoutSubtreeIfNeeded()
            if let row { row.scrollToVisible(row.bounds) }
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
        row.layer?.backgroundColor = selected ? NSColor.white.withAlphaComponent(0.13).cgColor : NSColor.clear.cgColor
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

    private func detailPane(_ node: ViewNode?) -> NSView {
        let pane = NSView()
        pane.translatesAutoresizingMaskIntoConstraints = false
        guard let node else { return pane }

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

        let info = NSStackView()
        info.orientation = .vertical
        info.alignment = .width // rows fill the pane width so values right-align
        info.distribution = .fill
        info.spacing = 7
        info.translatesAutoresizingMaskIntoConstraints = false
        let header = NSTextField(labelWithString: "Information")
        header.font = .systemFont(ofSize: 11, weight: .semibold)
        header.textColor = .tertiaryLabelColor
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

            // Information anchored at a constant Y (preview bottom), so it no longer jumps per item.
            info.topAnchor.constraint(equalTo: preview.bottomAnchor, constant: 14),
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
        for run in parsed.runs {
            let text = String(parsed[run.range].characters)
            var size = baseSize, bold = false, italic = false, mono = false
            if let block = run.presentationIntent {
                for comp in block.components { if case .header(let level) = comp.kind { bold = true; size = baseSize + CGFloat(max(0, 7 - level) * 2) } }
            }
            if let inline = run.inlinePresentationIntent {
                if inline.contains(.stronglyEmphasized) { bold = true }
                if inline.contains(.emphasized) { italic = true }
                if inline.contains(.code) { mono = true; size = baseSize - 1 }
            }
            var font = mono ? NSFont.monospacedSystemFont(ofSize: size, weight: bold ? .semibold : .regular)
                            : NSFont.systemFont(ofSize: size, weight: bold ? .semibold : .regular)
            if italic { font = NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask) }
            var attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.labelColor]
            if let link = run.link { attrs[.foregroundColor] = NSColor.linkColor; attrs[.link] = link }
            out.append(NSAttributedString(string: text, attributes: attrs))
        }
        return out
    }

    /// A scrollable wrapping label of attributed markdown.
    private func markdownScroll(_ md: String) -> NSScrollView {
        let body = NSTextField(labelWithAttributedString: Self.attributedMarkdown(md))
        body.isSelectable = true
        body.lineBreakMode = .byWordWrapping
        body.maximumNumberOfLines = 0
        body.translatesAutoresizingMaskIntoConstraints = false
        let doc = FlippedDocView()
        doc.translatesAutoresizingMaskIntoConstraints = false
        doc.addSubview(body)
        let scroll = NSScrollView()
        scroll.drawsBackground = false
        scroll.hasVerticalScroller = true
        scroll.scrollerStyle = .overlay
        scroll.documentView = doc
        scroll.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            doc.widthAnchor.constraint(equalTo: scroll.contentView.widthAnchor),
            body.leadingAnchor.constraint(equalTo: doc.leadingAnchor, constant: 16),
            body.trailingAnchor.constraint(equalTo: doc.trailingAnchor, constant: -16),
            body.topAnchor.constraint(equalTo: doc.topAnchor, constant: 14),
            body.bottomAnchor.constraint(equalTo: doc.bottomAnchor, constant: -14),
        ])
        return scroll
    }

    private func renderDetailSurface(_ node: ViewNode) {
        let md = node.props["markdown"]?.stringValue ?? node.props["detailText"]?.stringValue ?? (node.title ?? "")
        let h = NSStackView()
        h.orientation = .horizontal
        h.alignment = .top
        h.spacing = 0
        h.translatesAutoresizingMaskIntoConstraints = false
        h.addArrangedSubview(markdownScroll(md))
        if let metaNode = node.children.first(where: { $0.type == "metadata" }), !metaNode.children.isEmpty {
            let divider = NSBox(); divider.boxType = .separator; divider.translatesAutoresizingMaskIntoConstraints = false
            let side = detailMetadataSidebar(metaNode)
            h.addArrangedSubview(divider)
            h.addArrangedSubview(side)
            NSLayoutConstraint.activate([divider.widthAnchor.constraint(equalToConstant: 1), side.widthAnchor.constraint(equalToConstant: 240)])
        }
        stack.addArrangedSubview(h)
        NSLayoutConstraint.activate([
            h.widthAnchor.constraint(equalTo: stack.widthAnchor),
            h.heightAnchor.constraint(equalToConstant: 420),
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
        ])
        return wrap
    }

    // MARK: Grid

    private func renderGrid(_ grid: ViewNode, selectedIndex: Int) {
        var columns = 5
        if case .number(let n)? = grid.props["columns"] { columns = max(1, Int(n)) }
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
                let cell = gridCell(node, selected: idx == selectedIndex, index: idx)
                if idx == selectedIndex { selectedRowView = cell }
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

    private func gridCell(_ node: ViewNode, selected: Bool, index: Int) -> NSView {
        let cell = ClickableRow()
        wireClick(cell, index: index)
        cell.translatesAutoresizingMaskIntoConstraints = false
        cell.wantsLayer = true
        cell.layer?.cornerRadius = 8
        cell.layer?.backgroundColor = (selected ? NSColor.white.withAlphaComponent(0.13) : NSColor.white.withAlphaComponent(0.04)).cgColor
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
        if let b64 = node.props["thumb"]?.stringValue, let data = Data(base64Encoded: b64), let img = NSImage(data: data) {
            let iv = NSImageView(image: img); iv.imageScaling = .scaleProportionallyUpOrDown; iv.translatesAutoresizingMaskIntoConstraints = false
            thumb.addSubview(iv)
            NSLayoutConstraint.activate([iv.leadingAnchor.constraint(equalTo: thumb.leadingAnchor), iv.trailingAnchor.constraint(equalTo: thumb.trailingAnchor), iv.topAnchor.constraint(equalTo: thumb.topAnchor), iv.bottomAnchor.constraint(equalTo: thumb.bottomAnchor)])
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
            thumb.heightAnchor.constraint(equalToConstant: 72),
            thumb.widthAnchor.constraint(equalTo: v.widthAnchor),
            v.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 6),
            v.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -6),
            v.topAnchor.constraint(equalTo: cell.topAnchor, constant: 6),
            v.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -6),
        ])
        return cell
    }

    // MARK: Form

    /// Live value readers for the currently-rendered form, by field id (read at submit time).
    private var formControls: [(id: String, value: () -> String)] = []
    public func currentFormValues() -> [String: String] {
        var out: [String: String] = [:]
        for c in formControls { out[c.id] = c.value() }
        return out
    }

    private func renderFormSurface(_ node: ViewNode) {
        formControls.removeAll()
        let form = NSStackView()
        form.orientation = .vertical
        form.alignment = .leading
        form.spacing = 12
        form.translatesAutoresizingMaskIntoConstraints = false
        var fields: [ViewNode] = []
        func collect(_ n: ViewNode) { if n.type.hasPrefix("form-") { fields.append(n) }; n.children.forEach(collect) }
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
    }

    private func formFieldRow(_ f: ViewNode) -> NSView? {
        let id = f.props["id"]?.stringValue ?? ""
        let row = NSStackView()
        row.orientation = .vertical
        row.alignment = .leading
        row.spacing = 4
        row.translatesAutoresizingMaskIntoConstraints = false
        if let title = f.props["title"]?.stringValue, !title.isEmpty {
            let label = NSTextField(labelWithString: title)
            label.font = .systemFont(ofSize: 12, weight: .medium)
            label.textColor = .secondaryLabelColor
            row.addArrangedSubview(label)
        }
        switch f.type {
        case "form-textfield":
            let tf = NSTextField(string: f.props["value"]?.stringValue ?? f.props["defaultValue"]?.stringValue ?? "")
            tf.placeholderString = f.props["placeholder"]?.stringValue
            tf.translatesAutoresizingMaskIntoConstraints = false
            row.addArrangedSubview(tf)
            NSLayoutConstraint.activate([tf.widthAnchor.constraint(equalTo: row.widthAnchor)])
            formControls.append((id, { [weak tf] in tf?.stringValue ?? "" }))
        case "form-textarea":
            let tv = NSTextView()
            tv.string = f.props["value"]?.stringValue ?? f.props["defaultValue"]?.stringValue ?? ""
            tv.isEditable = true
            tv.font = .systemFont(ofSize: 13)
            let s = NSScrollView()
            s.borderType = .lineBorder
            s.hasVerticalScroller = true
            s.documentView = tv
            s.translatesAutoresizingMaskIntoConstraints = false
            row.addArrangedSubview(s)
            NSLayoutConstraint.activate([s.widthAnchor.constraint(equalTo: row.widthAnchor), s.heightAnchor.constraint(equalToConstant: 80)])
            formControls.append((id, { [weak tv] in tv?.string ?? "" }))
        case "form-checkbox":
            let cb = NSButton(checkboxWithTitle: f.props["label"]?.stringValue ?? "", target: nil, action: nil)
            if case .bool(true)? = f.props["value"] { cb.state = .on }
            cb.translatesAutoresizingMaskIntoConstraints = false
            row.addArrangedSubview(cb)
            formControls.append((id, { [weak cb] in cb?.state == .on ? "true" : "false" }))
        case "form-dropdown":
            let pop = NSPopUpButton(frame: .zero, pullsDown: false)
            pop.translatesAutoresizingMaskIntoConstraints = false
            row.addArrangedSubview(pop) // options need Form.Dropdown.Item (SDK gap) — empty for now
            formControls.append((id, { [weak pop] in pop?.titleOfSelectedItem ?? "" }))
        default:
            return nil
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
        title.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
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

    private func iconView(for node: ViewNode, selected: Bool) -> NSImageView? {
        // Real app/file icon (full color) for application and file rows.
        if let path = node.props["appPath"]?.stringValue ?? node.props["fileIcon"]?.stringValue {
            let iv = NSImageView(image: NSWorkspace.shared.icon(forFile: path))
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.widthAnchor.constraint(equalToConstant: 20).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 20).isActive = true
            return iv
        }
        // Otherwise a tinted SF Symbol: try the name directly (e.g. "house"), else map the Icon enum.
        guard let name = node.props["icon"]?.stringValue,
              let img = NSImage(systemSymbolName: name, accessibilityDescription: nil)
                ?? NSImage(systemSymbolName: sfSymbol(for: name), accessibilityDescription: nil) else { return nil }
        let iv = NSImageView(image: img)
        iv.contentTintColor = selected ? .white : .secondaryLabelColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.widthAnchor.constraint(equalToConstant: 16).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 16).isActive = true
        return iv
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
        default: return "app"
        }
    }
}
