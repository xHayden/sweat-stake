//
//  MissedDaysCounterView.swift
//  SweatStake
//
//  Created by Hayden Carpenter on 11/25/23.
//

import Foundation
import SwiftUI

struct MissedDaysCounterView: View {
    let missedDays: Int
    let penaltyPerDay: Int

    var body: some View {
        VStack {
            Text("$\(missedDays * penaltyPerDay)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(missedDays > 0 ? .red : .red)
            Text("\(missedDays) lil' bitch days")
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color(uiColor: hexStringToUIColor(hex: "#252422")))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}
