//
//  MemorizingApp.swift
//  Memorizing
//
//  Created by 진준호 on 2023/01/05.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct MemorizingApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authStore: AuthStore = AuthStore()
    @StateObject var notiManager: NotificationManager = NotificationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView(email: "", password: "")
                .environmentObject(authStore)
                .environmentObject(notiManager)
        }
    }
}
