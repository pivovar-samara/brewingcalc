import SwiftUI

@Observable
@MainActor
final class AppViewModel {
    var categories: [CalculatorCategory]
    var selectedCategoryID: CalculatorCategory.ID? {
        didSet {
            guard selectedCategoryID != oldValue,
                  let id = selectedCategoryID,
                  let category = categories.first(where: { $0.id == id }) else { return }
            analytics.track(.calculatorOpened(categoryName: category.localizedName))
        }
    }
    var showAbout = false {
        didSet {
            if showAbout { analytics.track(.aboutOpened) }
        }
    }

    let analytics: any AnalyticsService

    init(analytics: any AnalyticsService = NoOpAnalyticsService()) {
        self.analytics = analytics
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

    func trackAppBecameActive() {
        analytics.track(.appBecameActive)
    }

    func makeDetailViewModel(for category: CalculatorCategory) -> CalculatorDetailViewModel {
        CalculatorDetailViewModel(category: category, analytics: analytics)
    }
}
