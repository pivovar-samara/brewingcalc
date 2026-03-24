enum AnalyticsEvent: Sendable, Equatable {
    case appBecameActive
    case calculatorOpened(categoryName: String)
    case calculationPerformed(calculatorName: String, categoryName: String)
    case aboutOpened
    case emailTapped
    case supportLinkTapped
    case privacyPolicyTapped
}
