//
//  BrainrotActivityReport.swift
//  BrainrotActivityReport
//
//  Created by Alexander Lisovyk on 17.11.25.
//

import DeviceActivity
import SwiftUI

@main
struct BrainrotActivityReport: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Create a report for each DeviceActivityReport.Context that your app supports.
        TotalActivityReport { totalActivity in
            TotalActivityView(totalActivity: totalActivity)
        }
        // Add more reports here...
    }
}
