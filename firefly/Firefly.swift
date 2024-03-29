//
//  Firefly.swift
//  firefly
//
//  Created by Mike Chambers on 3/28/24.
//

import Foundation

@main
struct Firefly {
	static func main() async throws {
		//print(Secrets.fireflyClientId)
		//print(Secrets.fireflyClientSecret)
		
		
		let authManager = AuthManager()
		try await authManager.initialize(fireflyClientId: Secrets.fireflyClientId)
		
		if !authManager.isValid {
			print("Could not retrieve auth tokens")
			exit(1)
			
		}
	  
		print(authManager.token ?? "No Token")
		print(authManager.expires ?? "No Expires Date")
	  
  }
}
