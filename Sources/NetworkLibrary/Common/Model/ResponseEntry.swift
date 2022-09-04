//
//  ResponseEntry.swift
//
//
//  Created by Volodymyr Shyrochuk on 03.09.2022.
//

import Foundation

/// Contains response and its body representation
public struct ResponseEntry {
    /// Response body data
    public let data: Data
    /// Response of request
    public let response: URLResponse
}
