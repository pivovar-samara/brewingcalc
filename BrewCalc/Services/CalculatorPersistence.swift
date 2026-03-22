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
            case .threeNumbers(let t):
                defaults.set(t.number1.value, forKey: subKey(calculatorName: name, inputIndex: index, sub: 1))
                defaults.set(t.number2.value, forKey: subKey(calculatorName: name, inputIndex: index, sub: 2))
                defaults.set(t.number3.value, forKey: subKey(calculatorName: name, inputIndex: index, sub: 3))
            }
        }
    }

    /// Restores only `.number` and `.threeNumbers` values, skipping segments.
    /// Used in phase 2 of the two-phase restore: after segments have already been
    /// applied via `calculate(changedIndex:)` to update titles and numberOfDigits.
    static func restoreNumbers(into inputs: inout [CalculatorInput], forCalculatorNamed name: String) {
        let defaults = UserDefaults.standard
        for index in inputs.indices {
            switch inputs[index] {
            case .number(var n):
                let k = key(calculatorName: name, inputIndex: index)
                guard defaults.object(forKey: k) != nil else { continue }
                n.value = defaults.double(forKey: k)
                inputs[index] = .number(n)
            case .threeNumbers(var t):
                let k1 = subKey(calculatorName: name, inputIndex: index, sub: 1)
                let k2 = subKey(calculatorName: name, inputIndex: index, sub: 2)
                let k3 = subKey(calculatorName: name, inputIndex: index, sub: 3)
                if defaults.object(forKey: k1) != nil { t.number1.value = defaults.double(forKey: k1) }
                if defaults.object(forKey: k2) != nil { t.number2.value = defaults.double(forKey: k2) }
                if defaults.object(forKey: k3) != nil { t.number3.value = defaults.double(forKey: k3) }
                inputs[index] = .threeNumbers(t)
            case .segmented:
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
            case .threeNumbers(var t):
                let k1 = subKey(calculatorName: name, inputIndex: index, sub: 1)
                let k2 = subKey(calculatorName: name, inputIndex: index, sub: 2)
                let k3 = subKey(calculatorName: name, inputIndex: index, sub: 3)
                if defaults.object(forKey: k1) != nil { t.number1.value = defaults.double(forKey: k1) }
                if defaults.object(forKey: k2) != nil { t.number2.value = defaults.double(forKey: k2) }
                if defaults.object(forKey: k3) != nil { t.number3.value = defaults.double(forKey: k3) }
                inputs[index] = .threeNumbers(t)
            }
        }
    }

    private static func key(calculatorName: String, inputIndex: Int) -> String {
        "persistence.\(calculatorName).input.\(inputIndex)"
    }

    private static func subKey(calculatorName: String, inputIndex: Int, sub: Int) -> String {
        "persistence.\(calculatorName).input.\(inputIndex).\(sub)"
    }
}
