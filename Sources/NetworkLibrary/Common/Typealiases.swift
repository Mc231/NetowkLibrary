//
//  Typealiases.swift
//  NetworkLibrary
//
//  Created by Volodymyr Shyrochuk on 03/09/22.
//  Copyright © 2022 Volodymyr Shyrochuk. All rights reserved.
//

import Foundation

public typealias HttpHeaders = [String: String]
public typealias Parameters = [String: Any]
public typealias NetworkRouterCompletion = (_ result: Result<Data,Error>) -> Swift.Void
public typealias NetworkRouterVoidCompletion = (_ result: Result<Void,Error>) -> Swift.Void
public typealias NetworkRouterCompletionWithResponse = (_ result: Result<Data,Error>,
    _ response: URLResponse?) -> Swift.Void

