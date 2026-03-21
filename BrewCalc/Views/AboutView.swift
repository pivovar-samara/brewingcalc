import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showMailAlert = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text(l("about.label.email"))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button(bcEmail) {
                openEmail()
            }
            .buttonStyle(.borderedProminent)
            .tint(.brewCalcAccent)

            Spacer()

            Text(l("about.label.copyright"))
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.bottom, 24)
        }
        .padding(.horizontal, 32)
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
        guard let url = URL(string: "mailto:\(bcEmail)?subject=\(l("mail.subject"))") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            UIPasteboard.general.string = bcEmail
            showMailAlert = true
        }
    }
}
