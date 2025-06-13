import SwiftUI
import SwiftSDK

struct SettingsPage: View {
    @State private var logOutAlert: Bool = false
    @State private var isLoggingOut: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackgroundView()
                
                VStack(spacing: 0) {
                    Button(action: {
                    }) {
                        HStack {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 25, height: 25)
                            
                            Text("Профиль")
                                .font(.custom("Flame", size: 18))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(UIColor(red: 0.527, green: 0.857, blue: 0.929, alpha: 1)))
                        }
                        .padding(.horizontal, 20)
                        .frame(height: 60)
                        .overlay(
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(.gray)
                                .offset(y: 30)
                        )
                    }
                    
                    Button(action: {
                        logOutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "door.right.hand.open")
                                .font(.system(size: 18))
                                .foregroundColor(Color(UIColor(red: 0.863, green: 0.262, blue: 0.262, alpha: 1)))
                            Text("Выйти")
                                .font(.custom("Flame", size: 18))
                                .foregroundColor(Color(UIColor(red: 0.863, green: 0.262, blue: 0.262, alpha: 1)))
                        }
                        .frame(width: 226, height: 42)
                        .background(.white)
                        .cornerRadius(25)
                        .padding(.top, 80)
                    }
                    .alert(isPresented: $logOutAlert) {
                        Alert(
                            title: Text("Выйти"),
                            message: Text("Вы действительно хотите выйти?"),
                            primaryButton: .destructive(Text("Да")) {
                                isLoggingOut = true
                                logout { success in
                                    if success {
                                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                           let window = scene.windows.first {
                                            window.rootViewController = UIHostingController(rootView: SignIn())
                                            window.makeKeyAndVisible()
                                        }
                                    } else {
                                        isLoggingOut = false
                                        logOutAlert = true
                                    }
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    
                    Spacer()
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .safeAreaPadding(.top, 100)
            }
            .ignoresSafeArea()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Настройки")
                        .font(.custom("Inter-SemiBold", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(isLoggingOut)
        }
    }
    
    private func logout(completion: @escaping (Bool) -> Void) {
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.removeObject(forKey: "lastUserEmail")
        UserDefaults.standard.removeObject(forKey: "lastUserPassword")
        
        Backendless.shared.userService.logout(responseHandler: {
            print("User logged out successfully")
            completion(true)
        }, errorHandler: { fault in
            print("Logout failed: \(fault.message ?? "")")
            completion(false)
        })
    }
}
