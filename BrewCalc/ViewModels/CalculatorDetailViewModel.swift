import SwiftUI

@Observable
@MainActor
final class CalculatorDetailViewModel {
    var category: CalculatorCategory
    var showInstruction = false

    private let persistableCalculatorNames: Set<String> = [
        "GravityConverter", "VolumeConverter", "WeightConverter", "TemperatureConverter",
        "CalorieCalculatorModel", "ABVTableCalculator", "ABVFormulaCalculator",
        "BrixCalculatorModel", "BitteringCalculator"
    ]

    private let analytics: any AnalyticsService
    private let debounceDelay: Duration
    private let defaults: UserDefaults
    @ObservationIgnored
    private var pendingTrackTask: Task<Void, Never>?

    init(
        category: CalculatorCategory,
        analytics: any AnalyticsService = NoOpAnalyticsService(),
        debounceDelay: Duration = .seconds(1.5),
        defaults: UserDefaults = .standard
    ) {
        self.category = category
        self.analytics = analytics
        self.debounceDelay = debounceDelay
        self.defaults = defaults
        for index in category.calculators.indices {
            let name = String(describing: type(of: category.calculators[index]))
            guard persistableCalculatorNames.contains(name) else { continue }
            var calculator = category.calculators[index]

            // Restore the number of hops before index-based value restore so indices line up.
            if var bittering = calculator as? BitteringCalculator {
                let count = CalculatorPersistence.restoreItemCount(forCalculatorNamed: name, defaults: defaults)
                    ?? CalculatorPersistence.legacyThreeNumbersCount(
                        forCalculatorNamed: name,
                        firstIndex: BitteringCalculator.firstHopIndex,
                        maxLegacyCount: 5,
                        defaults: defaults
                    )
                bittering.setHopCount(count)
                calculator = bittering
            }

            if calculator.outputs.isEmpty {
                // Simple converters: direct restore, all state lives in inputs
                CalculatorPersistence.restore(into: &calculator.inputs, forCalculatorNamed: name, defaults: defaults)
            } else {
                // Two-phase restore for Calorie, ABVTable, ABVFormula, Bittering:
                // Phase 1 — apply saved segment selections via calculate() so that
                //            field titles and numberOfDigits are updated correctly.
                for inputIndex in calculator.inputs.indices {
                    guard case .segmented(let s) = calculator.inputs[inputIndex] else { continue }
                    let k = "persistence.\(name).input.\(inputIndex)"
                    guard defaults.object(forKey: k) != nil else { continue }
                    let savedIndex = defaults.integer(forKey: k)
                    guard s.selectedIndex != savedIndex else { continue }
                    var updated = s
                    updated.selectedIndex = savedIndex
                    calculator.inputs[inputIndex] = .segmented(updated)
                    calculator.calculate(changedIndex: inputIndex)
                }
                // Phase 2 — override number values with the saved values (the segment
                //            switch above converted init defaults; we replace them here).
                CalculatorPersistence.restoreNumbers(into: &calculator.inputs, forCalculatorNamed: name, defaults: defaults)
                // Phase 3 — recompute outputs from restored inputs.
                calculator.calculate(changedIndex: calculator.inputs.count - 1)
            }

            self.category.calculators[index] = calculator
        }
    }

    private func persistIfNeeded(_ calculator: any BrewCalculator) {
        let name = String(describing: type(of: calculator))
        guard persistableCalculatorNames.contains(name) else { return }
        CalculatorPersistence.save(inputs: calculator.inputs, forCalculatorNamed: name, defaults: defaults)
        if let bittering = calculator as? BitteringCalculator {
            CalculatorPersistence.saveItemCount(bittering.hopCount, forCalculatorNamed: name, defaults: defaults)
        }
    }

    private func trackCalculation(calculatorIndex: Int) {
        guard calculatorIndex < category.calculators.count else { return }
        let calculatorName = category.calculators[calculatorIndex].uniqueName
        let categoryName = category.uniqueName

        pendingTrackTask?.cancel()
        pendingTrackTask = Task { @MainActor [analytics, debounceDelay] in
            try? await Task.sleep(for: debounceDelay)
            guard !Task.isCancelled else { return }
            analytics.track(.calculationPerformed(
                calculatorName: calculatorName,
                categoryName: categoryName
            ))
        }
    }

