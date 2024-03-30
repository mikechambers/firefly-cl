//
//  UploadReferenceImageResponse.swift
//  firefly
//
//  Created by Mike Chambers on 3/30/24.
//

import Foundation


struct UploadReferenceImageResponse : Codable {
	let images : [UploadInfo]
}

struct UploadInfo : Codable {
	let id : String
}
