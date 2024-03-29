//
//  FireflyGenerateImageResponse.swift
//  firefly
//
//  Created by Mike Chambers on 3/29/24.
//

struct GenerateImageResponse : Codable{
	let version:String
	
	let size:ImageSize
	
	let outputs:[GenerateImageOutput]
}

struct GenerateImageOutput : Codable {
	let image:GeneratedImageInfo
	let seed:Int
}

struct GeneratedImageInfo : Codable {
	let presignedUrl:String
	let id: String
}

struct ImageSize : Codable {
	let width : UInt
	let height: UInt
}
