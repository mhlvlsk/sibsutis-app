import SwiftUI
import SwiftSDK

struct AssignTaskView: View {
    let task: Task
    @ObservedObject var viewModel: TasksViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack {
                Text("Кому назначить задачу?")
                    .font(.custom("Flame", size: 20))
                    .padding()
                
                List(viewModel.users, id: \.objectId) { user in
                    Button(action: {
                        viewModel.assignTask(task: task, toUser: user)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.largeTitle)
                            VStack(alignment: .leading) {
                                Text(user.properties["fullname"] as? String ?? "No name")
                                    .font(.headline)
                                Text(user.email ?? "No email")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .onAppear {
                viewModel.fetchAllUsers()
            }
            .navigationBarTitle("Назначить", displayMode: .inline)
            .navigationBarItems(leading: Button("Отмена") {
                dismiss()
            })
        }
    }
}
