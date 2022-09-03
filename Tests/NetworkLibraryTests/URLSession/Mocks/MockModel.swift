//
//  MockModel.swift
//  NetworkLibraryTests
//
//  Created by Volodymyr Shyrochuk on 03.09.2022.
//

import Foundation

// Fake models

struct MockModel: Codable, Equatable {
	let stub: String
}

struct MockModel2: Codable {
	let stub: Int
}
