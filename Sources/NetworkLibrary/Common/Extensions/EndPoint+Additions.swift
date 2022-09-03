//
//  EndPoint+Additions.swift
//  NetworkLibrary
//
//  Created by Volodymyr Shyrochuk on 03.09.2022.
//

import Foundation

public extension EndPoint {
    var defaultTimeout: TimeInterval {
        return 10.0
    }

    var timeout: TimeInterval {
        return defaultTimeout
    }
}
