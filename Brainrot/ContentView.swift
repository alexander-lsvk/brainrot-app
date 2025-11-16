//
//  ContentView.swift
//  Brainrot
//
//  Created by Alexander Lisovyk on 16.11.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager()

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                DashboardView()
            } else {
                LoadingView(authManager: authManager)
            }
        }
    }
}

struct LoadingView: View {
    @ObservedObject var authManager: AuthManager

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundColor(.white)

                Text("Brainrot VPN")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                if authManager.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                } else {
                    Button(action: {
                        Task {
                            await authManager.signInAnonymously()
                        }
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 40)
                    }
                }

                if let error = authManager.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
        }
        .task {
            // Try to sign in automatically if not authenticated
            if !authManager.isAuthenticated {
                await authManager.signInAnonymously()
            }
        }
    }
}

#Preview {
    ContentView()
}
