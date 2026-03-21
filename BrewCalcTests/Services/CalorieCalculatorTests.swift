import Testing
@testable import BrewCalc

struct CalorieCalculatorTests {

    @Test("Zero volume produces zero calories")
    func zeroVolume() {
        let result = CalorieCalculator.calories(ogPlato: 12.0, fgPlato: 3.0, volumeLitres: 0.0)
        #expect(result == 0.0)
    }

    @Test("Zero gravity produces zero calories")
    func zeroGravity() {
        let result = CalorieCalculator.calories(ogPlato: 0.0, fgPlato: 0.0, volumeLitres: 0.5)
        #expect(result == 0.0)
    }

    @Test("Typical beer calories - 0.5L, 12P OG, 3P FG")
    func typicalBeer() {
        let result = CalorieCalculator.calories(ogPlato: 12.0, fgPlato: 3.0, volumeLitres: 0.5)
        // A typical 500ml beer has ~200-300 kcal
        #expect(result > 100.0 && result < 500.0, "Calories should be reasonable: \(result)")
    }

    @Test("Calories per 100ml")
    func per100ml() {
        let total = CalorieCalculator.calories(ogPlato: 12.0, fgPlato: 3.0, volumeLitres: 0.5)
        let per100 = CalorieCalculator.caloriesPer100ml(ogPlato: 12.0, fgPlato: 3.0, volumeLitres: 0.5)
        // per100ml should be total / 5 (0.5L = 5 x 100ml)
        #expect(abs(per100 - total / 5.0) < 1.0)
    }

    @Test("Higher OG produces more calories")
    func higherOGMoreCalories() {
        let low = CalorieCalculator.calories(ogPlato: 10.0, fgPlato: 2.0, volumeLitres: 0.5)
        let high = CalorieCalculator.calories(ogPlato: 15.0, fgPlato: 3.0, volumeLitres: 0.5)
        #expect(high > low)
    }
}
