import AppKit
#if canImport(InvokeServices)
import InvokeServices
#endif

// MARK: - LayoutDesignerWindow

/// Two-pane modal designer for Window Layout and Single-Window commands.
/// Owns `name`, `items`, and `selected` state; wires LayoutPreviewView (left)
/// ↔ LayoutInspectorView (right). Call `present(...)` to show it.
public final class LayoutDesignerWindow: NSObject {

    // MARK: - Strong reference (prevents dealloc while shown)

    private static var current: LayoutDesignerWindow?

    // MARK: - Public entry point

    /// Present the two-pane designer modally.
    ///
    /// - Parameters:
    ///   - mode:        `.layout` (multi-app) or `.singleWindow`.
    ///   - title:       Window title, e.g. "Create Window Layout".
    ///   - name:        Initial command/layout name.
    ///   - items:       Pre-seeded `DesignerItem` list.
    ///   - runningApps: Apps available in the App dropdown.
    ///   - onSave:      Called with the final (name, items) when user presses Save.
    ///   - onCancel:    Called when user presses Cancel or Esc.
    public static func present(
        mode:        DesignerMode,
        title:       String,
        name:        String,
        items:       [DesignerItem],
        runningApps: [(bundleId: String, name: String, iconPath: String?)],
        onSave:      @escaping (String, [DesignerItem]) -> Void,
        onCancel:    @escaping () -> Void
    ) {
        // Dismiss any existing designer first.
        current?.dismiss(save: false)

        let designer = LayoutDesignerWindow(
            mode:        mode,
            title:       title,
            name:        name,
            items:       items,
            runningApps: runningApps,
            onSave:      onSave,
            onCancel:    onCancel
        )
        current = designer
        designer.show()
    }

    // MARK: - Private state

    private let mode:        DesignerMode
    private var name:        String
    private var items:       [DesignerItem]
    private var selected:    Int
    private let runningApps: [(bundleId: String, name: String, iconPath: String?)]
    private let onSave:      (String, [DesignerItem]) -> Void
    private let onCancel:    () -> Void

    // MARK: - Views

    private var panel:    NSPanel!
    private var preview:  LayoutPreviewView!
    private var inspector: LayoutInspectorView!
    private var saveButton: NSButton!
    private var cancelButton: NSButton!

    // MARK: - Init

    private init(
        mode:        DesignerMode,
        title:       String,
        name:        String,
        items:       [DesignerItem],
        runningApps: [(bundleId: String, name: String, iconPath: String?)],
        onSave:      @escaping (String, [DesignerItem]) -> Void,
        onCancel:    @escaping () -> Void
    ) {
        self.mode        = mode
        self.name        = name
        self.runningApps = runningApps
        self.onSave      = onSave
        self.onCancel    = onCancel

        // Seed items — for .singleWindow, ensure exactly one item.
        if mode == .singleWindow {
            if items.isEmpty {
                // Seed a placeholder item targeting nothing (focused window on run).
                let placeholder = DesignerItem(
                    bundleId:  "",
                    appName:   "",
                    appPath:   nil,
                    placement: .default
                )
                self.items = [placeholder]
            } else {
                self.items = [items[0]]
            }
        } else {
            self.items = items
        }

        // Selected: -1 when empty (layout), or 0 when we have items.
        self.selected = self.items.isEmpty ? -1 : 0

        super.init()

        buildPanel(title: title)
        wireCallbacks()
        refreshAll()
    }

    // MARK: - Panel construction

