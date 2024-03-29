//
//  FireflyApiInterface.swift
//  firefly
//
//  Created by Mike Chambers on 3/29/24.
//

import Foundation

class FireflyApiInterface {
	private var apiClient : ApiClient
	
	private var fireflyClientId:String
	
	private var authUrl : URL = URL(string: "https://ims-na1.adobelogin.com/ims/token/v3")!

	init(fireflyClientId:String) {
		
		self.fireflyClientId = fireflyClientId
		apiClient = ApiClient()
	}

	func close() {
		apiClient.close()
	}
	
	func retrieveAuthToken(fireflyClientSecret:String) async throws -> AuthResponse {
		
		let data = [
			"client_id": fireflyClientId,
			"client_secret" : fireflyClientSecret,
			"grant_type": "client_credentials",
			"scope": "openid,AdobeID,session,additional_info,read_organizations,firefly_api,ff_apis"
		]
		
		let response : AuthResponse  = try await apiClient.postUrlEncoded(url: authUrl, data: data)
		
		return response
	}
}
