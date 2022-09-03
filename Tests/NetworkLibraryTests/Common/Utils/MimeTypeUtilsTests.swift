//
//  MimeTypeUtilsTest.swift
//  NetworkLibraryTests
//
//  Created by Volodymyr Shyrochuk on 03.09.2022.
//

@testable import NetworkLibrary
import XCTest

class MimeTypeUtilsTests: XCTestCase {
    // MARK: - Constatns

    private struct Constatns {
        static let textFile = "test_file"
        static let textExtension = "txt"
        static let expectedImageMimeType = "text/plain"
    }

    // MARK: - Vairables

    private lazy var bundle: Bundle = {
        Bundle(for: type(of: self))
    }()

    func testMimeTypeOfTextFile() {
        // Given
        let path = Bundle.module.path(forResource: Constatns.textFile, ofType: Constatns.textExtension)
        XCTAssertNotNil(path)
        // When
        let type = MimeTypeUtils.mimeType(for: path!)
        // Then
        XCTAssertEqual(type, Constatns.expectedImageMimeType)
    }

    func testDefaultOctetStream() {
        // Given
        let path = ""
        // When
        let type = MimeTypeUtils.mimeType(for: path)
        // Then
        XCTAssertEqual(type, MimeTypeUtils.streamConstatns)
    }
}
