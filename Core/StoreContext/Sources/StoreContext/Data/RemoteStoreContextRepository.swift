import Networking

public struct RemoteStoreContextRepository: StoreContextRepository {
    private let apiClient: any APIClient
    private let path: String

    public init(apiClient: any APIClient, path: String = "/store-context") {
        self.apiClient = apiClient
        self.path = path
    }

    public func loadStoreContext() async throws -> StoreContext {
        let response: StoreContextDTO = try await apiClient.send(APIRequest(path: path))
        return response.domainModel
    }
}

private struct StoreContextDTO: Decodable, Sendable {
    let store: StoreDTO
    let employee: EmployeeDTO
    let salesChannel: String

    var domainModel: StoreContext {
        StoreContext(
            store: store.domainModel,
            employee: employee.domainModel,
            salesChannel: SalesChannel(rawValue: salesChannel) ?? .store
        )
    }
}

private struct StoreDTO: Decodable, Sendable {
    let id: String
    let name: String
    let countryCode: String
    let currencyCode: String

    var domainModel: Store {
        Store(id: id, name: name, countryCode: countryCode, currencyCode: currencyCode)
    }
}

private struct EmployeeDTO: Decodable, Sendable {
    let id: String
    let displayName: String
    let role: String

    var domainModel: Employee {
        Employee(
            id: id,
            displayName: displayName,
            role: EmployeeRole(rawValue: role) ?? .seller
        )
    }
}
