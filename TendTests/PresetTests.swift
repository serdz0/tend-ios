import Foundation
import Testing
@testable import Tend

/// Watering interval by plant type, and the car task presets.
@MainActor
struct PresetTests {
    @Test func plantTypesHaveTheAgreedWateringIntervals() {
        #expect(PlantType.basil.wateringDays == 3)
        #expect(PlantType.monstera.wateringDays == 7)
        #expect(PlantType.fiddleLeafFig.wateringDays == 7)
        #expect(PlantType.peaceLily.wateringDays == 7)
        #expect(PlantType.orchid.wateringDays == 7)
        #expect(PlantType.ficus.wateringDays == 7)
        #expect(PlantType.pothos.wateringDays == 10)
        #expect(PlantType.snakePlant.wateringDays == 14)
        #expect(PlantType.zzPlant.wateringDays == 14)
        #expect(PlantType.aloeVera.wateringDays == 14)
        #expect(PlantType.succulent.wateringDays == 21)
    }

    @Test func otherPlantHasNoPresetInterval() {
        #expect(PlantType.other.wateringDays == nil)
    }

    @Test func everyPlantTypeExceptOtherHasANameAndAPositiveInterval() {
        for type in PlantType.allCases where type != .other {
            #expect(!type.defaultName.isEmpty)
            #expect((type.wateringDays ?? 0) > 0)
        }
    }

    @Test func carPresetsHaveTheAgreedSchedules() {
        #expect(CarTaskPreset.stk.taskName == "STK inspection")
        #expect(CarTaskPreset.stk.scheduleStyle == .interval(Recurrence(count: 2, unit: .year)))
        #expect(CarTaskPreset.insurance.taskName == "Insurance renewal")
        #expect(CarTaskPreset.insurance.scheduleStyle == .interval(Recurrence(count: 1, unit: .year)))
        #expect(CarTaskPreset.winterTyres.taskName == "Fit winter tyres")
        #expect(CarTaskPreset.winterTyres.scheduleStyle == .yearly(month: 10, day: 31))
        #expect(CarTaskPreset.summerTyres.taskName == "Fit summer tyres")
        #expect(CarTaskPreset.summerTyres.scheduleStyle == .yearly(month: 4, day: 1))
        #expect(CarTaskPreset.oilService.taskName == "Oil service")
        #expect(CarTaskPreset.oilService.scheduleStyle == .distance(intervalKm: 15_000))
    }

    @Test func customCarTaskIsAnOrdinaryRepeatWithNoPresetName() {
        #expect(CarTaskPreset.custom.taskName == "")
        #expect(CarTaskPreset.custom.scheduleStyle == .interval(Recurrence(count: 1, unit: .year)))
    }
}
