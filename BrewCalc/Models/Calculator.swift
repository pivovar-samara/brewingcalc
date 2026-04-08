import Foundation

protocol BrewCalculator: Identifiable, Sendable {
    var id: UUID { get }
    var uniqueName: String { get }
    var localizedName: String { get }
    var inputs: [CalculatorInput] { get set }
    var outputs: [CalculatorInput] { get }
    var hasSeparateOutputSection: Bool { get }
    var outputSectionName: String? { get }
    mutating func calculate(changedIndex: Int)
}

extension BrewCalculator {
    var hasSeparateOutputSection: Bool { false }
    var outputSectionName: String? { nil }
    var outputs: [CalculatorInput] { [] }

    mutating func markAllUsed() {
        for i in inputs.indices {
            if case .number(var input) = inputs[i] {
                input.isUsed = true
                inputs[i] = .number(input)
            }
        }
    }
}

// MARK: - Gravity Converter

struct GravityConverter: BrewCalculator {
    let id = UUID()
    var uniqueName: String { "gravity" }
    var localizedName: String { l("calc.gravity") }
    var inputs: [CalculatorInput]

    init() {
        inputs = [
            .number(NumberInput(title: l("calc.gravity.plato"), value: 12.0, numberOfDigits: 2)),
            .number(NumberInput(title: l("calc.gravity.kgl"))),
        ]
        calculate(changedIndex: 0)
    }

    mutating func calculate(changedIndex: Int) {
        markAllUsed()
        guard case .number(let changed) = inputs[changedIndex] else { return }
        let source = changed.value

        let sg: Double
        switch changedIndex {
        case 0: sg = UnitConverter.Gravity.sgFromPlato(source)
        case 1: sg = source
        default: return
        }

        if case .number(var plato) = inputs[0] {
            plato.value = UnitConverter.Gravity.platoFromSG(sg)
            inputs[0] = .number(plato)
        }
        if case .number(var sgInput) = inputs[1] {
            sgInput.value = sg
            inputs[1] = .number(sgInput)
        }
    }
}

// MARK: - Volume Converter

struct VolumeConverter: BrewCalculator {
    let id = UUID()
    var uniqueName: String { "volume" }
    var localizedName: String { l("metrics.volume") }
    var inputs: [CalculatorInput]

    init() {
        inputs = [
            .number(NumberInput(title: l("calc.metrics.litres"), value: 1.0)),
            .number(NumberInput(title: l("calc.metrics.decalitres"), numberOfDigits: 4)),
            .number(NumberInput(title: l("calc.metrics.hectolitres"), numberOfDigits: 5)),
            .number(NumberInput(title: l("calc.metrics.millilitres"), numberOfDigits: 0)),
            .number(NumberInput(title: l("calc.metrics.enggallon"), numberOfDigits: 4)),
            .number(NumberInput(title: l("calc.metrics.engunc"), numberOfDigits: 2)),
            .number(NumberInput(title: l("calc.metrics.engpint"))),
            .number(NumberInput(title: l("calc.metrics.usgallon"), numberOfDigits: 4)),
            .number(NumberInput(title: l("calc.metrics.usunc"), numberOfDigits: 2)),
            .number(NumberInput(title: l("calc.metrics.uspint"))),
        ]
        calculate(changedIndex: 0)
    }

    mutating func calculate(changedIndex: Int) {
        markAllUsed()
        guard case .number(let changed) = inputs[changedIndex] else { return }
        let litres = UnitConverter.Volume.toLitres(changed.value, fromIndex: changedIndex)
        let all = UnitConverter.Volume.allFromLitres(litres)
        for i in inputs.indices {
            if case .number(var input) = inputs[i] {
                input.value = all[i]
                inputs[i] = .number(input)
            }
        }
    }
}

// MARK: - Weight Converter

struct WeightConverter: BrewCalculator {
    let id = UUID()
    var uniqueName: String { "weight" }
    var localizedName: String { l("metrics.weight") }
    var inputs: [CalculatorInput]

    init() {
        inputs = [
            .number(NumberInput(title: l("calc.metrics.kilogramm"), value: 1.0)),
            .number(NumberInput(title: l("calc.metrics.gramm"), numberOfDigits: 0)),
            .number(NumberInput(title: l("calc.metrics.unc"), numberOfDigits: 2)),
            .number(NumberInput(title: l("calc.metrics.funt"))),
        ]
        calculate(changedIndex: 0)
    }

