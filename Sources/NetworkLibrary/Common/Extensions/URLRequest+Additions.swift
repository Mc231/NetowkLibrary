//
//  URLRequest+Additions.swift
//  HTTPLib
//
//  Created by Volodymyr Shyrochuk on 03/09/22.
//  Copyright © 2022 Volodymyr Shyrochuk. All rights reserved.
//

import Foundation

public extension URLRequest {
    /**
     Add headers to request
     - parameter additionalHeaders: Headers that will be added to request
     */
    mutating func addAdditionalHeaders(_ additionalHeaders: HttpHeaders?) {
        guard let headers = additionalHeaders else { return }
        for iteration in headers {
            let key = iteration.key
            if value(forHTTPHeaderField: key) == nil {
                setValue(iteration.value, forHTTPHeaderField: key)
            }
        }
    }

    /**
     Encode parameters to form data format
     - parameter parameters: Parameters to encode
     */
    mutating func encodeFormDataParameters(_ parameters: Parameters) throws {
        var components = URLComponents()
        components.queryItems = parameters.asQueryItems
        httpBody = components.query?.data(using: .utf8)
    }

    /**
     Encode parameters to url format
     - parameter parameters: Parameters to encode
     */
    mutating func encodeUrlParameters(_ parameters: Parameters) throws {
        guard let url = self.url else { throw NetworkLibraryError.invalidUrl }

        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
            urlComponents.percentEncodedQueryItems = parameters.asQueryItems
            self.url = urlComponents.url
        }

        if value(forHTTPHeaderField: HTTPHeader.contentType) == nil {
            setValue(HTTPHeaderValue.xWWWFormUrlEncoded, forHTTPHeaderField: HTTPHeader.contentType)
        }
    }

    /**
     Encode body parameters
     - parameter parameters: Parameters to encode
     - parameter options: Options of JSON serialization
     */
    mutating func encodeBodyParameters(_ parameters: Parameters, options: JSONSerialization.WritingOptions = .prettyPrinted) throws {
        if JSONSerialization.isValidJSONObject(parameters) {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: options)
            httpBody = jsonData
            if value(forHTTPHeaderField: HTTPHeader.contentType) == nil {
                setValue(HTTPHeaderValue.applicationJson, forHTTPHeaderField: HTTPHeader.contentType)
            }
        } else {
            throw NetworkLibraryError.encodingFailed
        }
    }
}
