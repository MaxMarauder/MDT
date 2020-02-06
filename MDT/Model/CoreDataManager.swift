//
//  CoreDataManager.swift
//  MDT
//
//  Created by Maksym Kershengolts on 18.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataManagerType {
    var productsFetchedResultsController: NSFetchedResultsController<Product> { get }
    func save(products: [APIPayload.Product])
    func set(note: String?, product: Product)
}

class CoreDataManager: CoreDataManagerType {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MDT")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    lazy var viewContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()

    lazy var writeContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }()

    func saveContext(_ completion: @escaping () -> Void) {
        writeContext.perform {
            do {
                try self.writeContext.save()
            } catch {
                assertionFailure("Error saving write context: \(error)")
            }
            if let parentContext = self.writeContext.parent {
                parentContext.perform {
                    do {
                        try parentContext.save()
                    } catch {
                        assertionFailure("Error saving parent context: \(error)")
                    }
                    DispatchQueue.main.async(execute: completion)
                }
            }
            else {
                DispatchQueue.main.async(execute: completion)
            }
        }
    }

    var productsFetchedResultsController: NSFetchedResultsController<Product> {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }

    func save(products: [APIPayload.Product]) {
        writeContext.perform { [weak self] in
            guard let context = self?.writeContext else { return }
            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
            var fetchedProducts: [Product]
            do {
                fetchedProducts = try context.fetch(fetchRequest)
            } catch {
                fatalError("Failed to delete objects")
            }
            for data in products {
                if let index = fetchedProducts.firstIndex(where: { $0.identifier == data.identifier }) {
                    fetchedProducts[index].set(data: data, context: context)
                    fetchedProducts.remove(at: index)
                } else {
                    _ = Product(with: data, context: context)
                }
            }
            for product in fetchedProducts {
                context.delete(product)
            }
            self?.saveContext { }
        }
    }

    func set(note: String?, product: Product) {
        product.note = note
        saveContext { }
    }
}