    mutating func calculate(changedIndex: Int) {
        markAllUsed()
        guard case .number(let changed) = inputs[changedIndex] else { return }
        let kg = UnitConverter.Weight.toKg(changed.value, fromIndex: changedIndex)
        let all = UnitConverter.Weight.allFromKg(kg)
        for i in inputs.indices {
            if case .number(var input) = inputs[i] {
                input.value = all[i]
                inputs[i] = .number(input)
            }
        }
    }
}

// MARK: - Temperature Converter

struct TemperatureConverter: BrewCalculator {
    let id = UUID()
    var uniqueName: String { "temperature" }
    var localizedName: String { l("metrics.temperature") }
    var inputs: [CalculatorInput]

    init() {
        inputs = [
            .number(NumberInput(title: l("calc.metrics.celsius"), value: 20.0, numberOfDigits: 1)),
            .number(NumberInput(title: l("calc.metrics.fahrenheit"), numberOfDigits: 1)),
            .number(NumberInput(title: l("calc.metrics.kelvin"), numberOfDigits: 1)),
        ]
        calculate(changedIndex: 0)
    }

    mutating func calculate(changedIndex: Int) {
        markAllUsed()
        guard case .number(let changed) = inputs[changedIndex] else { return }
        let celsius = UnitConverter.Temperature.toCelsius(changed.value, fromIndex: changedIndex)
        let all = UnitConverter.Temperature.allFromCelsius(celsius)
        for i in inputs.indices {
            if case .number(var input) = inputs[i] {
                input.value = all[i]
                inputs[i] = .number(input)
            }
        }
    }
}

// MARK: - Calorie Calculator

struct CalorieCalculatorModel: BrewCalculator {
    let id = UUID()
    var uniqueName: String { "calorie" }
    var localizedName: String { l("calc.calorie.input") }
    var hasSeparateOutputSection: Bool { true }
    var outputSectionName: String? { l("calc.calorie.result") }
    var inputs: [CalculatorInput]
    var outputs: [CalculatorInput]

    init() {
        inputs = [
            .segmented(SegmentedInput(segments: [l("segment.units.plato"), l("segment.units.gravity")], selectedIndex: 0)),
            .segmented(SegmentedInput(segments: [l("segment.units.litres"), l("segment.units.gallons")], selectedIndex: 0)),
            .number(NumberInput(title: l("calc.calorie.volume"), value: 20.0, numberOfDigits: 1)),
            .number(NumberInput(title: l("calc.calorie.og"), value: 12.0, numberOfDigits: 2)),
            .number(NumberInput(title: l("calc.calorie.fg"), value: 3.0, numberOfDigits: 2)),
        ]
        outputs = [
            .number(NumberInput(title: l("calc.calorie.general"), numberOfDigits: 1, isEditable: false)),
            .number(NumberInput(title: l("calc.calorie.100g"), numberOfDigits: 1, isEditable: false)),
        ]
        calculate(changedIndex: 4)
    }

