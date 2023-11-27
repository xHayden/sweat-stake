//
//  SettingsPageView.swift
//  SweatStake
//
//  Created by Hayden Carpenter on 11/26/23.
//

import SwiftUI

struct SettingsPageView: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel

    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Penalty Per Day:")
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: {
                        if workoutViewModel.penaltyPerDay > 0 {
                            workoutViewModel.penaltyPerDay -= 1
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.white)
                    }

                    Text("$\(workoutViewModel.penaltyPerDay)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(minWidth: 36)

                    Button(action: {
                        if workoutViewModel.penaltyPerDay < 100 {
                            workoutViewModel.penaltyPerDay += 1
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color(uiColor: hexStringToUIColor(hex: "#252422")))
                .cornerRadius(10)
                HStack {
                    Text("Break Days Per Week:")
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: {
                        if workoutViewModel.breakDaysPerWeek > 0 {
                            workoutViewModel.breakDaysPerWeek -= 1
                            workoutViewModel.clearAutoBreakDays()
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.white)
                    }

                    Text("\(workoutViewModel.breakDaysPerWeek)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(minWidth: 36)

                    Button(action: {
                        if workoutViewModel.breakDaysPerWeek < 7 {
                            workoutViewModel.breakDaysPerWeek += 1
                            workoutViewModel.clearAutoBreakDays()
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color(uiColor: hexStringToUIColor(hex: "#252422")))
                .cornerRadius(10)
            }.padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        TakeBreakDayView(workoutViewModel: workoutViewModel)
            .padding([.horizontal])
    }
}
