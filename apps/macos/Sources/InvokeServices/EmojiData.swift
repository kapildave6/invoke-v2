import Foundation

/// Emoji & symbols picker data (PLAN.md §2). A curated subset (the most-used emoji across
/// categories) with search keywords. A full Unicode emoji index is a later data drop; this is
/// enough to be genuinely useful and keeps the binary small.
public enum EmojiData {
    public struct Emoji: Sendable {
        public let char: String
        public let name: String
        public let keywords: [String]
    }

    /// Case-insensitive match on name or keywords.
    public static func search(_ query: String) -> [Emoji] {
        let q = query.lowercased().trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return all }
        return all.filter { e in
            e.name.contains(q) || e.keywords.contains { $0.contains(q) }
        }
    }

    public static func emoji(forChar char: String) -> Emoji? { all.first { $0.char == char } }

    public static let all: [Emoji] = [
        // Smileys & emotion
        e("😀", "grinning face", "happy", "smile"),
        e("😄", "grinning face with smiling eyes", "happy", "smile"),
        e("😁", "beaming face", "happy", "grin"),
        e("😂", "face with tears of joy", "lol", "laugh", "joy"),
        e("🤣", "rolling on the floor laughing", "rofl", "lol", "laugh"),
        e("😊", "smiling face with smiling eyes", "blush", "happy"),
        e("🙂", "slightly smiling face", "smile"),
        e("😉", "winking face", "wink"),
        e("😍", "smiling face with heart-eyes", "love", "crush"),
        e("😘", "face blowing a kiss", "kiss", "love"),
        e("😎", "smiling face with sunglasses", "cool", "sunglasses"),
        e("🤔", "thinking face", "hmm", "think"),
        e("😐", "neutral face", "meh"),
        e("🙄", "face with rolling eyes", "eyeroll", "annoyed"),
        e("😴", "sleeping face", "sleep", "zzz", "tired"),
        e("😢", "crying face", "sad", "cry", "tear"),
        e("😭", "loudly crying face", "sob", "cry", "sad"),
        e("😡", "enraged face", "angry", "mad"),
        e("🥳", "partying face", "party", "celebrate"),
        e("🤯", "exploding head", "mind blown", "shocked"),
        e("😱", "face screaming in fear", "scream", "shocked"),
        e("🤖", "robot", "bot", "ai"),
        e("👀", "eyes", "look", "watch"),
        e("🧠", "brain", "mind", "smart"),
        // Gestures
        e("👍", "thumbs up", "like", "approve", "yes", "+1"),
        e("👎", "thumbs down", "dislike", "no", "-1"),
        e("👌", "ok hand", "okay", "perfect"),
        e("✌️", "victory hand", "peace"),
        e("🤞", "crossed fingers", "luck", "hope"),
        e("🙏", "folded hands", "please", "thanks", "pray"),
        e("👏", "clapping hands", "applause", "clap", "bravo"),
        e("🙌", "raising hands", "celebrate", "hooray"),
        e("💪", "flexed biceps", "strong", "muscle"),
        e("👋", "waving hand", "hi", "hello", "bye", "wave"),
        e("🤝", "handshake", "deal", "agree"),
        // Hearts & symbols
        e("❤️", "red heart", "love", "like"),
        e("🧡", "orange heart", "love"),
        e("💛", "yellow heart", "love"),
        e("💚", "green heart", "love"),
        e("💙", "blue heart", "love"),
        e("💜", "purple heart", "love"),
        e("🖤", "black heart", "love"),
        e("💔", "broken heart", "sad", "breakup"),
        e("💕", "two hearts", "love"),
        e("🔥", "fire", "lit", "hot", "flame"),
        e("✨", "sparkles", "shiny", "magic", "new"),
        e("⭐", "star", "favorite"),
        e("🎉", "party popper", "celebrate", "tada", "congrats"),
        e("💯", "hundred points", "100", "perfect"),
        e("⚡", "high voltage", "lightning", "fast", "power"),
        e("✅", "check mark button", "done", "yes", "ok", "complete"),
        e("❌", "cross mark", "no", "wrong", "delete"),
        e("✔️", "check mark", "done", "tick"),
        e("⚠️", "warning", "caution", "alert"),
        e("❓", "question mark", "help", "what"),
        e("❗", "exclamation mark", "important"),
        e("➕", "plus", "add"),
        e("➖", "minus", "subtract"),
        e("♻️", "recycle", "reuse"),
        e("🔒", "locked", "secure", "private"),
        e("🔑", "key", "password", "access"),
        e("⏰", "alarm clock", "time", "reminder"),
        e("📌", "pushpin", "pin", "save"),
        // Objects
        e("💻", "laptop", "computer", "code", "work"),
        e("📱", "mobile phone", "phone", "iphone"),
        e("📷", "camera", "photo", "picture"),
        e("💡", "light bulb", "idea", "tip"),
        e("📝", "memo", "note", "write", "edit"),
        e("📎", "paperclip", "attach"),
        e("✂️", "scissors", "cut"),
        e("🎁", "gift", "present"),
        e("🔔", "bell", "notification", "alert"),
        e("☕", "hot beverage", "coffee", "tea"),
        e("🍕", "pizza", "food"),
        e("🍔", "hamburger", "burger", "food"),
        e("🍎", "red apple", "fruit"),
        e("🎂", "birthday cake", "cake", "birthday"),
        e("🍺", "beer mug", "beer", "drink"),
        // Animals & nature
        e("🐶", "dog face", "puppy", "animal"),
        e("🐱", "cat face", "kitten", "animal"),
        e("🦄", "unicorn", "magic"),
        e("🐝", "honeybee", "bee", "bug"),
        e("🦋", "butterfly", "bug"),
        e("🌊", "water wave", "ocean", "sea"),
        e("🌙", "crescent moon", "night", "moon"),
        e("☀️", "sun", "sunny", "weather"),
        // Travel & arrows
        e("🚀", "rocket", "launch", "ship", "fast"),
        e("✈️", "airplane", "flight", "travel"),
        e("🚗", "car", "drive", "auto"),
        e("🏠", "house", "home"),
        e("⬆️", "up arrow", "up"),
        e("⬇️", "down arrow", "down"),
        e("⬅️", "left arrow", "left"),
        e("➡️", "right arrow", "right"),
        e("🔁", "repeat", "loop", "refresh"),
    ]

    private static func e(_ char: String, _ name: String, _ keywords: String...) -> Emoji {
        Emoji(char: char, name: name, keywords: keywords)
    }
}
