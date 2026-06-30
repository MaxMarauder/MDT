//
//  ProductsEndpoint.swift
//  ProductKit — Data layer / Network
//

import Foundation

// MARK: - Products endpoint
//
// The entire definition of "fetch the product list" — a declarative `Resource`.
// `Payload = [ProductDTO]` is `Decodable`, so parsing is inherited and there is no
// imperative networking here at all. `internal` because only the repository (also
// in this package) issues it; the app never sees endpoints or DTOs.
struct ProductsEndpoint: Resource {
    typealias Payload = [ProductDTO]

    // Mockaroo's mock products live behind the `cars` mock.
    static var endpoint: String { "cars" }
}
