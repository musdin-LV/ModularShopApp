import FeatureFlags
import Foundation
import Networking
import Testing

@Test
func iPadDisablesCartCheckoutAndStartSale() {
    let capabilities = AppCapabilities(platform: .iPad, flags: .allEnabled)

    #expect(capabilities.allows(.cart) == false)
    #expect(capabilities.allows(.checkout) == false)
    #expect(capabilities.allows(.startSale) == false)
    #expect(capabilities.allows(.clientManagement) == true)
}

@Test
func disabledFlagRemovesCapability() {
    let flags = FeatureFlagSet(enabledFlags: [.cart, .clientManagement])
    let capabilities = AppCapabilities(platform: .iPhone, flags: flags)

    #expect(capabilities.allows(.cart) == true)
    #expect(capabilities.allows(.checkout) == false)
    #expect(capabilities.allows(.favorites) == false)
    #expect(capabilities.allows(.clientManagement) == true)
}

@Test
func jsonRepositoryDecodesEnabledFlags() async throws {
    let json = """
    {
      "cart": true,
      "checkout": false,
      "clientManagement": true,
      "favorites": false,
      "passwordReset": true,
      "productSearch": true,
      "unknownFutureFlag": true
    }
    """
    let repository = JSONFeatureFlagRepository {
        try #require(json.data(using: .utf8))
    }
    let flags = try await repository.loadFlags()
    let capabilities = AppCapabilities(platform: .iPhone, flags: flags)

    #expect(capabilities.allows(.cart) == true)
    #expect(capabilities.allows(.checkout) == false)
    #expect(capabilities.allows(.clientManagement) == true)
    #expect(capabilities.allows(.favorites) == false)
    #expect(capabilities.allows(.passwordReset) == true)
    #expect(capabilities.allows(.productSearch) == true)
}

@Test
func remoteRepositoryDecodesWebServicePayload() async throws {
    let repository = RemoteFeatureFlagRepository(
        apiClient: StubAPIClient(
            payload: [
                "cart": true,
                "checkout": true,
                "favorites": false
            ]
        )
    )

    let flags = try await repository.loadFlags()
    let capabilities = AppCapabilities(platform: .iPhone, flags: flags)

    #expect(capabilities.allows(.cart) == true)
    #expect(capabilities.allows(.checkout) == true)
    #expect(capabilities.allows(.favorites) == false)
}

@Test
func fallbackRepositoryUsesLocalJSONWhenRemoteFails() async throws {
    let localJSON = """
    {
      "cart": true,
      "checkout": false,
      "clientManagement": true
    }
    """
    let repository = FallbackFeatureFlagRepository(
        primary: FailingFeatureFlagRepository(),
        fallback: JSONFeatureFlagRepository {
            try #require(localJSON.data(using: .utf8))
        }
    )

    let flags = try await repository.loadFlags()
    let capabilities = AppCapabilities(platform: .iPhone, flags: flags)

    #expect(capabilities.allows(.cart) == true)
    #expect(capabilities.allows(.checkout) == false)
    #expect(capabilities.allows(.clientManagement) == true)
}

private struct StubAPIClient: APIClient {
    let payload: [String: Bool]

    func send<Response: Decodable & Sendable>(_ request: APIRequest) async throws -> Response {
        let data = try JSONEncoder().encode(payload)
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

private struct FailingFeatureFlagRepository: FeatureFlagRepository {
    func loadFlags() async throws -> FeatureFlagSet {
        throw TestError.failed
    }
}

private enum TestError: Error {
    case failed
}
