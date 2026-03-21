import Foundation

enum UnitConverter: Sendable {

    // MARK: - Gravity

    enum Gravity: Sendable {
        static func sgFromPlato(_ plato: Double) -> Double {
            round(1000.0 * (1.0 + (plato / (258.6 - ((plato / 258.2) * 227.1))))) / 1000.0
        }

        static func platoFromSG(_ sg: Double) -> Double {
            round(100.0 * (258.6 / (1.0 / (sg - 1.0) + 227.1 / 258.2))) / 100.0
        }
    }

    // MARK: - Volume

    enum Volume: Sendable {
        static func litresFromDecalitres(_ source: Double) -> Double {
            round(1000.0 * source * 10.0) / 1000.0
        }

        static func litresFromHectolitres(_ source: Double) -> Double {
            round(1000.0 * source * 100.0) / 1000.0
        }

        static func litresFromMillilitres(_ source: Double) -> Double {
            round(1000.0 * source / 1000.0) / 1000.0
        }

        static func litresFromEngGallon(_ source: Double) -> Double {
            round(1000.0 * source * 4.54609188) / 1000.0
        }

        static func litresFromEngFlOz(_ source: Double) -> Double {
            round(1000.0 * source / 1000.0 * 28.413063) / 1000.0
        }

        static func litresFromEngPint(_ source: Double) -> Double {
            round(1000.0 * source * 0.568261485) / 1000.0
        }

        static func litresFromUSGallon(_ source: Double) -> Double {
            round(1000.0 * source * 3.78541178) / 1000.0
        }

        static func litresFromUSFlOz(_ source: Double) -> Double {
            round(1000.0 * source / 1000.0 * 29.573531) / 1000.0
        }

        static func litresFromUSPint(_ source: Double) -> Double {
            round(1000.0 * source * 0.473176473) / 1000.0
        }

        static func decalitresFromLitres(_ source: Double) -> Double {
            source / 10.0
        }

        static func hectolitresFromLitres(_ source: Double) -> Double {
            source / 100.0
        }

        static func millilitresFromLitres(_ source: Double) -> Double {
            round(1000.0 * source)
        }

        static func engGallonFromLitres(_ source: Double) -> Double {
            round(10000.0 * source / 4.54609188) / 10000.0
        }

        static func engFlOzFromLitres(_ source: Double) -> Double {
            round(100.0 * source * 1000.0 / 28.413063) / 100.0
        }

        static func engPintFromLitres(_ source: Double) -> Double {
            round(1000.0 * source / 0.568261485) / 1000.0
        }

        static func usGallonFromLitres(_ source: Double) -> Double {
            round(10000.0 * source / 3.78541178) / 10000.0
        }

        static func usFlOzFromLitres(_ source: Double) -> Double {
            round(100.0 * source * 1000.0 / 29.573531) / 100.0
        }

        static func usPintFromLitres(_ source: Double) -> Double {
            round(1000.0 * source / 0.473176473) / 1000.0
        }

        /// Convert any volume unit index to litres
        static func toLitres(_ value: Double, fromIndex index: Int) -> Double {
            switch index {
            case 0: return value // litres
            case 1: return litresFromDecalitres(value)
            case 2: return litresFromHectolitres(value)
            case 3: return litresFromMillilitres(value)
            case 4: return litresFromEngGallon(value)
            case 5: return litresFromEngFlOz(value)
            case 6: return litresFromEngPint(value)
            case 7: return litresFromUSGallon(value)
            case 8: return litresFromUSFlOz(value)
            case 9: return litresFromUSPint(value)
            default: return value
            }
        }

        /// Convert litres to all volume units, returns array of 10 values
        static func allFromLitres(_ litres: Double) -> [Double] {
            [
                litres,
                decalitresFromLitres(litres),
                hectolitresFromLitres(litres),
                millilitresFromLitres(litres),
                engGallonFromLitres(litres),
                engFlOzFromLitres(litres),
                engPintFromLitres(litres),
                usGallonFromLitres(litres),
                usFlOzFromLitres(litres),
                usPintFromLitres(litres),
            ]
        }
    }

    // MARK: - Weight

    enum Weight: Sendable {
        static func kgFromGrams(_ source: Double) -> Double {
            round(1000.0 * source / 1000.0) / 1000.0
        }

        static func kgFromOz(_ source: Double) -> Double {
            round(1000.0 * source * 0.0283495231) / 1000.0
        }

        static func kgFromPounds(_ source: Double) -> Double {
            round(1000.0 * source * 0.45359237) / 1000.0
        }

        static func gramsFromKg(_ source: Double) -> Double {
            round(source * 1000.0)
        }

        static func ozFromKg(_ source: Double) -> Double {
            round(100.0 * source / 0.0283495231) / 100.0
        }

        static func poundsFromKg(_ source: Double) -> Double {
            round(1000.0 * source / 0.45359237) / 1000.0
        }

        static func ozFromGrams(_ source: Double) -> Double {
            ozFromKg(kgFromGrams(source))
        }

        static func gramsFromOz(_ source: Double) -> Double {
            gramsFromKg(kgFromOz(source))
        }

        /// Convert any weight unit index to kg
        static func toKg(_ value: Double, fromIndex index: Int) -> Double {
            switch index {
            case 0: return value // kg
            case 1: return kgFromGrams(value)
            case 2: return kgFromOz(value)
            case 3: return kgFromPounds(value)
            default: return value
            }
        }

        /// Convert kg to all weight units, returns array of 4 values
        static func allFromKg(_ kg: Double) -> [Double] {
            [kg, gramsFromKg(kg), ozFromKg(kg), poundsFromKg(kg)]
        }
    }

    // MARK: - Temperature

    enum Temperature: Sendable {
        static func celsiusFromFahrenheit(_ source: Double) -> Double {
            round(10.0 * (source - 32.0) * 5.0 / 9.0) / 10.0
        }

        static func celsiusFromKelvin(_ source: Double) -> Double {
            round(10.0 * (source - 273.15)) / 10.0
        }

        static func fahrenheitFromCelsius(_ source: Double) -> Double {
            round(10.0 * (source * 9.0 / 5.0 + 32.0)) / 10.0
        }

        static func kelvinFromCelsius(_ source: Double) -> Double {
            round(10.0 * (source + 273.15)) / 10.0
        }

        /// Convert any temperature unit index to Celsius
        static func toCelsius(_ value: Double, fromIndex index: Int) -> Double {
            switch index {
            case 0: return value // Celsius
            case 1: return celsiusFromFahrenheit(value)
            case 2: return celsiusFromKelvin(value)
            default: return value
            }
        }

        /// Convert Celsius to all temperature units, returns array of 3 values
        static func allFromCelsius(_ celsius: Double) -> [Double] {
            [celsius, fahrenheitFromCelsius(celsius), kelvinFromCelsius(celsius)]
        }
    }
}
