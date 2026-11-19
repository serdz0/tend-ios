import Foundation

/// A request to show the odometer sheet for one item. Setting it opens the sheet; clearing it closes it.
struct OdometerRequest: Identifiable {
    let item: CareItem
    let purpose: OdometerPurpose

    var id: UUID { item.id }
}
