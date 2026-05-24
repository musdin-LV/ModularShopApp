public struct StaticStoreContextRepository: StoreContextRepository {
    private let context: StoreContext

    public init(context: StoreContext = .defaultRetailContext) {
        self.context = context
    }

    public func loadStoreContext() async throws -> StoreContext {
        context
    }
}

public extension StoreContext {
    static let defaultRetailContext = StoreContext(
        store: Store(
            id: "PAR-001",
            name: "Paris Flagship",
            countryCode: "FR",
            currencyCode: "EUR"
        ),
        employee: Employee(
            id: "EMP-001",
            displayName: "Emilie",
            role: .seller
        ),
        salesChannel: .store
    )
}
