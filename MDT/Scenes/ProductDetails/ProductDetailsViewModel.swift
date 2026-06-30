//
//  ProductDetailsViewModel.swift
//  MDT — Presentation / ProductDetails
//

import Foundation
import Observation
import ProductKit

// MARK: - ProductDetailsViewModel
//
// The detail screen's view model, deliberately written with the **`@Observable`
// macro** (Observation framework, iOS 17) to contrast with the list's
// `ObservableObject` + Combine approach.
//
// `@Observable` vs `ObservableObject` (a favourite interview question):
//  - No `@Published`: every stored `var` is tracked automatically.
//  - **Per-property** change tracking — a view that reads only `noteText` is *not*
//    invalidated when an unrelated property changes (finer-grained than
//    `objectWillChange`, which fires for any change).
//  - Views own it with `@State` (not `@StateObject`) and bind with `@Bindable`.
//  - It does not use Combine at all; it's built on the Observation runtime.
@MainActor
@Observable
final class ProductDetailsViewModel {

    // The immutable, display-ready data for the screen.
    let viewState: ProductDetailViewState

    // Editable note. A plain `var` — `@Observable` makes it observable, so the
    // bound `TextField` updates it and the view re-renders with no extra ceremony.
    var noteText: String

    // `@ObservationIgnored` keeps these out of change tracking — they're collaborators,
    // not view state, so mutating/reading them should never invalidate a view.
    @ObservationIgnored private let product: Product
    @ObservationIgnored private let repository: any ProductsRepository

    init(product: Product, repository: any ProductsRepository) {
        self.product = product
        self.repository = repository
        self.viewState = ProductDetailViewState(product: product)
        self.noteText = product.note ?? ""
    }

    /// Persists the current note. Called from the view's `.onChange(of:)`. Fires a
    /// detached unit of work with `Task` — the UI stays responsive while the write
    /// happens on the repository's persistence actor. An empty string clears the note.
    func commitNote() {
        let note = noteText.isEmpty ? nil : noteText
        let id = product.id
        Task { [repository] in
            try? await repository.updateNote(note, productID: id)
        }
    }
}
