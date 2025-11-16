//
//  DashboardView.swift
//  Brainrot
//
//  Created by Alexander Lisovyk on 16.11.25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // VPN Status Card
                        VPNStatusCard(
                            isConnected: viewModel.isVPNConnected,
                            onToggle: {
                                Task {
                                    await viewModel.toggleVPN()
                                }
                            }
                        )

                        // User Info Card
                        if let user = viewModel.user {
                            UserInfoCard(user: user)
                        }

                        // Bandwidth Controls
                        BandwidthControlCard(
                            downloadSpeed: Binding(
                                get: { viewModel.downloadLimit ?? 0 },
                                set: { viewModel.downloadLimit = $0 == 0 ? nil : $0 }
                            ),
                            uploadSpeed: Binding(
                                get: { viewModel.uploadLimit ?? 0 },
                                set: { viewModel.uploadLimit = $0 == 0 ? nil : $0 }
                            ),
                            onSave: {
                                Task {
                                    await viewModel.saveBandwidthLimits()
                                }
                            }
                        )

                        if viewModel.isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Brainrot VPN")
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
        .task {
            await viewModel.loadUserData()
        }
    }
}

// MARK: - VPN Status Card
struct VPNStatusCard: View {
    let isConnected: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Connection Status Indicator
            Circle()
                .fill(isConnected ? Color.green : Color.red)
                .frame(width: 80, height: 80)
                .shadow(color: (isConnected ? Color.green : Color.red).opacity(0.5), radius: 20)
                .overlay(
                    Image(systemName: isConnected ? "checkmark.shield.fill" : "xmark.shield.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                )

            Text(isConnected ? "Connected" : "Disconnected")
                .font(.title2)
                .fontWeight(.bold)

            Button(action: onToggle) {
                Text(isConnected ? "Disconnect" : "Connect")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isConnected ? Color.red : Color.green)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}

// MARK: - User Info Card
struct UserInfoCard: View {
    let user: User

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account Info")
                .font(.headline)

            HStack {
                Label("Username", systemImage: "person.fill")
                Spacer()
                Text(user.username)
                    .foregroundColor(.secondary)
            }

            Divider()

            HStack {
                Label("IP Address", systemImage: "network")
                Spacer()
                Text(user.ipAddress)
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .monospaced))
            }

            Divider()

            HStack {
                Label("Email", systemImage: "envelope.fill")
                Spacer()
                Text(user.email)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}

// MARK: - Bandwidth Control Card
struct BandwidthControlCard: View {
    @Binding var downloadSpeed: Int
    @Binding var uploadSpeed: Int
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Bandwidth Limits")
                .font(.headline)

            // Download Speed
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Download", systemImage: "arrow.down.circle.fill")
                        .foregroundColor(.blue)
                    Spacer()
                    Text(downloadSpeed == 0 ? "Unlimited" : "\(downloadSpeed) Mbps")
                        .foregroundColor(.secondary)
                }

                Slider(value: Binding(
                    get: { Double(downloadSpeed) },
                    set: { downloadSpeed = Int($0) }
                ), in: 0...100, step: 1)
                .accentColor(.blue)
            }

            Divider()

            // Upload Speed
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Upload", systemImage: "arrow.up.circle.fill")
                        .foregroundColor(.green)
                    Spacer()
                    Text(uploadSpeed == 0 ? "Unlimited" : "\(uploadSpeed) Mbps")
                        .foregroundColor(.secondary)
                }

                Slider(value: Binding(
                    get: { Double(uploadSpeed) },
                    set: { uploadSpeed = Int($0) }
                ), in: 0...100, step: 1)
                .accentColor(.green)
            }

            Button(action: onSave) {
                Text("Save Bandwidth Settings")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }

            Text("Note: Upload limiting is client-side only. Download limits are enforced by the server.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}

#Preview {
    DashboardView()
}
