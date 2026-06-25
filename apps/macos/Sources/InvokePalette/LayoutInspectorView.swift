import AppKit
#if canImport(InvokeServices)
import InvokeServices
#endif

// MARK: - LayoutInspectorView

/// Right-pane inspector for the Window Layout Designer.
/// Sections (top-to-bottom): Name · App row · Size · Position (3×3 anchor grid) · Offset.
public final class LayoutInspectorView: NSView {

    // MARK: - Public API

    public var mode: DesignerMode = .layout {
        didSet { updateAppRowVisibility() }
    }

    /// Callbacks — fired on user interaction only (NEVER during `load` / seeding).
    public var onNameChange:      ((String) -> Void)?
    public var onAppChange:       ((String) -> Void)?
    public var onPlacementChange: ((WindowPlacement) -> Void)?
    public var onDelete:          (() -> Void)?

    /// Seeds all controls from the given values.
    /// Programmatic seeding does NOT fire any callbacks (guarded by `isSeeding`).
    public func load(
        name:        String,
        item:        DesignerItem?,
        runningApps: [(bundleId: String, name: String, iconPath: String?)]
    ) {
        isSeeding = true
        defer { isSeeding = false }

        currentItem        = item
        currentRunningApps = runningApps

        // Name
        nameField.stringValue = name

        // App popup
        populateAppPopup(runningApps: runningApps, selectedBundleId: item?.bundleId)
        updateAppRowVisibility()

        // Placement controls
        let p = item?.placement ?? .default
        currentPlacement = p
        seedSizeFields(p)
        seedAnchorButtons(p.anchor)
        seedOffsetFields(p)
    }

    // MARK: - Init

