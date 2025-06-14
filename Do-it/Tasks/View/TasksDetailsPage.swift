import SwiftUI
import SwiftSDK

struct TasksDetailsPage: View {
    let task: Task
    @ObservedObject var viewModel: TasksViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showEditTaskView = false
    @State private var showAssignTaskView = false
    
    private var isManager: Bool {
        viewModel.isManager
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackgroundView()
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    VStack(alignment: .leading) {
                        
                        HStack {
                            Text(task.title)
                                .font(.custom("Flame", size: 18))
                                .foregroundColor(.white)
                                .frame(alignment: .leading)
                            
                            Button(action: {
                                showEditTaskView = true 
                            }) {
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(.white)
                            }
                        }
                        
                        HStack {
                            Text(task.subject)
                                .font(.custom("Flame", size: 14))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(alignment: .leading)
                        }
                        
                        Text(task.date)
                            .font(.custom("Flame", size: 14))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider()
                            .frame(height: 0.5)
                            .background(.white.opacity(0.7))
                            .padding(.top, 20)
                            .padding(.bottom, 20)
                        
                        Text(task.info)
                            .font(.custom("Flame", size: 14))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        if isManager {
                            Button(action: {
                                showAssignTaskView = true
                            }) {
                                ZStack {
                                    Text("Назначить")
                                        .offset(y: 18)
                                        .font(.custom("Flame", size: 16))
                                        .frame(width: 120, height: 71)
                                        .background(Color(UIColor(red: 0.055, green: 0.647, blue: 0.914, alpha: 1)))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                    
                                    Image(systemName: "person.badge.plus")
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.white)
                                        .padding(.bottom, 20)
                                }
                            }
                        }
                        
                        Button(action: {
                            viewModel.toggleTaskCompletion(task: task)
                            dismiss()
                        }) {
                            ZStack {
                                Text(task.isCompleted ? "Не готово" : "Готово")
                                    .offset(y: 18)
                                    .font(.custom("Flame", size: 16))
                                    .frame(width: 88, height: 71)
                                    .background(Color(UIColor(red: 0.02, green: 0.143, blue: 0.242, alpha: 1)))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(task.isCompleted ? .orange : .green)
                                    .padding(.bottom, 20)
                            }
                        }
                        
                        Button(action: {
                            viewModel.deleteTask(task: task)
                            dismiss()
                        }) {
                            ZStack {
                                
                                Text("Удалить")
                                    .offset(y: 18)
                                    .font(.custom("Flame", size: 16))
                                    .frame(width: 88, height: 71)
                                    .background(Color(UIColor(red: 0.02, green: 0.143, blue: 0.242, alpha: 1)))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                
                                Image(systemName: "trash.fill")
                                    .frame(width: 20, height: 22)
                                    .foregroundColor(.red)
                                    .padding(.bottom, 20)
                            }
                        }
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .sheet(isPresented: $showEditTaskView) {
            AddTaskView(viewModel: viewModel, task: task)
        }
        .sheet(isPresented: $showAssignTaskView) {
            AssignTaskView(task: task, viewModel: viewModel)
        }
    }
}
