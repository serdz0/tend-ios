import SwiftUI

/// "About 700 km to go" or "About 200 km past due". An estimate, so it says "about".
struct KilometresLeftText: View {
    let distance: DistanceSchedule
    let now: Date

    var body: some View {
        let left = distance.kmLeft(on: now)
        if left >= 0 {
            Text("About \(left, format: .number) km to go")
        } else {
            Text("About \(-left, format: .number) km past due")
        }
    }
}
