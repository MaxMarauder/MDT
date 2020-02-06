//
//  ImageExtension.swift
//  MDT
//
//  Created by Maksym Kershengolts on 18.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import Foundation
import CoreData

extension Image {

    convenience init(with data: APIPayload.Image, context: NSManagedObjectContext) {
        self.init(context: context)
        set(data: data, context:  context)
    }

    func set(data: APIPayload.Image, context: NSManagedObjectContext) {
        self.id = Int32(data.id)
        self.url = data.url
    }
}
