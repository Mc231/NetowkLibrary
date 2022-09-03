//
//  MultipartBodyTests.swift
//  NetworkLibraryTests
//
//  Created by Volodymyr Shyrochuk on 03.09.2022.
//

import XCTest
@testable import NetworkLibrary

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
	
	func testBuildBodySuccess() {
		// Given
		XCTAssertNotNil(sut)
		// When
		let data = sut.build()
		// Then
		XCTAssertNotNil(data)
	}
}
