//
//  Parameters+Additions.swift
//  NetworkLibrary
//
//  Created by Volodymyr Shyrochuk on 03.09.2022.
//

import Foundation

public extension Parameters {
	
	/// Convert parameters to query items
	var asQueryItems: [URLQueryItem] {
		return reduce(into: [URLQueryItem]()) { (result, iteration) in
			let item = URLQueryItem(name: iteration.key, value: "\(iteration.value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
			result.append(item)
		}
	}
}
