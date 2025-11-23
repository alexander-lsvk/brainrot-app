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
        VStack(spacing: 16) {
            // Two Column Stats Card
            HStack(spacing: 16) {
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
                            Color(red: 130/255, green: 130/255, blue: 130/255).opacity(0.1),
                            lineWidth: 1
                        )
                }

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
                .frame(height: 100)
                .padding()
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(16)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            Color(red: 130/255, green: 130/255, blue: 130/255).opacity(0.1),
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
                        Color(red: 130/255, green: 130/255, blue: 130/255).opacity(0.1),
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
