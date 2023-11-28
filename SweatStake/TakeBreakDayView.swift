//
//  TakeBreakDayView.swift
//  SweatStake
//
//  Created by Hayden Carpenter on 11/26/23.
//

import SwiftUI

struct TakeBreakDayView: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    @State private var isBreakDay: Bool = false

    var body: some View {
        VStack {
            Button(action: {
                isBreakDay.toggle()
                if isBreakDay {
                    workoutViewModel.markDayAsBreakDay(date: Date())
                } else {
                    workoutViewModel.unmarkDayAsBreakDay(date: Date())
                }
            }) {
                Text(isBreakDay ? "You're only cheating yourself" : "Make today a break day")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity) // Makes the button stretch
                    .padding() // Padding inside the button
                    .background(isBreakDay ? Color.red : Color.green)
                    .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            isBreakDay = workoutViewModel.customBreakDays.contains(Calendar.current.startOfDay(for: Date()))
        }
        .background(Color(uiColor: hexStringToUIColor(hex: "#252422")))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

