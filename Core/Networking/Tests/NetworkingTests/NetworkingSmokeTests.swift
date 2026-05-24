import Testing
@testable import Networking

@Test
func networkErrorEquatable() {
    #expect(NetworkError.requestFailed(statusCode: 401) == .requestFailed(statusCode: 401))
}