    mutating func calculate(changedIndex: Int) {
        markAllUsed()

        // Handle unit switching for gravity (index 0)
        if changedIndex == 0, case .segmented(let seg) = inputs[0] {
            if seg.selectedIndex == 0 {
                // Convert to Plato
                if case .number(var og) = inputs[3] {
                    og.value = UnitConverter.Gravity.platoFromSG(og.value)
                    og.title = l("calc.calorie.og")
                    og.numberOfDigits = 2
                    inputs[3] = .number(og)
                }
                if case .number(var fg) = inputs[4] {
                    fg.value = UnitConverter.Gravity.platoFromSG(fg.value)
                    fg.title = l("calc.calorie.fg")
                    fg.numberOfDigits = 2
                    inputs[4] = .number(fg)
                }
            } else {
                // Convert to SG
                if case .number(var og) = inputs[3] {
                    og.value = UnitConverter.Gravity.sgFromPlato(og.value)
                    og.title = l("calc.calorie.og")
                    og.numberOfDigits = 3
                    inputs[3] = .number(og)
                }
                if case .number(var fg) = inputs[4] {
                    fg.value = UnitConverter.Gravity.sgFromPlato(fg.value)
                    fg.title = l("calc.calorie.fg")
                    fg.numberOfDigits = 3
                    inputs[4] = .number(fg)
                }
            }
        }

        // Handle unit switching for volume (index 1)
        if changedIndex == 1, case .segmented(let seg) = inputs[1] {
            if case .number(var vol) = inputs[2] {
                if seg.selectedIndex == 0 {
                    vol.value = UnitConverter.Volume.litresFromUSGallon(vol.value)
                } else {
                    vol.value = UnitConverter.Volume.usGallonFromLitres(vol.value)
                }
                vol.numberOfDigits = 1
                inputs[2] = .number(vol)
            }
        }

        // Get values for calculation - convert to Plato and litres
        var ogPlato = 0.0
        var fgPlato = 0.0
        var volLitres = 0.0

        if case .number(let vol) = inputs[2] { volLitres = vol.value }
        if case .number(let og) = inputs[3] { ogPlato = og.value }
        if case .number(let fg) = inputs[4] { fgPlato = fg.value }

        if case .segmented(let seg) = inputs[0], seg.selectedIndex == 1 {
            ogPlato = UnitConverter.Gravity.platoFromSG(ogPlato)
            fgPlato = UnitConverter.Gravity.platoFromSG(fgPlato)
        }
        if case .segmented(let seg) = inputs[1], seg.selectedIndex == 1 {
            volLitres = UnitConverter.Volume.litresFromUSGallon(volLitres)
        }

        let total = CalorieCalculator.calories(ogPlato: ogPlato, fgPlato: fgPlato, volumeLitres: volLitres)
        let per100ml = round(10.0 * (0.1 * total / volLitres)) / 10.0

        if case .number(var out) = outputs[0] {
            out.value = total
            outputs[0] = .number(out)
        }
        if case .number(var out) = outputs[1] {
            out.value = per100ml
            outputs[1] = .number(out)
        }
    }
}

// MARK: - ABV Table Calculator

struct ABVTableCalculator: BrewCalculator {
    let id = UUID()
    var uniqueName: String { "abv-table" }
    var localizedName: String { l("calc.alcohol.table.input") }
    var hasSeparateOutputSection: Bool { true }
    var outputSectionName: String? { l("calc.alcohol.table.result") }
    var inputs: [CalculatorInput]
    var outputs: [CalculatorInput]

    init() {
        inputs = [
            .segmented(SegmentedInput(segments: [l("segment.units.plato"), l("segment.units.gravity")], selectedIndex: 0)),
            .number(NumberInput(title: l("calc.alcohol.table.plato.begin"), value: 12.0, numberOfDigits: 2)),
            .number(NumberInput(title: l("calc.alcohol.table.plato.end"), value: 3.0, numberOfDigits: 2)),
        ]
        outputs = [
            .number(NumberInput(title: l("calc.alcohol.table.abv"), numberOfDigits: 2, isEditable: false)),
        ]
        calculate(changedIndex: 2)
    }

    mutating func calculate(changedIndex: Int) {
        markAllUsed()

        if changedIndex == 0, case .segmented(let seg) = inputs[0] {
            if seg.selectedIndex == 0 {
                if case .number(var og) = inputs[1] {
                    og.value = UnitConverter.Gravity.platoFromSG(og.value)
                    og.title = l("calc.alcohol.table.plato.begin")
                    og.numberOfDigits = 2
                    inputs[1] = .number(og)
                }
                if case .number(var fg) = inputs[2] {
                    fg.value = UnitConverter.Gravity.platoFromSG(fg.value)
                    fg.title = l("calc.alcohol.table.plato.end")
                    fg.numberOfDigits = 2
                    inputs[2] = .number(fg)
                }
            } else {
                if case .number(var og) = inputs[1] {
                    og.value = UnitConverter.Gravity.sgFromPlato(og.value)
                    og.title = l("calc.alcohol.table.kgl.begin")
                    og.numberOfDigits = 3
                    inputs[1] = .number(og)
                }
                if case .number(var fg) = inputs[2] {
                    fg.value = UnitConverter.Gravity.sgFromPlato(fg.value)
                    fg.title = l("calc.alcohol.table.kgl.end")
                    fg.numberOfDigits = 3
                    inputs[2] = .number(fg)
                }
            }
        }

        var og = 0.0
        var fg = 0.0
        if case .number(let ogInput) = inputs[1] { og = ogInput.value }
        if case .number(let fgInput) = inputs[2] { fg = fgInput.value }

        if case .segmented(let seg) = inputs[0], seg.selectedIndex == 0 {
            og = UnitConverter.Gravity.sgFromPlato(og)
            fg = UnitConverter.Gravity.sgFromPlato(fg)
        }

        if case .number(var abv) = outputs[0] {
            abv.value = ABVCalculator.abvFromTable(og: og, fg: fg)
            outputs[0] = .number(abv)
        }
    }
}

