//
//  NetworkRouter.swift
//  NetworkLibrary
//
//  Created by Volodymyr Shyrochuk on 3/09/22.
//  Copyright © 2022 Volodymyr Shyrochuk. All rights reserved.
//

import Foundation

/**
 Describes base functionality of NetworkRouter
 */
public protocol NetworkRouter: AnyObject {
    /// Network Manager that is responsible for request logic
    associatedtype Manager
    /// Network Task
    associatedtype Task
    /// Manager that will perform requests
    var manager: Manager { get set }

    /**
     Perform endpoint task
     - parameters endpoint: Endpoint where request will be done
     - parameter completion: Completion block that will be returned when response was received or error occurred
     */
    @discardableResult
    func performTask<Endpoint: EndPoint>(to endpoint: Endpoint, completion: @escaping NetworkRouterCompletionWithResponse) -> Task?
}
