import Testing
@testable import BrewCalc

// MARK: - Spy

@MainActor
final class SpyAnalyticsService: AnalyticsService {
    private(set) var trackedEvents: [AnalyticsEvent] = []

    func track(_ event: AnalyticsEvent) {
        trackedEvents.append(event)
    }
}

// MARK: - Tests

struct AppViewModelTests {

    @Test("trackAppBecameActive emits appBecameActive event")
    @MainActor
    func trackAppBecameActiveEmitsEvent() {
        let spy = SpyAnalyticsService()
        let vm = AppViewModel(analytics: spy)

        vm.trackAppBecameActive()

        #expect(spy.trackedEvents == [.appBecameActive])
    }

    @Test("Selecting a new category fires calculatorOpened with correct name")
    @MainActor
    func selectingNewCategoryTracksEvent() {
        let spy = SpyAnalyticsService()
        let vm = AppViewModel(analytics: spy)
        guard let first = vm.categories.first else { return }

        vm.selectedCategoryID = first.id

        #expect(spy.trackedEvents == [.calculatorOpened(categoryName: first.localizedName)])
    }

    @Test("Reassigning the same category ID does not re-fire")
    @MainActor
    func reassigningSameIDSkipsDuplicateEvent() {
        let spy = SpyAnalyticsService()
        let vm = AppViewModel(analytics: spy)
        guard let first = vm.categories.first else { return }

        vm.selectedCategoryID = first.id
        vm.selectedCategoryID = first.id

        #expect(spy.trackedEvents.count == 1)
    }

    @Test("Setting showAbout to true fires aboutOpened event")
    @MainActor
    func showAboutFiresAboutOpenedEvent() {
        let spy = SpyAnalyticsService()
        let vm = AppViewModel(analytics: spy)

        vm.showAbout = true

        #expect(spy.trackedEvents == [.aboutOpened])
    }

    @Test("Setting showAbout to false does not fire aboutOpened event")
    @MainActor
    func dismissingAboutDoesNotFireEvent() {
        let spy = SpyAnalyticsService()
        let vm = AppViewModel(analytics: spy)
        vm.showAbout = true

        vm.showAbout = false

        #expect(spy.trackedEvents == [.aboutOpened])
    }

    @Test("Setting showAbout to true multiple times fires aboutOpened only once")
    @MainActor
    func showAboutMultipleTrueAssignmentsDoNotDuplicateEvent() {
        let spy = SpyAnalyticsService()
        let vm = AppViewModel(analytics: spy)

        vm.showAbout = true
        vm.showAbout = true

        #expect(spy.trackedEvents == [.aboutOpened])
    }
}
