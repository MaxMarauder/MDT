//
//  MDTApp.swift
//  MDT
//
//  Created by Maksym Kershengolts on 12.10.25.
//  Copyright © 2025 Maksym Kershengolts. All rights reserved.
//

import SwiftUI

@main
struct MDTApp: App {
    let repositories: Repositories = {
        let apiClient = APIClient()
        let coreDataManager = CoreDataManager()
        let productsRepository = ProductsRepository(apiClient: apiClient, coreDataManager: coreDataManager)
        return Repositories(productsRepository: productsRepository)
    }()

    let appCoordinator: AppCoordinator
    
    init () {
        appCoordinator = AppCoordinator(withRepositories: repositories)
    }
    
    var body: some Scene {
        WindowGroup {
            let viewModel = ProductListViewModel(withCoordinator: appCoordinator)
            ProductListView(viewModel: viewModel)

//            appCoordinator.rootView
        }
    }
}
