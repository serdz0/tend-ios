import SwiftUI

/// The short "how often" line under an item's name. Seasonal plants say what applies right now.
struct ScheduleLine: View {
    let item: CareItem

    var body: some View {
        if let watering = item.activeSeasonalWatering {
            let season = Season.of(.now)
            Text("Every \(watering.days(in: season)) days in \(season.name)")
        } else {
            ScheduleText(schedule: item.schedule)
        }
    }
}
