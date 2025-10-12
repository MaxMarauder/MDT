//
//  ProductImagePreview.swift
//  MDT
//
//  Created by Maksym Kershengolts on 11.10.25.
//  Copyright © 2025 Maksym Kershengolts. All rights reserved.
//

import Foundation

class ProductImagePreview: ProductImage {
    
    override var id: Int32 {
        set {}
        get { 101 }
    }
    
    override var url: String? {
        set {}
        get { "https://qwerty/101.jpg" }
    }
}
