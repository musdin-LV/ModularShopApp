import Foundation

enum AppConfiguration: Sendable {
    case remote
    case mock

    static func current(environment: [String: String] = ProcessInfo.processInfo.environment) -> AppConfiguration {
        switch environment["MODULAR_SHOP_CONFIGURATION"]?.lowercased() {
        case "mock":
            .mock
        default:
            .remote
        }
    }
}
