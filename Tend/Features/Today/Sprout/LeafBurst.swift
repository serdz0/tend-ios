import SwiftUI

/// A handful of tiny leaves that fly out from the tick for a moment when something is finished.
struct LeafBurst: View {
    let isActive: Bool

    /// 0 = waiting, 1 = leaves together and visible, 2 = leaves spread and gone.
    @State private var phase = 0
    private let count = 6

    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { index in
                Image(systemName: "leaf.fill")
                    .font(.caption2)
                    .foregroundStyle(Color.accentColor)
                    .rotationEffect(.degrees(angle(of: index) + 90))
                    .offset(phase == 2 ? offset(of: index) : .zero)
                    .scaleEffect(phase == 2 ? 1 : 0.5)
                    .opacity(phase == 1 ? 1 : (phase == 2 ? 0 : 0))
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .task(id: isActive) {
            guard isActive else {
                phase = 0
                return
            }
            phase = 1
            try? await Task.sleep(for: .milliseconds(40))
            withAnimation(.easeOut(duration: 0.55)) {
                phase = 2
            }
        }
    }

    private func angle(of index: Int) -> Double {
        Double(index) / Double(count) * 360 - 60
    }

    private func offset(of index: Int) -> CGSize {
        let radians = angle(of: index) * .pi / 180
        return CGSize(width: cos(radians) * 26, height: sin(radians) * 26)
    }
}
