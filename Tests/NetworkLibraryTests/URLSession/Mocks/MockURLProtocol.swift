//
//  MockURLProtocol.swift
//  NetworkLibraryTests
//
//  Created by Volodymyr Shyrochuk on 03.09.2022.
//

import XCTest

open class MockURLProtocol: URLProtocol {
	
	public static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
	
	override open class func canInit(with request: URLRequest) -> Bool {
		return true
	}
	
	override open class func canonicalRequest(for request: URLRequest) -> URLRequest {
		return request
	}
	
	override open func startLoading() {
		guard let handler = MockURLProtocol.requestHandler else {
			XCTFail("No handler set")
			return
		}
		
		do {
			let (response, data) = try handler(request)
			client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
			if let data = data {
				client?.urlProtocol(self, didLoad: data)
			}
			client?.urlProtocolDidFinishLoading(self)
		} catch {
			client?.urlProtocol(self, didFailWithError: error)
		}
	}
	
	override open func stopLoading() {
		
	}
}
