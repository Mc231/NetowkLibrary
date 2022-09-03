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
    func performVoidTask<Endpoint: EndPoint>(to endpoint: Endpoint,
                         completion: @escaping NetworkRouterVoidCompletion) -> URLSessionTask? {
        return performTask(to: endpoint) { (result) in
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

// MARK: - Async await support

@available(macOS 10.15.0, *)
@available(iOS 15, *)
extension NetworkRouter where Self.Task == URLSessionTask {

	func performTask<Endpoint: EndPoint>(to endpoint: Endpoint) async throws -> ResponseEntry {
		return try await withCheckedThrowingContinuation({ [weak self] (continuation: CheckedContinuation<ResponseEntry, Error>) in
			self?.performTask(to: endpoint) { result, response in
				switch result {
				case let .success(data):
					if let response = response {
						let entry = ResponseEntry(data: data, response: response)
						continuation.resume(returning: entry)
					}
				case let .failure(error):
					continuation.resume(throwing: error)
				}
			}
		})
	}
	
	func performTask<Endpoint: EndPoint>(to endpoint: Endpoint) async throws -> Data {
		return try await withCheckedThrowingContinuation({ [weak self] (continuation: CheckedContinuation<Data, Error>) in
			self?.performTask(to: endpoint) { result in
				switch result {
				case let .success(data):
					continuation.resume(returning: data)
				case let .failure(error):
					continuation.resume(throwing: error)
				}
			}
		})
	}
	
	func performVoidTask<Endpoint: EndPoint>(to endpoint: Endpoint) async throws  {
		return try await withCheckedThrowingContinuation({ [weak self] (continuation: CheckedContinuation<Void, Error>) in
			self?.performVoidTask(to: endpoint) { result in
				switch result {
				case .success:
					continuation.resume(returning: Void())
				case let .failure(error):
					continuation.resume(throwing: error)
				}
			}
		})
	}
	
	func performTask<Endpoint: EndPoint, T: Decodable>(to endpoint: Endpoint,
											decodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase) async throws -> T {
		return try await withCheckedThrowingContinuation({ [weak self] (continuation: CheckedContinuation<T, Error>) in
			self?.performTask(to: endpoint) { result in
				switch result {
				case let .success(data):
					do {
						let decoder = JSONDecoder()
						decoder.keyDecodingStrategy = decodingStrategy
						let entity = try decoder.decode(T.self, from: data)
						continuation.resume(returning: entity)
					}catch{
						continuation.resume(throwing: NetworkLibraryError.decodingFaield)
					}
				case let .failure(error):
					continuation.resume(throwing: error)
				}
			}
		})
	}
}
