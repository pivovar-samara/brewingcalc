import Foundation

struct CalculatorCategory: Identifiable, Sendable {
    let id: UUID
    var uniqueName: String
    var localizedName: String
    var calculators: [any BrewCalculator]
    var instructionFilename: String?

    init(
        id: UUID = UUID(),
        uniqueName: String,
        localizedName: String,
        calculators: [any BrewCalculator],
        instructionFilename: String? = nil
    ) {
        self.id = id
        self.uniqueName = uniqueName
        self.localizedName = localizedName
        self.calculators = calculators
        self.instructionFilename = instructionFilename
    }

    static func allCategories() -> [CalculatorCategory] {
        [
            CalculatorCategory(
                uniqueName: "metrics",
                localizedName: l("calc.metrics"),
                calculators: [GravityConverter(), VolumeConverter(), WeightConverter(), TemperatureConverter()]
            ),
            CalculatorCategory(
                uniqueName: "calorie",
                localizedName: l("calc.calorie"),
                calculators: [CalorieCalculatorModel()]
            ),
            CalculatorCategory(
                uniqueName: "abv-table",
                localizedName: l("calc.alcohol.table"),
                calculators: [ABVTableCalculator()]
            ),
            CalculatorCategory(
                uniqueName: "abv-formula",
                localizedName: l("calc.alcohol.formula"),
                calculators: [ABVFormulaCalculator()]
            ),
            CalculatorCategory(
                uniqueName: "brix",
                localizedName: l("calc.brix"),
                calculators: [BrixCalculatorModel()],
                instructionFilename: l("instruction.brix.filename")
            ),
            CalculatorCategory(
                uniqueName: "bittering",
                localizedName: l("calc.bittering"),
                calculators: [BitteringCalculator()]
            ),
        ]
    }
}
