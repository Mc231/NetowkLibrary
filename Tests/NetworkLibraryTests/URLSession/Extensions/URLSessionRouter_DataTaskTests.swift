//
//  URLSessionRouter_DataTaskTests.swift
//  NetworkLibraryTests
//
//  Created by Volodymyr Shyrochuk on 03.09.2022.
//

@testable import NetworkLibrary
import XCTest

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
        sut.performVoidTask(to: MockEndpoint.mock) { result in
            if case let .success(result) = result {
                // Then
                XCTAssertNotNil(result)
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 1)
    }

    func testVoidTaskSuccessAsync() async throws {
        // Given
        let data = "Success".data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200,
                                           httpVersion: "HTTP/2.0",
                                           headerFields: nil)!
            return (response, data)
        }
        // When & Then
        try await sut.performVoidTask(to: MockEndpoint.mock)
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
        sut.performVoidTask(to: MockEndpoint.mock) { result in
            if case let .failure(error) = result {
                // Then
                XCTAssertNotNil(error)
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 1)
    }

    func testVoidTaskFailedAsync() async throws {
        // Given
        let data = "Failure".data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 404,
                                           httpVersion: "HTTP/2.0",
                                           headerFields: nil)!
            return (response, data)
        }
        // When
        do {
            try await sut.performVoidTask(to: MockEndpoint.mock)
        } catch {
            // Then
            XCTAssertNotNil(error)
        }
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
            if case let .success(result) = result {
                // Then
                XCTAssertEqual(result, mockModel)
            }
            promise.fulfill()
        }
        // When
        sut.performTask(to: MockEndpoint.mock, completion: handler)
        wait(for: [promise], timeout: 1)
    }

    func testDecodableTaskSuccessAsync() async throws {
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
        // When
        let result: MockModel = try await sut.performTask(to: MockEndpoint.mock)
        // Then
        XCTAssertEqual(result, mockModel)
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
            if case let .failure(error) = result {
                // Then
                XCTAssertNotNil(error)
            }
            promise.fulfill()
        }
        // When
        sut.performTask(to: MockEndpoint.mock, completion: handler)
        wait(for: [promise], timeout: 1)
    }

    func testDecodableTaskFailedAsync() async throws {
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
        do {
            // When
            let _: MockModel = try await sut.performTask(to: MockEndpoint.mock)
        } catch {
            // Then
            print(error)
            XCTAssertNotNil(error)
        }
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
            if case let .failure(error) = result {
                // Then
                XCTAssertEqual(error as? NetworkLibraryError, .decodingFailed)
            }
            promise.fulfill()
        }
        // When
        sut.performTask(to: MockEndpoint.mock, completion: handler)
        wait(for: [promise], timeout: 1)
    }

    func testDecodingErrorAsync() async throws {
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
        do {
            // When
            let _: MockModel2 = try await sut.performTask(to: MockEndpoint.mock)
        } catch {
            // Then
            if let networkLibraryError = error as? NetworkLibraryError {
                XCTAssertEqual(networkLibraryError, .decodingFailed)
            } else {
                XCTFail("Error should be of type NetworkLibraryError")
            }
        }
    }
}
