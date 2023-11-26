//
//  WorkoutModel.swift
//  SweatStake
//
//  Created by Hayden Carpenter on 11/24/23.
//
import Foundation
import HealthKit

struct MockWorkoutData: WorkoutDataProtocol {
    var id: UUID
    var type: HKWorkoutActivityType
    var duration: TimeInterval?
    var startDate: Date?
    var endDate: Date?
}

extension MockWorkoutData {
    static func generateMockData() -> [MockWorkoutData] {
        return [
            MockWorkoutData(id: UUID(), type: .running, duration: 3000, startDate: Date().addingTimeInterval(-3600), endDate: Date()),
            MockWorkoutData(id: UUID(), type: .cycling, duration: 7200, startDate: Date().addingTimeInterval(-86400 * 2), endDate: Date().addingTimeInterval(-86400)),
            MockWorkoutData(id: UUID(), type: .yoga, duration: 1800, startDate: Date().addingTimeInterval(-86400 * 4), endDate: Date().addingTimeInterval(-86400 * 3)),
        ]
    }
}
