import SwiftUI

struct ResultRow: View {
    let title: String
    let value: Double
    var numberOfDigits: Int = 3

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(String(format: "%.\(numberOfDigits)f", value))
                .fontWeight(.medium)
                .monospacedDigit()
        }
    }
}
