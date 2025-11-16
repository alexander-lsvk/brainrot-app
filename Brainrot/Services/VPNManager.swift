//
//  VPNManager.swift
//  Brainrot
//
//  Created by Alexander Lisovyk on 16.11.25.
//

import Foundation
import NetworkExtension

enum VPNError: Error {
    case noConfiguration
    case connectionFailed(Error)
    case saveFailed(Error)
}

@MainActor
class VPNManager: ObservableObject {
    static let shared = VPNManager()

    @Published var isConnected = false
    @Published var connectionStatus: NEVPNStatus = .disconnected

    private var tunnelManager: NETunnelProviderManager?
    private let apiService = APIService.shared

    // Bundle identifier for the Network Extension target
    private let tunnelBundleIdentifier = "com.app.Brainrot.BrainrotVPN"

    private init() {
        // Observe VPN status changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(vpnStatusDidChange),
            name: .NEVPNStatusDidChange,
            object: nil
        )

        Task {
            await loadTunnelManager()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func vpnStatusDidChange() {
        Task { @MainActor in
            await updateConnectionStatus()
        }
    }

    private func updateConnectionStatus() async {
        guard let tunnelManager = tunnelManager,
              let session = tunnelManager.connection as? NETunnelProviderSession else {
            connectionStatus = .disconnected
            isConnected = false
            return
        }

        connectionStatus = session.status
        isConnected = session.status == .connected
    }

    private func loadTunnelManager() async {
        do {
            let managers = try await NETunnelProviderManager.loadAllFromPreferences()
            tunnelManager = managers.first
            await updateConnectionStatus()
            print("Loaded existing tunnel manager")
        } catch {
            print("Error loading tunnel managers: \(error)")
        }
    }

    func connect() async throws {
        print("Attempting to connect to VPN...")

        // Get the VPN config from backend
        let vpnConfig = try await apiService.getVPNConfig()

        // Load or create tunnel manager
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()
        let preExistingTunnelManager = managers.first
        let tunnelManager = preExistingTunnelManager ?? NETunnelProviderManager()

        // Configure the tunnel
        let protocolConfiguration = NETunnelProviderProtocol()
        protocolConfiguration.providerBundleIdentifier = tunnelBundleIdentifier
        protocolConfiguration.serverAddress = "Brainrot VPN"

        // Pass the WireGuard config to the tunnel extension
        protocolConfiguration.providerConfiguration = [
            "wgQuickConfig": vpnConfig.config
        ]

        tunnelManager.protocolConfiguration = protocolConfiguration
        tunnelManager.isEnabled = true
        tunnelManager.localizedDescription = "Brainrot VPN"

        // Save to preferences
        try await tunnelManager.saveToPreferences()
        print("Tunnel configuration saved")

        // Reload to get a valid instance
        try await tunnelManager.loadFromPreferences()
        print("Tunnel configuration reloaded")

        // Store reference
        self.tunnelManager = tunnelManager

        // Start the tunnel
        guard let session = tunnelManager.connection as? NETunnelProviderSession else {
            throw VPNError.noConfiguration
        }

        do {
            try session.startTunnel()
            print("Tunnel start requested")
        } catch {
            print("Error starting tunnel: \(error)")
            throw VPNError.connectionFailed(error)
        }
    }

    func disconnect() async {
        print("Attempting to disconnect VPN...")

        do {
            let managers = try await NETunnelProviderManager.loadAllFromPreferences()
            guard let tunnelManager = managers.first,
                  let session = tunnelManager.connection as? NETunnelProviderSession else {
                print("No tunnel manager found")
                return
            }

            switch session.status {
            case .connected, .connecting, .reasserting:
                print("Stopping the tunnel")
                session.stopTunnel()
            default:
                print("Tunnel is not in a state that can be stopped: \(session.status)")
            }
        } catch {
            print("Error disconnecting: \(error)")
        }
    }

    func toggleConnection() async throws {
        if isConnected {
            await disconnect()
        } else {
            try await connect()
        }
    }
}
