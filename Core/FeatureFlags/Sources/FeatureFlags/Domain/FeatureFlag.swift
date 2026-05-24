public enum FeatureFlag: String, CaseIterable, Hashable, Sendable {
    case cart
    case checkout
    case clientManagement
    case favorites
    case passwordReset
    case productSearch
}

public struct FeatureFlagSet: Equatable, Sendable {
    private let enabledFlags: Set<FeatureFlag>

    public init(enabledFlags: Set<FeatureFlag>) {
        self.enabledFlags = enabledFlags
    }

    public static let allEnabled = FeatureFlagSet(enabledFlags: Set(FeatureFlag.allCases))

    public func isEnabled(_ flag: FeatureFlag) -> Bool {
        enabledFlags.contains(flag)
    }
}
