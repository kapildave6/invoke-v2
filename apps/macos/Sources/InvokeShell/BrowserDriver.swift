import AppKit

struct BrowserTab { let id: String; let url: String; let title: String; let active: Bool }
enum BrowserError: Error { case noBrowser; case automationDenied(String); case jsDisabled(String); case script(String) }

enum BrowserDriver {
  // bundle id → (AppleScript app name, family), in preference order.
  static let supported: [(bundle: String, name: String, family: String)] = [
    ("com.google.Chrome", "Google Chrome", "chromium"),
    ("com.brave.Browser", "Brave Browser", "chromium"),
    ("company.thebrowser.Browser", "Arc", "chromium"),
    ("com.microsoft.edgemac", "Microsoft Edge", "chromium"),
    ("com.vivaldi.Vivaldi", "Vivaldi", "chromium"),
    ("org.chromium.Chromium", "Chromium", "chromium"),
    ("com.apple.Safari", "Safari", "safari"),
  ]
  private static let FS = "\u{1F}", RS = "\u{1E}" // field / record separators

  static func supportedBrowser(frontmost: String?, running: [String]) -> (name: String, family: String)? {
    if let f = frontmost, let m = supported.first(where: { $0.bundle == f }) { return (m.name, m.family) }
    for cand in supported where running.contains(cand.bundle) { return (cand.name, cand.family) }
    return nil
  }
  static func parseTabId(_ id: String) -> (window: Int, tab: Int)? {
    let parts = id.split(separator: ":")
    guard parts.count == 2, let w = Int(parts[0]), let t = Int(parts[1]) else { return nil }
    return (w, t)
  }
  private static func escapeJS(_ s: String) -> String {
    s.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
  }
  static func contentJS(format: String, cssSelector: String?) -> String {
    let root = cssSelector.map { "document.querySelector(\"\(escapeJS($0))\")" } ?? (format == "html" ? "document.documentElement" : "document.body")
    let prop = format == "html" ? "outerHTML" : "innerText"
    return "(function(){var e=\(root);return e?e.\(prop):\"\";})()"
  }

  static func tabsScript(appName: String, family: String) -> String {
    if family == "safari" {
      return """
      tell application "\(appName)"
        set out to ""
        set wi to 0
        repeat with w in windows
          set wi to wi + 1
          set ct to current tab of w
          set ti to 0
          repeat with t in tabs of w
            set ti to ti + 1
            set act to (t is ct)
            set out to out & wi & "\(FS)" & ti & "\(FS)" & (act as text) & "\(FS)" & (URL of t) & "\(FS)" & (name of t) & "\(RS)"
          end repeat
        end repeat
        return out
      end tell
      """
    }
    return """
    tell application "\(appName)"
      set out to ""
      set wi to 0
      repeat with w in windows
        set wi to wi + 1
        set ai to active tab index of w
        set ti to 0
        repeat with t in tabs of w
          set ti to ti + 1
          set out to out & wi & "\(FS)" & ti & "\(FS)" & ((ti = ai) as text) & "\(FS)" & (URL of t) & "\(FS)" & (title of t) & "\(RS)"
        end repeat
      end repeat
      return out
    end tell
    """
  }
  static func contentScript(appName: String, family: String, window: Int?, tab: Int?, format: String, cssSelector: String?) -> String {
    let js = contentJS(format: format, cssSelector: cssSelector)
    if family == "safari" {
      let target = (window != nil && tab != nil) ? "tab \(tab!) of window \(window!)" : "current tab of window 1"
      return "tell application \"\(appName)\" to do JavaScript \"\(escapeJS(js))\" in \(target)"
    }
    let target = (window != nil && tab != nil) ? "tab \(tab!) of window \(window!)" : "active tab of window 1"
    return "tell application \"\(appName)\" to execute javascript \"\(escapeJS(js))\" in \(target)"
  }

  private static func run(_ source: String, appName: String, isContent: Bool) throws -> String {
    // osascript subprocess (NOT NSAppleScript) — runs reliably off-main; see AppleScriptRunner.
    let r = AppleScriptRunner.run(source)
    if r.exitCode != 0 {
      if r.automationDenied { throw BrowserError.automationDenied("Allow Invoke to control \(appName) in System Settings → Privacy & Security → Automation.") }
      // Safari/Chromium return an error when JS-from-Apple-Events is off.
      if isContent && r.jsDisabled {
        throw BrowserError.jsDisabled("Enable \(appName) → Develop/Developer → \u{201C}Allow JavaScript from Apple Events\u{201D}.")
      }
      throw BrowserError.script(r.stderr.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    return r.output
  }

  private static func frontBrowser() throws -> (name: String, family: String) {
    let ws = NSWorkspace.shared
    let running = ws.runningApplications.compactMap { $0.bundleIdentifier }
    let front = ws.frontmostApplication?.bundleIdentifier
    guard let b = supportedBrowser(frontmost: front, running: running) else {
      throw BrowserError.noBrowser
    }
    return b
  }

  static func getTabs() throws -> [BrowserTab] {
    let b = try frontBrowser()
    let raw = try run(tabsScript(appName: b.name, family: b.family), appName: b.name, isContent: false)
    return raw.components(separatedBy: RS).filter { !$0.isEmpty }.compactMap { row in
      let f = row.components(separatedBy: FS)
      guard f.count == 5 else { return nil }
      return BrowserTab(id: "\(f[0]):\(f[1])", url: f[3], title: f[4], active: f[2] == "true")
    }
  }
  static func getContent(tabId: String?, format: String, cssSelector: String?) throws -> String {
    let b = try frontBrowser()
    let pos = tabId.flatMap(parseTabId)
    return try run(contentScript(appName: b.name, family: b.family, window: pos?.window, tab: pos?.tab, format: format, cssSelector: cssSelector), appName: b.name, isContent: true)
  }
}

/// Runs AppleScript via the `/usr/bin/osascript` SUBPROCESS rather than NSAppleScript. NSAppleScript on
/// a background queue is unreliable (no run loop / Apple-Event thread affinity → empty result + spurious
/// error), and on the main thread it freezes the whole app while a script blocks (e.g. on the Automation
/// prompt or app launch). A subprocess has its own run loop, runs safely off-main, and is process-isolated.
enum AppleScriptRunner {
    struct Result { let output: String; let exitCode: Int32; let stderr: String
        var automationDenied: Bool { stderr.contains("-1743") || stderr.localizedCaseInsensitiveContains("not authorized to send apple events") }
        var jsDisabled: Bool { stderr.localizedCaseInsensitiveContains("not allowed") || (stderr.localizedCaseInsensitiveContains("javascript") && exitCode != 0) }
    }
    /// MUST be called off the main thread (it blocks on the subprocess).
    static func run(_ source: String) -> Result {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        proc.arguments = ["-e", source]
        let outPipe = Pipe(); let errPipe = Pipe()
        proc.standardOutput = outPipe; proc.standardError = errPipe
        do { try proc.run() } catch { return Result(output: "", exitCode: -1, stderr: String(describing: error)) }
        let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
        let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
        proc.waitUntilExit()
        let out = (String(data: outData, encoding: .utf8) ?? "").trimmingCharacters(in: .newlines)
        return Result(output: out, exitCode: proc.terminationStatus, stderr: String(data: errData, encoding: .utf8) ?? "")
    }
}
