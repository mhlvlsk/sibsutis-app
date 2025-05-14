import SwiftUI

struct SettingsPage: View {
    
    @State private var logOutAlert: Bool = false
    
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
                    }) {
                        HStack {
                            Image(systemName: "message.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 25, height: 25)
                            
                            Text("Диалоги")
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
                    }) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 25, height: 25)
                            
                            Text("Проекты")
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
                    }) {
                        HStack {
                            Image(systemName: "doc.text.magnifyingglass")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 25, height: 25)
                            
                            Text("Пользовательское соглашение")
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
                                logout()
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
        }
    }
    
    
    private func logout() {
        
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.removeObject(forKey: "lastUserEmail")
        UserDefaults.standard.removeObject(forKey: "lastUserPassword")
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = scene.windows.first {
                window.rootViewController = UIHostingController(rootView: SignIn())
                window.makeKeyAndVisible()
            }
        }
    }
}





