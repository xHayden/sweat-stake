//
//  WorkoutModel.swift
//  SweatStake
//
//  Created by Hayden Carpenter on 11/24/23.
//

import Foundation
import HealthKit

extension MockWorkoutData {

    static func generateMockData() -> [MockWorkoutData] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = TimeZone.current

        return [
            MockWorkoutData(id: UUID(), type: .running, duration: 3000, startDate: dateFormatter.date(from: "2023-11-24 20:00")!, endDate: Date()), // 11-24 10 AM
            MockWorkoutData(id: UUID(), type: .cycling, duration: 7200, startDate: dateFormatter.date(from: "2023-11-22 09:00")!, endDate: dateFormatter.date(from: "2023-11-23 09:00")!), // 4 AM
            MockWorkoutData(id: UUID(), type: .yoga, duration: 1800, startDate: dateFormatter.date(from: "2023-11-20 08:00")!, endDate: dateFormatter.date(from: "2023-11-21 08:00")!), // 3 AM
            MockWorkoutData(id: UUID(), type: .running, duration: 3000, startDate: dateFormatter.date(from: "2023-11-19 10:00")!, endDate: Date()), // 11-19 5 AM
            MockWorkoutData(id: UUID(), type: .running, duration: 3000, startDate: dateFormatter.date(from: "2023-11-09 07:00")!, endDate: Date()), // 2 AM
            MockWorkoutData(id: UUID(), type: .running, duration: 3000, startDate: dateFormatter.date(from: "2023-10-15 06:00")!, endDate: Date()), // 1AM local ?
            MockWorkoutData(id: UUID(), type: .running, duration: 3000, startDate: dateFormatter.date(from: "2023-06-07 05:00")!, endDate: Date()), // 12 PM
            MockWorkoutData(id: UUID(), type: .running, duration: 3000, startDate: dateFormatter.date(from: "2023-05-28 04:00")!, endDate: Date()), // 12 PM?
            MockWorkoutData(id: UUID(), type: .running, duration: 3000, startDate: dateFormatter.date(from: "2023-01-19 03:00")!, endDate: Date()) // 1-18
        ]
    }
}
