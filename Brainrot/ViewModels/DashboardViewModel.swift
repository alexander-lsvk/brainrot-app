//
//  DashboardViewModel.swift
//  Brainrot
//
//  Created by Alexander Lisovyk on 16.11.25.
//

import Foundation
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var user: User?
    @Published var isVPNConnected = false
    @Published var downloadLimit: Int?
    @Published var uploadLimit: Int?
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""

    private let apiService = APIService.shared
    private let vpnManager = VPNManager.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Observe VPN connection status
        vpnManager.$isConnected
            .assign(to: &$isVPNConnected)
    }

    func loadUserData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Load user info
            let fetchedUser = try await apiService.getUserInfo()
            self.user = fetchedUser
            self.downloadLimit = fetchedUser.downloadLimit
            self.uploadLimit = fetchedUser.uploadLimit

        } catch {
            handleError(error)
        }
    }

    func toggleVPN() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await vpnManager.toggleConnection()
        } catch {
            handleError(error)
        }
    }

    func saveBandwidthLimits() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await apiService.updateBandwidth(
                upload: uploadLimit,
                download: downloadLimit
            )

            // Update local state with server response
            self.uploadLimit = response.uploadLimit
            self.downloadLimit = response.downloadLimit

            // Show success message (you might want to add a success alert)
            print("Bandwidth limits updated: \(response.message)")

        } catch {
            handleError(error)
        }
    }

    private func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            switch apiError {
            case .unauthorized:
                errorMessage = "Unauthorized. Please log in again."
            case .networkError(let error):
                errorMessage = "Network error: \(error.localizedDescription)"
            case .serverError(let message):
                errorMessage = "Server error: \(message)"
            case .decodingError:
                errorMessage = "Failed to decode server response"
            case .invalidURL:
                errorMessage = "Invalid URL"
            case .invalidResponse:
                errorMessage = "Invalid response from server"
            }
        } else if let vpnError = error as? VPNError {
            switch vpnError {
            case .noConfiguration:
                errorMessage = "VPN configuration not found"
            case .connectionFailed(let error):
                errorMessage = "VPN connection failed: \(error.localizedDescription)"
            case .saveFailed(let error):
                errorMessage = "Failed to save VPN configuration: \(error.localizedDescription)"
            }
        } else {
            errorMessage = error.localizedDescription
        }
        showError = true
    }
}
