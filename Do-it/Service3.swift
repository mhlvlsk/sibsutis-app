import SwiftUI

struct Service3: View {
    var body: some View {
        ZStack {
            GradientBackgroundView()
            
            VStack(spacing: 15) {
                Image("teamManagement")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 211)
                
                Text("Create a team task, invite people and manage your work together")
                    .font(.custom("Poppins", size: 20))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(60)
                    .padding(.bottom, 100)
            }
        }
        .ignoresSafeArea()
    }
}
