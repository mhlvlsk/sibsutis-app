import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TasksViewModel
    
    @State private var subject: String
    @State private var title: String
    @State private var info: String
    @State private var date: Date
    @State private var time: Date
    
    @State private var showAlert = false
    private var taskToEdit: Task?
    
    init(viewModel: TasksViewModel, task: Task? = nil) {
        self.taskToEdit = task
        _subject = State(initialValue: task?.subject ?? "")
        _title = State(initialValue: task?.title ?? "")
        _info = State(initialValue: task?.info ?? "")
        _date = State(initialValue: task?.parseDate(task?.date ?? "") ?? Date())
        _time = State(initialValue: task?.parseDate(task?.date ?? "") ?? Date())
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        hideKeyboard()
                    }
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Image(systemName: "checkmark.square")
                                .foregroundColor(.white)
                            ZStack {
                                if subject.isEmpty {
                                    Text("Предмет")
                                        .foregroundColor(.white)
                                        .font(.custom("Flame", size: 12))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                TextField("", text: $subject)
                                    .font(.custom("Flame", size: 12))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(Color(UIColor(red: 0.02, green: 0.143, blue: 0.242, alpha: 1)))
                        .frame(width: 358, height: 42)
                        .cornerRadius(5)
                        
                        HStack {
                            Image(systemName: "checkmark.square")
                                .foregroundColor(.white)
                            ZStack {
                                if title.isEmpty {
                                    Text("Задача")
                                        .foregroundColor(.white)
                                        .font(.custom("Flame", size: 12))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                TextField("", text: $title)
                                    .font(.custom("Flame", size: 12))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(Color(UIColor(red: 0.02, green: 0.143, blue: 0.242, alpha: 1)))
                        .frame(width: 358, height: 42)
                        .cornerRadius(5)
                        
                        HStack(alignment: .top) {
                            Image(systemName: "text.alignleft")
                                .foregroundColor(.white)
                                .padding(.top, 10)
                            
                            ZStack(alignment: .topLeading) {
                                if info.isEmpty {
                                    Text("Описание")
                                        .opacity(info.isEmpty ? 1 : 0)
                                        .foregroundColor(.white)
                                        .font(.custom("Flame", size: 12))
                                        .padding(.top, 10)
                                        .padding(.leading, 5)
                                }
                                TextEditor(text: $info)
                                    .foregroundColor(.white)
                                    .font(.custom("Flame", size: 12))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(.clear)
                                    .scrollContentBackground(.hidden)
                            }
                        }
                        .padding(.horizontal)
                        .background(Color(UIColor(red: 0.02, green: 0.143, blue: 0.242, alpha: 1)))
                        .frame(width: 358, height: 159)
                        .cornerRadius(5)
                        
                        HStack(spacing: 16) {
                            DatePicker(
                                "",
                                selection: $date,
                                displayedComponents: .date
                            )
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                            .background(Color(UIColor(red: 0.02, green: 0.143, blue: 0.242, alpha: 0.6)))
                            .cornerRadius(5)
                            .environment(\.locale, Locale(identifier: "ru_RU"))
                            
                            DatePicker(
                                "",
                                selection: $time,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                            .background(Color(UIColor(red: 0.02, green: 0.143, blue: 0.242, alpha: 0.6)))
                            .cornerRadius(5)
                            .environment(\.locale, Locale(identifier: "ru_RU"))
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 20) {
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Отмена")
                                    .font(.custom("Flame", size: 16))
                                    .foregroundColor(Color(UIColor(red: 0.02, green: 0.143, blue: 0.242, alpha: 1)))
                                    .padding()
                                    .frame(width: 165, height: 46)
                                    .frame(maxWidth: .infinity)
                                    .background(.white)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(UIColor(red: 0.055, green: 0.647, blue: 0.914, alpha: 1)), lineWidth: 2))
                            }
                            
                            Button(action: {
                                if title.isEmpty || info.isEmpty {
                                    showAlert.toggle()
                                } else {
                                    if let task = taskToEdit {
                                        viewModel.updateTask(
                                            subject: subject,
                                            task: task,
                                            title: title,
                                            date: formatDate(date: date),
                                            info: info
                                        )
                                    } else {
                                        viewModel.addTaskToServer(
                                            subject: subject,
                                            title: title,
                                            date: formatDate(date: date),
                                            info: info
                                        )
                                    }
                                    dismiss()
                                }
                            }) {
                                Text(taskToEdit != nil ? "Применить" : "Создать")
                                    .font(.custom("Flame", size: 16))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 165, height: 46)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(UIColor(red: 0.055, green: 0.647, blue: 0.914, alpha: 1)))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.top, 40)
                    .padding()
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Ошибка"),
                            message: Text("Не удалось создать задачу"),
                            dismissButton: .default(Text("ОК"))
                        )
                    }
                }
            }
        }
    }
    
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMM yyyy, HH:mm"
        return formatter.string(from: date)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
