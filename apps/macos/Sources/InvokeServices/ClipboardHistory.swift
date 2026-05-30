import AppKit

/// Clipboard history (PLAN.md §2). Polls NSPasteboard's changeCount and keeps a capped, in-memory
/// list of recent text clips. IN-MEMORY ONLY by design: persisting clipboard contents requires the
/// encrypted-at-rest store (§3.4, SQLCipher) — until that lands, keeping history in RAM avoids
/// writing plaintext clips to disk. Clips are captured only while Invoke is running.
public final class ClipboardHistory {
    public struct Clip: Sendable {
        public let text: String
        public let kind: String // "Text" | "Link"
        public let date: Date
    }

    private var clips: [Clip] = []
    private var lastChange = 0
    private var timer: Timer?
    private let cap = 100

    public init() {}

    /// Begin watching the pasteboard. Baselines on the current content so existing clipboard data
    /// isn't captured retroactively.
    public func start() {
        lastChange = NSPasteboard.general.changeCount
        let t = Timer(timeInterval: 0.6, repeats: true) { [weak self] _ in self?.poll() }
        RunLoop.main.add(t, forMode: .common) // keep firing during menu/modal tracking
        timer = t
    }

    private func poll() {
        let pb = NSPasteboard.general
        guard pb.changeCount != lastChange else { return }
        lastChange = pb.changeCount

        // A password-manager / concealed copy is excluded by convention via this pasteboard type.
        if pb.types?.contains(NSPasteboard.PasteboardType("org.nspasteboard.ConcealedType")) == true { return }
        guard let s = pb.string(forType: .string), !s.isEmpty else { return }

        clips.removeAll { $0.text == s } // re-copying an existing clip moves it to the top (no dupes)
        let isLink = s.hasPrefix("http://") || s.hasPrefix("https://")
        clips.insert(Clip(text: s, kind: isLink ? "Link" : "Text", date: Date()), at: 0)
        if clips.count > cap { clips.removeLast(clips.count - cap) }
    }

    /// Recent clips, optionally filtered by a case-insensitive substring (newest first).
    public func entries(matching query: String = "") -> [Clip] {
        let q = query.lowercased().trimmingCharacters(in: .whitespaces)
        return q.isEmpty ? clips : clips.filter { $0.text.lowercased().contains(q) }
    }
}
