//
//  DashboardView.swift
//  Brainrot
//
//  Created by Alexander Lisovyk on 16.11.25.
//

import SwiftUI
import DeviceActivity
import ManagedSettings

// #if targetEnvironment(simulator)
// Import for mock data - only needed on simulator
// ActivityReport and AppActivity are defined in BrainrotActivityReport extension
struct ActivityReport {
    let totalDuration: TimeInterval
    let apps: [AppActivity]
    let historicalAverages: HistoricalAverages?
}

struct HistoricalAverages: Codable {
    let yesterday: TimeInterval
    let lastWeek: TimeInterval
    let lastMonth: TimeInterval
}

struct AppActivity: Identifiable {
    let id = UUID()
    let displayName: String
    let bundleIdentifier: String
    let duration: TimeInterval
    let category: String
    let token: ApplicationToken?
}
// #endif

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    @StateObject private var productsService = ProductsService.shared

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
                LinearGradient(colors: [.white, .green.opacity(0.3), .white, .white, .white], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

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
                }
                .padding(16)
                
                VStack {
                    LinearGradient(colors: [.white, .clear], startPoint: .top, endPoint: .bottom)
                        .frame(height: 50)
                    
                    Spacer()
                }
            }
            .scrollIndicators(.hidden)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                AnalyticsManager.shared.trackDashboardViewed()
            }
            .toolbar {
                if productsService.subscribed {
                    ToolbarItem(placement: .principal) {
                        Button {
                            AnalyticsManager.shared.trackButtonClicked(
                                buttonName: "galaxy_brain_button",
                                screen: "dashboard"
                            )
                            AnalyticsManager.shared.trackParticleEffectTriggered()

                        } label: {
                            HStack {
                                Image("galaxy-brain-to")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .scaledToFit()
                                Text("GALAXY BRAIN ON")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                        }
                        .buttonStyle(
                            PressableButtonStyle(
                                foregroundColor: .purple,
                                backgroundColor: .purple.opacity(0.7),
                                cornerRadius: 16,
                                yOffset: 6
                            )
                        )
                        .frame(width: 200, height: 30)
                    }
                } else {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            AnalyticsManager.shared.trackButtonClicked(
                                buttonName: "heal_me_button",
                                screen: "dashboard"
                            )
                            AnalyticsManager.shared.trackSubscriptionViewPresented(source: "dashboard_heal_me_button")
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
                                yOffset: 6
                            )
                        )
                        .frame(width: 100, height: 30)
                    }
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
                .frame(width: UIScreen.main.bounds.height > 700 ? 200 : 120)
                .padding(.bottom, UIScreen.main.bounds.height > 700 ? 32 : 16)
            
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
                AnalyticsManager.shared.trackButtonClicked(
                    buttonName: isConnected ? "stop_vpn" : "start_vpn",
                    screen: "dashboard"
                )
                AnalyticsManager.shared.trackVPNToggled(isEnabled: !isConnected)
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
        let calendar = Calendar.current
        let now = Date()

        // Get last 30 days interval
        let startOfToday = calendar.startOfDay(for: now)
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: startOfToday)!
        let monthInterval = DateInterval(start: thirtyDaysAgo, end: now)

        return DeviceActivityFilter(
            segment: .daily(during: monthInterval),
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
#else
            // DEVICE: Show real DeviceActivityReport (authorization is handled in onboarding)
            DeviceActivityReport(.totalActivity, filter: filter)
#endif
        }
    }
    
