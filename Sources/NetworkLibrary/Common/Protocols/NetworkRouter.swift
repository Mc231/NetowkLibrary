//
//  NetworkRouter.swift
//  NetworkLibrary
//
//  Created by Volodymyr Shyrochuk on 3/09/22.
//  Copyright © 2022 Volodymyr Shyrochuk. All rights reserved.
//

import Foundation

/**
	Describes base functionallity of NetworkRouter
 */
public protocol NetworkRouter: AnyObject {
    /// Network Manager that is responsible for request logic
    associatedtype Manager
    /// Network Task
    associatedtype Task
    
    var manager: Manager { get set }
    
    @discardableResult
	func performTask<Endpoint: EndPoint>(to endpoint: Endpoint, completion: @escaping NetworkRouterCompletionWithResponse) -> Task?
}

