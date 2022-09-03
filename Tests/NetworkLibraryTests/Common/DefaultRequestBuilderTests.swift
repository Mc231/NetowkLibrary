//
//  DefaultRequestBuilderTest.swift
//  NetworkLibraryTests
//
//  Created by Volodymyr Shyrochuk on 03.09.2022.
//

@testable import NetworkLibrary
import XCTest

final class DefaultRequestBuilderTests: XCTestCase {
    private let baseUrl = URL(string: "https://stub2.com")!
    private var sut: RequestBuilder?

    override func setUp() {
        super.setUp()
        sut = DefaultRequestBuilder(baseUrl: baseUrl)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testBuilderInitWithURL() {
        // Given
        let builder = DefaultRequestBuilder(baseUrl: baseUrl)
        // Then
        XCTAssertEqual(builder.baseUrl, baseUrl)
    }

    func testBuildNoPathRequest() {
        // Given
        let endpoint = RequestBuilderMock.noPathRequest
        // When
        let request = try? sut?.buildFromEndpoint(endpoint)
        // Then
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.url, baseUrl)
    }

    func testBuildRequestWithBodyParameters() {
        // Given
        let bodyParams: Parameters = ["Stub": "Test"]
        let endpoint = RequestBuilderMock.requestWithParameters(body: bodyParams, url: nil)
        // When
        let request = try? sut?.buildFromEndpoint(endpoint)
        // Then
        XCTAssertNotNil(request)
        let body = request?.httpBody
        XCTAssertNotNil(body)
        let serializedParams = try? JSONSerialization.jsonObject(with: body!, options: .allowFragments) as? Parameters
        XCTAssertNotNil(serializedParams)
        XCTAssertNotNil(serializedParams?["Stub"])
    }

    func testBuildRequestWithBody() {
        // Given
        let data = ["Test"]
        let endpoint = RequestBuilderMock.requestWithBody(body: data)
        // When
        let request = try? sut?.buildFromEndpoint(endpoint)
        // Then
        XCTAssertNotNil(request)
        XCTAssertNotNil(request?.httpBody)
    }

    func testBuildRequestWithDataBody() {
        // Given
        let data = "Test".data(using: .utf8)
        let endpoint = RequestBuilderMock.requestWithBody(body: data as Any)
        // When
        let request = try? sut?.buildFromEndpoint(endpoint)
        // Then
        XCTAssertNotNil(request)
        XCTAssertNotNil(request?.httpBody)
    }

    func testBuildRequestWithURLParameters() {
        // Given
        let urlParams: Parameters = ["Stub": "Test"]
        let expectedResult = "Stub=Test"
        let endpoint = RequestBuilderMock.requestWithParameters(body: nil, url: urlParams)
        // When
        let request = try? sut?.buildFromEndpoint(endpoint)
        // Then
        XCTAssertNotNil(request)
        let url = request?.url
        XCTAssertNotNil(url)
        let query = URLComponents(url: url!, resolvingAgainstBaseURL: false)?.query
        XCTAssertEqual(query, expectedResult)
    }

    func testBuildRequestWithAdditionalHeader() {
        // Given
        let beforeHeaders: HttpHeaders = ["Stub": "Test"]
        let endpoint = RequestBuilderMock.requestWithParametersAndHeader(body: nil, url: nil, headers: beforeHeaders)
        // When
        let request = try? sut?.buildFromEndpoint(endpoint)
        // Then
        XCTAssertNotNil(request)
        let afterHeaders = request?.allHTTPHeaderFields
        XCTAssertEqual(beforeHeaders, afterHeaders)
    }

    func testBuildEndpointWithHeaders() {
        // Given
        let endpoint = RequestBuilderMock.request
        let expectedHeaders: HttpHeaders = ["StubHeader": "Stub", "Content-Type": "application/json"]
        // When
        let request = try? sut?.buildFromEndpoint(endpoint)
        // Then
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.allHTTPHeaderFields, expectedHeaders)
    }

    func testBuildRequestWithEncodableParameters() {
        // Given
        let stub = RequestBuilderEncodableMock(stub: "Stub")
        let endpoint = RequestBuilderMock.requestWithDecodableParameters(body: stub)
        let request = try? sut?.buildFromEndpoint(endpoint)
        XCTAssertNotNil(request)
        let body = request?.httpBody
        XCTAssertNotNil(body)
        // When
        let decodedStub: RequestBuilderEncodableMock? = try? JSONDecoder().decode(RequestBuilderEncodableMock.self, from: body!)
        // Then
        XCTAssertNotNil(decodedStub)
        XCTAssertEqual(stub.stub, decodedStub!.stub)
    }

    func testBuildUploadRequest() {
        // Given
        let bundle = Bundle.module
        let url = bundle.url(forResource: "test_file", withExtension: "txt")
        XCTAssertNotNil(url)
        let stubBody = MultipartBody(fileUrls: [url!])
        XCTAssertNotNil(stubBody)
        let endpoint = RequestBuilderMock.upload(body: stubBody)
        // When
        let request = try? sut?.buildFromEndpoint(endpoint)
        // Then
        XCTAssertNotNil(request?.httpBody)
    }

    func testBuildFormDataRequest() {
        // Given
        let formDataParams: Parameters = ["Stub": "Test"]
        let expectedResult = "Stub=Test"
        let endpoint = RequestBuilderMock.formDataRequest(body: formDataParams)
        // When
        let request = try? sut?.buildFromEndpoint(endpoint)
        // Then
        let body = request?.httpBody
        XCTAssertNotNil(body)
        let bodyString = String(data: body!, encoding: .utf8)
        XCTAssertEqual(bodyString, expectedResult)
    }
}
