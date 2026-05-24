public protocol StoreContextRepository: Sendable {
    func loadStoreContext() async throws -> StoreContext
}
