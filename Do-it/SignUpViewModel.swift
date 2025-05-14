import Foundation

class SignUpViewModel: ObservableObject {
    @Published var fullname: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var isSignedUp: Bool = false  

    func signUp() {
        guard ValidationService.isValidName(fullname) else {
            alertMessage = "Имя может содержать только буквы."
            showAlert = true
            return
        }
        
        guard ValidationService.isValidEmail(email) else {
            alertMessage = "Неверный адрес электронной почты."
            showAlert = true
            return
        }
        
        guard ValidationService.isValidPassword(password) else {
            alertMessage = "Пароль должен содержать минимум 6 символов."
            showAlert = true
            return
        }
        
        var users: [User] = []
        if let usersData = UserDefaults.standard.data(forKey: "users"),
           let decodedUsers = try? JSONDecoder().decode([User].self, from: usersData) {
            users = decodedUsers
        }
        
        if users.contains(where: { $0.email == email }) {
            alertMessage = "Пользователь с таким email уже существует."
            showAlert = true
            return
        }
        
        let newUser = User(email: email, password: password, fullname: fullname)
        users.append(newUser)
        
        if let encodedUsers = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(encodedUsers, forKey: "users")
        }
        
        UserDefaults.standard.set(newUser.email, forKey: "currentUser")
        UserDefaults.standard.set(newUser.email, forKey: "lastUserEmail")
        UserDefaults.standard.set(newUser.password, forKey: "lastUserPassword")
        isSignedUp = true
    }
}
