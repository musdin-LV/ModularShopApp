import Foundation

public struct Client: Identifiable, Equatable, Hashable, Sendable {
    public let id: Int
    public let firstName: String
    public let lastName: String
    public let email: String
    public let phone: String?
    public let country: ClientCountry

    public init(
        id: Int,
        firstName: String,
        lastName: String,
        email: String,
        phone: String? = nil,
        country: ClientCountry = .france
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.country = country
    }

    public var displayName: String {
        "\(firstName) \(lastName)"
    }
}

public enum ClientCountry: String, CaseIterable, Identifiable, Equatable, Hashable, Sendable {
    case france = "France"
    case belgium = "Belgium"
    case germany = "Germany"
    case italy = "Italy"
    case spain = "Spain"
    case unitedKingdom = "United Kingdom"
    case unitedStates = "United States"

    public var id: String {
        rawValue
    }
}

public struct CreateClientRequest: Equatable, Sendable {
    public let firstName: String
    public let lastName: String
    public let email: String
    public let phone: String?
    public let country: ClientCountry

    public init(
        firstName: String,
        lastName: String,
        email: String,
        phone: String? = nil,
        country: ClientCountry
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.country = country
    }
}

public struct UpdateClientRequest: Equatable, Sendable {
    public let id: Client.ID
    public let firstName: String
    public let lastName: String
    public let email: String
    public let phone: String?
    public let country: ClientCountry

    public init(
        id: Client.ID,
        firstName: String,
        lastName: String,
        email: String,
        phone: String? = nil,
        country: ClientCountry
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.country = country
    }
}
