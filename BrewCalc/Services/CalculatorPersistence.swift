import Foundation

enum CalculatorPersistence {

    static func save(inputs: [CalculatorInput], forCalculatorNamed name: String) {
        let defaults = UserDefaults.standard
        for (index, input) in inputs.enumerated() {
            switch input {
            case .number(let n):
                defaults.set(n.value, forKey: key(calculatorName: name, inputIndex: index))
            case .segmented(let s):
                defaults.set(s.selectedIndex, forKey: key(calculatorName: name, inputIndex: index))
            case .threeNumbers:
                break
            }
        }
    }

    static func restore(into inputs: inout [CalculatorInput], forCalculatorNamed name: String) {
        let defaults = UserDefaults.standard
        for index in inputs.indices {
            let k = key(calculatorName: name, inputIndex: index)
            switch inputs[index] {
            case .number(var n):
                guard defaults.object(forKey: k) != nil else { continue }
                n.value = defaults.double(forKey: k)
                inputs[index] = .number(n)
            case .segmented(var s):
                guard defaults.object(forKey: k) != nil else { continue }
                s.selectedIndex = defaults.integer(forKey: k)
                inputs[index] = .segmented(s)
            case .threeNumbers:
                break
            }
        }
    }

    private static func key(calculatorName: String, inputIndex: Int) -> String {
        "persistence.\(calculatorName).input.\(inputIndex)"
    }
}
