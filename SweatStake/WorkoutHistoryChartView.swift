// WorkoutHistoryChartView.swift
// SweatStake
//
// Created by Hayden Carpenter on 11/25/23.
//

import Foundation
import SwiftUI
import Charts

struct SimpleWorkoutData {
    let startDate: Date
    let durationInHours: Double
}

func transformWorkoutData(_ workouts: [AnyWorkoutData]) -> [SimpleWorkoutData] {
    let calendar = Calendar.current
    let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date())!

    return workouts.compactMap { workout in
        guard let startDate = workout.workoutData.startDate,
              let duration = workout.workoutData.duration,
              startDate >= thirtyDaysAgo else { return nil }

        return SimpleWorkoutData(startDate: startDate, durationInHours: duration / 3600)
    }
}


struct WorkoutHistoryChartView: View {
    let workouts: [AnyWorkoutData]
    
    var body: some View {
        let simpleWorkouts = transformWorkoutData(workouts)

        return Chart {
            ForEach(simpleWorkouts, id: \.startDate) { workout in
                BarMark(
                    x: .value("Day", workout.startDate),
                    y: .value("Workout Duration", workout.durationInHours), width: 4
                )
                .cornerRadius(8.0)
            }
        }
        .chartYAxis {
            AxisMarks {
                AxisValueLabel()
                    .foregroundStyle(Color(uiColor: hexStringToUIColor(hex: "#feeafa")))
                    .offset(x: 10)
            }
        }
        .chartYAxisLabel(content: {
            Text("Duration (Hours)").foregroundStyle(Color(uiColor: hexStringToUIColor(hex: "#feeafa")))
        })
        
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, roundUpperBound: true)) {
                AxisValueLabel()
                    .foregroundStyle(Color(uiColor: hexStringToUIColor(hex: "#feeafa")))
            }
        }
    }
}
