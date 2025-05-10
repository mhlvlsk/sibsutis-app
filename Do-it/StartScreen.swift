import SwiftUI

struct StartScreen: View {
    @State private var isLoaded = false
    @StateObject private var viewModel = SignInViewModel()
    @State private var navigateToHomePage: Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoaded {
                    ServiceScreen()
                } else {
                    ZStack {
                        GradientBackgroundView()
                        
                        VStack(spacing: 15) {
                            Image("CheckmarkLabel")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                            
                            Text("SIBSUTIS APP")
                                .font(.custom("DarumadropOne-Regular", size: 36))
                                .foregroundColor(.white)
                            
                            Text("v 1.0.0")
                                .font(.custom("Poppins", size: 20))
                                .foregroundColor(.white)
                                .padding(.top, 300)
                        }
                    }
                    .ignoresSafeArea()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isLoaded = true
                            }
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToHomePage) {
                TabBarView()
            }
        }
        .onAppear {
            if viewModel.isAuthenticated {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        navigateToHomePage = true
                    }
                }
            }
        }
    }
}