// MARK: - ABV Formula Calculator

struct ABVFormulaCalculator: BrewCalculator {
    let id = UUID()
    var uniqueName: String { "abv-formula" }
    var localizedName: String { l("calc.alcohol.formula.input") }
    var hasSeparateOutputSection: Bool { true }
    var outputSectionName: String? { l("calc.alcohol.formula.result") }
    var inputs: [CalculatorInput]
    var outputs: [CalculatorInput]

    init() {
        inputs = [
            .segmented(SegmentedInput(segments: [l("segment.units.plato"), l("segment.units.gravity")], selectedIndex: 0)),
            .segmented(SegmentedInput(segments: [l("segment.units.celsii"), l("segment.units.farenheit")], selectedIndex: 0)),
            .number(NumberInput(title: l("calc.alcohol.formula.plato.begin"), value: 12.0, numberOfDigits: 2)),
            .number(NumberInput(title: l("calc.alcohol.formula.temp.begin"), value: 20.0, numberOfDigits: 1)),
            .number(NumberInput(title: l("calc.alcohol.formula.plato.end"), value: 3.0, numberOfDigits: 2)),
            .number(NumberInput(title: l("calc.alcohol.formula.temp.end"), value: 20.0, numberOfDigits: 1)),
        ]
        outputs = [
            .number(NumberInput(title: l("calc.alcohol.formula.abv"), numberOfDigits: 2, isEditable: false)),
        ]
        calculate(changedIndex: 5)
    }

    mutating func calculate(changedIndex: Int) {
        markAllUsed()

        // Handle gravity unit switch
        if changedIndex == 0, case .segmented(let seg) = inputs[0] {
            if seg.selectedIndex == 0 {
                if case .number(var og) = inputs[2] {
                    og.value = UnitConverter.Gravity.platoFromSG(og.value)
                    og.title = l("calc.alcohol.formula.plato.begin")
                    og.numberOfDigits = 2
                    inputs[2] = .number(og)
                }
                if case .number(var fg) = inputs[4] {
                    fg.value = UnitConverter.Gravity.platoFromSG(fg.value)
                    fg.title = l("calc.alcohol.formula.plato.end")
                    fg.numberOfDigits = 2
                    inputs[4] = .number(fg)
                }
            } else {
                if case .number(var og) = inputs[2] {
                    og.value = UnitConverter.Gravity.sgFromPlato(og.value)
                    og.title = l("calc.alcohol.formula.plato.begin")
                    og.numberOfDigits = 3
                    inputs[2] = .number(og)
                }
                if case .number(var fg) = inputs[4] {
                    fg.value = UnitConverter.Gravity.sgFromPlato(fg.value)
                    fg.title = l("calc.alcohol.formula.plato.end")
                    fg.numberOfDigits = 3
                    inputs[4] = .number(fg)
                }
            }
        }

        // Handle temperature unit switch
        if changedIndex == 1, case .segmented(let seg) = inputs[1] {
            if seg.selectedIndex == 0 {
                if case .number(var ot) = inputs[3] {
                    ot.value = UnitConverter.Temperature.celsiusFromFahrenheit(ot.value)
                    ot.numberOfDigits = 1
                    inputs[3] = .number(ot)
                }
                if case .number(var ft) = inputs[5] {
                    ft.value = UnitConverter.Temperature.celsiusFromFahrenheit(ft.value)
                    ft.numberOfDigits = 1
                    inputs[5] = .number(ft)
                }
            } else {
                if case .number(var ot) = inputs[3] {
                    ot.value = UnitConverter.Temperature.fahrenheitFromCelsius(ot.value)
                    ot.numberOfDigits = 1
                    inputs[3] = .number(ot)
                }
                if case .number(var ft) = inputs[5] {
                    ft.value = UnitConverter.Temperature.fahrenheitFromCelsius(ft.value)
                    ft.numberOfDigits = 1
                    inputs[5] = .number(ft)
                }
            }
        }

        // Get values for calculation
        var ogPlato = 0.0
        var otCelsius = 0.0
        var fgPlato = 0.0
        var ftCelsius = 0.0

        if case .number(let og) = inputs[2] { ogPlato = og.value }
        if case .number(let ot) = inputs[3] { otCelsius = ot.value }
        if case .number(let fg) = inputs[4] { fgPlato = fg.value }
        if case .number(let ft) = inputs[5] { ftCelsius = ft.value }

        // Convert to Plato if in SG mode
        if case .segmented(let seg) = inputs[0], seg.selectedIndex == 1 {
            ogPlato = UnitConverter.Gravity.platoFromSG(ogPlato)
            fgPlato = UnitConverter.Gravity.platoFromSG(fgPlato)
        }
        // Convert to Celsius if in Fahrenheit mode
        if case .segmented(let seg) = inputs[1], seg.selectedIndex == 1 {
            otCelsius = UnitConverter.Temperature.celsiusFromFahrenheit(otCelsius)
            ftCelsius = UnitConverter.Temperature.celsiusFromFahrenheit(ftCelsius)
        }

        if case .number(var abv) = outputs[0] {
            abv.value = ABVCalculator.abvFromFormula(ogPlato: ogPlato, ogTempC: otCelsius, fgPlato: fgPlato, fgTempC: ftCelsius)
            outputs[0] = .number(abv)
        }
    }
}

