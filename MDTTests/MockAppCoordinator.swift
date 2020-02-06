//
//  MockAppCoordinator.swift
//  MDTTests
//
//  Created by Maksym Kershengolts on 13.08.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import UIKit
@testable import MDT

class MockAppCoordinator: CoordinatorType {
    var children: [CoordinatorType] = []
    let repositories = Repositories(productsRepository: MockProductsRepository(coreDataManager: CoreDataManager()))
    let rootController = UIViewController()
    
    var navigateCount: Int = 0
    
    func navigate(to state: AppState) {
        navigateCount += 1
    }
    
    
}
