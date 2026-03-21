import Testing
@testable import BrewCalc

struct IBUCalculatorTests {

    @Test("Zero weight produces zero IBU")
    func zeroWeight() {
        let result = IBUCalculator.tinsethIBU(
            alphaAcid: 10.0,
            weightOz: 0.0,
            boilMinutes: 60.0,
            volumeGallons: 5.0,
            gravity: 1.050
        )
        #expect(result == 0.0)
    }

    @Test("Zero alpha produces zero IBU")
    func zeroAlpha() {
        let result = IBUCalculator.tinsethIBU(
            alphaAcid: 0.0,
            weightOz: 1.0,
            boilMinutes: 60.0,
            volumeGallons: 5.0,
            gravity: 1.050
        )
        #expect(result == 0.0)
    }

    @Test("Zero time produces zero IBU")
    func zeroTime() {
        let result = IBUCalculator.tinsethIBU(
            alphaAcid: 10.0,
            weightOz: 1.0,
            boilMinutes: 0.0,
            volumeGallons: 5.0,
            gravity: 1.050
        )
        #expect(result == 0.0)
    }

    @Test("Known IBU value - 1oz, 10% alpha, 60min, 5gal, 1.050 SG")
    func knownIBU() {
        let result = IBUCalculator.tinsethIBU(
            alphaAcid: 10.0,
            weightOz: 1.0,
            boilMinutes: 60.0,
            volumeGallons: 5.0,
            gravity: 1.050
        )
        // Tinseth formula should produce a positive, reasonable IBU
        #expect(result > 10.0 && result < 80.0, "IBU should be reasonable: \(result)")
    }

    @Test("Higher gravity reduces IBU")
    func higherGravityReducesIBU() {
        let lowGravity = IBUCalculator.tinsethIBU(
            alphaAcid: 10.0, weightOz: 1.0, boilMinutes: 60.0,
            volumeGallons: 5.0, gravity: 1.040
        )
        let highGravity = IBUCalculator.tinsethIBU(
            alphaAcid: 10.0, weightOz: 1.0, boilMinutes: 60.0,
            volumeGallons: 5.0, gravity: 1.080
        )
        #expect(lowGravity > highGravity, "Higher gravity should reduce IBU utilization")
    }

    @Test("Longer boil time increases IBU")
    func longerBoilIncreasesIBU() {
        let short = IBUCalculator.tinsethIBU(
            alphaAcid: 10.0, weightOz: 1.0, boilMinutes: 15.0,
            volumeGallons: 5.0, gravity: 1.050
        )
        let long = IBUCalculator.tinsethIBU(
            alphaAcid: 10.0, weightOz: 1.0, boilMinutes: 60.0,
            volumeGallons: 5.0, gravity: 1.050
        )
        #expect(long > short, "Longer boil should produce more IBU")
    }
}
