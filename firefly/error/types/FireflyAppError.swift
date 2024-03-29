

import Foundation

enum ErrorLevel {
	//Some odd state we will log
	case information
	
	//visual indicator that something happened but no error
	case warning
	
	//probably indicates a bug
	case critical
	
	//present dialog to use
	case fatal
	
	case unknown
}

protocol FireflyAppError : Error {
	var level : ErrorLevel { get }
	var description: String { get }
	var error: Error? { get }
	var name: String { get }
}

struct ErrorDetails {
	var level: ErrorLevel
	var message: String
	var error: Error?
}
