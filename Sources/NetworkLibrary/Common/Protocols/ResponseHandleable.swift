//
//  ResponseHandleable.swift
//  NetworkLibrary
//
//  Created by Volodymyr Shyrochuk on 3/09/22.
//  Copyright © 2022 Volodymyr Shyrochuk. All rights reserved.
//

import Foundation

/// Base protocol for handling response
public protocol ResponseHandleable {
    /**
     Responsible for handling response
     - parameter data: Data of the response
     - parameter response: Response of request
     - parameter error: Error of the request
     - parameter queue: Dispatch queue that will handle response
     - parameter completion: Completion block that will be invoked after request was handled
     */
    func handleResponse(data: Data?, response: URLResponse?, error: Error?, queue: DispatchQueue, completion: @escaping NetworkRouterCompletionWithResponse)
}
