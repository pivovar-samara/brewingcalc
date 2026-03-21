import Testing
@testable import BrewCalc

struct UnitConverterTests {

    // MARK: - Gravity

    @Test("Plato to SG conversion", arguments: [
        (plato: 0.0, sg: 1.0),
        (plato: 10.0, sg: 1.040),
        (plato: 15.0, sg: 1.061),
        (plato: 20.0, sg: 1.083),
    ])
    func platoToSG(plato: Double, sg: Double) {
        let result = UnitConverter.Gravity.sgFromPlato(plato)
        #expect(abs(result - sg) < 0.002, "sgFromPlato(\(plato)) = \(result), expected ~\(sg)")
    }

    @Test("SG to Plato round-trip")
    func gravityRoundTrip() {
        let plato = 12.0
        let sg = UnitConverter.Gravity.sgFromPlato(plato)
        let backToPlato = UnitConverter.Gravity.platoFromSG(sg)
        #expect(abs(backToPlato - plato) < 0.1, "Round-trip: \(plato) -> \(sg) -> \(backToPlato)")
    }

    // MARK: - Volume

    @Test("US Gallon to Litres and back")
    func usGallonConversion() {
        let litres = UnitConverter.Volume.litresFromUSGallon(1.0)
        #expect(abs(litres - 3.785) < 0.01)
        let gallons = UnitConverter.Volume.usGallonFromLitres(litres)
        #expect(abs(gallons - 1.0) < 0.001)
    }

    @Test("Eng Gallon to Litres and back")
    func engGallonConversion() {
        let litres = UnitConverter.Volume.litresFromEngGallon(1.0)
        #expect(abs(litres - 4.546) < 0.01)
        let gallons = UnitConverter.Volume.engGallonFromLitres(litres)
        #expect(abs(gallons - 1.0) < 0.001)
    }

    @Test("Millilitres to Litres")
    func millilitresConversion() {
        let litres = UnitConverter.Volume.litresFromMillilitres(1000.0)
        #expect(abs(litres - 1.0) < 0.001)
        let ml = UnitConverter.Volume.millilitresFromLitres(1.0)
        #expect(abs(ml - 1000.0) < 0.1)
    }

    @Test("All volume conversions from 1 litre")
    func allVolumeFromOneLitre() {
        let all = UnitConverter.Volume.allFromLitres(1.0)
        #expect(all.count == 10)
        #expect(abs(all[0] - 1.0) < 0.001) // litres
        #expect(abs(all[3] - 1000.0) < 1.0) // millilitres
    }

    @Test("Volume toLitres helper", arguments: [
        (value: 1.0, index: 0, expected: 1.0),
        (value: 1.0, index: 7, expected: 3.785),
    ])
    func volumeToLitres(value: Double, index: Int, expected: Double) {
        let result = UnitConverter.Volume.toLitres(value, fromIndex: index)
        #expect(abs(result - expected) < 0.01)
    }

    // MARK: - Weight

    @Test("Oz to Grams round-trip")
    func ozGramsRoundTrip() {
        let oz = 1.0
        let grams = UnitConverter.Weight.gramsFromOz(oz)
        // Original formula rounds through kg, so 1oz ≈ 28g (rounded)
        #expect(abs(grams - 28.0) < 1.0, "1 oz should be ~28g: \(grams)")
        let backToOz = UnitConverter.Weight.ozFromGrams(grams)
        #expect(abs(backToOz - oz) < 0.1, "Round-trip: \(backToOz)")
    }

    @Test("Pounds to Kg")
    func poundsToKg() {
        let kg = UnitConverter.Weight.kgFromPounds(1.0)
        #expect(abs(kg - 0.454) < 0.01)
    }

    @Test("All weight conversions from 1 kg")
    func allWeightFromOneKg() {
        let all = UnitConverter.Weight.allFromKg(1.0)
        #expect(all.count == 4)
        #expect(abs(all[0] - 1.0) < 0.001) // kg
        #expect(abs(all[1] - 1000.0) < 1.0) // grams
    }

    // MARK: - Temperature

    @Test("Celsius to Fahrenheit", arguments: [
        (celsius: 0.0, fahrenheit: 32.0),
        (celsius: 100.0, fahrenheit: 212.0),
        (celsius: 20.0, fahrenheit: 68.0),
    ])
    func celsiusToFahrenheit(celsius: Double, fahrenheit: Double) {
        let result = UnitConverter.Temperature.fahrenheitFromCelsius(celsius)
        #expect(abs(result - fahrenheit) < 0.2)
    }

    @Test("Celsius to Kelvin")
    func celsiusToKelvin() {
        let kelvin = UnitConverter.Temperature.kelvinFromCelsius(0.0)
        #expect(abs(kelvin - 273.2) < 0.2)
        let celsius = UnitConverter.Temperature.celsiusFromKelvin(373.15)
        #expect(abs(celsius - 100.0) < 0.2)
    }

    @Test("Temperature round-trip Fahrenheit")
    func temperatureRoundTrip() {
        let celsius = 25.0
        let f = UnitConverter.Temperature.fahrenheitFromCelsius(celsius)
        let back = UnitConverter.Temperature.celsiusFromFahrenheit(f)
        #expect(abs(back - celsius) < 0.2)
    }
}
