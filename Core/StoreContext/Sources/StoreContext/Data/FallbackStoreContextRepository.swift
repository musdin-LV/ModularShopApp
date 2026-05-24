public struct FallbackStoreContextRepository: StoreContextRepository {
    private let primary: any StoreContextRepository
    private let fallback: any StoreContextRepository

    public init(primary: any StoreContextRepository, fallback: any StoreContextRepository) {
        self.primary = primary
        self.fallback = fallback
    }

    public func loadStoreContext() async throws -> StoreContext {
        do {
            return try await primary.loadStoreContext()
        } catch {
            return try await fallback.loadStoreContext()
        }
    }
}
