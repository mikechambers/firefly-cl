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

//General app errors
enum AppError : FireflyAppError {
	
	//error encoding / decoding data. Usually JSON
	case encoding(details:ErrorDetails)
	
	//error with authentication
	case auth(details:ErrorDetails)
	
	//error working with file system
	case file(details:ErrorDetails)
	
	//error working with app
	case api(details:ErrorDetails)
	
	//general app error
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
