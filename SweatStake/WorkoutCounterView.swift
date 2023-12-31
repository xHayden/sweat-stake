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
            HStack {
                Spacer()
            }
            Spacer()
            Text("\(totalHours) Total Hour\(Text(totalHours == 1 ? "" : "s"))")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("Average Workout: \(TimeFormatter.shared.format(seconds: avgWorkoutLength) ?? "N/A")")
                .font(.caption)
                .foregroundColor(.white)
            Spacer()
        }
        .padding()
        .background(Color(uiColor: hexStringToUIColor(hex: "#181716")))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}
