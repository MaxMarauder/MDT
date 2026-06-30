//
//  ProductDetailsViewModelTests.swift
//  MDTTests
//
//  Exercises the @Observable detail view model.
//

import Testing
import Foundation
@testable import MDT
import ProductKit

@MainActor
struct ProductDetailsViewModelTests {

    @Test("initialises note and view state from the product")
    func initialisesFromProduct() {
        let product = Product.fixture(id: "1", name: "Alpha", note: "existing")
        let viewModel = ProductDetailsViewModel(product: product, repository: MockProductsRepository())

        #expect(viewModel.noteText == "existing")
        #expect(viewModel.viewState.name == "Alpha")
    }

    @Test("committing a note persists it via the repository")
    func commitNotePersists() async throws {
        let repo = MockProductsRepository()
        let product = Product.fixture(id: "42", name: "Alpha")
        let viewModel = ProductDetailsViewModel(product: product, repository: repo)

        viewModel.noteText = "hello"
        viewModel.commitNote()

        // commitNote() fires a detached Task; give it a beat to complete.
        try await Task.sleep(for: .milliseconds(100))

        #expect(repo.lastNote == "hello")
        #expect(repo.lastNoteProductID == "42")
    }

    @Test("clearing the note persists nil")
    func commitEmptyNotePersistsNil() async throws {
        let repo = MockProductsRepository()
        let product = Product.fixture(id: "42", name: "Alpha", note: "old")
        let viewModel = ProductDetailsViewModel(product: product, repository: repo)

        viewModel.noteText = ""
        viewModel.commitNote()
        try await Task.sleep(for: .milliseconds(100))

        #expect(repo.lastNote == nil)
        #expect(repo.lastNoteProductID == "42")
    }
}
