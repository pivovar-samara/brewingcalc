import SwiftUI

struct CalculatorDetailView: View {
    @State var viewModel: CalculatorDetailViewModel
    var onCategoryUpdated: ((CalculatorCategory) -> Void)?

    var body: some View {
        Form {
            ForEach(Array(viewModel.category.calculators.enumerated()), id: \.element.id) { calcIndex, calculator in
                // Input section
                Section(header: Text(calculator.localizedName)) {
                    ForEach(Array(calculator.inputs.enumerated()), id: \.element.id) { inputIndex, input in
                        inputView(for: input, calculatorIndex: calcIndex, inputIndex: inputIndex)
                    }
                }

                // Output section (for separated calculators)
                if calculator.hasSeparateOutputSection {
                    Section(header: Text(calculator.outputSectionName ?? "")) {
                        ForEach(Array(calculator.outputs.enumerated()), id: \.element.id) { _, output in
                            outputView(for: output)
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.category.localizedName)
        .toolbar {
            if viewModel.hasInstructions {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showInstruction = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showInstruction) {
            if let filename = viewModel.category.instructionFilename {
                NavigationStack {
                    InstructionView(filename: filename)
                }
            }
        }
        .onChange(of: viewModel.category.calculators.map(\.id)) {
            onCategoryUpdated?(viewModel.category)
        }
    }

    @ViewBuilder
    private func inputView(for input: CalculatorInput, calculatorIndex: Int, inputIndex: Int) -> some View {
        switch input {
        case .number(let numberInput):
            NumberInputField(
                title: numberInput.title,
                value: Binding(
                    get: { numberInput.value },
                    set: { newValue in
                        viewModel.updateInput(calculatorIndex: calculatorIndex, inputIndex: inputIndex, value: newValue)
                    }
                ),
                numberOfDigits: numberInput.numberOfDigits,
                isEnabled: numberInput.isEditable,
                isUsed: numberInput.isUsed,
                onValueChanged: {
                    viewModel.updateInput(
                        calculatorIndex: calculatorIndex,
                        inputIndex: inputIndex,
                        value: {
                            if case .number(let n) = viewModel.category.calculators[calculatorIndex].inputs[inputIndex] {
                                return n.value
                            }
                            return 0
                        }()
                    )
                }
            )

        case .segmented(let segInput):
            SegmentedSelector(
                segments: segInput.segments,
                selectedIndex: Binding(
                    get: { segInput.selectedIndex },
                    set: { newIndex in
                        viewModel.updateSegment(calculatorIndex: calculatorIndex, inputIndex: inputIndex, selectedIndex: newIndex)
                    }
                )
            )

        case .threeNumbers(let threeInput):
            ThreeNumberInputGroup(
                title: threeInput.title,
                number1: Binding(
                    get: { threeInput.number1 },
                    set: { newValue in
                        viewModel.updateThreeNumberInput(calculatorIndex: calculatorIndex, inputIndex: inputIndex, numberIndex: 1, value: newValue.value)
                    }
                ),
                number2: Binding(
                    get: { threeInput.number2 },
                    set: { newValue in
                        viewModel.updateThreeNumberInput(calculatorIndex: calculatorIndex, inputIndex: inputIndex, numberIndex: 2, value: newValue.value)
                    }
                ),
                number3: Binding(
                    get: { threeInput.number3 },
                    set: { newValue in
                        viewModel.updateThreeNumberInput(calculatorIndex: calculatorIndex, inputIndex: inputIndex, numberIndex: 3, value: newValue.value)
                    }
                ),
                onValueChanged: nil
            )
        }
    }

    @ViewBuilder
    private func outputView(for output: CalculatorInput) -> some View {
        switch output {
        case .number(let numberInput):
            ResultRow(
                title: numberInput.title,
                value: numberInput.value,
                numberOfDigits: numberInput.numberOfDigits
            )
        default:
            EmptyView()
        }
    }
}
