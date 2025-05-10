import SwiftUI

struct Service4: View {
    var body: some View {
        ZStack {
            GradientBackgroundView()
            
            VStack(spacing: 15) {
                Image("3dShield")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 411, height: 255)
                
                Text("You informations are secure with us")
                    .font(.custom("Poppins", size: 20))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(65)
                    .padding(.bottom, 100)
            }
        }
        .ignoresSafeArea()
    }
}
