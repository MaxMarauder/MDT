//
//  MockProductsRepository.swift
//  MDTTests
//
//  Test double for the domain `ProductsRepository` port. The view-model tests
//  depend only on this protocol, so they never touch networking or SwiftData —
//  the payoff of putting every layer behind an abstraction.
//

import Foundation
import Combine
@testable import MDT
import ProductKit

@MainActor
final class MockProductsRepository: ProductsRepository {

    private let subject = CurrentValueSubject<[Product], Never>([])
    var productsPublisher: AnyPublisher<[Product], Never> { subject.eraseToAnyPublisher() }

    private(set) var loadCallCount = 0
    private(set) var refreshCallCount = 0
    private(set) var lastNote: String?
    private(set) var lastNoteProductID: String?

    @discardableResult
    func load() async -> [Product] {
        loadCallCount += 1
        return subject.value
    }

    func refresh() async throws { refreshCallCount += 1 }

    func updateNote(_ note: String?, productID: String) async throws {
        lastNote = note
        lastNoteProductID = productID
    }

    /// Test helper: push a new product list through the publisher.
    func emit(_ products: [Product]) {
        subject.send(products)
    }
}

// Convenience domain fixtures for the presentation-layer tests.
extension Product {
    static func fixture(
        id: String,
        name: String,
        originalPrice: Double = 10,
        currentPrice: Double = 10,
        note: String? = nil
    ) -> Product {
        Product(
            identifier: id,
            name: name,
            brand: "Brand",
            originalPrice: originalPrice,
            currentPrice: currentPrice,
            currency: "EUR",
            image: ProductImage(id: 1, url: nil),
            note: note
        )
    }
}
