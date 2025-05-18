import SwiftUI

struct TabBarView: View {
    @StateObject private var tasksViewModel = TasksViewModel() 
    
    var body: some View {
        NavigationView {
            TabView {
                HomePage()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Color(.white)
                    }
                
                TasksPage(viewModel: tasksViewModel)
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Color(.white)
                    }
                
                CalendarPage(tasksViewModel: tasksViewModel)
                    .tabItem {
                        Image(systemName: "calendar")
                    }
                
                SettingsPage()
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Color(.white)
                    }
            }
            .accentColor(Color(UIColor(red: 0.055, green: 0.777, blue: 0.914, alpha: 1)))
        }
        .navigationBarBackButtonHidden(true)
    }
}
