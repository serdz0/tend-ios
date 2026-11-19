import SwiftUI

/// A gentle curve from the left edge to the right edge. A positive bend dips down (a smile),
/// a negative bend arches up (a happy closed eye).
nonisolated struct CurveShape: Shape {
    var bend: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control: CGPoint(x: rect.midX, y: rect.midY + bend * rect.height)
        )
        return path
    }
}
