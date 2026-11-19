import SwiftUI

/// "About 700 km left" or "About 200 km past the limit". An estimate, so it says "about".
struct KilometresLeftText: View {
    let distance: DistanceSchedule
    let now: Date

    var body: some View {
        let left = distance.kmLeft(on: now)
        if left >= 0 {
            Text("About \(left, format: .number) km left")
        } else {
            Text("About \(-left, format: .number) km past the limit")
        }
    }
}
