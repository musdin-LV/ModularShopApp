import DesignSystem
import SwiftUI

public struct AuthView: View {
    @State private var loginViewModel: LoginViewModel
    @State private var registerViewModel: RegisterViewModel
    @State private var forgotPasswordViewModel: ForgotPasswordViewModel
    @State private var mode = AuthMode.login

    private let allowsPasswordReset: Bool
    private let onAuthenticated: @MainActor (UserSession) -> Void

    public init(
        loginViewModel: LoginViewModel,
        registerViewModel: RegisterViewModel,
        forgotPasswordViewModel: ForgotPasswordViewModel,
        allowsPasswordReset: Bool = true,
        onAuthenticated: @escaping @MainActor (UserSession) -> Void
    ) {
        _loginViewModel = State(initialValue: loginViewModel)
        _registerViewModel = State(initialValue: registerViewModel)
        _forgotPasswordViewModel = State(initialValue: forgotPasswordViewModel)
        self.allowsPasswordReset = allowsPasswordReset
        self.onAuthenticated = onAuthenticated
    }

    public var body: some View {
        NavigationStack {
            Form {
                Picker("Mode", selection: $mode) {
                    Text("Login").tag(AuthMode.login)
                    Text("Create account").tag(AuthMode.register)
                    if allowsPasswordReset {
                        Text("Reset").tag(AuthMode.forgotPassword)
                    }
                }
                .pickerStyle(.segmented)
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))

                switch mode {
                case .login:
                    LoginForm(
                        viewModel: loginViewModel,
                        onAuthenticated: onAuthenticated
                    )
                case .register:
                    RegisterForm(
                        viewModel: registerViewModel,
                        onAuthenticated: onAuthenticated
                    )
                case .forgotPassword:
                    ForgotPasswordForm(viewModel: forgotPasswordViewModel)
                }
            }
            .navigationTitle("Modular Shop")
        }
    }
}

private enum AuthMode: Hashable {
    case login
    case register
    case forgotPassword
}

private struct LoginForm: View {
    @Bindable var viewModel: LoginViewModel
    let onAuthenticated: @MainActor (UserSession) -> Void

    var body: some View {
        Section("Login") {
            TextField("Username", text: $viewModel.username)
                .autocorrectionDisabled()
            SecureField("Password", text: $viewModel.password)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            PrimaryButton("Login", isLoading: viewModel.isLoading) {
                Task {
                    if let session = await viewModel.login() {
                        onAuthenticated(session)
                    }
                }
            }
        }
    }
}

private struct ForgotPasswordForm: View {
    @Bindable var viewModel: ForgotPasswordViewModel

    var body: some View {
        Section("Forgot password") {
            TextField("Username or email", text: $viewModel.usernameOrEmail)
                .autocorrectionDisabled()

            if let message = viewModel.message {
                Text(message)
                    .foregroundStyle(.secondary)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            PrimaryButton("Request reset", isLoading: viewModel.isLoading) {
                Task {
                    await viewModel.requestPasswordReset()
                }
            }
        }
    }
}

private struct RegisterForm: View {
    @Bindable var viewModel: RegisterViewModel
    let onAuthenticated: @MainActor (UserSession) -> Void

    var body: some View {
        Section("Create account") {
            TextField("Username", text: $viewModel.username)
                .autocorrectionDisabled()
            SecureField("Password", text: $viewModel.password)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            PrimaryButton("Create account", isLoading: viewModel.isLoading) {
                Task {
                    if let session = await viewModel.register() {
                        onAuthenticated(session)
                    }
                }
            }
        }
    }
}
