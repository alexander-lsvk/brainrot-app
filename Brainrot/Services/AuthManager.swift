//
//  AuthManager.swift
//  Brainrot
//
//  Created by Alexander Lisovyk on 16.11.25.
//

import Foundation
import FirebaseAuth

struct BackendAuthCredentials: Codable {
    let username: String
    let password: String
}

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private let apiService = APIService.shared
    private var isAuthenticating = false

    init() {
        // Listen for auth state changes
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                if let user = user {
                    // User is signed in with Firebase
                    await self?.authenticateWithBackend(firebaseUser: user)
                } else {
                    self?.isAuthenticated = false
                }
            }
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signInAnonymously() async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await Auth.auth().signInAnonymously()
            print("Signed in anonymously with Firebase UID: \(result.user.uid)")

            // Auth state listener will handle backend authentication automatically

        } catch {
            errorMessage = "Failed to sign in: \(error.localizedDescription)"
            print("Error signing in anonymously: \(error)")
        }

        isLoading = false
    }

    private func authenticateWithBackend(firebaseUser: FirebaseAuth.User) async {
        // Prevent concurrent authentication attempts
        guard !isAuthenticating else {
            print("Authentication already in progress, skipping...")
            return
        }

        isAuthenticating = true
        defer { isAuthenticating = false }

        // Use Firebase UID as username and a hash of it as password
        let username = "user_\(firebaseUser.uid.prefix(12))"
        let password = firebaseUser.uid // Use full UID as password
        let email = "\(username)@brainrot.app" // Generated email

        // Try to login first
        do {
            let token = try await apiService.login(username: username, password: password)
            apiService.setToken(token)
            isAuthenticated = true
            print("Logged in to backend successfully")
        } catch {
            // If login fails, try to register
            print("Login failed, attempting registration...")
            do {
                let token = try await apiService.register(
                    email: email,
                    username: username,
                    password: password
                )
                apiService.setToken(token)
                isAuthenticated = true
                print("Registered and logged in to backend successfully")
            } catch {
                errorMessage = "Failed to authenticate with backend: \(error.localizedDescription)"
                print("Backend authentication failed: \(error)")
                isAuthenticated = false
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            apiService.setToken("")
        } catch {
            errorMessage = "Failed to sign out: \(error.localizedDescription)"
        }
    }

    var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }
}
