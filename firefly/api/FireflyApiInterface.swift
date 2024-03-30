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
	private var authToken:String?
	
	private let authUrl : URL = URL(string: "https://ims-na1.adobelogin.com/ims/token/v3")!
	private let apiBase : String = "firefly-api.adobe.io"

	init(fireflyClientId:String, authToken:String? = nil) {
		
		self.fireflyClientId = fireflyClientId
		self.authToken = authToken
		
		apiClient = ApiClient(fireflyClientId: fireflyClientId, authToken:authToken)
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
	
	
	
	
	
	func generateImage(query:GenerateImageQuery) async throws -> GenerateImageResponse {
		let url = createUrl(host: apiBase, path: "/v2/images/generate")
	
		let response : GenerateImageResponse = try await apiClient.postJson(url: url, data: query)
		
		return response
	}
}

func createUrl(host:String, path:String) -> URL {
	var components : URLComponents = URLComponents()
	components.path = path
	components.host = host
	components.scheme = "https"
	
	return components.url!
}
