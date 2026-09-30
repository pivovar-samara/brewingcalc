import Foundation
import Testing
@testable import BrewCalc
// SpyAnalyticsService and AnalyticsEvent: Equatable are defined in AppViewModelTests.swift

struct CalculatorDetailViewModelTests {

    @Test("Gravity converter updates both fields")
    @MainActor
    func gravityConverterUpdates() {
        var category = CalculatorCategory(
            uniqueName: "UniqueTestCategory",
            localizedName: "Test",
            calculators: [GravityConverter()]
        )
        // Set Plato to 12 and calculate
        if case .number(var plato) = category.calculators[0].inputs[0] {
            plato.value = 12.0
            plato.isUsed = true
            category.calculators[0].inputs[0] = .number(plato)
        }
        category.calculators[0].calculate(changedIndex: 0)

        // Check SG output
        if case .number(let sg) = category.calculators[0].inputs[1] {
            #expect(sg.value > 1.0 && sg.value < 1.1, "SG should be reasonable: \(sg.value)")
        }
    }

    @Test("Volume converter updates all fields from litres")
    @MainActor
    func volumeConverterUpdates() {
        var calculator = VolumeConverter()

        if case .number(var litres) = calculator.inputs[0] {
            litres.value = 1.0
            litres.isUsed = true
            calculator.inputs[0] = .number(litres)
        }
        calculator.calculate(changedIndex: 0)

        // Check US gallons (index 7)
        if case .number(let usGal) = calculator.inputs[7] {
            #expect(abs(usGal.value - 0.2642) < 0.01)
        }
    }

    @Test("ABV Table calculator produces output")
    @MainActor
    func abvTableProducesOutput() {
        var calculator = ABVTableCalculator()

        // Set OG to 12 Plato
        if case .number(var og) = calculator.inputs[1] {
            og.value = 12.0
            og.isUsed = true
            calculator.inputs[1] = .number(og)
        }
        calculator.calculate(changedIndex: 1)

        // Set FG to 3 Plato
        if case .number(var fg) = calculator.inputs[2] {
            fg.value = 3.0
            fg.isUsed = true
            calculator.inputs[2] = .number(fg)
        }
        calculator.calculate(changedIndex: 2)

        // Check ABV output
        if case .number(let abv) = calculator.outputs[0] {
            #expect(abv.value > 0.0, "ABV should be positive: \(abv.value)")
        }
    }

    @Test("Bittering calculator with hop input")
    @MainActor
    func bitteringWithHop() {
        var calculator = BitteringCalculator()

        // Set volume to 20L
        if case .number(var vol) = calculator.inputs[2] {
            vol.value = 20.0
            vol.isUsed = true
            calculator.inputs[2] = .number(vol)
        }
        calculator.calculate(changedIndex: 2)

        // Set gravity to 12 Plato
        if case .number(var grav) = calculator.inputs[3] {
            grav.value = 12.0
            grav.isUsed = true
            calculator.inputs[3] = .number(grav)
        }
        calculator.calculate(changedIndex: 3)

        // Set hop 1: 50g, 5% alpha, 60 min
        if case .threeNumbers(var hop) = calculator.inputs[4] {
            hop.number1.value = 50.0
            hop.number1.isUsed = true
            hop.number2.value = 5.0
            hop.number2.isUsed = true
            hop.number3.value = 60.0
            hop.number3.isUsed = true
            calculator.inputs[4] = .threeNumbers(hop)
        }
        calculator.calculate(changedIndex: 4)

        // Check total IBU
        if case .number(let totalIBU) = calculator.outputs[0] {
            #expect(totalIBU.value > 0.0, "Total IBU should be positive: \(totalIBU.value)")
        }
        // Check hop 1 IBU
        if case .number(let hop1IBU) = calculator.outputs[1] {
            #expect(hop1IBU.value > 0.0, "Hop 1 IBU should be positive: \(hop1IBU.value)")
        }
    }

    @Test("Debounce: multiple rapid input changes emit only one calculation event")
    @MainActor
    func rapidInputChangesEmitSingleEvent() async throws {
        let spy = SpyAnalyticsService()
        let categoryName = "Metrics"
        let category = CalculatorCategory(uniqueName: categoryName, localizedName: "Gravity", calculators: [GravityConverter()])
        let vm = CalculatorDetailViewModel(category: category, analytics: spy, debounceDelay: .milliseconds(10))

        await confirmation("single calculationPerformed event after rapid input", expectedCount: 1) { confirm in
            spy.onTrack = { event in
                if case .calculationPerformed = event { confirm() }
            }
            vm.updateInput(calculatorIndex: 0, inputIndex: 0, value: 10.0)
            vm.updateInput(calculatorIndex: 0, inputIndex: 0, value: 11.0)
            vm.updateInput(calculatorIndex: 0, inputIndex: 0, value: 12.0)
            try? await Task.sleep(for: .milliseconds(500))
        }
    }

