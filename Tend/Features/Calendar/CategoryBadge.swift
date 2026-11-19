import SwiftUI

/// A small rounded square with the group's icon, tinted in the group's soft colour.
struct CategoryBadge: View {
    let category: CareCategory
    var isFaded = false

    @ScaledMetric(relativeTo: .body) private var size = 36.0

    var body: some View {
        Image(systemName: category.symbolName)
            .foregroundStyle(category.color)
            .frame(width: size, height: size)
            .background(category.color.opacity(isFaded ? 0.1 : 0.2), in: .rect(cornerRadius: 10))
            .opacity(isFaded ? 0.8 : 1)
            .accessibilityHidden(true)
    }
}
