import Foundation

class TasksViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var showAddTask: Bool = false
    
    private var currentUser: String? {
        UserDefaults.standard.string(forKey: "currentUser")
    }
    
    init() {
        loadTasks()
    }
    
    func addTask(subject: String, title: String, date: String, info: String = "") {
        let newTask = Task(subject: subject, title: title, date: date, info: info)
        tasks.append(newTask)
        saveTasks()
        notifyTasksChanged()
    }

    func deleteTask(task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
        notifyTasksChanged()
    }
    
    func updateTask(subject: String, task: Task, title: String, date: String, info: String) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].subject = subject
            tasks[index].title = title
            tasks[index].date = date
            tasks[index].info = info
            notifyTasksChanged()
        }
    }
    
    func toggleTaskCompletion(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveTasks()
            notifyTasksChanged()
        }
    }
    
    private func saveTasks() {
        guard let currentUser = currentUser else { return }
        
        let encoder = JSONEncoder()
        if let encodedTasks = try? encoder.encode(tasks) {
            UserDefaults.standard.set(encodedTasks, forKey: "tasks_\(currentUser)")
        }
    }
    
    func loadTasks() {
        guard let currentUser = currentUser else { return }
        
        let decoder = JSONDecoder()
        if let savedTasksData = UserDefaults.standard.data(forKey: "tasks_\(currentUser)"),
           let savedTasks = try? decoder.decode([Task].self, from: savedTasksData) {
            tasks = savedTasks
        }
    }
    
    private func notifyTasksChanged() {
        NotificationCenter.default.post(name: .tasksChanged, object: nil)
    }
}

extension Notification.Name {
    static let tasksChanged = Notification.Name("tasksChanged")
}
