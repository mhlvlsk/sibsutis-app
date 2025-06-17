import SwiftUI
import SwiftSDK

struct AssignTaskView: View {
    let task: Task
    @ObservedObject var viewModel: TasksViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedUserIds = Set<String>()

    var body: some View {
        NavigationView {
            VStack {
                TextField("Поиск по имени или email", text: $viewModel.searchText)
                    .padding(7)
                    .padding(.horizontal, 25)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 8)
                        }
                    )
                    .padding(.horizontal, 10)

                List(viewModel.filteredUsers, id: \.objectId) { user in
                    Button(action: {
                        if selectedUserIds.contains(user.objectId ?? "") {
                            selectedUserIds.remove(user.objectId ?? "")
                        } else {
                            selectedUserIds.insert(user.objectId ?? "")
                        }
                    }) {
                        HStack {
                            Image(systemName: selectedUserIds.contains(user.objectId ?? "") ? "checkmark.circle.fill" : "circle")
                                .font(.largeTitle)
                                .foregroundColor(selectedUserIds.contains(user.objectId ?? "") ? .blue : .gray)
                            
                            VStack(alignment: .leading) {
                                Text(user.properties["fullname"] as? String ?? "No name")
                                    .font(.headline)
                                Text(user.email ?? "No email")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .listStyle(PlainListStyle())
            .onAppear {
                viewModel.fetchAllUsers()
            }
            .navigationTitle("Исполнители:")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Назначить") {
                        viewModel.assignTask(task: task, toUserIds: selectedUserIds)
                        dismiss()
                    }
                    .disabled(selectedUserIds.isEmpty)
                }
            }
        }
    }
}
