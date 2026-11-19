import SwiftUI

/// A row with a title and a number of kilometres to type.
struct KilometresField: View {
    let title: LocalizedStringKey
    @Binding var value: Int

    var body: some View {
        LabeledContent(title) {
            HStack(spacing: Theme.Spacing.xs) {
                TextField(title, value: $value, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                Text("km")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
