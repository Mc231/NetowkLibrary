//
//  URLRequest+Additions.swift
//  HTTPLib
//
//  Created by Volodymyr Shyrochuk on 03/09/22.
//  Copyright © 2022 Volodymyr Shyrochuk. All rights reserved.
//

import Foundation

public extension URLRequest {
    
    mutating func addAdditionalHeaders(_ additionalHeaders: HttpHeaders?) {
        guard let headers = additionalHeaders else { return }
        for iteration in headers {
            let key = iteration.key
            if value(forHTTPHeaderField: key) == nil {
                setValue(iteration.value, forHTTPHeaderField: key)
            }
        }
    }
    
    mutating func encodeFormDataParameters(_ parameters: Parameters, excludingEncodingCharacters: String? = nil) throws {
        var components = URLComponents()
		components.queryItems = parameters.asQueryItems
        httpBody = components.query?.data(using: .utf8)
    }
    
    mutating func encodeUrlParameters(_ parameters: Parameters) throws {
        
        guard let url = self.url else { throw NetworkLibraryError.invalidUrl }
        
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
            urlComponents.percentEncodedQueryItems = parameters.asQueryItems
            self.url = urlComponents.url
        }
        
        if self.value(forHTTPHeaderField: HTTPHeader.contentType) == nil {
            self.setValue(HTTPHeaderValue.xWWWFormUrlencoded, forHTTPHeaderField: HTTPHeader.contentType)
        }
    }
    
	mutating func encodeBodyParameters(_ parameters: Parameters, options: JSONSerialization.WritingOptions = .prettyPrinted) throws {
        if JSONSerialization.isValidJSONObject(parameters) {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: options)
            self.httpBody = jsonData
            if self.value(forHTTPHeaderField: HTTPHeader.contentType) == nil {
                self.setValue(HTTPHeaderValue.applicationJson, forHTTPHeaderField: HTTPHeader.contentType)
            }
        }else {
           throw NetworkLibraryError.encodingFailed
        }
    }
}
