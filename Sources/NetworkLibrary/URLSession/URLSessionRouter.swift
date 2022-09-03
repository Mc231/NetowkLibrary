//
//  URLSessionRouter.swift
//  HTTPLib
//
//  Created by Volodymyr Shyrochuk on 3/09/22.
//  Copyright © 2022 Volodymyr Shyrochuk. All rights reserved.
//

import Foundation

/**
 URL session implementation of NetworkRouter
 */
open class URLSessionRouter: NSObject, NetworkRouter {
    public let builder: RequestBuilder
    public var manager: URLSession?
    public let responseHandleQueue: DispatchQueue
    public let responseHandler: ResponseHandleable

    public init(builder: RequestBuilder,
                manager: URLSession = .shared,
                responseHandleQueue: DispatchQueue = .main,
                responseHandler: ResponseHandleable = DefaultResponseHandler()) {
        self.builder = builder
        self.manager = manager
        self.responseHandleQueue = responseHandleQueue
        self.responseHandler = responseHandler
    }

    @discardableResult
    public func performTask<Endpoint: EndPoint>(to endpoint: Endpoint,
                                                completion: @escaping NetworkRouterCompletionWithResponse) -> URLSessionTask? {
        do {
            let request = try builder.buildFromEndpoint(endpoint)
            let queue = responseHandleQueue
            let task = manager?.dataTask(with: request) { [weak self] data, response, error in
                self?.responseHandler.handleResponse(data: data, response: response, error: error, queue: queue, completion: completion)
            }
            task?.resume()
            return task
        } catch {
            completion(.failure(error), nil)
            return nil
        }
    }
}

// MARK: - Public methods

public extension URLSessionRouter {
    convenience init(baseURL: String,
                     manager: URLSession = .shared,
                     responseHandleQueue: DispatchQueue = .main,
                     responseHandler: ResponseHandleable = DefaultResponseHandler()) throws {
        guard let url = URL(string: baseURL) else {
            throw NetworkLibraryError.invalidUrl
        }
        let builder = DefaultRequestBuilder(baseUrl: url)
        self.init(builder: builder, manager: manager, responseHandleQueue: responseHandleQueue, responseHandler: responseHandler)
    }
}
