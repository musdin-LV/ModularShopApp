import Networking

public struct RemoteFeatureFlagRepository: FeatureFlagRepository {
    private let apiClient: any APIClient
    private let path: String

    public init(apiClient: any APIClient, path: String = "/feature-flags") {
        self.apiClient = apiClient
        self.path = path
    }

    public func loadFlags() async throws -> FeatureFlagSet {
        let response: [String: Bool] = try await apiClient.send(APIRequest(path: path))
        return FeatureFlagConfiguration(
            values: response.reduce(into: [FeatureFlag: Bool]()) { result, element in
                guard let flag = FeatureFlag(rawValue: element.key) else {
                    return
                }

                result[flag] = element.value
            }
        )
        .featureFlagSet
    }
}
