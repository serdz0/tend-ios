import SwiftUI

struct HistoryHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("Journal")
                .font(.screenTitle)
                .accessibilityAddTraits(.isHeader)
            Text("A look back at everything you've cared for.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
