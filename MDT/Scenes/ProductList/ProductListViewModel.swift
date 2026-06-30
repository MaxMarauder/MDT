//
//  ProductListViewModel.swift
//  MDT — Presentation / ProductList
//

import Foundation
import Combine
import ProductKit

// MARK: - ProductListViewModel
//
// The list screen's view model, in the ObservableObject + Combine style (the
// detail screen's view model uses the `@Observable` macro instead).
//
// `@MainActor` guarantees every property mutation and publish happens on the main
// thread, so the UI never reads half-updated state. Heavy work is awaited on the
// repository's background actors.
@MainActor
final class ProductListViewModel: ObservableObject {

    // `@Published` bridges Combine and SwiftUI: each property synthesises a
    // publisher and triggers `objectWillChange`, so views holding this object via
    // `@StateObject` re-render automatically.
    @Published var searchText: String = ""
    @Published private(set) var items: [ProductListItem] = []

    private let repository: any ProductsRepository
    private let router: Router

    /// Domain products matching the current filter, kept so a tapped row can be
    /// resolved back to its domain `Product` for navigation.
    private var filteredProducts: [Product] = []

    /// Combine subscriptions are owned here; when the view model deallocates, the
    /// pipeline is torn down automatically.
    private var cancellables = Set<AnyCancellable>()

    /// Whether the initial load for this app session has already run, so returning
    /// to the list (e.g. from product details) doesn't trigger it again.
    private var hasLoaded = false

    init(repository: any ProductsRepository, router: Router) {
        self.repository = repository
        self.router = router
        bind()
    }

    // MARK: Combine pipeline
    //
    // Declaratively wires "products" and "what the user typed" into "the filtered
    // list to display":
    //
    //   searchText ──debounce──removeDuplicates──┐
    //                                            ├─combineLatest──map(filter)──▶ items
    //   repository.productsPublisher ────────────┘
    //
    // Why each operator:
    //  - `debounce`: wait 250ms after typing stops, so we don't refilter on every
    //    keystroke.
    //  - `removeDuplicates`: ignore no-op changes (e.g. autocorrect re-emitting).
    //  - `combineLatest`: re-run whenever either the data or the query changes, so a
    //    refresh and a keystroke both update the list through one path.
    //  - `map`: pure transform from domain → presentation models.
    private func bind() {
        let query = $searchText
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .removeDuplicates()

        repository.productsPublisher
            .combineLatest(query)
            .map { products, query -> [Product] in
                Self.filtered(products, query: query)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] products in
                self?.filteredProducts = products
                self?.items = products.map(ProductListItem.init)
            }
            .store(in: &cancellables)
    }

    private static func filtered(_ products: [Product], query: String) -> [Product] {
        guard !query.isEmpty else { return products }
        return products.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    // MARK: Lifecycle / actions

    /// Called from the view's `.task`. Runs once per app session: it shows the
    /// persisted products, and only fetches from the network when nothing is
    /// persisted yet (the first-ever launch). On later launches the stored list is
    /// shown as-is and stays put until the user pulls to refresh — so returning
    /// from product details never silently reloads the list.
    func onAppear() async {
        guard !hasLoaded else { return }
        hasLoaded = true

        let persisted = await repository.load()
        if persisted.isEmpty {
            await refresh()
        }
    }

    /// Drives `.refreshable` (pull-to-refresh). Logs and swallows errors — a
    /// production app would surface them.
    func refresh() async {
        do {
            try await repository.refresh()
        } catch {
            #if DEBUG
            print("⛔️ Refresh failed: \(error)")
            #endif
        }
    }

    /// The view hands back the tapped item; the view model decides to navigate and
    /// delegates the mechanics to the `Router`.
    func didSelect(_ item: ProductListItem) {
        guard let product = filteredProducts.first(where: { $0.id == item.id }) else { return }
        router.push(.productDetails(product))
    }
}
