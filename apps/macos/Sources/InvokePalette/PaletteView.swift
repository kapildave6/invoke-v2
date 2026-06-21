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
    // Virtualized grid (Raycast parity): an NSCollectionView only builds/recycles VISIBLE cells, so a
    // 2,000+ item grid (e.g. glyph-search) is instant instead of building every cell up front.
    private let gridScroll = NSScrollView()
    private let collectionView = NSCollectionView()
    private var gridData: [ViewNode] = []
    private var gridSelected = 0
    private var gridThumbHeight: CGFloat = 72
    private var itemCounter = 0
    private var selectedRowView: NSView?
    // Virtualized list (Raycast parity): an NSTableView builds/recycles only VISIBLE rows, so a huge list
    // is instant and arrow-nav doesn't rebuild every row (the stack path rebuilt all rows on each render).
    private let listScroll = NSScrollView()
    private let listTable = NSTableView()
    private enum ListEntry { case header(String); case item(ViewNode, Int); case card([String: JSONValue], Int) }
    private var listData: [ListEntry] = []
    private var listSelected = 0
    private var lastSurfaceWasList = false
    // Virtualized master-detail SPLIT (clipboard history, List.Item.Detail): the left list is a second
    // view-based NSTableView; the right detail pane is swapped on selection. Persistent so arrow-nav uses
    // a fast path (reload old+new left rows + rebuild only the detail pane) instead of rebuilding the split.
    private let splitContainer = NSView()
    private let splitLeftScroll = NSScrollView()
    private let splitTable = NSTableView()
    private let splitDetailHolder = NSView()
    private enum SplitEntry { case header(String); case item(ViewNode, Int) }
    private var splitData: [SplitEntry] = []
    private var splitItems: [ViewNode] = []
    private var splitSelected = 0
    private var lastSurfaceWasSplit = false
    private var splitEdgeConstraints: [NSLayoutConstraint] = []
    /// Master (left list) width. Clipboard/snippet rows (thumbnail + title) want the roomy 300; an
    /// extension's List.Item.Detail list (short labels, detail is the star) gets a narrower master so
    /// the detail pane gets the Raycast-style ~⅔ share instead of an even split.
    private var splitMasterWidthConstraint: NSLayoutConstraint!
    private let splitMasterWideWidth: CGFloat = 300
    private let splitMasterDetailWidth: CGFloat = 230
    private let loadingBar = LoadingBar()

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

        // Virtualized grid surface — its own scroll/collection view, shown only for grid surfaces.
        let layout = NSCollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = NSEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        collectionView.collectionViewLayout = layout
        collectionView.isSelectable = true
        collectionView.allowsEmptySelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.backgroundColors = [.clear]
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(GridItemView.self, forItemWithIdentifier: GridItemView.id)
        gridScroll.translatesAutoresizingMaskIntoConstraints = false
        gridScroll.drawsBackground = false
        gridScroll.hasVerticalScroller = true
        gridScroll.scrollerStyle = .overlay
        gridScroll.documentView = collectionView
        gridScroll.isHidden = true
        addSubview(gridScroll)
        let dbl = NSClickGestureRecognizer(target: self, action: #selector(gridDoubleClick(_:)))
        dbl.numberOfClicksRequired = 2
        dbl.delaysPrimaryMouseButtonEvents = false
        collectionView.addGestureRecognizer(dbl)
        NSLayoutConstraint.activate([
            gridScroll.topAnchor.constraint(equalTo: topAnchor),
            gridScroll.leadingAnchor.constraint(equalTo: leadingAnchor),
            gridScroll.trailingAnchor.constraint(equalTo: trailingAnchor),
            gridScroll.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        addSubview(loadingBar)
        loadingBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingBar.topAnchor.constraint(equalTo: topAnchor),
            loadingBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingBar.heightAnchor.constraint(equalToConstant: 2),
        ])

        // Virtualized list surface — view-based NSTableView, its own scroll view, shown only for plain
        // list surfaces. We draw the Raycast-style row highlight ourselves (selectionHighlightStyle .none)
        // and manage selection from the host's index, so clicks route through each row's ClickableRow.
        let listCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("row"))
        listCol.resizingMask = .autoresizingMask
        listTable.addTableColumn(listCol)
        listTable.headerView = nil
        listTable.backgroundColor = .clear
        listTable.selectionHighlightStyle = .none
        listTable.intercellSpacing = NSSize(width: 0, height: 3)
        listTable.gridStyleMask = []
        listTable.allowsEmptySelection = true
        listTable.refusesFirstResponder = true // arrow keys stay with the search field / host selection model
        listTable.dataSource = self
        listTable.delegate = self
        listScroll.translatesAutoresizingMaskIntoConstraints = false
        listScroll.drawsBackground = false
        listScroll.hasVerticalScroller = true
        listScroll.scrollerStyle = .overlay
        listScroll.documentView = listTable
        listScroll.isHidden = true
        addSubview(listScroll)
        NSLayoutConstraint.activate([
            listScroll.topAnchor.constraint(equalTo: topAnchor),
            listScroll.leadingAnchor.constraint(equalTo: leadingAnchor),
            listScroll.trailingAnchor.constraint(equalTo: trailingAnchor),
            listScroll.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        // Master-detail split surface: a fixed-width virtualized left table + a divider + the detail holder.
        let splitCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("split"))
        splitCol.resizingMask = .autoresizingMask
        splitTable.addTableColumn(splitCol)
        splitTable.headerView = nil
        splitTable.backgroundColor = .clear
        splitTable.selectionHighlightStyle = .none
        splitTable.intercellSpacing = NSSize(width: 0, height: 2)
        splitTable.gridStyleMask = []
        splitTable.allowsEmptySelection = true
        splitTable.refusesFirstResponder = true
        splitTable.dataSource = self
        splitTable.delegate = self
        splitLeftScroll.translatesAutoresizingMaskIntoConstraints = false
        splitLeftScroll.drawsBackground = false
        splitLeftScroll.hasVerticalScroller = true
        splitLeftScroll.scrollerStyle = .overlay
        splitLeftScroll.documentView = splitTable
        let splitDivider = NSBox()
        splitDivider.boxType = .separator
        splitDivider.translatesAutoresizingMaskIntoConstraints = false
        splitDetailHolder.translatesAutoresizingMaskIntoConstraints = false
        splitContainer.translatesAutoresizingMaskIntoConstraints = false
        splitContainer.addSubview(splitLeftScroll)
        splitContainer.addSubview(splitDivider)
        splitContainer.addSubview(splitDetailHolder)
        // splitContainer is attached to PaletteView ONLY while a split renders (attachSplit/detachSplit).
        // A permanently-pinned hidden container's edge constraints collapsed the root window's height.
        splitMasterWidthConstraint = splitLeftScroll.widthAnchor.constraint(equalToConstant: splitMasterWideWidth)
        NSLayoutConstraint.activate([
            splitLeftScroll.topAnchor.constraint(equalTo: splitContainer.topAnchor),
            splitLeftScroll.bottomAnchor.constraint(equalTo: splitContainer.bottomAnchor),
            splitLeftScroll.leadingAnchor.constraint(equalTo: splitContainer.leadingAnchor),
            splitMasterWidthConstraint,
            splitDivider.leadingAnchor.constraint(equalTo: splitLeftScroll.trailingAnchor),
            splitDivider.topAnchor.constraint(equalTo: splitContainer.topAnchor, constant: 8),
            splitDivider.bottomAnchor.constraint(equalTo: splitContainer.bottomAnchor, constant: -8),
            splitDivider.widthAnchor.constraint(equalToConstant: 1),
            splitDetailHolder.leadingAnchor.constraint(equalTo: splitDivider.trailingAnchor, constant: 12),
            splitDetailHolder.trailingAnchor.constraint(equalTo: splitContainer.trailingAnchor, constant: -12),
            splitDetailHolder.topAnchor.constraint(equalTo: splitContainer.topAnchor, constant: 8),
            splitDetailHolder.bottomAnchor.constraint(equalTo: splitContainer.bottomAnchor, constant: -8),
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
    /// `selectionOnly` is set by arrow-key navigation (the caller knows only the highlight moved). The
    /// grid/list/split fast paths require it — a content re-render (extension commit / search) reuses the
    /// SAME ViewTree instance (the reconciler mutates it in place), so tree identity alone can't tell a
    /// selection move from new content. Without this, a self-filtering List's search results never rebuild.
    public func render(_ tree: ViewTree, selectedIndex: Int, selectionOnly: Bool = false) -> Bool {
        // Fast path: same grid tree, only the selection changed → just move the collection-view selection
        // (no reload), keeping arrow navigation snappy on large grids.
        if selectionOnly, lastSurfaceWasGrid, tree === lastRenderedTree, !gridData.isEmpty {
            selectGridItem(selectedIndex, scroll: true)
            return false
        }
        // Fast path: same list tree, only the selection changed → reload just the old + new selected rows
        // (highlight follows) and scroll, instead of rebuilding the whole list on every arrow key.
        if selectionOnly, lastSurfaceWasList, tree === lastRenderedTree, !listData.isEmpty {
            selectListItem(selectedIndex, scroll: true)
            return false
        }
        // Fast path: same master-detail tree, selection changed → reload the old+new left rows and rebuild
        // only the detail pane, instead of rebuilding the whole split.
        if selectionOnly, lastSurfaceWasSplit, tree === lastRenderedTree, !splitData.isEmpty {
            selectSplitItem(selectedIndex)
            return false
        }
        // Fast path: a form re-rendered with the SAME structure (e.g. a keystroke firing onChange) →
        // update field values in place instead of tearing down + rebuilding, so the focused field keeps
        // its caret/scroll and there's no flicker. Falls through to a full rebuild if structure changed.
        if !selectionOnly, lastSurfaceWasForm, let form = tree.root.children.first(where: { $0.type == "form" }),
           reconcileFormInPlace(form) {
            lastRenderedTree = tree
            return false
        }
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        gridCells.removeAll()
        itemCounter = 0
        selectedRowView = nil
        let surfaces = tree.root.children
        lastRenderedTree = tree
        lastSurfaceWasGrid = surfaces.contains { $0.type == "grid" }
        // The virtualized grid/list live in their own scroll views; default to the stack surface and let
        // renderGrid / renderListVirtualized claim their own. (List visibility is set in renderListVirtualized.)
        lastSurfaceWasList = false
        listScroll.isHidden = true; listData = []
        lastSurfaceWasSplit = false
        lastSurfaceWasForm = false
        detachSplit(); splitData = []; splitItems = []
        if !lastSurfaceWasGrid { gridScroll.isHidden = true; scrollView.isHidden = false; gridData = [] }
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
                self.renderSplitVirtualized(list: list, selectedIndex: selectedIndex) // master–detail (Clipboard, List.Item.Detail)
            } else if surfaces.contains(where: { $0.type == "list" }) || tree.root.children.contains(where: { $0.type == "list" }) {
                // Root list + plain extension Lists → the virtualized table (constant height; don't shrink
                // for "No Results"). Master-detail lists take the renderSplit branch above.
                self.fixedHeightSurface = true
                self.renderListVirtualized(tree.root, selectedIndex: selectedIndex)
            } else {
                // Non-list fallback (compact root states with a few suggestion rows) — keep the stack.
                self.fixedHeightSurface = false
                self.appendRows(for: tree.root, selectedIndex: selectedIndex)
                self.scrollSelectedIntoView()
            }
        }) {
            renderErrorSurface(reason)
        }
        // Raycast's isLoading: thin sweep bar while any active surface is loading.
        if surfaces.contains(where: { Self.isTrue($0.props["isLoading"]) }) { loadingBar.start() } else { loadingBar.stop() }
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

    /// Attach the split container to PaletteView (pinned to its edges) only while a split is showing —
    /// keeping it permanently attached collapsed the root window's height even when hidden.
    private func attachSplit() {
        guard splitContainer.superview == nil else { return }
        addSubview(splitContainer)
        splitEdgeConstraints = [
            splitContainer.topAnchor.constraint(equalTo: topAnchor),
            splitContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            splitContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            splitContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]
        NSLayoutConstraint.activate(splitEdgeConstraints)
    }

    private func detachSplit() {
        guard splitContainer.superview != nil else { return }
        NSLayoutConstraint.deactivate(splitEdgeConstraints)
        splitEdgeConstraints = []
        splitContainer.removeFromSuperview()
    }

    /// Virtualized master-detail: flatten the list into an optional header + selectable items, show them
    /// in the persistent left table (only visible rows built), and render the selected item's detail pane.
    private func renderSplitVirtualized(list: ViewNode, selectedIndex: Int) {
        var items: [ViewNode] = []
        func collect(_ n: ViewNode) { if n.type == "list-item" { items.append(n) }; n.children.forEach(collect) }
        collect(list)
        splitItems = items
        var entries: [SplitEntry] = []
        if let section = list.children.first(where: { $0.type == "list-section" }), let t = section.title, !t.isEmpty {
            entries.append(.header(t))
        }
        for (i, node) in items.enumerated() { entries.append(.item(node, i)) }
        splitData = entries
        splitSelected = items.isEmpty ? 0 : max(0, min(selectedIndex, items.count - 1))
        // Extension List.Item.Detail (markdown/metadata detail) → give the detail the larger share.
        let isExtensionDetail = items.contains { $0.children.contains { $0.type == "list-item-detail" } }
        splitMasterWidthConstraint.constant = isExtensionDetail ? splitMasterDetailWidth : splitMasterWideWidth
        scrollView.isHidden = true
        gridScroll.isHidden = true
        listScroll.isHidden = true
        attachSplit()
        lastSurfaceWasSplit = true
        splitTable.reloadData()
        updateSplitDetail()
        if let r = splitTableRow(forItemIndex: splitSelected) { splitTable.scrollRowToVisible(r) }
    }

    /// Selection-only fast path for the split: reload just the old+new left rows (highlight follows) and
    /// rebuild only the detail pane.
    private func selectSplitItem(_ index: Int) {
        let oldRow = splitTableRow(forItemIndex: splitSelected)
        splitSelected = splitItems.isEmpty ? 0 : max(0, min(index, splitItems.count - 1))
        let newRow = splitTableRow(forItemIndex: splitSelected)
        var reload = IndexSet()
        if let oldRow { reload.insert(oldRow) }
        if let newRow { reload.insert(newRow) }
        if !reload.isEmpty { splitTable.reloadData(forRowIndexes: reload, columnIndexes: IndexSet(integer: 0)) }
        updateSplitDetail()
        if let newRow { splitTable.scrollRowToVisible(newRow) }
    }

    /// Rebuild the right detail pane for the current split selection and swap it into the holder.
    private func updateSplitDetail() {
        splitDetailHolder.subviews.forEach { $0.removeFromSuperview() }
        let node = (splitSelected >= 0 && splitSelected < splitItems.count) ? splitItems[splitSelected] : nil
        let detail = detailPane(node)
        splitDetailHolder.addSubview(detail)
        // An extension List.Item.Detail with markdown fills the pane height (see extensionDetailPane), so
        // pin its bottom to the holder to give it that height. Clipboard/snippet panes (fixed-height
        // preview + info block) keep hug-to-content so their layout is unchanged.
        let lid = node?.children.first(where: { $0.type == "list-item-detail" })
        let md = lid?.props["markdown"]?.stringValue ?? ""
        let fillsHeight = !md.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        NSLayoutConstraint.activate([
            detail.leadingAnchor.constraint(equalTo: splitDetailHolder.leadingAnchor),
            detail.trailingAnchor.constraint(equalTo: splitDetailHolder.trailingAnchor),
            detail.topAnchor.constraint(equalTo: splitDetailHolder.topAnchor),
            fillsHeight
                ? detail.bottomAnchor.constraint(equalTo: splitDetailHolder.bottomAnchor)
                : detail.bottomAnchor.constraint(lessThanOrEqualTo: splitDetailHolder.bottomAnchor),
        ])
    }

    private func splitTableRow(forItemIndex idx: Int) -> Int? {
        for (row, e) in splitData.enumerated() {
            if case .item(_, let i) = e, i == idx { return row }
        }
        return nil
    }

    private func makeSplitItemCell(_ node: ViewNode, selected: Bool, index: Int) -> NSView {
        let cell = ClickableRow()
        cell.translatesAutoresizingMaskIntoConstraints = true
        cell.autoresizingMask = [.width, .height]
        wireClick(cell, index: index)
        let bg = NSView()
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.wantsLayer = true
        bg.layer?.cornerRadius = 6
        bg.layer?.backgroundColor = selected ? NSColor.controlAccentColor.withAlphaComponent(0.20).cgColor : NSColor.clear.cgColor
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
        bg.addSubview(h)
        cell.addSubview(bg)
        NSLayoutConstraint.activate([
            bg.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 6),
            bg.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -4),
            bg.topAnchor.constraint(equalTo: cell.topAnchor, constant: 1),
            bg.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -1),
            h.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 8),
            h.trailingAnchor.constraint(lessThanOrEqualTo: bg.trailingAnchor, constant: -8),
            h.centerYAnchor.constraint(equalTo: bg.centerYAnchor),
        ])
        return cell
    }

    private func makeSplitHeaderCell(_ title: String) -> NSView {
        let cell = NSView()
        cell.translatesAutoresizingMaskIntoConstraints = true
        cell.autoresizingMask = [.width, .height]
        let label = NSTextField(labelWithString: title)
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 14),
            label.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -5),
        ])
        return cell
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

        var hasMarkdown = false
        if let md = node.props["markdown"]?.stringValue, !md.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            hasMarkdown = true
            let scroll = markdownScroll(md)
            stack.addArrangedSubview(scroll)
            scroll.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
            // Fill the available detail height — Raycast renders List.Item.Detail markdown full-height.
            // The old fixed 160px box jammed a long cheat sheet into a sliver, leaving the pane empty below.
            scroll.setContentHuggingPriority(.defaultLow, for: .vertical)
            scroll.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
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
            // When there's markdown, the stack fills the pane so the scroll can expand; otherwise it
            // hugs its (metadata-only) content at the top.
            hasMarkdown
                ? stack.bottomAnchor.constraint(equalTo: pane.bottomAnchor, constant: -12)
                : stack.bottomAnchor.constraint(lessThanOrEqualTo: pane.bottomAnchor, constant: -12),
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

    /// Render a grid into the virtualized NSCollectionView (only visible cells are built/recycled).
    private func renderGrid(_ grid: ViewNode, selectedIndex: Int) {
        var columns = 5
        if case .number(let n)? = grid.props["columns"] { columns = max(1, Int(n)) }
        var itemHeight: CGFloat = 72
        if case .number(let h)? = grid.props["itemHeight"] { itemHeight = CGFloat(h) }
        var items: [ViewNode] = []
        func collect(_ n: ViewNode) { if n.type == "grid-item" { items.append(n) }; n.children.forEach(collect) }
        collect(grid)
        gridData = items
        gridThumbHeight = itemHeight
        gridSelected = max(0, min(selectedIndex, items.count - 1))
        itemCounter = items.count

        // Fit exactly `columns` cells per row across the palette width (matches PaletteWindow's gridColumns
        // for 2-D arrow nav). itemSize = cell width × (thumb + title).
        let spacing: CGFloat = 8, sideInset: CGFloat = 12
        let paletteW = bounds.width > 50 ? bounds.width : 750 // fall back to the fixed palette width pre-layout
        let avail = paletteW - sideInset * 2 - spacing * CGFloat(columns - 1)
        let w = max(40, floor(avail / CGFloat(columns)))
        if let flow = collectionView.collectionViewLayout as? NSCollectionViewFlowLayout {
            flow.itemSize = NSSize(width: w, height: itemHeight + 26)
        }
        scrollView.isHidden = true
        gridScroll.isHidden = false
        collectionView.reloadData()
        selectGridItem(gridSelected, scroll: true)
    }

    /// Update the collection view's selected cell (highlight + scroll). Called by the render fast-path on
    /// arrow-key moves so selection changes don't rebuild the grid.
    private func selectGridItem(_ index: Int, scroll: Bool) {
        guard index >= 0, index < gridData.count else { return }
        gridSelected = index
        let ip = IndexPath(item: index, section: 0)
        collectionView.selectionIndexPaths = [ip]
        for vip in collectionView.indexPathsForVisibleItems() {
            (collectionView.item(at: vip) as? GridItemView)?.applySelected(vip == ip)
        }
        if scroll { collectionView.scrollToItems(at: [ip], scrollPosition: .centeredVertically) }
    }

    /// Build/recycle a grid cell's content (image + title), mirroring the per-cell logic the old
    /// stack-based grid used, but for a reused NSCollectionViewItem.
    private func configureGridItem(_ item: GridItemView, node: ViewNode) {
        item.label.stringValue = node.title ?? ""
        item.thumb.image = nil
        item.thumb.contentTintColor = nil
        item.thumb.identifier = nil
        if let b64 = node.props["thumb"]?.stringValue, let img = cachedImage(b64) {
            item.thumb.image = img
        } else if let p = fileIconPath(node.props["content"] ?? node.props["icon"]) {
            item.thumb.image = NSWorkspace.shared.icon(forFile: p) // Image.ImageLike { fileIcon }
        } else if let src = imageSource(node.props["content"] ?? node.props["icon"]) {
            if let img = loadLocalImage(src) { item.thumb.image = img }
            else if src.hasPrefix("http://") || src.hasPrefix("https://") { loadRemoteImage(src, into: item.thumb) }
            else if let sym = NSImage(systemSymbolName: src, accessibilityDescription: nil) ?? NSImage(systemSymbolName: sfSymbol(for: src), accessibilityDescription: nil) {
                item.thumb.image = sym; item.thumb.contentTintColor = .secondaryLabelColor
            }
        }
    }

    /// Extract a `fileIcon` path from an Image.ImageLike (`{ fileIcon }` or `{ value: { fileIcon } }`).
    private func fileIconPath(_ v: JSONValue?) -> String? {
        if case .object(let o)? = v {
            if case .string(let s)? = o["fileIcon"] { return (s as NSString).expandingTildeInPath }
            if case .object(let inner)? = o["value"], case .string(let s)? = inner["fileIcon"] { return (s as NSString).expandingTildeInPath }
        }
        return nil
    }

    // A double-click first single-selects (didSelectItemsAt updates gridSelected), then activates it.
    @objc private func gridDoubleClick(_ g: NSClickGestureRecognizer) { onActivate?(gridSelected) }

    // Bridges for the NSCollectionView data source / delegate (below) to PaletteView's private grid state.
    fileprivate func gridCount() -> Int { gridData.count }
    fileprivate func gridConfigure(_ item: GridItemView, at index: Int) {
        guard index >= 0, index < gridData.count else { return }
        configureGridItem(item, node: gridData[index])
        item.applySelected(index == gridSelected)
    }
    fileprivate func gridClicked(_ index: Int) { gridSelected = index; onSelect?(index) }

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
        if case .object(let o)? = v {
            if case .string(let s)? = o["source"] { return s }
            // Grid.Item / List.Item content can wrap the ImageLike: { value: <ImageLike>, tooltip }.
            if case .object(let inner)? = o["value"], case .string(let s)? = inner["source"] { return s }
            if case .string(let s)? = o["value"] { return s }
        }
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

    /// Shared session for remote images with a PERSISTENT on-disk HTTP cache (survives relaunch) and more
    /// concurrent connections — so a grid of hundreds of remote images (e.g. glyph-search) loads fast and
    /// is instant on the next launch, instead of N throttled refetches every time.
    private static let imageSession: URLSession = {
        let cfg = URLSessionConfiguration.default
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent("com.invoke.app/img", isDirectory: true)
        cfg.urlCache = URLCache(memoryCapacity: 32 * 1024 * 1024, diskCapacity: 256 * 1024 * 1024, directory: dir)
        cfg.requestCachePolicy = .returnCacheDataElseLoad // prefer the disk cache; only hit the network on a miss
        cfg.httpMaximumConnectionsPerHost = 12
        return URLSession(configuration: cfg)
    }()

    /// Load a remote http(s) image into an image view asynchronously. Decoded images are cached in memory
    /// by URL (grids re-render on every arrow keypress — don't re-decode), and the bytes are cached on disk
    /// by `imageSession` (don't re-download across renders/launches).
    private func loadRemoteImage(_ url: String, into iv: NSImageView) {
        if let cached = imageCache[url] { iv.image = cached; return }
        guard let u = URL(string: url) else { return }
        Self.imageSession.dataTask(with: u) { [weak self, weak iv] data, _, _ in
            guard let data, let img = NSImage(data: data) else { return }
            DispatchQueue.main.async {
                if self?.imageCache.count ?? 0 > 1000 { self?.imageCache.removeAll() }
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
    /// The palette's content/blur view — where a FormDropdown presents its popover so it floats above
    /// the form's scroll view (set by PaletteWindow, mirroring SearchBarDropdown.hostContentView).
    public weak var dropdownHostView: NSView?

    /// Form reconciliation: whether the last surface was a form, the ordered field signature (to detect a
    /// same-structure re-render), and per-field closures to apply a new node's value in place — so typing
    /// into a controlled field updates siblings WITHOUT tearing down + rebuilding the form each keystroke
    /// (which made the caret jump to the bottom and the screen flicker).
    private var lastSurfaceWasForm = false
    /// Per-field STRUCTURAL signatures (type/id/title/placeholder/label/description/error-presence +
    /// dropdown items) — everything EXCEPT live values. The reconcile fast path only fires when this is
    /// unchanged, so a different form (other extension, a pushed form) or a structural change (dropdown
    /// items appearing, a validation error) falls back to a full rebuild instead of a false in-place update.
    private var formStructure: [String] = []
    private var formApply: [String: (ViewNode) -> Void] = [:]
    /// Auto-grow: each textarea's height constraint keyed by the text view, so multiple textareas each grow
    /// with their own content (capped, then scroll).
    private var formTextareaHeights: [ObjectIdentifier: NSLayoutConstraint] = [:]
    private let formTextareaMinHeight: CGFloat = 150
    private let formTextareaMaxHeight: CGFloat = 300

    /// The field id of the form field that currently has focus (so a re-render can restore it instead of
    /// jumping back to the first field). For an NSTextField, the first responder is its field editor.
    private func focusedFormFieldId() -> String? {
        guard let fr = window?.firstResponder else { return nil }
        if let tv = fr as? NSTextView {
            if let info = formFieldInfo[ObjectIdentifier(tv)] { return info.id }   // a form-textarea (its own responder)
            if let tf = tv.delegate as? NSTextField { return formFieldInfo[ObjectIdentifier(tf)]?.id } // field editor of an NSTextField
            return nil
        }
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

    /// In-place form update for a same-structure re-render: update each controlled field's value from the
    /// new tree WITHOUT rebuilding the controls, and skip the field being edited so the caret/scroll don't
    /// jump. Returns false if the structure changed (field added/removed/reordered, or an error appeared/
    /// cleared) so the caller falls back to a full rebuild. This is what makes typing smooth.
    private func reconcileFormInPlace(_ form: ViewNode) -> Bool {
        let fieldTypes: Set<String> = ["form-textfield", "form-textarea", "form-checkbox", "form-dropdown", "form-description", "form-separator"]
        var fields: [ViewNode] = []
        func collect(_ n: ViewNode) {
            if fieldTypes.contains(n.type) { fields.append(n); return }
            n.children.forEach(collect)
        }
        collect(form)
        guard fields.count == formStructure.count else { return false }
        for (i, f) in fields.enumerated() where formFieldSignature(f) != formStructure[i] { return false }
        let focusedId = focusedFormFieldId()
        for f in fields {
            let id = f.props["id"]?.stringValue ?? ""
            if id == focusedId { continue } // don't clobber the field the user is typing into
            formApply[id]?(f)
        }
        return true
    }

    /// Structural fingerprint of a form field — everything that, if changed, means the form must be rebuilt
    /// rather than value-reconciled: type, id, the visible labels/placeholder, error presence, and (for a
    /// dropdown) its item set. Deliberately EXCLUDES `value`/`defaultValue` so a keystroke (value-only
    /// change) reconciles in place.
    private func formFieldSignature(_ f: ViewNode) -> String {
        var parts = [
            f.type,
            f.props["id"]?.stringValue ?? "",
            f.props["title"]?.stringValue ?? "",
            f.props["placeholder"]?.stringValue ?? "",
            f.props["label"]?.stringValue ?? "",
            f.props["text"]?.stringValue ?? "",                       // form-description body
            (f.props["error"]?.stringValue ?? "").isEmpty ? "" : "e", // error appeared/cleared → rebuild
        ]
        if f.type == "form-dropdown" {
            func items(_ n: ViewNode) {
                for c in n.children {
                    if c.type == "form-dropdown-item" {
                        parts.append("i:" + (c.props["value"]?.stringValue ?? "") + "=" + (c.props["title"]?.stringValue ?? ""))
                    } else if c.type == "form-dropdown-section" {
                        parts.append("s:" + (c.props["title"]?.stringValue ?? "")); items(c)
                    }
                }
            }
            items(f)
        }
        return parts.joined(separator: "\u{1}")
    }

    /// Grow a textarea to fit its content (Raycast-style), clamped between min and max; past the max it
    /// scrolls. Called as the user types so the box expands smoothly without a rebuild.
    private func growTextarea(_ tv: NSTextView) {
        guard let height = formTextareaHeights[ObjectIdentifier(tv)], let lm = tv.layoutManager, let tc = tv.textContainer else { return }
        lm.ensureLayout(for: tc)
        let used = lm.usedRect(for: tc).height + tv.textContainerInset.height * 2
        let clamped = max(formTextareaMinHeight, min(used, formTextareaMaxHeight))
        if abs(height.constant - clamped) > 0.5 { height.constant = clamped }
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
        formStructure.removeAll()
        formApply.removeAll()
        formTextareaHeights.removeAll()
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
            formStructure.append(formFieldSignature(f)) // for the same-structure reconcile fast path
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
        lastSurfaceWasForm = true // enable the same-structure reconcile fast path for the next re-render
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
        let title = f.props["title"]?.stringValue ?? ""
        // Vertical alignment of the label gutter vs. the control (used only when a gutter is shown).
        var rowAlignment: NSLayoutConstraint.Attribute = .firstBaseline

        let control: NSView
        switch f.type {
        case "form-textfield":
            // Seed from the node value, falling back to the value the user had typed before a re-render
            // (controlled forms don't echo edits back, so the node value can lag — preserve user input).
            let seeded = f.props["value"]?.stringValue ?? f.props["defaultValue"]?.stringValue ?? ""
            let tf = NSTextField(string: seeded.isEmpty ? (preservedFormValues[id] ?? "") : seeded)
            tf.placeholderString = f.props["placeholder"]?.stringValue
            // Borderless field inside a styled container (matching the dropdown/textarea tokens) instead
            // of the system rounded bezel, so all form controls share one look.
            tf.isBezeled = false
            tf.drawsBackground = false
            tf.focusRingType = .none
            tf.font = .systemFont(ofSize: 13)
            tf.textColor = .labelColor
            tf.translatesAutoresizingMaskIntoConstraints = false
            tf.target = self
            tf.action = #selector(formFieldEnter) // Return in a single-line field submits the form
            // Only Return fires the action — NOT Tab/click-away (end-editing), which would otherwise
            // submit the form and dismiss the palette when moving between fields.
            tf.cell?.sendsActionOnEndEditing = false
            let box = Self.styledFieldBox()
            box.addSubview(tf)
            NSLayoutConstraint.activate([
                box.heightAnchor.constraint(equalToConstant: 28),
                tf.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 9),
                tf.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -9),
                tf.centerYAnchor.constraint(equalTo: box.centerYAnchor),
            ])
            formControls.append((id, { [weak tf] in tf?.stringValue ?? "" }))
            tf.delegate = self // controlTextDidChange → live onChange
            formFieldInfo[ObjectIdentifier(tf)] = (id, f.props["onChange"]?.handlerRef)
            formFieldViewById[id] = tf
            if firstFormResponder == nil { firstFormResponder = tf }
            formResponderViews.append(tf)
            formApply[id] = { [weak tf] n in
                if let v = n.props["value"]?.stringValue, tf?.stringValue != v { tf?.stringValue = v }
            }
            control = box
            rowAlignment = .centerY
        case "form-textarea":
            let tv = PlaceholderTextView()
            tv.string = f.props["value"]?.stringValue ?? f.props["defaultValue"]?.stringValue ?? ""
            tv.placeholderText = f.props["placeholder"]?.stringValue ?? ""
            tv.isEditable = true
            tv.font = .systemFont(ofSize: 13)
            tv.textColor = .labelColor
            tv.backgroundColor = NSColor.controlColor.withAlphaComponent(0.45) // shared field fill token
            tv.insertionPointColor = .labelColor
            // Standard document-view-in-scrollview wiring so text wraps + scrolls correctly.
            tv.isVerticallyResizable = true
            tv.isHorizontallyResizable = false
            tv.autoresizingMask = [.width]
            tv.minSize = NSSize(width: 0, height: 0)
            tv.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            tv.textContainerInset = NSSize(width: 5, height: 7)
            tv.textContainer?.widthTracksTextView = true
            let s = NSScrollView()
            s.borderType = .noBorder // the layer draws the border (matches the dropdown/textfield tokens)
            s.drawsBackground = false
            s.hasVerticalScroller = true
            s.documentView = tv
            s.wantsLayer = true
            s.layer?.cornerRadius = 7
            s.layer?.masksToBounds = true
            s.layer?.borderWidth = 1
            s.layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.6).cgColor
            s.translatesAutoresizingMaskIntoConstraints = false
            // Moderate default height (Raycast shows a compact box when empty); it auto-grows with
            // content via growTextarea() as the user types, then scrolls past the cap.
            let taHeight = s.heightAnchor.constraint(equalToConstant: formTextareaMinHeight)
            taHeight.isActive = true
            formTextareaHeights[ObjectIdentifier(tv)] = taHeight
            formControls.append((id, { [weak tv] in tv?.string ?? "" }))
            tv.delegate = self // textDidChange → live onChange
            formFieldInfo[ObjectIdentifier(tv)] = (id, f.props["onChange"]?.handlerRef)
            formFieldViewById[id] = tv
            if firstFormResponder == nil { firstFormResponder = tv }
            formResponderViews.append(tv)
            formApply[id] = { [weak self, weak tv] n in
                guard let tv, let v = n.props["value"]?.stringValue, tv.string != v else { return }
                tv.string = v
                tv.needsDisplay = true
                self?.growTextarea(tv)
            }
            DispatchQueue.main.async { [weak self, weak tv] in if let tv { self?.growTextarea(tv) } } // size to initial content
            control = s
            rowAlignment = .top
        case "form-checkbox":
            // The checkbox carries its own label; the gutter title is usually empty (Raycast parity).
            let cb = NSButton(checkboxWithTitle: f.props["label"]?.stringValue ?? "", target: nil, action: nil)
            if case .bool(true)? = (f.props["value"] ?? f.props["defaultValue"]) { cb.state = .on } // honor defaultValue
            formControls.append((id, { [weak cb] in cb?.state == .on ? "true" : "false" }))
            formApply[id] = { [weak cb] n in
                if case .bool(let b)? = n.props["value"] { cb?.state = b ? .on : .off }
                else if let s = n.props["value"]?.stringValue { cb?.state = (s == "true") ? .on : .off } // string-encoded bool
            }
            control = cb
            rowAlignment = .firstBaseline
        case "form-dropdown":
            // World-class styled dropdown (FormDropdown) instead of the system NSPopUpButton — a pill
            // trigger + translucent keyboard-navigable popover, matching the search-bar dropdown.
            let dd = FormDropdown()
            dd.hostContentView = dropdownHostView
            // Flatten Form.Dropdown.Item / Form.Dropdown.Section children into items + (non-selectable)
            // section-header rows. Visible text is `title`; the SUBMITTED value is `value`.
            var ddItems: [FormDropdown.Item] = []
            func addItems(_ n: ViewNode) {
                for c in n.children {
                    if c.type == "form-dropdown-item" {
                        let title = c.props["title"]?.stringValue ?? c.props["value"]?.stringValue ?? ""
                        ddItems.append(FormDropdown.Item(title: title,
                                                         value: c.props["value"]?.stringValue ?? title,
                                                         iconPath: c.props["iconPath"]?.stringValue))
                    } else if c.type == "form-dropdown-section" {
                        if let t = c.props["title"]?.stringValue, !t.isEmpty {
                            ddItems.append(FormDropdown.Item(title: t, value: "", isHeader: true))
                        }
                        addItems(c)
                    }
                }
            }
            addItems(f)
            // Precedence: a controlled `value` wins; else the user's preserved pick (uncontrolled forms
            // don't echo changes back, so a non-empty defaultValue like "new" would otherwise revert the
            // selection every re-render); else `defaultValue`.
            let current = f.props["value"]?.stringValue
                ?? preservedFormValues[id]
                ?? f.props["defaultValue"]?.stringValue
                ?? ""
            let onChangeRef = f.props["onChange"]?.handlerRef
            dd.configure(items: ddItems, selected: current) { [weak self] value in
                if let h = onChangeRef { self?.onFormFieldChange?(h, value) }
            }
            formControls.append((id, { [weak dd] in dd?.selectedValue ?? "" }))
            formApply[id] = { [weak dd] n in
                if let v = n.props["value"]?.stringValue { dd?.setSelected(v) }
            }
            control = dd
            rowAlignment = .centerY
        default:
            return nil
        }
        control.translatesAutoresizingMaskIntoConstraints = false
        control.setContentHuggingPriority(.defaultLow, for: .horizontal) // let the control fill the row

        // Inline validation error (Raycast shows it in red under the field). useForm sets this on a
        // failed submit; without rendering it, Save "does nothing" with no feedback.
        let content: NSView
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
            content = col
        } else {
            content = control
        }

        // No title → the control spans the full row width (Raycast renders titleless fields full-width);
        // otherwise a fixed right-aligned label gutter on the left and the control filling the rest.
        if title.isEmpty { return content }
        let row = NSStackView()
        row.orientation = .horizontal
        row.spacing = 12
        row.distribution = .fill
        row.alignment = rowAlignment
        row.translatesAutoresizingMaskIntoConstraints = false
        let label = NSTextField(labelWithString: title)
        label.alignment = .right
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabelColor
        label.lineBreakMode = .byWordWrapping
        label.maximumNumberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        row.addArrangedSubview(label)
        label.widthAnchor.constraint(equalToConstant: 150).isActive = true
        row.addArrangedSubview(content)
        return row
    }

    /// A styled container for a single-line form field — the shared rounded fill+border token used by the
    /// dropdown and textarea, so all form controls read as one family (vs. the system rounded bezel).
    private static func styledFieldBox() -> NSView {
        let box = NSView()
        box.translatesAutoresizingMaskIntoConstraints = false
        box.wantsLayer = true
        box.layer?.cornerRadius = 7
        box.layer?.backgroundColor = NSColor.controlColor.withAlphaComponent(0.45).cgColor
        box.layer?.borderWidth = 1
        box.layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.6).cgColor
        return box
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

    /// The horizontal content of an item row (icon/glyph · title · subtitle · spacer · accessories),
    /// shared by the stack-based fallback (addItemRow) and the virtualized table cell (makeItemCell).
    private func itemRowContent(_ node: ViewNode, selected: Bool) -> NSStackView {
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
        return h
    }

    private func addItemRow(_ node: ViewNode, selected: Bool, index: Int) {
        let row = ClickableRow()
        wireClick(row, index: index)
        row.translatesAutoresizingMaskIntoConstraints = false
        row.wantsLayer = true
        row.layer?.cornerRadius = 7
        // Subtle translucent highlight (not saturated accent), text colors unchanged — matches the
        // Raycast row selection.
        row.layer?.backgroundColor = selected ? NSColor.white.withAlphaComponent(0.13).cgColor : NSColor.clear.cgColor
        let h = itemRowContent(node, selected: selected)
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

    // MARK: - Virtualized list (NSTableView)

    /// Build the flattened row model from the tree and reload the table. Only VISIBLE rows are built
    /// (tableView(_:viewFor:row:)), so a huge list is instant and arrow-nav uses the selection fast path.
    private func renderListVirtualized(_ root: ViewNode, selectedIndex: Int) {
        var entries: [ListEntry] = []
        var itemIdx = 0
        func walk(_ node: ViewNode) {
            switch node.type {
            case "list-section":
                if let t = node.title, !t.isEmpty { entries.append(.header(t)) }
                node.children.forEach(walk)
            case "list-item":
                if let cardVal = node.props["card"], case .object(let card) = cardVal,
                   node.props["display"]?.stringValue == "card" {
                    entries.append(.card(card, itemIdx))
                } else {
                    entries.append(.item(node, itemIdx))
                }
                itemIdx += 1
            default:
                node.children.forEach(walk)
            }
        }
        walk(root)
        listData = entries
        itemCounter = itemIdx
        listSelected = itemIdx == 0 ? 0 : max(0, min(selectedIndex, itemIdx - 1))
        scrollView.isHidden = true
        gridScroll.isHidden = true
        listScroll.isHidden = false
        lastSurfaceWasList = true
        listTable.reloadData()
        selectListItem(listSelected, scroll: true)
    }

    /// Selection-only fast path: reload just the previously- and newly-selected rows (their highlight is
    /// rebuilt with the right `selected` flag) and scroll the new one into view. No full rebuild.
    private func selectListItem(_ index: Int, scroll: Bool) {
        let oldRow = tableRow(forItemIndex: listSelected)
        listSelected = index
        let newRow = tableRow(forItemIndex: index)
        var reload = IndexSet()
        if let oldRow { reload.insert(oldRow) }
        if let newRow { reload.insert(newRow) }
        if !reload.isEmpty { listTable.reloadData(forRowIndexes: reload, columnIndexes: IndexSet(integer: 0)) }
        if scroll, let newRow { listTable.scrollRowToVisible(newRow) }
    }

    /// The table row holding a given selectable item index (skips section headers).
    private func tableRow(forItemIndex idx: Int) -> Int? {
        for (row, e) in listData.enumerated() {
            switch e {
            case .item(_, let i), .card(_, let i): if i == idx { return row }
            case .header: break
            }
        }
        return nil
    }

    /// Table-cell version of an item row: a full-width ClickableRow (height from heightOfRow) with an
    /// inset rounded highlight, reusing the shared content. Returned from tableView(_:viewFor:row:).
    private func makeItemCell(_ node: ViewNode, selected: Bool, index: Int) -> NSView {
        let cell = ClickableRow()
        cell.translatesAutoresizingMaskIntoConstraints = true
        cell.autoresizingMask = [.width, .height]
        wireClick(cell, index: index)
        let bg = NSView()
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.wantsLayer = true
        bg.layer?.cornerRadius = 7
        bg.layer?.backgroundColor = selected ? NSColor.white.withAlphaComponent(0.13).cgColor : NSColor.clear.cgColor
        let h = itemRowContent(node, selected: selected)
        bg.addSubview(h)
        cell.addSubview(bg)
        NSLayoutConstraint.activate([
            bg.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 8),
            bg.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -8),
            bg.topAnchor.constraint(equalTo: cell.topAnchor, constant: 1),
            bg.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -1),
            h.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 10),
            h.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -10),
            h.centerYAnchor.constraint(equalTo: bg.centerYAnchor),
        ])
        return cell
    }

    private func makeHeaderCell(_ title: String) -> NSView {
        let cell = NSView()
        cell.translatesAutoresizingMaskIntoConstraints = true
        cell.autoresizingMask = [.width, .height]
        let label = NSTextField(labelWithString: title)
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 18), // aligns with row content
            label.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -6),
        ])
        return cell
    }

    private func makeCardCell(_ card: [String: JSONValue], selected: Bool, index: Int) -> NSView {
        let cell = ClickableRow()
        cell.translatesAutoresizingMaskIntoConstraints = true
        cell.autoresizingMask = [.width, .height]
        wireClick(cell, index: index)
        let bg = NSView()
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.wantsLayer = true
        bg.layer?.cornerRadius = 12
        bg.layer?.backgroundColor = (selected ? NSColor.white.withAlphaComponent(0.10) : NSColor.white.withAlphaComponent(0.06)).cgColor
        let leftCol = valueColumn(value: card["left"]?.stringValue ?? "", label: card["leftLabel"]?.stringValue ?? "")
        let rightCol = valueColumn(value: card["right"]?.stringValue ?? "", label: card["rightLabel"]?.stringValue ?? "")
        let centerCol = centerColumn(note: card["note"]?.stringValue ?? "")
        let h = NSStackView(views: [leftCol, centerCol, rightCol])
        h.orientation = .horizontal; h.alignment = .centerY; h.distribution = .fill; h.spacing = 12
        h.translatesAutoresizingMaskIntoConstraints = false
        bg.addSubview(h)
        cell.addSubview(bg)
        NSLayoutConstraint.activate([
            bg.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 8),
            bg.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -8),
            bg.topAnchor.constraint(equalTo: cell.topAnchor, constant: 2),
            bg.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -2),
            h.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 16),
            h.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -16),
            h.centerYAnchor.constraint(equalTo: bg.centerYAnchor),
            leftCol.widthAnchor.constraint(equalTo: rightCol.widthAnchor),
        ])
        return cell
    }

    // MARK: - Helpers

    private func chip(_ text: String, color: NSColor? = nil) -> NSView {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = color ?? .secondaryLabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        let bg = NSView()
        bg.wantsLayer = true
        bg.layer?.cornerRadius = 6
        bg.layer?.backgroundColor = (color?.withAlphaComponent(0.18) ?? NSColor.white.withAlphaComponent(0.09)).cgColor
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

    private struct Accessory {
        var iconValue: JSONValue?   // an Image.ImageLike to render at 15pt
        var iconTint: NSColor?      // tintColor for an SF-symbol icon
        var label: String?          // resolved text/tag/date string
        var isTag: Bool = false     // true → chip; false → plain right-aligned label
        var color: NSColor?         // text color (label) / tint (tag)
        var tooltip: String?        // applied as the accessory view's toolTip
    }

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
        // Real app/file icon (full color) for application and file rows — a top-level appPath/fileIcon
        // prop, or an Image.ImageLike `{ fileIcon }` on the icon prop (Raycast's app/file icon form).
        if let path = node.props["appPath"]?.stringValue ?? node.props["fileIcon"]?.stringValue
            ?? fileIconPath(node.props["icon"]) {
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
        growTextarea(tv) // auto-grow as the user types (no-op for non-textarea views)
        if let h = info.onChange { onFormFieldChange?(h, tv.string) }
    }
}

