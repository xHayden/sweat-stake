//
//  HistoricalPaymentsPageView.swift
//  SweatStake
//
//  Created by Hayden Carpenter on 11/26/23.
//

import SwiftUI

struct HistoricalPaymentsPageView: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(workoutViewModel.missedWorkoutsByMonth().sorted(by: { $0.key > $1.key }), id: \.key) { monthYearKey, data in
                    let components = monthYearKey.split(separator: "-").map { Int($0) }
                    if let year = components[0], let month = components[1] {
                        MonthPaymentDueView(month: month, year: year, numDaysMissed: data.missedDays, numStreakDays: data.streakDays,
                                            workoutViewModel: workoutViewModel
                        )
                    }
                }
            }
        }
    }
    
    init(workoutViewModel: WorkoutViewModel) {
        self.workoutViewModel = workoutViewModel
    }
}
