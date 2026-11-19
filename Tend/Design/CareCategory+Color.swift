import SwiftUI

extension CareCategory {
    /// Soft, earthy colours for the calendar. They are muted on purpose and always come with an icon.
    var color: Color {
        switch self {
        case .plant: Color(.sage)
        case .inspection: Color(.heather)
        case .insurance: Color(.dusk)
        case .tyres: Color(.honey)
        case .cleaning: Color(.mist)
        case .service, .other: Color(.stone)
        }
    }
}
