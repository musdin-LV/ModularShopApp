public protocol FeatureFlagRepository: Sendable {
    func loadFlags() async throws -> FeatureFlagSet
}

public enum FeatureFlagLoadingError: Error, Equatable, Sendable {
    case missingLocalConfiguration
}
