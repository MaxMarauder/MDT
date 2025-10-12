//
//  ProductExtension.swift
//  MDT
//
//  Created by Maksym Kershengolts on 18.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import UIKit
import CoreData

extension Product {

    convenience init(with data: APIPayload.Product, context: NSManagedObjectContext) {
        self.init(context: context)
        set(data: data, context: context)
    }

    var listID: String {
        return "\(identifier ?? "")_\(note ?? "")"
    }
    
    func set(data: APIPayload.Product, context: NSManagedObjectContext) {
        self.identifier = data.identifier
        self.name = data.name
        self.brand = data.brand
        self.originalPrice = data.original_price
        self.currentPrice = data.current_price
        self.currency = data.currency
        self.image = ProductImage(with: data.image, context: context)
    }

    var isDiscounted : Bool {
        return currentPrice != originalPrice
    }    
}
