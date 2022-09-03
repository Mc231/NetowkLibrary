//
//  ResponseHandlable.swift
//  NetworkLibrary
//
//  Created by Volodymyr Shyrochuk on 3/09/22.
//  Copyright © 2019 Volodymyr Shyrochuk. All rights reserved.
//

import Foundation

/// Base protocol for handling response
public protocol ResponseHandlable {
	/**
	 Responsible for handling response
	 - parameter data: Data of the reposne
	 - parameter response: Response of request
	 - parameter error: Error of the request
	 - parameter queue: Dispatch queue that will handle response
	 - parameter completion: Complition block that will be invoked after request was handled
	 */
	func handleResponse(data: Data?, response: URLResponse?, error: Error?, queue: DispatchQueue, completion: @escaping NetworkRouterCompletionWithResponse)
}
