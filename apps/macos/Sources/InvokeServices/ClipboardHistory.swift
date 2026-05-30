import AppKit

/// Clipboard history (PLAN.md §2). Polls NSPasteboard's changeCount and keeps a capped, in-memory
/// list of recent clips (text, links, and files). IN-MEMORY ONLY by design: persisting clipboard
/// contents requires the encrypted-at-rest store (§3.4, SQLCipher) — until that lands, keeping
/// history in RAM avoids writing plaintext clips to disk. Clips are captured only while running.
/// Raw image data and paste-to-frontmost (Accessibility) are follow-ups.
public final class ClipboardHistory {
    public struct Clip: Sendable {
        public let kind: String // "Text" | "Link" | "File"
        public let text: String // content (text/link) or absolute path (file) — also the dedupe key
        public let date: Date
        public let timesCopied: Int
        public let source: String?  // app focused when copied
        public let filePath: String? // file clips
        public let fileSize: Int?    // file clips, bytes
    }

    private var clips: [Clip] = []
    private var lastChange = 0
    private var timer: Timer?
    private let cap = 100

    public init() {}

    public func start() {
        lastChange = NSPasteboard.general.changeCount
        let t = Timer(timeInterval: 0.6, repeats: true) { [weak self] _ in self?.poll() }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func poll() {
        let pb = NSPasteboard.general
        guard pb.changeCount != lastChange else { return }
        lastChange = pb.changeCount

        if pb.types?.contains(NSPasteboard.PasteboardType("org.nspasteboard.ConcealedType")) == true { return }
        let source = NSWorkspace.shared.frontmostApplication?.localizedName

        // File first (a copied file also carries a string path, which we don't want to capture twice).
        if let urls = pb.readObjects(forClasses: [NSURL.self],
                                     options: [.urlReadingFileURLsOnly: true]) as? [URL], let url = urls.first {
            let path = url.path
            let size = (try? FileManager.default.attributesOfItem(atPath: path)[.size]) as? Int
            record(kind: "File", text: path, source: source, filePath: path, fileSize: size)
            return
        }
        if let s = pb.string(forType: .string), !s.isEmpty {
            let isLink = s.hasPrefix("http://") || s.hasPrefix("https://")
            record(kind: isLink ? "Link" : "Text", text: s, source: source, filePath: nil, fileSize: nil)
        }
    }

    private func record(kind: String, text: String, source: String?, filePath: String?, fileSize: Int?) {
        let prior = clips.first(where: { $0.text == text })?.timesCopied ?? 0
        clips.removeAll { $0.text == text } // re-copy → move to top, keep count
        clips.insert(Clip(kind: kind, text: text, date: Date(), timesCopied: prior + 1,
                          source: source, filePath: filePath, fileSize: fileSize), at: 0)
        if clips.count > cap { clips.removeLast(clips.count - cap) }
    }

    /// The distinct kinds currently present, for the type filter (always includes "All Types").
    public func availableKinds() -> [String] {
        var seen: [String] = ["All Types"]
        for k in ["Text", "Link", "File"] where clips.contains(where: { $0.kind == k }) { seen.append(k) }
        return seen
    }

    /// Recent clips, newest first, filtered by substring and (optionally) kind.
    public func entries(matching query: String = "", kind: String = "All Types") -> [Clip] {
        let q = query.lowercased().trimmingCharacters(in: .whitespaces)
        return clips.filter { clip in
            (kind == "All Types" || clip.kind == kind) &&
            (q.isEmpty || clip.text.lowercased().contains(q))
        }
    }
}
