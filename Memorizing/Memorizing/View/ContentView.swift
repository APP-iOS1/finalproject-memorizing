//
//  ContentView.swift
//  Memorizing
//
//  Created by 진준호 on 2023/01/05.
//

import SwiftUI
import FirebaseAuth
// MARK: Login 상태에 따라 LoginView 또는 TabView를 보여주는 View
struct ContentView: View {
    @EnvironmentObject var authStore: AuthStore
    @StateObject var marketStore: MarketStore = MarketStore()
    @EnvironmentObject var notiManager: NotificationManager
    @EnvironmentObject var coreDataStore: CoreDataStore
    @State var email: String
    @State var password: String
    
    var body: some View {
        VStack {
            if Auth.auth().currentUser != nil {
                MainView()
                    .environmentObject(marketStore)
            } else {
                if authStore.state == .signedOut {
                    LoginView()
                        .environmentObject(marketStore)
                } else if authStore.state == .firstIn {
                    var _ = print("OnBoardingTabView: \(self.email) / \(self.password)")
                    OnBoardingTabView(currentTab: self.email.isEmpty
                                      && self.password.isEmpty
                                      ? 0
                                      : 3,
                                      email: $email,
                                      password: $password)
                } else if authStore.state == .check {
                    FirstView()
                }
                
            }
            
        }
        .onChange(of: Auth.auth().currentUser, perform: { newValue in
            if newValue == nil {
                print("onChange nil")
                coreDataStore.deleteAll()
            } else {
                print("onChange uid")
                coreDataStore.syncronizeWithDB()
                // CoreData 서버에서 페치해오기
            }
            
        })
        .task {
            // 알림 권한 여부 확인
            try? await notiManager.requestAuthorization()
            if UserDefaults.standard.string(forKey: UserDefaults.Keys.isExistingAuth.rawValue) != nil {
                await authStore.signInDidExistingAuth()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(email: "", password: "")
            .environmentObject(AuthStore())
            .environmentObject(NotificationManager())
    }
}
