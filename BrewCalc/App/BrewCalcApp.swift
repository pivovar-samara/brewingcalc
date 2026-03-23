import SwiftUI

@main
struct BrewCalcApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var appViewModel: AppViewModel

    init() {
        // Unit tests:  XCTestConfigurationFilePath is present in the process environment.
        // UI tests:    the test runner injects -RunningTests via launchArguments.
        // In both cases skip Firebase entirely — no credentials needed to run tests.
        let isRunningTests =
            ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ||
            ProcessInfo.processInfo.arguments.contains("-RunningTests")

        let analytics: any AnalyticsService = isRunningTests
            ? NoOpAnalyticsService()
            : FirebaseAnalyticsService()

        _appViewModel = State(initialValue: AppViewModel(analytics: analytics))
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: appViewModel)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                appViewModel.trackAppOpened()
            }
        }
    }
}
