//
//  Data+Additions.swift
//  NetworkLibrary
//
//  Created by Volodymyr Shyrochuk on 03.09.2022.
//

import Foundation

public extension Data {
    // https://stackoverflow.com/questions/26162616/upload-image-with-parameters-in-swift/26163136#26163136
    /* Append string to Data
     Rather than littering my code with calls to `data(using: .utf8)` to convert `String` values to `Data`, this wraps it in a nice convenient little extension to Data. This defaults to converting using UTF-8.
     - parameter string: The string to be added to the `Data`.
     - parameter encoding: Encoding of string
     */
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}
