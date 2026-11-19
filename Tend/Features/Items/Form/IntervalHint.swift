import SwiftUI

/// Under the repeat fields: for plants, a friendly note that the interval is only a starting point.
struct IntervalHint: View {
    let draft: ItemDraft

    var body: some View {
        if draft.kind == .plant, let days = draft.plantType.wateringDays {
            Text("A good starting point for \(draft.plantType.displayName): every ^[\(days) day](inflect: true). Pot, light and season all matter, so adjust it to suit your plant.")
        }
    }
}
