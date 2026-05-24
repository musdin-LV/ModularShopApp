import SwiftUI

public struct ErrorStateView: View {
    private let message: String
    private let retry: (@MainActor () -> Void)?

    public init(
        message: String,
        retry: (@escaping @MainActor () -> Void)
    ) {
        self.message = message
        self.retry = retry
    }

    public init(message: String) {
        self.message = message
        self.retry = nil
    }

    public var body: some View {
        ContentUnavailableView {
            Label("Something went wrong", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            if let retry {
                Button("Retry", action: retry)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}
