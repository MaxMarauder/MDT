//
//  ProductImageExtension.swift
//  MDT
//
//  Created by Maksym Kershengolts on 18.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import Foundation
import CoreData

extension ProductImage {

    convenience init(with data: APIPayload.ProductImage, context: NSManagedObjectContext) {
        self.init(context: context)
        set(data: data, context:  context)
    }

    func set(data: APIPayload.ProductImage, context: NSManagedObjectContext) {
        self.id = Int32(data.id)
        self.url = data.url
    }
}
