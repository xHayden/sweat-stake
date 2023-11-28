//
//  MonthPaymentDueView.swift
//  SweatStake
//
//  Created by Hayden Carpenter on 11/26/23.
//

import SwiftUI

struct MonthPaymentDueView: View {
    let month: Int
    let year: Int
    let numDaysMissed: Int
    let numStreakDays: Int
    @ObservedObject var workoutViewModel: WorkoutViewModel
    
    private var monthName: String {
        DateFormatter().monthSymbols[month - 1]
    }

    var body: some View {
        VStack {
            VStack {
                HStack {
                    HStack {
                        Text("\(monthName) \(String(year))")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("$\(workoutViewModel.getPenaltyPerDay() * numDaysMissed)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(numDaysMissed > 0 ? .red : .green)
                            Text("\(numDaysMissed)/\(numStreakDays + numDaysMissed) streak day\(Text(numDaysMissed == 1 ? "" : "s")) missed")
                                .font(.caption)
                                .foregroundColor(numDaysMissed > 0 ? .red : .green)
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(Color(uiColor: hexStringToUIColor(hex: "#181716")))
                .cornerRadius(10)
                .shadow(radius: 5)
            }
            VStack {
                HStack(spacing: 0) {
                    ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                        Text(day)
                            .frame(minWidth: 0, maxWidth: .infinity) // Distribute evenly across the screen
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                }
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(0..<firstDayOffset(year: year, month: month), id: \.self) { _ in
                        Color.clear.frame(height: 30) // Inserts empty spaces for offset
                    }
                    ForEach(daysInMonth(year: year, month: month), id: \.self) { day in
                        ZStack {
                            Rectangle()
                                .fill(Color(uiColor: hexStringToUIColor(hex: "#252422")))
                                .frame(width: 30, height: 30)
                                .cornerRadius(180)
                                .overlay(
                                    Circle()
                                        .stroke(colorForDay(day), lineWidth: 4)
                                )

                            Text("\(Calendar.current.component(.day, from: day))") // Extract and display day number
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding([.horizontal])
            .padding([.vertical], 10)
            .background(Color(uiColor: hexStringToUIColor(hex: "#252422")))
            .cornerRadius(10)
        }.padding([.horizontal])
    }
    
    func firstDayOffset(year: Int, month: Int) -> Int {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Adjust depending on which day your week starts (e.g., 2 for Monday)
        let dateComponents = DateComponents(year: year, month: month)
        let date = calendar.date(from: dateComponents)!
        let weekday = calendar.component(.weekday, from: date)
        
        return (weekday - calendar.firstWeekday + 7) % 7
    }
    
    private func daysInMonth(year: Int, month: Int) -> [Date] { // returns midnight according to local time zone
        var dates = [Date]()
        let calendar = Calendar.current

        // Define the date components of the start of the month
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.hour = 3
        dateComponents.minute = 0
        dateComponents.second = 1
        
        // THIS IS FLAWED, I KNOW. I USE IT IN STREAKLENGTH TOO :(
        // It's flawed because a workout can be before 3 am and then not count as this day's workout even if there's a workout on the previous day.

        // Get the first date of the month at 0:00
        guard let firstOfMonth = calendar.date(from: dateComponents) else { return [] }

        // Get the range of days in the specified month
        guard let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else { return [] }

        // Create an array of dates for each day of the month
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                dates.append(date)
            }
        }
        return dates
    }

    
    private func colorForDay(_ day: Date) -> Color {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        switch (workoutViewModel.isWorkoutDay(day)) {
            case .CUSTOM_BREAK_DAY: return Color(uiColor: hexStringToUIColor(hex: "#3b4040"))
            case .BREAK_DAY: return Color(uiColor: hexStringToUIColor(hex: "#3b4040"))
            case .MISSED_DAY:
                if (calendar.isDate(day, inSameDayAs: today)) {
                    return Color.purple
                }
                return Color.red
            case.NOT_IN_STREAK: return Color.gray
            case .WORKOUT_DAY: return Color.green
        }
    }
}
