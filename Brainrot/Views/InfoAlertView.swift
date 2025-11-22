//
//  InfoAlertView.swift
//  Brainrot
//
//  Created by Alexander Lisovyk on 19.11.25.
//

import SwiftUI
import UIKit

struct InfoAlertView: View {
    let title: String
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.leading)
            
            Text(message)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.leading)
                .lineSpacing(1)
            
            Divider()
                .padding(.horizontal, -24)
                .padding(.top, 8)
            
            Button(action: onDismiss) {
                Text("OK")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.textPrimary)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
            }
            .frame(maxWidth: .infinity)
        }
        .padding([.horizontal, .top], 24)
        .padding(.bottom, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 10)
        .padding(.horizontal, 32)
    }
}

struct InfoAlertOverlay: View {
    let title: String
    let message: String
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {}
            
            InfoAlertView(title: title, message: message) {
                AlertWindowPresenter.shared.dismiss()
            }
        }
        .transition(.opacity)
    }
}

final class AlertWindowPresenter {
    static let shared = AlertWindowPresenter()
    
    private var window: UIWindow?
    
    func present<Content: View>(_ view: Content) {
        let hosting = UIHostingController(rootView: view)
        hosting.modalPresentationStyle = .overFullScreen
        hosting.view.backgroundColor = .clear
        
        let windowScene = UIApplication.shared.connectedScenes
            .first { $0.activationState == .foregroundActive } as? UIWindowScene
        
        guard let scene = windowScene else { return }
        
        let newWindow = UIWindow(windowScene: scene)
        newWindow.rootViewController = hosting
        newWindow.windowLevel = .alert + 1
        newWindow.makeKeyAndVisible()
        
        self.window = newWindow
    }
    
    func dismiss() {
        window?.isHidden = true
        window = nil
    }
}


// MARK: - Preview

#Preview {
    ZStack {
        Color.white
        
        Button {
            AlertWindowPresenter.shared.present(
                InfoAlertOverlay(
                    title: "What is Glycemic Index (GI)?",
                    message: """
                    Glycemic Index ranks how quickly a food raises your blood sugar.
                    High-GI foods cause rapid spikes, while low-GI foods help keep energy steady and hunger in check — supporting weight loss and balanced health.
                        
                    Low: 0–55 ✅
                    Medium: 56–69 ⚠️
                    High: 70+ 🚫
                                        
                    Choosing low-GI foods helps reduce cravings and improve energy throughout the day.
                    """
                )
            )
        } label: {
            Image(systemName: "info.circle")
                .font(.system(size: 12, weight: .regular, design: .rounded))
        }
        .foregroundStyle(.secondary)
    }
}
