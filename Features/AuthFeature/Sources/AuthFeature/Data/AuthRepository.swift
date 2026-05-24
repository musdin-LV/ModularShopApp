import Foundation
import Networking

public protocol AuthRepository: Sendable {
    func login(credentials: LoginCredentials) async throws -> UserSession
    func register(credentials: RegisterCredentials) async throws -> UserSession
    func requestPasswordReset(_ request: PasswordResetRequest) async throws
}

public struct RemoteAuthRepository: AuthRepository {
    private let apiClient: any APIClient
    private let encoder: JSONEncoder

    public init(apiClient: any APIClient, encoder: JSONEncoder = JSONEncoder()) {
        self.apiClient = apiClient
        self.encoder = encoder
    }

    public func login(credentials: LoginCredentials) async throws -> UserSession {
        let payload = LoginRequestDTO(
            username: credentials.username,
            password: credentials.password
        )
        let body = try encoder.encode(payload)
        let response: LoginResponseDTO = try await apiClient.send(
            APIRequest(
                path: "/auth/login",
                method: .post,
                headers: ["Content-Type": "application/json"],
                body: body
            )
        )

        return UserSession(
            userID: response.id,
            username: response.username,
            accessToken: response.accessToken
        )
    }

    public func register(credentials: RegisterCredentials) async throws -> UserSession {
        guard !credentials.username.isEmpty, !credentials.password.isEmpty else {
            throw AuthError.emptyFields
        }

        let payload = RegisterRequestDTO(
            username: credentials.username,
            password: credentials.password
        )
        let body = try encoder.encode(payload)
        let response: RegisterResponseDTO = try await apiClient.send(
            APIRequest(
                path: "/users/add",
                method: .post,
                headers: ["Content-Type": "application/json"],
                body: body
            )
        )

        return UserSession(
            userID: response.id,
            username: response.username,
            accessToken: "registered-session-\(response.id)"
        )
    }

    public func requestPasswordReset(_ request: PasswordResetRequest) async throws {
        guard !request.usernameOrEmail.isEmpty else {
            throw AuthError.emptyFields
        }

        let _: UserSearchResponseDTO = try await apiClient.send(
            APIRequest(
                path: "/users/search",
                queryItems: [URLQueryItem(name: "q", value: request.usernameOrEmail)]
            )
        )
    }
}

private struct LoginRequestDTO: Encodable, Sendable {
    let username: String
    let password: String
}

private struct LoginResponseDTO: Decodable, Sendable {
    let id: Int
    let username: String
    let accessToken: String
}

private struct RegisterRequestDTO: Encodable, Sendable {
    let username: String
    let password: String
}

private struct RegisterResponseDTO: Decodable, Sendable {
    let id: Int
    let username: String
}

private struct UserSearchResponseDTO: Decodable, Sendable {
    let users: [UserDTO]
}

private struct UserDTO: Decodable, Sendable {
    let id: Int
}
