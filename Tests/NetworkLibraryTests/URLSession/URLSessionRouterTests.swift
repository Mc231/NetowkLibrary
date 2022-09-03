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
	
	func testThrowsErrorWhenPerformingTaskWithBadParametersAsync() async {
		// Given
		let endpoint = MockEnpoint.badMock
		do {
			// When
			 try await sut.performVoidTask(to: endpoint)
			XCTFail("Should throw error")
		} catch {
			// Then
			if let networkError = error as? NetworkLibraryError {
				XCTAssertEqual(networkError, .encodingFailed)
			} else {
				XCTFail("Should be NetworkLibraryError")
			}
		}
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
	
	func testTaskSuccessAsync() async throws {
		// Given
		let data = "Success".data(using: .utf8)!
		MockURLProtocol.requestHandler = { request in
			let response = HTTPURLResponse(url: request.url!,
										   statusCode: 200,
										   httpVersion: "HTTP/2.0",
										   headerFields: nil)!
			return (response, data)
		}
		// When
		let result: ResponseEntry = try await sut.performTask(to: MockEnpoint.mock)
		// Then
		XCTAssertEqual(result.data, data)
		if let response = result.response as? HTTPURLResponse {
			XCTAssertEqual(response.statusCode, 200)
			XCTAssertTrue(response.allHeaderFields.isEmpty)
			XCTAssertEqual(response.url, URLSessionRouterTests.baseURL)
		} else {
			XCTFail("Response must be of type HTTPURLResponse")
		}
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
	
	func testTaskReturnsBadStatusCodeAsync() async throws {
		// Given
		let data = "Failure".data(using: .utf8)!
		MockURLProtocol.requestHandler = { request in
			let response = HTTPURLResponse(url: request.url!,
										   statusCode: 300,
										   httpVersion: "HTTP/2.0",
										   headerFields: nil)!
			return (response, data)
		}
		do {
			// When
			let _ : ResponseEntry = try await sut.performTask(to: MockEnpoint.mock)
		} catch {
			if case .invalidResponse(let errorResponse) = error as? NetworkLibraryError, let response = errorResponse as? HTTPURLResponse {
				XCTAssertEqual(response.statusCode, 300)
				XCTAssertEqual(response.url, URLSessionRouterTests.baseURL)
			} else {
				XCTFail("Error should be instance of NetworkLibraryError")
			}
		}
	}
	
	func testDataTaskSuccessAsync() async throws {
		// Given
		let data = "Success".data(using: .utf8)!
		MockURLProtocol.requestHandler = { request in
			let response = HTTPURLResponse(url: request.url!,
										   statusCode: 200,
										   httpVersion: "HTTP/2.0",
										   headerFields: nil)!
			return (response, data)
		}
		// When
		let result: Data = try await sut.performTask(to: MockEnpoint.mock)
		// Then
		XCTAssertEqual(result, data)
	}
	
	func testDataTaskFailedAsync() async throws {
		// Given
		let data = "Failed".data(using: .utf8)!
		MockURLProtocol.requestHandler = { request in
			let response = HTTPURLResponse(url: request.url!,
										   statusCode: 400,
										   httpVersion: "HTTP/2.0",
										   headerFields: nil)!
			return (response, data)
		}
		do {
			// When
			let _ : Data = try await sut.performTask(to: MockEnpoint.mock)
		} catch {
			if case .invalidResponse(let errorResponse) = error as? NetworkLibraryError, let response = errorResponse as? HTTPURLResponse {
				XCTAssertEqual(response.statusCode, 400)
				XCTAssertEqual(response.url, URLSessionRouterTests.baseURL)
			} else {
				XCTFail("Error should be instance of NetworkLibraryError")
			}
		}
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
	
	func testBadUrlInitializationFailed() {
		// Given
		let badURL = "\\\\///////asdasdsdasd"
		// When
		XCTAssertThrowsError(try URLSessionRouter(baseURL: badURL )) { (error) in
			// Then
			XCTAssertEqual(error as? NetworkLibraryError, .invalidUrl)
		}
	}
}
