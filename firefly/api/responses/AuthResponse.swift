//
//  AuthToken.swift
//  firefly
//
//  Created by Mike Chambers on 3/29/24.
//

import Foundation

struct AuthResponse : Codable {
	var access_token:String
	var expires_in:UInt32
}
