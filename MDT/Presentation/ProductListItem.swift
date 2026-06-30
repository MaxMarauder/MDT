//
//  ProductListItem.swift
//  MDT — Presentation layer
//

import Foundation
import ProductKit

// MARK: - Presentation model
//
// A presentation model holds values that are already formatted and ready to
// render, so the SwiftUI view contains no business or formatting logic — it just
// binds strings to `Text`.
//
// Benefits:
//  - The View stays declarative and dumb → trivially previewable and testable.
//  - Formatting rules (currency, "by <brand>", discount visibility) live in one
//    place and can be unit-tested without spinning up SwiftUI.
//  - It decouples the View from the domain `Product`.
struct ProductListItem: Identifiable, Equatable {
    let id: String
    let name: String
    let byBrandText: String
    let priceText: String
    /// Non-nil only when discounted — the View shows it conditionally.
    let discountedPriceText: String?
    let isDiscounted: Bool
    let noteText: String
    let imageURL: URL?

    init(product: Product) {
        self.id = product.identifier
        self.name = product.name
        self.byBrandText = "by \(product.brand)"
        self.isDiscounted = product.isDiscounted
        self.priceText = Self.priceText(product.originalPrice, product.currency)
        self.discountedPriceText = product.isDiscounted
            ? Self.priceText(product.currentPrice, product.currency)
            : nil
        self.noteText = product.note ?? ""
        self.imageURL = product.image.url
    }

    private static func priceText(_ amount: Double, _ currency: String) -> String {
        String(format: "%.2f %@", amount, currency)
    }
}
