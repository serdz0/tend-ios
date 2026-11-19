import SwiftUI

/// Under the repeat fields: for plants, an honest note that the interval is only a starting point.
struct IntervalHint: View {
    let draft: ItemDraft

    var body: some View {
        if draft.kind == .plant, let days = draft.plantType.wateringDays {
            Text("A starting point for \(draft.plantType.displayName): every ^[\(days) day](inflect: true). Pot, light and season change what a plant needs, so adjust it.")
        }
    }
}
