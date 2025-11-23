//
//  TotalActivityReport.swift
//  BrainrotActivityReport
//
//  Created by Alexander Lisovyk on 17.11.25.
//

import DeviceActivity
import SwiftUI
import ManagedSettings

extension DeviceActivityReport.Context {
    static let totalActivity = Self("Total Activity")
}

struct TotalActivityReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .totalActivity
    let content: (ActivityReport) -> TotalActivityView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> ActivityReport {
        print("🔍 Extension: makeConfiguration started")

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var todayTotal: TimeInterval = 0
        var todayApps: [AppActivity] = []

        // Storage for historical data by day
        var dailyTotals: [Date: TimeInterval] = [:]

        // Process all device activity data (last 30 days based on filter)
        for await dataEntry in data {
            print("📊 Extension: Processing data entry")
            for await activity in dataEntry.activitySegments {
                let segmentStart = calendar.startOfDay(for: activity.dateInterval.start)
                let segmentDuration = activity.totalActivityDuration

                // Accumulate daily totals
                dailyTotals[segmentStart, default: 0] += segmentDuration

                // If this is today's data, also collect app details
                if calendar.isDate(segmentStart, inSameDayAs: today) {
                    todayTotal += segmentDuration
                    print("⏱️ Extension: Today's total so far: \(todayTotal)")

                    for await categoryActivity in activity.categories {
                        for await appActivity in categoryActivity.applications {
                            let duration = appActivity.totalActivityDuration

                            todayApps.append(AppActivity(
                                displayName: (appActivity.application.localizedDisplayName ?? appActivity.application.bundleIdentifier) ?? "Unknown",
                                bundleIdentifier: appActivity.application.bundleIdentifier ?? "unknown",
                                duration: duration,
                                category: categoryActivity.category.localizedDisplayName ?? "Other",
                                token: appActivity.application.token
                            ))
                            print("📱 Extension: Added app: \(appActivity.application.bundleIdentifier ?? "unknown")")
                        }
                    }
                }
            }
        }

        print("✅ Extension: Finished processing. Found \(todayApps.count) apps, today's duration: \(todayTotal)")
        print("📊 Extension: Collected \(dailyTotals.count) days of historical data")

        // If no data from DeviceActivityResults, try loading from UserDefaults cache
        if todayApps.isEmpty {
            print("⚠️ Extension: No data from DeviceActivityResults, checking UserDefaults cache...")
            if let defaults = UserDefaults(suiteName: "group.com.app.Brainrot"),
               let savedData = defaults.data(forKey: "lastActivityReport"),
               let decoded = try? JSONDecoder().decode(CachedActivityReport.self, from: savedData) {
                print("✅ Extension: Loaded \(decoded.apps.count) apps from cache")
                // Even with cache, try to calculate from the historical data we got
                let historicalAverages = calculateHistoricalAverages(from: dailyTotals, today: today)
                return ActivityReport(totalDuration: decoded.totalDuration, apps: decoded.apps, historicalAverages: historicalAverages)
            } else {
                print("❌ Extension: No cached data available")
            }
        } else {
            // Save to cache for next time
            let cached = CachedActivityReport(totalDuration: todayTotal, apps: todayApps)
            if let encoded = try? JSONEncoder().encode(cached),
               let defaults = UserDefaults(suiteName: "group.com.app.Brainrot") {
                defaults.set(encoded, forKey: "lastActivityReport")
                print("💾 Extension: Saved to cache")
            }
        }

        // Filter out "Other" category apps and sort by duration
        todayApps = todayApps.filter { !$0.category.lowercased().contains("other") }
        todayApps.sort { $0.duration > $1.duration }

        // Calculate historical averages directly from the data we got
        let historicalAverages = calculateHistoricalAverages(from: dailyTotals, today: today)

        print("🏁 Extension: makeConfiguration complete with \(todayApps.count) apps (filtered)")
        return ActivityReport(totalDuration: todayTotal, apps: todayApps, historicalAverages: historicalAverages)
    }

    private func calculateHistoricalAverages(from dailyTotals: [Date: TimeInterval], today: Date) -> HistoricalAverages? {
        let calendar = Calendar.current

        // Need at least 2 days of data (yesterday + today) to show comparisons
        guard dailyTotals.count > 1 else {
            print("📊 Only today's data exists, showing 'Building history...'")
            return nil
        }

        print("📊 Calculating from \(dailyTotals.count) days of historical data")

        // Calculate yesterday's total
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let yesterdayTotal = dailyTotals[yesterday] ?? 0

        // Calculate last 7 days average (excluding today)
        let lastWeekStart = calendar.date(byAdding: .day, value: -7, to: today)!
        let lastWeekTotals = dailyTotals.filter { $0.key >= lastWeekStart && $0.key < today }.map { $0.value }
        let lastWeekAverage = lastWeekTotals.isEmpty ? 0 : lastWeekTotals.reduce(0, +) / TimeInterval(lastWeekTotals.count)

        // Calculate last 30 days average (excluding today)
        let lastMonthStart = calendar.date(byAdding: .day, value: -30, to: today)!
        let lastMonthTotals = dailyTotals.filter { $0.key >= lastMonthStart && $0.key < today }.map { $0.value }
        let lastMonthAverage = lastMonthTotals.isEmpty ? 0 : lastMonthTotals.reduce(0, +) / TimeInterval(lastMonthTotals.count)

        print("📊 Historical - Yesterday: \(yesterdayTotal/3600)h, Week: \(lastWeekAverage/3600)h, Month: \(lastMonthAverage/3600)h")

        return HistoricalAverages(
            yesterday: yesterdayTotal,
            lastWeek: lastWeekAverage,
            lastMonth: lastMonthAverage
        )
    }
}

// MARK: - Activity Report Model
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

// MARK: - Cached Activity Report (Codable for UserDefaults)
struct CachedActivityReport: Codable {
    let totalDuration: TimeInterval
    let apps: [AppActivity]
}

extension AppActivity: Codable {
    enum CodingKeys: String, CodingKey {
        case displayName
        case bundleIdentifier
        case duration
        case category
        // token is not Codable, so we exclude it from persistence
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        displayName = try container.decode(String.self, forKey: .displayName)
        bundleIdentifier = try container.decode(String.self, forKey: .bundleIdentifier)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        category = try container.decode(String.self, forKey: .category)
        token = nil // Tokens can't be cached
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(bundleIdentifier, forKey: .bundleIdentifier)
        try container.encode(duration, forKey: .duration)
        try container.encode(category, forKey: .category)
        // token is not encoded
    }
}