    @MainActor
    deinit {
        pendingTrackTask?.cancel()
    }

    var hasInstructions: Bool {
        guard let filename = category.instructionFilename else { return false }
        return !filename.isEmpty
    }

    func updateInput(calculatorIndex: Int, inputIndex: Int, value: Double) {
        guard calculatorIndex < category.calculators.count else { return }
        var calculator = category.calculators[calculatorIndex]

        if case .number(var input) = calculator.inputs[inputIndex] {
            input.value = value
            input.isUsed = true
            calculator.inputs[inputIndex] = .number(input)
        }

        calculator.calculate(changedIndex: inputIndex)
        category.calculators[calculatorIndex] = calculator
        persistIfNeeded(calculator)
        trackCalculation(calculatorIndex: calculatorIndex)
    }

    func updateThreeNumberInput(calculatorIndex: Int, inputIndex: Int, numberIndex: Int, value: Double) {
        guard calculatorIndex < category.calculators.count else { return }
        var calculator = category.calculators[calculatorIndex]

        if case .threeNumbers(var input) = calculator.inputs[inputIndex] {
            switch numberIndex {
            case 1:
                input.number1.value = value
                input.number1.isUsed = true
            case 2:
                input.number2.value = value
                input.number2.isUsed = true
            case 3:
                input.number3.value = value
                input.number3.isUsed = true
            default: break
            }
            calculator.inputs[inputIndex] = .threeNumbers(input)
        }

        calculator.calculate(changedIndex: inputIndex)
        category.calculators[calculatorIndex] = calculator
        persistIfNeeded(calculator)
        trackCalculation(calculatorIndex: calculatorIndex)
    }

    func updateSegment(calculatorIndex: Int, inputIndex: Int, selectedIndex: Int) {
        guard calculatorIndex < category.calculators.count else { return }
        var calculator = category.calculators[calculatorIndex]

        if case .segmented(var input) = calculator.inputs[inputIndex] {
            input.selectedIndex = selectedIndex
            calculator.inputs[inputIndex] = .segmented(input)
        }

        calculator.calculate(changedIndex: inputIndex)
        category.calculators[calculatorIndex] = calculator
        persistIfNeeded(calculator)
        trackCalculation(calculatorIndex: calculatorIndex)
    }

    // MARK: - Hop list (IBU calculator)

    func canAddHop(calculatorIndex: Int) -> Bool {
        guard calculatorIndex < category.calculators.count,
              let bittering = category.calculators[calculatorIndex] as? BitteringCalculator else { return false }
        return bittering.canAddHop
    }

    func isRemovableHop(calculatorIndex: Int, inputIndex: Int) -> Bool {
        guard calculatorIndex < category.calculators.count,
              let bittering = category.calculators[calculatorIndex] as? BitteringCalculator else { return false }
        return bittering.isHop(inputIndex: inputIndex) && bittering.hopCount > 1
    }

    func addHop(calculatorIndex: Int) {
        guard calculatorIndex < category.calculators.count,
              var bittering = category.calculators[calculatorIndex] as? BitteringCalculator else { return }
        bittering.addHop()
        category.calculators[calculatorIndex] = bittering
        persistIfNeeded(bittering)
        trackCalculation(calculatorIndex: calculatorIndex)
    }

    func canResetHops(calculatorIndex: Int) -> Bool {
        guard calculatorIndex < category.calculators.count else { return false }
        return category.calculators[calculatorIndex] is BitteringCalculator
    }

    func resetHops(calculatorIndex: Int) {
        guard calculatorIndex < category.calculators.count,
              var bittering = category.calculators[calculatorIndex] as? BitteringCalculator else { return }
        bittering.resetHops()
        category.calculators[calculatorIndex] = bittering
        persistIfNeeded(bittering)
        trackCalculation(calculatorIndex: calculatorIndex)
    }

    func removeHop(calculatorIndex: Int, inputIndex: Int) {
        guard calculatorIndex < category.calculators.count,
              var bittering = category.calculators[calculatorIndex] as? BitteringCalculator else { return }
        bittering.removeHop(atInputIndex: inputIndex)
        category.calculators[calculatorIndex] = bittering
        persistIfNeeded(bittering)
        trackCalculation(calculatorIndex: calculatorIndex)
    }
}
