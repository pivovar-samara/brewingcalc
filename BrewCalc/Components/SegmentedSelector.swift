import SwiftUI

struct SegmentedSelector: View {
    let segments: [String]
    @Binding var selectedIndex: Int
    var onSelectionChanged: (() -> Void)?

    var body: some View {
        Picker("", selection: $selectedIndex) {
            ForEach(segments.indices, id: \.self) { index in
                Text(segments[index]).tag(index)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: selectedIndex) {
            onSelectionChanged?()
        }
    }
}
