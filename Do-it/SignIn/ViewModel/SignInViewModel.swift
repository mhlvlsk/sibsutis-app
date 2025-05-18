import Foundation
import SwiftSDK

class SignInViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var authState: AuthState = .idle
    @Published var isAuth: Bool = false
    @Published var isLoading: Bool = false

    enum AuthState: Equatable {
        case idle
        case loading
        case success
        case error(String)
    }

    init() {
        autoSignIn()
    }
    
    func signIn() {
        guard ValidationService.isValidEmail(email) else {
            authState = .error("Неверный адрес электронной почты.")
            return
        }
        
        guard ValidationService.isValidPassword(password) else {
            authState = .error("Пароль должен содержать минимум 6 символов.")
            return
        }

        authState = .loading
        isLoading = true

        Backendless.shared.userService.stayLoggedIn = true

        Backendless.shared.userService.login(identity: email, password: password, responseHandler: { loggedInUser in
            print("User logged in: \(loggedInUser)")
            DispatchQueue.main.async {
                self.authState = .success
                self.isLoading = false
                self.isAuth = true
            }
        }, errorHandler: { fault in
            print("Login failed: \(fault.message ?? "")")
            DispatchQueue.main.async {
                self.authState = .error(fault.message ?? "Login failed")
                self.isLoading = false
            }
        })
    }
    
    func autoSignIn() {
        if let currentUser = Backendless.shared.userService.currentUser {
            DispatchQueue.main.async {
                self.authState = .success
                self.email = currentUser.email ?? ""
                self.isAuth = true
            }
        }
    }
    
    func logout() {
        Backendless.shared.userService.logout(responseHandler: {
            DispatchQueue.main.async {
                self.authState = .idle
                self.isAuth = false
                self.email = ""
                self.password = ""
                print("User logged out")
            }
        }, errorHandler: { fault in
            print("Logout failed: \(fault.message ?? "Unknown error")")
        })
    }
}

//import Foundation
//import SwiftSDK
//
//class SignInViewModel: ObservableObject {
//    @Published var email: String = ""
//    @Published var password: String = ""
//    @Published var authState: AuthState = .idle
//    @Published var isAuth: Bool = false
//    @Published var isLoading: Bool = false
//
//    enum AuthState: Equatable {
//        case idle
//        case loading
//        case success
//        case error(String)
//    }
//
//    init() {
//        autoSignIn()
//    }
//    
//    func signIn() {
//        // Шаг 1: Выполнение клиентской валидации
//        guard ValidationService.isValidEmail(email) else {
//            authState = .error("Неверный адрес электронной почты.")
//            return
//        }
//        
//        guard ValidationService.isValidPassword(password) else {
//            authState = .error("Пароль должен содержать минимум 6 символов.")
//            return
//        }
//
//        // Шаг 2: Установка состояния загрузки
//        authState = .loading
//        isLoading = true
//
//        // Шаг 3: Аутентификация с Backendless
//        Backendless.shared.userService.login(identity: email, password: password, responseHandler: { loggedInUser in
//            print("User logged in: \(loggedInUser)")
//            DispatchQueue.main.async {
//                self.authState = .success
//                self.isLoading = false
//            }
//        }, errorHandler: { fault in
//            print("Login failed: \(fault.message ?? "")")
//            DispatchQueue.main.async {
//                self.authState = .error(fault.message ?? "Login failed")
//                self.isLoading = false
//            }
//        })
//    }
//    
//    func autoSignIn() {
//        if let currentUser = Backendless.shared.userService.currentUser {
//            DispatchQueue.main.async {
//                self.authState = .success
//                self.email = currentUser.email ?? ""
//                self.isAuth = true
//            }
//            print("AUTO SIGN IN WORKED")
//        } else {
//            print("NO AUTO SIGN IN")
//        }
//    }
//}


