public protocol ClientRepository: Sendable {
    func searchClients(query: String) async throws -> [Client]
    func createClient(_ request: CreateClientRequest) async throws -> Client
    func updateClient(_ request: UpdateClientRequest) async throws -> Client
}

public enum ClientError: Error, Equatable, Sendable {
    case emptyRequiredFields
}
