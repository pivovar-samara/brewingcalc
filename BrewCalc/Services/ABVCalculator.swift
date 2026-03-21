import Foundation

enum ABVCalculator: Sendable {

    // MARK: - Table-based ABV (60-point interpolation)

    private static let abvTable: [Double] = [
        0.0, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.25,
        2.5, 2.75, 3.0, 3.25, 3.5, 3.75, 4.0, 4.25, 4.5, 4.75,
        5.0, 5.25, 5.5, 5.75, 6.0, 6.25, 6.5, 6.75, 7.0, 7.25,
        7.5, 7.75, 8.0, 8.25, 8.5, 8.75, 9.0, 9.25, 9.5, 9.75,
        10.0, 10.25, 10.5, 10.75, 11.0, 11.25, 11.5, 11.75, 12.0, 12.25,
        12.5, 12.75, 13.0, 13.25, 13.5, 13.75, 14.0, 14.25, 14.5, 14.75,
    ]

    private static let gravityTable: [Double] = [
        1.002, 1.004, 1.006, 1.008, 1.010, 1.012, 1.014, 1.016, 1.018, 1.020,
        1.022, 1.024, 1.026, 1.028, 1.030, 1.032, 1.034, 1.036, 1.038, 1.040,
        1.041, 1.043, 1.045, 1.047, 1.049, 1.051, 1.053, 1.055, 1.056, 1.058,
        1.060, 1.061, 1.063, 1.065, 1.067, 1.069, 1.071, 1.073, 1.075, 1.076,
        1.078, 1.080, 1.082, 1.084, 1.086, 1.088, 1.090, 1.092, 1.093, 1.095,
        1.097, 1.098, 1.100, 1.102, 1.104, 1.105, 1.107, 1.109, 1.111, 1.113,
    ]

    /// Look up ABV for a single SG value using the 60-point interpolation table.
    static func abvForSG(_ sg: Double) -> Double {
        var result = 0.0

        for i in 0..<(gravityTable.count - 1) {
            let beg = gravityTable[i]
            let end = gravityTable[i + 1]

            if sg >= beg && sg < end {
                let cg = sg - beg
                let pplg = end - beg
                let xg = cg * 100.0 / pplg

                let palg = abvTable[i + 1] - abvTable[i]
                let yg = xg * palg / 100.0

                result = abvTable[i] + yg
                break
            }
        }

        return round(100.0 * result) / 100.0
    }

    /// Calculate ABV from OG and FG (both as SG values) using the lookup table.
    static func abvFromTable(og: Double, fg: Double) -> Double {
        abvForSG(og) - abvForSG(fg)
    }

    // MARK: - Formula-based ABV (temperature-dependent polynomial)

    /// Calculate ABV using temperature-dependent polynomial correction.
    /// OG and FG in degrees Plato, temperatures in Celsius.
    static func abvFromFormula(ogPlato: Double, ogTempC: Double, fgPlato: Double, fgTempC: Double) -> Double {
        let a = -9.944 * pow(10.0, -4.0) - 2.031 * pow(10.0, -5.0) * ogTempC
        let b = 5.887 * pow(10.0, -6.0) * pow(ogTempC, 2.0) - 13.578 * pow(10.0, -9.0) * pow(ogTempC, 3.0)
        let deltaPopn = a + b

        let c = -9.944 * pow(10.0, -4.0) - 2.031 * pow(10.0, -5.0) * fgTempC
        let d = 5.887 * pow(10.0, -6.0) * pow(fgTempC, 2.0) - 13.578 * pow(10.0, -9.0) * pow(fgTempC, 3.0)
        let deltaPopk = c + d

        let e = 1.00001 + 0.0038661 * ogPlato
        let f = 1.3488 * pow(10.0, -5.0) * pow(ogPlato, 2.0) + 4.3074 * pow(10.0, -8.0) * pow(ogPlato, 3.0)
        let edOE = e + f
        let edpopOE = edOE - deltaPopn
        let eDeltaPopn = -668.962 + 1262.45 * edpopOE - 776.43 * pow(edpopOE, 2.0) + 182.94 * pow(edpopOE, 3.0)

        let g = 1.00001 + 0.0038661 * fgPlato
        let h = 1.3488 * pow(10.0, -5.0) * pow(fgPlato, 2.0) + 4.3074 * pow(10.0, -8.0) * pow(fgPlato, 3.0)
        let edAE = g + h
        let edpopAE = edAE - deltaPopk
        let eDeltaPopk = -668.962 + 1262.45 * edpopAE - 776.43 * pow(edpopAE, 2.0) + 182.94 * pow(edpopAE, 3.0)

        let pRE = 0.8114 * eDeltaPopk + 0.1886 * eDeltaPopn

        let pABW = (eDeltaPopn - pRE) / (2.0665 - 0.010665 * eDeltaPopn)
        let pABV = pABW / 0.7893

        return round(100.0 * pABV) / 100.0
    }
}
