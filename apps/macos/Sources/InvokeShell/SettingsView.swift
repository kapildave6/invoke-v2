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
    /// Called after an enable/disable or hotkey change so the controller re-registers global hotkeys.
    let onBindingsChanged: () -> Void

    @State private var expanded: Set<String> = []
    @State private var search = ""

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
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.secondary).font(.caption)
                TextField("Search commands", text: $search).textFieldStyle(.plain)
            }
            .padding(.horizontal, 12).padding(.vertical, 7)
            Divider()
            columnHeader
            Divider()
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filtered) { group in
                        if group.commands.count > 1 {
                            groupRow(group)
                            if expanded.contains(group.id) {
                                ForEach(group.commands) { commandRow($0, indented: true) }
                            }
                        } else if let only = group.commands.first {
                            commandRow(only, indented: false, type: "Command")
                        }
                    }
                }
            }
        }
        .frame(minWidth: 600, maxWidth: .infinity, minHeight: 380, maxHeight: .infinity)
    }

    // MARK: - Column layout (shared by header + rows)

    private let typeW: CGFloat = 90
    private let aliasW: CGFloat = 110
    private let hotkeyW: CGFloat = 140
    private let enabledW: CGFloat = 56

    private var columnHeader: some View {
        HStack(spacing: 0) {
            Text("Name").frame(maxWidth: .infinity, alignment: .leading)
            Text("Type").frame(width: typeW, alignment: .leading)
            Text("Alias").frame(width: aliasW, alignment: .leading)
            Text("Hotkey").frame(width: hotkeyW, alignment: .leading)
            Text("Enabled").frame(width: enabledW, alignment: .center)
        }
        .font(.caption).foregroundColor(.secondary)
        .padding(.horizontal, 14).padding(.vertical, 6)
    }

    // MARK: - Rows

    private func groupRow(_ group: ExtensionGroup) -> some View {
        let allOn = group.commands.allSatisfy { settings.isEnabled($0.id) }
        let anyOn = group.commands.contains { settings.isEnabled($0.id) }
        let symbol = allOn ? "checkmark.square.fill" : (anyOn ? "minus.square.fill" : "square")
        return HStack(spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: expanded.contains(group.id) ? "chevron.down" : "chevron.right")
                    .font(.caption2).foregroundColor(.secondary).frame(width: 12)
                Image(systemName: group.icon).frame(width: 18)
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
        .padding(.horizontal, 14).padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture { toggleExpanded(group.id) }
    }

    private func commandRow(_ c: CommandInfo, indented: Bool, type: String = "Command") -> some View {
        HStack(spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: c.icon).frame(width: 18).foregroundColor(.secondary)
                Text(c.title)
                if !c.subtitle.isEmpty && !indented {
                    Text(c.subtitle).foregroundColor(.secondary).font(.callout)
                }
            }
            .padding(.leading, indented ? 26 : 0)
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
        .padding(.horizontal, 14).padding(.vertical, 5)
    }

    private func toggleExpanded(_ id: String) {
        if expanded.contains(id) { expanded.remove(id) } else { expanded.insert(id) }
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
        }
        .formStyle(.grouped)
        .frame(minWidth: 540, maxWidth: .infinity, minHeight: 380, maxHeight: .infinity)
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
