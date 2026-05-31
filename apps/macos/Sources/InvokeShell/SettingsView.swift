import AppKit
import ApplicationServices
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
