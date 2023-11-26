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
        @Published var workouts: [WorkoutDataProtocol] = []

        init(workouts: [WorkoutDataProtocol] = []) {
            self.workouts = workouts
            self.healthStore = HKHealthStore.isHealthDataAvailable() ? HKHealthStore() : nil
        }
    
        var totalWorkoutHoursThisMonth: Int {
                let calendar = Calendar.current
                let currentDate = Date()
                let workoutsThisMonth = workouts.filter {
                    if let startDate = $0.startDate {
                        let components = calendar.dateComponents([.year, .month], from: startDate)
                        let startOfMonth = calendar.date(from: components)
                        return startOfMonth == calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))
                    }
                    return false
                }

                let totalSeconds = workoutsThisMonth.reduce(0.0) { (result, workout) in
                    if let duration = workout.duration {
                        return result + duration
                    }
                    return result
                }

                // Convert totalSeconds to hours (rounded)
                let totalHours = Int(totalSeconds / 3600)

                return totalHours
            }

            var averageWorkoutLength: TimeInterval {
                let workoutsWithDuration = workouts.filter { $0.duration != nil }
                let totalDuration = workoutsWithDuration.reduce(0.0) { (result, workout) in
                    if let duration = workout.duration {
                        return result + duration
                    }
                    return result
                }

                // Calculate the average duration in seconds
                let averageDuration = totalDuration / Double(workoutsWithDuration.count)

                return averageDuration
            }

        var missedDaysThisMonth: Int {
            let calendar = Calendar.current
            let currentDate = Date()
            
            // Create a Set to store unique dates
            var uniqueDates = Set<String>()
            
            for workout in workouts {
                if let startDate = workout.startDate {
                    let components = calendar.dateComponents([.year, .month, .day], from: startDate)
                    let dateKey = "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
                    uniqueDates.insert(dateKey)
                }
            }

            let totalDaysThisMonth = calendar.range(of: .day, in: .month, for: currentDate)?.count ?? 0

            let missedDays = totalDaysThisMonth - uniqueDates.count

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
                        print("HealthKit authorization granted.")
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
                        
                        print("Fetched \(workouts.count) workouts:")
//                        for workout in workouts {
//                            print("Workout ID: \(workout.uuid), Type: \(workout.workoutActivityType), Duration: \(workout.duration), Start Date: \(workout.startDate), End Date: \(String(describing: workout.endDate))")
//                        }

                        self?.workouts = workouts.map { workout in
                            WorkoutData(
                                id: UUID(),
                                type: workout.workoutActivityType,
                                duration: workout.duration,
                                startDate: workout.startDate,
                                endDate: workout.endDate
                            )
                        }
                        
                        
                    }
                }
                healthStore.execute(query)
            }
    }
