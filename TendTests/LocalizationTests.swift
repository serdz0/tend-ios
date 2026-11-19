import Foundation
import Testing
@testable import Tend

/// Czech and Ukrainian: every sentence has a translation, plurals follow each language's rules,
/// and names saved in one language are still recognised in another.
@MainActor
struct LocalizationTests {
    private func bundle(_ code: String) throws -> Bundle {
        try #require(Languages.bundles.first { $0.bundlePath.hasSuffix("/\(code).lproj") })
    }

    /// Every key a language knows, from its plain strings and its plural rules.
    private func keys(in code: String) throws -> Set<String> {
        let folder = try bundle(code).bundlePath
        var found = Set<String>()
        for file in ["Localizable.strings", "Localizable.stringsdict"] {
            let table = NSDictionary(contentsOfFile: "\(folder)/\(file)") as? [String: Any] ?? [:]
            found.formUnion(table.keys)
        }
        return found
    }

    // MARK: Nothing is missing

    @Test func allThreeLanguagesAreInTheApp() throws {
        #expect(Languages.bundles.count == Languages.codes.count)
    }

    @Test func czechAndUkrainianHaveEverySentenceEnglishHas() throws {
        let english = try keys(in: "en")
        #expect(english.count > 200)
        #expect(try keys(in: "cs") == english)
        #expect(try keys(in: "uk") == english)
    }

    // MARK: Plurals

    // Plural rules come from the locale, so each test names the language it checks.
    @Test func czechPluralsFollowCzechRules() throws {
        let cs = try bundle("cs")
        func overdue(_ days: Int) -> String { String(localized: "\(days) days overdue", bundle: cs, locale: Locale(identifier: "cs")) }
        #expect(overdue(1) == "1 den po termínu")
        #expect(overdue(2) == "2 dny po termínu")
        #expect(overdue(4) == "4 dny po termínu")
        #expect(overdue(5) == "5 dní po termínu")
        #expect(overdue(14) == "14 dní po termínu")
    }

    @Test func ukrainianPluralsFollowUkrainianRules() throws {
        let uk = try bundle("uk")
        func overdue(_ days: Int) -> String { String(localized: "\(days) days overdue", bundle: uk, locale: Locale(identifier: "uk")) }
        #expect(overdue(1) == "Прострочено: 1 день")
        #expect(overdue(3) == "Прострочено: 3 дні")
        #expect(overdue(5) == "Прострочено: 5 днів")
        #expect(overdue(11) == "Прострочено: 11 днів")
        #expect(overdue(21) == "Прострочено: 21 день")
        #expect(overdue(22) == "Прострочено: 22 дні")
    }

    @Test func aPluralCanSitNextToAnotherPiece() throws {
        let list = "Zalít: Bazalka, Zalít: Fíkus"
        let cs = try bundle("cs")
        #expect(String(localized: "\(1) things are waiting for you: \(list).", bundle: cs, locale: Locale(identifier: "cs")) == "Čeká na vás jedna věc: \(list).")
        #expect(String(localized: "\(3) things are waiting for you: \(list).", bundle: cs, locale: Locale(identifier: "cs")) == "Čekají na vás 3 věci: \(list).")
        #expect(String(localized: "\(7) things are waiting for you: \(list).", bundle: cs, locale: Locale(identifier: "cs")) == "Čeká na vás 7 věcí: \(list).")
    }

    @Test func englishKeepsItsOwnPluralWording() {
        #expect(String(localized: "\(1) things need you today.") == "One little thing needs you today.")
        #expect(String(localized: "\(4) things need you today.") == "4 things need you today.")
    }

    // MARK: Names saved in one language, read in another

    @Test func aStockPlantNameIsRecognisedInEveryLanguage() {
        let names = PlantType.basil.defaultNameInAnyLanguage
        #expect(names.isSuperset(of: ["Basil", "Bazalka", "Базилік"]))
    }

    @Test func aCzechStockNameIsReplacedWhenThePlantTypeChanges() {
        var draft = ItemDraft()
        draft.name = "Bazalka"
        draft.plantType = .orchid
        draft.applyPlantTypeDefaults()
        #expect(draft.name == PlantType.orchid.defaultName)
    }

    @Test func aNameYouTypedYourselfIsKept() {
        var draft = ItemDraft()
        draft.name = "Kitchen window herb"
        draft.plantType = .orchid
        draft.applyPlantTypeDefaults()
        #expect(draft.name == "Kitchen window herb")
    }

    // MARK: Car tasks are saved in English and shown in the phone's language

    @Test func presetsAreSavedInEnglishWhateverThePhoneSpeaks() {
        // The tests run in English, so the saved name and the shown name agree.
        for preset in CarTaskPreset.allCases {
            #expect(preset.localizedName == preset.taskName)
        }
    }

    @Test func aTaskYouTypedIsShownAsYouTypedIt() {
        let item = CareItem(
            name: "Skoda", kind: .car, task: "Replace wipers",
            recurrence: Recurrence(count: 1, unit: .year), dueDate: .now
        )
        #expect(item.displayTask == "Replace wipers")
        #expect(item.title == "Replace wipers")
    }

    @Test func czechAndUkrainianTranslateEveryCarPreset() throws {
        for code in ["cs", "uk"] {
            let b = try bundle(code)
            for preset in CarTaskPreset.allCases where preset != .custom {
                let translated = String(localized: String.LocalizationValue(preset.taskName), bundle: b)
                #expect(translated != preset.taskName, "\(preset.taskName) in \(code)")
            }
        }
    }
}
