//
//  APIService.swift
//  Brainrot
//
//  Created by Alexander Lisovyk on 16.11.25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case serverError(String)
    case unauthorized
}

class APIService {
    static let shared = APIService()

    private let baseURL = "https://web-production-6dd4b.up.railway.app"
    private var token: String?

    private init() {}

    func setToken(_ token: String) {
        self.token = token
    }

    // MARK: - Authentication
    func register(email: String, username: String, password: String) async throws -> String {
        let url = URL(string: "\(baseURL)/api/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email, "username": username, "password": password]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError("Status code: \(httpResponse.statusCode)")
        }

        struct AuthResponse: Codable {
            let accessToken: String
            let tokenType: String
            enum CodingKeys: String, CodingKey {
                case accessToken = "access_token"
                case tokenType = "token_type"
            }
        }

        do {
            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            return authResponse.accessToken
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func login(username: String, password: String) async throws -> String {
        let url = URL(string: "\(baseURL)/api/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["username": username, "password": password]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError("Status code: \(httpResponse.statusCode)")
        }

        struct AuthResponse: Codable {
            let accessToken: String
            let tokenType: String
            enum CodingKeys: String, CodingKey {
                case accessToken = "access_token"
                case tokenType = "token_type"
            }
        }

        do {
            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            return authResponse.accessToken
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // MARK: - User Info
    func getUserInfo() async throws -> User {
        guard let token = token else {
            throw APIError.unauthorized
        }

        let url = URL(string: "\(baseURL)/api/user/me")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError("Status code: \(httpResponse.statusCode)")
        }

        do {
            let user = try JSONDecoder().decode(User.self, from: data)
            return user
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // MARK: - VPN Config
    func getVPNConfig() async throws -> VPNConfig {
        guard let token = token else {
            throw APIError.unauthorized
        }

        let url = URL(string: "\(baseURL)/api/vpn/config")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError("Status code: \(httpResponse.statusCode)")
        }

        do {
            let config = try JSONDecoder().decode(VPNConfig.self, from: data)
            return config
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // MARK: - Bandwidth Control
    func updateBandwidth(upload: Int?, download: Int?) async throws -> BandwidthUpdateResponse {
        guard let token = token else {
            throw APIError.unauthorized
        }

        let url = URL(string: "\(baseURL)/api/user/bandwidth")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let bandwidthUpdate = BandwidthUpdate(uploadLimit: upload, downloadLimit: download)
        request.httpBody = try JSONEncoder().encode(bandwidthUpdate)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError("Status code: \(httpResponse.statusCode)")
        }

        do {
            let result = try JSONDecoder().decode(BandwidthUpdateResponse.self, from: data)
            return result
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
