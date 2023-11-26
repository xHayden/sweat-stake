//
//  WorkoutModel.swift
//  SweatStake
//
//  Created by Hayden Carpenter on 11/24/23.
//
import Foundation
import HealthKit

protocol WorkoutDataProtocol {
    var id: UUID { get }
    var type: HKWorkoutActivityType { get }
    var duration: TimeInterval? { get }
    var startDate: Date? { get }
    var endDate: Date? { get }
}

struct WorkoutData: WorkoutDataProtocol {
    var id: UUID
    var type: HKWorkoutActivityType
    var duration: TimeInterval?
    var startDate: Date?
    var endDate: Date?
}
