//
//  Product.swift
//  ProductKit — Domain layer
//

import Foundation

// MARK: - Domain model
//
// `Product` is the app's domain model — the single representation that flows
// through repositories, view models, and (after mapping) into the UI.
//
// It is a value type for three reasons:
//  - **Value semantics**: copies are independent, so a `Product` can be passed
//    across threads/actors without shared-mutable-state bugs.
//  - **`Sendable`**: every stored property is `Sendable`, so the compiler can
//    prove `Product` is safe to cross an actor boundary (it leaves the SwiftData
//    `@ModelActor` and lands on the `@MainActor` view models with no data race).
//  - **Framework-free**: no persistence or UI imports (`SwiftData`, `SwiftUI`).
//    The domain doesn't know how products are fetched or stored — that lives in
//    the Data layer. This keeps the dependency arrow pointing inward.
public struct Product: Identifiable, Equatable, Hashable, Sendable {
    public let identifier: String
    public let name: String
    public let brand: String
    public let originalPrice: Double
    public let currentPrice: Double
    public let currency: String
    public let image: ProductImage
    /// Per-product user note. Sourced from persistence, not from the network DTO.
    public let note: String?

    /// `Identifiable` conformance keys SwiftUI lists/diffing off the stable
    /// backend identifier.
    public var id: String { identifier }

    public init(
        identifier: String,
        name: String,
        brand: String,
        originalPrice: Double,
        currentPrice: Double,
        currency: String,
        image: ProductImage,
        note: String?
    ) {
        self.identifier = identifier
        self.name = name
        self.brand = brand
        self.originalPrice = originalPrice
        self.currentPrice = currentPrice
        self.currency = currency
        self.image = image
        self.note = note
    }

    /// A product is discounted when its current price differs from its original.
    public var isDiscounted: Bool {
        currentPrice != originalPrice
    }
}

// MARK: - Domain value object

public struct ProductImage: Equatable, Hashable, Sendable {
    public let id: Int
    /// Parsed at the data boundary: invalid strings become `nil` here rather than
    /// forcing every view to call `URL(string:)` defensively.
    public let url: URL?

    public init(id: Int, url: URL?) {
        self.id = id
        self.url = url
    }
}