// MARK: - Brix Calculator

struct BrixCalculatorModel: BrewCalculator {
    let id = UUID()
    var uniqueName: String { "brix" }
    var localizedName: String { l("calc.brixes.gravity.input") }
    var hasSeparateOutputSection: Bool { true }
    var outputSectionName: String? { l("calc.brixes.gravity.output") }
    var inputs: [CalculatorInput]
    var outputs: [CalculatorInput]

    init() {
        inputs = [
            .segmented(SegmentedInput(segments: [l("segment.units.plato"), l("segment.units.gravity")], selectedIndex: 0)),
            .segmented(SegmentedInput(segments: [l("segment.refractometer.brix"), l("segment.refractometer.gravity")], selectedIndex: 0)),
            .number(NumberInput(title: l("calc.brixes.gravity.kpd"), value: 1.04, numberOfDigits: 2)),
            .number(NumberInput(title: l("calc.brixes.gravity.ob"), value: 12.0, numberOfDigits: 2)),
            .number(NumberInput(title: l("calc.brixes.gravity.fb"), value: 3.0, numberOfDigits: 2)),
        ]
        outputs = [
            .number(NumberInput(title: l("calc.brixes.gravity.og"), numberOfDigits: 2, isEditable: false)),
            .number(NumberInput(title: l("calc.brixes.gravity.fg"), numberOfDigits: 2, isEditable: false)),
            .number(NumberInput(title: l("calc.brixes.gravity.abv"), numberOfDigits: 2, isEditable: false)),
        ]
        calculate(changedIndex: 4)
    }

