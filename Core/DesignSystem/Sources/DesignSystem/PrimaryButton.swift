import SwiftUI

public struct PrimaryButton: View {
    private let title: String
    private let isLoading: Bool
    private let action: @MainActor () -> Void

    public init(
        _ title: String,
        isLoading: Bool = false,
        action: @escaping @MainActor () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                }

                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(isLoading)
    }
}
