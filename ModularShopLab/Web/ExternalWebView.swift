import SafariServices
import SwiftUI

struct ExternalWebRoute: Identifiable, Sendable {
    let id = UUID()
    let url: URL
}

struct ExternalWebView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let viewController = SFSafariViewController(url: url)
        viewController.dismissButtonStyle = .close
        return viewController
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
