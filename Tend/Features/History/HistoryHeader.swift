import SwiftUI

struct HistoryHeader: View {
    var body: some View {
        Text("History")
            .font(.screenTitle)
            .accessibilityAddTraits(.isHeader)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
