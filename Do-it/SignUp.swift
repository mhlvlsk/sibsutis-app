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
                    
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Welcome to")
                                .font(.custom("Poppins", size: 25))
                                .foregroundColor(.white)
                            
                            Text("DO IT")
                                .font(.custom("DarumadropOne-Regular", size: 25))
                                .foregroundColor(.white)
                                .baselineOffset(5)
                        }
                        
                        Text("Create an account and Join us now!")
                            .font(.custom("Poppins", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 35)
                        
                        VStack(alignment: .leading, spacing: 35) {
                            TextField("Full name", text: $viewModel.fullname)
                                .padding()
                                .background(.white)
                                .foregroundColor(.gray)
                                .font(.custom("Poppins", size: 18))
                                .frame(width: 358, height: 42)
                                .cornerRadius(5)
                            
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
                        .padding(.bottom, 35)
                        
                        VStack(alignment: .center, spacing: 15) {
                            Button(action: {
                                viewModel.signUp()
                                if viewModel.isSignedUp {
                                    navigateToHomePage = true
                                }
                            }) {
                                Text("sign up")
                                    .font(.custom("Poppins", size: 18))
                                    .foregroundColor(.white)
                                    .frame(width: 348, height: 42)
                                    .background(Color(UIColor(red: 0.055, green: 0.647, blue: 0.914, alpha: 1)))
                                    .cornerRadius(5)
                            }
                            
                            HStack {
                                Text("Already have an account?")
                                    .font(.custom("Poppins", size: 14))
                                    .foregroundColor(.white)
                                
                                NavigationLink(destination: SignIn()) {
                                    Text("sign in")
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
        .navigationBarBackButtonHidden(true)
    }
}
