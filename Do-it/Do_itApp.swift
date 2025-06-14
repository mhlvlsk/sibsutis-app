//
//  Do_itApp.swift
//  Do-it
//
//  Created by Mihail Vlasyuk on 18.12.2024.
//

import SwiftUI
import SwiftSDK

@main
struct Do_itApp: App {
    
    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
        Backendless.shared.hostUrl = "https://eu-api.backendless.com"
        Backendless.shared.initApp(applicationId: ApiKeys.applicationId, apiKey: ApiKeys.apiKey)
        
        Backendless.shared.data.of(BackendTask.self).mapToTable(tableName: "TasksV2")
        Backendless.shared.data.of(BackendTask.self).mapColumn(columnName: "dateString", toProperty: "date")
        
        Backendless.shared.data.of(UserTask.self).mapToTable(tableName: "UserTasksV2")
    }
    
    var body: some Scene {
        WindowGroup {
            StartScreen()
        }
    }
}
