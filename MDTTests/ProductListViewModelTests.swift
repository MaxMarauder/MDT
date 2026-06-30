//
//  ProductListViewModelTests.swift
//  MDTTests
//
//  Exercises the ObservableObject + Combine list view model against a mock
//  repository. The pipeline is debounced, so the async tests wait past the
//  250ms window before asserting.
//

import Testing
import Foundation
@testable import MDT
import ProductKit

@MainActor
struct ProductListViewModelTests {

    /// Slightly longer than the view model's 250ms debounce.
    private static let debounceWait: Duration = .milliseconds(400)

    @Test("published products become presentation items")
    func publishesItems() async throws {
        let repo = MockProductsRepository()
        let viewModel = ProductListViewModel(repository: repo, router: Router())

        repo.emit([.fixture(id: "1", name: "Alpha"), .fixture(id: "2", name: "Beta")])
        try await Task.sleep(for: Self.debounceWait)

        #expect(viewModel.items.count == 2)
    }

    @Test("searchText filters the list (case-insensitive)")
    func filtersBySearchText() async throws {
        let repo = MockProductsRepository()
        let viewModel = ProductListViewModel(repository: repo, router: Router())

        repo.emit([.fixture(id: "1", name: "Alpha"), .fixture(id: "2", name: "Beta")])
        viewModel.searchText = "alp"
        try await Task.sleep(for: Self.debounceWait)

        #expect(viewModel.items.count == 1)
        #expect(viewModel.items.first?.name == "Alpha")
    }

    @Test("selecting an item pushes a route onto the router")
    func didSelectPushesRoute() async throws {
        let repo = MockProductsRepository()
        let router = Router()
        let viewModel = ProductListViewModel(repository: repo, router: router)

        repo.emit([.fixture(id: "1", name: "Alpha")])
        try await Task.sleep(for: Self.debounceWait)

        let item = try #require(viewModel.items.first)
        viewModel.didSelect(item)

        #expect(router.path.count == 1)
    }

    @Test("refresh delegates to the repository")
    func refreshDelegates() async {
        let repo = MockProductsRepository()
        let viewModel = ProductListViewModel(repository: repo, router: Router())

        await viewModel.refresh()

        #expect(repo.refreshCallCount == 1)
    }

    @Test("first launch with an empty store fetches from the network")
    func onAppearFetchesWhenStoreEmpty() async {
        let repo = MockProductsRepository() // publisher starts empty
        let viewModel = ProductListViewModel(repository: repo, router: Router())

        await viewModel.onAppear()

        #expect(repo.loadCallCount == 1)
        #expect(repo.refreshCallCount == 1)
    }

    @Test("later launch with persisted data does not auto-fetch")
    func onAppearSkipsFetchWhenStoreHasData() async {
        let repo = MockProductsRepository()
        repo.emit([.fixture(id: "1", name: "Alpha")]) // store already has products
        let viewModel = ProductListViewModel(repository: repo, router: Router())

        await viewModel.onAppear()

        #expect(repo.loadCallCount == 1)
        #expect(repo.refreshCallCount == 0)
    }

    @Test("returning to the list does not load again")
    func onAppearRunsOncePerSession() async {
        let repo = MockProductsRepository()
        repo.emit([.fixture(id: "1", name: "Alpha")])
        let viewModel = ProductListViewModel(repository: repo, router: Router())

        await viewModel.onAppear()
        await viewModel.onAppear()

        #expect(repo.loadCallCount == 1)
    }
}
