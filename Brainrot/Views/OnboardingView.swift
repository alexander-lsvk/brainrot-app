//
//  OnboardingView.swift
//  Brainrot
//
//  Created by Alexander Lisovyk on 19.11.25.
//

import SwiftUI
import StoreKit

struct ReviewCard: View {
    let imageName: String
    let name: String
    let rating: Int
    let review: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.textPrimary)

                    Spacer()

                    HStack(spacing: 2) {
                        ForEach(0..<rating, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.yellow)
                        }
                    }
                }

                Text(review)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ChatBubble: View {
    let text: String
    var isFromMe: Bool = false

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }

    var body: some View {
        HStack {
            if isFromMe { Spacer() }

            HStack(alignment: .bottom, spacing: 8) {
                if isFromMe {
                    Text(timeString)
                        .font(.system(size: 11))
                        .foregroundStyle(.gray)
                }

                Text(text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(isFromMe ? .white : .textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(isFromMe ? Color.green : Color.gray.opacity(0.15))
                    .cornerRadius(20)

                if !isFromMe {
                    Text(timeString)
                        .font(.system(size: 11))
                        .foregroundStyle(.gray)
                }
            }

            if !isFromMe { Spacer() }
        }
    }
}

enum OnboardingStep: CaseIterable {
    case welcome
    case intro
    case howItWorks
    case rating
    case connectScreenTime
    case allowScreenTime
    case ups

    var previous: OnboardingStep? {
        let all = Self.allCases
        guard let index = all.firstIndex(of: self), index > 0 else { return nil }
        return all[all.index(before: index)]
    }

    var progress: CGFloat {
        let all = Self.allCases
        guard let index = all.firstIndex(of: self) else { return 0 }
        return CGFloat(index + 1) / CGFloat(all.count)
    }
}

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var screenTimeManager = ScreenTimeManager.shared

    @State private var currentStep: OnboardingStep = .welcome
    @State private var isAnimating = false
    @State private var visibleBenefits: Int = 0
    @State private var visibleMessages: Int = 0
    @State private var visibleTrickMessages: Int = 0
    
    @State private var showSubscriptionView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    switch currentStep {
                    case .welcome:
                        welcome()
                    case .intro:
                        intro()
                    case .howItWorks:
                        howItWorks()
                    case .rating:
                        rating()
                    case .connectScreenTime:
                        connectScreenTime()
                    case .allowScreenTime:
                        allowScreenTime()
                    case .ups:
                        ups()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if let previous = currentStep.previous {
                        Button {
                            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                            currentStep = previous
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.black)
                        }
                    }
                }

                ToolbarItem(placement: .principal) {
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: UIScreen.main.bounds.width/2, height: 3)

                        Rectangle()
                            .fill(.green)
                            .frame(width: UIScreen.main.bounds.width/2 * currentStep.progress, height: 3)
                            .animation(.easeInOut(duration: 1), value: currentStep)
                    }
                }
            }
            .fullScreenCover(isPresented: $showSubscriptionView) {
                SubscriptionView() {
                    dismiss()
                }
            }
        }
        .task {
            await screenTimeManager.checkAuthorization()
        }
    }
    
    private func welcome() -> some View {
        ZStack {
            VStack {
                Spacer()
                
                Image("mascot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                
                Text("Welcome to Brainheal!")
                    .foregroundStyle(.black)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 16)
                
                Text("It's time to **finally** regain\ncontrol of your **screen time**")
                    .foregroundStyle(.textSecondary)
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.center)

                Spacer()

                Button {
                    currentStep = .intro
                } label: {
                    Text("Continue")
                        .foregroundStyle(.white)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                }
                .buttonStyle(
                    PressableButtonStyle(
                        foregroundColor: .green,
                        backgroundColor: .green.opacity(0.7),
                        cornerRadius: 16
                    )
                )
                .frame(height: 60)
            }
        }
        .padding(16)
    }
    
    private func intro() -> some View {
        ZStack {
            VStack(spacing: 0) {
                Text("How it Works?")
                    .foregroundStyle(.black)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)
                
                Text("A smarter way to break the doomscroll loop")
                    .foregroundStyle(.black)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(Array(chatMessages.enumerated()), id: \.offset) { index, message in
                                ChatBubble(text: message.text, isFromMe: message.isFromMe)
                                    .opacity(visibleMessages > index ? 1 : 0)
                                    .offset(y: visibleMessages > index ? 0 : 20)
                                    .animation(.easeOut(duration: 0.3), value: visibleMessages)
                                    .id(index)
                                    .padding(.bottom, 8)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 16)
                    }
                    .scrollIndicators(.hidden)
                    .onChange(of: visibleMessages) { _, newValue in
                        withAnimation {
                            proxy.scrollTo(newValue - 1, anchor: .bottom)
                        }
                    }
                }
                
                Spacer()

                Button {
                    currentStep = .howItWorks
                } label: {
                    Text("How?")
                        .foregroundStyle(.white)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                }
                .buttonStyle(
                    PressableButtonStyle(
                        foregroundColor: .green,
                        backgroundColor: .green.opacity(0.7),
                        cornerRadius: 16
                    )
                )
                .frame(height: 60)
            }
        }
        .padding(16)
        .onAppear {
            visibleMessages = 0
            animateMessages()
        }
    }

    private let chatMessages: [(text: String, isFromMe: Bool)] = [
        ("🚫 You've tried blocking apps", false),
        ("😓 We know it doesn't work...", false),
        ("💬 You got a message → you unblock", false),
        ("👀 First video hits → 2 hours gone again", false),
        ("🤬 We've all been there...", true),
        ("🙅‍♂️ And unlike those blocking apps", true),
        ("🧠 We actually know how to fix it!", true)
    ]

    private func animateMessages() {
        for i in 0..<chatMessages.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.0) {
                visibleMessages = i + 1
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }

    private func howItWorks() -> some View {
        ZStack {
            VStack(spacing: 0) {
                Text("Our Trick")
                    .foregroundStyle(.black)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)
                
                Text("No blocking. No guilt. You just naturally quit")
                    .foregroundStyle(.black)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(Array(trickMessages.enumerated()), id: \.offset) { index, message in
                                ChatBubble(text: message.text, isFromMe: message.isFromMe)
                                    .opacity(visibleTrickMessages > index ? 1 : 0)
                                    .offset(y: visibleTrickMessages > index ? 0 : 20)
                                    .animation(.easeOut(duration: 0.3), value: visibleTrickMessages)
                                    .id(index)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 16)
                    }
                    .scrollIndicators(.hidden)
                    .onChange(of: visibleTrickMessages) { _, newValue in
                        withAnimation {
                            proxy.scrollTo(newValue - 1, anchor: .bottom)
                        }
                    }
                }
                
                Spacer()

                Button {
                    currentStep = .rating
                } label: {
                    Text("Quit Scrolling")
                        .foregroundStyle(.white)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                }
                .buttonStyle(
                    PressableButtonStyle(
                        foregroundColor: .green,
                        backgroundColor: .green.opacity(0.7),
                        cornerRadius: 16
                    )
                )
                .frame(height: 60)
            }
        }
        .padding(16)
        .onAppear {
            visibleTrickMessages = 0
            animateTrickMessages()
        }
    }

    private let trickMessages: [(text: String, isFromMe: Bool)] = [
        ("🌎 We use a private VPN profile to slow down your internet only for doomscrolling apps like TikTok, Instagram, Shorts, etc.", false),
        ("✅ Your chat apps, messaging, browsing and everything else → work normally.", false),
        ("Your feed loads…", false),
        ("Slow…", false),
        ("Like you're on an island with 1 bar of signal 🌴📶", false),
        ("And something amazing happens", true),
        ("You get bored. You give up", true),
        ("🧠 Your brain simply walks away from the trap 😌", true)
    ]

    private func animateTrickMessages() {
        for i in 0..<trickMessages.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.0) {
                visibleTrickMessages = i + 1
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }
    
    private func rating() -> some View {
        ZStack {
            VStack(spacing: 0) {
                Text("Give Us a Rating")
                    .foregroundStyle(.black)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text("⭐️ ⭐️ ⭐️ ⭐️ ⭐️")
                    .foregroundStyle(.black)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)
                
                Text("Brainheal was made for people like you")
                    .foregroundStyle(.black)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)
                
                HStack(spacing: -15) {
                    Image("review-1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))

                    Image("review-2")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))

                    Image("review-3")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
                .padding(.top, 16)
                
                Text("+10,000 Brainheal users")
                    .foregroundStyle(.textSecondary)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)

                VStack(spacing: 12) {
                    ReviewCard(
                        imageName: "review-4",
                        name: "Sarah M.",
                        rating: 5,
                        review: "The slow loading trick is genius. Instagram became so boring that I just naturally stopped opening it. Best decision ever!"
                    )

                    ReviewCard(
                        imageName: "review-5",
                        name: "Michael T.",
                        rating: 5,
                        review: "Finally broke my TikTok addiction! I was spending 4+ hours a day scrolling. Now I actually have time for something meaningful."
                    )
                }
                .padding(.top, 24)

                Spacer()

                Button {
                    currentStep = .connectScreenTime
                } label: {
                    Text("Continue")
                        .foregroundStyle(.white)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                }
                .buttonStyle(
                    PressableButtonStyle(
                        foregroundColor: .green,
                        backgroundColor: .green.opacity(0.7),
                        cornerRadius: 16
                    )
                )
                .frame(height: 60)
            }
        }
        .padding(16)
        .onAppear {
            requestAppStoreReview()
        }
    }
    
    private func connectScreenTime() -> some View {
        ZStack {
            VStack {
                HStack(spacing: -16) {
                    Image("icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .cornerRadius(16)
                        .rotationEffect(Angle(degrees: -15))
                    
                    Image("screen-time")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .cornerRadius(16)
                        .rotationEffect(Angle(degrees: 15))
                }
                .padding(.vertical, 64)
                
                Text("Connect Brainheal to\nScreen Time")
                    .foregroundStyle(.black)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)
                
                Text("Your data is **completely private** and never leaves your device.")
                    .foregroundStyle(.textSecondary)
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 4)

                Spacer()

                Button {
                    currentStep = .allowScreenTime
                } label: {
                    Text("Continue")
                        .foregroundStyle(.white)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                }
                .buttonStyle(
                    PressableButtonStyle(
                        foregroundColor: .green,
                        backgroundColor: .green.opacity(0.7),
                        cornerRadius: 16
                    )
                )
                .frame(height: 60)
            }
        }
        .padding(16)
    }

    private func allowScreenTime() -> some View {
        ZStack {
            VStack {
                Text("Connect Brainheal to\nScreen Time")
                    .foregroundStyle(.black)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 4)

                Spacer()

                Button {
                    currentStep = .ups
                } label: {
                    Text("Continue")
                        .foregroundStyle(.white)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                }
                .buttonStyle(
                    PressableButtonStyle(
                        foregroundColor: screenTimeManager.isAuthorized ? .green : .gray,
                        backgroundColor: screenTimeManager.isAuthorized ? .green.opacity(0.7) : .gray.opacity(0.7),
                        cornerRadius: 16
                    )
                )
                .frame(height: 60)
                .disabled(!screenTimeManager.isAuthorized)
            }

            Image("screen-time-access")
                .resizable()
                .scaledToFit()
                .frame(width: 270)
                .contentShape(Rectangle())
                .onTapGesture {
                    Task {
                        do {
                            try await screenTimeManager.requestAuthorization()
                        } catch {
                            print("Authorization failed: \(error)")
                        }
                    }
                }
                .overlay(alignment: .bottom) {
                    VStack(alignment: .center) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.textPrimary)

                        Text("Tap to Allow")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.textPrimary)
                    }
                    .offset(x: -70, y: isAnimating ? 45 : 55)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
                    .opacity(screenTimeManager.isAuthorized ? 0 : 1)
                }
                .onAppear {
                    isAnimating = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isAnimating = true
                    }
                }
        }
        .padding(16)
    }
    
    private func ups() -> some View {
        ZStack {
            VStack {
                Image("mascot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                
                Text("This week, Brainheal will\nhelp you:")
                    .foregroundStyle(.black)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 36)
                
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(benefits.enumerated()), id: \.offset) { index, benefit in
                        Text(benefit)
                            .opacity(visibleBenefits > index ? 1 : 0)
                            .offset(y: visibleBenefits > index ? 0 : 20)
                            .animation(.easeOut(duration: 0.4), value: visibleBenefits)
                    }
                }
                .foregroundStyle(.textPrimary)
                .font(.system(size: 18, weight: .regular, design: .rounded))

                Spacer()

                Button {
                    showSubscriptionView.toggle()
                } label: {
                    Text("Continue")
                        .foregroundStyle(.white)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                }
                .buttonStyle(
                    PressableButtonStyle(
                        foregroundColor: .green,
                        backgroundColor: .green.opacity(0.7),
                        cornerRadius: 16
                    )
                )
                .frame(height: 60)
            }
        }
        .padding(16)
        .onAppear {
            visibleBenefits = 0
            animateBenefits()
        }
    }

    private let benefits = [
        "📱  Regain control of your phone",
        "⏳  Save over 5 hours every day",
        "🧠  Improve your focus and mental clarity",
        "🌿  End dopamine overload, live happier"
    ]

    private func animateBenefits() {
        for i in 0..<benefits.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                visibleBenefits = i + 1
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            }
        }
    }

    private func requestAppStoreReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

#Preview {
    OnboardingView()
}
