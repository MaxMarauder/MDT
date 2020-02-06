//
//  MockProductsRepository.swift
//  MDTTests
//
//  Created by Maksym Kershengolts on 13.08.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import Foundation
import CoreData
@testable import MDT

class MockProductsRepository: ProductsRepositoryType {
    let coreDataManager: CoreDataManagerType
    lazy var productsFetchedResultsController = {
        self.coreDataManager.productsFetchedResultsController
    }()
    
    var requestProductsCount: Int = 0
    var setNoteCount: Int = 0
    
    init(coreDataManager: CoreDataManagerType) {
        self.coreDataManager = coreDataManager
    }
    
    func requestProducts(completion: @escaping (Result<Void, APIError>) -> Void) {
        requestProductsCount += 1
        completion(.success(()))
    }
    
    func set(note: String?, product: Product) {
        setNoteCount += 1
    }
    
    
}
