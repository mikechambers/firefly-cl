//
//  Firefly.swift
//  firefly
//
//  Created by Mike Chambers on 3/28/24.
//

//Add reference image upload
//add passing in secret / key and reading from environment (args, env, built in)
//add settings saving
//create script that loads settings and write command line to call it again
//think about file naming
//look at options, docs, enforcing constraints
//better error handling and reporting


import Foundation
import ArgumentParser

@main
struct Firefly : AsyncParsableCommand {
	
	static var configuration = CommandConfiguration(abstract: "Command line wrapper to access the Adobe Firefly API")

	@Option(name: .long, help: "The prompt to generate the image")
	var prompt: String
	
	@Option(name: .long, help: "The model will avoid these words in the generated content.")
	var negativePrompt: String?
	
	@Option(help: "The output directory.", completion: .directory)
	var outputDir: String
	
	@Option(
		help: "Path to image to use as a style reference.",
		completion: .file(extensions: ["jpg", "jpeg", "png", "webp"]),
		transform: { input in
			let fileURL = URL(fileURLWithPath: input)
				guard FileManager.default.fileExists(atPath: fileURL.path) else {
					throw ValidationError("File does not exist at path: \(input)")
				}
				return fileURL
		}
		)
	var referenceImage: URL?
	
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
	
	@Option(
		parsing:.upToNextOption,
		help:"""
			Seeds. Array of seed(s) that will provide generation stability across \
			multiple API calls. E.g. You can use the same seed to generate a similar \
			image with different styles. If "--variationCount" is specified, the \
			number of elements in the array must be equal to "--variationCount".
		"""
	)
	var seeds:[Int32] = []
	
	@Option(help:"Locale")
	var locale:String?
	
	@Option(help: """
		Width of image used in combination with --height. Supported aspect ratios include \
		Square(1/1), Landscape(4/3), Portrait(3/4), Widescreen(16/9). Other aspect ratios \
		may generate skewed images.
		""")
	var width: Int?
	
	@Option(help: """
		Height of image used in combination with --height. Supported aspect ratios include \
		Square(1/1), Landscape(4/3), Portrait(3/4), Widescreen(16/9). Other aspect ratios \
		may generate skewed images.
		""")
	var height: Int?
	
	@Option(help:"Aperature")
	var aperture:Float?
	
	@Option(help:"Shutter Speed")
	var shutterSpeed:Float?
	
	@Option(help:"Field of View")
	var fieldOfView:Int?
	
	@Flag
	var verbose = false
	
	
	mutating func run() async throws {

		//todo: check for environment variables, or keys passed in
		
		Global.verbose = verbose
		
		let authManager = AuthManager()
		try await authManager.initialize(fireflyClientId: Secrets.fireflyClientId)
		
		if !authManager.isValid {
			print("Could not retrieve auth tokens")
			Firefly.exit(withError: nil)
		}
	  
		let apiInterface  = FireflyApiInterface(
			fireflyClientId: Secrets.fireflyClientId,
			authToken: authManager.token)
		
		
		if let referenceImage = referenceImage {
			try await apiInterface.uploadReferenceImage(file: referenceImage)
		}
		
		
		var style:GenerateImageStyle? = nil
		
		if !stylePresets.isEmpty {
			style = GenerateImageStyle(presets: stylePresets, strength: styleStrength)
		}
		
		//todo: check variations and seeds are the same
		
		let size = determineImageSize(width: width, height: height)
		let photoSettings = createPhotoSettings(
			aperture: aperture,
			shutterSpeed: shutterSpeed,
			fieldOfView: fieldOfView)
		
		let query = GenerateImageQuery(
			prompt:prompt,
			negativePrompt: negativePrompt,
			contentClass: contentClass,
			n:variationCount,
			size: size,
			seeds: seeds.isEmpty ? nil : seeds,
			locale: locale,
			visualIntensity: visualIntensity,
			styles: style,
			photoSettings: photoSettings
		)
		
		let response : GenerateImageResponse = try await apiInterface.generateImage(query: query)
		
		
		let directoryUrl = URL(fileURLWithPath: outputDir, isDirectory: true)
		try FileManager.default.createDirectory(
			at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
		
		
		let defaultFilename = "firefly-image.png"
		let baseFilename = filename ?? defaultFilename
		

		for (index, img) in response.outputs.enumerated() {
			let url = URL(string: img.image.presignedUrl)!
			
			
			let n = response.outputs.count > 1 ? "\(index)-\(img.seed)-\(baseFilename)" : baseFilename
			
			print(img.seed)
			//todo: can do these all at once
			try await downloadImage(from: url, to: directoryUrl, with: n)
		}
  }
	
}

func determineImageSize(width: Int?, height: Int?) -> ImageSize? {
	switch (width, height) {
	case let (w?, h?):
		// Both width and height are provided
		return ImageSize(width: w, height: h)
	case let (w?, nil):
		// Only width is provided, set height equal to width
		return ImageSize(width: w, height: w)
	case let (nil, h?):
		// Only height is provided, set width equal to height
		return ImageSize(width: h, height: h)
	default:
		// Neither width nor height is provided
		return nil
	}
}

func createPhotoSettings(aperture: Float?, shutterSpeed: Float?, fieldOfView: Int?) -> PhotoSettings? {
	if aperture != nil || shutterSpeed != nil || fieldOfView != nil {
		return PhotoSettings(aperture: aperture, shutterSpeed: shutterSpeed, fieldOfView: fieldOfView)
	} else {
		return nil
	}
}
