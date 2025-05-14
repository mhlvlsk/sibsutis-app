import Foundation

struct User: Codable, Equatable {
    let email: String
    let password: String
    let fullname: String
}

struct Task: Identifiable, Codable, Hashable {
    let id: UUID
    var subject: String
    var title: String
    var date: String
    var info: String
    var isCompleted: Bool
    
    init(subject: String, title: String, date: String, info: String, isCompleted: Bool = false) {
        self.id = UUID()
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