    public override init(frame: NSRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Internal State

    private var isSeeding          = false
    private var currentPlacement   = WindowPlacement.default
    private var currentItem:        DesignerItem?
    private var currentRunningApps: [(bundleId: String, name: String, iconPath: String?)] = []

    // MARK: - Subviews

    // Name section
    private let nameLabel = LayoutInspectorView.makeLabel("Name")
    private let nameField = LayoutInspectorView.makeTextField(placeholder: "Rule name…")

    // App row
    private let appRowContainer = NSView()
    private let appPopup        = NSPopUpButton(frame: .zero, pullsDown: false)
    private let deleteButton: NSButton = {
        let img = NSImage(systemSymbolName: "trash", accessibilityDescription: "Delete") ?? NSImage()
        let btn = NSButton(image: img, target: nil, action: nil)
        btn.bezelStyle      = .rounded
        btn.isBordered      = true
        btn.controlSize     = .regular
        btn.imagePosition   = .imageOnly
        btn.contentTintColor = .systemRed
        btn.toolTip         = "Delete this window rule"
        return btn
    }()

    // Size section
    private let sizeHeader    = LayoutInspectorView.makeSectionHeader("Size")
    private let widthLabel    = LayoutInspectorView.makeLabel("W:")
    private let widthField    = LayoutInspectorView.makeTextField(placeholder: "Auto")
    private let widthPtLabel  = LayoutInspectorView.makeLabel("pt")
    private let heightLabel   = LayoutInspectorView.makeLabel("H:")
    private let heightField   = LayoutInspectorView.makeTextField(placeholder: "Auto")
    private let heightPtLabel = LayoutInspectorView.makeLabel("pt")

    // Position section
    private let positionHeader = LayoutInspectorView.makeSectionHeader("Position")
    /// 9 buttons — index == Anchor.rawValue (row-major: 0=topLeft … 8=bottomRight).
    private var anchorButtons: [NSButton] = []

    // Offset section
    private let offsetHeader   = LayoutInspectorView.makeSectionHeader("Offset")
    private let offsetXLabel   = LayoutInspectorView.makeLabel("X:")
    private let offsetXField   = LayoutInspectorView.makeTextField(placeholder: "0")
    private let offsetXPtLabel = LayoutInspectorView.makeLabel("pt")
    private let offsetYLabel   = LayoutInspectorView.makeLabel("Y:")
    private let offsetYField   = LayoutInspectorView.makeTextField(placeholder: "0")
    private let offsetYPtLabel = LayoutInspectorView.makeLabel("pt")

    // MARK: - Setup

    private func setup() {
        wantsLayer = true

        // Name
        nameField.delegate = self
        addSubview(nameLabel)
        addSubview(nameField)

        // App row
        appRowContainer.wantsLayer = true
        appPopup.bezelStyle  = .rounded
        appPopup.controlSize = .regular
        appPopup.font        = .systemFont(ofSize: 12)
        appPopup.target = self
        appPopup.action = #selector(appPopupChanged(_:))
        appRowContainer.addSubview(appPopup)
        deleteButton.target = self
        deleteButton.action = #selector(deleteTapped)
        appRowContainer.addSubview(deleteButton)
        addSubview(appRowContainer)

        // Size
        widthField.delegate  = self
        heightField.delegate = self
        for v in [sizeHeader, widthLabel, widthField, widthPtLabel,
                  heightLabel, heightField, heightPtLabel] as [NSView] {
            addSubview(v)
        }

        // Position (9 anchor buttons — SF Symbol per anchor)
        let symbols = [
            "arrow.up.left",           "arrow.up",    "arrow.up.right",
            "arrow.left",              "smallcircle.filled.circle", "arrow.right",
            "arrow.down.left",         "arrow.down",  "arrow.down.right"
        ]
        anchorButtons = symbols.enumerated().map { idx, sym in
            let img = NSImage(systemSymbolName: sym,
                              accessibilityDescription: Anchor(rawValue: idx)?.accessibilityLabel) ?? NSImage()
            let btn = NSButton(image: img, target: self, action: #selector(anchorTapped(_:)))
            btn.bezelStyle = .rounded
            btn.isBordered = true
            btn.wantsLayer = true
            btn.tag        = idx
            return btn
        }
        addSubview(positionHeader)
        anchorButtons.forEach { addSubview($0) }

        // Offset
        offsetXField.delegate = self
        offsetYField.delegate = self
        for v in [offsetHeader, offsetXLabel, offsetXField, offsetXPtLabel,
                  offsetYLabel, offsetYField, offsetYPtLabel] as [NSView] {
            addSubview(v)
        }

        // Seed anchor highlight default
        highlightAnchorButton(.center)
    }

    // MARK: - Layout

    private let hPad:        CGFloat = 16
    private let sectionGap:  CGFloat = 16
    private let rowH:        CGFloat = 22
    private let headerH:     CGFloat = 14
    private let shortLabelW: CGFloat = 18   // "W:" / "H:" / "X:" / "Y:"
    private let ptLabelW:    CGFloat = 18
    private let fieldW:      CGFloat = 64

    public override func layout() {
        super.layout()
        let w = bounds.width
        var y: CGFloat = 12
        let contentW = w - hPad * 2

        // ── Name ────────────────────────────────────────────────────
        nameLabel.frame = NSRect(x: hPad, y: y, width: contentW, height: headerH)
        y += headerH + 4
        nameField.frame = NSRect(x: hPad, y: y, width: contentW, height: rowH)
        y += rowH + sectionGap

        // ── App row ─────────────────────────────────────────────────
        let deleteW: CGFloat = 28
        let popupW = contentW - deleteW - 6
        appRowContainer.frame = NSRect(x: hPad, y: y, width: contentW, height: rowH)
        appPopup.frame    = NSRect(x: 0, y: 0, width: popupW, height: rowH)
        deleteButton.frame = NSRect(x: popupW + 6, y: 0, width: deleteW, height: rowH)
        if !appRowContainer.isHidden {
            y += rowH + sectionGap
        }

        // ── Size ─────────────────────────────────────────────────────
        sizeHeader.frame = NSRect(x: hPad, y: y, width: contentW, height: headerH)
        y += headerH + 4

        // W row
        widthLabel.frame  = NSRect(x: hPad, y: y, width: shortLabelW, height: rowH)
        widthField.frame  = NSRect(x: hPad + shortLabelW + 4, y: y, width: fieldW, height: rowH)
        widthPtLabel.frame = NSRect(x: hPad + shortLabelW + 4 + fieldW + 4, y: y, width: ptLabelW, height: rowH)
        y += rowH + 4

        // H row
        heightLabel.frame  = NSRect(x: hPad, y: y, width: shortLabelW, height: rowH)
        heightField.frame  = NSRect(x: hPad + shortLabelW + 4, y: y, width: fieldW, height: rowH)
        heightPtLabel.frame = NSRect(x: hPad + shortLabelW + 4 + fieldW + 4, y: y, width: ptLabelW, height: rowH)
        y += rowH + sectionGap

        // ── Position (3×3 grid) ──────────────────────────────────────
        positionHeader.frame = NSRect(x: hPad, y: y, width: contentW, height: headerH)
        y += headerH + 4

        let cellSize: CGFloat = 28
        let gridGap:  CGFloat = 3
        for idx in 0..<9 {
            let col = idx % 3
            let row = idx / 3
            let bx = hPad + CGFloat(col) * (cellSize + gridGap)
            let by = y    + CGFloat(row) * (cellSize + gridGap)
            anchorButtons[idx].frame = NSRect(x: bx, y: by, width: cellSize, height: cellSize)
        }
        y += cellSize * 3 + gridGap * 2 + sectionGap

        // ── Offset ───────────────────────────────────────────────────
        offsetHeader.frame = NSRect(x: hPad, y: y, width: contentW, height: headerH)
        y += headerH + 4

        // X row
        offsetXLabel.frame  = NSRect(x: hPad, y: y, width: shortLabelW, height: rowH)
        offsetXField.frame  = NSRect(x: hPad + shortLabelW + 4, y: y, width: fieldW, height: rowH)
        offsetXPtLabel.frame = NSRect(x: hPad + shortLabelW + 4 + fieldW + 4, y: y, width: ptLabelW, height: rowH)
        y += rowH + 4

        // Y row
        offsetYLabel.frame  = NSRect(x: hPad, y: y, width: shortLabelW, height: rowH)
        offsetYField.frame  = NSRect(x: hPad + shortLabelW + 4, y: y, width: fieldW, height: rowH)
        offsetYPtLabel.frame = NSRect(x: hPad + shortLabelW + 4 + fieldW + 4, y: y, width: ptLabelW, height: rowH)
    }

    // MARK: - Actions

    @objc private func appPopupChanged(_ sender: NSPopUpButton) {
        guard !isSeeding else { return }
        let idx = sender.indexOfSelectedItem
        guard idx >= 0, idx < currentRunningApps.count else { return }
        onAppChange?(currentRunningApps[idx].bundleId)
    }

    @objc private func deleteTapped() {
        guard !isSeeding else { return }
        onDelete?()
    }

    @objc private func anchorTapped(_ sender: NSButton) {
        guard !isSeeding else { return }
        guard let anchor = Anchor(rawValue: sender.tag) else { return }
        currentPlacement.anchor = anchor
        highlightAnchorButton(anchor)
        onPlacementChange?(currentPlacement)
    }

    // MARK: - Seeding

    private func seedSizeFields(_ p: WindowPlacement) {
        widthField.stringValue  = sizingString(p.width)
        heightField.stringValue = sizingString(p.height)
    }

    private func seedAnchorButtons(_ anchor: Anchor) {
        highlightAnchorButton(anchor)
    }

    private func seedOffsetFields(_ p: WindowPlacement) {
        offsetXField.stringValue = p.offsetX == 0 ? "" : formatDouble(p.offsetX)
        offsetYField.stringValue = p.offsetY == 0 ? "" : formatDouble(p.offsetY)
    }

    private func sizingString(_ s: Sizing) -> String {
        switch s {
        case .auto:          return ""
        case .points(let v): return formatDouble(v)
        }
    }

    private func formatDouble(_ v: Double) -> String {
        v == v.rounded() ? "\(Int(v))" : "\(v)"
    }

    // MARK: - Highlight

    private func highlightAnchorButton(_ anchor: Anchor) {
        for btn in anchorButtons {
            let selected = (btn.tag == anchor.rawValue)
            if selected {
                btn.contentTintColor  = .controlAccentColor
                btn.layer?.borderWidth  = 1.5
                btn.layer?.borderColor  = NSColor.controlAccentColor.cgColor
                btn.layer?.cornerRadius = 4
            } else {
                btn.contentTintColor = .secondaryLabelColor
                btn.layer?.borderWidth = 0
            }
        }
    }

    // MARK: - App Popup

    private func populateAppPopup(
        runningApps: [(bundleId: String, name: String, iconPath: String?)],
        selectedBundleId: String?
    ) {
        appPopup.removeAllItems()
        for app in runningApps {
            let item = NSMenuItem(title: app.name, action: nil, keyEquivalent: "")
            if let path = app.iconPath {
                let icon = NSWorkspace.shared.icon(forFile: path)
                icon.size = NSSize(width: 16, height: 16)
                item.image = icon
            }
            item.representedObject = app.bundleId
            appPopup.menu?.addItem(item)
        }
        if let bid = selectedBundleId,
           let idx = runningApps.firstIndex(where: { $0.bundleId == bid }) {
            appPopup.selectItem(at: idx)
        } else if !runningApps.isEmpty {
            appPopup.selectItem(at: 0)
        }
    }

    // MARK: - Visibility

    private func updateAppRowVisibility() {
        let hide = (mode == .singleWindow) || (currentItem == nil)
        appRowContainer.isHidden = hide
        needsLayout = true
    }

    // MARK: - Parsing

    private func parseSizing(_ text: String) -> Sizing {
        let t = text.trimmingCharacters(in: .whitespaces)
        if t.isEmpty || t.lowercased() == "auto" { return .auto }
        return Double(t).map { .points($0) } ?? .auto
    }

    private func parseOffset(_ text: String) -> Double {
        Double(text.trimmingCharacters(in: .whitespaces)) ?? 0
    }

    // MARK: - Static Factories

    private static func makeLabel(_ text: String) -> NSTextField {
        let tf = NSTextField(labelWithString: text)
        tf.font            = .systemFont(ofSize: 11, weight: .medium)
        tf.textColor       = .secondaryLabelColor
        tf.isEditable      = false
        tf.isSelectable    = false
        tf.isBezeled       = false
        tf.drawsBackground = false
        return tf
    }

    private static func makeSectionHeader(_ text: String) -> NSTextField {
        let tf = NSTextField(labelWithString: text.uppercased())
        tf.font            = .systemFont(ofSize: 10, weight: .semibold)
        tf.textColor       = .tertiaryLabelColor
        tf.isEditable      = false
        tf.isSelectable    = false
        tf.isBezeled       = false
        tf.drawsBackground = false
        return tf
    }

    private static func makeTextField(placeholder: String) -> NSTextField {
        let tf = NSTextField()
        tf.placeholderString = placeholder
        tf.font              = .systemFont(ofSize: 12)
        tf.bezelStyle        = .roundedBezel
        tf.isBezeled         = true
        tf.isEditable        = true
        tf.isSelectable      = true
        return tf
    }
}

// MARK: - NSTextFieldDelegate

extension LayoutInspectorView: NSTextFieldDelegate {
    public func controlTextDidChange(_ obj: Notification) {
        guard !isSeeding, let field = obj.object as? NSTextField else { return }

        if field === nameField {
            onNameChange?(field.stringValue)
            return
        }
        if field === widthField || field === heightField {
            currentPlacement.width  = parseSizing(widthField.stringValue)
            currentPlacement.height = parseSizing(heightField.stringValue)
            onPlacementChange?(currentPlacement)
            return
        }
        if field === offsetXField || field === offsetYField {
            currentPlacement.offsetX = parseOffset(offsetXField.stringValue)
            currentPlacement.offsetY = parseOffset(offsetYField.stringValue)
            onPlacementChange?(currentPlacement)
            return
        }
    }

    public func controlTextDidEndEditing(_ obj: Notification) {
        // Normalise sizing on blur: "auto"/"" stays empty; number stays as typed.
        guard !isSeeding, let field = obj.object as? NSTextField else { return }
        if field === widthField || field === heightField {
            if case .auto = parseSizing(field.stringValue) { field.stringValue = "" }
        }
    }
}

// MARK: - Anchor helpers

private extension Anchor {
    var accessibilityLabel: String {
        switch self {
        case .topLeft:     return "Top Left"
        case .top:         return "Top"
        case .topRight:    return "Top Right"
        case .left:        return "Left"
        case .center:      return "Center"
        case .right:       return "Right"
        case .bottomLeft:  return "Bottom Left"
        case .bottom:      return "Bottom"
        case .bottomRight: return "Bottom Right"
        }
    }
}
