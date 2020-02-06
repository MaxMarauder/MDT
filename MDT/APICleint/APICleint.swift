//
//  APICleint.swift
//  MDT
//
//  Created by Maksym Kershengolts on 18.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import Foundation

/// Errors returned from APIClient
enum APIError: Error {
    case networkingError(Error?)
    case parsingError(Error)
}

/// Networking completion closure returning either `Data` or `APIError`
typealias NetworkingCompletion = (_ result: Result<Data, APIError>) -> Void
/// Completion closure returning either generic `Payload` or `APIError`
typealias PayloadCompletion<Payload> = (_ result: Result<Payload, APIError>) -> Void

protocol APIClientType {
    func request(service: Service, completion: @escaping NetworkingCompletion)
    func request<R: Resource>(resource: R, completion: @escaping PayloadCompletion<R.Payload>)
}

class APIClient: APIClientType {
    enum HTTPMethod: String {
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case delete = "DELETE"
    }

    /**
     Sends network request
     - Parameter url: Endpoint URL
     - Parameter method: HTTP method
     - Parameter queryItems: GET request parameters
     - Parameter body: POST/PUT request body
     - Parameter headers: HTTP headers
     - Parameter completion: Completion closure
     */
    private func request(_ url: URL, method: HTTPMethod, queryItems: [URLQueryItem]?, body: Data?, headers: [String: String], completion: @escaping NetworkingCompletion) {
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = queryItems
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.allHTTPHeaderFields = headers
        let task = URLSession.shared.dataTask(with: request) { data, response, nsError in
            DispatchQueue.main.async {
                if let data = data, nsError == nil {
                    completion(.success(data))
                } else {
                    completion(.failure(.networkingError(nsError)))
                }
            }
        }
        task.resume()
    }

    /**
     Sends request to a `Service` - any endpoint returning a `NetworkingResponse` (body `Data` and headers `Dictionary`).
     - Parameter service: Endpoint object
     - Parameter completion: Completion closure
     */
    func request(service: Service, completion: @escaping NetworkingCompletion) {
        request(service.url, method: service.method, queryItems: service.queryItems, body: service.body, headers: service.headers, completion: completion)
    }

    /**
     Sends request to a `Resource` - any endpoint that is supposed to return generic `Payload` (some data structure)
     - Parameter resource: Endpoint object
     - Parameter completion: Completion closure
     */
    func request<R: Resource>(resource: R, completion: @escaping PayloadCompletion<R.Payload>) {
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
