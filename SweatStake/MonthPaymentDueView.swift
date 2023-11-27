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
                .background(Color(uiColor: hexStringToUIColor(hex: "#252422")))
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(daysInMonth(year: year, month: month), id: \.self) { day in
                    ZStack {
                        Rectangle()
                            .fill(colorForDay(day))
                            .frame(width: 30, height: 30)
                            .cornerRadius(3.0)
                        
                        Text("\(Calendar.current.component(.day, from: day))") // Extract and display day number
                            .foregroundColor(.white)
                    }
                }
            }
            .padding([.horizontal])
            .padding([.vertical], 10)
        }.padding([.horizontal, .bottom])
    }
    
    private func daysInMonth(year: Int, month: Int) -> [Date] { // returns midnight according to local time zone
        var dates = [Date]()
        let calendar = Calendar.current

        // Define the date components of the start of the month
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.hour = 12
        dateComponents.minute = 0
        dateComponents.second = 0

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
            case .CUSTOM_BREAK_DAY: return Color(uiColor: hexStringToUIColor(hex: "#252422"))
            case .BREAK_DAY: return Color(uiColor: hexStringToUIColor(hex: "#252422"))
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
