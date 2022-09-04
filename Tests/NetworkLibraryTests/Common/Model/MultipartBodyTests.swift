//
//  MultipartBodyTests.swift
//  NetworkLibraryTests
//
//  Created by Volodymyr Shyrochuk on 03.09.2022.
//

@testable import NetworkLibrary
import XCTest

class MultipartBodyTests: XCTestCase {
    private var sut: MultipartBody!

    override func setUp() {
        super.setUp()
        let url = Bundle.module.url(forResource: "test_file", withExtension: "txt")
        sut = MultipartBody(parameters: ["Stub": "Stub"], fileUrls: [url!])
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testBuildBodySuccess() throws {
        // Given
        XCTAssertNotNil(sut)
        // When
        let data = try sut.build()
        // Then
        XCTAssertNotNil(data)
    }
}
