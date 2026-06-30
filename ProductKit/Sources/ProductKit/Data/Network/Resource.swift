//
//  Resource.swift
//  ProductKit — Data layer / Network
//

import Foundation

// MARK: - Resource
//
// A `Resource` is a `Service` that yields a typed `Payload`. Conformers provide a
// `parse`, but when `Payload: Decodable` they get it for free from the extension
// below — so a JSON endpoint is just a tiny type declaration.
//
// `parse` throws, which composes with the client's own `throws` so a single
// `do/catch` at the call site handles every failure mode.
public protocol Resource: Service {
    associatedtype Payload
    func parse(_ data: Data) throws -> Payload
}

public extension Resource where Payload: Decodable {
    func parse(_ data: Data) throws -> Payload {
        do {
            return try JSONDecoder().decode(Payload.self, from: data)
        } catch {
            #if DEBUG
            print("⛔️ JSON parsing error: \(error)")
            #endif
            throw APIError.parsing(error)
        }
    }
}
