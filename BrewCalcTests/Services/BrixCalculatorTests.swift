import Testing
@testable import BrewCalc

struct BrixCalculatorTests {

    // MARK: - Brix <-> SG

    @Test("Brix to SG - zero Brix gives SG ~1.000")
    func zeroBrix() {
        let result = BrixCalculator.gravityFromBrix(0.0)
        #expect(abs(result - 1.0) < 0.001)
    }

    @Test("Brix to SG - 10 Brix", arguments: [
        (brix: 10.0, expectedSG: 1.040),
        (brix: 15.0, expectedSG: 1.061),
        (brix: 20.0, expectedSG: 1.083),
    ])
    func brixToSG(brix: Double, expectedSG: Double) {
        let result = BrixCalculator.gravityFromBrix(brix)
        #expect(abs(result - expectedSG) < 0.003, "gravityFromBrix(\(brix)) = \(result), expected ~\(expectedSG)")
    }

    @Test("SG to Brix round-trip")
    func sgBrixRoundTrip() {
        let brix = 12.0
        let sg = BrixCalculator.gravityFromBrix(brix)
        let back = BrixCalculator.brixFromGravity(sg)
        #expect(abs(back - brix) < 0.5, "Round-trip: \(brix) -> \(sg) -> \(back)")
    }

    // MARK: - OB/FB to FG

    @Test("Gravity from OB/FB with zero inputs")
    func zeroOBFB() {
        let result = BrixCalculator.gravityFromOBFB(ob: 0.0, fb: 0.0)
        #expect(abs(result - 1.002) < 0.002, "Zero inputs should give ~1.002: \(result)")
    }

    @Test("Gravity from OB/FB with typical values")
    func typicalOBFB() {
        let result = BrixCalculator.gravityFromOBFB(ob: 12.0, fb: 6.0)
        // Should produce a reasonable FG
        #expect(result > 0.99 && result < 1.05, "FG should be reasonable: \(result)")
    }

    // MARK: - ABV from Brix

    @Test("ABV from corrected Brix and gravity")
    func abvFromBrix() {
        let result = BrixCalculator.abv(correctedBrix: 6.0, currentGravity: 1.010)
        #expect(result > 0.0, "ABV should be positive: \(result)")
    }

    // MARK: - OG from Brix

    @Test("OG from corrected Brix and current gravity")
    func ogFromBrix() {
        let result = BrixCalculator.ogFromBrix(correctedBrix: 6.0, currentGravity: 1.010)
        // Should produce a reasonable OG (higher than current gravity)
        #expect(result > 1.0 && result < 1.2, "OG should be reasonable: \(result)")
    }
}
