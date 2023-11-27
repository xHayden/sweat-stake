//
//  OverviewPageView.swift
//  SweatStake
//
//  Created by Hayden Carpenter on 11/26/23.
//

import SwiftUI

struct OverviewPageView: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                WorkoutCounterView(totalHours: workoutViewModel.totalWorkoutHoursThisMonth,
                                   avgWorkoutLength: workoutViewModel.averageWorkoutLength)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                Spacer()
                
                MissedDaysCounterView(missedDays: workoutViewModel.missedDaysInStreak,
                                      penaltyPerDay: workoutViewModel.getPenaltyPerDay())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            HStack(spacing: 0) {
                WorkoutHistoryChartView(workouts: workoutViewModel.workouts.compactMap { AnyWorkoutData($0) })
                    .padding()
                    .background(Color(uiColor: hexStringToUIColor(hex: "#252422")))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .foregroundColor(.green)
            }
//            HStack {
//                Text("Streak Statistics")
//                    .font(.caption)
//                    .foregroundColor(.white)
//                Spacer()
//            }
//            .cornerRadius(10)
            
            WorkoutListView(workouts: workoutViewModel.workouts)
        }.padding([.horizontal])
//            .onAppear {
//                        workoutViewModel.requestHealthKitAuthorization()
//                    }
    }
}
