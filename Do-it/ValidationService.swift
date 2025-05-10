import Foundation

class ValidationService {
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
    
    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    static func isValidName(_ name: String) -> Bool {
        let nameRegex = "^[a-zA-Z ]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return predicate.evaluate(with: name)
    }
}
