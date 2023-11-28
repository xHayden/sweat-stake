//
//  MissedDaysMonthCounterView.swift
//  SweatStake
//
//  Created by Hayden Carpenter on 11/27/23.
//

import SwiftUI

struct MissedDaysMonthCounterView: View {
    let missedDays: Int
    let penaltyPerDay: Int

    var body: some View {
        VStack {
            HStack {
                Spacer()
            }
            Spacer()
            Text("$\(missedDays * penaltyPerDay)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(missedDays > 0 ? .red : .green)
            Text("\(Text("\(missedDays)").foregroundColor(missedDays > 0 ? .red : .green)) missed day\(Text(missedDays == 1 ? "" : "s")) this month")
                .font(.subheadline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
        .background(Color(uiColor: hexStringToUIColor(hex: "#181716")))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}