    @Test("Debounce: emitted event carries correct calculator and category names")
    @MainActor
    func debounceEmitsCorrectNames() async throws {
        let spy = SpyAnalyticsService()
        let categoryName = "Metrics"
        let category = CalculatorCategory(uniqueName: categoryName, localizedName: "Gravity", calculators: [GravityConverter()])
        let vm = CalculatorDetailViewModel(category: category, analytics: spy, debounceDelay: .milliseconds(10))

        await confirmation("calculationPerformed event fired") { confirm in
            spy.onTrack = { event in
                if case .calculationPerformed = event { confirm() }
            }
            vm.updateInput(calculatorIndex: 0, inputIndex: 0, value: 12.0)
            try? await Task.sleep(for: .milliseconds(500))
        }

        let expectedName = GravityConverter().uniqueName
        #expect(spy.trackedEvents == [.calculationPerformed(calculatorName: expectedName, categoryName: categoryName)])
    }

    @Test("Unit switching converts values")
    @MainActor
    func unitSwitchingConverts() {
        var calculator = ABVTableCalculator()

        // Set OG to 12 Plato
        if case .number(var og) = calculator.inputs[1] {
            og.value = 12.0
            og.isUsed = true
            calculator.inputs[1] = .number(og)
        }
        calculator.calculate(changedIndex: 1)

        // Switch to SG
        if case .segmented(var seg) = calculator.inputs[0] {
            seg.selectedIndex = 1
            calculator.inputs[0] = .segmented(seg)
        }
        calculator.calculate(changedIndex: 0)

        // Check that OG has been converted to SG
        if case .number(let og) = calculator.inputs[1] {
            #expect(og.value > 1.0 && og.value < 1.1, "Should be SG now: \(og.value)")
        }
    }

    // MARK: - Dynamic hop list

    private func hopTitle(_ input: CalculatorInput) -> String? {
        if case .threeNumbers(let hop) = input { return hop.title }
        return nil
    }

    private func numberValues(_ inputs: ArraySlice<CalculatorInput>) -> [Double] {
        inputs.compactMap { input in
            if case .number(let n) = input { return n.value }
            return nil
        }
    }

    private func setHop(_ calculator: inout BitteringCalculator, inputIndex: Int, weight: Double, alpha: Double, minutes: Double) {
        if case .threeNumbers(var hop) = calculator.inputs[inputIndex] {
            hop.number1.value = weight
            hop.number2.value = alpha
            hop.number3.value = minutes
            calculator.inputs[inputIndex] = .threeNumbers(hop)
        }
        calculator.calculate(changedIndex: inputIndex)
    }

    @Test("Bittering calculator starts with a single hop")
    func bitteringStartsWithOneHop() {
        let calculator = BitteringCalculator()
        #expect(calculator.hopCount == 1)
        #expect(calculator.inputs.count == BitteringCalculator.firstHopIndex + 1)
        #expect(calculator.outputs.count == 2)
        #expect(calculator.canAddHop)
    }

    @Test("addHop appends a numbered hop and its output")
    func addHopAppends() {
        var calculator = BitteringCalculator()
        calculator.addHop()
        #expect(calculator.hopCount == 2)
        #expect(calculator.outputs.count == 3)
        #expect(hopTitle(calculator.inputs[5]) == String(format: l("calc.bittering.hop.params"), 2))
        if case .number(let out) = calculator.outputs[2] {
            #expect(out.title == String(format: l("calc.bittering.result.hop"), 2))
        }
    }

    @Test("Hop added in US units gets an oz weight title")
    func addHopUsesCurrentUnits() {
        var calculator = BitteringCalculator()
        if case .segmented(var seg) = calculator.inputs[0] {
            seg.selectedIndex = 1
            calculator.inputs[0] = .segmented(seg)
        }
        calculator.calculate(changedIndex: 0)
        calculator.addHop()
        if case .threeNumbers(let hop) = calculator.inputs[5] {
            #expect(hop.number1.title == l("calc.bittering.hop.param.weight.oz"))
        } else {
            Issue.record("Expected a hop input at index 5")
        }
    }

    @Test("addHop stops at the maximum number of hops")
    func addHopRespectsMax() {
        var calculator = BitteringCalculator()
        for _ in 0..<20 { calculator.addHop() }
        #expect(calculator.hopCount == BitteringCalculator.maxHops)
        #expect(calculator.outputs.count == BitteringCalculator.maxHops + 1)
        #expect(!calculator.canAddHop)
    }

