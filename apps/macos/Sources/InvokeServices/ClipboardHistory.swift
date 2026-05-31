import AppKit

/// Clipboard history (PLAN.md §2). Polls NSPasteboard's changeCount and keeps a capped, in-memory
/// list of recent clips — text, links, files, and images. IN-MEMORY ONLY by design: persisting
/// clipboard contents requires the encrypted-at-rest store (§3.4, SQLCipher); until then, keeping
/// history in RAM avoids writing plaintext clips to disk. (Image clips keep full PNG data in RAM
/// for re-paste — bounded by the 100-clip cap.) Clips are captured only while running.
public final class ClipboardHistory {
    public struct Clip {
        public let key: String // stable identity + dedupe key
        public let kind: String // "Text" | "Link" | "File" | "Image"
        public let text: String // content (text/link), path (file), or a label (image)
        public let date: Date
        public let timesCopied: Int
        public let source: String?
        public let filePath: String?
        public let fileSize: Int?
        public let imageData: Data?   // full PNG (image clips), for display + re-paste
        public let imageW: Int?
        public let imageH: Int?
    }

    private var clips: [Clip] = []
    private var lastChange = 0
    private var timer: Timer?
    public var capacity = 100

    public init() {}

    /// Clear all history (Settings → Clipboard → Clear History).
    public func clear() { clips.removeAll() }

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

        // File first (a copied file also carries a path string we don't want to capture twice).
        if let urls = pb.readObjects(forClasses: [NSURL.self],
                                     options: [.urlReadingFileURLsOnly: true]) as? [URL], let url = urls.first {
            let path = url.path
            let size = (try? FileManager.default.attributesOfItem(atPath: path)[.size]) as? Int
            insert(.init(key: path, kind: "File", text: path, date: Date(), timesCopied: bump(path),
                         source: source, filePath: path, fileSize: size, imageData: nil, imageW: nil, imageH: nil))
            return
        }
        // Image data (no file): screenshots-to-clipboard, copied images, etc.
        if pb.types?.contains(where: { $0 == .png || $0 == .tiff }) == true,
           let image = NSImage(pasteboard: pb), let png = Self.png(image) {
            let rep = NSBitmapImageRep(data: png)
            let key = "img:\(png.count):\(png.prefix(64).hashValue)"
            insert(.init(key: key, kind: "Image", text: "Image", date: Date(), timesCopied: bump(key),
                         source: source, filePath: nil, fileSize: png.count,
                         imageData: png, imageW: rep?.pixelsWide, imageH: rep?.pixelsHigh))
            return
        }
        if let s = pb.string(forType: .string), !s.isEmpty {
            let isLink = s.hasPrefix("http://") || s.hasPrefix("https://")
            insert(.init(key: s, kind: isLink ? "Link" : "Text", text: s, date: Date(), timesCopied: bump(s),
                         source: source, filePath: nil, fileSize: nil, imageData: nil, imageW: nil, imageH: nil))
        }
    }

    private func bump(_ key: String) -> Int { (clips.first(where: { $0.key == key })?.timesCopied ?? 0) + 1 }

    private func insert(_ clip: Clip) {
        clips.removeAll { $0.key == clip.key } // re-copy → move to top
        clips.insert(clip, at: 0)
        if clips.count > capacity { clips.removeLast(clips.count - capacity) }
    }

    private static func png(_ image: NSImage) -> Data? {
        guard let tiff = image.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff) else { return nil }
        return rep.representation(using: .png, properties: [:])
    }

    public func clip(forKey key: String) -> Clip? { clips.first { $0.key == key } }

    public func availableKinds() -> [String] {
        var seen = ["All Types"]
        for k in ["Text", "Link", "File", "Image"] where clips.contains(where: { $0.kind == k }) { seen.append(k) }
        return seen
    }

    public func entries(matching query: String = "", kind: String = "All Types") -> [Clip] {
        let q = query.lowercased().trimmingCharacters(in: .whitespaces)
        return clips.filter { clip in
            (kind == "All Types" || clip.kind == kind) &&
            (q.isEmpty || clip.text.lowercased().contains(q) || (clip.filePath?.lowercased().contains(q) ?? false))
        }
    }
}
