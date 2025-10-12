//
//  MockAppCoordinator.swift
//  MDTTests
//
//  Created by Maksym Kershengolts on 13.08.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import UIKit
import SwiftUI
@testable import MDT

class MockAppCoordinator: CoordinatorType {
    var children: [CoordinatorType] = []
    let repositories = Repositories(productsRepository: MockProductsRepository(coreDataManager: CoreDataManager()))
    let rootView = AnyView(EmptyView())
    
    var navigateCount: Int = 0
    
    func view(for state: AppState) -> AnyView {
        navigateCount += 1
        return AnyView(EmptyView())
    }
    
    
}
