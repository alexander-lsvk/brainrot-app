//
//  DeviceActivityDataStore.swift
//
//  Add this file to BOTH extension targets AND the main app target
//  This allows sharing data between the extensions and main app
//

import Foundation

class DeviceActivityDataStore {
    static let shared = DeviceActivityDataStore()

    private let defaults: UserDefaults?
    private let dataKey = "deviceActivityData"

    private init() {
        defaults = UserDefaults(suiteName: "group.com.app.Brainrot")
    }

    // Save activity data (called from extensions)
    func saveActivityData(_ data: AppActivityData) {
        guard let defaults = defaults else {
            print("Failed to access app group")
            return
        }

        do {
            let encoded = try JSONEncoder().encode(data)
            defaults.set(encoded, forKey: dataKey)
            defaults.synchronize()
            print("Saved activity data: \(data.applications.count) apps")
        } catch {
            print("Failed to encode activity data: \(error)")
        }
    }

    // Load activity data (called from main app)
    func loadActivityData() -> AppActivityData? {
        guard let defaults = defaults,
              let data = defaults.data(forKey: dataKey) else {
            return nil
        }

        do {
            let decoded = try JSONDecoder().decode(AppActivityData.self, from: data)
            return decoded
        } catch {
            print("Failed to decode activity data: \(error)")
            return nil
        }
    }

    // Clear stored data
    func clearActivityData() {
        defaults?.removeObject(forKey: dataKey)
        defaults?.synchronize()
    }
}
