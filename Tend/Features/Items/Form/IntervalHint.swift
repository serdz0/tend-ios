import SwiftUI

/// Under the repeat fields: for plants, a friendly note that the interval is only a starting point,
/// plus a season tip for plants whose need changes a lot through the year.
struct IntervalHint: View {
    let draft: ItemDraft

    var body: some View {
        if draft.usesSeasons {
            Text("Tend changes how often you water through the year, so you do not have to. These are general care-guide numbers, so adjust them to suit your plant: switch the seasons off to set your own.")
        } else if draft.kind == .plant, let days = draft.plantType.wateringDays {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("A good starting point for \(draft.plantType.displayName): every \(days) days. Pot, light and season all matter, so adjust it to suit your plant.")
                if let tip = draft.plantType.seasonTip {
                    Text(tip)
                }
            }
        }
    }
}
