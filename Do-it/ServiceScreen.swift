import SwiftUI

struct ServiceScreen: View {
    @State private var currentPage = 0
    @State private var navigateToSignIn = false
    
    var body: some View {
        ZStack {
            GradientBackgroundView()
                .ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPage) {
                    Service1()
                        .tag(0)
                    
                    Service2()
                        .tag(1)
                    
                    Service3()
                        .tag(2)
                    
                    Service4()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                Spacer()
            }
            
            VStack {
                Spacer()
                HStack {
                    
                    CustomPagingIndicator(currentPage: $currentPage, totalPages: 4, activeTint: .white, inactiveTint: .white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 40)
                        .padding(.leading, 120)
                    
                    Spacer()
                    if currentPage < 3 {
                        Button(action: {
                            if currentPage < 3 {
                                currentPage += 1
                            }
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .font(.system(size: 70, weight: .thin))
                                .frame(width: 70, height: 70)
                                .foregroundColor(.white)
                                .padding(.bottom, 40)
                                .padding(.trailing, 40)
                        }
                    } else {
                        Button(action: {
                            navigateToSignIn = true
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .font(.system(size: 70, weight: .thin))
                                .frame(width: 70, height: 70)
                                .foregroundColor(.white)
                                .padding(.bottom, 40)
                                .padding(.trailing, 40)
                        }
                        .fullScreenCover(isPresented: $navigateToSignIn) {
                            SignIn()
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}
