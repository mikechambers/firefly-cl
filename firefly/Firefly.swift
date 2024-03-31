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
import ArgumentParser

@main
struct Firefly : AsyncParsableCommand {
	
	//IDs for environment variables for API keys
	static let fireflyClientIdToken : String = "FIREFLY_CLIENT_ID"
	static let fireflyClientSecretToken : String = "FIREFLY_CLIENT_SECRET"
	
	static var configuration = CommandConfiguration(
		abstract: "Command line wrapper to access the Adobe Firefly API.",
		discussion: """
		You can view complete API documentation at:
		https://developer.adobe.com/firefly-services/docs/firefly-api/

		Created by Mike Chambers
		https://github.com/mikechambers/firefly
		""",
		version: Global.version
	)


	@Option(name: .long, help: "Text prompt for image generation.")
	var prompt: String
	
	@Option(name: .long, help: "The model will avoid these words in the generated content.")
	var negativePrompt: String?
	
	@Option(help: "The directory that generated images will be written to.", completion: .directory)
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
	
	@Option(help: """
		Output file name. If only a single image is used, this will be the name of
		the generated image. If multiple images are generated, then this will be
		the base for the names.
	""")
	var filename: String?
	
	@Option(
		help: "Content type. Available options: \(ContentClass.allCases.map { $0.rawValue }.joined(separator: ", "))"
	)
	var contentClass: ContentClass?
	
	@Option(
		help: "Style strength. 1 to 100. Default: 60",
		transform: {
			guard let value = Int($0), value >= 1, value <= 100 else {
				throw ValidationError("Style strength must be between 1 and 100.")
			}
			return value
		}
	)
	var styleStrength: Int?

	
	@Option(
		help: "Adjusts the overall intensity of your photo's existing visual characteristics. 2 to 10. Default: 6",
		transform: {
			guard let value = Int($0), value >= 2, value <= 10 else {
				throw ValidationError("Visual intensity must be between 2 and 10.")
			}
			return value
		}
	)
	var visualIntensity: Int?

	
	@Option(
		parsing: .upToNextOption,
		help: "Style presets. Available options: \(ImageStylePreset.allCases.map { $0.rawValue }.joined(separator: ", "))."
	)
	var stylePresets: [ImageStylePreset] = []

	
	@Option(help: "Number of variations. 1 to 4. Default: 1",
			transform: {
				guard let value = Int($0), value >= 1, value <= 4 else {
					throw ValidationError("Variation count must be between 1 and 4.")
				}
				return value
			})
	var variationCount: Int?

	@Option(
		parsing: .upToNextOption,
		help: """
			Seeds. Array of seed(s) that will provide generation stability across \
			multiple API calls. E.g. You can use the same seed to generate a similar \
			image with different styles. If "--variationCount" is specified, the \
			number of elements in the array must be equal to "--variationCount".
		"""
	)
	var seeds: [Int32] = []
	
	@Option(help: """
	Locale string in the format of a hyphen-separated combination of ISO 639-1 language code and ISO 3166-1 region code, such as 'en-US'. \
	When a locale is set, the prompt will be debiased to generate more relevant content for that region. If not specified, the locale will \
	be auto-detected, based on the user's profile and Accept-Language header.
	""")
	var locale: String?
	
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
	
	@Option(
		help: "Aperture. Acceptable range: 1.2 to 22.",
		transform: {
			guard let value = Float($0), value >= 1.2, value <= 22 else {
				throw ValidationError("Aperture must be between 1.2 and 22.")
			}
			return value
		}
	)
	var aperture: Float?

	
	@Option(
		help: "Shutter Speed in seconds. Acceptable range: 0.0005 to 10.",
		transform: {
			guard let value = Float($0), value >= 0.0005, value <= 10 else {
				throw ValidationError("Shutter Speed must be between 0.0005 and 10.")
			}
			return value
		}
	)
	var shutterSpeed: Float?

	
	@Option(
		help: "Field of View (millimeters). Acceptable range: 14 to 300.",
		transform: {
			guard let value = Int($0), value >= 14, value <= 300 else {
				throw ValidationError("Field of View must be between 14 and 300 millimeters.")
			}
			return value
		}
	)
	var fieldOfView: Int?

	@Option(help:"Firefly Client Id. If not specified, the \(Firefly.fireflyClientIdToken) environment variable will be used if available.")
	var clientId:String?
	
	@Option(help:"Firefly Client Secret. If not specified, the \(Firefly.fireflyClientSecretToken) environment variable will be used if available.")
	var clientSecret:String?
	
	
	@Flag
	var verbose = false
	
	@Flag(help:"If included, will write out a json file for each generated image with info that can be used to regenerate it.")
	var writeSettings = false
	