    mutating func calculate(changedIndex: Int) {
        markAllUsed()

        var koef = 1.04
        if case .number(let koefInput) = inputs[2] { koef = koefInput.value }

        // Handle output unit switching (Plato <-> SG) at index 0
        if changedIndex == 0, case .segmented(let seg0) = inputs[0] {
            if case .segmented(let seg1) = inputs[1] {
                switch seg1.selectedIndex {
                case 0:
                    // Mode: Brix inputs
                    if seg0.selectedIndex == 0 {
                        // Convert outputs to Plato
                        if case .number(var og) = outputs[0] {
                            og.value = UnitConverter.Gravity.platoFromSG(og.value)
                            og.numberOfDigits = 2
                            outputs[0] = .number(og)
                        }
                        if case .number(var fg) = outputs[1] {
                            fg.value = UnitConverter.Gravity.platoFromSG(fg.value)
                            fg.numberOfDigits = 2
                            outputs[1] = .number(fg)
                        }
                    } else {
                        // Convert outputs to SG
                        if case .number(var og) = outputs[0] {
                            og.value = UnitConverter.Gravity.sgFromPlato(og.value)
                            og.numberOfDigits = 3
                            outputs[0] = .number(og)
                        }
                        if case .number(var fg) = outputs[1] {
                            fg.value = UnitConverter.Gravity.sgFromPlato(fg.value)
                            fg.numberOfDigits = 3
                            outputs[1] = .number(fg)
                        }
                    }
                case 1:
                    // Mode: Final measurements
                    if seg0.selectedIndex == 0 {
                        // Convert input[3] (FG) and output[0] (OG) to Plato
                        if case .number(var fgInput) = inputs[3] {
                            fgInput.value = UnitConverter.Gravity.platoFromSG(fgInput.value)
                            fgInput.numberOfDigits = 2
                            inputs[3] = .number(fgInput)
                        }
                        if case .number(var og) = outputs[0] {
                            og.value = UnitConverter.Gravity.platoFromSG(og.value)
                            og.numberOfDigits = 2
                            outputs[0] = .number(og)
                        }
                    } else {
                        // Convert to SG
                        if case .number(var fgInput) = inputs[3] {
                            fgInput.value = UnitConverter.Gravity.sgFromPlato(fgInput.value)
                            fgInput.numberOfDigits = 3
                            inputs[3] = .number(fgInput)
                        }
                        if case .number(var og) = outputs[0] {
                            og.value = UnitConverter.Gravity.sgFromPlato(og.value)
                            og.numberOfDigits = 3
                            outputs[0] = .number(og)
                        }
                    }
                default: break
                }
            }
        }

        // Handle mode switching (Brix <-> Final measurements) at index 1
        if changedIndex == 1, case .segmented(let seg1) = inputs[1] {
            switch seg1.selectedIndex {
            case 0:
                // Switching TO Brix mode: swap output[1] back to input[3], input[3] to output[1]
                if case .number(let ogbrix) = outputs[1] {
                    let swapped = inputs[3]
                    inputs[3] = .number(NumberInput(
                        title: ogbrix.title,
                        value: round(100.0 * ogbrix.value * koef) / 100.0,
                        numberOfDigits: ogbrix.numberOfDigits
                    ))
                    // The field moves back to the output section — mark it non-editable
                    if case .number(var fg) = swapped {
                        fg.isEditable = false
                        outputs[1] = .number(fg)
                    }
                }
            case 1:
                // Switching TO Final measurements mode: swap input[3] to output[1], output[1] to input[3]
                if case .number(let ogbrix) = inputs[3] {
                    let swapped = outputs[1]
                    // The field moves into the input section — mark it editable
                    if case .number(var fg) = swapped {
                        fg.isEditable = true
                        inputs[3] = .number(fg)
                    }
                    outputs[1] = .number(ogbrix)
                }
            default: break
            }
        }

        // Get current values
        var inp1 = 0.0
        var inp2 = 0.0
        if case .number(let i3) = inputs[3] { inp1 = i3.value }
        if case .number(let i4) = inputs[4] { inp2 = i4.value }

        guard case .segmented(let seg0) = inputs[0],
              case .segmented(let seg1) = inputs[1] else { return }

        var out1 = 0.0
        var out2 = 0.0
        var out3 = 0.0

        switch seg1.selectedIndex {
        case 0:
            // Brix input mode
            out1 = BrixCalculator.gravityFromBrix(inp1 / koef)
            out2 = BrixCalculator.gravityFromOBFB(ob: inp1 / koef, fb: inp2 / koef)
            out3 = BrixCalculator.abv(correctedBrix: inp2 / koef, currentGravity: out2)

            if case .number(var og) = outputs[0] {
                og.value = out1
                outputs[0] = .number(og)
            }
            if case .number(var fg) = outputs[1] {
                fg.value = out2
                outputs[1] = .number(fg)
            }
            if case .number(var abv) = outputs[2] {
                abv.value = out3
                outputs[2] = .number(abv)
            }

            // Convert outputs to Plato if needed
            if seg0.selectedIndex == 0 {
                if case .number(var og) = outputs[0] {
                    og.value = UnitConverter.Gravity.platoFromSG(og.value)
                    og.numberOfDigits = 2
                    outputs[0] = .number(og)
                }
                if case .number(var fg) = outputs[1] {
                    fg.value = UnitConverter.Gravity.platoFromSG(fg.value)
                    fg.numberOfDigits = 2
                    outputs[1] = .number(fg)
                }
            } else {
                if case .number(var og) = outputs[0] {
                    og.numberOfDigits = 3
                    outputs[0] = .number(og)
                }
                if case .number(var fg) = outputs[1] {
                    fg.numberOfDigits = 3
                    outputs[1] = .number(fg)
                }
            }

        case 1:
            // Final measurements mode
            var inp1ForCalc = inp1
            if seg0.selectedIndex == 0 {
                inp1ForCalc = UnitConverter.Gravity.sgFromPlato(inp1)
            }
            out3 = BrixCalculator.abv(correctedBrix: inp2 / koef, currentGravity: inp1ForCalc)
            out1 = BrixCalculator.ogFromBrix(correctedBrix: inp2 / koef, currentGravity: inp1ForCalc)
            out2 = BrixCalculator.brixFromGravity(out1)

            if case .number(var og) = outputs[0] {
                og.value = out1
                outputs[0] = .number(og)
            }
            if case .number(var brix) = outputs[1] {
                brix.value = out2
                outputs[1] = .number(brix)
            }
            if case .number(var abv) = outputs[2] {
                abv.value = out3
                outputs[2] = .number(abv)
            }

            // Convert OG output to Plato if needed
            if seg0.selectedIndex == 0 {
                if case .number(var og) = outputs[0] {
                    og.value = UnitConverter.Gravity.platoFromSG(out1)
                    og.numberOfDigits = 2
                    outputs[0] = .number(og)
                }
            } else {
                if case .number(var og) = outputs[0] {
                    og.numberOfDigits = 3
                    outputs[0] = .number(og)
                }
            }

        default: break
        }
    }
}

