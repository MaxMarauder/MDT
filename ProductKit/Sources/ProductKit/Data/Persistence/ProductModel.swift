//
//  ProductModel.swift
//  ProductKit — Data layer / Persistence
//

import Foundation
import SwiftData

// MARK: - SwiftData persistence model
//
// `@Model` turns a plain class into a persistent entity: the schema is the Swift
// type itself (compile-checked and refactor-safe), with no separate model-editor
// file to keep in sync.
//
// This is the persistence representation of a product. It's deliberately
// `internal`: a `@Model` is bound to a `ModelContext` and is not `Sendable`, so it
// must never escape the package. Callers always receive the value-type domain
// `Product` via `toDomain()`.
@Model
final class ProductModel {
    // `.unique` is SwiftData's upsert primitive: inserting a model whose
    // `identifier` already exists updates the existing row instead of duplicating.
    @Attribute(.unique) var identifier: String
    var name: String
    var brand: String
    var originalPrice: Double
    var currentPrice: Double
    var currency: String
    var imageID: Int
    var imageURLString: String
    /// User-local note — survives network refreshes (never overwritten by a DTO).
    var note: String?

    init(
        identifier: String,
        name: String,
        brand: String,
        originalPrice: Double,
        currentPrice: Double,
        currency: String,
        imageID: Int,
        imageURLString: String,
        note: String?
    ) {
        self.identifier = identifier
        self.name = name
        self.brand = brand
        self.originalPrice = originalPrice
        self.currentPrice = currentPrice
        self.currency = currency
        self.imageID = imageID
        self.imageURLString = imageURLString
        self.note = note
    }
}

// MARK: - Mapping (DTO → Model, Model → Domain)

extension ProductModel {
    /// Creates a fresh persistence model from a network DTO. New products have no
    /// note yet, so it defaults to `nil`.
    convenience init(dto: ProductDTO) {
        self.init(
            identifier: dto.identifier,
            name: dto.name,
            brand: dto.brand,
            originalPrice: dto.originalPrice,
            currentPrice: dto.currentPrice,
            currency: dto.currency,
            imageID: dto.image.id,
            imageURLString: dto.image.url,
            note: nil
        )
    }

    /// Updates server-owned fields from a DTO while preserving the user's note.
    func update(from dto: ProductDTO) {
        name = dto.name
        brand = dto.brand
        originalPrice = dto.originalPrice
        currentPrice = dto.currentPrice
        currency = dto.currency
        imageID = dto.image.id
        imageURLString = dto.image.url
        // `note` intentionally left untouched.
    }

    /// Converts the persistence model into the framework-free domain value type
    /// that crosses the actor boundary out to the view models.
    func toDomain() -> Product {
        Product(
            identifier: identifier,
            name: name,
            brand: brand,
            originalPrice: originalPrice,
            currentPrice: currentPrice,
            currency: currency,
            image: ProductImage(id: imageID, url: URL(string: imageURLString)),
            note: note
        )
    }
}
