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

enum FireflyAPIStatusResponseCode : Int, CaseIterable {
	case unknown = -1
	case badRequest = 400
	case unauthorized = 403
	case timeout = 408
	case payloadTooLarge = 413
	case unsupportedMediaType = 415
	case unprocessableEntity = 422
	case tooManyRequests = 429
	case unavailableForLegalReasons = 451
	
	init(rawValue: Int) {
		let temp: FireflyAPIStatusResponseCode? = FireflyAPIStatusResponseCode.allCases.first { $0.rawValue == rawValue }
		let out: FireflyAPIStatusResponseCode

		if let temp = temp {
			out = temp
		} else {
			out = .unknown
		}
		
		self = out
	}
}

enum FireflyAPIError : FireflyAppError {
	case errorStatusReturned(status:FireflyAPIStatusResponseCode)
	
	private var details: ErrorDetails {
		switch self {
		case .errorStatusReturned(let status):
			switch status {
			case .badRequest :
				return ErrorDetails(level: .critical, message: "Bad Request")
			case .unauthorized :
				return ErrorDetails(level: .critical, message: "Unauthorized")
			case .timeout :
				return ErrorDetails(level: .critical, message: "Timeout")
			case .payloadTooLarge :
				return ErrorDetails(level: .critical, message: "Payload too large")
			case .unsupportedMediaType :
				return ErrorDetails(level: .critical, message: "Unsupported Media Type")
			case .unprocessableEntity :
				return ErrorDetails(level: .critical, message: "Unprocessable Entity")
			case .tooManyRequests :
				return ErrorDetails(level: .critical, message: "Too Many Requests")
			case .unavailableForLegalReasons :
				return ErrorDetails(level: .critical, message: "Unavailable For Legal Reasons")
			case .unknown :
				return ErrorDetails(level: .critical, message: "Unknown")
			}
			
		}
	}
	
	var name: String {
		switch self {
		case .errorStatusReturned(let status):
			return "FireflyAPIError.errorStatusReturned(\(status))"
		}
	}
	
	var level: ErrorLevel {
		return details.level
	}
	
	var description: String {
		return details.message
	}
	
	var error: Error? {
		return details.error
	}
}
