//
//  RootView.swift
//  Brainrot
//
//  Created by Alexander Lisovyk on 22.11.25.
//

import SwiftUI

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    @StateObject private var authManager = AuthManager()

    var body: some View {
        DashboardView()
            .fullScreenCover(isPresented: Binding(
                get: { !hasCompletedOnboarding },
                set: { hasCompletedOnboarding = !$0 }
            )) {
                OnboardingView()
            }
            .transaction { transaction in
                transaction.disablesAnimations = !hasCompletedOnboarding
            }
            .task {
                await authManager.signInAnonymously()
            }
    }
}
