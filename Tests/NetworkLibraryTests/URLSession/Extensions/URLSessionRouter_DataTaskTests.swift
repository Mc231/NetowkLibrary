//
//  URLSessionRouter_DataTaskTests.swift
//  NetworkLibraryTests
//
//  Created by Volodymyr Shyrochuk on 03.09.2022.
//

import XCTest
@testable import NetworkLibrary

class URLSessionRouter_DataTaskTests: XCTestCase {
	
	private var sut: URLSessionRouter!
	private static let baseURL = URL(string: "https://stub.com")!
	
	override func setUp() {
		super.setUp()
		
		let sessionConfig = URLSessionConfiguration.ephemeral
		sessionConfig.protocolClasses = [MockURLProtocol.self]
		let session = URLSession(configuration: sessionConfig)
		sut = try? URLSessionRouter(baseURL: URLSessionRouter_DataTaskTests.baseURL.absoluteString, manager: session)
	}
	
	override func tearDown() {
		sut = nil
		super.tearDown()
	}
	
	func testVoidTaskSuccess() {
		// Given
		let data = "Success".data(using: .utf8)!
		MockURLProtocol.requestHandler = { request in
			let response = HTTPURLResponse(url: request.url!,
										   statusCode: 200,
										   httpVersion: "HTTP/2.0",
										   headerFields: nil)!
			return (response, data)
		}
		let promise = expectation(description: "response")
		// When
		sut.performVoidTask(to: MockEnpoint.mock) { (result) in
			if case .success(let result) = result {
				// Then
				XCTAssertNotNil(result)
			}
			promise.fulfill()
		}
		wait(for: [promise], timeout: 1)
	}
	
	func testVoidTaskFailed() {
		// Given
		let data = "Failure".data(using: .utf8)!
		MockURLProtocol.requestHandler = { request in
			let response = HTTPURLResponse(url: request.url!,
										   statusCode: 404,
										   httpVersion: "HTTP/2.0",
										   headerFields: nil)!
			return (response, data)
		}
		let promise = expectation(description: "response")
		// When
		sut.performVoidTask(to: MockEnpoint.mock) { (result) in
			if case .failure(let error) = result {
				// Then
				XCTAssertNotNil(error)
			}
			promise.fulfill()
		}
		wait(for: [promise], timeout: 1)
	}
	
	func testDecodableTaskSuccess() {
		// Given
		let mockModel = MockModel(stub: "Test Model")
		let data = try! JSONEncoder().encode(mockModel)
		MockURLProtocol.requestHandler = { request in
			let response = HTTPURLResponse(url: request.url!,
										   statusCode: 200,
										   httpVersion: "HTTP/2.0",
										   headerFields: nil)!
			return (response, data)
		}
		let promise = expectation(description: "response")
		
		let handler: ((Result<MockModel, Error>) -> Swift.Void) = { result in
			if case .success(let result)  = result {
				// Then
				XCTAssertEqual(result, mockModel)
			}
			promise.fulfill()
		}
		// When
		sut.performTask(to: MockEnpoint.mock, completion: handler)
		wait(for: [promise], timeout: 1)
	}
	
	func testDecodableTaskFailed() {
		// Given
		let mockModel = MockModel(stub: "Test Model")
		let data = try! JSONEncoder().encode(mockModel)
		MockURLProtocol.requestHandler = { request in
			let response = HTTPURLResponse(url: request.url!,
										   statusCode: 404,
										   httpVersion: "HTTP/2.0",
										   headerFields: nil)!
			return (response, data)
		}
		let promise = expectation(description: "response")
		
		let handler: ((Result<MockModel, Error>) -> Swift.Void) = { result in
			if case .failure(let error)  = result {
				// Then
				XCTAssertNotNil(error)
			}
			promise.fulfill()
		}
		// When
		sut.performTask(to: MockEnpoint.mock, completion: handler)
		wait(for: [promise], timeout: 1)
	}
	
	func testDecodingError() {
		// Given
		let mockModel = MockModel(stub: "Test Model")
		let data = try! JSONEncoder().encode(mockModel)
		MockURLProtocol.requestHandler = { request in
			let response = HTTPURLResponse(url: request.url!,
										   statusCode: 200,
										   httpVersion: "HTTP/2.0",
										   headerFields: nil)!
			return (response, data)
		}
		let promise = expectation(description: "response")
		let handler: ((Result<MockModel2, Error>) -> Swift.Void) = { result in
			if case .failure(let error)  = result {
				// Then
				XCTAssertEqual(error as? NetworkLibraryError, .decodingFaield)
			}
			promise.fulfill()
		}
		// When
		sut.performTask(to: MockEnpoint.mock, completion: handler)
		wait(for: [promise], timeout: 1)
	}
}

