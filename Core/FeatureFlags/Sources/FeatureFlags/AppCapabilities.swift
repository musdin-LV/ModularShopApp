public enum AppPlatform: Sendable {
    case iPhone
    case iPad
}

public enum AppCapability: Sendable {
    case cart
    case checkout
    case clientManagement
    case favorites
    case passwordReset
    case productSearch
    case startSale
}

public struct AppCapabilities: Equatable, Sendable {
    private let platform: AppPlatform
    private let flags: FeatureFlagSet

    public init(platform: AppPlatform, flags: FeatureFlagSet) {
        self.platform = platform
        self.flags = flags
    }

    public func allows(_ capability: AppCapability) -> Bool {
        switch capability {
        case .cart:
            platform == .iPhone && flags.isEnabled(.cart)
        case .checkout:
            platform == .iPhone && flags.isEnabled(.cart) && flags.isEnabled(.checkout)
        case .clientManagement:
            flags.isEnabled(.clientManagement)
        case .favorites:
            flags.isEnabled(.favorites)
        case .passwordReset:
            flags.isEnabled(.passwordReset)
        case .productSearch:
            flags.isEnabled(.productSearch)
        case .startSale:
            platform == .iPhone && flags.isEnabled(.cart)
        }
    }
}
