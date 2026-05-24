import Foundation

public enum SaveClientMode: Equatable, Sendable {
    case create
    case update(Client)
}

public struct ClientFormInput: Equatable, Sendable {
    public let firstName: String
    public let lastName: String
    public let email: String
    public let phone: String
    public let country: ClientCountry

    public init(
        firstName: String,
        lastName: String,
        email: String,
        phone: String,
        country: ClientCountry
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.country = country
    }
}

public struct SaveClientUseCase: Sendable {
    private let repository: any ClientRepository

    public init(repository: any ClientRepository) {
        self.repository = repository
    }

    public func execute(mode: SaveClientMode, input: ClientFormInput) async throws -> Client {
        let firstName = input.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = input.lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = input.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = input.phone.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty

        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty else {
            throw ClientError.emptyRequiredFields
        }

        switch mode {
        case .create:
            return try await repository.createClient(
                CreateClientRequest(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    phone: phone,
                    country: input.country
                )
            )
        case let .update(client):
            return try await repository.updateClient(
                UpdateClientRequest(
                    id: client.id,
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    phone: phone,
                    country: input.country
                )
            )
        }
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
