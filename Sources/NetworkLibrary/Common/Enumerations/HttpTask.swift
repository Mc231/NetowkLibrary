//
//  HttpTask.swift
//  NetworkLibrary
//
//  Created by Volodymyr Shyrochuk on 03/09/22.
//  Copyright © 2022 Volodymyr Shyrochuk. All rights reserved.
//

import Foundation

// Possible HTTP tasks
public enum HttpTask {
    case request(contentType: String = HTTPHeaderValue.applicationJson)
    case requestWithBody(body: Any)
    case requestWithEncodableParameters(body: Encodable, encodingStrategy: JSONEncoder.KeyEncodingStrategy = .convertToSnakeCase)
    case requestWithParameters(body: Parameters?, url: Parameters?)
    case requestWithParametersAndHeaders(body: Parameters?, url: Parameters?, headers: HttpHeaders?)
    case upload(body: MultipartBody)
    case formDataRequest(body: Parameters)
}
