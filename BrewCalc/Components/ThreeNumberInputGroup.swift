import SwiftUI

struct ThreeNumberInputGroup: View {
    let title: String
    @Binding var number1: NumberInput
    @Binding var number2: NumberInput
    @Binding var number3: NumberInput
    var onValueChanged: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(number1.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("", text: binding(for: $number1))
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .font(.body)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(number2.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("", text: binding(for: $number2))
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .font(.body)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(number3.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("", text: binding(for: $number3))
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .font(.body)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func binding(for numberBinding: Binding<NumberInput>) -> Binding<String> {
        Binding<String>(
            get: {
                String(format: "%.\(numberBinding.wrappedValue.numberOfDigits)f", numberBinding.wrappedValue.value)
            },
            set: { newText in
                let parsed = Double(newText) ?? 0.0
                numberBinding.wrappedValue.value = parsed
                numberBinding.wrappedValue.isUsed = true
                onValueChanged?()
            }
        )
    }
}
