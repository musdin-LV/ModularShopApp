public struct LoadFeatureFlagsUseCase: Sendable {
    private let repository: any FeatureFlagRepository

    public init(repository: any FeatureFlagRepository) {
        self.repository = repository
    }

    public func execute() async throws -> FeatureFlagSet {
        try await repository.loadFlags()
    }
}
