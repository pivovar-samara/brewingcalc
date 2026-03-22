import SwiftUI

struct ThreeNumberInputGroup: View {
    let title: String
    @Binding var number1: NumberInput
    @Binding var number2: NumberInput
    @Binding var number3: NumberInput
    var onValueChanged: (() -> Void)?

    @State private var text1: String = ""
    @State private var text2: String = ""
    @State private var text3: String = ""
    @FocusState private var focused: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                numberField(title: number1.title, text: $text1, tag: 1)
                numberField(title: number2.title, text: $text2, tag: 2)
                numberField(title: number3.title, text: $text3, tag: 3)
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            text1 = format(number1)
            text2 = format(number2)
            text3 = format(number3)
        }
        .onChange(of: focused) {
            if focused != 1 { text1 = reformatText(text1, digits: number1.numberOfDigits) }
            if focused != 2 { text2 = reformatText(text2, digits: number2.numberOfDigits) }
            if focused != 3 { text3 = reformatText(text3, digits: number3.numberOfDigits) }
        }
        .onChange(of: number1.value) { if focused != 1 { text1 = format(number1) } }
        .onChange(of: number2.value) { if focused != 2 { text2 = format(number2) } }
        .onChange(of: number3.value) { if focused != 3 { text3 = format(number3) } }
        .onChange(of: text1) {
            guard focused == 1 else { return }
            number1.value = parseDouble(text1)
            onValueChanged?()
        }
        .onChange(of: text2) {
            guard focused == 2 else { return }
            number2.value = parseDouble(text2)
            onValueChanged?()
        }
        .onChange(of: text3) {
            guard focused == 3 else { return }
            number3.value = parseDouble(text3)
            onValueChanged?()
        }
    }

    @ViewBuilder
    private func numberField(title: String, text: Binding<String>, tag: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("", text: text)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .font(.body)
                .focused($focused, equals: tag)
        }
    }

    private func format(_ n: NumberInput) -> String {
        String(format: "%.\(n.numberOfDigits)f", n.value)
    }

    private func reformatText(_ text: String, digits: Int) -> String {
        String(format: "%.\(digits)f", parseDouble(text))
    }

    private func parseDouble(_ text: String) -> Double {
        if let value = Double(text) { return value }
        return Double(text.replacingOccurrences(of: ",", with: ".")) ?? 0.0
    }
}
