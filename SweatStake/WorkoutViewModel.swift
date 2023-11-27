    //
    //  WorkoutViewModel.swift
    //  SweatStake
    //
    //  Created by Hayden Carpenter on 11/24/23.
    //

    import SwiftUI
    import HealthKit

class WorkoutViewModel: ObservableObject {
    private var healthStore: HKHealthStore?
    @Published var penaltyPerDay: Int = 20
    @Published var breakDaysPerWeek: Int = 0
    @Published var workouts: [WorkoutDataProtocol] = []
    @Published var customBreakDays: Set<Date> = []
    @Published var automaticBreakDays: Set<Date> = []
    private var streaks: [[Date]] = []
    private var dayStatusInStreaks: [Date: Bool] = [:]
    
    init(workouts: [WorkoutDataProtocol] = []) {
        self.workouts = workouts
        self.healthStore = HKHealthStore.isHealthDataAvailable() ? HKHealthStore() : nil
        self.requestHealthKitAuthorization()
        self.loadBreakDays()
        self.calculateAndStoreStreaks()
    }
    
    var totalWorkoutHoursThisMonth: Int {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let now = Date()
        let thisMonth = calendar.component(.month, from: now)
        let thisYear = calendar.component(.year, from: now)
        
        return workouts
            .filter {
                guard let startDate = $0.startDate else { return false }
                return calendar.component(.month, from: startDate) == thisMonth &&
                calendar.component(.year, from: startDate) == thisYear
            }
            .compactMap { $0.duration }
            .reduce(0) { $0 + Int($1 / 3600) }
    }
    
    func workoutsInMonth(month: Int) -> [WorkoutDataProtocol] {
        guard month >= 1 && month <= 12 else {
            print("Invalid month. Month should be between 1 and 12.")
            return []
        }
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let filteredWorkouts = workouts.filter { workout in
            guard let startDate = workout.startDate else { return false }
            return calendar.component(.month, from: startDate) == month
        }
        
        return filteredWorkouts
    }
    
    var averageWorkoutLength: TimeInterval {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let now = Date()
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
        
        let filteredWorkouts = workouts.filter { workout in
            guard let startDate = workout.startDate else { return false }
            return startDate >= oneMonthAgo
        }
        
        let totalDuration = filteredWorkouts
            .compactMap { $0.duration }
            .reduce(0, +)
        
        return filteredWorkouts.isEmpty ? 0 : totalDuration / Double(filteredWorkouts.count)
    }
    
    func streakLength() -> Int {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let now = Date()
        var latestWorkoutDate: Date?
        
        // Sort workouts by date in descending order
        let sortedWorkouts = workouts
            .compactMap { $0.startDate }
            .sorted(by: >)
        
        for workoutDate in sortedWorkouts {
            if let latestDate = latestWorkoutDate {
                let oneMonthBefore = calendar.date(byAdding: .month, value: -1, to: latestDate)!
                if workoutDate >= oneMonthBefore {
                    latestWorkoutDate = workoutDate
                } else {
                    break
                }
            } else {
                latestWorkoutDate = workoutDate
            }
        }
        
        guard let startDateOfStreak = latestWorkoutDate else { return 0 }
        let streakDays = calendar.dateComponents([.day], from: startDateOfStreak, to: now).day ?? 0
        return streakDays
    }
    
    var missedDaysInStreak: Int {
        let streakLength = streakLength()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let now = Date()
        
        // Start date of the streak
        guard let startDateOfStreak = calendar.date(byAdding: .day, value: -streakLength, to: now) else { return 0 }
        
        // Iterate over each day since the start of the streak
        var missedDays = 0
        for day in 0..<streakLength {
            guard let checkDate = calendar.date(byAdding: .day, value: day, to: startDateOfStreak) else { continue }
            let isWorkoutDay = isWorkoutDay(checkDate)
            if (isWorkoutDay == .MISSED_DAY) {
                missedDays += 1
            }
        }
        return missedDays
    }
    
    
    // Helper method to provide mock data for previews
    static func previewViewModel() -> WorkoutViewModel {
        let mockData = MockWorkoutData.generateMockData()
        return WorkoutViewModel(workouts: mockData)
    }
    
