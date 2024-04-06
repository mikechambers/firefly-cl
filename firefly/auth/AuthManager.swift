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


//Used to manage, update and store Firefly API auth tokens
class AuthManager {
	
	private let authTokenKey = "AUTH_TOKEN"
	private let authExpiresKey = "AUTH_EXPIRES"
	private let clientIdKey = "CLIENT_ID_KEY"
	private let authBufferSeconds: TimeInterval = -3600
	
	private var _expires:Date?
	private var _token:String?
	
	//initialize tokens, either from storage, or from API
	func initialize(fireflyClientId:String, fireflyClientSecret:String) async throws  {
		let defaults = UserDefaults.standard
		
		
		var authToken = defaults.string(forKey: authTokenKey)
		var expiresDate = defaults.object(forKey: authExpiresKey) as? Date
		var clientId = defaults.string(forKey: clientIdKey)

		//check if we have a valid token, and it has not expired
		if let expiresDate = expiresDate, Date.now <= expiresDate,
		   let authToken = authToken, let clientId = clientId, clientId == fireflyClientId {
			// Token is valid and not expired
			_token = authToken
			_expires = expiresDate
		} else {
			
			//Need to get a new auth token
			
			let apiInterface = FireflyApiInterface(fireflyClientId: fireflyClientId)
			
			let response:AuthResponse
			do {
				response = try await apiInterface.retrieveAuthToken(fireflyClientSecret: fireflyClientSecret)
			} catch {
				
				//if we get here, we know tokens are not valid, so lets clear
				//them to be safe
				clear()
				throw error
			}
			
			authToken = response.access_token
			
			// Calculate the new expiration date based on the current time and the expiresIn value
			// Tokens are currently 24 hours and we expire aat 23 just so we don't get in a state where they expire
			// in the middle of calls
			expiresDate = Date.now.addingTimeInterval(TimeInterval(response.expires_in) + authBufferSeconds)
			
			// Save the new authToken and its expiration date to UserDefaults
			defaults.set(authToken, forKey: authTokenKey)
			defaults.set(expiresDate, forKey: authExpiresKey)
			defaults.set(fireflyClientId, forKey: clientIdKey)
		}

		_token = authToken
		_expires = expiresDate
		
		print(authToken)
	}
	
	//clear saved token / data
	func clear() {
		let defaults = UserDefaults.standard
		defaults.removeObject(forKey: authTokenKey)
		defaults.removeObject(forKey: authExpiresKey)
	}
	
	// Getter for expires property
	var expires: Date? {
		return _expires
	}
	
	// Getter for token property
	var token: String? {
		return _token
	}
	
	// Check if the token is valid
	var isValid: Bool {
		// Ensure token and expires are non-nil and expires is in the future
		if let _ = _token, let expires = _expires, Date.now < expires {
			return true
		} else {
			return false
		}
	}
}
