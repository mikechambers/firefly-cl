//
//  FireflyAPIError.swift
//  firefly
//
//  Created by Mike Chambers on 3/29/24.
//

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
