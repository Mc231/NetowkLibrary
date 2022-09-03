//
//  DefaultResponseHandler.swift
//  NetworkLibrary
//
//  Created by Volodymyr Shyrochuk on 3/09/22.
//  Copyright © 2022 Volodymyr Shyrochuk. All rights reserved.
//

import Foundation

/**
 Default implementation of ResponseHandleable
 */
public struct DefaultResponseHandler: ResponseHandleable {
    // MARK: - Constants

    public static let defaultValidStatusCodeRange = 200 ... 299

    private let validStatusCodeRange: ClosedRange<Int>

    public init(validStatusCodeRange: ClosedRange<Int> = DefaultResponseHandler.defaultValidStatusCodeRange) {
        self.validStatusCodeRange = validStatusCodeRange
    }

    public func handleResponse(data: Data?, response: URLResponse?, error: Error?, queue: DispatchQueue, completion: @escaping NetworkRouterCompletionWithResponse) {
        queue.async {
            if let error = error {
                completion(.failure(error), response)
            } else if let data = data,
                let response = response as? HTTPURLResponse {
                let statusCode = response.statusCode
                let isValid = self.validStatusCodeRange.contains(statusCode)
                if isValid {
                    completion(.success(data), response)
                } else {
                    completion(.failure(NetworkLibraryError.invalidResponse(response)), response)
                }
            } else {
                completion(.failure(NetworkLibraryError.invalidResponse(response)), response)
            }
        }
    }
}
