//
//  AppDelegate.swift
//  MDT
//
//  Created by Maksym Kershengolts on 18.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let window = window else {
            return false
        }

        appCoordinator.coordinate(inWindow: window)

        return true
    }
}

