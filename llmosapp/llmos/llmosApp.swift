//
//  llmosApp.swift
//  llmos
//
//  Created by Ethan Shaotran on 2/16/24.
import SwiftUI

@main
struct YourAppName: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // You might not need .windowStyle(HiddenTitleBarWindowStyle()) if the window is fully hidden
    }
}


