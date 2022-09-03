//
//  RequestBuildabler.swift
//  NetworkLIbrary
//
//  Created by Volodymyr Shyrochuk on 3/09/22.
//  Copyright © 2022 Volodymyr Shyrochuk. All rights reserved.
//

import Foundation

/**
 Base protocol for building request
 */
public protocol RequestBuilder {
	/**
	 Creates URLRequest from specific endpoint
	 */
    func buildFromEndpoint(_ endpoint: EndPoint) throws -> URLRequest
}
