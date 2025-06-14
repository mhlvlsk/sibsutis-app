import Foundation
import SwiftSDK

class TasksViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var showAddTask: Bool = false
    @Published var users: [BackendlessUser] = []
    
    // Централизованное свойство для роли менеджера
    @Published var isManager: Bool = false
    
    private var currentUser: String? {
        UserDefaults.standard.string(forKey: "currentUser")
    }
    
    private let dataStore = Backendless.shared.data.of(BackendTask.self)
    
    init() {
        // Мы больше не вызываем loadTasksFromServer напрямую.
        // Вместо этого мы запускаем процесс обновления пользователя.
        refreshCurrentUserAndLoadTasks()
    }
    
    // Шаг 1: Новый метод, который получает роли ПЕРЕД загрузкой задач
    func refreshCurrentUserAndLoadTasks() {
        // Проверяем, есть ли залогиненный пользователь
        guard let currentUser = Backendless.shared.userService.currentUser else {
            print("No logged in user found on app start.")
            // Если пользователя нет, очищаем список задач
            DispatchQueue.main.async {
                self.tasks = []
                self.isManager = false
            }
            return
        }
        
        print("User is logged in. Fetching user roles from server...")
        
        // Используем специальный метод для получения ролей
        Backendless.shared.userService.getUserRoles { roles in
            print("✅ User roles fetched successfully. Roles found: \(roles)")
            
            // Теперь мы можем надежно проверить, является ли пользователь менеджером
            let isManager = roles.contains("Manager")
            DispatchQueue.main.async {
                self.isManager = isManager
            }
            
            // Загружаем задачи, зная точную роль пользователя
            self.loadTasksFromServer(with: roles)
            
        } errorHandler: { fault in
            print("❌ Failed to fetch user roles: \(fault.message ?? "unknown error")")
            // Даже если не удалось получить роли, попробуем загрузить задачи с пустым списком ролей
            self.loadTasksFromServer(with: [])
        }
    }
    
    // Новая простая функция для вызова из UI
    func refreshData() {
        refreshCurrentUserAndLoadTasks()
    }
    
    func addTaskToServer(subject: String, title: String, date: String, info: String = "") {
        guard let currentUser = Backendless.shared.userService.currentUser else {
            print("Error: Current user not found. Cannot set creator.")
            return
        }
        
        let backendTask = BackendTask(subject: subject, title: title, date: date, info: info, creatorId: currentUser.objectId)
        
        logTaskBeforeSave(backendTask, axtion: "CREATING")

        dataStore.save(entity: backendTask, responseHandler: { savedTask in
            if let savedTask = savedTask as? BackendTask, let objectId = savedTask.objectId {
                print("✅ Task successfully saved to Backendless: \(savedTask)")
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
        
        guard let objectId = task.objectId else {
            print("Cannot delete task from server: objectId is nil")
            return
        }
        
        let backendTask = BackendTask()
        backendTask.objectId = objectId
        
        dataStore.remove(entity: backendTask, responseHandler: { removed in
            print("Task successfully deleted from Backendless. Object ID: \(objectId)")
        }, errorHandler: { fault in
            print("Failed to delete task from Backendless: \(fault.message ?? "Unknown error")")
        })
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
            
            guard let currentUser = Backendless.shared.userService.currentUser else {
                print("Error: Current user not found. Cannot set creator.")
                return
            }
            
            let backendTask = BackendTask(from: updatedTask)
            backendTask.objectId = objectId
            backendTask.creatorId = currentUser.objectId
            
            logTaskBeforeSave(backendTask, axtion: "UPDATING")
            
            dataStore.save(entity: backendTask, responseHandler: { savedTask in
                if let savedTask = savedTask as? BackendTask, let objectId = savedTask.objectId {
                    print("✅ Task successfully updated on Backendless: \(savedTask)")
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
    
    func loadTasksFromServer(with roles: [String]) {
        guard let currentUser = Backendless.shared.userService.currentUser,
              let currentUserId = currentUser.objectId else {
            print("No authenticated user. Clearing local tasks.")
            DispatchQueue.main.async {
                self.tasks = []
                self.saveTasks()
            }
            return
        }
        
        let isManager = roles.contains("Manager")
        
        // Обновляем наше @Published свойство, чтобы UI отреагировал
        DispatchQueue.main.async {
            self.isManager = isManager
        }
        
        if isManager {
            // 2. Логика для Менеджера: загружаем все созданные им задачи
            print("User is a Manager. Loading created tasks.")
            let queryBuilder = DataQueryBuilder()
            // Используем ownerId - это надежнее, чем наше кастомное поле creatorId
            queryBuilder.whereClause = "ownerId = '\(currentUserId)'"
            
            dataStore.find(queryBuilder: queryBuilder, responseHandler: { backendTasks in
                if let backendTasks = backendTasks as? [BackendTask] {
                    let tasks = backendTasks.map { $0.toTask() }
                    DispatchQueue.main.async {
                        self.tasks = tasks
                        self.saveTasks()
                        print("✅ Manager tasks loaded from server: \(tasks.count)")
                    }
                }
            }, errorHandler: { fault in
                print("❌ Failed to load manager tasks from server: \(fault.message ?? "Unknown error")")
            })
        } else {
            // 3. Логика для обычного Пользователя: загружаем назначенные ему задачи
            print("User is a regular User. Loading assigned tasks.")
            let userTasksStore = Backendless.shared.data.of(UserTask.self)
            let queryBuilder = DataQueryBuilder()
            queryBuilder.whereClause = "userId = '\(currentUserId)'"
            
            // Шаг A: Найти все назначения для этого пользователя
            userTasksStore.find(queryBuilder: queryBuilder) { userTasks in
                guard let assignedUserTasks = userTasks as? [UserTask], !assignedUserTasks.isEmpty else {
                    print("No tasks assigned to this user. Clearing local tasks.")
                    DispatchQueue.main.async {
                        self.tasks = []
                        self.saveTasks()
                    }
                    return
                }
                
                // Шаг B: Собрать ID всех назначенных задач
                let taskIds = assignedUserTasks.compactMap { $0.taskId }
                guard !taskIds.isEmpty else {
                    print("Assigned tasks have no valid Task IDs.")
                    return
                }
                print("Found assigned task IDs: \(taskIds)")

                // Шаг C: Загрузить полные данные этих задач
                let taskQueryBuilder = DataQueryBuilder()
                let taskIdsString = taskIds.map { "'\($0)'" }.joined(separator: ",")
                taskQueryBuilder.whereClause = "objectId IN (\(taskIdsString))"
                
                self.dataStore.find(queryBuilder: taskQueryBuilder) { backendTasks in
                    if let backendTasks = backendTasks as? [BackendTask] {
                        let tasks = backendTasks.map { $0.toTask() }
                        DispatchQueue.main.async {
                            self.tasks = tasks
                            self.saveTasks()
                            print("✅ Assigned tasks loaded from server: \(tasks.count)")
                        }
                    }
                } errorHandler: { fault in
                    print("❌ Failed to load details of assigned tasks: \(fault.message ?? "Unknown error")")
                }
            } errorHandler: { fault in
                print("❌ Failed to load user's task assignments: \(fault.message ?? "Unknown error")")
            }
        }
    }
    
    private func logTaskBeforeSave(_ task: BackendTask, axtion: String) {
        print("------- 🔬 TASK DEBUG: \(axtion) 🔬 -------")
        let mirror = Mirror(reflecting: task)
        for child in mirror.children {
            if let label = child.label {
                print("  > \(label): \(child.value)")
            }
        }
        print("------------------------------------")
    }
    
    private func notifyTasksChanged() {
        NotificationCenter.default.post(name: .tasksChanged, object: nil)
    }
    
    func fetchAllUsers() {
        let queryBuilder = DataQueryBuilder()
        if let currentUserId = Backendless.shared.userService.currentUser?.objectId {
            queryBuilder.whereClause = "objectId != '\(currentUserId)'"
        }
        
        Backendless.shared.data.of(BackendlessUser.self).find(queryBuilder: queryBuilder) { allUsers in
            if let allUsers = allUsers as? [BackendlessUser] {
                DispatchQueue.main.async {
                    self.users = allUsers
                    print("✅ Successfully fetched \(allUsers.count) users.")
                }
            }
        } errorHandler: { fault in
            print("❌ Failed to fetch users: \(fault.message ?? "unknown error")")
        }
    }
    
    func assignTask(task: Task, toUser user: BackendlessUser) {
        guard let taskId = task.objectId, let userId = user.objectId else {
            print("❌ Error: Task ID or User ID is missing. Cannot assign task.")
            return
        }
        
        let userTask = UserTask()
        userTask.status = "new"
        userTask.taskId = taskId
        userTask.userId = userId
        
        Backendless.shared.data.of(UserTask.self).save(entity: userTask) { savedUserTask in
            print("✅ Successfully created UserTask entry. Task '\(taskId)' assigned to user '\(userId)'.")
        } errorHandler: { fault in
            print("❌ Failed to assign task: \(fault.message ?? "unknown error")")
        }
    }
}

extension Notification.Name {
    static let tasksChanged = Notification.Name("tasksChanged")
}


