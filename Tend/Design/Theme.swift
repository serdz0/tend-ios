import SwiftUI

/// Shared sizes and colours so every screen looks like the same app.
enum Theme {
    /// 8-point spacing grid.
    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
    }

    /// Apple's minimum comfortable tap area.
    static let minimumTapSize: CGFloat = 44

    /// Warm paper behind everything, and the slightly lighter card on top of it.
    static let paper = Color(.paper)
    static let card = Color(.card)
    /// Used for overdue items. The words "overdue" always appear next to it.
    static let overdue = Color(.terracotta)
}

extension Font {
    /// Serif screen titles. Built on a text style, so it grows with the user's text size.
    static let screenTitle = Font.system(.largeTitle, design: .serif).bold()
}
