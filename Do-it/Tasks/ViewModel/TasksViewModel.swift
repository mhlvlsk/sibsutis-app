import Foundation
import SwiftSDK

class TasksViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var showAddTask: Bool = false
    @Published var users: [BackendlessUser] = []
    
    // Новая структура для отображения в UI
    struct AssignedUserInfo: Identifiable {
        let id: String // userId
        let email: String
        let fullname: String
        let status: String
    }
    
    // Новое @Published свойство для хранения назначенных пользователей
    @Published var assignedUsers: [AssignedUserInfo] = []
    
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
                
                // Шаг C.1: Создать словарь [taskId: (status, userTaskId)] - исправленный вариант
                let userTaskInfoMap = assignedUserTasks.reduce(into: [String: (status: String?, userTaskId: String?)]()) { dictionary, userTask in
                    if let taskId = userTask.taskId {
                        dictionary[taskId] = (userTask.status, userTask.objectId)
                    }
                }
                
                self.dataStore.find(queryBuilder: taskQueryBuilder) { backendTasks in
                    if let backendTasks = backendTasks as? [BackendTask] {
                        let tasks = backendTasks.map { backendTask -> Task in
                            var task = backendTask.toTask()
                            // Добавляем персональный статус и ID назначения
                            if let taskId = task.objectId, let info = userTaskInfoMap[taskId] {
                                task.userStatus = info.status
                                task.userTaskId = info.userTaskId
                            }
                            return task
                        }
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
    
    func assignTask(task: Task, toUserIds userIds: Set<String>) {
        guard let taskId = task.objectId else {
            print("❌ Error: Task ID is missing. Cannot assign task.")
            return
        }
        
        if userIds.isEmpty {
            print("No users selected to assign the task.")
            return
        }
        
        let userTasks = userIds.map { userId -> UserTask in
            let userTask = UserTask()
            userTask.status = "new"
            userTask.taskId = taskId
            userTask.userId = userId
            return userTask
        }
        
        Backendless.shared.data.of(UserTask.self).bulkCreate(entities: userTasks) { createdIds in
            print("✅ Successfully bulk created \(createdIds.count ?? 0) UserTask entries. Task '\(taskId)' assigned to users.")
        } errorHandler: { fault in
            print("❌ Failed to bulk assign task: \(fault.message ?? "unknown error")")
        }
    }
    
    func fetchAssignedUsers(for task: Task) {
        guard let taskId = task.objectId else {
            print("Cannot fetch assigned users: Task ID is nil.")
            return
        }
        
        let userTasksStore = Backendless.shared.data.of(UserTask.self)
        let queryBuilder = DataQueryBuilder()
        queryBuilder.whereClause = "taskId = '\(taskId)'"
        
        // 1. Найти все назначения для этой задачи
        userTasksStore.find(queryBuilder: queryBuilder) { [weak self] userTasks in
            guard let self = self,
                  let assignedUserTasks = userTasks as? [UserTask],
                  !assignedUserTasks.isEmpty else {
                print("No users assigned to this task.")
                DispatchQueue.main.async {
                    self?.assignedUsers = []
                }
                return
            }
            
            // 2. Собрать ID всех назначенных пользователей
            let userIds = assignedUserTasks.compactMap { $0.userId }
            guard !userIds.isEmpty else { return }
            
            // 3. Создать словарь [userId: status] для быстрого доступа (исправленный вариант)
            let statusMap = assignedUserTasks.reduce(into: [String: String]()) { dictionary, userTask in
                if let userId = userTask.userId, let status = userTask.status {
                    dictionary[userId] = status
                }
            }
            
            // 4. Загрузить полные данные этих пользователей
            let userQueryBuilder = DataQueryBuilder()
            let userIdsString = userIds.map { "'\($0)'" }.joined(separator: ",")
            userQueryBuilder.whereClause = "objectId IN (\(userIdsString))"
            
            Backendless.shared.data.of(BackendlessUser.self).find(queryBuilder: userQueryBuilder) { backendlessUsers in
                guard let users = backendlessUsers as? [BackendlessUser] else { return }
                
                // 5. Создать массив AssignedUserInfo
                let assignedUsersInfo = users.compactMap { user -> AssignedUserInfo? in
                    guard let userId = user.objectId,
                          let email = user.email,
                          let fullname = user.properties["fullname"] as? String,
                          let status = statusMap[userId] else {
                        return nil
                    }
                    return AssignedUserInfo(id: userId, email: email, fullname: fullname, status: status)
                }
                
                DispatchQueue.main.async {
                    self.assignedUsers = assignedUsersInfo
                    print("✅ Successfully fetched assigned users: \(assignedUsersInfo.count)")
                }
                
            } errorHandler: { fault in
                print("❌ Failed to fetch user details for assigned tasks: \(fault.message ?? "unknown error")")
            }
        } errorHandler: { fault in
            print("❌ Failed to load user's task assignments: \(fault.message ?? "unknown error")")
        }
    }
    
    func clearAssignedUsers() {
        self.assignedUsers = []
    }
    
    // Переименовываем и обновляем метод для работы со статусом UserTask
    func updateTaskStatus(task: Task) {
        // Эта функция теперь только для обычных пользователей
        guard !isManager,
              let userTaskId = task.userTaskId,
              let taskId = task.objectId,
              let currentUserId = Backendless.shared.userService.currentUser?.objectId,
              let currentStatus = task.userStatus else {
            print("❌ Cannot update status. Not a regular user or task/user info is missing.")
            return
        }

        let newStatus = (currentStatus == "выполнено") ? "невыполнено" : "выполнено"

        // Создаем ПОЛНЫЙ объект для обновления, чтобы не затереть другие поля
        let userTaskToUpdate = UserTask()
        userTaskToUpdate.objectId = userTaskId
        userTaskToUpdate.status = newStatus
        userTaskToUpdate.taskId = taskId // <-- ВАЖНО: сохраняем ID задачи
        userTaskToUpdate.userId = currentUserId // <-- ВАЖНО: сохраняем ID пользователя
        userTaskToUpdate.ownerId = currentUserId // <-- ВАЖНО: сохраняем владельца записи

        Backendless.shared.data.of(UserTask.self).save(entity: userTaskToUpdate) { [weak self] updatedUserTask in
            print("✅ Successfully updated user task status to '\(newStatus)'")
            // Обновляем локальные данные для мгновенного отклика UI
            DispatchQueue.main.async {
                if let index = self?.tasks.firstIndex(where: { $0.id == task.id }) {
                    self?.tasks[index].userStatus = newStatus
                }
            }
        } errorHandler: { fault in
            print("❌ Failed to update user task status: \(fault.message ?? "unknown error")")
        }
    }
}

extension Notification.Name {
    static let tasksChanged = Notification.Name("tasksChanged")
}


