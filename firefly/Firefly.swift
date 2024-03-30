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
	
	@Option(name: .long, help: "The model will avoid these words in the generated content.")
	var negativePrompt: String?
	
	@Option(help: "The output directory.", completion: .directory)
	var outputDir: String
	
	@Option(help: "Filename.")
	var filename: String?
	
	@Option(help: "Content type. [photo, art]")
	var contentClass:ContentClass?
	
	@Option(help:"Number of variations. 1 to 4. Default: 1")
	var variationCount:Int?
	
	//todo: can we validate
	@Option(help:"Style strength. 1 to 100. Default: 60")
	var styleStrength:Int?
	
	@Option(help:"Adjusts the overall intensity of your photo's existing visual characteristics. 2 to 10. Default: 6")
	var visualIntensity:Int?
	
	@Option(
		parsing:.upToNextOption,
		help:"Style presets. Complete list at https://developer.adobe.com/firefly-services/docs/firefly-api/guides/concepts/styles/")
	var stylePresets:[ImageStylePreset] = []
	
	mutating func run() async throws {

		//todo: check for environment variables, or keys passed in
		
		let authManager = AuthManager()
		try await authManager.initialize(fireflyClientId: Secrets.fireflyClientId)
		
		if !authManager.isValid {
			print("Could not retrieve auth tokens")
			Firefly.exit(withError: nil)
		}
	  
		
		let apiInterface : FireflyApiInterface = FireflyApiInterface(fireflyClientId: Secrets.fireflyClientId, authToken: authManager.token)
		
		var style:GenerateImageStyle? = nil
		
		if !stylePresets.isEmpty {
			style = GenerateImageStyle(presets: stylePresets, strength: styleStrength)
		}
		
		let query = GenerateImageQuery(prompt:prompt, negativePrompt: negativePrompt, contentClass: contentClass, n:variationCount, visualIntensity: visualIntensity, styles: style )
		
		let response : GenerateImageResponse = try await apiInterface.generateImage(query: query)
		
		
		let directoryUrl = URL(fileURLWithPath: outputDir, isDirectory: true)
		try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
		
		
		let defaultFilename = "firefly-image.png"
		let baseFilename = filename ?? defaultFilename
		

		for (index, img) in response.outputs.enumerated() {
			let url = URL(string: img.image.presignedUrl)!
			
			let n = index > 0 ? "\(index)-\(baseFilename)" : baseFilename
			
			//todo: can do these all at once
			try await downloadImage(from: url, to: directoryUrl, with: n)
		}
  }
	
}
func downloadImage(from url: URL, to directory: URL, with fileName: String) async throws {
	let (data, _) = try await URLSession.shared.data(from: url)
	
	let fileURL = directory.appendingPathComponent(fileName)
	try data.write(to: fileURL)
}
