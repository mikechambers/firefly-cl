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
	
	func uploadReferenceImage(file:URL) async throws -> String? {
		
		let url = createUrl(host: apiBase, path: "/v2/storage/image")

		let response : UploadReferenceImageResponse = try await apiClient.postImage(url:url, file:file)
		
		if response.images.isEmpty {
			return nil
		}
		
		return response.images[0].id
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
