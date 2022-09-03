//
//  Encodable_AdditionsTests.swift
//  NetworkLibraryTests
//
//  Created by Volodymyr Shyrochuk on 03.09.2022.
//

import XCTest
@testable import NetworkLibrary

final class Encodable_AdditionsTests: XCTestCase {

    func testEncodableToDictionarySnakeCaseEncodingStrategy() throws {
		// Given
		let model = EncodableMock(testField: "Test", testFieldTwo: 123)
		// When
		let result: [String: Any]? = model.asDictionary(encodingStrategy: .convertToSnakeCase)
		// Then
		XCTAssertEqual(result?["test_field"] as? String, "Test")
		XCTAssertEqual(result?["test_field_two"] as? Int, 123)
    }
	
	func testEncodableToDictionaryDefaultEncodingStrategy() throws {
		// Given
		let model = EncodableMock(testField: "Test", testFieldTwo: 123)
		// When
		let result: [String: Any]? = model.asDictionary(encodingStrategy: .useDefaultKeys)
		// Then
		XCTAssertEqual(result?["testField"] as? String, "Test")
		XCTAssertEqual(result?["testFieldTwo"] as? Int, 123)
	}
}
