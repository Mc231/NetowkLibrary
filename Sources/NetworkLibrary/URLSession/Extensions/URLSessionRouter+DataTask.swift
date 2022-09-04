//
//  URLSessionRouter+DataTask.swift
//  LMFoundation
//
//  Created by Volodymyr Shyrochuk on 3/09/22.
//  Copyright © 2022 Volodymyr Shyrochuk. All rights reserved.
//

import Foundation

public extension NetworkRouter where Self.Task == URLSessionTask {
    /**
     Perform task to specific endpoint
     - parameter endpoint: Endpoint where to make request
     - parameter completion: Completion block that will be invoked with response or error
     */
    @discardableResult
    func performTask<Endpoint: EndPoint>(to endpoint: Endpoint, completion: @escaping NetworkRouterCompletion) -> URLSessionTask? {
        return performTask(to: endpoint) { result, _ in
            completion(result)
        }
    }

    /**
     Perform task to specific endpoint
     - parameter endpoint: Endpoint where to make request
     - parameter completion: Completion block that will be invoked with Void type or error
     */
    @discardableResult
    func performVoidTask<Endpoint: EndPoint>(to endpoint: Endpoint,
                                             completion: @escaping NetworkRouterVoidCompletion) -> URLSessionTask? {
        return performTask(to: endpoint) { result in
            switch result {
            case .success:
                completion(.success(Void()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    /**
     Perform task to specific endpoint and decode response to specific Decodable
     - parameter endpoint: Endpoint where to make request
     - parameter decodingStrategy: Strategy to decode keys
     - parameter completion: Completion block that will be invoked with Decodable type or error
     */
    @discardableResult
    func performTask<Endpoint: EndPoint, T: Decodable>(to endpoint: Endpoint,
                                                       decodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase,
                                                       completion: @escaping (Result<T, Error>) -> Swift.Void) -> URLSessionTask? {
        return performTask(to: endpoint, completion: { result in
            switch result {
            case let .success(data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = decodingStrategy
                    let entity = try decoder.decode(T.self, from: data)
                    completion(.success(entity))
                } catch {
                    completion(.failure(NetworkLibraryError.decodingFailed))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        })
    }
}

// MARK: - Async await support

@available(macOS 10.15.0, *)
@available(iOS 15, *)
public extension NetworkRouter where Self.Task == URLSessionTask {
    /**
     Perform async task to specific endpoint
     - parameter endpoint: Endpoint where to make request
     - returns Response of request or throw error if request failed
     */
    func performTask<Endpoint: EndPoint>(to endpoint: Endpoint) async throws -> ResponseEntry {
        return try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<ResponseEntry, Error>) in
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
        }
    }

    /**
     Perform async task to specific endpoint
     - parameter endpoint: Endpoint where to make request
     - returns Data of response body or throw error if request failed
     */
    func performTask<Endpoint: EndPoint>(to endpoint: Endpoint) async throws -> Data {
        return try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<Data, Error>) in
            self?.performTask(to: endpoint) { result in
                switch result {
                case let .success(data):
                    continuation.resume(returning: data)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /**
     Perform async task to specific endpoint
     - parameter endpoint: Endpoint where to make request
     - returns Nothing or throw error if request failed
     */
    func performVoidTask<Endpoint: EndPoint>(to endpoint: Endpoint) async throws {
        return try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<Void, Error>) in
            self?.performVoidTask(to: endpoint) { result in
                switch result {
                case .success:
                    continuation.resume(returning: Void())
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /**
     Perform async task to specific endpoint and decode response to specific Decodable
     - parameter endpoint: Endpoint where to make request
     - parameter decodingStrategy: Strategy to decode keys
     - returns Decodable model or throw error
     */
    func performTask<Endpoint: EndPoint, T: Decodable>(to endpoint: Endpoint,
                                                       decodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase) async throws -> T {
        return try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<T, Error>) in
            self?.performTask(to: endpoint) { result in
                switch result {
                case let .success(data):
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = decodingStrategy
                        let entity = try decoder.decode(T.self, from: data)
                        continuation.resume(returning: entity)
                    } catch {
                        continuation.resume(throwing: NetworkLibraryError.decodingFailed)
                    }
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
