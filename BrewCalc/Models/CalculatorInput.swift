import Foundation

struct NumberInput: Identifiable, Sendable, Equatable {
    let id: UUID
    var title: String
    var value: Double
    var numberOfDigits: Int
    var isUsed: Bool
    var isEditable: Bool

    init(
        id: UUID = UUID(),
        title: String,
        value: Double = 0.0,
        numberOfDigits: Int = 3,
        isUsed: Bool = false,
        isEditable: Bool = true
    ) {
        self.id = id
        self.title = title
        self.value = value
        self.numberOfDigits = numberOfDigits
        self.isUsed = isUsed
        self.isEditable = isEditable
    }

    var formattedValue: String {
        String(format: "%.\(numberOfDigits)f", value)
    }
}

struct SegmentedInput: Identifiable, Sendable, Equatable {
    let id: UUID
    var segments: [String]
    var selectedIndex: Int

    init(id: UUID = UUID(), segments: [String], selectedIndex: Int = 0) {
        self.id = id
        self.segments = segments
        self.selectedIndex = selectedIndex
    }
}

struct ThreeNumbersInput: Identifiable, Sendable, Equatable {
    let id: UUID
    var title: String
    var number1: NumberInput
    var number2: NumberInput
    var number3: NumberInput

    init(
        id: UUID = UUID(),
        title: String,
        number1: NumberInput,
        number2: NumberInput,
        number3: NumberInput
    ) {
        self.id = id
        self.title = title
        self.number1 = number1
        self.number2 = number2
        self.number3 = number3
    }
}

enum CalculatorInput: Identifiable, Sendable {
    case number(NumberInput)
    case segmented(SegmentedInput)
    case threeNumbers(ThreeNumbersInput)

    var id: UUID {
        switch self {
        case .number(let input): return input.id
        case .segmented(let input): return input.id
        case .threeNumbers(let input): return input.id
        }
    }
}
