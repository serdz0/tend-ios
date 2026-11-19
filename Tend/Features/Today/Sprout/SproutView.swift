import SwiftUI

/// Tend's little mascot: a round seedling face with two leaves. Drawn with shapes, no images.
/// Its mood follows the day. It never droops: a busy day only makes it wave you on.
struct SproutView: View {
    let kind: DayMood.Kind

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var size: CGFloat = 68
    @State private var sway = false

    var body: some View {
        VStack(spacing: -size * 0.1) {
            leaves
            face
        }
        .frame(width: size, height: size)
        .animation(reduceMotion ? nil : .spring(duration: 0.5, bounce: 0.4), value: kind)
        .task(id: reduceMotion) {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                sway = true
            }
        }
    }

    /// How far the leaves are raised towards upright: relaxed when resting, arms up when cheering.
    private var raise: Double {
        switch kind {
        case .resting: 0
        case .cheerful: 14
        case .encouraging: 30
        case .celebrating: 38
        }
    }

    private var swayAngle: Double {
        sway ? 5 : -5
    }

    private var leaves: some View {
        HStack(spacing: size * 0.04) {
            LeafShape()
                .fill(Color.accentColor)
                .frame(width: size * 0.4, height: size * 0.32)
                .scaleEffect(x: -1)
                .rotationEffect(.degrees(raise + swayAngle), anchor: .bottomTrailing)
            LeafShape()
                .fill(Color.accentColor)
                .frame(width: size * 0.4, height: size * 0.32)
                .rotationEffect(.degrees(-(raise + swayAngle)), anchor: .bottomLeading)
        }
    }

    private var face: some View {
        ZStack {
            Circle()
                .fill(Color.accentColor.opacity(0.18))
            Circle()
                .stroke(Color.accentColor, lineWidth: size * 0.04)
            VStack(spacing: size * 0.05) {
                eyes
                mouth
            }
            .offset(y: size * 0.02)
        }
        .frame(width: size * 0.7, height: size * 0.7)
    }

    private var eyes: some View {
        HStack(spacing: size * 0.18) {
            eye
            eye
        }
    }

    @ViewBuilder
    private var eye: some View {
        switch kind {
        case .resting, .celebrating:
            CurveShape(bend: -1.2)
                .stroke(Color.primary, style: StrokeStyle(lineWidth: size * 0.035, lineCap: .round))
                .frame(width: size * 0.1, height: size * 0.06)
        case .cheerful, .encouraging:
            Circle()
                .fill(Color.primary)
                .frame(width: size * 0.075, height: size * 0.075)
        }
    }

    @ViewBuilder
    private var mouth: some View {
        switch kind {
        case .celebrating:
            Circle()
                .trim(from: 0, to: 0.5)
                .fill(Color.primary.opacity(0.85))
                .frame(width: size * 0.16, height: size * 0.16)
                .frame(height: size * 0.08, alignment: .top)
        case .resting:
            CurveShape(bend: 1.4)
                .stroke(Color.primary, style: StrokeStyle(lineWidth: size * 0.035, lineCap: .round))
                .frame(width: size * 0.1, height: size * 0.05)
        case .cheerful, .encouraging:
            CurveShape(bend: 1.8)
                .stroke(Color.primary, style: StrokeStyle(lineWidth: size * 0.035, lineCap: .round))
                .frame(width: size * 0.16, height: size * 0.07)
        }
    }
}

#if DEBUG
#Preview("Moods") {
    HStack(spacing: 24) {
        SproutView(kind: .resting)
        SproutView(kind: .cheerful)
        SproutView(kind: .encouraging)
        SproutView(kind: .celebrating)
    }
    .padding()
    .background(Theme.paper)
}
#endif
