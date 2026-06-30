//
//  DefaultProductsRepository.swift
//  ProductKit — Data layer
//

import Foundation
import Combine
import SwiftData

// MARK: - Repository implementation
//
// Composes the two data sources — the async `HTTPClient` (network) and the
// `@ModelActor` `ProductsLocalStore` (SwiftData) — behind the domain
// `ProductsRepository` port. This is where the layers meet: network DTOs come in,
// are persisted, and only value-type domain `Product`s go out via Combine.
@MainActor
public final class DefaultProductsRepository: ProductsRepository {

    private let client: HTTPClient
    private let store: ProductsLocalStore

    // `CurrentValueSubject` is a Combine publisher that also remembers its latest
    // value: new subscribers immediately receive the current product list, and
    // every `send` pushes updates to the UI.
    private let subject = CurrentValueSubject<[Product], Never>([])

    public var productsPublisher: AnyPublisher<[Product], Never> {
        // Erase to a read-only publisher so callers can subscribe but never `send`.
        subject.eraseToAnyPublisher()
    }

    // MARK: Initialisers

    /// Designated initialiser — full dependency injection. `internal` so package
    /// tests (`@testable import ProductKit`) can inject a mock client and an
    /// in-memory store, while the app uses the public convenience init below.
    init(client: HTTPClient, store: ProductsLocalStore) {
        self.client = client
        self.store = store
    }

    /// Production initialiser used by the app's composition root. Builds the
    /// SwiftData stack and wires the real network client. `inMemory` powers tests
    /// and previews with an ephemeral store.
    public convenience init(inMemory: Bool = false) throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        let container = try ModelContainer(for: ProductModel.self, configurations: configuration)
        let store = SwiftDataProductsStore(modelContainer: container)
        self.init(client: APIClient(), store: store)
    }

    // MARK: ProductsRepository

    @discardableResult
    public func load() async -> [Product] {
        // `await` hops to the store actor, runs the fetch there, and resumes back
        // on the main actor with a `Sendable` `[Product]` — no locks, no races.
        let products = await store.fetchAll()
        subject.send(products)
        return products
    }

    public func refresh() async throws {
        // Straight-line async: fetch → persist → reload → publish. Each `try await`
        // either yields a value or throws up to the caller (the view model).
        let dtos = try await client.request(ProductsEndpoint())
        try await store.upsert(dtos)
        let products = await store.fetchAll()
        subject.send(products)
    }

    public func updateNote(_ note: String?, productID: String) async throws {
        try await store.setNote(note, productID: productID)
        let products = await store.fetchAll()
        subject.send(products)
    }
}
