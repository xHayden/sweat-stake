import SwiftUI

struct ContentView: View {
    let workoutViewModel: WorkoutViewModel
    @AppStorage("selectedTab") private var selectedTab: Int = 1

    init(viewModel: WorkoutViewModel = WorkoutViewModel()) {
        self.workoutViewModel = viewModel
    }

    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                   HStack {
                       NavTabButton(title: "Workouts", isSelected: $selectedTab, tag: 1)
                       NavTabButton(title: "Calendar", isSelected: $selectedTab, tag: 2)
                       NavTabButton(title: "Settings", isSelected: $selectedTab, tag: 3)
                   }
                   .padding([.horizontal])
                   .padding([.vertical], 5)
               }
                ScrollView {
                    switch selectedTab {
                    case 1:
                        OverviewPageView(workoutViewModel: workoutViewModel)
                    case 2:
                        HistoricalPaymentsPageView(workoutViewModel: workoutViewModel)
                    case 3:
                        SettingsPageView(workoutViewModel: workoutViewModel)
                    default:
                        EmptyView()
                    }
                }
            }
            .background(Color(uiColor: hexStringToUIColor(hex: "#403d39")))
        }
        .background(Color(uiColor: hexStringToUIColor(hex: "#403d39")))
    }
}


struct NavTabButton: View {
    var title: String
    @Binding var isSelected: Int
    var tag: Int

    var body: some View {
        Button(action: {
            self.isSelected = tag
        }) {
            Text(title)
                .foregroundColor(isSelected == tag ? Color(uiColor: hexStringToUIColor(hex: "#FFFFFF")) : Color(uiColor: hexStringToUIColor(hex: "#878787")))
                .padding([.horizontal], 23)
                .padding([.vertical], 8)
                .background(isSelected == tag ? Color(uiColor: hexStringToUIColor(hex: "#0a0a0a")) : Color(uiColor: hexStringToUIColor(hex: "#252422")))
                .cornerRadius(100)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: WorkoutViewModel.previewViewModel())
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

