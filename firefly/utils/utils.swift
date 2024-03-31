/*
* Copyright (c) 2024 Mike Chambers
* https://github.com/mikechambers/firefly-cl
*
* MIT License
*
* Permission is hereby granted, free of charge, to any person obtaining a copy of
* this software and associated documentation files (the "Software"), to deal in
* the Software without restriction, including without limitation the rights to
* use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
* of the Software, and to permit persons to whom the Software is furnished to do
* so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
* FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
* IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

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
func writeJSON<T: Codable>(object: T, to directory: URL, with fileName: String) async throws {
	let encoder = JSONEncoder()

	encoder.outputFormatting = .prettyPrinted
	
	let data = try encoder.encode(object)
	
	let fileURL = directory.appendingPathComponent(fileName)
	try data.write(to: fileURL)
}

func createJSON<T: Codable>(object:T, pretty:Bool = true) throws -> String? {
	let encoder = JSONEncoder()
	
	if pretty {
		encoder.outputFormatting = .prettyPrinted
	}
	
	let encoded = try encoder.encode(object)
	
	if let jsonString = String(data: encoded, encoding: .utf8) {
		return jsonString
	}
	
	return nil
}
