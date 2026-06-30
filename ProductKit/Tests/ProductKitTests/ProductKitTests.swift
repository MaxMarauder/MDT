//
//  ProductKitTests.swift
//  ProductKit
//
//  Swift Testing (`import Testing`, `@Test`, `#expect`/`#require`). These exercise
//  the *real* data layer — async networking (mocked transport), SwiftData
//  persistence (in-memory), and their composition in the repository — with full
//  dependency injection via the internal designated initialiser (`@testable`).
//

import Testing
import Foundation
import Combine
import SwiftData
@testable import ProductKit

// MARK: - Fixtures

private let sampleJSON = """
[
  {"identifier":"1","name":"QWERTY","brand":"Brand 1","original_price":99.95,"current_price":59.95,"currency":"EUR","image":{"id":101,"url":"https://qwerty/101.jpg"}},
  {"identifier":"2","name":"ASDFGH","brand":"Brand 2","original_price":199.95,"current_price":199.95,"currency":"USD","image":{"id":201,"url":"https://asdfgh/201.jpg"}}
]
"""

private func sampleDTOs() throws -> [ProductDTO] {
    try JSONDecoder().decode([ProductDTO].self, from: Data(sampleJSON.utf8))
}

/// Test double for the networking seam. The single endpoint's `Payload` is
/// `[ProductDTO]`, so the force-cast is safe in tests.
private struct MockHTTPClient: HTTPClient {
    var result: Result<[ProductDTO], APIError>

    func request<R: Resource>(_ resource: R) async throws -> R.Payload {
        switch result {
        case .success(let dtos): return dtos as! R.Payload
        case .failure(let error): throw error
        }
    }
}

@MainActor
private func makeInMemoryStore() throws -> SwiftDataProductsStore {
    let container = try ModelContainer(
        for: ProductModel.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return SwiftDataProductsStore(modelContainer: container)
}

// MARK: - DTO decoding

@Test("DTO maps snake_case JSON onto camelCase Swift properties")
func dtoDecoding() throws {
    let dtos = try sampleDTOs()
    #expect(dtos.count == 2)
    #expect(dtos[0].originalPrice == 99.95)
    #expect(dtos[0].currentPrice == 59.95)
    #expect(dtos[0].image.url == "https://qwerty/101.jpg")
}

// MARK: - Repository

@Test("refresh() fetches, persists, and publishes mapped domain products")
@MainActor
func refreshPublishesProducts() async throws {
    let store = try makeInMemoryStore()
    let repo = DefaultProductsRepository(
        client: MockHTTPClient(result: .success(try sampleDTOs())),
        store: store
    )

    try await repo.refresh()

    // CurrentValueSubject replays its latest value synchronously on subscription.
    var received: [Product] = []
    let cancellable = repo.productsPublisher.sink { received = $0 }
    defer { cancellable.cancel() }

    #expect(received.count == 2)
    #expect(received.contains { $0.identifier == "1" && $0.isDiscounted })
    #expect(received.contains { $0.identifier == "2" && !$0.isDiscounted })
}

@Test("a user note survives a network refresh of the same product")
@MainActor
func notePreservedAcrossRefresh() async throws {
    let store = try makeInMemoryStore()
    let repo = DefaultProductsRepository(
        client: MockHTTPClient(result: .success(try sampleDTOs())),
        store: store
    )

    try await repo.refresh()
    try await repo.updateNote("remember me", productID: "1")
    try await repo.refresh() // same DTOs again — must not clobber the note

    let products = await store.fetchAll()
    #expect(products.first { $0.identifier == "1" }?.note == "remember me")
}

@Test("refresh() rethrows networking errors")
@MainActor
func refreshPropagatesError() async throws {
    let store = try makeInMemoryStore()
    let repo = DefaultProductsRepository(
        client: MockHTTPClient(result: .failure(.invalidResponse(statusCode: 500))),
        store: store
    )

    await #expect(throws: APIError.self) {
        try await repo.refresh()
    }
}

// MARK: - Store (upsert + prune)

@Test("upsert prunes products no longer returned by the backend")
@MainActor
func upsertPrunesStaleProducts() async throws {
    let store = try makeInMemoryStore()

    try await store.upsert(try sampleDTOs())          // 2 products
    #expect(await store.fetchAll().count == 2)

    let firstOnly = Array(try sampleDTOs().prefix(1))
    try await store.upsert(firstOnly)                 // id "2" should be pruned

    let remaining = await store.fetchAll()
    #expect(remaining.count == 1)
    #expect(remaining.first?.identifier == "1")
}
