//
//  AppCoordinator.swift
//  MDT
//
//  Created by Maksym Kershengolts on 18.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import UIKit
import AMScrollingNavbar

enum AppState {
    case productList
    case productDetails(product: Product)
}

class AppCoordinator: CoordinatorType {
    var repositories: Repositories
    lazy var rootController: UIViewController = {
        let viewModel = ProductListViewModel(withCoordinator: self)
        let controller = ProductListViewController.instantiate(with: viewModel)
        return ScrollingNavigationController(rootViewController: controller)
    }()
    var children: [CoordinatorType] = []

    init(withRepositories repositories: Repositories) {
        self.repositories = repositories
    }

    func coordinate(inWindow window: UIWindow) {
        window.rootViewController = rootController
    }

    func navigate(to state: AppState) {
        switch state {
        case .productDetails(let product):
            let viewModel = ProductDetailsViewModel(withCoordinator: self, product: product)
            let controller = ProductDetailsViewController.instantiate(with: viewModel)
            (rootController as? UINavigationController)?.pushViewController(controller, animated: true)
        default:
            break
        }
    }
}
