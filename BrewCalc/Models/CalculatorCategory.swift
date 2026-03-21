import Foundation

struct CalculatorCategory: Identifiable, Sendable {
    let id: UUID
    var localizedName: String
    var calculators: [any BrewCalculator]
    var instructionFilename: String?

    init(
        id: UUID = UUID(),
        localizedName: String,
        calculators: [any BrewCalculator],
        instructionFilename: String? = nil
    ) {
        self.id = id
        self.localizedName = localizedName
        self.calculators = calculators
        self.instructionFilename = instructionFilename
    }

    static func allCategories() -> [CalculatorCategory] {
        [
            CalculatorCategory(
                localizedName: l("calc.metrics"),
                calculators: [GravityConverter(), VolumeConverter(), WeightConverter(), TemperatureConverter()]
            ),
            CalculatorCategory(
                localizedName: l("calc.calorie"),
                calculators: [CalorieCalculatorModel()]
            ),
            CalculatorCategory(
                localizedName: l("calc.alcohol.table"),
                calculators: [ABVTableCalculator()]
            ),
            CalculatorCategory(
                localizedName: l("calc.alcohol.formula"),
                calculators: [ABVFormulaCalculator()]
            ),
            CalculatorCategory(
                localizedName: l("calc.brix"),
                calculators: [BrixCalculatorModel()],
                instructionFilename: isRussian ? "instr_brix_ru" : "instr_brix_en"
            ),
            CalculatorCategory(
                localizedName: l("calc.bittering"),
                calculators: [BitteringCalculator()]
            ),
        ]
    }
}