// MARK: - Virtualized grid (NSCollectionView)

/// A recycled grid cell: a rounded thumbnail box + a centered title below it. The collection view builds
/// only the visible ones, so a 2,000+ item grid is instant. Content is filled by PaletteView.configureGridItem.
final class GridItemView: NSCollectionViewItem {
    static let id = NSUserInterfaceItemIdentifier("InvokeGridItem")
    let bg = NSView()
    let thumb = NSImageView()
    let label = NSTextField(labelWithString: "")

    override func loadView() {
        let root = NSView()
        bg.wantsLayer = true; bg.layer?.cornerRadius = 7; bg.translatesAutoresizingMaskIntoConstraints = false
        thumb.imageScaling = .scaleProportionallyUpOrDown; thumb.animates = true
        thumb.wantsLayer = true; thumb.layer?.cornerRadius = 6; thumb.layer?.masksToBounds = true
        thumb.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12); label.alignment = .center
        label.lineBreakMode = .byTruncatingTail; label.maximumNumberOfLines = 1
        label.textColor = .labelColor; label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        root.addSubview(bg); root.addSubview(label); bg.addSubview(thumb)
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: root.topAnchor),
            bg.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            thumb.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 8),
            thumb.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -8),
            thumb.topAnchor.constraint(equalTo: bg.topAnchor, constant: 8),
            thumb.bottomAnchor.constraint(equalTo: bg.bottomAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: bg.bottomAnchor, constant: 2),
            label.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 2),
            label.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -2),
            label.bottomAnchor.constraint(equalTo: root.bottomAnchor),
        ])
        view = root
        applySelected(false)
    }

    func applySelected(_ sel: Bool) {
        bg.layer?.backgroundColor = (sel ? NSColor.controlAccentColor.withAlphaComponent(0.20) : NSColor.gray.withAlphaComponent(0.12)).cgColor
        bg.layer?.borderWidth = sel ? 2 : 0
        bg.layer?.borderColor = NSColor.controlAccentColor.cgColor
    }
    override var isSelected: Bool { didSet { applySelected(isSelected) } }
    override func prepareForReuse() {
        super.prepareForReuse()
        thumb.image = nil; thumb.identifier = nil; thumb.contentTintColor = nil; label.stringValue = ""
        applySelected(false)
    }
}

