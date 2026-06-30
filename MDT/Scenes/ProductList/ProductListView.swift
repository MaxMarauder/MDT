//
//  ProductListView.swift
//  MDT — Presentation / ProductList
//

import SwiftUI

// MARK: - ProductListView
//
// Root screen. Shows several SwiftUI state wrappers and lifecycle modifiers (each
// annotated below), and contains the `NavigationStack` that the `Router` drives.
struct ProductListView: View {

    // `@StateObject`: this view owns the view model for its lifetime. SwiftUI
    // creates it once and keeps the same instance across re-renders.
    @StateObject private var viewModel: ProductListViewModel

    // `@EnvironmentObject`: the shared `Router`, injected once at the app root and
    // read here without being passed through every initialiser.
    @EnvironmentObject private var router: Router

    // A plain dependency (no view state), so just a `let`.
    private let routeFactory: RouteFactory

    init(viewModel: ProductListViewModel, routeFactory: RouteFactory) {
        // `StateObject(wrappedValue:)` lets the composition root build the view
        // model while the view still owns its lifetime.
        _viewModel = StateObject(wrappedValue: viewModel)
        self.routeFactory = routeFactory
    }

    var body: some View {
        // `NavigationStack(path:)` is bound to the Router's `NavigationPath`, so
        // navigation is pure state: appending a `Route` pushes; removing pops.
        NavigationStack(path: $router.path) {
            List(viewModel.items) { item in
                // The row is a button that only emits an intent; it does not know
                // what screen comes next.
                Button {
                    viewModel.didSelect(item)
                } label: {
                    ProductRow(item: item)
                }
                .buttonStyle(.plain)
            }
            .listStyle(.plain)
            .animation(.default, value: viewModel.items)
            .navigationTitle("MDT")
            .navigationBarTitleDisplayMode(.inline)
            // Maps a pushed `Route` value to its destination view via the factory.
            .navigationDestination(for: Route.self) { route in
                routeFactory.destination(for: route)
            }
            // `.searchable` two-way binds to the view model's `@Published` text,
            // which feeds the Combine debounce pipeline.
            .searchable(text: $viewModel.searchText)
            // `.refreshable` is async-native: pull-to-refresh awaits this directly.
            .refreshable {
                await viewModel.refresh()
            }
            // `.task` runs when the view appears and is auto-cancelled when it
            // disappears.
            .task {
                await viewModel.onAppear()
            }
        }
    }
}
