//
//  WorkoutListView.swift
//  SweatStake
//
//  Created by Hayden Carpenter on 11/26/23.
//

import SwiftUI

struct WorkoutListView: View {
        @ObservedObject var workoutViewModel: WorkoutViewModel
        @State private var visibleWorkoutCount: Int = 10 // Initial number of workouts to display

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 10) {
                ForEach(workoutViewModel.workouts.prefix(visibleWorkoutCount), id: \.id) { workout in
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "figure.walk")
                                .foregroundColor(.green)
                            Text("\(workout.type.commonName)")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(TimeFormatter.shared.format(seconds: workout.duration ?? 0.0) ?? "N/A")")
                                .foregroundColor(.white)
                        }.padding([.bottom], 5)
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.red)
                            Text(workout.startDate.map { $0.relativeDateString() } ?? "N/A")
                                .foregroundColor(.white)
                                .font(.subheadline)
                            Spacer()
                            Image(systemName: "flame.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 20))
                            Text(workout.startDate != nil ? "\(workoutViewModel.streakLength(upTo: workout.startDate!))" : "N/A")
                                .foregroundColor(.white)
                                .font(.headline)
                                .bold()
                        }
                    }
                    .padding([.vertical, .horizontal])
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: hexStringToUIColor(hex: "#252422")))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
            }
            if visibleWorkoutCount < workoutViewModel.workouts.count {
                Button("Load More") {
                    let remainingCount = workoutViewModel.workouts.count - visibleWorkoutCount
                    visibleWorkoutCount += min(remainingCount, 10) // Load 10 more workouts at a time, or remaining if less than 10
                }
                .foregroundColor(.white)
                .padding([.vertical], 10)
                .padding([.horizontal], 20)
                .background(Color(uiColor: hexStringToUIColor(hex: "#252422")))
                .cornerRadius(180)
                .padding([.vertical], 10)
            }
        }
        .background(Color.clear)
    }
}

extension Date {
    func relativeDateString() -> String {
        let calendar = Calendar.current
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short

        let timeString = timeFormatter.string(from: self)

        if calendar.isDateInToday(self) {
            return "Today at \(timeString)"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday at \(timeString)"
        } else {
            let startOfNow = calendar.startOfDay(for: Date())
            let startOfDate = calendar.startOfDay(for: self)
            let components = calendar.dateComponents([.day], from: startOfDate, to: startOfNow)
            guard let daysAgo = components.day, daysAgo <= 7 else {
                return DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .none) + " at \(timeString)"
            }
            return "\(daysAgo) days ago at \(timeString)"
        }
    }
}
