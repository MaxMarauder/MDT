//
//  ProductDetailsViewModel.swift
//  MDT
//
//  Created by Maksym Kershengolts on 20.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import Foundation

final class ProductDetailsViewModel: ViewModel {
    weak var coordinator: CoordinatorType?
    var product: Product

    init(withCoordinator coordinator: CoordinatorType, product: Product) {
        self.coordinator = coordinator
        self.product = product
    }
    
    func set(note: String?) {
        coordinator?.repositories.productsRepository.set(note: note, product: product)
    }
}
