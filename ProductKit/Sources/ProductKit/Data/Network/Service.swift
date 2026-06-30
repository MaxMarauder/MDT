//
//  Service.swift
//  ProductKit — Data layer / Network
//

import Foundation

/// HTTP verbs. `Sendable` so endpoint specs can cross concurrency domains freely.
public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

// MARK: - Service
//
// `Service` describes a request declaratively — it's a specification of an
// endpoint (method, URL, query, body, headers), not imperative networking code.
// To add an endpoint you describe it as a type; the client stays untouched.
//
// `Sendable` conformance means every concrete endpoint is safe to hand to the
// async client across an actor boundary.
public protocol Service: Sendable {
    static var endpoint: String { get }
    var method: HTTPMethod { get }
    var baseURL: URL { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Data? { get }
    var headers: [String: String] { get }
    var url: URL { get }
}

// Protocol-extension defaults: an endpoint only overrides what differs from a
// plain authenticated Mockaroo GET.
public extension Service {
    var baseURL: URL { URL(string: "https://my.api.mockaroo.com")! }
    var method: HTTPMethod { .get }
    var queryItems: [URLQueryItem]? { nil }
    var body: Data? { nil }
    var headers: [String: String] {
        [
            "Content-type": "application/json",
            "X-API-Key": "6de8eb90"
        ]
    }
    var url: URL { baseURL.appendingPathComponent(Self.endpoint) }
}
