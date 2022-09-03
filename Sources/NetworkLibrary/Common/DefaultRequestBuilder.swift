//
//  DefaultRequestBuilder.swift
//  NetworkLibrary
//
//  Created by Volodymyr Shyrochuk on 03.09.2022.
//

import Foundation

public class DefaultRequestBuilder: RequestBuilder {
	
	// MARK: - Inizialization
	
	private(set) public var baseUrl : URL
	
	public init(baseUrl: URL) {
		self.baseUrl = baseUrl
	}
	
	public func buildFromEndpoint(_ endpoint: EndPoint) throws -> URLRequest {
		let url = endpoint.path.isEmpty ? baseUrl : baseUrl.appendingPathComponent(endpoint.path)
		var request = URLRequest(url: url,
								 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
								 timeoutInterval: endpoint.timeout)
		request.httpMethod = endpoint.httpMethod.rawValue
		
		if let headers = endpoint.headers {
			request.addAdditionalHeaders(headers)
		}
		
		switch endpoint.task {
		case let .request(contentType):
			request.setValue(contentType, forHTTPHeaderField: HTTPHeader.contentType)
		case .requestWithBody(let body):
			if let data = body as? Data {
				request.httpBody = data
			}else{
				let dataBody = try JSONSerialization.data(withJSONObject: body, options: [])
				request.setValue(HTTPHeaderValue.applicationJson, forHTTPHeaderField: HTTPHeader.contentType)
				request.httpBody = dataBody
			}
		case .requestWithParameters(let bodyParameters, let urlParameters):
			try encode(urlParameters: urlParameters, bodyParameters: bodyParameters, request: &request)
		case .requestWithParametersAndHeaders(let bodyParameters, let urlParameters, let headers):
			request.addAdditionalHeaders(headers)
			try encode(urlParameters: urlParameters, bodyParameters: bodyParameters, request: &request)
		case .requestWithEncodableParameters(let body, let strategy):
			request.httpBody = body.asData(encodingStrategy: strategy)
		case .upload(let body):
			let data = body.build()
			let contentLength = (data as NSData).length
			request.setValue("\(HTTPHeaderValue.multipartFromData); boundary=\(body.boundary)", forHTTPHeaderField: HTTPHeader.contentType)
			request.setValue("\(contentLength)", forHTTPHeaderField: HTTPHeader.contentLength)
			request.httpBody = data
		case .formDataRequest(let parameters, let excludingEncodingCharacters):
			try request.encodeFormDataParameters(parameters, excludingEncodingCharacters: excludingEncodingCharacters)
		}
		return request
	}
	
	private func encode(urlParameters: Parameters?, bodyParameters: Parameters?, request: inout  URLRequest) throws {
		
		if urlParameters != nil {
			try request.encodeUrlParameters(urlParameters!)
		}
		
		if bodyParameters != nil {
			try request.encodeBodyParameters(bodyParameters!)
		}
	}
}
