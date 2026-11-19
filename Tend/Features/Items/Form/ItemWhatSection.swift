import SwiftUI

/// The top of the form: plant or car, which type or task, and what to call it.
struct ItemWhatSection: View {
    @Binding var draft: ItemDraft
    let isEditing: Bool

    var body: some View {
        Section {
            if !isEditing {
                Picker("Kind", selection: $draft.kind) {
                    ForEach(ItemKind.allCases) { kind in
                        Text(kind.title).tag(kind)
                    }
                }
                .pickerStyle(.segmented)
            }

            switch draft.kind {
            case .plant:
                Picker("Type of plant", selection: $draft.plantType) {
                    ForEach(PlantType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                TextField("Name, such as Kitchen Monstera", text: $draft.name)
                    .textInputAutocapitalization(.words)
                    .accessibilityLabel("Plant name")
            case .car:
                if !isEditing {
                    Picker("Task", selection: $draft.carPreset) {
                        ForEach(CarTaskPreset.allCases) { preset in
                            Text(preset.displayName).tag(preset)
                        }
                    }
                }
                if draft.carPreset == .custom {
                    TextField("Task, such as Replace wipers", text: $draft.customTask)
                        .textInputAutocapitalization(.sentences)
                        .accessibilityLabel("Task name")
                }
                TextField("Car name", text: $draft.name)
                    .textInputAutocapitalization(.words)
            }
        }
    }
}
