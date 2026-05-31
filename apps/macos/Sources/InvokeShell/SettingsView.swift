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

private let paneSize = CGSize(width: 580, height: 420)

/// Settings panes (PLAN.md §6). Hosted individually by SettingsWindow inside an NSTabViewController
/// with the native `.toolbar` tab style (icon + label, like macOS System Settings / Raycast).

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
        .frame(width: paneSize.width, height: paneSize.height)
    }
}

struct CommandsPane: View {
    @ObservedObject var settings = AppSettings.shared
    let commands: [CommandInfo]
    var body: some View {
        Form {
            Section {
                ForEach(commands) { c in
                    Toggle(isOn: Binding(get: { settings.isEnabled(c.id) }, set: { settings.setEnabled(c.id, $0) })) {
                        HStack {
                            Text(c.title)
                            Spacer()
                            Text(c.subtitle).foregroundColor(.secondary).font(.callout)
                        }
                    }
                }
            } header: {
                Text("Enable or disable commands in the root search")
            }
        }
        .formStyle(.grouped)
        .frame(width: paneSize.width, height: paneSize.height)
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
        .frame(width: paneSize.width, height: paneSize.height)
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
        .frame(width: paneSize.width, height: paneSize.height)
    }
}

struct AboutPane: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "command.square.fill")
                .resizable().frame(width: 72, height: 72).foregroundColor(.accentColor)
            Text("Invoke").font(.title.bold())
            Text("Version 0.1 (dev)").foregroundColor(.secondary)
            Text("A keyboard-first command palette — a Raycast-style launcher.\nPersonal project.")
                .multilineTextAlignment(.center).foregroundColor(.secondary).font(.callout)
            Button("View on GitHub") {
                if let url = URL(string: "https://github.com/kapildave6/invoke-v2") { NSWorkspace.shared.open(url) }
            }
            .padding(.top, 4)
        }
        .frame(width: paneSize.width, height: paneSize.height)
    }
}
