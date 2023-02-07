//
//  MemorizingApp.swift
//  Memorizing
//
//  Created by 진준호 on 2023/01/05.
//

import SwiftUI
import FirebaseCore
import KakaoSDKAuth
import KakaoSDKCommon
import Firebase

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
    
    // MARK: - ScenePhase 선언
    @Environment(\.scenePhase) var scenePhase
    @StateObject var authStore: AuthStore = AuthStore()
    @StateObject var myNoteStore: MyNoteStore = MyNoteStore()
    @StateObject var marketStore: MarketStore = MarketStore()
    @StateObject var reviewStore: ReviewStore = ReviewStore()
    @StateObject var notiManager: NotificationManager = NotificationManager()
    @StateObject var coreData: CoreDataStore = CoreDataStore()
    init() {
        // Kakao SDK 초기화
        KakaoSDK.initSDK(appKey: "f601fab092f88d03d3a95c1b5773efed")
    }
    
    var body: some Scene {
        WindowGroup {
            
            ContentView(email: "", password: "")
                .environmentObject(authStore)
                .environmentObject(myNoteStore)
                .environmentObject(marketStore)
                .environmentObject(reviewStore)
                .environmentObject(notiManager)
                .environmentObject(coreData)
                .onOpenURL { url in // 뷰가 속한 Window에 대한 URL을 받았을 때 호출할 Handler를 등록하는 함수
                    // 카카오 로그인을 위해 웹 혹은 카카오톡 앱으로 이동 후 다시 앱으로 돌아오는 과정을 거쳐야하므로, Handler를 추가로 등록해줌
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
                .onChange(of: scenePhase) { newValue in
                    if newValue == .active {
                        UIApplication.shared.applicationIconBadgeNumber = 0
                        UserDefaults.standard.set(0, forKey: UserDefaults.Keys.notificationBadgeCount.rawValue)
                    }
                }
        }
    }
}