    @Test("removeHop removes the hop, its output and renumbers the rest")
    func removeHopRenumbers() {
        var calculator = BitteringCalculator()
        calculator.addHop()
        calculator.addHop()
        setHop(&calculator, inputIndex: 6, weight: 30, alpha: 7, minutes: 15)

        calculator.removeHop(atInputIndex: 5)

        #expect(calculator.hopCount == 2)
        #expect(calculator.outputs.count == 3)
        #expect(hopTitle(calculator.inputs[5]) == String(format: l("calc.bittering.hop.params"), 2))
        if case .threeNumbers(let hop) = calculator.inputs[5] {
            #expect(hop.number1.value == 30)
        }
        if case .number(let out) = calculator.outputs[2] {
            #expect(out.title == String(format: l("calc.bittering.result.hop"), 2))
            #expect(out.value > 0)
        }
    }

    @Test("The last remaining hop cannot be removed")
    func removeLastHopIsNoOp() {
        var calculator = BitteringCalculator()
        calculator.removeHop(atInputIndex: BitteringCalculator.firstHopIndex)
        #expect(calculator.hopCount == 1)
        calculator.removeHop(atInputIndex: 2)
        #expect(calculator.inputs.count == BitteringCalculator.firstHopIndex + 1)
    }

    @Test("Total IBU equals the sum of per-hop IBUs")
    func totalIBUIsSumOfHops() {
        var calculator = BitteringCalculator()
        calculator.addHop()
        calculator.addHop()
        setHop(&calculator, inputIndex: 5, weight: 15, alpha: 6, minutes: 30)
        setHop(&calculator, inputIndex: 6, weight: 10, alpha: 8, minutes: 10)

        var perHop = 0.0
        for output in calculator.outputs.dropFirst() {
            if case .number(let n) = output { perHop += n.value }
        }
        if case .number(let total) = calculator.outputs[0] {
            #expect(abs(total.value - perHop) < 0.0001)
            #expect(total.value > 0)
        }
    }

    @Test("setHopCount clamps to the valid range")
    func setHopCountClamps() {
        var calculator = BitteringCalculator()
        calculator.setHopCount(4)
        #expect(calculator.hopCount == 4)
        #expect(calculator.outputs.count == 5)
        calculator.setHopCount(0)
        #expect(calculator.hopCount == 1)
        calculator.setHopCount(99)
        #expect(calculator.hopCount == BitteringCalculator.maxHops)
    }

    @Test("resetHops leaves a single zeroed hop and zero IBU")
    func resetHopsLeavesSingleZeroedHop() {
        var calculator = BitteringCalculator()
        calculator.addHop()
        calculator.addHop()
        setHop(&calculator, inputIndex: 5, weight: 15, alpha: 6, minutes: 30)
        calculator.resetHops()

        #expect(calculator.hopCount == 1)
        #expect(calculator.outputs.count == 2)
        #expect(hopTitle(calculator.inputs[BitteringCalculator.firstHopIndex]) == String(format: l("calc.bittering.hop.params"), 1))
        if case .threeNumbers(let hop) = calculator.inputs[BitteringCalculator.firstHopIndex] {
            #expect(hop.number1.value == 0)
            #expect(hop.number2.value == 0)
            #expect(hop.number3.value == 0)
        } else {
            Issue.record("Expected a hop input at index \(BitteringCalculator.firstHopIndex)")
        }
        if case .number(let total) = calculator.outputs[0] {
            #expect(total.value == 0)
        }
    }

    @Test("resetHops keeps units, volume and gravity")
    func resetHopsKeepsOtherInputs() {
        var calculator = BitteringCalculator()
        if case .segmented(var seg) = calculator.inputs[0] {
            seg.selectedIndex = 1
            calculator.inputs[0] = .segmented(seg)
        }
        calculator.calculate(changedIndex: 0)
        let before = numberValues(calculator.inputs[0..<BitteringCalculator.firstHopIndex])
        calculator.resetHops()

        #expect(numberValues(calculator.inputs[0..<BitteringCalculator.firstHopIndex]) == before)
        if case .segmented(let seg) = calculator.inputs[0] {
            #expect(seg.selectedIndex == 1)
        }
        if case .threeNumbers(let hop) = calculator.inputs[BitteringCalculator.firstHopIndex] {
            #expect(hop.number1.title == l("calc.bittering.hop.param.weight.oz"))
        } else {
            Issue.record("Expected a hop input at index \(BitteringCalculator.firstHopIndex)")
        }
    }
}
