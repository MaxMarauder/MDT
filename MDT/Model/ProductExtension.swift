//
//  ProductExtension.swift
//  MDT
//
//  Created by Maksym Kershengolts on 18.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import UIKit
import CoreData
import CryptoSwift

private let kCacheDirectory = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("Images")

extension Product {

    convenience init(with data: APIPayload.Product, context: NSManagedObjectContext) {
        self.init(context: context)
        set(data: data, context: context)
    }

    func set(data: APIPayload.Product, context: NSManagedObjectContext) {
        self.identifier = data.identifier
        self.name = data.name
        self.brand = data.brand
        self.originalPrice = data.original_price
        self.currentPrice = data.current_price
        self.currency = data.currency
        self.image = Image(with: data.image, context: context)
    }

    func downloadImage(completion: @escaping (UIImage?) -> Void) {
        guard let urlStr = image?.url, let url = URL(string: urlStr) else {
            completion(nil)
            return
        }

        let cachePath = kCacheDirectory.appendingPathComponent(urlStr.md5())
        if FileManager.default.fileExists(atPath: cachePath.path) {
            DispatchQueue.global(qos: .userInitiated).async {
                let image = UIImage(contentsOfFile: cachePath.path)
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let data = try? Data(contentsOf: url)
            let image = data.flatMap { UIImage(data: $0) }
            DispatchQueue.main.async {
                if let data = data {
                    if !FileManager.default.fileExists(atPath: kCacheDirectory.path) {
                        try! FileManager.default.createDirectory(at: kCacheDirectory, withIntermediateDirectories: true, attributes: nil)
                    }
                    do {
                        try data.write(to: cachePath)
                    } catch {
                        assertionFailure("Failed to cache an image")
                    }
                }
                completion(image)
            }
        }
    }
}