// MARK: - Bittering (IBU) Calculator

struct BitteringCalculator: BrewCalculator {
    let id = UUID()
    var uniqueName: String { "bittering" }
    var localizedName: String { l("calc.bittering.input") }
    var hasSeparateOutputSection: Bool { true }
    var outputSectionName: String? { l("calc.bittering.output") }
    var inputs: [CalculatorInput]
    var outputs: [CalculatorInput]

    init() {
        inputs = [
            .segmented(SegmentedInput(segments: [l("segment.units.metric"), l("segment.units.us")], selectedIndex: 0)),
            .segmented(SegmentedInput(segments: [l("segment.units.plato"), l("segment.units.gravity")], selectedIndex: 0)),
            .number(NumberInput(title: l("calc.bittering.volume.litres"), value: 20.0, numberOfDigits: 1)),
            .number(NumberInput(title: l("calc.bittering.gravity.plato"), value: 12.0, numberOfDigits: 2)),
            .threeNumbers(ThreeNumbersInput(
                title: l("calc.bittering.hop1.params"),
                number1: NumberInput(title: l("calc.bittering.hop.param.weight.gram"), value: 20.0, numberOfDigits: 1),
                number2: NumberInput(title: l("calc.bittering.hop.param.alpha"), value: 5.0, numberOfDigits: 1),
                number3: NumberInput(title: l("calc.bittering.hop.param.min"), value: 60.0, numberOfDigits: 1)
            )),
            .threeNumbers(ThreeNumbersInput(
                title: l("calc.bittering.hop2.params"),
                number1: NumberInput(title: l("calc.bittering.hop.param.weight.gram"), numberOfDigits: 1),
                number2: NumberInput(title: l("calc.bittering.hop.param.alpha"), numberOfDigits: 1),
                number3: NumberInput(title: l("calc.bittering.hop.param.min"), numberOfDigits: 1)
            )),
            .threeNumbers(ThreeNumbersInput(
                title: l("calc.bittering.hop3.params"),
                number1: NumberInput(title: l("calc.bittering.hop.param.weight.gram"), numberOfDigits: 1),
                number2: NumberInput(title: l("calc.bittering.hop.param.alpha"), numberOfDigits: 1),
                number3: NumberInput(title: l("calc.bittering.hop.param.min"), numberOfDigits: 1)
            )),
            .threeNumbers(ThreeNumbersInput(
                title: l("calc.bittering.hop4.params"),
                number1: NumberInput(title: l("calc.bittering.hop.param.weight.gram"), numberOfDigits: 1),
                number2: NumberInput(title: l("calc.bittering.hop.param.alpha"), numberOfDigits: 1),
                number3: NumberInput(title: l("calc.bittering.hop.param.min"), numberOfDigits: 1)
            )),
            .threeNumbers(ThreeNumbersInput(
                title: l("calc.bittering.hop5.params"),
                number1: NumberInput(title: l("calc.bittering.hop.param.weight.gram"), numberOfDigits: 1),
                number2: NumberInput(title: l("calc.bittering.hop.param.alpha"), numberOfDigits: 1),
                number3: NumberInput(title: l("calc.bittering.hop.param.min"), numberOfDigits: 1)
            )),
        ]
        outputs = [
            .number(NumberInput(title: l("calc.bittering.result"), numberOfDigits: 1, isEditable: false)),
            .number(NumberInput(title: l("calc.bittering.result.hop1"), numberOfDigits: 1, isEditable: false)),
            .number(NumberInput(title: l("calc.bittering.result.hop2"), numberOfDigits: 1, isEditable: false)),
            .number(NumberInput(title: l("calc.bittering.result.hop3"), numberOfDigits: 1, isEditable: false)),
            .number(NumberInput(title: l("calc.bittering.result.hop4"), numberOfDigits: 1, isEditable: false)),
            .number(NumberInput(title: l("calc.bittering.result.hop5"), numberOfDigits: 1, isEditable: false)),
        ]
        calculate(changedIndex: 8)
    }

