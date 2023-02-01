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
import FirebaseMessaging

// MARK: - LocalPush, ServerPush를 위한 AppDelegate 선언
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil)
    -> Bool {
         
         // Use Firebase library to configure APIs
         // 파이어베이스 설정
         FirebaseApp.configure()
         
         // 원격 알림 등록
         if #available(iOS 10.0, *) {
             // For iOS 10 display notification (sent via APNS)
             UNUserNotificationCenter.current().delegate = self
             
             let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
             UNUserNotificationCenter.current().requestAuthorization(
                 options: authOptions,
                 completionHandler: { _, _ in }
             )
         } else {
             let settings: UIUserNotificationSettings =
             UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
             application.registerUserNotificationSettings(settings)
         }
         
         application.registerForRemoteNotifications()
         
         // 메세징 델리겟
         Messaging.messaging().delegate = self
         
         // 푸시 포그라운드 설정
         UNUserNotificationCenter.current().delegate = self
         
         return true
     }
     
     // fcm 토큰이 등록 되었을 때
     func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
     ) {
         Messaging.messaging().apnsToken = deviceToken
     }
}

extension AppDelegate: MessagingDelegate {
    
    // fcm 등록 토큰을 받았을 때
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("AppDelegate - 파베 토큰을 받았다.")
        print("AppDelegate - Firebase registration token: \(String(describing: fcmToken))")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // 푸시메세지가 앱이 켜져 있을때 나올때
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions
                                ) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        print("willPresent: userInfo: ", userInfo)
        
        completionHandler([.banner, .sound, .badge])
    }
    
    // 푸시메세지를 받았을 때
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("didReceive: userInfo: ", userInfo)
        completionHandler()
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
             /*
            FirstLoginView(isFirstLoginView: .constant(true))
                .environmentObject(authStore)
              */
        }
    }
}
