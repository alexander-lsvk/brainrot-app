//
//  TotalActivityReport.swift
//  BrainrotActivityReport
//
//  Created by Alexander Lisovyk on 17.11.25.
//

import DeviceActivity
import SwiftUI

extension DeviceActivityReport.Context {
    static let totalActivity = Self("Total Activity")
}

struct TotalActivityReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .totalActivity
    let content: (ActivityReport) -> TotalActivityView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> ActivityReport {
        print("🔍 Extension: makeConfiguration started")
        var totalDuration: TimeInterval = 0
        var apps: [AppActivity] = []

        // Process the device activity data
        for await dataEntry in data {
            print("📊 Extension: Processing data entry")
            for await activity in dataEntry.activitySegments {
                totalDuration += activity.totalActivityDuration
                print("⏱️ Extension: Total duration so far: \(totalDuration)")

                for await categoryActivity in activity.categories {
                    for await appActivity in categoryActivity.applications {
                        let duration = appActivity.totalActivityDuration

                        apps.append(AppActivity(
                            displayName: (appActivity.application.localizedDisplayName ?? appActivity.application.bundleIdentifier) ?? "Unknown",
                            bundleIdentifier: appActivity.application.bundleIdentifier ?? "unknown",
                            duration: duration,
                            category: categoryActivity.category.localizedDisplayName ?? "Other"
                        ))
                        print("📱 Extension: Added app: \(appActivity.application.bundleIdentifier ?? "unknown")")
                    }
                }
            }
        }

        print("✅ Extension: Finished processing. Found \(apps.count) apps, total duration: \(totalDuration)")

        // If no data from DeviceActivityResults, try loading from UserDefaults cache
        if apps.isEmpty {
            print("⚠️ Extension: No data from DeviceActivityResults, checking UserDefaults cache...")
            if let defaults = UserDefaults(suiteName: "group.com.app.Brainrot"),
               let savedData = defaults.data(forKey: "lastActivityReport"),
               let decoded = try? JSONDecoder().decode(CachedActivityReport.self, from: savedData) {
                print("✅ Extension: Loaded \(decoded.apps.count) apps from cache")
                return ActivityReport(totalDuration: decoded.totalDuration, apps: decoded.apps)
            } else {
                print("❌ Extension: No cached data available")
            }
        } else {
            // Save to cache for next time
            let cached = CachedActivityReport(totalDuration: totalDuration, apps: apps)
            if let encoded = try? JSONEncoder().encode(cached),
               let defaults = UserDefaults(suiteName: "group.com.app.Brainrot") {
                defaults.set(encoded, forKey: "lastActivityReport")
                print("💾 Extension: Saved to cache")
            }
        }

        // Sort apps by duration
        apps.sort { $0.duration > $1.duration }

        // Save to App Group UserDefaults for main app to access
        let activityData = AppActivityData(
            totalScreenTime: totalDuration,
            applications: apps.map { app in
                ApplicationActivity(
                    id: app.bundleIdentifier,
                    name: app.displayName,
                    totalDuration: app.duration,
                    numberOfPickups: 0,
                    categoryName: app.category
                )
            },
            categories: [],
            date: Date()
        )


        print("🏁 Extension: makeConfiguration complete with \(apps.count) apps")
        return ActivityReport(totalDuration: totalDuration, apps: apps)
    }
}

// MARK: - Activity Report Model
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
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        displayName = try container.decode(String.self, forKey: .displayName)
        bundleIdentifier = try container.decode(String.self, forKey: .bundleIdentifier)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        category = try container.decode(String.self, forKey: .category)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(bundleIdentifier, forKey: .bundleIdentifier)
        try container.encode(duration, forKey: .duration)
        try container.encode(category, forKey: .category)
    }
}
