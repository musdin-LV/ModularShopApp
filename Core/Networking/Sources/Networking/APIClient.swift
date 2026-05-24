import Foundation

public protocol APIClient: Sendable {
    func send<Response: Decodable & Sendable>(_ request: APIRequest) async throws -> Response
}

public struct APIRequest: Sendable {
    public let path: String
    public let method: HTTPMethod
    public let queryItems: [URLQueryItem]
    public let headers: [String: String]
    public let body: Data?

    public init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
    }
}

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

public enum NetworkError: Error, Equatable, Sendable {
    case invalidURL
    case invalidResponse
    case requestFailed(statusCode: Int)
    case decodingFailed
}
