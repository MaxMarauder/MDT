//
//  ProductDTO.swift
//  ProductKit — Data layer / DTO
//

import Foundation

// MARK: - Data Transfer Objects
//
// A DTO mirrors the wire format exactly — the shape and naming the backend sends.
// Keeping it separate from the domain `Product` buys us:
//  - A decoding boundary: snake_case JSON keys (`original_price`) are mapped here
//    via `CodingKeys`, so that naming never reaches the domain or UI.
//  - Decoupling: if the backend renames or restructures a field, only this file
//    and the mapper change — the domain model and views stay untouched.
//
// These types are `internal` on purpose: a DTO must never escape the package; the
// app only ever receives domain `Product` values.
struct ProductDTO: Decodable, Equatable, Sendable {
    let identifier: String
    let name: String
    let brand: String
    let originalPrice: Double
    let currentPrice: Double
    let currency: String
    let image: ProductImageDTO

    // Maps the backend's snake_case onto Swift's camelCase — allocation-free and
    // self-documenting compared with a decoder-wide key strategy.
    enum CodingKeys: String, CodingKey {
        case identifier
        case name
        case brand
        case currency
        case image
        case originalPrice = "original_price"
        case currentPrice = "current_price"
    }
}

struct ProductImageDTO: Decodable, Equatable, Sendable {
    let id: Int
    let url: String
}
