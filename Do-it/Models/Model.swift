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
    
    init(subject: String, title: String, date: String, info: String, isCompleted: Bool = false, objectId: String? = nil, ownerId: String? = nil) {
        self.id = UUID()
        self.objectId = objectId
        self.ownerId = ownerId
        self.subject = subject
        self.title = title
        self.date = date
        self.info = info
        self.isCompleted = isCompleted
    }
    
    func parseDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy h:mm a"
        return formatter.date(from: dateString) ?? Date()
    }
}

class BackendTask: NSObject, Codable {
    @objc dynamic var objectId: String?
    @objc dynamic var ownerId: String?
    @objc dynamic var subject: String
    @objc dynamic var title: String
    @objc dynamic var date: String
    @objc dynamic var info: String
    @objc dynamic var isCompleted: Bool
    
    override init() {
        self.subject = ""
        self.title = ""
        self.date = ""
        self.info = ""
        self.isCompleted = false
        super.init()
    }
    
    init(subject: String, title: String, date: String, info: String, isCompleted: Bool = false) {
        self.subject = subject
        self.title = title
        self.date = date
        self.info = info
        self.isCompleted = isCompleted
        super.init()
    }
    
    convenience init(from task: Task) {
        self.init(subject: task.subject, title: task.title, date: task.date, info: task.info, isCompleted: task.isCompleted)
        self.objectId = task.objectId
        self.ownerId = task.ownerId
    }
    
    func toTask() -> Task {
        Task(subject: subject, title: title, date: date, info: info, isCompleted: isCompleted, objectId: objectId, ownerId: ownerId)
    }
}
