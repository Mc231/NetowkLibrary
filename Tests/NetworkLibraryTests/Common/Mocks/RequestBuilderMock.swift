//
//  RequestBuilderMock.swift
//  NetworkLibraryTests
//
//  Created by Volodymyr Shyrochuk on 03.09.2022.
//

@testable import NetworkLibrary


enum RequestBuilderMock: EndPoint {
	
	case request
	case noPathRequest
	case requestWithBody(body: Any)
	case requestWithDecodableParameters(body: Encodable)
	case requestWithParameters(body: Parameters?, url: Parameters?)
	case requestWithParametersAndHeader(body: Parameters?, url: Parameters?, headers: HttpHeaders?)
	case upload(body: MultipartBody)
	case formDataRequest(body: Parameters)
	
	var path: String {
		switch self {
		case .noPathRequest:
			return ""
		default:
			return "/stubPath"
		}
	}
	
	var httpMethod: HttpMethod {
		return .get
	}
	
	var task: HttpTask {
		switch self {
		case .request, .noPathRequest:
			return .request()
		case .requestWithBody(let body):
			return .requestWithBody(body: body)
		case .requestWithDecodableParameters(let body):
			return .requestWithEncodableParameters(body: body)
		case .requestWithParameters(let body, let url):
			return .requestWithParameters(body: body, url: url)
		case .requestWithParametersAndHeader(let body, let url, let headers):
			return .requestWithParametersAndHeaders(body: body, url: url, headers: headers)
		case .upload(let body):
			return .upload(body: body)
		case .formDataRequest(let body):
			return .formDataRequest(body: body)
		}
	}
	
	var headers: HttpHeaders? {
		switch self {
		case .request:
			return ["StubHeader": "Stub"]
		default:
			return nil
		}
	}
}
