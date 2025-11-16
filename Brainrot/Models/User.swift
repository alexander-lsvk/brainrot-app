//
//  User.swift
//  Brainrot
//
//  Created by Alexander Lisovyk on 16.11.25.
//

import Foundation

struct User: Codable {
    let username: String
    let email: String
    let ipAddress: String
    let createdAt: String
    let isActive: Bool
    let uploadLimit: Int?
    let downloadLimit: Int?

    enum CodingKeys: String, CodingKey {
        case username
        case email
        case ipAddress = "ip_address"
        case createdAt = "created_at"
        case isActive = "is_active"
        case uploadLimit = "upload_limit"
        case downloadLimit = "download_limit"
    }
}

struct VPNConfig: Codable {
    let config: String
    let qrCodeUrl: String?

    enum CodingKeys: String, CodingKey {
        case config
        case qrCodeUrl = "qr_code_url"
    }
}

struct BandwidthUpdate: Codable {
    let uploadLimit: Int?
    let downloadLimit: Int?

    enum CodingKeys: String, CodingKey {
        case uploadLimit = "upload_limit"
        case downloadLimit = "download_limit"
    }
}

struct BandwidthUpdateResponse: Codable {
    let message: String
    let uploadLimit: Int?
    let downloadLimit: Int?

    enum CodingKeys: String, CodingKey {
        case message
        case uploadLimit = "upload_limit"
        case downloadLimit = "download_limit"
    }
}
