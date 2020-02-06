//
//  MockAPIClient.swift
//  MDTTests
//
//  Created by Maksym Kershengolts on 21.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import Foundation
@testable import MDT

private let kBundle = Bundle(for: MockAPIClient.self)

class MockAPIClient: APIClientType {
    func request(service: Service, completion: @escaping NetworkingCompletion) {
        switch service {
        case is Products:
            guard let url = kBundle.url(forResource: "products", withExtension: "json"), let data = try? Data(contentsOf: url) else {
                fatalError("Failed to load response from file")
            }
            completion(.success(data))
        default:
            completion(.failure(.networkingError(nil)))
        }
    }

    func request<R>(resource: R, completion: @escaping (Result<R.Payload, APIError>) -> Void) where R : Resource {
        self.request(service: resource) { result in
            switch result {
            case .success(let data):
                let payload = resource.parse(data)
                completion(payload)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
