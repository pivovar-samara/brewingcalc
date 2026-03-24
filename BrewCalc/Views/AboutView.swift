import SwiftUI

private enum AboutURLs {
    static let privacyEN = URL(string: "https://circular-drug-3ff.notion.site/BrewingCalc-Privacy-Policy-32c8f966e5038088b197e31e892a0eae")
    static let supportEN = URL(string: "https://circular-drug-3ff.notion.site/BrewingCalc-Support-32c8f966e503802aa086d9923ee6f31d")
    static let privacyRU = URL(string: "https://circular-drug-3ff.notion.site/BrewingCalc-32c8f966e503802fb288cc8e0bcba8f0")
    static let supportRU = URL(string: "https://circular-drug-3ff.notion.site/BrewingCalc-32c8f966e50380229186f7bfee1fe9c2")
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var showMailAlert = false

    private let analytics: any AnalyticsService

    init(analytics: any AnalyticsService = NoOpAnalyticsService()) {
        self.analytics = analytics
    }

    private var isRussian: Bool {
        Locale.current.language.languageCode?.identifier == "ru"
    }

    private var privacyURL: URL? { isRussian ? AboutURLs.privacyRU : AboutURLs.privacyEN }
    private var supportURL: URL? { isRussian ? AboutURLs.supportRU : AboutURLs.supportEN }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }

    var body: some View {
        List {
            Section {
                HStack {
                    Text(l("about.label.version"))
                    Spacer()
                    Text(appVersion)
                        .foregroundStyle(.secondary)
                }
            }

            Section(l("about.section.contact")) {
                Button {
                    openEmail()
                } label: {
                    Label(bcEmail, systemImage: "envelope")
                }
                .foregroundStyle(.brewCalcAccent)
            }

            Section(l("about.section.support")) {
                if let url = supportURL {
                    Button {
                        analytics.track(.supportLinkTapped)
                        openURL(url)
                    } label: {
                        Label(l("about.link.support"), systemImage: "questionmark.circle")
                    }
                    .foregroundStyle(.brewCalcAccent)
                }
                if let url = privacyURL {
                    Button {
                        analytics.track(.privacyPolicyTapped)
                        openURL(url)
                    } label: {
                        Label(l("about.link.privacy"), systemImage: "lock.shield")
                    }
                    .foregroundStyle(.brewCalcAccent)
                }
            }
        }
        .navigationTitle(l("about.title"))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(l("button.close")) {
                    dismiss()
                }
            }
        }
        .alert(
            l("about.alert.email.cant.send.title"),
            isPresented: $showMailAlert
        ) {
            Button(l("OK")) {}
        } message: {
            Text(l("about.alert.email.cant.send.message"))
        }
    }

    private func openEmail() {
        analytics.track(.emailTapped)
        let subject = l("mail.subject")
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "mailto:\(bcEmail)?subject=\(subject)") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            UIPasteboard.general.string = bcEmail
            showMailAlert = true
        }
    }
}
