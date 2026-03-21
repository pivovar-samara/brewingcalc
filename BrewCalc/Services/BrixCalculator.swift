import Foundation

enum BrixCalculator: Sendable {

    /// Convert Brix reading to Specific Gravity (SG).
    /// Source: Brew Your Own Magazine
    /// SG = (Brix / (258.6-((Brix / 258.2)*227.1))) + 1
    static func gravityFromBrix(_ brix: Double) -> Double {
        round(1000.0 * (brix / (258.6 - ((brix / 258.2) * 227.1)) + 1.0)) / 1000.0
    }

    /// Convert SG to Brix.
    /// Source: http://en.wikipedia.org/wiki/Brix
    /// Brix = (((182.4601 * SG -775.6821) * SG +1262.7794) * SG -669.5622)
    static func brixFromGravity(_ sg: Double) -> Double {
        round(100.0 * (((182.4601 * sg - 775.6821) * sg + 1262.7794) * sg - 669.5622)) / 100.0
    }

    /// Calculate Final Gravity from Original Brix and Final Brix readings.
    static func gravityFromOBFB(ob: Double, fb: Double) -> Double {
        let g =
            1.001843
            - 0.002318474 * ob
            - 0.000007775 * pow(ob, 2.0)
            - 0.000000034 * pow(ob, 3.0)
            + 0.00574 * fb
            + 0.00003344 * pow(fb, 2.0)
            + 0.000000086 * pow(fb, 3.0)
        return round(1000.0 * g) / 1000.0
    }

    /// Calculate ABV from corrected Brix and current gravity.
    static func abv(correctedBrix cb: Double, currentGravity cg: Double) -> Double {
        let abv = (277.8851 - 277.4 * cg + 0.9956 * cb + 0.00523 * pow(cb, 2.0) + 0.000013 * pow(cb, 3.0)) * (cg / 0.79)
        return round(100.0 * abv) / 100.0
    }

    /// Calculate Original Gravity from corrected Brix and current gravity.
    static func ogFromBrix(correctedBrix cb: Double, currentGravity cg: Double) -> Double {
        let j = (100.0 * ((194.5935 + (129.8 * cg) + ((1.33302 + (0.001427193 * cb) + (0.000005791157 * pow(cb, 2.0))) * ((410.8815 * (1.33302 + (0.001427193 * cb) + (0.000005791157 * pow(cb, 2.0)))) - 790.8732))) + (2.0665 * (1017.5596 - (277.4 * cg) + ((1.33302 + (0.001427193 * cb) + (0.000005791157 * pow(cb, 2.0))) * ((937.8135 * (1.33302 + (0.001427193 * cb) + (0.000005791157 * pow(cb, 2.0)))) - 1805.1228)))))) / (100.0 + (1.0665 * (1017.5596 - (277.4 * cg) + ((1.33302 + (0.001427193 * cb) + (0.000005791157 * pow(cb, 2.0))) * ((937.8135 * (1.33302 + (0.001427193 * cb) + (0.000005791157 * pow(cb, 2.0)))) - 1805.1228)))))

        let og = (j / (258.6 - ((j / 258.2) * 227.1))) + 1.0

        return round(1000.0 * og) / 1000.0
    }
}
