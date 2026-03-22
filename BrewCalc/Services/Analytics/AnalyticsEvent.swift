enum AnalyticsEvent: Sendable {
    case appOpened
    case calculatorOpened(categoryName: String)
    case calculationPerformed(calculatorName: String, categoryName: String)
}
