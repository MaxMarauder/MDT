//
//  APIService.swift
//  MDT
//
//  Created by Maksym Kershengolts on 18.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import Foundation

/// Parsing JSON from data into a generic type
extension Data {
    func parse<T: Decodable>() -> Result<T, APIError> {
        let decoder = JSONDecoder()
        do {
            let value = try decoder.decode(T.self, from: self)
            return .success(value)
        } catch {
            #if DEBUG
            print("⛔️ JSON parsing error: \(error)")
            #endif
            return .failure(.parsingError(error))
        }
    }
}

/// `Service` is the specification for a request
protocol Service {
    static var endpoint: String { get }

    /**
     The HTTP method used in the request.

     Default value is `.get`
     */
    var method: APIClient.HTTPMethod { get }

    /**
     The target's base `URL`.

     Default value available.
     */
    var baseURL: URL { get }

    /**
     The query parameters used in the request.

     default value is `nil`
     */
    var queryItems: [URLQueryItem]? { get }

    /**
     The HTTP body to be used in the request.

     Default value is `nil`
     */
    var body: Data? { get }

    /**
     The headers to be used in the request.

     Default value is `["Content-type": "application/json"]`
     */
    var headers: [String: String] { get }

    /// The default implementation appends the `endpoint` to the `baseURL`.
    var url: URL { get }
}

extension Service {
    public var baseURL: URL {
        return URL(string: "https://my.api.mockaroo.com")!
    }

    public var method: APIClient.HTTPMethod {
        return .get
    }

    public var queryItems: [URLQueryItem]? {
        return nil
    }

    public var body: Data? {
        return nil
    }

    public var headers: [String: String] {
        return [
            "Content-type": "application/json",
            "X-API-Key": "6de8eb90"
        ]
    }

    public var url: URL {
        return baseURL.appendingPathComponent(Self.endpoint)
    }
}

/**
 A `Resource` is a `Service` that returns some data.

 Provide a `parse` function to convert the response `Data` into a `Payload` value. To provide automatic parsing, there is a default implementation for `parse` if `Payload` is `Decodable`.
 */
protocol Resource: Service {
    associatedtype Payload
    func parse(_ data: Data) -> Result<Payload, APIError>
}

extension Resource where Payload: Decodable {
    func parse(_ data: Data) -> Result<Payload, APIError> {
        return data.parse()
    }
}
