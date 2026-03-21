import SwiftUI

extension Color {
    static let brewCalcAccent = Color(red: 32.0 / 255.0, green: 151.0 / 255.0, blue: 220.0 / 255.0)
}

extension ShapeStyle where Self == Color {
    static var brewCalcAccent: Color { .brewCalcAccent }
}
