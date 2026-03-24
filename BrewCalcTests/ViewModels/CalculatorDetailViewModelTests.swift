import Testing
@testable import BrewCalc
// SpyAnalyticsService and AnalyticsEvent: Equatable are defined in AppViewModelTests.swift

struct CalculatorDetailViewModelTests {

    @Test("Gravity converter updates both fields")
    @MainActor
    func gravityConverterUpdates() {
        var category = CalculatorCategory(
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
        let category = CalculatorCategory(localizedName: "Gravity", calculators: [GravityConverter()])
        let vm = CalculatorDetailViewModel(category: category, analytics: spy, debounceDelay: .milliseconds(10))

        vm.updateInput(calculatorIndex: 0, inputIndex: 0, value: 10.0)
        vm.updateInput(calculatorIndex: 0, inputIndex: 0, value: 11.0)
        vm.updateInput(calculatorIndex: 0, inputIndex: 0, value: 12.0)

        try await Task.sleep(for: .milliseconds(50))

        let calcEvents = spy.trackedEvents.filter {
            if case .calculationPerformed = $0 { return true }
            return false
        }
        #expect(calcEvents.count == 1)
    }

    @Test("Debounce: emitted event carries correct calculator and category names")
    @MainActor
    func debounceEmitsCorrectNames() async throws {
        let spy = SpyAnalyticsService()
        let category = CalculatorCategory(localizedName: "Gravity", calculators: [GravityConverter()])
        let vm = CalculatorDetailViewModel(category: category, analytics: spy, debounceDelay: .milliseconds(10))

        vm.updateInput(calculatorIndex: 0, inputIndex: 0, value: 12.0)

        try await Task.sleep(for: .milliseconds(50))

        let expectedName = String(describing: type(of: GravityConverter()))
        #expect(spy.trackedEvents == [.calculationPerformed(calculatorName: expectedName, categoryName: "Gravity")])
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
}
