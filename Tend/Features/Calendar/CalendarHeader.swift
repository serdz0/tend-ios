import SwiftUI

/// The month as the screen title, with buttons to move between months.
/// At very large text sizes the buttons move to their own line so the title keeps its room.
struct CalendarHeader: View {
    let month: CalendarMonth
    let showsTodayButton: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onToday: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading) {
                    title
                    HStack { buttons }
                }
            } else {
                HStack {
                    title
                    Spacer(minLength: Theme.Spacing.s)
                    buttons
                }
            }
        }
        .buttonStyle(.borderless)
    }

    private var title: some View {
        Text(month.start, format: .dateTime.month(.wide).year())
            .font(.screenTitle)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .accessibilityAddTraits(.isHeader)
    }

    @ViewBuilder
    private var buttons: some View {
        if showsTodayButton {
            Button("Back to today", systemImage: "arrow.uturn.backward.circle", action: onToday)
                .labelStyle(.iconOnly)
                .frame(minWidth: Theme.minimumTapSize, minHeight: Theme.minimumTapSize)
        }
        Button("Previous month", systemImage: "chevron.left", action: onPrevious)
            .labelStyle(.iconOnly)
            .frame(minWidth: Theme.minimumTapSize, minHeight: Theme.minimumTapSize)
        Button("Next month", systemImage: "chevron.right", action: onNext)
            .labelStyle(.iconOnly)
            .frame(minWidth: Theme.minimumTapSize, minHeight: Theme.minimumTapSize)
    }
}
