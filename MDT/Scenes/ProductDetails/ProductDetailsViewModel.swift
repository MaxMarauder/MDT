//
//  ProductDetailsViewModel.swift
//  MDT
//
//  Created by Maksym Kershengolts on 20.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import Foundation

final class ProductDetailsViewModel: ViewModel, ObservableObject {
    weak var coordinator: CoordinatorType?
    
    var product: Product

    @Published var noteText: String {
        didSet {
            set(note: noteText)
        }
    }

    init(withCoordinator coordinator: CoordinatorType, product: Product) {
        self.coordinator = coordinator
        self.product = product
        noteText = product.note ?? ""
    }
    
    func set(note: String?) {
        coordinator?.repositories.productsRepository.set(note: note, product: product)
        objectWillChange.send()
    }
}
