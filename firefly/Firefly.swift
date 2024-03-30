//
//  Firefly.swift
//  firefly
//
//  Created by Mike Chambers on 3/28/24.
//

import Foundation
import ArgumentParser

@main
struct Firefly : AsyncParsableCommand {
	
	@Option(name: .long, help: "The prompt to generate the image")
	var prompt: String
	
	@Option(help: "The output directory.", completion: .directory)
	var outputDir: String
	
	
	mutating func run() async throws {
		//print(Secrets.fireflyClientId)
		//print(Secrets.fireflyClientSecret)
		
		
		let authManager = AuthManager()
		try await authManager.initialize(fireflyClientId: Secrets.fireflyClientId)
		
		if !authManager.isValid {
			print("Could not retrieve auth tokens")
			Firefly.exit(withError: nil)
		}
	  
		
		let apiInterface : FireflyApiInterface = FireflyApiInterface(fireflyClientId: Secrets.fireflyClientId, authToken: authManager.token)
		
		let response : GenerateImageResponse = try await apiInterface.generateImage(prompt: prompt)
		
		
		let directoryUrl = URL(fileURLWithPath: outputDir, isDirectory: true)
		try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
		
		let fileName = "image.png"
		
		print(response.outputs[0].image.presignedUrl)
		
		let url = URL(string: response.outputs[0].image.presignedUrl)!
		try await downloadImage(from: url, to: directoryUrl, with: fileName)
		

		
		print("hi")

  }
	
	
}
func downloadImage(from url: URL, to directory: URL, with fileName: String) async throws {
	let (data, _) = try await URLSession.shared.data(from: url)
	
	let fileURL = directory.appendingPathComponent(fileName)
	try data.write(to: fileURL)
}
