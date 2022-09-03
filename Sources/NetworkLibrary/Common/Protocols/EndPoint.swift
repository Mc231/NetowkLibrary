//
//  EndPoint.swift
//  NetworkLibrary
//
//  Created by Volodymyr Shyrochuk on 3/09/22.
//  Copyright © 2019 Volodymyr Shyrochuk. All rights reserved.
//

import Foundation

/// Bease protocol tthat describe Endpoint
public protocol EndPoint {
    var path: String { get }
    var httpMethod: HttpMethod { get }
    var task: HttpTask { get }
    var headers: HttpHeaders? { get }
    var timeout: TimeInterval { get }
}
