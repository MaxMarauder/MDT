//
//  ProductService.swift
//  MDT
//
//  Created by Maksym Kershengolts on 20.08.21.
//  Copyright © 2021 Maksym Kershengolts. All rights reserved.
//

import Foundation

final class Products: Resource {
    typealias Payload = [APIPayload.Product]

    static var endpoint: String {
        return "cars"
    }
}
