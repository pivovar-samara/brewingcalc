import SwiftUI

@main
struct BrewCalcApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var appViewModel = AppViewModel(analytics: NoOpAnalyticsService())

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