    mutating func calculate(changedIndex: Int) {
        markAllUsed()

        // Handle unit system switch (Metric <-> US)
        if changedIndex == 0, case .segmented(let seg) = inputs[0] {
            if seg.selectedIndex == 0 {
                // Convert to Metric
                if case .number(var vol) = inputs[2] {
                    vol.value = UnitConverter.Volume.litresFromUSGallon(vol.value)
                    vol.title = l("calc.bittering.volume.litres")
                    vol.numberOfDigits = 1
                    inputs[2] = .number(vol)
                }
                for i in 4...8 {
                    if case .threeNumbers(var hop) = inputs[i] {
                        hop.number1.value = UnitConverter.Weight.gramsFromOz(hop.number1.value)
                        hop.number1.title = l("calc.bittering.hop.param.weight.gram")
                        hop.number1.numberOfDigits = 1
                        inputs[i] = .threeNumbers(hop)
                    }
                }
            } else {
                // Convert to US
                if case .number(var vol) = inputs[2] {
                    vol.value = UnitConverter.Volume.usGallonFromLitres(vol.value)
                    vol.title = l("calc.bittering.volume.gal")
                    vol.numberOfDigits = 1
                    inputs[2] = .number(vol)
                }
                for i in 4...8 {
                    if case .threeNumbers(var hop) = inputs[i] {
                        hop.number1.value = UnitConverter.Weight.ozFromGrams(hop.number1.value)
                        hop.number1.title = l("calc.bittering.hop.param.weight.oz")
                        hop.number1.numberOfDigits = 1
                        inputs[i] = .threeNumbers(hop)
                    }
                }
            }
        }

        // Handle gravity unit switch (Plato <-> SG)
        if changedIndex == 1, case .segmented(let seg) = inputs[1] {
            if case .number(var grav) = inputs[3] {
                if seg.selectedIndex == 0 {
                    grav.value = UnitConverter.Gravity.platoFromSG(grav.value)
                    grav.title = l("calc.bittering.gravity.plato")
                    grav.numberOfDigits = 2
                } else {
                    grav.value = UnitConverter.Gravity.sgFromPlato(grav.value)
                    grav.title = l("calc.bittering.gravity.sg")
                    grav.numberOfDigits = 3
                }
                inputs[3] = .number(grav)
            }
        }

        // Get values and convert to US units for the formula
        var vol = 0.0
        var grav = 0.0
        if case .number(let volInput) = inputs[2] { vol = volInput.value }
        if case .number(let gravInput) = inputs[3] { grav = gravInput.value }

        // Convert to US gallons if metric
        if case .segmented(let seg) = inputs[0], seg.selectedIndex == 0 {
            vol = UnitConverter.Volume.usGallonFromLitres(vol)
        }
        // Convert to SG if Plato
        if case .segmented(let seg) = inputs[1], seg.selectedIndex == 0 {
            grav = UnitConverter.Gravity.sgFromPlato(grav)
        }

        // Calculate IBU for each hop
        var totalIBU = 0.0
        var hopIBUs = [Double]()

        for i in 4...8 {
            if case .threeNumbers(let hop) = inputs[i] {
                var weight = hop.number1.value
                let alpha = hop.number2.value
                let minutes = hop.number3.value

                // Convert to oz if metric
                if case .segmented(let seg) = inputs[0], seg.selectedIndex == 0 {
                    weight = UnitConverter.Weight.ozFromGrams(weight)
                }

                let ibu = IBUCalculator.tinsethIBU(
                    alphaAcid: alpha,
                    weightOz: weight,
                    boilMinutes: minutes,
                    volumeGallons: vol,
                    gravity: grav
                )
                hopIBUs.append(ibu)
                totalIBU += ibu
            }
        }

        // Set outputs
        if case .number(var total) = outputs[0] {
            total.value = totalIBU
            outputs[0] = .number(total)
        }
        for i in 0..<hopIBUs.count {
            if case .number(var hopOut) = outputs[i + 1] {
                hopOut.value = hopIBUs[i]
                outputs[i + 1] = .number(hopOut)
            }
        }
    }
}
