import SwiftUI

struct CalendarPage: View {
    @State private var selectedDate = Date()
    @ObservedObject var tasksViewModel: TasksViewModel
    
    var body: some View {
        ZStack {
            GradientBackgroundView()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Calendar")
                    .font(.custom("Inter-SemiBold", size: 18))
                    .foregroundColor(.white)
                
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .background(Color.white)
                .cornerRadius(10)
                .frame(width: 380, height: 285)
                .padding(.top, 30)
                .padding()
                
                ScrollView {
                    if tasksForSelectedDate.isEmpty {
                        Text("No tasks for this date.")
                            .font(.custom("Poppins", size: 16))
                            .foregroundColor(.white)
                            .padding()
                    } else {
                        ForEach(tasksForSelectedDate) { task in
                            TaskRow(task: task)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding()
                .frame(maxHeight: .infinity)
            }
            .padding()
        }
        .onAppear {
            subscribeToNotifications()
        }
        .onDisappear {
            unsubscribeFromNotifications()
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private var tasksForSelectedDate: [Task] {
        tasksViewModel.tasks.filter { task in
            let taskDate = parseDate(task.date)
            return Calendar.current.isDate(taskDate, inSameDayAs: selectedDate)
        }
    }
    
    private func parseDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy h:mm a"
        return formatter.date(from: dateString) ?? Date()
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(
            forName: .tasksChanged,
            object: nil,
            queue: .main
        ) { _ in
            tasksViewModel.loadTasks()
        }
    }
    
    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self, name: .tasksChanged, object: nil)
    }
}
