//
//  utils.swift
//  firefly
//
//  Created by Mike Chambers on 3/28/24.
//

import Foundation

func getEnvironmentVar(_ name: String) -> String? {
	guard let rawValue = getenv(name) else { return nil }
	return String(utf8String: rawValue)
}
