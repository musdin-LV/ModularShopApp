import Observation

@MainActor
@Observable
public final class ForgotPasswordViewModel {
    public var usernameOrEmail = ""
    public private(set) var isLoading = false
    public private(set) var message: String?
    public private(set) var errorMessage: String?

    private let repository: any AuthRepository

    public init(repository: any AuthRepository) {
        self.repository = repository
    }

    public func requestPasswordReset() async {
        guard !usernameOrEmail.isEmpty else {
            errorMessage = "Username or email is required."
            return
        }

        isLoading = true
        message = nil
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            try await repository.requestPasswordReset(
                PasswordResetRequest(usernameOrEmail: usernameOrEmail)
            )
            message = "If the account exists, reset instructions will be sent."
        } catch {
            errorMessage = "Unable to request a password reset."
        }
    }
}
