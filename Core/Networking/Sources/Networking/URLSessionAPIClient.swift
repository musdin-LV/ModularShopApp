import Foundation

public struct URLSessionAPIClient: APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(
        baseURL: URL = URL(string: "https://dummyjson.com")!,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    public func send<Response: Decodable & Sendable>(_ request: APIRequest) async throws -> Response {
        let urlRequest = try makeURLRequest(from: request)
        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.requestFailed(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    private func makeURLRequest(from request: APIRequest) throws -> URLRequest {
        let trimmedPath = request.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(trimmedPath),
            resolvingAgainstBaseURL: false
        ) else {
            throw NetworkError.invalidURL
        }

        if !request.queryItems.isEmpty {
            components.queryItems = request.queryItems
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body

        request.headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        return urlRequest
    }
}
