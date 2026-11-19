import SwiftUI

/// The top of the form: plant or car, which type or task, and what to call it.
struct ItemWhatSection: View {
    @Binding var draft: ItemDraft
    let isEditing: Bool

    var body: some View {
        Section {
            if !isEditing {
                Picker("What are you adding?", selection: $draft.kind) {
                    ForEach(ItemKind.allCases) { kind in
                        Text(kind.title).tag(kind)
                    }
                }
                .pickerStyle(.segmented)
            }

            switch draft.kind {
            case .plant:
                Picker("What kind of plant?", selection: $draft.plantType) {
                    ForEach(PlantType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                TextField("Give it a name, like Kitchen Monstera", text: $draft.name)
                    .textInputAutocapitalization(.words)
                    .accessibilityLabel("Plant name")
            case .car:
                if !isEditing {
                    Picker("What needs doing?", selection: $draft.carPreset) {
                        ForEach(CarTaskGroup.allCases) { group in
                            Section(group.title) {
                                ForEach(group.presets) { preset in
                                    Text(preset.displayName).tag(preset)
                                }
                            }
                        }
                    }
                }
                if let hint = draft.carPreset.hint {
                    Label(hint, systemImage: "lightbulb")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                if draft.carPreset == .custom {
                    TextField("What needs doing? For example, replace wipers", text: $draft.customTask)
                        .textInputAutocapitalization(.sentences)
                        .accessibilityLabel("Task name")
                }
                TextField("Which car? For example, Family Skoda", text: $draft.name)
                    .textInputAutocapitalization(.words)
            }
        }
    }
}
