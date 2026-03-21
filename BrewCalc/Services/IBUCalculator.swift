import Foundation

enum IBUCalculator: Sendable {

    /// Glenn Tinseth IBU formula for a single hop addition.
    /// All inputs must be in US units: weight in oz, volume in US gallons, gravity as SG (1.xxx).
    static func tinsethIBU(
        alphaAcid: Double,
        weightOz: Double,
        boilMinutes: Double,
        volumeGallons: Double,
        gravity: Double
    ) -> Double {
        let someAlpha = alphaAcid / 100.0
        let someWeight = weightOz * 7490.0
        let someVolume = volumeGallons * 1.65
        let someGravity = pow(0.000125, gravity - 1.0)
        let someTime = 1.0 - exp(-0.04 * boilMinutes)
        return someAlpha * someWeight / someVolume * someGravity * someTime / 4.15
    }
}
