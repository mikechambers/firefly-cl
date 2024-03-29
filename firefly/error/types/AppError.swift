

import Foundation

enum AppError : FireflyAppError {
	case encoding(details:ErrorDetails)

	
	private var details: ErrorDetails {
		switch self {

		case .encoding(let details):
			return details

		}
	}
	
	var name: String {
		switch self {

		case .encoding(_):
			return "AppError.encoding"
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
