//
//  ProductListViewModel.swift
//  MDT
//
//  Created by Maksym Kershengolts on 18.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import Foundation
import CoreData

final class ProductListViewModel: NSObject, ViewModel, ObservableObject {
    weak var coordinator: CoordinatorType?
    
    let fetchedResultsController: NSFetchedResultsController<Product>
    
    var products: [Product] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    var onProductsFetched: (() -> Void)?

    @Published var searchText: String = "" {
        didSet {
            filter(with: searchText)
        }
    }

    init(withCoordinator coordinator: CoordinatorType) {
        self.coordinator = coordinator
        fetchedResultsController = coordinator.repositories.productsRepository.productsFetchedResultsController
        super.init()
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Error fetching results \(error)")
        }
    }

    func refresh(completion: @escaping () -> Void) {
        coordinator?.repositories.productsRepository.requestProducts { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        completion()
    }

    func filter(with text: String) {
        fetchedResultsController.fetchRequest.predicate = text.isEmpty ? nil : NSPredicate(format: "name CONTAINS[c] %@", text)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Error fetching results \(error)")
        }
        objectWillChange.send()
        onProductsFetched?()
    }
}

extension ProductListViewModel: NSFetchedResultsControllerDelegate {    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objectWillChange.send()
        onProductsFetched?()
    }
}
