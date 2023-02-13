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
    @EnvironmentObject var notiManager: NotificationManager
    @EnvironmentObject var coreDataStore: CoreDataStore
    
    var body: some View {
        VStack {
            if authStore.user != nil {
                MainView()
            } else {
                LoginView()
            }
            
        }
        .onChange(of: Auth.auth().currentUser, perform: { newValue in
             if newValue != nil {
                // CoreData 서버에서 페치해오기
                Task {
                    await coreDataStore.syncronizeNotes()
                    await coreDataStore.saveNotesInCoreData()
                    coreDataStore.getNotes()
                }
            }
            
        })
        .task {
            // 알림 권한 여부 확인
            try? await notiManager.requestAuthorization()
            await notiManager.getPendingRequests()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthStore())
            .environmentObject(NotificationManager())
    }
}
