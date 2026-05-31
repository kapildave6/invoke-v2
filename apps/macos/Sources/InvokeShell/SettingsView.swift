import AppKit
import ApplicationServices
import SwiftUI

/// Lightweight metadata for a command row in the Commands tab.
public struct CommandInfo: Identifiable {
    public let id: String
    public let title: String
    public let subtitle: String
    public init(id: String, title: String, subtitle: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
    }
}

/// The Settings window content (PLAN.md §6). Thin SwiftUI over the shared AppSettings model.
struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    let commands: [CommandInfo]
    let onClearClipboard: () -> Void

    var body: some View {
        TabView {
            GeneralTab(settings: settings).tabItem { Label("General", systemImage: "gearshape") }
            CommandsTab(settings: settings, commands: commands).tabItem { Label("Commands", systemImage: "command") }
            ClipboardTab(settings: settings, onClear: onClearClipboard).tabItem { Label("Clipboard", systemImage: "doc.on.clipboard") }
            AdvancedTab(settings: settings).tabItem { Label("Advanced", systemImage: "wrench.and.screwdriver") }
            AboutTab().tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 640, height: 480)
    }
}

private struct GeneralTab: View {
    @ObservedObject var settings: AppSettings
    var body: some View {
        Form {
            Toggle("Launch Invoke at login", isOn: $settings.launchAtLogin)
            Section("Hotkeys") {
                LabeledContent("Summon", value: "⌥Space")
                LabeledContent("Clipboard History", value: "⌘⇧V")
                LabeledContent("Window: left / right / maximize", value: "⌃⌥← / → / ↑")
            }
        }
        .formStyle(.grouped)
    }
}

private struct CommandsTab: View {
    @ObservedObject var settings: AppSettings
    let commands: [CommandInfo]
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Enable or disable commands in the root search.")
                .font(.callout).foregroundColor(.secondary).padding([.horizontal, .top], 16).padding(.bottom, 8)
            List(commands) { c in
                Toggle(isOn: Binding(get: { settings.isEnabled(c.id) }, set: { settings.setEnabled(c.id, $0) })) {
                    HStack(spacing: 8) {
                        Text(c.title)
                        Text(c.subtitle).foregroundColor(.secondary).font(.caption)
                    }
                }
            }
        }
    }
}

private struct ClipboardTab: View {
    @ObservedObject var settings: AppSettings
    let onClear: () -> Void
    var body: some View {
        Form {
            Picker("History size", selection: $settings.clipboardLimit) {
                Text("25 items").tag(25)
                Text("50 items").tag(50)
                Text("100 items").tag(100)
                Text("250 items").tag(250)
            }
            Text("History is kept in memory only (no plaintext on disk until the encrypted store ships).")
                .font(.caption).foregroundColor(.secondary)
            Button("Clear Clipboard History", role: .destructive, action: onClear)
        }
        .formStyle(.grouped)
    }
}

private struct AdvancedTab: View {
    @ObservedObject var settings: AppSettings
    @State private var axGranted = AXIsProcessTrusted()
    var body: some View {
        Form {
            Section("Permissions") {
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
                Text("Required to paste clipboard/emoji into apps and to move windows.")
                    .font(.caption).foregroundColor(.secondary)
            }
            Section("Emoji") {
                Picker("Skin tone", selection: $settings.emojiSkinTone) {
                    Text("Default").tag(0)
                    Text("🏻").tag(1); Text("🏼").tag(2); Text("🏽").tag(3); Text("🏾").tag(4); Text("🏿").tag(5)
                }
                .pickerStyle(.segmented)
            }
        }
        .formStyle(.grouped)
    }
}

private struct AboutTab: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "command.square.fill")
                .resizable().frame(width: 64, height: 64).foregroundColor(.accentColor)
            Text("Invoke").font(.title.bold())
            Text("Version 0.1 (dev)").foregroundColor(.secondary)
            Text("A keyboard-first command palette — a Raycast-style launcher.\nPersonal project.")
                .multilineTextAlignment(.center).foregroundColor(.secondary).font(.callout)
            Button("View on GitHub") {
                if let url = URL(string: "https://github.com/kapildave6/invoke-v2") { NSWorkspace.shared.open(url) }
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(30)
    }
}
