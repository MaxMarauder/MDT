//
//  APIPayload.swift
//  MDT
//
//  Created by Maksym Kershengolts on 18.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import Foundation

struct APIPayload {
    struct Image: Decodable {
        let id: Int
        let url: String
    }
    
    struct Product: Decodable {
        let identifier: String
        let name: String
        let brand: String
        let original_price: Double
        let current_price: Double
        let currency: String
        let image: Image
    }
}
