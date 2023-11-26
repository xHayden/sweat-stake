import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = WorkoutViewModel()
    var workouts: [WorkoutDataProtocol]?
    
    init(viewModel: WorkoutViewModel = WorkoutViewModel(), workouts: [WorkoutDataProtocol]? = nil) {
        self.viewModel = viewModel
        self.workouts = workouts
    }

    var body: some View {
        ScrollView {
            HStack(spacing: 20) {
                WorkoutCounterView(totalHours: viewModel.totalWorkoutHoursThisMonth,
                                   avgWorkoutLength: viewModel.averageWorkoutLength)
                MissedDaysCounterView(missedDays: viewModel.missedDaysThisMonth,
                                      penaltyPerDay: 20)
            }
            .padding(.vertical)
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(viewModel.workouts, id: \.id) { workout in
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "figure.walk")
                                .foregroundColor(.blue)
                            Text("Type: \(workout.type.commonName)")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(.green)
                            Text("Duration: \(TimeFormatter.shared.format(seconds: workout.duration ?? 0.0) ?? "N/A")")
                                .foregroundColor(.white)
                        }
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.red)
                            Text("Date: \(TimeFormatter.shared.format(date: workout.startDate ?? Date()))")
                                .foregroundColor(.white)
                        }
                    }
                    .padding([.vertical, .horizontal], 20)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .background(Color(uiColor: hexStringToUIColor(hex: "#252422")))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .background(Color(uiColor: hexStringToUIColor(hex: "#403d39")))
                .onAppear {
                    if (workouts == nil) {
                        viewModel.requestHealthKitAuthorization()
                    }
                }
            }
            .background(Color.clear)
            .padding([.horizontal], 20)
        }
        .background(Color(uiColor: hexStringToUIColor(hex: "#403d39")))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: WorkoutViewModel.previewViewModel(),
                    workouts: MockWorkoutData.generateMockData())
    }
}

class TimeFormatter {
    static let shared = TimeFormatter()
    private let numFormatter: DateComponentsFormatter
    private let dateFormatter: DateFormatter
    
    private init() {
        numFormatter = DateComponentsFormatter()
        numFormatter.unitsStyle = .full
        numFormatter.allowedUnits = [.minute, .second]
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
    }

    func format(seconds: TimeInterval) -> String? {
            return numFormatter.string(from: seconds)
    }
    
    func format(date: Date) -> String {
            return dateFormatter.string(from: date)
    }
}

