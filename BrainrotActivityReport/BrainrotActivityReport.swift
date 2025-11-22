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
        TotalActivityReport { activityReport in
            TotalActivityView(activityReport: activityReport)
        }
    }
}
