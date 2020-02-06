//
//  Repositories.swift
//  MDT
//
//  Created by Maksym Kershengolts on 18.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import Foundation

/// Structure containing all the repositories
struct Repositories {
    var productsRepository: ProductsRepositoryType

    init(productsRepository: ProductsRepositoryType) {
        self.productsRepository = productsRepository
    }
}
