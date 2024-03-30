//
//  AuthManager.swift
//  firefly
//
//  Created by Mike Chambers on 3/29/24.
//

import Foundation


class AuthManager {
	
	private let authTokenKey = "AUTH_TOKEN"
	private let authExpiresKey = "AUTH_EXPIRES"
	private let authBufferSeconds: TimeInterval = -3600
	
	private var _expires:Date?
	private var _token:String?
	
	func initialize(fireflyClientId:String) async throws  {
		let defaults = UserDefaults.standard
		
		
		var authToken = defaults.string(forKey: authTokenKey)
		var expiresDate = defaults.object(forKey: authExpiresKey) as? Date

		// Check if the authToken is nil or if expiresDate is nil or if the current date is past the expiresDate
		if authToken == nil || expiresDate == nil || Date.now > expiresDate! {
			
			print("retrieving auth token")
			
			let apiInterface = FireflyApiInterface(fireflyClientId: Secrets.fireflyClientId)
			
			let response = try await apiInterface.retrieveAuthToken(fireflyClientSecret: Secrets.fireflyClientSecret)
			
			authToken = response.access_token
			
			// Calculate the new expiration date based on the current time and the expiresIn value
			expiresDate = Date.now.addingTimeInterval(TimeInterval(response.expires_in) + authBufferSeconds)
			
			// Save the new authToken and its expiration date to UserDefaults
			defaults.set(authToken, forKey: authTokenKey)
			defaults.set(expiresDate, forKey: authExpiresKey)
			
			//throw error if we can set
		}
		
		_token = authToken
		_expires = expiresDate
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