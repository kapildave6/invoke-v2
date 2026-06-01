import AppKit
import ApplicationServices
import InvokeServices
import SwiftUI

/// Lightweight metadata for a command row in the Commands tab.
public struct CommandInfo: Identifiable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let icon: String        // SF Symbol
    public let supportsBinding: Bool // false for the calculator (a typed-fallback, not a runnable command)
    public init(id: String, title: String, subtitle: String, icon: String = "command", supportsBinding: Bool = true) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.supportsBinding = supportsBinding
    }
}

/// An extension (group) owning one or more commands — the unit Raycast shows as a disclosure row.
public struct ExtensionGroup: Identifiable {
    public let id: String
    public let name: String
    public let icon: String
    public let commands: [CommandInfo]
    public init(id: String, name: String, icon: String, commands: [CommandInfo]) {
        self.id = id; self.name = name; self.icon = icon; self.commands = commands
    }
}

/// A colored rounded-tile command icon (white glyph), matching the palette's command tiles — colored
/// stably per group so Settings and the palette agree.
struct CommandTileIcon: View {
    let symbol: String
    let colorKey: String
    var size: CGFloat = 20
    private static let tones: [Color] = [.blue, .red, .orange, .purple, .green, .teal, .pink, .indigo, .brown]
    private var color: Color {
        var h: UInt64 = 5381
        for b in colorKey.utf8 { h = (h &* 33) &+ UInt64(b) } // djb2 — same keying as PaletteView
        return Self.tones[Int(h % UInt64(Self.tones.count))]
    }
    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.25, style: .continuous)
            .fill(color)
            .frame(width: size, height: size)
            .overlay(Image(systemName: symbol).font(.system(size: size * 0.55, weight: .semibold)).foregroundColor(.white))
    }
}

/// Settings panes (PLAN.md §6). Hosted individually by SettingsWindow inside an NSTabViewController
/// with the native `.toolbar` tab style (icon + label, like macOS System Settings / Raycast).
/// Panes FILL the window (the window sets the size) — pinning a fixed width clipped the content.

struct GeneralPane: View {
    @ObservedObject var settings = AppSettings.shared
    var body: some View {
        Form {
            Toggle("Launch Invoke at login", isOn: $settings.launchAtLogin)
            Section("Hotkeys") {
                LabeledContent("Summon Invoke", value: "⌥Space")
                LabeledContent("Clipboard History", value: "⌘⇧V")
                LabeledContent("Window — left / right / maximize", value: "⌃⌥← / → / ↑")
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 540, maxWidth: .infinity, minHeight: 380, maxHeight: .infinity)
    }
}

/// Commands tab — commands grouped under their parent extension (Raycast parity): a multi-command
/// extension is a collapsible disclosure row; a single-command extension is one top-level row.
/// Columns: Name · Type · Alias · Hotkey · Enabled. Alias and hotkey are per command and functional
/// (the alias surfaces the command when typed in the root; the hotkey is a real global shortcut).
struct CommandsPane: View {
    @ObservedObject var settings = AppSettings.shared
    let groups: [ExtensionGroup]
    let prefGroups: [ExtensionPrefGroup]
    /// Called after an enable/disable or hotkey change so the controller re-registers global hotkeys.
    let onBindingsChanged: () -> Void
    let onClearClipboard: () -> Void

    @State private var expanded: Set<String> = []
    @State private var search = ""
    @State private var selection: String?  // selected command or group id → drives the detail panel

