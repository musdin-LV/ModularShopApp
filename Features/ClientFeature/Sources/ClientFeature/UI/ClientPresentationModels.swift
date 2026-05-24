public struct ClientRowState: Identifiable, Equatable, Sendable {
    public let id: Client.ID
    public let displayName: String
    public let email: String
    public let countryName: String

    public init(client: Client) {
        self.id = client.id
        self.displayName = client.displayName
        self.email = client.email
        self.countryName = client.country.rawValue
    }
}

public struct ClientDetailViewState: Equatable, Sendable {
    public let title: String
    public let displayName: String
    public let email: String
    public let phone: String?
    public let countryName: String

    public init(client: Client) {
        self.title = client.displayName
        self.displayName = client.displayName
        self.email = client.email
        self.phone = client.phone
        self.countryName = client.country.rawValue
    }
}
