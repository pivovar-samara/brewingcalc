import SwiftUI
import WebKit

struct InstructionView: View {
    let filename: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        WebViewRepresentable(filename: filename)
            .navigationTitle(l("instruction.title"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(l("button.close")) {
                        dismiss()
                    }
                }
            }
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    let filename: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if let filepath = Bundle.main.path(forResource: filename, ofType: "html") {
            let url = URL(fileURLWithPath: filepath)
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
