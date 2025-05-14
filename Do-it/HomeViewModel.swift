import Foundation

class HomeViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var userName: String = "Неизвестный пользователь"
    @Published var userEmail: String = "user@example.com"
    
    private var currentUser: String? {
        UserDefaults.standard.string(forKey: "currentUser")
    }
    
    init() {
        loadUserData()
        loadTasks()
    }
    
    func loadUserData() {
        guard let currentUserEmail = currentUser else { return }
        
        if let userData = UserDefaults.standard.data(forKey: "users"),
           let users = try? JSONDecoder().decode([User].self, from: userData) {
            
            if let currentUser = users.first(where: { $0.email == currentUserEmail }) {
                userName = currentUser.fullname
                userEmail = currentUser.email
            } else {
                userName = "Unknown User"
                userEmail = "Unknown Email"
            }
        }
    }
    
    func loadTasks() {
        guard let currentUser = currentUser else { return }
        
        let decoder = JSONDecoder()
        if let savedTasksData = UserDefaults.standard.data(forKey: "tasks_\(currentUser)"),
           let savedTasks = try? decoder.decode([Task].self, from: savedTasksData) {
            self.tasks = savedTasks
        }
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
