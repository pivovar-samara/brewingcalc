import SwiftUI

struct NumberInputField: View {
    let title: String
    @Binding var value: Double
    var numberOfDigits: Int = 3
    var isEnabled: Bool = true
    var isUsed: Bool = true
    var onValueChanged: (() -> Void)?

    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(isEnabled ? .primary : .secondary)
            Spacer()
            TextField("", text: $text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 120)
                .disabled(!isEnabled)
                .focused($isFocused)
                .onChange(of: text) {
                    if isFocused {
                        let parsed = Double(text) ?? Double(text.replacingOccurrences(of: ",", with: ".")) ?? 0.0
                        value = parsed
                        onValueChanged?()
                    }
                }
                .onChange(of: isFocused) {
                    if isFocused {
                        if !isUsed {
                            text = ""
                        }
                    } else {
                        text = formatValue()
                    }
                }
        }
        .onAppear {
            text = formatValue()
        }
        .onChange(of: value) {
            if !isFocused {
                text = formatValue()
            }
        }
    }

    private func formatValue() -> String {
        String(format: "%.\(numberOfDigits)f", value)
    }
}
