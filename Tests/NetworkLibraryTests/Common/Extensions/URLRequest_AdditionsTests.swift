//
//  URLRequest_AdditionsTests.swift
//  NetworkLibraryTests
//
//  Created by Volodymyr Shyrochuk on 03.09.2022.
//

@testable import NetworkLibrary
import XCTest

final class URLRequest_AdditionsTests: XCTestCase {
    private var invalidParams: Parameters {
        let invalidValue: (String, String?) = ("231", nil)
        return ["stub": invalidValue]
    }

    private var sut: URLRequest?

    override func setUp() {
        super.setUp()
        let url = URL(string: "stub.stub.stub")!
        sut = URLRequest(url: url)
        sut?.url = nil
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testAddNilHeadersFailed() {
        // Given
        XCTAssertNil(sut?.allHTTPHeaderFields)
        // When
        sut?.addAdditionalHeaders(nil)
        // Then
        XCTAssertNil(sut?.allHTTPHeaderFields)
    }

    func testEncodeUrlParametersFailed() {
        // Given
        let promise = expectation(description: "wait for encode url error")
        // When
        XCTAssertThrowsError(try sut?.encodeUrlParameters(["": ""]), "Must throw invalid url") { error in
            // Then
            XCTAssertEqual(error as? NetworkLibraryError, .invalidUrl)
            promise.fulfill()
        }
        wait(for: [promise], timeout: 1.0)
    }

    func testEncodeBodyParametersFailed() {
        // Given
        let promise = expectation(description: "wait for encode params error")
        // When
        XCTAssertThrowsError(try sut?.encodeBodyParameters(invalidParams), "Must throw encoding failed") { error in
            // Then
            XCTAssertEqual(error as? NetworkLibraryError, .encodingFailed)
            promise.fulfill()
        }
        wait(for: [promise], timeout: 1.0)
    }
}
