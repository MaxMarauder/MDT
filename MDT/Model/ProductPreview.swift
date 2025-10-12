//
//  ProductPreview.swift
//  MDT
//
//  Created by Maksym Kershengolts on 11.10.25.
//  Copyright © 2025 Maksym Kershengolts. All rights reserved.
//

import Foundation

class ProductPreview: Product {
    private let imagePreview = ProductImagePreview()
    
    override var brand: String? {
        set {}
        get { "Brand 1" }
    }
    
    override var currency: String? {
        set {}
        get { "EUR" }
    }

    override var currentPrice: Double {
        set {}
        get { 59.95 }
    }

    override var identifier: String? {
        set {}
        get { "1" }
    }

    override var name: String? {
        set {}
        get { "Product A" }
    }

    override var note: String? {
        set {}
        get { "note" }
    }

    override var originalPrice: Double {
        set {}
        get { 99.95 }
    }

    override var image: ProductImage? {
        set {}
        get { imagePreview }
    }

}
