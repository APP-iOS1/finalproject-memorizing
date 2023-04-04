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
    @State private var isActive: Bool = false
    @State private var isNetworkError: Bool = false

    var body: some View {
        VStack {
            if isActive {
                ContentView()
            } else {
                Image("LoginTitle")
                    .animation(.spring(), value: true)
            }
        } // VStack
        .task {
            if !(DeviceManager.shared.networkStatus) {
                isNetworkError = true
            } else {
                if Auth.auth().currentUser != nil {
                    await authStore.signInDidExistingAuth()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.isActive = true
                }
            }
            
        }
        .customAlert(isPresented: $isNetworkError,
                     title: "네트워크 상태 확인",
                     message: "서버와의 통신이 원활하지 않습니다.\n \n이용에 불편을 드려 죄송합니다.\n잠시후에 다시 시도해 주세요",
                     primaryButtonTitle: "확인",
                     primaryAction: {
                        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            exit(0)
                        }
                     },
                     withCancelButton: false,
                     cancelButtonText: "")
    } // body
} // struct

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
            .environmentObject(AuthStore())
    }
}
