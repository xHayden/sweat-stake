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

extension WorkoutDataProtocol {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

struct AnyWorkoutData: Identifiable, Hashable, Equatable {
    let id: UUID
    let workoutData: any WorkoutDataProtocol

    init(_ workoutData: any WorkoutDataProtocol) {
        self.id = workoutData.id
        self.workoutData = workoutData
    }
    
    static func == (lhs: AnyWorkoutData, rhs: AnyWorkoutData) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct WorkoutData: WorkoutDataProtocol, CustomStringConvertible, Equatable, Hashable {
    var id: UUID
    var type: HKWorkoutActivityType
    var duration: TimeInterval?
    var startDate: Date?
    var endDate: Date?

    var description: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        let startDateString = startDate.map { dateFormatter.string(from: $0) } ?? "N/A"
        let durationString = duration.map { String(format: "%.2f hours", $0 / 3600) } ?? "N/A"

        return "Workout(id: \(id), type: \(type), startDate: \(startDateString), duration: \(durationString))"
    }
    
    static func == (lhs: WorkoutData, rhs: WorkoutData) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct MockWorkoutData: WorkoutDataProtocol, CustomStringConvertible, Equatable, Hashable {
    var id: UUID
    var type: HKWorkoutActivityType
    var duration: TimeInterval?
    var startDate: Date?
    var endDate: Date?
    var description: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short

            let startDateString = startDate.map { dateFormatter.string(from: $0) } ?? "N/A"
            let durationString = duration.map { String(format: "%.2f hours", $0 / 3600) } ?? "N/A"

            return "Workout(id: \(id), type: \(type), startDate: \(startDateString), duration: \(durationString))"
        }
    
    static func == (lhs: MockWorkoutData, rhs: MockWorkoutData) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
