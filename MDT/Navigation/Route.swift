//
//  Route.swift
//  MDT — Navigation
//

import Foundation
import ProductKit

// MARK: - Route
//
// A `Route` is a typed, value-based description of a destination. It is the
// vocabulary of the app's navigation: every screen you can navigate *to* is a case.
// A View expresses an intent and a `Route` value flows through `NavigationStack`'s
// path; the View itself never constructs a destination.
//
// `Hashable` is required by SwiftUI's `navigationDestination(for:)` /
// `NavigationPath`, which key destinations off the pushed value.
enum Route: Hashable {
    case productDetails(Product)
}