    private func buildPanel(title: String) {
        let panelW: CGFloat = 900
        let panelH: CGFloat = 560

        // Plain titled panel, SIZE-LOCKED. (Earlier flags — .fullSizeContentView + .nonactivatingPanel
        // + no size lock — collapsed the window into a thin full-width strip and blocked keyboard focus.)
        let panel = NSPanel(
            contentRect:  NSRect(x: 0, y: 0, width: panelW, height: panelH),
            styleMask:    [.titled],
            backing:      .buffered,
            defer:        false
        )
        panel.title             = title
        panel.level             = .modalPanel
        panel.isMovableByWindowBackground = true
        panel.hidesOnDeactivate = false
        panel.setContentSize(NSSize(width: panelW, height: panelH))
        panel.minSize           = NSSize(width: panelW, height: panelH)
        panel.maxSize           = NSSize(width: panelW, height: panelH)
        self.panel = panel

        let contentView = panel.contentView!
        contentView.wantsLayer = true

        // ── Left pane: LayoutPreviewView ────────────────────────────────
        let preview = LayoutPreviewView(frame: .zero)
        preview.translatesAutoresizingMaskIntoConstraints = false
        self.preview = preview

        // ── Separator ──────────────────────────────────────────────────
        let separator = NSBox()
        separator.boxType = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false

        // ── Right pane: LayoutInspectorView ────────────────────────────
        let inspector = LayoutInspectorView(frame: .zero)
        inspector.mode = mode
        inspector.translatesAutoresizingMaskIntoConstraints = false
        self.inspector = inspector

        // ── Bottom bar: Cancel + Save ───────────────────────────────────
        let bottomBar = NSView()
        bottomBar.translatesAutoresizingMaskIntoConstraints = false

        let cancelBtn = NSButton(title: "Cancel", target: self, action: #selector(cancelTapped))
        cancelBtn.bezelStyle = .rounded
        cancelBtn.keyEquivalent = "\u{1b}"   // Esc
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        self.cancelButton = cancelBtn

        let saveBtn = NSButton(title: "Save", target: self, action: #selector(saveTapped))
        saveBtn.bezelStyle = .rounded
        saveBtn.keyEquivalent = "\r"          // Return / ⏎
        saveBtn.keyEquivalentModifierMask = .command
        saveBtn.hasDestructiveAction = false
        saveBtn.translatesAutoresizingMaskIntoConstraints = false
        self.saveButton = saveBtn

        bottomBar.addSubview(cancelBtn)
        bottomBar.addSubview(saveBtn)

        contentView.addSubview(preview)
        contentView.addSubview(separator)
        contentView.addSubview(inspector)
        contentView.addSubview(bottomBar)

        let inspectorW: CGFloat = 340
        let bottomBarH: CGFloat = 48
        let btnH:       CGFloat = 30
        let btnW:       CGFloat = 80

        NSLayoutConstraint.activate([
            // Bottom bar — pinned to bottom of content
            bottomBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: bottomBarH),

            // Cancel button — right-anchored, then Save to its right
            saveBtn.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16),
            saveBtn.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            saveBtn.widthAnchor.constraint(equalToConstant: btnW),
            saveBtn.heightAnchor.constraint(equalToConstant: btnH),

            cancelBtn.trailingAnchor.constraint(equalTo: saveBtn.leadingAnchor, constant: -8),
            cancelBtn.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            cancelBtn.widthAnchor.constraint(equalToConstant: btnW),
            cancelBtn.heightAnchor.constraint(equalToConstant: btnH),

            // Inspector — right pane, fixed width, above bottom bar
            inspector.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            inspector.topAnchor.constraint(equalTo: contentView.topAnchor),
            inspector.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),
            inspector.widthAnchor.constraint(equalToConstant: inspectorW),

            // Separator — 1pt divider between preview and inspector
            separator.trailingAnchor.constraint(equalTo: inspector.leadingAnchor),
            separator.topAnchor.constraint(equalTo: contentView.topAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),
            separator.widthAnchor.constraint(equalToConstant: 1),

            // Preview — fills the rest of the width, above bottom bar
            preview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            preview.trailingAnchor.constraint(equalTo: separator.leadingAnchor),
            preview.topAnchor.constraint(equalTo: contentView.topAnchor),
            preview.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),
        ])

        // Center on screen
        panel.center()
    }

    // MARK: - Callback wiring

    private func wireCallbacks() {
        // Preview: user clicked a window rect
        preview.onSelect = { [weak self] idx in
            guard let self else { return }
            self.selected = idx
            self.refreshInspector()
            self.preview.selected = idx
        }

        // Preview: user tapped "+ Add" (layout mode only)
        if mode == .layout {
            preview.onAdd = { [weak self] in
                guard let self else { return }
                self.addNextApp()
            }
        } else {
            // .singleWindow: suppress the Add button
            preview.onAdd = nil
            preview.showsAddButton = false
        }

        // Inspector: name field changed
        inspector.onNameChange = { [weak self] newName in
            self?.name = newName
            self?.updateSaveButtonState()
        }

        // Inspector: app selection changed
        inspector.onAppChange = { [weak self] newBundleId in
            guard let self, self.selected >= 0, self.selected < self.items.count else { return }
            if let app = self.runningApps.first(where: { $0.bundleId == newBundleId }) {
                self.items[self.selected].bundleId = app.bundleId
                self.items[self.selected].appName  = app.name
                self.items[self.selected].appPath  = app.iconPath
            }
            self.preview.items = self.items
        }

        // Inspector: placement changed (size / anchor / offset)
        inspector.onPlacementChange = { [weak self] newPlacement in
            guard let self, self.selected >= 0, self.selected < self.items.count else { return }
            self.items[self.selected].placement = newPlacement
            self.preview.items = self.items
        }

        // Inspector: delete the selected item
        inspector.onDelete = { [weak self] in
            guard let self, self.selected >= 0, self.selected < self.items.count else { return }
            self.items.remove(at: self.selected)
            // Reselect: prefer the same index, else last item, else -1.
            if self.items.isEmpty {
                self.selected = -1
            } else {
                self.selected = min(self.selected, self.items.count - 1)
            }
            self.refreshAll()
        }
    }

    // MARK: - Show / Dismiss

    private func show() {
        // Force an explicit centered frame — size-lock alone wasn't holding (window rendered as a thin
        // full-width strip). setFrame sets the WHOLE window frame (incl. titlebar).
        let w: CGFloat = 900, h: CGFloat = 588 // 560 content + ~28 titlebar
        if let vis = NSScreen.main?.visibleFrame {
            let x = vis.minX + (vis.width - w) / 2
            let y = vis.minY + (vis.height - h) / 2
            panel.setFrame(NSRect(x: x, y: y, width: w, height: h), display: true)
        }
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        NSLog("[invoke:designer] after show: panel.frame=\(NSStringFromRect(panel.frame)) content=\(NSStringFromRect(panel.contentView?.frame ?? .zero)) preview=\(NSStringFromRect(preview?.frame ?? .zero)) inspector=\(NSStringFromRect(inspector?.frame ?? .zero)) screen=\(NSStringFromRect(NSScreen.main?.frame ?? .zero))")
    }

    private func dismiss(save: Bool) {
        panel.orderOut(nil)
        if save {
            onSave(name, items)
        } else {
            onCancel()
        }
        // Release the strong reference.
        LayoutDesignerWindow.current = nil
    }

    // MARK: - Button actions

    @objc private func saveTapped() {
        guard isValid() else {
            NSSound.beep()
            return
        }
        dismiss(save: true)
    }

    @objc private func cancelTapped() {
        dismiss(save: false)
    }

    // MARK: - Validation

    private func isValid() -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        switch mode {
        case .layout:
            return !trimmedName.isEmpty && !items.isEmpty
        case .singleWindow:
            return !trimmedName.isEmpty
        }
    }

    private func updateSaveButtonState() {
        // Visual feedback: dim Save when invalid.
        saveButton.alphaValue = isValid() ? 1.0 : 0.45
    }

    // MARK: - State helpers

    /// Refresh both panes from current state.
    private func refreshAll() {
        preview.items    = items
        preview.selected = selected
        refreshInspector()
        updateSaveButtonState()
    }

    /// Push current selected item + name into the inspector.
    private func refreshInspector() {
        let item: DesignerItem? = (selected >= 0 && selected < items.count) ? items[selected] : nil
        inspector.load(name: name, item: item, runningApps: runningApps)
    }

    // MARK: - Add next app

    /// Append the first running app not already in `items`; select it.
    private func addNextApp() {
        let existingBundleIds = Set(items.map { $0.bundleId })
        guard let app = runningApps.first(where: { !existingBundleIds.contains($0.bundleId) }) else {
            NSSound.beep()
            return
        }
        let newItem = DesignerItem(
            bundleId:  app.bundleId,
            appName:   app.name,
            appPath:   app.iconPath,
            placement: .default
        )
        items.append(newItem)
        selected = items.count - 1
        refreshAll()
    }
}
