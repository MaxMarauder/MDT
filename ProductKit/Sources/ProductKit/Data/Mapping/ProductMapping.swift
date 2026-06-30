//
//  ProductMapping.swift
//  ProductKit — Data layer / Mapping
//

import Foundation

// MARK: - DTO → Domain mapping
//
// Mapping is the explicit translation step between layers. It lives in the Data
// layer (it must know about the internal `ProductDTO`) and produces a public
// domain `Product`. Centralising it here means there is exactly one place where
// wire concerns turn into domain concerns — including parsing the image URL string
// into a `URL?` so the rest of the app never deals with raw strings.
extension Product {
    /// Builds a domain `Product` from a freshly decoded network DTO.
    ///
    /// - Parameter note: the DTO has no `note` field (it's user-local state, not
    ///   server data), so the caller supplies any existing persisted note. New
    ///   products default to `nil`.
    init(dto: ProductDTO, note: String? = nil) {
        self.init(
            identifier: dto.identifier,
            name: dto.name,
            brand: dto.brand,
            originalPrice: dto.originalPrice,
            currentPrice: dto.currentPrice,
            currency: dto.currency,
            image: ProductImage(id: dto.image.id, url: URL(string: dto.image.url)),
            note: note
        )
    }
}
