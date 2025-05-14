import SwiftUI

struct Service1: View {
    var body: some View {
        ZStack {
            GradientBackgroundView()
            
            VStack(spacing: 15) {
                Image("clipboardAndPencil")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 411, height: 297)
                
                Text("Планируйте выполнение ваших заданий, чтобы не забыть их сделать")
                    .font(.custom("Flame-Regular", size: 20))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(60)
                    .padding(.bottom, 100)
            }
        }
        .ignoresSafeArea()
    }
}
