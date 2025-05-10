import SwiftUI

struct CustomPagingIndicator: View {
    @Binding var currentPage: Int
    var totalPages: Int
    var activeTint: Color
    var inactiveTint: Color
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<totalPages, id: \.self) { index in
                if index == currentPage {
                    Capsule()
                        .fill(activeTint)
                        .frame(width: 33, height: 7) 
                        .transition(.scale)
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                } else {
                    Capsule()
                        .fill(inactiveTint)
                        .frame(width: 18, height: 7)
                        .transition(.scale)
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                }
            }
        }
    }
}
