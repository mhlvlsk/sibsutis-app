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
    }
    
    var body: some Scene {
        WindowGroup {
            StartScreen()
        }
    }
}
