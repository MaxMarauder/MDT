//
//  ProductDetailViewState.swift
//  MDT — Presentation layer
//

import Foundation
import ProductKit

// MARK: - Presentation model (detail screen)
//
// Display-ready data for the details screen. The editable note is deliberately not
// here: this struct is immutable, derived-once view data, whereas the note is
// mutable user input that the view model owns and writes back through the
// repository.
struct ProductDetailViewState: Equatable {
    let name: String
    let byBrandText: String
    let priceText: String
    let discountedPriceText: String?
    let isDiscounted: Bool
    let imageURL: URL?

    init(product: Product) {
        self.name = product.name
        self.byBrandText = "by \(product.brand)"
        self.isDiscounted = product.isDiscounted
        self.priceText = String(format: "%.2f %@", product.originalPrice, product.currency)
        self.discountedPriceText = product.isDiscounted
            ? String(format: "%.2f %@", product.currentPrice, product.currency)
            : nil
        self.imageURL = product.image.url
    }
}
