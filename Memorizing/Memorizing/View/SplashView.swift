//
//  SplashView.swift
//  Memorizing
//
//  Created by 진태영 on 2023/02/10.
//

import SwiftUI
import FirebaseAuth

struct SplashView: View {
    @EnvironmentObject var authStore: AuthStore
    @State private var isActive = false
    
    var body: some View {
        VStack {
            if isActive {
                ContentView()
            } else {
                ProgressView()
            }
        } // VStack
        .task {
            if Auth.auth().currentUser != nil {
                await authStore.signInDidExistingAuth()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isActive = true
            }
        }
    } // body
} // struct

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
            .environmentObject(AuthStore())
    }
}
