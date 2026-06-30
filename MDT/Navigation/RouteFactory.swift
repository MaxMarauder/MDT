//
//  RouteFactory.swift
//  MDT — Navigation
//

import SwiftUI
import ProductKit

// MARK: - RouteFactory
//
// Turns a `Route` value into its concrete destination view. The responsibilities
// around navigation are split apart:
//   • the View expresses an intent (tap)            → no knowledge of destinations
//   • the view model decides to navigate            → `router.push(route)`
//   • the `Router` holds the navigation state       → `NavigationPath`
//   • the `RouteFactory` builds the destination     → here, in one place
//   • `NavigationStack` renders it via `.navigationDestination`
//
// The factory is also the single place that injects dependencies (the repository)
// into a screen's view model, keeping construction out of the views.
@MainActor
final class RouteFactory {
    private let repository: any ProductsRepository

    init(repository: any ProductsRepository) {
        self.repository = repository
    }

    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
        case .productDetails(let product):
            ProductDetailsView(
                viewModel: ProductDetailsViewModel(product: product, repository: repository)
            )
        }
    }
}
