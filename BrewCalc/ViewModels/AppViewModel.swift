import SwiftUI

@Observable
@MainActor
final class AppViewModel {
    var categories: [CalculatorCategory]
    var selectedCategoryID: CalculatorCategory.ID?
    var showAbout = false

    init() {
        self.categories = CalculatorCategory.allCategories()
    }

    var selectedCategory: CalculatorCategory? {
        guard let id = selectedCategoryID else { return nil }
        return categories.first { $0.id == id }
    }

    func updateCategory(_ category: CalculatorCategory) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
        }
    }
}
