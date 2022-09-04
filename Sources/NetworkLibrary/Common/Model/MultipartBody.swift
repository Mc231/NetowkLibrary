//
//  MultipartBody.swift
//  NetworkLibrary
//
//  Created by Volodymyr Shyrochuk on 03/09/22.
//  Copyright © 2022 Volodymyr Shyrochuk. All rights reserved.
//

import Foundation

/**
 Structure that represent multipart body to upload
 */
public struct MultipartBody {
    public static let fileKey = "file"
	public static let defaultMimeType = "application/octet-stream"

    private let parameters: Parameters
    private let fileKeyPath: String
    private let fileUrls: [URL]
	private let mimeType: String
    public var boundary: String

    public init(parameters: Parameters = [:],
                fileKeyPath: String = MultipartBody.fileKey,
                fileUrls: [URL],
				mimeType: String = MultipartBody.defaultMimeType) {
        self.parameters = parameters
        self.fileKeyPath = fileKeyPath
        self.fileUrls = fileUrls
		self.mimeType = mimeType
        boundary = "Boundary-\(UUID().uuidString)"
    }

    public func build() throws -> Data {
        var body = Data()
        if !parameters.isEmpty {
            appendParameters(body: &body, boundary: boundary)
        }
        try appendFileUrls(body: &body, boundary: boundary)
        body.append("--\(boundary)--\r\n")
        return body
    }

    private func appendParameters(body: inout Data, boundary: String) {
        parameters.forEach { iteration in
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(iteration.key)\"\r\n\r\n")
            body.append("\(iteration.value)\r\n")
        }
    }

    private func appendFileUrls(body: inout Data, boundary: String) throws {
        for url in fileUrls {
            let fileName = url.lastPathComponent
            // Fore unwrap try because url is validated and can not be nil
            let data = try Data(contentsOf: url)
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(fileKeyPath)\"; filename=\"\(fileName)\"\r\n")
            body.append("Content-Type: \(mimeType)\r\n\r\n")
            body.append(data)
            body.append("\r\n")
        }
    }
}
