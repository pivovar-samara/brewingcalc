import Foundation

enum CalorieCalculator: Sendable {

    /// Calculate beer calories.
    /// OG and FG in degrees Plato, volume in litres.
    /// Returns total calories for the given volume.
    static func calories(ogPlato: Double, fgPlato: Double, volumeLitres: Double) -> Double {
        let re = 0.8114 * fgPlato + 0.1886 * ogPlato
        let abw = (ogPlato - re) / (2.0665 - 0.010665 * ogPlato)
        let ev = 10.0 * volumeLitres * (3.8 * re + 7.1 * abw + 0.28 * re)
        return round(10.0 * ev) / 10.0
    }

    /// Calculate calories per 100ml.
    static func caloriesPer100ml(ogPlato: Double, fgPlato: Double, volumeLitres: Double) -> Double {
        let total = calories(ogPlato: ogPlato, fgPlato: fgPlato, volumeLitres: volumeLitres)
        return round(10.0 * (0.1 * total / volumeLitres)) / 10.0
    }
}
