//
//  TotalActivityView.swift
//  BrainrotActivityReport
//
//  Created by Alexander Lisovyk on 17.11.25.
//
//  IMPORTANT: This file should be kept in sync with SharedScreenTimeView in DashboardView.swift
//  When you edit the UI here, copy the changes to SharedScreenTimeView and vice versa

import SwiftUI

struct TotalActivityView: View {
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
        VStack(spacing: 16) {
            // Two Column Stats Card
            HStack(spacing: 16) {
                // Today's Total Column
                VStack(spacing: 4) {
                    Text("Today's Total")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(formatDuration(activityReport.totalDuration))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("\(activityReport.apps.count) apps")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .padding()
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(16)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            Color(red: 130, green: 130, blue: 130).opacity(0.2),
                            lineWidth: 1
                        )
                }
                
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
                .frame(height: 100)
                .padding()
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(16)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            Color(red: 130, green: 130, blue: 130).opacity(0.2),
                            lineWidth: 1
                        )
                }
            }
            .frame(height: 130)
            .padding(.bottom, 1)
            
            // App List
            VStack(alignment: .leading, spacing: 0) {
                ForEach(activityReport.apps.prefix(10)) { app in
                    VStack(spacing: 0) {
                        HStack(alignment: .center, spacing: 12) {
                            // App Info
                            VStack(alignment: .leading, spacing: 2) {
                                Text(app.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(app.category)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(height: 50)
                            
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
                            .frame(height: 50)
                        }
                        
                        if app.id != activityReport.apps.prefix(20).last?.id {
                            Divider()
                        }
                    }
                    .frame(height: 50)
                }
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(16)
            .frame(height: 500)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        Color(red: 130, green: 130, blue: 130).opacity(0.2),
                        lineWidth: 1
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

#Preview {
    TotalActivityView(activityReport: ActivityReport(
        totalDuration: 5000,
        apps: [
            AppActivity(displayName: "TikTok", bundleIdentifier: "com.test", duration: 3600, category: "Social"),
            AppActivity(displayName: "Instagram", bundleIdentifier: "com.test2", duration: 1400, category: "Social")
        ]
    ))
}
