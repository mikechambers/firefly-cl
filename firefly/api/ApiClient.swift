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

//Semi-Generic wrapper for making HTTP calls
struct ApiClient {
	
	private var urlSession : URLSession
	
	//todo: could move this out of here and have it passed in
	let userAgent : String = "Firefly Command Line App"
	
	init(fireflyClientId:String? = nil, authToken:String? = nil) {
		let config : URLSessionConfiguration = URLSessionConfiguration.default
		
		config.httpCookieStorage = nil
		config.httpCookieAcceptPolicy = .never
		config.httpShouldSetCookies = false
		
		config.allowsCellularAccess = true
		config.timeoutIntervalForRequest = 30
		config.timeoutIntervalForResource = 30
		config.waitsForConnectivity = true
		
		
		var headers : [String: String] = [
			"User-Agent": userAgent
		]
		
		if let id = fireflyClientId {
			headers["X-API-Key"] = id
		}
		
		if let auth = authToken {
			headers["Authorization"] = auth
		}
		
		config.httpAdditionalHeaders = headers
		
		urlSession = URLSession(configuration: config)
	}
	
	func close() {
		urlSession.invalidateAndCancel()
	}
	
	
	//post url encoded name / value pairs
	func postUrlEncoded<T:Codable>(url:URL, data:[String:String]) async throws -> T {
		let urlRequest : URLRequest = try createUrlEncodedPostRequest(url:url, data: data)
		
		let out:T = try await call(urlRequest: urlRequest)
		
		return out
	}
	
	//POST json data
	func postJson<T:Codable>(url:URL, data:Codable) async throws -> T {
		let urlRequest : URLRequest = try createJsonPostRequest(url: url, data: data)
		
		let out:T = try await call(urlRequest: urlRequest)
		
		return out
	}
	
	//Post an image, with content type determined by file name extension
	func postImage<T:Codable>(url:URL, file:URL) async throws -> T {
		let urlRequest : URLRequest = try createImageUploadPostRequest(url:url, file:file)
		
		let out : T = try await call(urlRequest: urlRequest)
		
		return out
	}
 

	
	/*
	func postRawUrlEncoded(url:URL, data:[String:String]) async throws -> String {

		let urlRequest : URLRequest = try createUrlEncodedPostRequest(url:url, data: data)
		
		return try await retrieveString(urlRequest: urlRequest)
	}
	 */
	
	private func call<T:Codable>(urlRequest:URLRequest) async throws -> T {
		let body = try await retrieveString(urlRequest: urlRequest)
		
		let decoder:JSONDecoder = JSONDecoder()
		
		let jsonData = Data(body.utf8)
	
		let response:T
		do {
			response = try decoder.decode(T.self, from: jsonData)
		} catch {
			
			//Logger.apiClient.critical("\(urlRequest.url!.absoluteString) : \(error)")
			throw RemoteCallError.jsonParseFailed(
				details: ErrorDetails(
					level: .critical,
					message: "Error parsing JSON response from server",
					error: error),
				body: body, url:urlRequest.url!)
		}
		
		return response
	}
	
	
	//returns body from response as a string
	func retrieveString(urlRequest:URLRequest) async throws -> String {
		
		var data:Data
		var response : URLResponse
		do {
			(data, response) =  try await urlSession.data(for:urlRequest)
			
		} catch let error as URLError {
			
			throw RemoteCallError(
				urlError: error,
				level: .warning,
				message: "Error loading STRING from url", url: urlRequest.url
			)
		} catch {
			throw RemoteCallError.dataLoad(
				details: ErrorDetails(
					level: .warning,
					message: "Error loading STRING from url",
					error:error),
				url: urlRequest.url!)
		}
		
		let httpResponse = response as? HTTPURLResponse
		
		let body:String = String(decoding: data, as: UTF8.self)
		
		let statusCode = httpResponse?.statusCode
		if statusCode != 200 {
			
			if let status = statusCode {
				let s = FireflyAPIStatusResponseCode(rawValue: status)
				
				if s != .unknown {
					throw FireflyAPIError.errorStatusReturned(status: s)
				}
				
				var o = "unknown"
				if let statusCode {
					o = "\(statusCode)"
				}
				
				throw RemoteCallError.unexpectedStatusResponse(
					details: ErrorDetails(
						level: .warning,
						message: "Received non 200 status code : [\(o)]",
						error: nil),
					body: body, url: urlRequest.url!)
			}
		}
		
		return body
	}

	//determine image mimeType based on fie extension
	private func mimeType(for fileExtension: String) -> String {
		switch fileExtension.lowercased() {
		case "jpg", "jpeg":
			return "image/jpeg"
		case "png":
			return "image/png"
		case "webp":
			return "image/webp"
		default:
			return "application/octet-stream" // Generic binary data MIME type
		}
	}

	//create a URLRequest to upload specified file / image
	private func createImageUploadPostRequest(url: URL, file: URL) throws -> URLRequest {
		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = "POST"
		
		// Extract the file extension from the URL
		let fileExtension = file.pathExtension
		
		//If no extension, it returns an empty string, and the call below will
		//probably fail
		
		// Use the mimeType(for:) function to get the MIME type for the file extension
		let mimeTypeValue = mimeType(for: fileExtension)
		
		// Set the Content-Type header dynamically based on the file's MIME type
		urlRequest.setValue(mimeTypeValue, forHTTPHeaderField: "Content-Type")
		
		// Add image data
		let imageData = try Data(contentsOf: file)
		urlRequest.httpBody = imageData
		
		return urlRequest
	}


	//Create a URLRequest that posts JSON representation of the passed in object
	private func createJsonPostRequest(url:URL, data:Codable) throws -> URLRequest {
		var urlRequest:URLRequest = URLRequest(url:url)
		
		urlRequest.httpMethod = "POST"
		urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
		let encoder = JSONEncoder()
		
		do {
			let encoded = try encoder.encode(data)
			
			if Global.verbose {
				encoder.outputFormatting = .prettyPrinted
				if let jsonString = String(data: encoded, encoding: .utf8) {
					print(jsonString)
				}
			}
			
			urlRequest.httpBody = encoded
		} catch {
			throw AppError.encoding(
				details: ErrorDetails(
					level: .critical,
					message: "Error encoding post body parameters to JSON",
					error:error)
			)
		}
		
		return urlRequest
	}
	
	//Create a URL encoded post requests passing specified name / value pairs passed
	//in via the specified object
	private func createUrlEncodedPostRequest(url:URL, data:[String:String]) throws -> URLRequest {
		var urlRequest:URLRequest = URLRequest(url:url)
		
		urlRequest.httpMethod = "POST"
		urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		
		let encoded = createURLEncodedString(from: data)
		
		urlRequest.httpBody = encoded.data(using: .utf8)
		
		
		return urlRequest
	}
	
	private func createURLEncodedString(from data: [String: String]) -> String {
		let pairs = data.map { key, value in
			// Encode both the key and the value to escape characters that are not allowed in a URL
			let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
			let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
			return "\(encodedKey)=\(encodedValue)"
		}
		// Join the encoded pairs with & to form the final query string
		return pairs.joined(separator: "&")
	}
	
}