extension PaletteView: NSTableViewDataSource, NSTableViewDelegate {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === splitTable ? splitData.count : listData.count
    }

    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView === splitTable {
            guard row < splitData.count else { return nil }
            switch splitData[row] {
            case .header(let title): return makeSplitHeaderCell(title)
            case .item(let node, let idx): return makeSplitItemCell(node, selected: idx == splitSelected, index: idx)
            }
        }
        guard row < listData.count else { return nil }
        switch listData[row] {
        case .header(let title): return makeHeaderCell(title)
        case .item(let node, let idx): return makeItemCell(node, selected: idx == listSelected, index: idx)
        case .card(let card, let idx): return makeCardCell(card, selected: idx == listSelected, index: idx)
        }
    }

    public func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if tableView === splitTable {
            guard row < splitData.count else { return 32 }
            if case .header = splitData[row] { return 28 }
            return 32
        }
        guard row < listData.count else { return 38 }
        switch listData[row] {
        case .header: return 30
        case .item: return 40
        case .card: return 96
        }
    }

    // We manage selection from the host's index model (custom highlight) — the table itself never selects.
    public func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool { false }
}

extension PaletteView: NSCollectionViewDataSource {
    public func collectionView(_ cv: NSCollectionView, numberOfItemsInSection section: Int) -> Int { gridCount() }
    public func collectionView(_ cv: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = cv.makeItem(withIdentifier: GridItemView.id, for: indexPath) as? GridItemView ?? GridItemView()
        gridConfigure(item, at: indexPath.item)
        return item
    }
}

extension PaletteView: NSCollectionViewDelegate {
    public func collectionView(_ cv: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let ip = indexPaths.first else { return }
        (cv.item(at: ip) as? GridItemView)?.applySelected(true)
        gridClicked(ip.item)
    }
    public func collectionView(_ cv: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        for ip in indexPaths { (cv.item(at: ip) as? GridItemView)?.applySelected(false) }
    }
}
