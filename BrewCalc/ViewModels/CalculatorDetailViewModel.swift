import SwiftUI

@Observable
@MainActor
final class CalculatorDetailViewModel {
    var category: CalculatorCategory
    var showInstruction = false

    private let persistableCalculatorNames: Set<String> = [
        "GravityConverter", "VolumeConverter", "WeightConverter", "TemperatureConverter"
    ]

    init(category: CalculatorCategory) {
        self.category = category
        for index in category.calculators.indices {
            let name = String(describing: type(of: category.calculators[index]))
            guard persistableCalculatorNames.contains(name) else { continue }
            var calculator = category.calculators[index]
            CalculatorPersistence.restore(into: &calculator.inputs, forCalculatorNamed: name)
            self.category.calculators[index] = calculator
        }
    }

    private func persistIfNeeded(_ calculator: any BrewCalculator) {
        let name = String(describing: type(of: calculator))
        guard persistableCalculatorNames.contains(name) else { return }
        CalculatorPersistence.save(inputs: calculator.inputs, forCalculatorNamed: name)
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
    }
}
