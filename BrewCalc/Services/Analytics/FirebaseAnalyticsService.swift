import FirebaseAnalytics
import FirebaseCore

struct FirebaseAnalyticsService: AnalyticsService {
    init() {
        let info = Bundle.main.infoDictionary
        let options = FirebaseOptions(
            googleAppID: info?["FIREBASE_APP_ID"] as? String ?? "",
            gcmSenderID: info?["FIREBASE_GCM_SENDER_ID"] as? String ?? ""
        )
        options.apiKey = info?["FIREBASE_API_KEY"] as? String
        options.projectID = info?["FIREBASE_PROJECT_ID"] as? String
        options.storageBucket = info?["FIREBASE_STORAGE_BUCKET"] as? String
        FirebaseApp.configure(options: options)

        // Debug builds: collection is off unless -FIRAnalyticsDebugEnabled is
        // present in the scheme's launch arguments. That flag also routes events
        // to Firebase Console's real-time DebugView instead of the normal batch.
        // CI builds run in Debug without the flag, so they are always silent.
        // Release builds: collection defaults to enabled; the block is skipped.
        #if DEBUG
        let debugEnabled = ProcessInfo.processInfo.arguments
            .contains("-FIRAnalyticsDebugEnabled")
        Analytics.setAnalyticsCollectionEnabled(debugEnabled)
        #endif

        // Collect anonymous usage events only — no advertising identifiers,
        // no user-level tracking, no cross-app signals.
        // This approach does not require user consent under GDPR / CCPA.
        Analytics.setConsent([
            .analyticsStorage: .granted,
            .adStorage: .denied,
            .adUserData: .denied,
            .adPersonalization: .denied
        ])
    }

    func track(_ event: AnalyticsEvent) {
        switch event {
        case .appOpened:
            Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)

        case .calculatorOpened(let categoryName):
            Analytics.logEvent("calculator_opened", parameters: [
                "category_name": categoryName
            ])

        case .calculationPerformed(let calculatorName, let categoryName):
            Analytics.logEvent("calculation_performed", parameters: [
                "calculator_name": calculatorName,
                "category_name": categoryName
            ])
        }
    }
}
