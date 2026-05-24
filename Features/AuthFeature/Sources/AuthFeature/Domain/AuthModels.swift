import Foundation

public struct UserSession: Equatable, Sendable {
    public let userID: Int
    public let username: String
    public let accessToken: String

    public init(userID: Int, username: String, accessToken: String) {
        self.userID = userID
        self.username = username
        self.accessToken = accessToken
    }
}

public struct LoginCredentials: Equatable, Sendable {
    public let username: String
    public let password: String

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

public struct RegisterCredentials: Equatable, Sendable {
    public let username: String
    public let password: String

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

public enum AuthError: Error, Equatable, Sendable {
    case invalidCredentials
    case emptyFields
}

public struct PasswordResetRequest: Equatable, Sendable {
    public let usernameOrEmail: String

    public init(usernameOrEmail: String) {
        self.usernameOrEmail = usernameOrEmail
    }
}
