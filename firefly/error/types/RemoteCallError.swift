

import Foundation

enum RemoteCallError : FireflyAppError {
	case timedOut(details:ErrorDetails, url:URL?)
	case jsonParseFailed(details:ErrorDetails, body:String, url:URL)
	case unexpectedStatusResponse(details:ErrorDetails, body:String, url:URL)
	case dataLoad(details:ErrorDetails, url:URL)
	case urlError(details:ErrorDetails, url:URL?)

	init(urlError:URLError, level:ErrorLevel, message:String, url:URL? = nil) {
		
		let out:RemoteCallError
		
		if urlError.code == .timedOut {
			out = RemoteCallError.timedOut(
				details: ErrorDetails(
					level: level, message: message, error: urlError)
				, url: url)
			
		} else {
			out =  RemoteCallError.urlError(
				details: ErrorDetails(
					level: level, message: message, error: urlError)
				, url: url)
		}
		
		self = out
		
	}
	
	private var details: ErrorDetails {
		switch self {
		case .timedOut(let details, _):
			return details
		case .jsonParseFailed(let details, _, _):
			return details
		case .unexpectedStatusResponse(let details, _, _):
			return details
		case .dataLoad(let details, _):
			return details
		case .urlError(let details, _):
			return details
		}
	}
	
	var name: String {
		switch self {
		case .timedOut(_, _):
			return "RemoteCallError.timedOut"
		case .jsonParseFailed(_, _, _):
			return "RemoteCallError.jsonParseFailed"
		case .unexpectedStatusResponse(_, _, _):
			return "RemoteCallError.unexpectedStatusResponse"
		case .dataLoad(_, _):
			return "RemoteCallError.dataLoad"
		case .urlError(_, _):
			return "RemoteCallError.urlError"
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
