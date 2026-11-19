import Foundation

/// One line on a calendar day.
struct CalendarEntry: Identifiable {
    enum Kind: Int {
        /// Due on this day (also used for overdue items, on the day they were due).
        case due
        /// Not due yet, but this is when it would come round if you do each one on time.
        case expected
        case done
        case snoozed
    }

    let item: CareItem
    let kind: Kind
    /// For done and snoozed: when it happened. Otherwise the start of the day.
    let date: Date

    var id: String {
        "\(item.id)-\(kind.rawValue)-\(date.timeIntervalSince1970)"
    }

    var category: CareCategory {
        CareCategory(item: item)
    }
}
