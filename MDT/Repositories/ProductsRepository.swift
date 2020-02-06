//
//  ProductsRepository.swift
//  MDT
//
//  Created by Maksym Kershengolts on 18.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import Foundation
import CoreData

protocol ProductsRepositoryType {
    var productsFetchedResultsController: NSFetchedResultsController<Product> { get }
    func requestProducts(completion: @escaping (_ result: Result<Void, APIError>) -> Void)
    func set(note: String?, product: Product)
}

class ProductsRepository: ProductsRepositoryType {
    let apiClient: APIClientType
    let coreDataManager: CoreDataManagerType

    var productsFetchedResultsController: NSFetchedResultsController<Product> {
        return coreDataManager.productsFetchedResultsController
    }

    init(apiClient: APIClientType, coreDataManager: CoreDataManagerType) {
        self.apiClient = apiClient
        self.coreDataManager = coreDataManager
    }

    func requestProducts(completion: @escaping (_ result: Result<Void, APIError>) -> Void) {
        apiClient.request(resource: Products()) { [weak self] result in
            switch result {
            case .success(let payload):
                self?.save(products: payload)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func save(products: [APIPayload.Product]) {
        coreDataManager.save(products: products)
    }

    func set(note: String?, product: Product) {
        coreDataManager.set(note: note, product: product)
    }
}
