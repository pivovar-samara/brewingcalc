protocol AnalyticsService: Sendable {
    func track(_ event: AnalyticsEvent)
}

struct NoOpAnalyticsService: AnalyticsService {
    func track(_ event: AnalyticsEvent) {}
}
