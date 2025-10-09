//
//  SceneDelegate.swift
//  MDT
//
//  Created by Maksym Kershengolts on 09.10.25.
//  Copyright © 2025 Maksym Kershengolts. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    lazy var repositories: Repositories = {
        let apiClient = APIClient()
        let coreDataManager = CoreDataManager()
        let productsRepository = ProductsRepository(apiClient: apiClient, coreDataManager: coreDataManager)
        return Repositories(productsRepository: productsRepository)
    }()

    lazy var appCoordinator: AppCoordinator = {
        return AppCoordinator(withRepositories: repositories)
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        guard let window = window else { return }
        appCoordinator.coordinate(inWindow: window)
        window.makeKeyAndVisible()
    }
}
