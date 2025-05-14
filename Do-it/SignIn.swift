import SwiftUI

struct SignIn: View {
    @StateObject private var viewModel = SignInViewModel()
    @State private var navigateToHomePage: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackgroundView()
                
                VStack(spacing: 15) {
                    Image("CheckmarkLabel")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 83, height: 83)
                    
                    VStack(alignment: .center, spacing: 5) {
                        HStack {
                            Text("С возвращением в")
                                .font(.custom("Flame-Regular", size: 23))
                                .foregroundColor(.white)
                            
                            Text("SIBSUTIS APP")
                                .font(.custom("DarumadropOne-Regular", size: 23))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Продуктивного дня!")
                            .font(.custom("Flame-Regular", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 45)
                        
                        VStack(alignment: .center, spacing: 50) {
                            TextField("", text: $viewModel.email, prompt: Text("E-mail").foregroundColor(.gray))
                                .autocapitalization(.none)
                                .padding()
                                .background(.white)
                                .foregroundColor(.gray)
                                .font(.custom("Flame", size: 18))
                                .frame(width: 360, height: 40)
                                .cornerRadius(5)
                            
                            SecureField("", text: $viewModel.password, prompt: Text("Пароль").foregroundColor(.gray))
                                .autocapitalization(.none)
                                .padding()
                                .background(.white)
                                .foregroundColor(.gray)
                                .font(.custom("Flame", size: 18))
                                .frame(width: 360, height: 40)
                                .cornerRadius(5)
                        }
                        .padding(.bottom, 50)
                        
                        VStack(alignment: .center, spacing: 15) {
                            Button(action: {
                                viewModel.signIn()
                                if viewModel.isAuthenticated {
                                    navigateToHomePage = true
                                }
                            }) {
                                Text("Вход")
                                    .font(.custom("Flame", size: 18))
                                    .foregroundColor(.white)
                                    .frame(width: 360, height: 40)
                                    .background(Color(UIColor(red: 0.055, green: 0.647, blue: 0.914, alpha: 1)))
                                    .cornerRadius(5)
                            }
                            
                            HStack {
                                Text("Нет аккаунта?")
                                    .font(.custom("Flame", size: 14))
                                    .foregroundColor(.white)
                                
                                NavigationLink(destination: SignUp()) {
                                    Text("Зарегистрироваться")
                                        .font(.custom("Flame", size: 14))
                                        .foregroundColor(Color(UIColor(red: 0.055, green: 0.777, blue: 0.914, alpha: 1)))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    Spacer()
                }
                .frame(maxHeight: .infinity, alignment: .center)
                .safeAreaPadding(.top, 70)
                .navigationDestination(isPresented: $navigateToHomePage) {
                    TabBarView()
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Error"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("Ok")))
            }
            .ignoresSafeArea()
        }
        .onAppear {
            if viewModel.isAuthenticated {
                navigateToHomePage = true
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
