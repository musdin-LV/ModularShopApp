public struct FallbackFeatureFlagRepository: FeatureFlagRepository {
    private let primary: any FeatureFlagRepository
    private let fallback: any FeatureFlagRepository

    public init(primary: any FeatureFlagRepository, fallback: any FeatureFlagRepository) {
        self.primary = primary
        self.fallback = fallback
    }

    public func loadFlags() async throws -> FeatureFlagSet {
        do {
            return try await primary.loadFlags()
        } catch {
            return try await fallback.loadFlags()
        }
    }
}
