//
//  ScreenTimeView.swift
//  Brainrot
//
//  Created by Alexander Lisovyk on 16.11.25.
//

import SwiftUI
import Charts
import DeviceActivity

struct ScreenTimeView: View {
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var refreshID = UUID()

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
                LinearGradient(
                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if !screenTimeManager.isAuthorized {
                    AuthorizationPromptCard(onAuthorize: {
                        Task {
                            try? await screenTimeManager.requestAuthorization()
                        }
                    })
                    .padding()
                } else {
                    // Show native DeviceActivityReport - it has built-in scrolling
                    DeviceActivityReport(.totalActivity, filter: filter)
                        .id(refreshID)
                }
            }
            .navigationTitle("Screen Time")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await screenTimeManager.checkAuthorization()
                if screenTimeManager.isAuthorized {
                    // Force refresh the DeviceActivityReport by changing its ID
                    refreshID = UUID()
                }
            }
        }
    }
}

// MARK: - Authorization Prompt Card
struct AuthorizationPromptCard: View {
    let onAuthorize: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "hourglass.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Screen Time Access Required")
                .font(.title2)
                .fontWeight(.bold)

            Text("To view your app usage statistics, please grant Screen Time access.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: onAuthorize) {
                Text("Authorize")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}

// MARK: - Total Screen Time Card
struct TotalScreenTimeCard: View {
    let appUsageData: [AppUsageInfo]

    private var totalMinutes: Int {
        appUsageData.reduce(0) { $0 + $1.usage }
    }

    private var formattedTime: String {
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return "\(hours)h \(minutes)m"
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Today's Total")
                .font(.headline)
                .foregroundColor(.secondary)

            Text(formattedTime)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text("\(totalMinutes) minutes across \(appUsageData.count) apps")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}

// MARK: - Usage Chart Card
struct UsageChartCard: View {
    let appUsageData: [AppUsageInfo]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Usage Breakdown")
                .font(.headline)

            Chart(appUsageData.prefix(5)) { app in
                BarMark(
                    x: .value("Minutes", app.usage),
                    y: .value("App", app.appName)
                )
                .foregroundStyle(by: .value("Category", app.category))
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}

// MARK: - App Usage List Card
struct AppUsageListCard: View {
    let appUsageData: [AppUsageInfo]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("App Usage")
                .font(.headline)

            if appUsageData.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "app.badge")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("No usage data available")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 40)
                    Spacer()
                }
            } else {
                ForEach(appUsageData) { app in
                    AppUsageRow(app: app)
                    if app.id != appUsageData.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}

// MARK: - App Usage Row
struct AppUsageRow: View {
    let app: AppUsageInfo

    private var formattedTime: String {
        let hours = app.usage / 60
        let minutes = app.usage % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    private var iconColor: Color {
        switch app.category {
        case "Social":
            return .pink
        case "Entertainment":
            return .red
        case "Productivity":
            return .blue
        case "Communication":
            return .green
        default:
            return .gray
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            // App Icon Placeholder
            Circle()
                .fill(iconColor.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "app.fill")
                        .foregroundColor(iconColor)
                )

            // App Info
            VStack(alignment: .leading, spacing: 4) {
                Text(app.appName)
                    .font(.headline)
                Text(app.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Usage Time
            VStack(alignment: .trailing, spacing: 4) {
                Text(formattedTime)
                    .font(.headline)
                    .fontWeight(.bold)

                // Usage bar
                GeometryReader { geometry in
                    let maxUsage = 180.0 // 3 hours max for visualization
                    let percentage = min(Double(app.usage) / maxUsage, 1.0)

                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 80, height: 4)

                        Rectangle()
                            .fill(iconColor)
                            .frame(width: 80 * percentage, height: 4)
                    }
                }
                .frame(width: 80, height: 4)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ScreenTimeView()
}

// MARK: - Error Card
struct ErrorCard: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Configuration Required")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("Apple's Screen Time API requires complex extension setup that is beyond the scope of this implementation. Real Screen Time data is available in iOS Settings → Screen Time.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}
