//
//  URLSessionRouter+DataTask.swift
//  LMFoundation
//
//  Created by Volodymyr Shyrochuk on 6/11/19.
//  Copyright © 2019 Volodymyr Shyrochuk. All rights reserved.
//

import Foundation

public extension NetworkRouter where Self.Task == URLSessionTask {
    
    @discardableResult
    func performTask<Endpoint: EndPoint>(to endpoint: Endpoint, completion: @escaping NetworkRouterCompletion) -> URLSessionTask? {
        return performTask(to: endpoint) { (result, response) in
            completion(result)
        }
    }
    
    @discardableResult
    func performVoidTask<Endpoint: EndPoint>(to endpint: Endpoint,
                         completion: @escaping NetworkRouterVoidCompletion) -> URLSessionTask? {
        return performTask(to: endpint) { (result) in
            switch result {
            case .success(_):
                completion(.success(Void()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @discardableResult
    func performTask<Endpoint: EndPoint, T: Decodable>(to endpoint: Endpoint,
                                                       decodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase,
                                                       completion: @escaping (Result<T, Error>) -> Swift.Void) -> URLSessionTask? {
        return performTask(to: endpoint, completion: { (result) in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = decodingStrategy
                    let entity = try decoder.decode(T.self, from: data)
                    completion(.success(entity))
                }catch{
					completion(.failure(NetworkLibraryError.decodingFaield))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}
