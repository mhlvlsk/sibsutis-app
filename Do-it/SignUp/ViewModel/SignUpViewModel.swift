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
        
        Backendless.shared.userService.logout(responseHandler: {
            print("Successfully logged out before registration.")
            self.performRegistration()
        }, errorHandler: { fault in
            print("Could not log out before registration (this is likely okay): \(fault.message ?? "N/A")")
            self.performRegistration()
        })
    }
    
    private func performRegistration() {
        DispatchQueue.main.async {
            self.authState = .loading
            self.isLoading = true
        }

        let user = BackendlessUser()
        user.email = email
        user.password = password
        user.properties["fullname"] = fullname

        Backendless.shared.userService.registerUser(user: user, responseHandler: { registeredUser in
            print("User registered: \(registeredUser)")
            
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
            print("Registration failed: \(fault.message ?? "")")
            DispatchQueue.main.async {
                self.authState = .error("Registration failed: \(fault.message ?? "")")
                self.isLoading = false
            }
        })
    }
}
