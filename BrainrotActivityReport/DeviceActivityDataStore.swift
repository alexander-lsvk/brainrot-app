//
//  DeviceActivityDataStore.swift
//
//  Add this file to BOTH extension targets AND the main app target
//  This allows sharing data between the extensions and main app
//

import Foundation

class DeviceActivityDataStore {
    static let shared = DeviceActivityDataStore()

    private let sharedContainerURL: URL?
    private let dataFileURL: URL?

    private init() {
        // Get the shared container URL
        sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.app.Brainrot")

        if let containerURL = sharedContainerURL {
            dataFileURL = containerURL.appendingPathComponent("screentime_data.json")
            print("📂 DataStore: Shared container at: \(containerURL.path)")
            print("📄 DataStore: Data file at: \(dataFileURL?.path ?? "nil")")
        } else {
            dataFileURL = nil
            print("❌ DataStore: Failed to get shared container URL")
        }
    }

    // Save activity data (called from extensions)
    func saveActivityData(_ data: AppActivityData) {
        print("🔍 DataStore: saveActivityData called with \(data.applications.count) apps")

        guard let fileURL = dataFileURL else {
            print("❌ DataStore: Data file URL is nil")
            return
        }

        do {
            let encoded = try JSONEncoder().encode(data)
            print("✅ DataStore: Encoded data (\(encoded.count) bytes)")

            try encoded.write(to: fileURL, options: [.atomic])
            print("💾 DataStore: Saved activity data to file: \(fileURL.path)")
            print("✅ DataStore: File exists after write: \(FileManager.default.fileExists(atPath: fileURL.path))")
        } catch {
            print("❌ DataStore: Failed to save activity data: \(error)")
        }
    }

    // Load activity data (called from main app)
    func loadActivityData() -> AppActivityData? {
        print("🔍 DataStore: loadActivityData called")

        guard let fileURL = dataFileURL else {
            print("❌ DataStore: Data file URL is nil")
            return nil
        }

        print("📄 DataStore: Looking for file at: \(fileURL.path)")
        print("📋 DataStore: File exists: \(FileManager.default.fileExists(atPath: fileURL.path))")

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("❌ DataStore: File does not exist")
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            print("✅ DataStore: Loaded data (\(data.count) bytes)")

            let decoded = try JSONDecoder().decode(AppActivityData.self, from: data)
            print("✅ DataStore: Successfully decoded \(decoded.applications.count) apps")
            return decoded
        } catch {
            print("❌ DataStore: Failed to load activity data: \(error)")
            return nil
        }
    }

    // Clear stored data
    func clearActivityData() {
        guard let fileURL = dataFileURL else { return }
        try? FileManager.default.removeItem(at: fileURL)
    }
}
