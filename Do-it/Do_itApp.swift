//
//  Do_itApp.swift
//  Do-it
//
//  Created by Mihail Vlasyuk on 18.12.2024.
//

import SwiftUI

@main
struct Do_itApp: App {
    
    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
    }
    
    var body: some Scene {
        WindowGroup {
            StartScreen()
        }
    }
}
