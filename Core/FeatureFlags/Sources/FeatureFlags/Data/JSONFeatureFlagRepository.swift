import Foundation

public struct JSONFeatureFlagRepository: FeatureFlagRepository {
    private let dataProvider: @Sendable () throws -> Data

    public init(dataProvider: @escaping @Sendable () throws -> Data) {
        self.dataProvider = dataProvider
    }

    public func loadFlags() async throws -> FeatureFlagSet {
        try FeatureFlagConfiguration.decode(from: dataProvider()).featureFlagSet
    }
}
