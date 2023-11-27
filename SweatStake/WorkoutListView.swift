//
//  WorkoutListView.swift
//  SweatStake
//
//  Created by Hayden Carpenter on 11/26/23.
//

import Foundation
import SwiftUI

struct WorkoutListView: View {
    let workouts: [WorkoutDataProtocol]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(workouts, id: \.id) { workout in
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "figure.walk")
                            .foregroundColor(.blue)
                        Text("Type: \(workout.type.commonName)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(.green)
                        Text("Duration: \(TimeFormatter.shared.format(seconds: workout.duration ?? 0.0) ?? "N/A")")
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.red)
                        Text("Date: \(TimeFormatter.shared.format(date: workout.startDate ?? Date()))")
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                }
                .padding([.vertical, .horizontal])
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .background(Color(uiColor: hexStringToUIColor(hex: "#252422")))
                .cornerRadius(10)
                .shadow(radius: 5)
            }
        }
        .background(Color.clear)
    }
}
