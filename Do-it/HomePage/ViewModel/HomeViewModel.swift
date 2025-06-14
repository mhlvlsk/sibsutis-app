import Foundation
import SwiftSDK
import Combine

class HomeViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var userName: String = (Backendless.shared.userService.currentUser?.properties["fullname"] as? String ?? "Unknown name")
    @Published var userEmail: String = (Backendless.shared.userService.currentUser?.email ?? "Unknown Email")
    
    private var currentUser: String? {
        UserDefaults.standard.string(forKey: "currentUser")
    }
    
    private let tasksVM = TasksViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        tasksChanges()
        tasksVM.refreshData()
        tasks = tasksVM.tasks
    }
    
    func tasksChanges() {
        tasksVM.objectWillChange
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.tasks = self?.tasksVM.tasks ?? []
                    print("Tasks updated in HomeViewModel: \(self?.tasks.count ?? 0)")
                }
            }
            .store(in: &cancellables)
    }
    
    // Метод для обновления задач
    func refreshTasks() {
        tasksVM.refreshData()
    }
    
    func getUncompletedTasks() -> [Task] {
        return tasks.filter { !$0.isCompleted }
            .sorted { $0.parseDate($0.date) > $1.parseDate($1.date) }
            .prefix(2)
            .map { $0 }
    }

    func getCompletedTasks() -> [Task] {
        return tasks.filter { $0.isCompleted }
            .sorted { $0.parseDate($0.date) > $1.parseDate($1.date) }
            .prefix(2)
            .map { $0 }
    }
}
