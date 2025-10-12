//
//  AppCoordinator.swift
//  MDT
//
//  Created by Maksym Kershengolts on 18.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import UIKit
import SwiftUI

enum AppState {
    case productList
    case productDetails(product: Product)
}

final class AppCoordinator: CoordinatorType {
    var repositories: Repositories
    lazy var rootView: AnyView = {
        let viewModel = ProductListViewModel(withCoordinator: self)
        return AnyView(ProductListView(viewModel: viewModel))
    }()
    var children: [CoordinatorType] = []

    init(withRepositories repositories: Repositories) {
        self.repositories = repositories
    }

    func view(for state: AppState) -> AnyView {
        switch state {
        case .productDetails(let product):
            let viewModel = ProductDetailsViewModel(withCoordinator: self, product: product)
            return AnyView(ProductDetailsView(viewModel: viewModel))
        default:
            return AnyView(EmptyView())
        }
    }
}
