//
//  MockCoreDataManager.swift
//  MDTTests
//
//  Created by Maksym Kershengolts on 21.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import Foundation
import CoreData
@testable import MDT

class MockCoreDataManager: CoreDataManagerType {
    var productsFetchedResultsController = NSFetchedResultsController<Product>()
    var savedProducts: [APIPayload.Product] = []
    var productNote: String?

    func save(products: [APIPayload.Product]) {
        savedProducts = products
    }

    func set(note: String?, product: Product) {
        productNote = note
    }

}
