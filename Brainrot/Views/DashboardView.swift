//
//  DashboardView.swift
//  Brainrot
//
//  Created by Alexander Lisovyk on 16.11.25.
//

import SwiftUI
import DeviceActivity

// #if targetEnvironment(simulator)
// Import for mock data - only needed on simulator
// ActivityReport and AppActivity are defined in BrainrotActivityReport extension
struct ActivityReport {
    let totalDuration: TimeInterval
    let apps: [AppActivity]
}

struct AppActivity: Identifiable {
    let id = UUID()
    let displayName: String
    let bundleIdentifier: String
    let duration: TimeInterval
    let category: String
}
// #endif

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    
    @State private var showSubscriptionView = false
    
    private var filter: DeviceActivityFilter {
        DeviceActivityFilter(
            segment: .daily(during: Calendar.current.dateInterval(of: .day, for: Date())!),
            users: .all,
            devices: .init([.iPhone, .iPad])
        )
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    ZStack {
                        LinearGradient(colors: [.white, .green.opacity(0.3), .white, .white, .white], startPoint: .top, endPoint: .bottom)
                            .ignoresSafeArea()
                            .padding(.horizontal, -16)
                        
                        VStack(spacing: 24) {
                            // VPN Status Card
                            VPNStatusCard(
                                isConnected: viewModel.isVPNConnected,
                                showSubscriptionView: $showSubscriptionView,
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
                            //                        BandwidthControlCard(
                            //                            downloadSpeed: Binding(
                            //                                get: { viewModel.downloadLimit ?? 0 },
                            //                                set: { viewModel.downloadLimit = $0 == 0 ? nil : $0 }
                            //                            ),
                            //                            uploadSpeed: Binding(
                            //                                get: { viewModel.uploadLimit ?? 0 },
                            //                                set: { viewModel.uploadLimit = $0 == 0 ? nil : $0 }
                            //                            ),
                            //                            onSave: {
                            //                                Task {
                            //                                    await viewModel.saveBandwidthLimits()
                            //                                }
                            //                            }
                            //                        )
                            
                            //                        if viewModel.isLoading {
                            //                            ProgressView()
                            //                                .scaleEffect(1.5)
                            //                                .padding()
                            //                        }
                            
                            // Screen Time Section - Single UI, different data source
                            ScreenTimeSection()
                                .frame(height: 650)
                        }
                    }
                    .padding(16)
                }
                
                VStack {
                    LinearGradient(colors: [.white, .clear], startPoint: .top, endPoint: .bottom)
                        .frame(height: 50)
                    
                    Spacer()
                }
            }
            .scrollIndicators(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSubscriptionView.toggle()
                    } label: {
                        Text("HEAL ME!")
                            .foregroundStyle(.black)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .buttonStyle(
                        PressableButtonStyle(
                            foregroundColor: .yellow,
                            backgroundColor: .yellow.opacity(0.7),
                            cornerRadius: 16,
                            yOffset: 4
                        )
                    )
                    .frame(width: 100, height: 30)
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .fullScreenCover(isPresented: $showSubscriptionView) {
                SubscriptionView() {}
            }
        }
        .task {
            //            await viewModel.loadUserData()
            await screenTimeManager.checkAuthorization()
        }
    }
}

// MARK: - VPN Status Card
struct VPNStatusCard: View {
    let isConnected: Bool
    @Binding var showSubscriptionView: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Image("mascot")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .padding(.bottom, 32)
            
            Text(isConnected ? "Your brain is healing" : "Your brain needs a break")
                .foregroundStyle(.black)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .padding(.bottom, 4)
            
                 Text(isConnected ? "Doomscrolling is not that easy anymore hehe" : "Let’s make scrolling harder today")
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .padding(.bottom, 16)
            
            Button {
                onToggle()
            } label: {
                Text(!isConnected ? "Start Brain Healing" : "Back To Rotting")
                    .foregroundStyle(.white)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
            }
            .buttonStyle(
                PressableButtonStyle(
                    foregroundColor: !isConnected ? .green : .gray,
                    backgroundColor: !isConnected ? .green.opacity(0.7) : .gray.opacity(0.7),
                    cornerRadius: 16
                )
            )
            .frame(height: 60)
            .padding(.top, 16)
            
            Button {
                AlertWindowPresenter.shared.present(
                    InfoAlertOverlay(
                        title: "How It Works?",
                        message: """
                        Brainheal doesn’t block your apps - it gently slows them.
                        
                        Your brain reacts to fast, infinite content loops.
                        
                        Brainheal uses a private, on-device VPN to gently slow down apps that trigger endless scrolling.
                        
                        1️⃣ Your feed loads slower 
                        2️⃣ Your brain stops craving the next hit 
                        3️⃣ Dopamine spike weaker 
                        4️⃣ You regain control without forcing yourself
                        
                        Your important apps still works normally: chats, calls, browsing, work tools, payments, etc.
                        
                        ⚠️ We never inspect or store data.
                        """
                    )
                )
            } label: {
                Text("How It Works?")
                    .foregroundStyle(.gray)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .padding(.top, 8)
        }
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

// MARK: - Screen Time Section (Single UI, different data sources)
struct ScreenTimeSection: View {
#if !targetEnvironment(simulator)
    // DEVICE: Use real Screen Time manager
    @StateObject private var screenTimeManager = ScreenTimeManager.shared

