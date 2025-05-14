import SwiftUI

struct HomePage: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            GradientBackgroundView()
                .ignoresSafeArea()
            
            VStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(viewModel.userName)")
                        .font(.custom("Flame", size: 18))
                        .foregroundColor(.white)
                    
                    Text(viewModel.userEmail)
                        .font(.custom("Flame", size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
                .padding(.top, 30)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if !viewModel.getUncompletedTasks().isEmpty {
                            Text("Невыполненные задачи")
                                .font(.custom("Flame", size: 14))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            ForEach(viewModel.getUncompletedTasks(), id: \.id) { task in
                                TaskRow(task: task)
                                    .padding(.horizontal, 20)
                            }
                        }
                        
                        if !viewModel.getCompletedTasks().isEmpty {
                            Text("Выполненные задачи")
                                .font(.custom("Flame", size: 14))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            ForEach(viewModel.getCompletedTasks(), id: \.id) { task in
                                TaskRow(task: task)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                }
            }
            .onAppear {
                viewModel.loadUserData()
                viewModel.loadTasks()
            }
        }
    }
}
