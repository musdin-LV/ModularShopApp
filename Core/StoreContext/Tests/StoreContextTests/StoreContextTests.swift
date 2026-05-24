import StoreContext
import Testing

@Test
func loadStoreContextUseCaseReturnsContext() async throws {
    let expectedContext = StoreContext.defaultRetailContext
    let useCase = LoadStoreContextUseCase(repository: StaticStoreContextRepository(context: expectedContext))

    let context = try await useCase.execute()

    #expect(context == expectedContext)
}

@Test
func fallbackRepositoryReturnsFallbackWhenPrimaryFails() async throws {
    let fallbackContext = StoreContext.defaultRetailContext
    let repository = FallbackStoreContextRepository(
        primary: FailingStoreContextRepository(),
        fallback: StaticStoreContextRepository(context: fallbackContext)
    )

    let context = try await repository.loadStoreContext()

    #expect(context == fallbackContext)
}

private struct FailingStoreContextRepository: StoreContextRepository {
    func loadStoreContext() async throws -> StoreContext {
        throw TestError.failed
    }
}

private enum TestError: Error {
    case failed
}
