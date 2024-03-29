//
//  ApiClient.swift
//  firefly
//
//  Created by Mike Chambers on 3/28/24.
//

import Foundation

struct ApiClient {
	
	private var urlSession : URLSession
	
	init() {
		let config : URLSessionConfiguration = URLSessionConfiguration.default
		
		config.httpCookieStorage = nil
		config.httpCookieAcceptPolicy = .never
		config.httpShouldSetCookies = false
		
		config.allowsCellularAccess = true
		config.timeoutIntervalForRequest = 10
		config.timeoutIntervalForResource = 10
		config.waitsForConnectivity = true
		
		
		/*
		if sendApiKeyHeader {
			config.httpAdditionalHeaders = [
				"User-Agent": userAgent,
				"X-API-Key": destinyApiKeyStorage
			]
		}
		 */
		
		urlSession = URLSession(configuration: config)
	}
	
	func close() {
		urlSession.invalidateAndCancel()
	}
	
	
	func postUrlEncoded<T:Codable>(url:URL, data:[String:String]) async throws -> T {
		let urlRequest : URLRequest = try createUrlEncodedPostRequest(url:url, data: data)
		
		let out:T = try await call(urlRequest: urlRequest)
	
		return out
	}
	
	/*
	func postRawUrlEncoded(url:URL, data:[String:String]) async throws -> String {

		let urlRequest : URLRequest = try createUrlEncodedPostRequest(url:url, data: data)
		
		return try await retrieveString(urlRequest: urlRequest)
	}
	 */
	
	func call<T:Codable>(urlRequest:URLRequest) async throws -> T {
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
				
				throw RemoteCallError.unexpectedStatusResponse(
					details: ErrorDetails(
						level: .warning,
						message: "Received non 200 status code : [\(s)]",
						error: nil),
					body: body, url: urlRequest.url!)
			}
		}
		
		return body
	}
	
	private func createUrlEncodedPostRequest(url:URL, data:[String:String]) throws -> URLRequest {
		var urlRequest:URLRequest = URLRequest(url:url)
		
		urlRequest.httpMethod = "POST"
		
		let encoded = createURLEncodedString(from: data)
		
		urlRequest.httpBody = encoded.data(using: .utf8)
		urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		
		return urlRequest
	}
	
	func createURLEncodedString(from data: [String: String]) -> String {
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
