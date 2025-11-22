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
