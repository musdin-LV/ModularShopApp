import Foundation

public struct FeatureFlagConfiguration: Equatable, Sendable {
    public let values: [FeatureFlag: Bool]

    public init(values: [FeatureFlag: Bool]) {
        self.values = values
    }

    public static func decode(from data: Data, decoder: JSONDecoder = JSONDecoder()) throws -> FeatureFlagConfiguration {
        let rawValues = try decoder.decode([String: Bool].self, from: data)
        let values = rawValues.reduce(into: [FeatureFlag: Bool]()) { result, element in
            guard let flag = FeatureFlag(rawValue: element.key) else {
                return
            }

            result[flag] = element.value
        }

        return FeatureFlagConfiguration(values: values)
    }

    public var featureFlagSet: FeatureFlagSet {
        FeatureFlagSet(
            enabledFlags: Set(
                values.compactMap { flag, isEnabled in
                    isEnabled ? flag : nil
                }
            )
        )
    }
}
