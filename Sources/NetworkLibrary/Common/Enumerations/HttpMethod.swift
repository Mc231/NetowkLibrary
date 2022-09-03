//
//  HttpMethod.swift
//  NetworkLibrary
//
//  Created by Volodymyr Shyrochuk on 03/09/22.
//  Copyright © 2022 Volodymyr Shyrochuk. All rights reserved.
//

import Foundation

/**
 Possible http methods
 */
public enum HttpMethod: String, Encodable {
    case get
    case post
    case put
    case path
    case delete
}
