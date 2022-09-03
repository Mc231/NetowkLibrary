//
//  URLSessionRouterTests.swift
//  NetworkLibraryTests
//
//  Created by Volodymyr Shyrochuk on 03.09.2022.
//

import XCTest
@testable import NetworkLibrary

final class URLSessionRouterTests: XCTestCase {
	
	private var sut: URLSessionRouter!
	private static let baseURL = URL(string: "https://stub.com")!

	override func setUp() {
		super.setUp()
		let sessionConfig = URLSessionConfiguration.ephemeral
		sessionConfig.protocolClasses = [MockURLProtocol.self]
		let session = URLSession(configuration: sessionConfig)
		sut = try? URLSessionRouter(baseURL: URLSessionRouterTests.baseURL.absoluteString, manager: session)
	}

	override func tearDown() {
		sut = nil
		super.tearDown()
	}
	
	func testCreateRouterWithStringURL() {
		// Given
		let stubUrl = "https://stub.com"
		// When
		let _sut = try? URLSessionRouter(baseURL: stubUrl)
		// Then
		XCTAssertNotNil(_sut)
	}
	
	func testThrowsErrorWhenPerformingTaskWithBadParameters() {
		// Given
		let promise = expectation(description: "Waiting for bad params")
	   // When
		sut.performVoidTask(to: MockEnpoint.badMock) { (result) in
			if case .failure(let error) = result {
				// Then
				XCTAssertEqual(error as? NetworkLibraryError, .encodingFailed)
			}
			promise.fulfill()
		}
		wait(for: [promise], timeout: 1.0)
	}

	func testTaskSuccess() {
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
		sut.performTask(to: MockEnpoint.mock, completion: { (result, response) in
			if let response =  response as? HTTPURLResponse {
				// Then
				XCTAssertEqual(response.statusCode, 200)
				XCTAssertTrue(response.allHeaderFields.isEmpty)
				XCTAssertEqual(response.url, URLSessionRouterTests.baseURL)
				if case .success(let responseData) = result {
					XCTAssertEqual(responseData, data)
				}
			}
			promise.fulfill()
		})
		wait(for: [promise], timeout: 1)
	}
	
	func testTaskReturnsBadStatusCode() {
		// Given
		let data = "Failure".data(using: .utf8)!
		MockURLProtocol.requestHandler = { request in
			let response = HTTPURLResponse(url: request.url!,
										   statusCode: 300,
										   httpVersion: "HTTP/2.0",
										   headerFields: nil)!
			return (response, data)
		}
		let promise = expectation(description: "response")
		// When
		sut.performTask(to: MockEnpoint.mock, completion: { (result, response) in
			if let response =  response as? HTTPURLResponse {
				// Then
				let statusCode = response.statusCode
				XCTAssertEqual(statusCode, 300)
				XCTAssertTrue(response.allHeaderFields.isEmpty)
				XCTAssertEqual(response.url, URLSessionRouterTests.baseURL)
				if case .failure(let error) = result, case .invalidResponse(let errorResponse) = error as? NetworkLibraryError {
					XCTAssertEqual(errorResponse, response)
				} else {
					XCTFail("Error should contain response")
				}
			}
			promise.fulfill()
		})
		wait(for: [promise], timeout: 1)
	}
	
	func testTaskThrowsError() {
		// Given
		MockURLProtocol.requestHandler = { request in
			throw NetworkLibraryError.invalidUrl
		}
		
		let promise = expectation(description: "response")
		// When
		sut.performTask(to: MockEnpoint.mock, completion: { (result, response) in
			// Then
			XCTAssertNil(response)
			promise.fulfill()
		})
		wait(for: [promise], timeout: 1)
	}
	
	func testRunBadTaskEndpoint() {
		// Given
		let badURL = "\\\\///////asdasdsdasd"
		// When
		XCTAssertThrowsError(try URLSessionRouter(baseURL: badURL )) { (error) in
			// Then
			XCTAssertEqual(error as? NetworkLibraryError, .invalidUrl)
		}
	}
}
