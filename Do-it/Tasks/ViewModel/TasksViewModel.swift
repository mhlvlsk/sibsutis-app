import Foundation
import SwiftSDK

class TasksViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var showAddTask: Bool = false
    
    private var currentUser: String? {
        UserDefaults.standard.string(forKey: "currentUser")
    }
    
    private let dataStore = Backendless.shared.data.of(BackendTask.self)
    
    init() {
        loadTasksFromServer()
        loadTasks()
    }
    
    func addTaskToServer(subject: String, title: String, date: String, info: String = "") {
        let backendTask = BackendTask(subject: subject, title: title, date: date, info: info)
        
        dataStore.save(entity: backendTask, responseHandler: { savedTask in
            if let savedTask = savedTask as? BackendTask, let objectId = savedTask.objectId {
                print("Task successfully saved to Backendless: \(savedTask)")
                print("Object ID: \(objectId)")
                let task = savedTask.toTask()
                DispatchQueue.main.async {
                    self.tasks.append(task)
                    self.saveTasks()
                    self.notifyTasksChanged()
                }
            }
        }, errorHandler: { fault in
            print("Failed to save task to Backendless: \(fault.message ?? "Unknown error")")
        })
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
            
            saveTasks()
            notifyTasksChanged()
            
            let updatedTask = tasks[index]
            guard let objectId = updatedTask.objectId else {
                print("Cannot update task on server: objectId is nil")
                return
            }
            
            let backendTask = BackendTask(from: updatedTask)
            backendTask.objectId = objectId
            
            dataStore.save(entity: backendTask, responseHandler: { savedTask in
                if let savedTask = savedTask as? BackendTask, let objectId = savedTask.objectId {
                    print("Task successfully updated on Backendless: \(savedTask)")
                    print("Object ID: \(objectId)")
                    DispatchQueue.main.async {
                        if let index = self.tasks.firstIndex(where: { $0.id == task.id }) {
                            self.tasks[index] = savedTask.toTask()
                            self.saveTasks()
                        }
                    }
                }
            }, errorHandler: { fault in
                print("Failed to update task on Backendless: \(fault.message ?? "Unknown error")")
            })
        }
    }

    func toggleTaskCompletion(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            
            saveTasks()
            notifyTasksChanged()
            
            let updatedTask = tasks[index]
            guard let objectId = updatedTask.objectId else {
                print("Cannot update task completion on server: objectId is nil")
                return
            }
            
            let backendTask = BackendTask(from: updatedTask)
            backendTask.objectId = objectId
            
            dataStore.save(entity: backendTask, responseHandler: { savedTask in
                if let savedTask = savedTask as? BackendTask, let objectId = savedTask.objectId {
                    print("Task completion successfully updated on Backendless: \(savedTask)")
                    print("Object ID: \(objectId)")
                    DispatchQueue.main.async {
                        if let index = self.tasks.firstIndex(where: { $0.id == task.id }) {
                            self.tasks[index] = savedTask.toTask()
                            self.saveTasks()
                        }
                    }
                }
            }, errorHandler: { fault in
                print("Failed to update task completion on Backendless: \(fault.message ?? "Unknown error")")
            })
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
    
    func loadTasksFromServer() {
        guard let currentUser = Backendless.shared.userService.currentUser else {
            print("No authenticated user")
            return
        }
        
        let queryBuilder = DataQueryBuilder()
        queryBuilder.whereClause = "ownerId = '\(currentUser.objectId ?? "")'"
        
        dataStore.find(queryBuilder: queryBuilder, responseHandler: { tasks in
            if let backendTasks = tasks as? [BackendTask] {
                let tasks = backendTasks.map { $0.toTask() }
                DispatchQueue.main.async {
                    self.tasks = tasks
                    self.saveTasks()
                    print("Tasks loaded from server and saved to UserDefaults: \(tasks.count)")
                }
            }
        }, errorHandler: { fault in
            print("Failed to load tasks from server: \(fault.message ?? "Unknown error")")
        })
    }
    
    private func notifyTasksChanged() {
        NotificationCenter.default.post(name: .tasksChanged, object: nil)
    }
}

extension Notification.Name {
    static let tasksChanged = Notification.Name("tasksChanged")
}


