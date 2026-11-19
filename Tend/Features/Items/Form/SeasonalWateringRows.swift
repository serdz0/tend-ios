import SwiftUI

/// Shown instead of the interval stepper when a plant follows the seasons:
/// today's rhythm and the whole year at a glance.
struct SeasonalWateringRows: View {
    let watering: SeasonalWatering
    var now: Date = .now

    var body: some View {
        let season = Season.of(now)
        LabeledContent("Right now") {
            Text("Every \(watering.days(in: season)) days (\(season.name))")
        }
        Text(watering.summary)
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}
