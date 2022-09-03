//
//  MockEndpoint.swift
//  NetworkLibraryTests
//
//  Created by Volodymyr Shyrochuk on 03.09.2022.
//

import Foundation
@testable import NetworkLibrary

enum MockEndpoint: EndPoint {
    case mock
    case mock2
    case badMock

    private var badParams: Parameters {
        let badValue: (String, String?) = ("stub", nil)
        return ["stub": badValue]
    }

    var path: String {
        return ""
    }

    var httpMethod: HttpMethod {
        return .get
    }

    var task: HttpTask {
        if self == .badMock {
            return .requestWithParameters(body: badParams, url: nil)
        }
        return .request()
    }

    var headers: HttpHeaders? {
        return nil
    }
}
