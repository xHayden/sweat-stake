//
//  WorkoutCounterView.swift
//  SweatStake
//
//  Created by Hayden Carpenter on 11/25/23.
//

import Foundation
import SwiftUI

struct WorkoutCounterView: View {
    let totalHours: Int
    let avgWorkoutLength: TimeInterval

    var body: some View {
        VStack {
            Text("\(totalHours) Hours")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("Avg. Workout: \(TimeFormatter.shared.format(seconds: avgWorkoutLength) ?? "N/A")")
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color(uiColor: hexStringToUIColor(hex: "#252422")))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}
