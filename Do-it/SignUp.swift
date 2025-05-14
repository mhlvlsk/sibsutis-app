import SwiftUI

struct SignUp: View {
    @StateObject private var viewModel = SignUpViewModel()
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
                            Text("Добро пожаловать в")
                                .font(.custom("Flame", size: 20))
                                .foregroundColor(.white)
                            
                            Text("SIBSUTIS APP")
                                .font(.custom("DarumadropOne-Regular", size: 20))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Создайте аккаунт и начните пользоваться прямо сейчас!")
                            .font(.custom("Flame", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 35)
                        
                        VStack(alignment: .leading, spacing: 35) {
                            TextField("", text: $viewModel.fullname, prompt: Text("Имя и Фамилия").foregroundColor(.gray))
                                .padding()
                                .background(.white)
                                .foregroundColor(.gray)
                                .font(.custom("Flame", size: 18))
                                .frame(width: 360, height: 40)
                                .cornerRadius(5)
                            
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
                        .padding(.bottom, 35)
                        
                        VStack(alignment: .center, spacing: 15) {
                            Button(action: {
                                viewModel.signUp()
                                if viewModel.isSignedUp {
                                    navigateToHomePage = true
                                }
                            }) {
                                Text("Зарегистрироваться")
                                    .font(.custom("Flame", size: 18))
                                    .foregroundColor(.white)
                                    .frame(width: 360, height: 40)
                                    .background(Color(UIColor(red: 0.055, green: 0.647, blue: 0.914, alpha: 1)))
                                    .cornerRadius(5)
                            }
                            
                            HStack {
                                Text("Уже есть аккаунт?")
                                    .font(.custom("Flame", size: 14))
                                    .foregroundColor(.white)
                                
                                NavigationLink(destination: SignIn()) {
                                    Text("Войти")
                                        .font(.custom("Flame", size: 14))
                                        .foregroundColor(Color(UIColor(red: 0.055, green: 0.777, blue: 0.914, alpha: 1)))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    Spacer()
                }
                .frame(maxHeight: .infinity, alignment: .top)
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
        .navigationBarBackButtonHidden(true)
    }
}
