//
//  ProductsRepository.swift
//  ProductKit — Domain layer (port)
//

import Foundation
import Combine

// MARK: - Repository port
//
// This protocol is the boundary between layers: it lives in the Domain layer and
// is the only thing the presentation layer knows about the data world. The Data
// layer provides the implementation, so either side can change independently and
// tests can substitute a mock.
//
// It is `@MainActor` because the repository owns a Combine subject that drives
// SwiftUI, so its observable state and publish points live on the main actor. The
// expensive work (network, disk) is delegated to off-main actors it awaits — the
// repository is a thin main-actor orchestrator, not a worker.
@MainActor
public protocol ProductsRepository: AnyObject {

    /// Reactive source of truth for the product list. Exposing data as a publisher
    /// lets the list view model react to any change — initial load, refresh, a note
    /// edit — through one declarative Combine pipeline.
    var productsPublisher: AnyPublisher<[Product], Never> { get }

    /// Loads persisted products and publishes them (offline-first first paint).
    /// Returns the loaded snapshot so the caller can decide whether an initial
    /// network fetch is needed (e.g. nothing persisted yet on a first launch).
    @discardableResult
    func load() async -> [Product]

    /// Fetches from the network, persists (upsert + prune), then republishes.
    func refresh() async throws

    /// Persists an edited note for one product, then republishes.
    func updateNote(_ note: String?, productID: String) async throws
}
