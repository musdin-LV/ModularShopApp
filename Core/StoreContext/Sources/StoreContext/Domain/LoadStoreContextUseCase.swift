public struct LoadStoreContextUseCase: Sendable {
    private let repository: any StoreContextRepository

    public init(repository: any StoreContextRepository) {
        self.repository = repository
    }

    public func execute() async throws -> StoreContext {
        try await repository.loadStoreContext()
    }
}