    private var filtered: [ExtensionGroup] {
        let q = search.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return groups }
        return groups.compactMap { g in
            if g.name.lowercased().contains(q) { return g }
            let kids = g.commands.filter { $0.title.lowercased().contains(q) }
            return kids.isEmpty ? nil : ExtensionGroup(id: g.id, name: g.name, icon: g.icon, commands: kids)
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary).font(.caption)
                    // Down from the search field jumps into the (focusable) list; type to filter.
                    TextField("Search commands", text: $search).textFieldStyle(.plain)
                        .focused($focus, equals: .search)
                        .onKeyPress(.downArrow) { focus = .list; if selection == nil { moveSelection(1) }; return .handled }
                }
                .padding(.horizontal, 12).padding(.vertical, 7)
                Divider()
                columnHeader
                Divider()
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filtered) { group in
                                if group.commands.count > 1 {
                                    groupRow(group).id(group.id)
                                    if expanded.contains(group.id) {
                                        ForEach(group.commands) { commandRow($0, indented: true, groupKey: group.name).id($0.id) }
                                    }
                                } else if let only = group.commands.first {
                                    commandRow(only, indented: false, type: "Command", groupKey: group.name).id(only.id)
                                }
                            }
                        }
                    }
                    .onChange(of: selection) { _, sel in
                        if let sel { withAnimation(.easeOut(duration: 0.12)) { proxy.scrollTo(sel, anchor: .center) } }
                    }
                }
                // The list (not the search field) handles arrow navigation — a focused TextField's
                // field editor swallows arrow keys, so onKeyPress there never fires.
                .focusable()
                .focusEffectDisabled()
                .focused($focus, equals: .list)
                .onKeyPress(.upArrow) { moveSelection(-1); return .handled }
                .onKeyPress(.downArrow) { moveSelection(1); return .handled }
                .onKeyPress(.rightArrow) { expandSelected(true); return .handled }
                .onKeyPress(.leftArrow) { expandSelected(false); return .handled }
            }
            .frame(minWidth: 560, maxWidth: .infinity)
            Divider()
            CommandDetailPane(selection: selection, groups: groups, prefGroups: prefGroups, onBindingsChanged: onBindingsChanged, onClearClipboard: onClearClipboard)
                .frame(width: 340)
        }
        .frame(minWidth: 920, maxWidth: .infinity, minHeight: 380, maxHeight: .infinity)
        .onAppear {
            if selection == nil { selection = visibleIds.first }
            DispatchQueue.main.async { focus = .list } // focus the list so arrows work immediately
        }
    }

    private enum FocusField { case search, list }
    @FocusState private var focus: FocusField?

    /// True when the row at `id` is the selected one (drives the row highlight).
    private func isSelected(_ id: String) -> Bool { selection == id }

    // MARK: - Keyboard navigation

    /// The row ids currently visible, in display order (groups + their expanded children).
    private var visibleIds: [String] {
        var ids: [String] = []
        for g in filtered {
            if g.commands.count > 1 {
                ids.append(g.id)
                if expanded.contains(g.id) { ids.append(contentsOf: g.commands.map { $0.id }) }
            } else if let only = g.commands.first {
                ids.append(only.id)
            }
        }
        return ids
    }

    private func moveSelection(_ delta: Int) {
        let ids = visibleIds
        guard !ids.isEmpty else { return }
        let cur = selection.flatMap { ids.firstIndex(of: $0) } ?? (delta > 0 ? -1 : 0)
        selection = ids[max(0, min(ids.count - 1, cur + delta))]
    }

    private func expandSelected(_ expand: Bool) {
        guard let sel = selection, filtered.contains(where: { $0.id == sel && $0.commands.count > 1 }) else { return }
        if expand { expanded.insert(sel) } else { expanded.remove(sel) }
    }

    // MARK: - Column layout (shared by header + rows)

    private let typeW: CGFloat = 120
    private let aliasW: CGFloat = 140
    private let hotkeyW: CGFloat = 170
    private let enabledW: CGFloat = 72

    private var columnHeader: some View {
        HStack(spacing: 0) {
            Text("Name").frame(maxWidth: .infinity, alignment: .leading)
            Text("Type").frame(width: typeW, alignment: .leading)
            Text("Alias").frame(width: aliasW, alignment: .leading)
            Text("Hotkey").frame(width: hotkeyW, alignment: .leading)
            Text("Enabled").frame(width: enabledW, alignment: .center)
        }
        .font(.caption).foregroundColor(.secondary)
        .padding(.horizontal, 16).padding(.vertical, 6)
    }

    // MARK: - Rows

    private func groupRow(_ group: ExtensionGroup) -> some View {
        let allOn = group.commands.allSatisfy { settings.isEnabled($0.id) }
        let anyOn = group.commands.contains { settings.isEnabled($0.id) }
        let symbol = allOn ? "checkmark.square.fill" : (anyOn ? "minus.square.fill" : "square")
        return HStack(spacing: 0) {
            HStack(spacing: 6) {
                Button { toggleExpanded(group.id) } label: {
                    Image(systemName: expanded.contains(group.id) ? "chevron.down" : "chevron.right")
                        .font(.caption2).foregroundColor(.secondary).frame(width: 12)
                }.buttonStyle(.plain)
                CommandTileIcon(symbol: group.icon, colorKey: group.name)
                Text(group.name).fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text("Extension").foregroundColor(.secondary).frame(width: typeW, alignment: .leading)
            Text("—").foregroundColor(.secondary).frame(width: aliasW, alignment: .leading)
            Text("—").foregroundColor(.secondary).frame(width: hotkeyW, alignment: .leading)
            // Tri-state: ✓ all enabled · – mixed · ☐ none. Click enables-all (from mixed/none) or
            // disables-all (from all) — no longer misrepresents a mixed group as plain OFF.
            Button {
                let target = !allOn
                group.commands.forEach { settings.setEnabled($0.id, target) }
                onBindingsChanged()
            } label: {
                Image(systemName: symbol).foregroundColor(anyOn ? .accentColor : .secondary)
            }
            .buttonStyle(.borderless)
            .frame(width: enabledW, alignment: .center)
        }
        .padding(.horizontal, 16).padding(.vertical, 8)
        .background(isSelected(group.id) ? Color.accentColor.opacity(0.15) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture { selection = group.id }
    }

    private func commandRow(_ c: CommandInfo, indented: Bool, type: String = "Command", groupKey: String) -> some View {
        HStack(spacing: 0) {
            HStack(spacing: 6) {
                // Reserve the disclosure-chevron slot (12pt) so a standalone command's icon lines up
                // with a group's icon; indented children sit one icon-width further right.
                Color.clear.frame(width: 12, height: 1)
                CommandTileIcon(symbol: c.icon, colorKey: groupKey)
                Text(c.title)
                if !c.subtitle.isEmpty && !indented {
                    Text(c.subtitle).foregroundColor(.secondary).font(.callout)
                }
            }
            .padding(.leading, indented ? 24 : 0)
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(type).foregroundColor(.secondary).frame(width: typeW, alignment: .leading)

            // Alias
            Group {
                if c.supportsBinding {
                    AliasField(commandId: c.id)
                } else {
                    Text("—").foregroundColor(.secondary)
                }
            }.frame(width: aliasW, alignment: .leading)

            // Hotkey
            Group {
                if c.supportsBinding {
                    HStack(spacing: 4) {
                        HotkeyRecorder(combo: Binding(
                            get: { settings.hotkey(for: c.id) },
                            set: { settings.setHotkey(c.id, $0); onBindingsChanged() }
                        ))
                        if settings.hotkey(for: c.id) != nil {
                            Button {
                                settings.setHotkey(c.id, nil); onBindingsChanged()
                            } label: { Image(systemName: "xmark.circle.fill") }
                                .buttonStyle(.borderless).foregroundColor(.secondary)
                        }
                    }
                } else {
                    Text("—").foregroundColor(.secondary)
                }
            }.frame(width: hotkeyW, alignment: .leading)

            Toggle("", isOn: Binding(
                get: { settings.isEnabled(c.id) },
                set: { settings.setEnabled(c.id, $0); onBindingsChanged() }
            )).labelsHidden().toggleStyle(.checkbox).frame(width: enabledW, alignment: .center)
        }
        .padding(.horizontal, 16).padding(.vertical, 7)
        .background(isSelected(c.id) ? Color.accentColor.opacity(0.15) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture { selection = c.id }
    }

    private func toggleExpanded(_ id: String) {
        if expanded.contains(id) { expanded.remove(id) } else { expanded.insert(id) }
    }
}

/// The right-hand detail panel for the Commands tab (Raycast parity): shows the selected command's or
/// extension's icon, name, type, and — for extensions that declare preferences — those preference
/// fields inline, so configuration lives next to the list instead of in a separate tab.
struct CommandDetailPane: View {
    let selection: String?
    let groups: [ExtensionGroup]
    let prefGroups: [ExtensionPrefGroup]
    let onBindingsChanged: () -> Void
    let onClearClipboard: () -> Void
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        Group {
            if let info = resolved {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 10) {
                            CommandTileIcon(symbol: info.icon, colorKey: info.colorKey, size: 30)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(info.title).font(.headline)
                                Text(info.type).font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(16)
                        Divider()

                        if !info.description.isEmpty {
                            section("Description") {
                                Text(info.description).font(.callout).fixedSize(horizontal: false, vertical: true)
                            }
                            Divider()
                        }

                        if info.supportsBinding {
                            section("Keyboard") {
                                LabeledRow("Alias") { AliasField(commandId: info.id).frame(maxWidth: 150) }
                                LabeledRow("Hotkey") {
                                    HotkeyRecorder(combo: Binding(
                                        get: { settings.hotkey(for: info.id) },
                                        set: { settings.setHotkey(info.id, $0); onBindingsChanged() }
                                    ))
                                }
                            }
                            Divider()
                        }

                        if info.isClipboard {
                            // Clipboard settings live in the command's detail now (no separate tab).
                            section("Clipboard") {
                                Picker("History size", selection: $settings.clipboardLimit) {
                                    Text("25 items").tag(25); Text("50 items").tag(50)
                                    Text("100 items").tag(100); Text("250 items").tag(250)
                                }
                                Button("Clear Clipboard History", role: .destructive, action: onClearClipboard)
                                Text("History is kept in memory only — no plaintext on disk until the encrypted store ships.")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                            Divider()
                        }

                        if !info.fields.isEmpty {
                            section("Preferences") { prefsView(info.fields, extID: info.prefExtID) }
                            Divider()
                        }

                        if !info.capabilities.isEmpty {
                            section("Capabilities") {
                                ForEach(info.capabilities) { cap in
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(cap.title).fontWeight(.medium)
                                        if !cap.description.isEmpty {
                                            Text(cap.description).font(.caption).foregroundColor(.secondary)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            Divider()
                        }

                        if !info.commands.isEmpty {
                            section("Commands") {
                                ForEach(info.commands) { c in
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(c.title).fontWeight(.medium)
                                        if !c.description.isEmpty {
                                            Text(c.description).font(.caption).foregroundColor(.secondary)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        Spacer(minLength: 0)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "sidebar.right").font(.system(size: 26)).foregroundColor(.secondary)
                    Text("Select a command").foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.4))
    }

    /// Render preference fields with Raycast-style section headers (a pref's `title` starts a group;
    /// checkboxes show their `label`).
    @ViewBuilder private func prefsView(_ fields: [ExtensionPreference], extID: String) -> some View {
        ForEach(fields) { f in
            if !f.title.isEmpty {
                Text(f.title).font(.caption).foregroundColor(.secondary).padding(.top, 2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if f.type == "checkbox" { CheckboxPref(extID: extID, pref: f) }
            else { PrefField(extID: extID, pref: f) }
        }
    }

    @ViewBuilder private func section<C: View>(_ title: String, @ViewBuilder _ content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased()).font(.caption2).foregroundColor(.secondary)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
    }

    private struct LabeledRow<C: View>: View {
        let label: String; let content: C
        init(_ label: String, @ViewBuilder _ content: () -> C) { self.label = label; self.content = content() }
        var body: some View {
            HStack { Text(label).foregroundColor(.secondary); Spacer(); content }
        }
    }

    /// Resolve the selected id (a command or an extension) to all the manifest detail to display.
    private struct Info {
        let id: String; let title: String; let icon: String; let type: String
        let supportsBinding: Bool; let colorKey: String
        let description: String; let fields: [ExtensionPreference]; let prefExtID: String
        let capabilities: [ExtensionCapability]; let commands: [ExtensionCommandDetail]; let isClipboard: Bool
    }
    private var resolved: Info? {
        guard let sel = selection else { return nil }
        // Extension (group) selected → its description, extension-level prefs, capabilities, command list.
        if let g = groups.first(where: { $0.id == sel }) {
            let pg = prefGroup(forGroupOrCommand: sel)
            return Info(id: sel, title: g.name, icon: g.icon, type: "Extension", supportsBinding: false, colorKey: g.name,
                        description: pg?.description ?? "", fields: pg?.fields ?? [], prefExtID: pg?.id ?? sel,
                        capabilities: pg?.capabilities ?? [], commands: pg?.commands ?? [], isClipboard: false)
        }
        // Command selected → its own description + command-level prefs.
        for g in groups {
            if let c = g.commands.first(where: { $0.id == sel }) {
                let pg = prefGroup(forGroupOrCommand: sel)
                let cname = sel.split(separator: ".").last.map(String.init) ?? sel
                let cd = pg?.commands.first { $0.id == cname }
                return Info(id: c.id, title: c.title, icon: c.icon, type: "Command", supportsBinding: c.supportsBinding, colorKey: g.name,
                            description: cd?.description ?? "", fields: cd?.fields ?? [], prefExtID: pg?.id ?? g.id,
                            capabilities: [], commands: [], isClipboard: c.id == "clipboard.history")
            }
        }
        return nil
    }

    /// Match the extension preference group: group ids are "ext.<key>", command ids "ext.<key>.<cmd>";
    /// preference-group ids are the bare "<key>".
    private func prefGroup(forGroupOrCommand id: String) -> ExtensionPrefGroup? {
        guard id.hasPrefix("ext.") else { return nil }
        let key = id.dropFirst(4).split(separator: ".").first.map(String.init) ?? String(id.dropFirst(4))
        return prefGroups.first { $0.id == key }
    }
}

/// An alias field that edits a LOCAL buffer and commits (trim + lowercase + uniqueness) only on
/// Enter or focus loss. Committing inside the binding on every keystroke fought the caret, blocked
/// uppercase/trailing-space input, and clobbered other rows' aliases mid-typing.
private struct AliasField: View {
    let commandId: String
    @ObservedObject private var settings = AppSettings.shared
    @State private var text = ""
    @FocusState private var focused: Bool

    var body: some View {
        TextField("Add Alias", text: $text)
            .textFieldStyle(.plain).font(.callout)
            .focused($focused)
            .onAppear { text = settings.alias(for: commandId) ?? "" }
            .onSubmit { commit() }
            .onChange(of: focused) { _, now in if !now { commit() } }
            .onChange(of: settings.alias(for: commandId)) { _, new in
                if !focused { text = new ?? "" } // reflect external changes (uniqueness displacement)
            }
    }

    private func commit() {
        settings.setAlias(commandId, text.isEmpty ? nil : text)
        text = settings.alias(for: commandId) ?? "" // show the normalized (lowercased) value
    }
}

struct ClipboardPane: View {
    @ObservedObject var settings = AppSettings.shared
    let onClear: () -> Void
    var body: some View {
        Form {
            Section {
                Picker("History size", selection: $settings.clipboardLimit) {
                    Text("25 items").tag(25)
                    Text("50 items").tag(50)
                    Text("100 items").tag(100)
                    Text("250 items").tag(250)
                }
                Button("Clear Clipboard History", role: .destructive, action: onClear)
            } footer: {
                Text("History is kept in memory only — no plaintext on disk until the encrypted store ships.")
                    .font(.caption).foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 540, maxWidth: .infinity, minHeight: 380, maxHeight: .infinity)
    }
}

struct AdvancedPane: View {
    @ObservedObject var settings = AppSettings.shared
    @State private var axGranted = AXIsProcessTrusted()
    @State private var aiKey = ""
    @State private var aiKeyStored = AIService.hasStoredKey()
    @State private var aiSaved = false
    var body: some View {
        Form {
            Section {
                LabeledContent("Accessibility") {
                    HStack(spacing: 10) {
                        Text(axGranted ? "Granted" : "Not granted")
                            .foregroundColor(axGranted ? .green : .orange)
                        Button("Open Settings…") {
                            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                                NSWorkspace.shared.open(url)
                            }
                        }
                        Button("Recheck") { axGranted = AXIsProcessTrusted() }
                    }
                }
            } header: {
                Text("Permissions")
            } footer: {
                Text("Required to paste clipboard/emoji into apps and to move windows.")
                    .font(.caption).foregroundColor(.secondary)
            }
            Section("Emoji") {
                Picker("Default skin tone", selection: $settings.emojiSkinTone) {
                    Text("👋  Default").tag(0)
                    Text("👋🏻  Light").tag(1)
                    Text("👋🏼  Medium-Light").tag(2)
                    Text("👋🏽  Medium").tag(3)
                    Text("👋🏾  Medium-Dark").tag(4)
                    Text("👋🏿  Dark").tag(5)
                }
            }
            Section {
                SecureField("Enter your Anthropic API key", text: $aiKey).onSubmit(saveAIKey)
                HStack {
                    Button("Save Key", action: saveAIKey).disabled(aiKey.isEmpty || AIService.usingEnvKey())
                    if aiKeyStored && !AIService.usingEnvKey() {
                        Button("Remove", role: .destructive) { AIService.clearStoredKey(); aiKey = ""; aiKeyStored = false; aiSaved = false }
                    }
                    Spacer()
                    Text(aiStatus).font(.caption).foregroundColor(aiKeyStored ? .green : .secondary)
                }
                Link("Get an Anthropic API key", destination: URL(string: "https://console.anthropic.com/settings/keys")!).font(.caption)
            } header: {
                Text("AI")
            } footer: {
                Text("Powers the AI commands (Improve Writing, Ask AI). Stored in your macOS Keychain — never in plaintext. An ANTHROPIC_API_KEY environment variable, if set, takes precedence.")
                    .font(.caption).foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 540, maxWidth: .infinity, minHeight: 380, maxHeight: .infinity)
    }

    private var aiStatus: String {
        if AIService.usingEnvKey() { return "Using ANTHROPIC_API_KEY (env)" }
        if aiSaved { return "Saved ✓" }
        return aiKeyStored ? "Key configured ✓" : "No key set"
    }

    private func saveAIKey() {
        let key = aiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else { return }
        AIService.storeAPIKey(key)
        aiKey = "" // never keep or re-display the key
        aiKeyStored = true
        aiSaved = true
    }
}

struct AboutPane: View {
    var body: some View {
        VStack(spacing: 12) {
            if let logo = Brand.logo {
                Image(nsImage: logo).resizable().scaledToFit().frame(width: 240)
            } else {
                Image(systemName: "command.square.fill")
                    .resizable().frame(width: 72, height: 72).foregroundColor(.accentColor)
                Text("Invoke").font(.title.bold())
            }
            Text("Version 0.1 (dev)").foregroundColor(.secondary)
            Text("A keyboard-first command palette — a Raycast-style launcher.\nPersonal project.")
                .multilineTextAlignment(.center).foregroundColor(.secondary).font(.callout)
            Button("View on GitHub") {
                if let url = URL(string: "https://github.com/kapildave6/invoke-v2") { NSWorkspace.shared.open(url) }
            }
            .padding(.top, 4)
        }
        .frame(minWidth: 540, maxWidth: .infinity, minHeight: 380, maxHeight: .infinity)
    }
}

// MARK: - Snippets

/// Master–detail CRUD for snippets: a list on the left (+/- to add/remove), an editor on the right.
/// The editor edits a local @State copy (re-seeded per selection via `.id`) and writes back on each
/// change — so typing never fights the caret, and the list/palette update from the store.
struct SnippetsPane: View {
    @ObservedObject private var store = SnippetStore.shared
    @State private var selectedId: String?

    private var selected: Snippet? { store.snippets.first { $0.id == selectedId } }

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                List(selection: $selectedId) {
                    ForEach(store.snippets) { s in
                        VStack(alignment: .leading, spacing: 1) {
                            Text(s.name.isEmpty ? "Untitled Snippet" : s.name).lineLimit(1)
                            if !s.keyword.isEmpty { Text(s.keyword).font(.caption).foregroundColor(.secondary) }
                        }.tag(s.id)
                    }
                }
                listToolbar(add: addSnippet, remove: deleteSelected, canRemove: selectedId != nil)
            }
            .frame(width: 200)
            Divider()
            Group {
                if let snip = selected {
                    SnippetEditor(snippet: snip) { store.update($0) }.id(snip.id)
                } else {
                    placeholderPane("Select a snippet, or add one with +")
                }
            }
        }
        .frame(minWidth: 600, maxWidth: .infinity, minHeight: 380, maxHeight: .infinity)
        .onAppear { if selectedId == nil { selectedId = store.snippets.first?.id } }
    }

    private func addSnippet() { selectedId = store.add(Snippet(name: "New Snippet")).id }
    private func deleteSelected() {
        guard let id = selectedId, let idx = store.snippets.firstIndex(where: { $0.id == id }) else { return }
        store.delete(id: id)
        selectedId = store.snippets.isEmpty ? nil : store.snippets[min(idx, store.snippets.count - 1)].id
    }
}

private struct SnippetEditor: View {
    let snippet: Snippet
    let onChange: (Snippet) -> Void
    @State private var name = ""
    @State private var keyword = ""
    @State private var content = ""

    var body: some View {
        Form {
            TextField("Name", text: $name).onChange(of: name) { _, _ in commit() }
            TextField("Keyword (optional)", text: $keyword).onChange(of: keyword) { _, _ in commit() }
            Section("Content") {
                TextEditor(text: $content)
                    .font(.system(size: 13, design: .monospaced))
                    .frame(minHeight: 150)
                    .onChange(of: content) { _, _ in commit() }
            }
        }
        .formStyle(.grouped)
        .onAppear { name = snippet.name; keyword = snippet.keyword; content = snippet.content }
    }

    private func commit() { onChange(Snippet(id: snippet.id, name: name, keyword: keyword, content: content)) }
}

// MARK: - Quicklinks

struct QuicklinksPane: View {
    @ObservedObject private var store = QuicklinkStore.shared
    @State private var selectedId: String?

    private var selected: Quicklink? { store.quicklinks.first { $0.id == selectedId } }

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                List(selection: $selectedId) {
                    ForEach(store.quicklinks) { q in
                        VStack(alignment: .leading, spacing: 1) {
                            Text(q.name.isEmpty ? "Untitled" : q.name).lineLimit(1)
                            Text(q.link).font(.caption).foregroundColor(.secondary).lineLimit(1)
                        }.tag(q.id)
                    }
                }
                listToolbar(add: addQuicklink, remove: deleteSelected, canRemove: selectedId != nil)
            }
            .frame(width: 200)
            Divider()
            Group {
                if let q = selected {
                    QuicklinkEditor(quicklink: q) { store.update($0) }.id(q.id)
                } else {
                    placeholderPane("Select a quicklink, or add one with +")
                }
            }
        }
        .frame(minWidth: 600, maxWidth: .infinity, minHeight: 380, maxHeight: .infinity)
        .onAppear { if selectedId == nil { selectedId = store.quicklinks.first?.id } }
    }

    private func addQuicklink() { selectedId = store.add(Quicklink(name: "New Quicklink")).id }
    private func deleteSelected() {
        guard let id = selectedId, let idx = store.quicklinks.firstIndex(where: { $0.id == id }) else { return }
        store.delete(id: id)
        selectedId = store.quicklinks.isEmpty ? nil : store.quicklinks[min(idx, store.quicklinks.count - 1)].id
    }
}

private struct QuicklinkEditor: View {
    let quicklink: Quicklink
    let onChange: (Quicklink) -> Void
    @State private var name = ""
    @State private var link = ""

    var body: some View {
        Form {
            TextField("Name", text: $name).onChange(of: name) { _, _ in commit() }
            TextField("Link", text: $link).onChange(of: link) { _, _ in commit() }
            Section {
                Text("Use **{query}** as a placeholder for input you'll type when running it — e.g.\nhttps://www.google.com/search?q={query}")
                    .font(.caption).foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .onAppear { name = quicklink.name; link = quicklink.link }
    }

    private func commit() { onChange(Quicklink(id: quicklink.id, name: name, link: link)) }
}

// MARK: - Shared list chrome

/// The +/- bar under a CRUD list (native source-list footer style).
private func listToolbar(add: @escaping () -> Void, remove: @escaping () -> Void, canRemove: Bool) -> some View {
    VStack(spacing: 0) {
        Divider()
        HStack(spacing: 0) {
            Button(action: add) { Image(systemName: "plus").frame(width: 24, height: 22) }.buttonStyle(.borderless)
            Divider().frame(height: 14)
            Button(action: remove) { Image(systemName: "minus").frame(width: 24, height: 22) }.buttonStyle(.borderless).disabled(!canRemove)
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

private func placeholderPane(_ text: String) -> some View {
    VStack { Spacer(); Text(text).foregroundColor(.secondary); Spacer() }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}

// MARK: - Import (in-app `invoke import`)

/// Settings → Import: paste/Browse to an extension's source folder, check compatibility, and import.
struct ImportPane: View {
    let repoRoot: String
    @State private var path = ""
    @State private var report: ImportReport?
    @State private var error = ""
    @State private var busy = false

    var body: some View {
        Form {
            Section {
                HStack {
                    TextField("Path to an extension's source folder", text: $path).textFieldStyle(.roundedBorder)
                    Button("Browse…", action: browse)
                }
                Text("Point at a folder with package.json + src/ — e.g. a folder from github.com/raycast/extensions. Dependency-light extensions (just @raycast/api / @raycast/utils) work best.")
                    .font(.caption).foregroundColor(.secondary)
                HStack {
                    Button("Check Compatibility") { Task { await go(install: false) } }.disabled(path.isEmpty || busy)
                    Button("Import") { Task { await go(install: true) } }
                        .disabled(path.isEmpty || busy || (report?.blocking ?? false))
                    if busy { ProgressView().controlSize(.small) }
                }
            } header: { Text("Import an extension") }

            if !error.isEmpty {
                Section { Text(error).font(.callout).foregroundColor(.red) }
            }
            if let r = report { reportSection(r) }
        }
        .formStyle(.grouped)
        .frame(minWidth: 540, maxWidth: .infinity, minHeight: 380, maxHeight: .infinity)
    }

    @ViewBuilder private func reportSection(_ r: ImportReport) -> some View {
        Section {
            LabeledContent("Extension", value: r.title)
            ForEach(r.commands, id: \.name) { c in
                LabeledContent(c.title) {
                    Text(c.entryFound ? (c.mode == "view" ? "view ✓" : c.mode) : "entry missing")
                        .foregroundColor(c.entryFound ? .secondary : .red)
                }
            }
            LabeledContent("Verdict") {
                switch r.verdict {
                case "runnable": Text("👍 Looks runnable").foregroundColor(.green)
                case "degraded": Text("Loads, degraded (denied builtins)").foregroundColor(.orange)
                default: Text("⚠️ Needs work before it runs").foregroundColor(.red)
                }
            }
            if !r.missingApi.isEmpty {
                LabeledContent("Unsupported APIs") { Text(r.missingApi.joined(separator: ", ")).foregroundColor(.red) }
            }
            if !r.deniedBuiltins.isEmpty {
                LabeledContent("Denied builtins") { Text(r.deniedBuiltins.joined(separator: ", ")).foregroundColor(.orange) }
            }
            if r.installed {
                Text("✓ Imported to \(r.dest). Relaunch Invoke to use it (Extensions group).")
                    .font(.callout).foregroundColor(.green)
            }
        } header: { Text("Compatibility") }
    }

    private func browse() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Choose"
        if panel.runModal() == .OK, let url = panel.url { path = url.path }
    }

    private func go(install: Bool) async {
        busy = true
        error = ""
        let result = await ExtensionImporter(repoRoot: repoRoot).run(path: path, install: install)
        busy = false
        switch result {
        case .success(let r): report = r
        case .failure(let e): error = e.message; report = nil
        }
    }
}

// MARK: - Extension preferences

public struct PrefOption: Identifiable { public let value: String; public let title: String; public var id: String { value }
    public init(value: String, title: String) { self.value = value; self.title = title } }

public struct ExtensionPreference: Identifiable {
    public let id: String        // = name
    public let name: String
    public let title: String     // section header when present (Raycast groups by this)
    public let label: String     // the checkbox's own text
    public let description: String
    public let type: String      // textfield | password | checkbox | dropdown
    public let defaultValue: String
    public let options: [PrefOption]
    public init(name: String, title: String, label: String = "", description: String, type: String, defaultValue: String, options: [PrefOption]) {
        self.id = name; self.name = name; self.title = title; self.label = label; self.description = description
        self.type = type; self.defaultValue = defaultValue; self.options = options
    }
}

/// An AI tool the extension exposes (Raycast's "Capabilities").
public struct ExtensionCapability: Identifiable {
    public let id: String; public let title: String; public let description: String
    public init(name: String, title: String, description: String) { self.id = name; self.title = title; self.description = description }
}

/// Per-command detail (title, description, and its own preferences) for the detail panel.
public struct ExtensionCommandDetail: Identifiable {
    public let id: String        // command name
    public let title: String
    public let description: String
    public let fields: [ExtensionPreference]
    public init(name: String, title: String, description: String, fields: [ExtensionPreference]) {
        self.id = name; self.title = title; self.description = description; self.fields = fields
    }
}

public struct ExtensionPrefGroup: Identifiable {
    public let id: String        // extension key
    public let title: String
    public let description: String
    public let fields: [ExtensionPreference]              // extension-level preferences
    public let commands: [ExtensionCommandDetail]         // per-command title/description/preferences
    public let capabilities: [ExtensionCapability]        // tools[]
    public init(id: String, title: String, description: String = "", fields: [ExtensionPreference],
                commands: [ExtensionCommandDetail] = [], capabilities: [ExtensionCapability] = []) {
        self.id = id; self.title = title; self.description = description
        self.fields = fields; self.commands = commands; self.capabilities = capabilities
    }
}

/// Settings → Extensions: configure each installed extension's declared preferences. Values are
/// applied at the extension's next launch (read via getPreferenceValues). `password` fields are
/// stored in the Keychain.
struct ExtensionPrefsPane: View {
    let groups: [ExtensionPrefGroup]
    var body: some View {
        Group {
            if groups.isEmpty {
                placeholderPane("No extension preferences yet. Extensions that declare preferences in their manifest show their settings here once installed.")
            } else {
                Form {
                    ForEach(groups) { g in
                        Section(g.title) {
                            ForEach(g.fields) { f in
                                if f.type == "checkbox" { CheckboxPref(extID: g.id, pref: f) } else { PrefField(extID: g.id, pref: f) }
                            }
                        }
                    }
                }
                .formStyle(.grouped)
            }
        }
        .frame(minWidth: 540, maxWidth: .infinity, minHeight: 380, maxHeight: .infinity)
    }
}

/// A text/password/dropdown preference editing a LOCAL buffer, committing on submit/blur (so it
/// neither fights the caret nor writes the Keychain on every keystroke).
private struct PrefField: View {
    let extID: String
    let pref: ExtensionPreference
    @ObservedObject private var settings = AppSettings.shared
    @State private var text = ""
    @FocusState private var focused: Bool
    private var secret: Bool { pref.type == "password" }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            switch pref.type {
            case "password":
                // Never read the stored secret back into the field — it stays in the Keychain. The
                // field is blank; typing replaces, and we only write when non-empty (an untouched blur
                // must not delete/re-add the item). Status comes from a non-secret presence marker.
                HStack(spacing: 8) {
                    SecureField(secretIsSet ? "Configured — type to replace" : pref.title, text: $text)
                        .focused($focused).onSubmit(commit)
                    if secretIsSet {
                        Button("Remove") {
                            text = ""
                            settings.setExtensionPref(extID: extID, name: pref.name, secret: true, value: "")
                        }
                    }
                }
            case "dropdown":
                // Commit only on a real user selection. A custom binding's setter fires on UI changes
                // but NOT on the programmatic seed assignment, so opening the pane never persists an
                // unchosen (clamped) default.
                Picker(pref.title, selection: Binding(get: { text }, set: { text = $0; commit() })) {
                    ForEach(pref.options) { Text($0.title).tag($0.value) }
                }
            default:
                TextField(pref.title, text: $text).focused($focused).onSubmit(commit)
            }
            if !pref.description.isEmpty { Text(pref.description).font(.caption).foregroundColor(.secondary) }
        }
        .onAppear(perform: seed)
        .onChange(of: focused) { _, now in if !now { commit() } }
    }

    private var secretIsSet: Bool { settings.hasExtensionSecret(extID: extID, name: pref.name) }

    private func seed() {
        if secret { text = ""; return } // never pull the secret out of the Keychain into memory
        var v = settings.extensionPref(extID: extID, name: pref.name, secret: false) ?? pref.defaultValue
        // A dropdown whose seed isn't a valid option would show a blank selection — clamp to the first.
        if pref.type == "dropdown", !pref.options.contains(where: { $0.value == v }) {
            v = pref.options.first?.value ?? v
        }
        text = v
    }

    private func commit() {
        // For secrets, an empty/whitespace buffer means "untouched" (use Remove to clear) — don't
        // rewrite the item. Trim so the guard agrees with setExtensionPref's emptiness test (no orphan).
        if secret && text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return }
        settings.setExtensionPref(extID: extID, name: pref.name, secret: secret, value: text)
        if secret { text = "" } // don't keep the typed secret in memory after saving
    }
}

private struct CheckboxPref: View {
    let extID: String
    let pref: ExtensionPreference
    @ObservedObject private var settings = AppSettings.shared
    var body: some View {
        Toggle(isOn: Binding(
            get: { (settings.extensionPref(extID: extID, name: pref.name, secret: false) ?? pref.defaultValue) == "true" },
            set: { settings.setExtensionPref(extID: extID, name: pref.name, secret: false, value: $0 ? "true" : "false") }
        )) {
            Text(pref.label.isEmpty ? pref.title : pref.label) // the checkbox's own text (label), not the section header
            if !pref.description.isEmpty { Text(pref.description).font(.caption).foregroundColor(.secondary) }
        }
    }
}
