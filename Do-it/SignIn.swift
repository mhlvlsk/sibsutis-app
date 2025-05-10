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
                    
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Welcome Back to")
                                .font(.custom("Poppins", size: 25))
                                .foregroundColor(.white)
                            
                            Text("SIBSUTIS APP")
                                .font(.custom("DarumadropOne-Regular", size: 20))
                                .foregroundColor(.white)
                                .baselineOffset(5)
                        }
                        
                        Text("Have another productive day!")
                            .font(.custom("Poppins", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 45)
                        
                        VStack(alignment: .leading, spacing: 50) {
                            TextField("E-mail", text: $viewModel.email)
                                .autocapitalization(.none)
                                .padding()
                                .background(.white)
                                .foregroundColor(.gray)
                                .font(.custom("Poppins", size: 18))
                                .frame(width: 358, height: 42)
                                .cornerRadius(5)
                            
                            SecureField("Password", text: $viewModel.password)
                                .autocapitalization(.none)
                                .padding()
                                .background(.white)
                                .foregroundColor(.gray)
                                .font(.custom("Poppins", size: 18))
                                .frame(width: 358, height: 42)
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
                                Text("sign in")
                                    .font(.custom("Poppins", size: 18))
                                    .foregroundColor(.white)
                                    .frame(width: 348, height: 42)
                                    .background(Color(UIColor(red: 0.055, green: 0.647, blue: 0.914, alpha: 1)))
                                    .cornerRadius(5)
                            }
                            
                            HStack {
                                Text("Don't have an account?")
                                    .font(.custom("Poppins", size: 14))
                                    .foregroundColor(.white)
                                
                                NavigationLink(destination: SignUp()) {
                                    Text("sign up")
                                        .font(.custom("Poppins", size: 14))
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
        .onAppear {
            if viewModel.isAuthenticated {
                navigateToHomePage = true
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