	mutating func run() async throws {
		
		Global.verbose = verbose
		
		guard let clientId = clientId, let clientSecret = clientSecret else {
			throw ValidationError("Client ID and Client Secret must be provided.")
		}
		
		outputDir = (outputDir as NSString).expandingTildeInPath
		
		let authManager = AuthManager()
		
		do {
			try await authManager.initialize(fireflyClientId: clientId, fireflyClientSecret: clientSecret)
		} catch {
			Firefly.exit(withError:
							AppError.auth(
								details: ErrorDetails(level: .fatal,
													  message: "Error retrieving authentication tokens.",
													  error: error)
							)
			)
		}
		
		if !authManager.isValid {
			Firefly.exit(withError: AppError.auth(details: ErrorDetails(level: .fatal, message: "Invalid authentication tokens")))
		}
		
		let apiInterface  = FireflyApiInterface(
			fireflyClientId: clientId,
			authToken: authManager.token)
		
		
		var refImage:ReferenceImage? = nil
		if let referenceImage = referenceImage {
			
			let id:String?
			do {
				id = try await apiInterface.uploadReferenceImage(file: referenceImage)
			} catch {
				Firefly.exit(withError: AppError.api(
					details: ErrorDetails(level: .fatal,
					message: "Error uploading reference image.",
					error: error)
				))
			}
			
			if let id = id {
				refImage = ReferenceImage(id: id)
			}
			
		}
		
		
		var style:GenerateImageStyle? = nil
		
		if !stylePresets.isEmpty || refImage != nil {
			style = GenerateImageStyle(
				presets: stylePresets,
				strength: styleStrength, referenceImage: refImage)
		}
		
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
		
		let response:GenerateImageResponse
		do {
			response = try await apiInterface.generateImage(query: query)
		}  catch {
			Firefly.exit(withError: AppError.api(
				details: ErrorDetails(level: .fatal,
				message: "Error generating image.",
				error: error)))
		}
		
		let directoryUrl = URL(fileURLWithPath: outputDir, isDirectory: true)
		
		do {
			try FileManager.default.createDirectory(
				at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
		} catch {
			Firefly.exit(withError: AppError.file(
				details: ErrorDetails(
					level: .fatal,
					message: "Creating directory to save images. Check permissions.",
					error: error)
			))
		}
		
		
		let defaultFilename = "firefly-image.jpg"
		let baseFilename = filename ?? defaultFilename
		
		for (index, img) in response.outputs.enumerated() {
			
			
			let n = response.outputs.count > 1 ? "\(index)-\(img.seed)-\(baseFilename)" : baseFilename
			
			if let url = URL(string: img.image.presignedUrl) {
				
				if Global.verbose {
					print(img.image.presignedUrl)
				}
				
				do {
					//todo: can do these all at once
					try await downloadImage(from: url, to: directoryUrl, with: n)
				} catch {
					print("Error downloading image. Skipping. Error: \(error.localizedDescription)")
					continue
				}
			} else {
				print("Error creating image URL. Skipping. [\(img.image.presignedUrl)]")
				continue
			}
			
			
			if writeSettings {
				let o = ImageSettings(query: query, seed: img.seed, fileName: n)
				
				do {
					try await writeJSON(object: o, to: directoryUrl, with: "\(n).json")
				} catch {
					print("Error writing image settings. Skipping. Error : \(error.localizedDescription)")
					continue
				}
			}
			
		}
  }
	
	mutating func validate() throws {
		
		// Check if one dimension is provided and the other is not
		if (width == nil) != (height == nil) { // Equivalent to XOR operation
			throw ValidationError("Both width and height must be provided together.")
		}
		
		// Check if either clientId or clientSecret is set, but not both
		if (clientId == nil) != (clientSecret == nil) { // XOR check: true if one is nil and the other is not
			throw ValidationError("Both --clientId and --clientSecret must be provided together if one is provided.")
		}
		
		if clientId == nil && clientSecret == nil {
			let envClientId = ProcessInfo.processInfo.environment[Firefly.fireflyClientIdToken]
			let envClientSecret = ProcessInfo.processInfo.environment[Firefly.fireflyClientSecretToken]
			
			if let envClientId = envClientId, let envClientSecret = envClientSecret {
				clientId = envClientId
				clientSecret = envClientSecret
			}
		}

		// If still nil, use compiled-in secrets
		if clientId == nil && clientSecret == nil {
			clientId = Secrets.fireflyClientId
			clientSecret = Secrets.fireflyClientSecret
		}
		
		// Validate that clientId and clientSecret are not nil
		guard clientId != nil && clientSecret != nil else {
			throw ValidationError("Firefly Client ID and Firefly Client Secret must be set via command line, environment variable, or compiled into the app.")
		}
		
		// Check if one is provided and the other is not
		if (clientId == nil && clientSecret != nil) || (clientId != nil && clientSecret == nil) {
			throw ValidationError("Both --clientId and --clientSecret must be provided together.")
		}
		
		if prompt.count < 1 || prompt.count > 1024 {
			throw ValidationError("The prompt must be between 1 and 1024 characters in length.")
		}
		
		if let negativePrompt = negativePrompt, negativePrompt.count < 1 || negativePrompt.count > 1024 {
			throw ValidationError("The negative prompt must be between 1 and 1024 characters in length.")
		}
		
		// Validate seeds count against variationCount if it's specified
		if let variationCount = variationCount, !seeds.isEmpty {
			// Validate seeds count against variationCount
			guard seeds.count == variationCount else {
				throw ValidationError("The number of seeds (\(seeds.count)) must match the variation count (\(variationCount)).")
			}
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

struct ImageSettings : Codable {
	let query:GenerateImageQuery
	let seed:Int
	let fileName:String
}
