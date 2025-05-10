import Foundation

class SignInViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var isAuthenticated: Bool = false 
    
    init() {
        autoSignIn()
    }
    
    func signIn() {
        guard ValidationService.isValidEmail(email) else {
            alertMessage = "Invalid email address."
            showAlert = true
            return
        }
        
        guard ValidationService.isValidPassword(password) else {
            alertMessage = "Password must be at least 6 characters."
            showAlert = true
            return
        }
        
        if let usersData = UserDefaults.standard.data(forKey: "users"),
           let users = try? JSONDecoder().decode([User].self, from: usersData) {
            
            if let user = users.first(where: { $0.email == email && $0.password == password }) {
                UserDefaults.standard.set(user.email, forKey: "currentUser")
                
                UserDefaults.standard.set(user.email, forKey: "lastUserEmail")
                UserDefaults.standard.set(user.password, forKey: "lastUserPassword")

                isAuthenticated = true
            } else {
                alertMessage = "Can't sign in. Invalid email or password."
                showAlert = true
            }
        } else {
            alertMessage = "No users found. Please sign up first."
            showAlert = true
        }
    }
    
    func autoSignIn() {
        if let savedEmail = UserDefaults.standard.string(forKey: "lastUserEmail"),
           let savedPassword = UserDefaults.standard.string(forKey: "lastUserPassword") {
            
            email = savedEmail
            password = savedPassword
            isAuthenticated = true
        }
    }
}
