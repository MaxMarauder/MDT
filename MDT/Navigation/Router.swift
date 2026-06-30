//
//  Router.swift
//  MDT — Navigation
//

import SwiftUI

// MARK: - Router
//
// The Router owns the navigation state — a single `NavigationPath` that backs the
// root `NavigationStack(path:)`. Pushing/popping is just mutating this value, so
// navigation is data-driven.
//
// SwiftUI state wrappers involved:
//  - `ObservableObject` + `@Published`: when `path` changes, SwiftUI re-renders the
//    `NavigationStack` bound to it.
//  - In views, this object is held with `@StateObject` (the owner) and read by
//    children via `@EnvironmentObject`.
//
// A View sends an intent to its view model, the view model calls `router.push(...)`,
// and the path drives the stack — each layer with one responsibility.
@MainActor
final class Router: ObservableObject {

    @Published var path = NavigationPath()

    /// Navigate forward to a destination described by a `Route` value.
    func push(_ route: Route) {
        path.append(route)
    }

    /// Pop the top screen.
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Pop back to the root screen.
    func popToRoot() {
        path = NavigationPath()
    }
}
