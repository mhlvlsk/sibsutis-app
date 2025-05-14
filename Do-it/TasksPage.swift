import SwiftUI

struct TasksPage: View {
    @ObservedObject var viewModel = TasksViewModel()
    @State private var searchText = ""
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy h:mm a"
        return formatter
    }()
    
    var filteredTasks: [Task] {
        let tasksToFilter: [Task]
        
        if searchText.isEmpty {
            tasksToFilter = viewModel.tasks
        } else {
            tasksToFilter = viewModel.tasks.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
        
        return tasksToFilter.sorted { (task1, task2) -> Bool in
            guard let date1 = parseDate(task1.date), let date2 = parseDate(task2.date) else {
                return false
            }
            return date1 > date2
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackgroundView()
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        ZStack(alignment: .leading) {
                            if searchText.isEmpty {
                                Text("Поиск задачи по названию")
                                    .foregroundColor(Color.white)
                                    .font(.custom("Flame", size: 12))
                                    .padding(.leading, 15)
                            }
                            
                            Image(systemName: "magnifyingglass")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 18, weight: .bold))
                                    .padding(.leading, 345)
                            
                            TextField("", text: $searchText)
                                .padding()
                                .background(Color(UIColor(red: 0.064, green: 0.175, blue: 0.325, alpha: 0.8)))
                                .foregroundColor(.white)
                                .font(.custom("Flame", size: 12))
                                .frame(width: 375, height: 42)
                                .cornerRadius(5)
                        }
                    }
                    .padding()
                    
                    VStack {
                        Text("Список задач")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.custom("Flame", size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.top, 20)
                    }
                    
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 30) {
                                
                                ForEach(filteredTasks.indices, id: \.self) { index in
                                    let task = filteredTasks[index]
                                    NavigationLink(
                                        destination: TasksDetailsPage(
                                            task: task,
                                            viewModel: viewModel
                                        )
                                    ) {
                                        TaskRow(task: task)
                                            .id(index)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .onAppear {
                                scrollToClosestTask(proxy: proxy)
                            }
                        }
                    }
                    
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                viewModel.showAddTask.toggle()
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 50, height: 50)
                                    .background(Color(UIColor(red: 0.39, green: 0.853, blue: 0.954, alpha: 1)))
                                    .clipShape(Circle())
                            }
                            .padding(30)
                            
                        }
                    }
                }
            }
            
            .sheet(isPresented: $viewModel.showAddTask) {
                AddTaskView(viewModel: viewModel)
            }
        }
    }
    
    private func scrollToClosestTask(proxy: ScrollViewProxy) {
        if let closestTask = filteredTasks.first(where: { task in
            if let taskDate = parseDate(task.date) {
                return Calendar.current.isDateInToday(taskDate)
            }
            return false
        }) {
            if let closestIndex = filteredTasks.firstIndex(where: { $0.id == closestTask.id }) {
                proxy.scrollTo(closestIndex, anchor: .top)
            }
        }
    }
}

struct TaskRow: View {
    let task: Task
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.custom("Flame", size: 14))
                    .foregroundColor(.black)
                Text(task.date)
                    .font(.custom("Flame", size: 10))
                    .foregroundColor(.black)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(UIColor(red: 0.055, green: 0.647, blue: 0.914, alpha: 1)))
                .frame(width: 11.21, height: 16)
            
        }
        .padding()
        .frame(width: 375, height: 51)
        .background(Color.white)
        .cornerRadius(5)
    }
}

extension TasksPage {
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy h:mm a"
        return formatter.date(from: dateString)
    }
}