#if targetEnvironment(simulator)
    // Mock data - only compiled for simulator
    private static let mockData = ActivityReport(
        totalDuration: 18720, // 5h 12m
        apps: [
            AppActivity(displayName: "TikTok", bundleIdentifier: "com.zhiliaoapp.musically", duration: 7200, category: "Social Networking", token: nil),
            AppActivity(displayName: "Instagram", bundleIdentifier: "com.burbn.instagram", duration: 5400, category: "Social Networking", token: nil),
            AppActivity(displayName: "YouTube", bundleIdentifier: "com.google.ios.youtube", duration: 3600, category: "Entertainment", token: nil),
            AppActivity(displayName: "Safari", bundleIdentifier: "com.apple.mobilesafari", duration: 1800, category: "Productivity", token: nil),
            AppActivity(displayName: "WhatsApp", bundleIdentifier: "net.whatsapp.WhatsApp", duration: 720, category: "Communication", token: nil),
            AppActivity(displayName: "Twitter", bundleIdentifier: "com.atebits.Tweetie2", duration: 600, category: "Social Networking", token: nil),
            AppActivity(displayName: "Reddit", bundleIdentifier: "com.reddit.Reddit", duration: 540, category: "Social Networking", token: nil),
            AppActivity(displayName: "Spotify", bundleIdentifier: "com.spotify.client", duration: 480, category: "Entertainment", token: nil),
            AppActivity(displayName: "Netflix", bundleIdentifier: "com.netflix.Netflix", duration: 420, category: "Entertainment", token: nil),
            AppActivity(displayName: "Gmail", bundleIdentifier: "com.google.Gmail", duration: 360, category: "Productivity", token: nil),
            AppActivity(displayName: "Facebook", bundleIdentifier: "com.facebook.Facebook", duration: 300, category: "Social Networking", token: nil),
            AppActivity(displayName: "Snapchat", bundleIdentifier: "com.toyopagroup.picaboo", duration: 240, category: "Social Networking", token: nil),
            AppActivity(displayName: "Telegram", bundleIdentifier: "ph.telegra.Telegraph", duration: 180, category: "Communication", token: nil),
            AppActivity(displayName: "Chrome", bundleIdentifier: "com.google.chrome.ios", duration: 120, category: "Productivity", token: nil),
            AppActivity(displayName: "Maps", bundleIdentifier: "com.apple.Maps", duration: 90, category: "Navigation", token: nil)
        ],
        historicalAverages: HistoricalAverages(
            yesterday: 21600, // 6h yesterday
            lastWeek: 19800,  // 5.5h average last week
            lastMonth: 22500  // 6.25h average last month
        )
    )
#endif
}

// MARK: - Shared Screen Time View
// THIS IS THE SINGLE SOURCE OF TRUTH FOR THE UI
// Used by both simulator (directly) and device (via TotalActivityView in extension)
// When you edit this, you need to copy the changes to TotalActivityView.swift in BrainrotActivityReport
struct SharedScreenTimeView: View {
    let activityReport: ActivityReport

    private func comparisonData(for period: TimeInterval) -> (percentage: Double, icon: String, color: Color, text: String) {
        guard period > 0 else {
            return (0, "minus.circle.fill", .gray, "N/A")
        }

        let diff = period - activityReport.totalDuration
        let percentage = (diff / period) * 100
        let icon = percentage > 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill"
        let color: Color = percentage > 0 ? .green : .red
        let text = String(format: "%.0f%%", abs(percentage))

        return (percentage, icon, color, text)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Two Column Stats Card
                HStack(spacing: 12) {
                    // Today's Total Column
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Today's Total")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer()

                        Text(formatDuration(activityReport.totalDuration))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)

                        Text("Very Bad")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)

                    // Progress Column
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Your Progress")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if let historical = activityReport.historicalAverages {
                            VStack(spacing: 6) {
                                ProgressIndicator(label: "Yesterday", data: comparisonData(for: historical.yesterday))
                                ProgressIndicator(label: "Last 7 days", data: comparisonData(for: historical.lastWeek))
                                ProgressIndicator(label: "Last 30 days", data: comparisonData(for: historical.lastMonth))
                            }
                        } else {
                            Text("Building history...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                }
                .frame(height: 100)

                // App List
                VStack(spacing: 0) {
                    ForEach(activityReport.apps) { app in
                        VStack(spacing: 0) {
                            HStack(spacing: 12) {
                                // App Icon
                                if let token = app.token {
                                    Label(token)
                                        .labelStyle(.iconOnly)
                                        .font(.largeTitle)
                                }

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

                            if app.id != activityReport.apps.last?.id {
                                Divider()
                            }
                        }
                        .frame(height: 60)
                    }
                }
            }
        }
        .onAppear {
            // Track screen time data view
            AnalyticsManager.shared.trackScreenTimeDataViewed(
                totalDuration: activityReport.totalDuration,
                appCount: activityReport.apps.count
            )

            // Track comparison data if available
            if let historical = activityReport.historicalAverages {
                let yesterdayData = comparisonData(for: historical.yesterday)
                let weekData = comparisonData(for: historical.lastWeek)
                let monthData = comparisonData(for: historical.lastMonth)

                AnalyticsManager.shared.trackScreenTimeComparison(
                    yesterdayChange: yesterdayData.percentage,
                    weekChange: weekData.percentage,
                    monthChange: monthData.percentage
                )
            }
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

// MARK: - Progress Indicator Component
struct ProgressIndicator: View {
    let label: String
    let data: (percentage: Double, icon: String, color: Color, text: String)

    var body: some View {
        HStack(spacing: 6) {
            // Circle indicator
            Circle()
                .fill(data.color)
                .frame(width: 8, height: 8)

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Percentage badge
            HStack(spacing: 3) {
                Image(systemName: data.icon)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(data.color)

                Text(data.text)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(data.color)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(data.color.opacity(0.15))
            .cornerRadius(6)
        }
    }
}

#Preview {
    DashboardView()
}
