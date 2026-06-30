//
//  ProductsLocalStore.swift
//  ProductKit — Data layer / Persistence
//

import Foundation
import SwiftData

// MARK: - Persistence port
//
// The repository depends on this abstraction, not on SwiftData directly — so the
// store can be swapped for an in-memory mock in tests, and the persistence
// technology stays an implementation detail. `Sendable` because the conforming
// type is an actor shared across the app.
//
// Methods are declared `async` because the only implementation is an actor: from
// the caller's side, reaching actor-isolated state is always asynchronous.
protocol ProductsLocalStore: Sendable {
    func fetchAll() async -> [Product]
    func upsert(_ dtos: [ProductDTO]) async throws
    func setNote(_ note: String?, productID: String) async throws
}

// MARK: - SwiftData implementation
//
// `@ModelActor` synthesises an actor that owns its own private `ModelContext`
// (plus an `init(modelContainer:)`). Everything it does is serialized on the
// actor's executor, giving race-free SwiftData access.
//
// Notes:
//  - `ModelContext` is not `Sendable`; `@ModelActor` confines it to the actor so
//    it can never be touched from two tasks at once — no data races by design.
//  - The methods below are written synchronously; actor isolation makes them
//    `async` to outside callers, which is exactly what the port requires (a sync
//    actor method legally satisfies an `async` protocol requirement).
//  - Only value-type domain `Product`s leave the actor (see `fetchAll`), so the
//    non-Sendable `ProductModel` never escapes.
@ModelActor
actor SwiftDataProductsStore: ProductsLocalStore {

    /// Reads every product, sorted by name, mapped to domain values.
    func fetchAll() -> [Product] {
        let descriptor = FetchDescriptor<ProductModel>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        let models = (try? modelContext.fetch(descriptor)) ?? []
        return models.map { $0.toDomain() }
    }

    /// Upsert + prune: update matches, insert new ones, delete the products the
    /// backend no longer returns — all while preserving user notes.
    func upsert(_ dtos: [ProductDTO]) throws {
        var existing = try modelContext.fetch(FetchDescriptor<ProductModel>())

        for dto in dtos {
            if let index = existing.firstIndex(where: { $0.identifier == dto.identifier }) {
                existing[index].update(from: dto)   // keeps the note
                existing.remove(at: index)          // mark as "still present"
            } else {
                modelContext.insert(ProductModel(dto: dto))
            }
        }

        // Whatever remains wasn't in the latest response → prune it.
        for stale in existing {
            modelContext.delete(stale)
        }

        try modelContext.save()
    }

    /// Persists an edited note for a single product.
    func setNote(_ note: String?, productID: String) throws {
        var descriptor = FetchDescriptor<ProductModel>(
            predicate: #Predicate { $0.identifier == productID }
        )
        descriptor.fetchLimit = 1
        guard let model = try modelContext.fetch(descriptor).first else { return }
        model.note = note
        try modelContext.save()
    }
}
