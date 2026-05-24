import Foundation
import Networking

public struct RemoteClientRepository: ClientRepository {
    private let apiClient: any APIClient
    private let encoder: JSONEncoder

    public init(apiClient: any APIClient, encoder: JSONEncoder = JSONEncoder()) {
        self.apiClient = apiClient
        self.encoder = encoder
    }

    public func searchClients(query: String) async throws -> [Client] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return []
        }

        let response: ClientSearchResponseDTO = try await apiClient.send(
            APIRequest(
                path: "/users/search",
                queryItems: [URLQueryItem(name: "q", value: trimmedQuery)]
            )
        )

        return response.users.map(\.domainModel)
    }

    public func createClient(_ request: CreateClientRequest) async throws -> Client {
        guard !request.firstName.isEmpty, !request.lastName.isEmpty, !request.email.isEmpty else {
            throw ClientError.emptyRequiredFields
        }

        let payload = CreateClientRequestDTO(
            firstName: request.firstName,
            lastName: request.lastName,
            email: request.email,
            phone: request.phone,
            country: request.country.rawValue
        )
        let body = try encoder.encode(payload)
        let response: ClientDTO = try await apiClient.send(
            APIRequest(
                path: "/users/add",
                method: .post,
                headers: ["Content-Type": "application/json"],
                body: body
            )
        )

        return response.domainModel
    }

    public func updateClient(_ request: UpdateClientRequest) async throws -> Client {
        guard !request.firstName.isEmpty, !request.lastName.isEmpty, !request.email.isEmpty else {
            throw ClientError.emptyRequiredFields
        }

        let payload = CreateClientRequestDTO(
            firstName: request.firstName,
            lastName: request.lastName,
            email: request.email,
            phone: request.phone,
            country: request.country.rawValue
        )
        let body = try encoder.encode(payload)
        let response: ClientDTO = try await apiClient.send(
            APIRequest(
                path: "/users/\(request.id)",
                method: .put,
                headers: ["Content-Type": "application/json"],
                body: body
            )
        )

        return response.domainModel
    }
}

private struct ClientSearchResponseDTO: Decodable, Sendable {
    let users: [ClientDTO]
}

private struct ClientDTO: Decodable, Sendable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
    let country: String?

    var domainModel: Client {
        Client(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            country: ClientCountry(rawValue: country ?? "") ?? .france
        )
    }
}

private struct CreateClientRequestDTO: Encodable, Sendable {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
    let country: String
}
