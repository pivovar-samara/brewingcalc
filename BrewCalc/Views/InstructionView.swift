import SwiftUI

private enum InstructionSectionType: String, Decodable {
    case h3, h4, paragraph, ol
}

private struct InstructionSection: Decodable, Sendable {
    let type: InstructionSectionType
    let text: String?
    let items: [String]?
}

struct InstructionView: View {
    let filename: String
    @Environment(\.dismiss) private var dismiss

    private var sections: [InstructionSection] {
        guard
            let url = Bundle.main.url(forResource: filename, withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let result = try? JSONDecoder().decode([InstructionSection].self, from: data)
        else { return [] }
        return result
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
                    sectionView(section)
                }
            }
            .padding()
        }
        .navigationTitle(l("instruction.title"))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(l("button.close")) {
                    dismiss()
                }
            }
        }
    }

    @ViewBuilder
    private func sectionView(_ section: InstructionSection) -> some View {
        switch section.type {
        case .h3:
            if let text = section.text {
                Text(text)
                    .font(.title3.weight(.semibold))
            }
        case .h4:
            if let text = section.text {
                Text(text)
                    .font(.subheadline.weight(.semibold))
                    .padding(.top, 4)
            }
        case .paragraph:
            if let text = section.text {
                Text(attributed(text))
                    .font(.body)
            }
        case .ol:
            if let items = section.items {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        HStack(alignment: .top, spacing: 4) {
                            Text("\(index + 1).")
                                .font(.body)
                                .monospacedDigit()
                                .frame(minWidth: 20, alignment: .leading)
                            Text(attributed(item))
                                .font(.body)
                        }
                    }
                }
            }
        }
    }

    private func attributed(_ string: String) -> AttributedString {
        (try? AttributedString(markdown: string)) ?? AttributedString(string)
    }
}
