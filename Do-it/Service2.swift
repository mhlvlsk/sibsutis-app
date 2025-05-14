import SwiftUI

struct Service2: View {
    var body: some View {
        ZStack {
            GradientBackgroundView()
            
            VStack(spacing: 15) {
                Image("calendarIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 279, height: 281)
                
                Text("Следите за сроком сдачи, чтобы задания были готовы вовремя")
                    .font(.custom("Flame", size: 20))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(60)
                    .padding(.bottom, 100)
            }
        }
        .ignoresSafeArea()
    }
}
