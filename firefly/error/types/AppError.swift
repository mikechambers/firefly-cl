

import Foundation

enum AppError : FireflyAppError {
	case encoding(details:ErrorDetails)
	case auth(details:ErrorDetails)
	case file(details:ErrorDetails)
	case api(details:ErrorDetails)
	case app(details:ErrorDetails)

	
	private var details: ErrorDetails {
		switch self {

		case .encoding(let details):
			return details
		case .auth(let details):
			return details
		case .file(let details):
			return details
		case .api(let details):
			return details

		case .app(let details):
			return details
		}
	}
	
	var name: String {
		switch self {

		case .encoding(_):
			return "AppError.encoding"
		case .auth(_):
			return "AppError.auth"
		case .file(_):
			return "AppError.file"
		case .api(_):
			return "AppError.api"
		case .app(_):
			return "AppError.api"
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
