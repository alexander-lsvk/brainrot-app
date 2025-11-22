//
//  ScreenTimeManager.swift
//  Brainrot
//
//  Created by Alexander Lisovyk on 16.11.25.
//

import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings
import SwiftUI

extension DeviceActivityReport.Context {
    static let totalActivity = DeviceActivityReport.Context("Total Activity")
}

extension DeviceActivityName {
    static let daily = Self("daily")
}

@MainActor
class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()

    @Published var isAuthorized = false
    @Published var appUsageData: [AppUsageInfo] = []
    @Published var isMonitoring = false
    @Published var errorMessage: String?

    private let center = AuthorizationCenter.shared
    private let activityCenter = DeviceActivityCenter()

    private init() {
        Task {
            await checkAuthorization()
            await startDailyMonitoring()
        }
    }

    func checkAuthorization() async {
        await MainActor.run {
            switch center.authorizationStatus {
            case .approved:
                isAuthorized = true
            default:
                isAuthorized = false
            }
        }
    }

    func requestAuthorization() async throws {
        do {
            try await center.requestAuthorization(for: .individual)
            await checkAuthorization()
            print("Authorization status after request: \(center.authorizationStatus)")
            await startDailyMonitoring()
        } catch {
            errorMessage = "Failed to authorize Screen Time: \(error.localizedDescription)"
            throw error
        }
    }

    private func startDailyMonitoring() async {
        guard isAuthorized else {
            print("⚠️ Not authorized, skipping monitoring setup")
            return
        }

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )

        do {
            try activityCenter.startMonitoring(.daily, during: schedule)
            await MainActor.run {
                isMonitoring = true
            }
            print("✅ Started daily monitoring")
        } catch {
            print("❌ Failed to start monitoring: \(error)")
            await MainActor.run {
                isMonitoring = false
                errorMessage = "Failed to start monitoring: \(error.localizedDescription)"
            }
        }
    }

    // Fetch app usage data
    func fetchAppUsage() async {
        print("=== SCREEN TIME DEBUG ===")
        print("Authorization status: \(center.authorizationStatus)")

        // Try to load from UserDefaults
        if let defaults = UserDefaults(suiteName: "group.com.app.Brainrot"),
           let data = defaults.data(forKey: "deviceActivityData") {
            print("Found data in UserDefaults, size: \(data.count) bytes")

            do {
                let activityData = try JSONDecoder().decode(AppActivityData.self, from: data)
                print("Successfully decoded data: \(activityData.applications.count) apps")

                await MainActor.run {
                    self.appUsageData = activityData.applications.map { app in
                        AppUsageInfo(
                            appName: app.name,
                            bundleID: app.id,
                            usage: app.durationInMinutes,
                            category: app.categoryName
                        )
                    }
                }
            } catch {
                print("ERROR decoding data: \(error)")
                await MainActor.run {
                    self.appUsageData = []
                }
            }
        } else {
            print("ERROR: No data found in UserDefaults at key 'deviceActivityData'")
            print("Group container path: \(FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.app.Brainrot")?.path ?? "nil")")

            await MainActor.run {
                self.appUsageData = []
            }
        }

        print("=== END DEBUG ===")
    }
}

struct AppUsageInfo: Identifiable {
    let id = UUID()
    let appName: String
    let bundleID: String
    let usage: Int // minutes
    let category: String
}
