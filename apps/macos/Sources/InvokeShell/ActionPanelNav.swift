import Foundation

/// Next selectable row index moving `delta` (+1 down / −1 up) from `from`, skipping non-selectable
/// rows (section headers / separators) and clamping at the ends (no wrap). Returns `from` if nothing
/// is selectable. `from` is expected to already be a selectable index (the selection invariant).
func nextSelectable(_ selectable: [Bool], from: Int, delta: Int) -> Int {
    guard selectable.contains(true), delta != 0 else { return from }
    var i = from
    while true {
        let n = i + delta
        if n < 0 || n >= selectable.count { return from } // hit an end → clamp to original
        i = n
        if selectable[i] { return i }
    }
}

/// First selectable index (initial selection), or 0 if none.
func firstSelectable(_ selectable: [Bool]) -> Int { selectable.firstIndex(of: true) ?? 0 }
