//
//  DeviceActivityMonitorExtension.swift
//  BrainrotActivityMonitor
//
//  Created by Alexander Lisovyk on 17.11.25.
//

import DeviceActivity
import Foundation

extension DeviceActivityName {
    static let daily = Self("daily")
}

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        print("📊 Monitor: Interval started for \(activity)")
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        print("📊 Monitor: Interval ended for \(activity)")

        // Signal that data collection is complete
        // The main app will fetch this from the Report extension
        if let defaults = UserDefaults(suiteName: "group.com.app.Brainrot") {
            defaults.set(Date(), forKey: "lastDataUpdate")
            defaults.synchronize()
            print("✅ Monitor: Updated lastDataUpdate timestamp")
        }
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        print("📊 Monitor: Event threshold reached: \(event)")
    }

    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
    }

    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
    }
}
