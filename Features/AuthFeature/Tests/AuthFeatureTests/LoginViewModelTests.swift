import Testing
@testable import AuthFeature

@MainActor
@Test
func loginViewModelHandlesSuccess() async {
    let session = UserSession(userID: 1, username: "emilys", accessToken: "token")
    let viewModel = LoginViewModel(repository: StubAuthRepository(result: .success(session)))

    let returnedSession = await viewModel.login()

    #expect(returnedSession == session)
    #expect(viewModel.errorMessage == nil)
    #expect(viewModel.isLoading == false)
}

@MainActor
@Test
func loginViewModelHandlesFailure() async {
    let viewModel = LoginViewModel(repository: StubAuthRepository(result: .failure(AuthError.invalidCredentials)))

    let returnedSession = await viewModel.login()

    #expect(returnedSession == nil)
    #expect(viewModel.errorMessage == "Login failed. Check your credentials.")
    #expect(viewModel.isLoading == false)
}

@MainActor
@Test
func forgotPasswordViewModelHandlesSuccess() async {
    let session = UserSession(userID: 1, username: "emilys", accessToken: "token")
    let viewModel = ForgotPasswordViewModel(repository: StubAuthRepository(result: .success(session)))
    viewModel.usernameOrEmail = "emilys"

    await viewModel.requestPasswordReset()

    #expect(viewModel.message == "If the account exists, reset instructions will be sent.")
    #expect(viewModel.errorMessage == nil)
    #expect(viewModel.isLoading == false)
}

private struct StubAuthRepository: AuthRepository {
    let result: Result<UserSession, Error>

    func login(credentials: LoginCredentials) async throws -> UserSession {
        try result.get()
    }

    func register(credentials: RegisterCredentials) async throws -> UserSession {
        try result.get()
    }

    func requestPasswordReset(_ request: PasswordResetRequest) async throws {
        _ = try result.get()
    }
}
