import Foundation
import SwiftSDK

struct User: Codable, Equatable {
    let email: String
    let password: String
    let fullname: String
}

struct Task: Identifiable, Codable, Hashable {
    let id: UUID
    var objectId: String?
    var ownerId: String? 
    var subject: String
    var title: String
    var date: String
    var info: String
    var isCompleted: Bool
    
    // Меняем сложный объект на простой String, чтобы Codable работал правильно
    var creatorId: String?
    
    init(subject: String, title: String, date: String, info: String, isCompleted: Bool = false, objectId: String? = nil, ownerId: String? = nil, creatorId: String? = nil) {
        self.id = UUID()
        self.objectId = objectId
        self.ownerId = ownerId
        self.subject = subject
        self.title = title
        self.date = date
        self.info = info
        self.isCompleted = isCompleted
        self.creatorId = creatorId
    }
    
    func parseDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMM yyyy, HH:mm"
        return formatter.date(from: dateString) ?? Date()
    }
}

class BackendTask: NSObject {
    @objc dynamic var objectId: String?
    @objc dynamic var ownerId: String?
    @objc dynamic var subject: String
    @objc dynamic var title: String
    @objc dynamic var date: String
    @objc dynamic var info: String
    @objc dynamic var isCompleted: Bool
    
    // Меняем сложное поле-связь на простое текстовое поле ID
    @objc dynamic var creatorId: String?
    
    override init() {
        self.subject = ""
        self.title = ""
        self.date = ""
        self.info = ""
        self.isCompleted = false
        super.init()
    }
    
    // Обновляем init, чтобы он принимал creatorId
    init(subject: String, title: String, date: String, info: String, isCompleted: Bool = false, creatorId: String? = nil) {
        self.subject = subject
        self.title = title
        self.date = date
        self.info = info
        self.isCompleted = isCompleted
        self.creatorId = creatorId
        super.init()
    }
    
    // Обновляем convenience init
    convenience init(from task: Task) {
        self.init(subject: task.subject, title: task.title, date: task.date, info: task.info, isCompleted: task.isCompleted, creatorId: task.creatorId)
        self.objectId = task.objectId
        self.ownerId = task.ownerId
    }
    
    // Обновляем toTask, чтобы он использовал creatorId
    func toTask() -> Task {
        Task(subject: subject, title: title, date: date, info: info, isCompleted: isCompleted, objectId: objectId, ownerId: ownerId, creatorId: creatorId)
    }
}

// Это новая модель для таблицы `UserTasks`, которая связывает задачи и пользователей.
// Она будет хранить статус выполнения конкретной задачи для конкретного пользователя.
class UserTask: NSObject {
    @objc dynamic var objectId: String?
    @objc dynamic var ownerId: String?
    
    // Статус задачи: "new", "in_progress", "completed"
    @objc dynamic var status: String?
    
    // Используем ID вместо прямых связей для надежности
    @objc dynamic var taskId: String?
    @objc dynamic var userId: String?
}
