//
//  HTTPClient.swift
//  ProductKit — Data layer / Network
//

import Foundation

/// Failures surfaced by the networking layer.
public enum APIError: Error, Sendable {
    case network(Error)
    case invalidResponse(statusCode: Int)
    case parsing(Error)
}

// MARK: - HTTPClient
//
// The protocol is the testing seam: repositories depend on `HTTPClient`, never on
// `URLSession`, so tests inject a mock. `Sendable` lets the client be shared
// across actors safely.
public protocol HTTPClient: Sendable {
    /// Performs `resource`'s request and decodes its `Payload`.
    ///
    /// `async throws` lets callers write straight-line code —
    /// `let dtos = try await client.request(...)` — with errors propagating up and
    /// `Task` cancellation honored automatically.
    func request<R: Resource>(_ resource: R) async throws -> R.Payload
}

// MARK: - URLSession implementation

public final class APIClient: HTTPClient {
    private let session: URLSession

    /// `URLSession` is injectable so tests can use a mock-protocol session.
    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func request<R: Resource>(_ resource: R) async throws -> R.Payload {
        var components = URLComponents(url: resource.url, resolvingAgainstBaseURL: false)!
        components.queryItems = resource.queryItems

        guard let url = components.url else {
            throw APIError.invalidResponse(statusCode: -1)
        }

        var request = URLRequest(url: url)
        request.httpMethod = resource.method.rawValue
        request.httpBody = resource.body
        request.allHTTPHeaderFields = resource.headers

        #if DEBUG
        print("🌀 Request [\(resource.method.rawValue)]: \(url)")
        #endif

        // `URLSession.data(for:)` suspends this task until the response arrives,
        // then resumes — no callback, no manual hop to the main queue. Honors
        // `Task` cancellation automatically.
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.network(error)
        }

        if let http = response as? HTTPURLResponse,
           !(200..<300).contains(http.statusCode) {
            throw APIError.invalidResponse(statusCode: http.statusCode)
        }

        #if DEBUG
        print("✅ Response: \(String(data: data, encoding: .utf8) ?? "???")")
        #endif

        return try resource.parse(data)
    }
}
