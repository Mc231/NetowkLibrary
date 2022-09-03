//
//  MultipartBody.swift
//  NetworkLIbrary
//
//  Created by Volodymyr Shyrochuk on 03/09/22.
//  Copyright © 2022 Volodymyr Shyrochuk. All rights reserved.
//

import Foundation

public struct MultipartBody {
    
    public static let fileKey = "file"
    
    private let parameters: Parameters
    private let fileKeyPath: String
    private let fileUrls: [URL]
    public var boundary: String
    
    public init(parameters: Parameters = [:],
                fileKeyPath: String = MultipartBody.fileKey,
                fileUrls: [URL]) {
        self.parameters = parameters
        self.fileKeyPath = fileKeyPath
        self.fileUrls = fileUrls
        self.boundary = "Boundary-\(UUID().uuidString)"
    }
    
    public func build() -> Data {
        var body = Data()
        if !parameters.isEmpty {
            appendParameters(body: &body, boundary: boundary)
        }
        appendFileUrls(body: &body, boundary: boundary)
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    private func appendParameters(body: inout Data, boundary: String) {
        parameters.forEach { (iteration) in
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(iteration.key)\"\r\n\r\n")
            body.append("\(iteration.value)\r\n")
        }
    }
    
    private func appendFileUrls(body: inout Data, boundary: String) {
        for url in fileUrls {
            let fileName = url.lastPathComponent
            // Fore unwrap try because url is validated and can not be nil
            let data = try! Data(contentsOf: url)
            let mimetype = MimeTypeUtils.mimeType(for: url.path)
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(fileKeyPath)\"; filename=\"\(fileName)\"\r\n")
            body.append("Content-Type: \(mimetype)\r\n\r\n")
            body.append(data)
            body.append("\r\n")
        }
    }
}

