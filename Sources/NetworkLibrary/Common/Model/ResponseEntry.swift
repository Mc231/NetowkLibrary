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
    let data: Data
    /// Response of request
    let response: URLResponse
}
