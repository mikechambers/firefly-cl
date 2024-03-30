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

func downloadImage(from url: URL, to directory: URL, with fileName: String) async throws {
	let (data, _) = try await URLSession.shared.data(from: url)
	
	let fileURL = directory.appendingPathComponent(fileName)
	try data.write(to: fileURL)
}
