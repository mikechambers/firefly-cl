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


//Errors making remote network calls
enum RemoteCallError : FireflyAppError {
	
	//Request timed out
	case timedOut(details:ErrorDetails, url:URL?)
	
	//error parsing JSON response
	case jsonParseFailed(details:ErrorDetails, body:String, url:URL)
	
	//unexpected status response
	case unexpectedStatusResponse(details:ErrorDetails, body:String, url:URL)
	
	//error loading data
	case dataLoad(details:ErrorDetails, url:URL)
	
	//error calling url
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
