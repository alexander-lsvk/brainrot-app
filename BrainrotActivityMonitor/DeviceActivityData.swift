//
//  DeviceActivityData.swift
//  Brainrot
//
//  Created by Alexander Lisovyk on 16.11.25.
//

import Foundation
import FamilyControls

struct AppActivityData: Codable {
    let totalScreenTime: TimeInterval
    let applications: [ApplicationActivity]
    let categories: [CategoryActivity]
    let date: Date
}

struct ApplicationActivity: Codable, Identifiable {
    let id: String // Bundle identifier
    let name: String
    let totalDuration: TimeInterval
    let numberOfPickups: Int
    let categoryName: String

    init(id: String, name: String, totalDuration: TimeInterval, numberOfPickups: Int, categoryName: String) {
        self.id = id
        self.name = name
        self.totalDuration = totalDuration
        self.numberOfPickups = numberOfPickups
        self.categoryName = categoryName
    }
}

struct CategoryActivity: Codable, Identifiable {
    let id: String
    let name: String
    let totalDuration: TimeInterval
}

extension ApplicationActivity {
    var durationInMinutes: Int {
        Int(totalDuration / 60)
    }

    var durationFormatted: String {
        let hours = Int(totalDuration) / 3600
        let minutes = (Int(totalDuration) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