    private var filter: DeviceActivityFilter {
        DeviceActivityFilter(
            segment: .daily(during: Calendar.current.dateInterval(of: .day, for: Date())!),
            users: .all,
            devices: .init([.iPhone, .iPad])
        )
    }

#endif

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
#if targetEnvironment(simulator)
            // SIMULATOR: Show mock data using the SAME shared UI component
            SharedScreenTimeView(activityReport: Self.mockData)
                .frame(height: 700)
#else
            // DEVICE: Show real DeviceActivityReport (authorization is handled in onboarding)
            DeviceActivityReport(.totalActivity, filter: filter)
                .frame(height: 650)
#endif
        }
    }
    
#if targetEnvironment(simulator)
    // Mock data - only compiled for simulator
    private static let mockData = ActivityReport(
        totalDuration: 18720, // 5h 12m
        apps: [
            AppActivity(displayName: "TikTok", bundleIdentifier: "com.zhiliaoapp.musically", duration: 7200, category: "Social Networking"),
            AppActivity(displayName: "Instagram", bundleIdentifier: "com.burbn.instagram", duration: 5400, category: "Social Networking"),
            AppActivity(displayName: "YouTube", bundleIdentifier: "com.google.ios.youtube", duration: 3600, category: "Entertainment"),
            AppActivity(displayName: "Safari", bundleIdentifier: "com.apple.mobilesafari", duration: 1800, category: "Productivity"),
            AppActivity(displayName: "WhatsApp", bundleIdentifier: "net.whatsapp.WhatsApp", duration: 720, category: "Communication"),
            AppActivity(displayName: "Twitter", bundleIdentifier: "com.atebits.Tweetie2", duration: 600, category: "Social Networking"),
            AppActivity(displayName: "Reddit", bundleIdentifier: "com.reddit.Reddit", duration: 540, category: "Social Networking"),
            AppActivity(displayName: "Spotify", bundleIdentifier: "com.spotify.client", duration: 480, category: "Entertainment"),
            AppActivity(displayName: "Netflix", bundleIdentifier: "com.netflix.Netflix", duration: 420, category: "Entertainment"),
            AppActivity(displayName: "Gmail", bundleIdentifier: "com.google.Gmail", duration: 360, category: "Productivity"),
            AppActivity(displayName: "Facebook", bundleIdentifier: "com.facebook.Facebook", duration: 300, category: "Social Networking"),
            AppActivity(displayName: "Snapchat", bundleIdentifier: "com.toyopagroup.picaboo", duration: 240, category: "Social Networking"),
            AppActivity(displayName: "Telegram", bundleIdentifier: "ph.telegra.Telegraph", duration: 180, category: "Communication"),
            AppActivity(displayName: "Chrome", bundleIdentifier: "com.google.chrome.ios", duration: 120, category: "Productivity"),
            AppActivity(displayName: "Maps", bundleIdentifier: "com.apple.Maps", duration: 90, category: "Navigation")
        ]
    )
#endif
}

// MARK: - Shared Screen Time View
// THIS IS THE SINGLE SOURCE OF TRUTH FOR THE UI
// Used by both simulator (directly) and device (via TotalActivityView in extension)
// When you edit this, you need to copy the changes to TotalActivityView.swift in BrainrotActivityReport
struct SharedScreenTimeView: View {
    let activityReport: ActivityReport

    // Mock improvement data (will be replaced with real logic later)
    private var averageScreenTime: TimeInterval {
        // Mock: average is 6 hours
        return 21600
    }
    
    private var improvementPercentage: Double {
        let diff = averageScreenTime - activityReport.totalDuration
        return (diff / averageScreenTime) * 100
    }
    
    private var improvementText: String {
        let percentage = abs(improvementPercentage)
        return String(format: "%.0f%%", percentage)
    }
    
    private var improvementIcon: String {
        improvementPercentage > 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill"
    }
    
    private var improvementColor: Color {
        improvementPercentage > 0 ? .green : .red
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Two Column Stats Card
            HStack(spacing: 12) {
                // Today's Total Column
                VStack(spacing: 4) {
                    Text("Today's Total")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(formatDuration(activityReport.totalDuration))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Very Bad")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                
                // Improvement Column
                VStack(spacing: 4) {
                    Text("Improvement")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: improvementIcon)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(improvementColor)
                        
                        Text(improvementText)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(improvementColor)
                    }
                    
                    Text("vs Avg")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(16)
            }
            .frame(height: 100)
            
            VStack(spacing: 0) {
                ForEach(activityReport.apps.prefix(10)) { app in
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            // App Info
                            VStack(alignment: .leading, spacing: 2) {
                                Text(app.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(app.category)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Usage Time
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(formatDuration(app.duration))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                // Progress bar
                                GeometryReader { geometry in
                                    let maxDuration = activityReport.apps.first?.duration ?? 1
                                    let percentage = app.duration / maxDuration
                                    
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 60, height: 3)
                                        
                                        Rectangle()
                                            .fill(iconColor(for: app.category))
                                            .frame(width: 60 * percentage, height: 3)
                                    }
                                }
                                .frame(width: 60, height: 3)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        if app.id != activityReport.apps.prefix(20).last?.id {
                            Divider()
                        }
                    }
                    .frame(height: 60)
                }
                
            }
            .frame(height: 600)
        }
    }
    
    private func iconColor(for category: String) -> Color {
        switch category.lowercased() {
        case let cat where cat.contains("social"):
            return .pink
        case let cat where cat.contains("entertainment"):
            return .red
        case let cat where cat.contains("productivity"):
            return .blue
        case let cat where cat.contains("communication"):
            return .green
        case let cat where cat.contains("creativity"):
            return .purple
        case let cat where cat.contains("reading"):
            return .orange
        case let cat where cat.contains("education"):
            return .indigo
        default:
            return .gray
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

#Preview {
    DashboardView()
}