    func requestHealthKitAuthorization() {
        // Check if HealthKit is available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }
        
        // Check if the necessary Info.plist keys are present
        let infoDictionary = Bundle.main.infoDictionary
        let healthShareUsageDescription = infoDictionary?["NSHealthShareUsageDescription"] as? String
        let healthUpdateUsageDescription = infoDictionary?["NSHealthUpdateUsageDescription"] as? String
        
        if healthShareUsageDescription == nil {
            print("NSHealthShareUsageDescription key is missing in Info.plist.")
        }
        
        if healthUpdateUsageDescription == nil {
            print("NSHealthUpdateUsageDescription key is missing in Info.plist.")
        }
        
        // Initialize HealthKit store
        guard let healthStore = self.healthStore else {
            print("Failed to initialize HKHealthStore.")
            return
        }
        
        // Define the HealthKit data types your app needs access to
        let readTypes = Set([
            HKObjectType.workoutType(),
            HKObjectType.activitySummaryType()
        ])
        
        // Request Authorization
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error requesting HealthKit authorization: \(error.localizedDescription)")
                    return
                }
                if success {
//                    print("HealthKit authorization granted.")
                    self.fetchMostRecentWorkouts()
                } else {
                    print("HealthKit authorization denied.")
                }
            }
        }
    }
    
    func fetchMostRecentWorkouts() {
        guard let healthStore = self.healthStore else { return }
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { [weak self] (query, samples, error) in
            DispatchQueue.main.async {
                guard let workouts = samples as? [HKWorkout], error == nil else {
                    print("Error fetching workouts: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
//                print("Fetched \(workouts.count) workouts:")
                if (workouts.count != 0) {
                    self?.workouts = workouts.map { workout in
                        WorkoutData(
                            id: UUID(),
                            type: workout.workoutActivityType,
                            duration: workout.duration,
                            startDate: workout.startDate,
                            endDate: workout.endDate
                        )
                    }
                    self?.calculateAndStoreStreaks()
                }
            }
        }
        healthStore.execute(query)
    }
    
    func missedWorkoutsByMonth() -> [String: (missedDays: Int, streakDays: Int)] {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        var workoutsPerMonth = [String: (missedDays: Int, streakDays: Int)]()

        let streaks = calculateStreaks()

        for streak in streaks {
            guard let firstDate = streak.first, let lastDate = streak.last else { continue }

            var currentDate = firstDate
            while currentDate <= lastDate {
                let year = calendar.component(.year, from: currentDate)
                let month = calendar.component(.month, from: currentDate)
                let monthYearKey = "\(year)-\(String(format: "%02d", month))"

                if workoutsPerMonth[monthYearKey] == nil {
                    workoutsPerMonth[monthYearKey] = (missedDays: 0, streakDays: 0)
                }
                
                let workoutDayStatus = isWorkoutDay(currentDate)
                if (workoutDayStatus == .WORKOUT_DAY) {
                    workoutsPerMonth[monthYearKey]?.streakDays += 1
                } else if (workoutDayStatus == .MISSED_DAY) {
                    workoutsPerMonth[monthYearKey]?.missedDays += 1
                }

                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
        }

        return workoutsPerMonth
    }

    
    func calculateStreaks() -> [[Date]] {
        guard !workouts.isEmpty else { return [] }
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        var streaks: [[Date]] = []
        var currentStreak: [Date] = []
        
        let sortedWorkouts = workouts.filter { $0.startDate != nil }
            .sorted { $0.startDate! < $1.startDate! }
        
        for i in 0..<sortedWorkouts.count {
            let workoutDate = sortedWorkouts[i].startDate!
            
            if currentStreak.isEmpty {
                currentStreak.append(workoutDate)
                continue
            }
            
            let oneMonthBeforeWorkoutDate = calendar.date(byAdding: .month, value: -1, to: workoutDate)!
            
            // Check if the currentStreak contains a date within one month before workoutDate
            if currentStreak.contains(where: { $0 >= oneMonthBeforeWorkoutDate }) {
                currentStreak.append(workoutDate)
            } else {
                // More than a month gap from all dates in the current streak, start a new streak
                streaks.append(currentStreak)
                currentStreak = [workoutDate]
            }
        }
        
        // Add the last streak if it's not empty
        if !currentStreak.isEmpty {
            streaks.append(currentStreak)
        }
        
        return streaks
    }
    
    private func calculateAndStoreStreaks() {
        streaks = calculateStreaks()
        for streak in streaks {
            for day in streak {
                dayStatusInStreaks[day] = workouts.contains { $0.startDate == day }
            }
        }
    }
    
    private func hasBreakDaysInWeek(date: Date, numberOfBreakDays: Int) -> Bool {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        let startOfWeek = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        guard let startOfWeekDate = calendar.date(from: startOfWeek) else { return false }

        let endOfWeekDate = calendar.date(byAdding: .day, value: 7, to: startOfWeekDate)!

        // Combine both custom and automatic break days
        let combinedBreakDays = customBreakDays.union(automaticBreakDays)

        // Count the break days within the specified week
        let breakDaysInWeek = combinedBreakDays.filter { $0 >= startOfWeekDate && $0 < endOfWeekDate }
        return breakDaysInWeek.count >= numberOfBreakDays
    }

    enum WorkoutDayStatus {
        case BREAK_DAY
        case CUSTOM_BREAK_DAY
        case MISSED_DAY
        case WORKOUT_DAY
        case NOT_IN_STREAK
    }

    func isWorkoutDay(_ date: Date) -> WorkoutDayStatus {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        let startOfDate = calendar.startOfDay(for: date)
        var shouldBeMissed = false;

        // If it's a manually marked break day, return nil
        if customBreakDays.contains(startOfDate) {
            return WorkoutDayStatus.CUSTOM_BREAK_DAY
        }
        
        if automaticBreakDays.contains(startOfDate) {
            return WorkoutDayStatus.BREAK_DAY
        }
        
        for streak in streaks {
            guard let first = streak.first,
                  let last = streak.last else { continue }
            
            // Start of first day in streak
            let firstDateInStreak = calendar.startOfDay(for: first)
            
            // End of last day in streak (midnight of the next day)
            if let lastDateInStreak = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: last)) {
                // Subtract one second to stay within the same day
                let lastDateInStreakEnd = calendar.date(byAdding: .second, value: -1, to: lastDateInStreak)!
                
                // Check if the date is within the streak range
                if date < firstDateInStreak || date > lastDateInStreakEnd {
                    continue
                }
                
                // Check for workouts on the current and previous day within the streak
                let isWorkoutOnCurrentDay = streak.contains { workoutDate in
                    calendar.isDate(workoutDate, inSameDayAs: date)
                }
                let isWorkoutOnPreviousDay = streak.contains { workoutDate in
                    calendar.isDate(workoutDate, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: date)!)
                }
                let isWorkoutOnNextDay = streak.contains { workoutDate in
                    calendar.isDate(workoutDate, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: date)!)
                }
                
                let hourComponent = calendar.component(.hour, from: date)
                let nextDay = calendar.date(byAdding: .day, value: 1, to: date)!
                let nextDayHourComponent = calendar.component(.hour, from: nextDay)
                
                if (isWorkoutOnCurrentDay && !isWorkoutOnPreviousDay && hourComponent < 3) {
                    // Early morning workout, check if the previous day is part of the streak
                    let previousDay = calendar.date(byAdding: .day, value: -1, to: startOfDate)!
                    let isPreviousDayInStreak = previousDay >= firstDateInStreak && previousDay <= lastDateInStreak
                    
                    if isPreviousDayInStreak {
                        // Previous day is in the streak, count as previous day
//                        return false
                        shouldBeMissed = true;
                        continue;
                    } else {
                        // Previous day is not in the streak, count as current day
                        return WorkoutDayStatus.WORKOUT_DAY
                    }
                } else if (!isWorkoutOnCurrentDay && isWorkoutOnNextDay && nextDayHourComponent < 3) {
                    // Next day's early morning workout, count as current day
                    return WorkoutDayStatus.WORKOUT_DAY
                } else if (!isWorkoutOnCurrentDay && !isWorkoutOnNextDay) {
                    // No workout today or next day
//                    return false
                    shouldBeMissed = true;
                    continue;
                } else if (isWorkoutOnCurrentDay) {
                    // Normal workout day
                    return WorkoutDayStatus.WORKOUT_DAY
                } else {
//                    return false
                    shouldBeMissed = true;
                    continue;
                }
            }
        }

        let currentDate = Date()
        if let lastStreakEndDate = streaks.last?.last, date > lastStreakEndDate && date <= currentDate {
//            return false
            shouldBeMissed = true;
        }
        
        if (shouldBeMissed) {
            if !hasBreakDaysInWeek(date: startOfDate, numberOfBreakDays: breakDaysPerWeek) {
                // mark day as automatic break day
                markDayAsAutomaticBreakDay(date: startOfDate)
                return WorkoutDayStatus.BREAK_DAY
            }
            return WorkoutDayStatus.MISSED_DAY
        }
        
        // Date is outside the range of all streaks and isn't up to the current day
        return WorkoutDayStatus.NOT_IN_STREAK
    }
    
    func markDayAsAutomaticBreakDay(date: Date) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        automaticBreakDays.insert(startOfDay)
        saveAutomaticBreakDays()
    }

    func unmarkDayAsAutomaticBreakDay(date: Date) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        automaticBreakDays.remove(startOfDay)
        saveAutomaticBreakDays()
    }

    func markDayAsBreakDay(date: Date) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        customBreakDays.insert(startOfDay)
        saveBreakDays()
    }

    func unmarkDayAsBreakDay(date: Date) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        customBreakDays.remove(startOfDay)
        saveBreakDays()
    }
    
    private func saveBreakDays() {
        let dates = Array(customBreakDays).map { $0.timeIntervalSince1970 }
        UserDefaults.standard.set(dates, forKey: "breakDays")
    }

    private func loadBreakDays() {
        if let dates = UserDefaults.standard.array(forKey: "breakDays") as? [TimeInterval] {
            customBreakDays = Set(dates.map(Date.init(timeIntervalSince1970:)))
        } else {
            customBreakDays = Set()
        }
    }
    
    func clearAutoBreakDays() {
        UserDefaults.standard.removeObject(forKey: "autoBreakDays")
        automaticBreakDays.removeAll()
        calculateAndStoreStreaks()
    }
    
    private func saveAutomaticBreakDays() {
        let dates = Array(automaticBreakDays).map { $0.timeIntervalSince1970 }
        UserDefaults.standard.set(dates, forKey: "autoBreakDays")
    }

    private func loadAutomaticBreakDays() {
        if let dates = UserDefaults.standard.array(forKey: "autoBreakDays") as? [TimeInterval] {
            automaticBreakDays = Set(dates.map(Date.init(timeIntervalSince1970:)))
        } else {
            automaticBreakDays = Set()
        }
    }
    
    func getPenaltyPerDay() -> Int {
        return penaltyPerDay
    }
}


extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components)!
    }
}
