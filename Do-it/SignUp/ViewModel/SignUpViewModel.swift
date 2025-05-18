import Foundation
import SwiftSDK

class SignUpViewModel: ObservableObject {
    @Published var fullname: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var authState: AuthState = .idle
    @Published var isLoading: Bool = false

    enum AuthState: Equatable {
        case idle
        case loading
        case success
        case error(String)
    }

    func signUp() {
        guard ValidationService.isValidName(fullname) else {
            authState = .error("Имя может содержать только буквы.")
            return
        }
        
        guard ValidationService.isValidEmail(email) else {
            authState = .error("Неверный адрес электронной почты.")
            return
        }
        
        guard ValidationService.isValidPassword(password) else {
            authState = .error("Пароль должен содержать минимум 6 символов.")
            return
        }

        // Шаг 2: Установка состояния загрузки
        authState = .loading
        isLoading = true

        // Шаг 3: Создание объекта BackendlessUser
        let user = BackendlessUser()
        user.email = email
        user.password = password
        user.properties["fullname"] = fullname  // Установка пользовательского свойства

        // Шаг 4: Регистрация пользователя с Backendless
        Backendless.shared.userService.registerUser(user: user, responseHandler: { registeredUser in
            // Регистрация успешна
            print("User registered: \(registeredUser)")
            
            // Шаг 5: Автоматический вход после регистрации
            Backendless.shared.userService.login(identity: self.email, password: self.password, responseHandler: { loggedInUser in
                print("User logged in: \(loggedInUser)")
                DispatchQueue.main.async {
                    self.authState = .success
                    self.isLoading = false
                }
            }, errorHandler: { fault in
                print("Login failed: \(fault.message ?? "")")
                DispatchQueue.main.async {
                    self.authState = .error("Login failed after registration: \(fault.message ?? "")")
                    self.isLoading = false
                }
            })
        }, errorHandler: { fault in
            // Обработка ошибок регистрации
            print("Registration failed: \(fault.message ?? "")")
            DispatchQueue.main.async {
                self.authState = .error("Registration failed: \(fault.message ?? "")")
                self.isLoading = false
            }
        })
    }
}

//import Foundation
//import SwiftSDK
//
//class SignUpViewModel: ObservableObject {
//    @Published var fullname: String = ""
//    @Published var email: String = ""
//    @Published var password: String = ""
//    @Published var showAlert: Bool = false
//    @Published var alertMessage: String = ""
//    @Published var isSignedUp: Bool = false
//
//    func signUp() {
//        guard ValidationService.isValidName(fullname) else {
//            alertMessage = "Имя может содержать только буквы."
//            showAlert = true
//            return
//        }
//        
//        guard ValidationService.isValidEmail(email) else {
//            alertMessage = "Неверный адрес электронной почты."
//            showAlert = true
//            return
//        }
//        
//        guard ValidationService.isValidPassword(password) else {
//            alertMessage = "Пароль должен содержать минимум 6 символов."
//            showAlert = true
//            return
//        }
//        
//        var users: [User] = []
//        if let usersData = UserDefaults.standard.data(forKey: "users"),
//           let decodedUsers = try? JSONDecoder().decode([User].self, from: usersData) {
//            users = decodedUsers
//        }
//        
//        let user = BackendlessUser()
//        user.email = email
//        user.password = password
//        user.properties["fullname"] = fullname
//        
//        Backendless.shared.userService.registerUser(user: user) { registeredUser in
//            // Регистрация успешна
//            print("User registered: \(registeredUser)")
//            
//            // Шаг 4: Автоматический вход после регистрации
//            Backendless.shared.userService.login(identity: self.email, password: self.password) { loggedInUser in
//                print("User logged in: \(loggedInUser)")
//            } errorHandler: { fault in
//                print("Login failed: \(fault.message ?? "")")
//                self.alertMessage = "Login failed after registration"
//                self.showAlert = true
//            }
//        } errorHandler: { fault in
//            print("Registration failed: \(fault.message ?? "")")
//            self.alertMessage = fault.message ?? "Registration failed"
//            self.showAlert = true
//        }
//        
//        if users.contains(where: { $0.email == email }) {
//            alertMessage = "Пользователь с таким email уже существует."
//            showAlert = true
//            return
//        }
//        
//        let newUser = User(email: email, password: password, fullname: fullname)
//        users.append(newUser)
//        
//        if let encodedUsers = try? JSONEncoder().encode(users) {
//            UserDefaults.standard.set(encodedUsers, forKey: "users")
//        }
//        
//        UserDefaults.standard.set(newUser.email, forKey: "currentUser")
//        UserDefaults.standard.set(newUser.email, forKey: "lastUserEmail")
//        UserDefaults.standard.set(newUser.password, forKey: "lastUserPassword")
//        isSignedUp = true
//    }
//}
