import Testing
@testable import BrewCalc

struct ABVCalculatorTests {

    // MARK: - Table-based ABV

    @Test("ABV for SG below table range returns 0")
    func belowRange() {
        let result = ABVCalculator.abvForSG(1.000)
        #expect(result == 0.0)
    }

    @Test("ABV for SG at table start")
    func tableStart() {
        let result = ABVCalculator.abvForSG(1.002)
        #expect(result == 0.0, "At first table entry, ABV should be 0")
    }

    @Test("ABV for SG 1.010 should give ~1.0%")
    func sgAt1010() {
        let result = ABVCalculator.abvForSG(1.010)
        #expect(abs(result - 1.0) < 0.1)
    }

    @Test("ABV from table with known OG/FG pair")
    func knownPair() {
        // OG 1.050, FG 1.010 should give approximately 5% ABV
        let result = ABVCalculator.abvFromTable(og: 1.050, fg: 1.010)
        #expect(result > 3.5 && result < 6.0, "ABV should be ~5%: got \(result)")
    }

    @Test("ABV from table with same OG and FG gives 0")
    func sameOGFG() {
        let result = ABVCalculator.abvFromTable(og: 1.050, fg: 1.050)
        #expect(result == 0.0)
    }

    @Test("ABV table interpolation at SG 1.003")
    func tableInterpolationLow() {
        let result = ABVCalculator.abvForSG(1.003)
        #expect(result >= 0.0 && result <= 0.5, "ABV for SG 1.003 = \(result)")
    }

    @Test("ABV table interpolation at SG 1.050")
    func tableInterpolationMid() {
        // SG 1.050 is between gi[24]=1.049 and gi[25]=1.051, maps to ABV ~6.1
        let result = ABVCalculator.abvForSG(1.050)
        #expect(result >= 5.5 && result <= 6.5, "ABV for SG 1.050 = \(result)")
    }

    @Test("ABV table interpolation at SG 1.101")
    func tableInterpolationHigh() {
        // SG 1.101 is between gi[52]=1.100 and gi[53]=1.102, maps to ABV ~13.1
        let result = ABVCalculator.abvForSG(1.101)
        #expect(result >= 12.5 && result <= 13.5, "ABV for SG 1.101 = \(result)")
    }

    // MARK: - Formula-based ABV

    @Test("Formula ABV with zero inputs")
    func formulaZeroInputs() {
        let result = ABVCalculator.abvFromFormula(ogPlato: 0.0, ogTempC: 20.0, fgPlato: 0.0, fgTempC: 20.0)
        #expect(abs(result) < 0.5, "Zero gravity should give ~0 ABV")
    }

    @Test("Formula ABV with typical values")
    func formulaTypical() {
        // 12 Plato OG, 3 Plato FG, both at 20C
        let result = ABVCalculator.abvFromFormula(ogPlato: 12.0, ogTempC: 20.0, fgPlato: 3.0, fgTempC: 20.0)
        #expect(result > 3.0 && result < 7.0, "ABV should be reasonable for 12P->3P: \(result)")
    }
}
