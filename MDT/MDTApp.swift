//
//  MDTApp.swift
//  MDT
//

import SwiftUI
import ProductKit

// MARK: - Composition root
//
// `MDTApp` is the one place that knows concrete types and wires the object graph
// together — the composition root. Nothing else in the app constructs a repository
// or a client; they receive abstractions (`any ProductsRepository`, `Router`) from
// here. Dependencies point inward and are assembled exactly once.
//
// The `App` value is created once and retained by SwiftUI for the process
// lifetime, so holding the graph in `let` properties is safe (no `@StateObject`
// needed at this level — those are for view-lifetime ownership).
@main
struct MDTApp: App {

    private let router: Router
    private let routeFactory: RouteFactory
    private let listViewModel: ProductListViewModel

    init() {
        // Build the data layer behind its port. `DefaultProductsRepository()`
        // assembles the async `HTTPClient` and the SwiftData `@ModelActor` store.
        let repository: any ProductsRepository
        do {
            repository = try DefaultProductsRepository()
        } catch {
            // A failed persistent store is unrecoverable at launch.
            fatalError("Failed to initialise persistence: \(error)")
        }

        let router = Router()
        self.router = router
        self.routeFactory = RouteFactory(repository: repository)
        self.listViewModel = ProductListViewModel(repository: repository, router: router)
    }

    var body: some Scene {
        WindowGroup {
            ProductListView(viewModel: listViewModel, routeFactory: routeFactory)
                // Inject the single `Router` so any screen can read it via
                // `@EnvironmentObject`. The same instance is held by the view models.
                .environmentObject(router)
        }
    }
}
