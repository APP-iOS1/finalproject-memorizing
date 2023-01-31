//
//  NotificationManager.swift
//  Memorizing
//
//  Created by Jae hyuk Yim on 2023/01/06.
//

import Foundation

// Local에서 알림센터를 띄우기 위해 활용 (Setting)
import NotificationCenter

// 기본 알림기능을 활용하기 위한 프레임워크
import UserNotifications

// 쓰레드 게시 오류를 해소하기 위해 선언
@MainActor

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    // MARK: - MyWordNote에서 아래의 데이터를 가져옴
    // 그리고 Time Interval을 위해
    @Published var myWordNotes: [MyWordNote] = []
    
    // MARK: - 알림의 모든 기능을 담는 인스턴스 [notificationCenter]
    let notificationCenter = UNUserNotificationCenter.current()
    
    @Published var isGranted: Bool = false
    @Published var isNotiAllow: Bool = true
    
    // MARK: - [UNNotificationRequest]라는 사용자의 Request를 담아내는 빈 배열을 만들어 줌
    @Published var pendingRequests: [UNNotificationRequest] = []
    
    // 대리자 위임을 받아야함.. delegate
    override init () {
        super.init()
        notificationCenter.delegate = self
    }
    
    // ---------  여기가 delegate function
    // ---------  이렇게 선언하면, 앱 foreground에서도 알람이 발생함
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        
        // 사용자가 입력하는 알림을 여기서 위임을 받아서 처리함 -> 알람 내용도 보여줘야 하니..
        await getPendingRequests()
        
        return [.sound, .banner, .badge]
    }
    
    private func userNotificationCenter(_ center: UNUserNotificationCenter,
                                        didReceive response: UNNotificationResponse) {
        let identifier = response.notification.request.identifier
        let userNotiCenter = UNUserNotificationCenter.current()
        print("response notification", response.notification.request.content as Any)
        userNotiCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Check Notification")
        
    }
    
    // MARK: - 앱이 시작하기 전, 알림설정을 물어보는 함수
    func requestAuthorization() async throws {
        try await notificationCenter.requestAuthorization(options: [.sound, .badge, .alert])
        
        await getCurrentSetting()
    }
    
    // --------- 현재의 인증 상태를 확인하고 세팅 -> [Center]
    func getCurrentSetting() async {
        
        // 현재의 인증현황을 확인하고
        let currentSetting = await notificationCenter.notificationSettings()
        
        // isGranted 프로퍼티에 현재 인증상태 값을 할당함 (거절을 눌렀다면 false, 동의를 눌렀으면 true로 변환되는걸 볼 수 있음)
        isGranted = (currentSetting.authorizationStatus == .authorized)
        print(isGranted)
    }
    
    func openSetting() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                Task {
                    await UIApplication.shared.open(url)
                }
            }
        }
    }
    
    /**
     선언한 사용자 입력값(구조체)를
     1. Content로 처리하고
     2. Trigger로 설정하고
     3. Request를 통해 Content + Trigger를 처리하고
     4. Center 저장소로 이동
     */
    func schedule(localNotification: LocalNotification) async {
        print("start notification schedule")
        // 1. UNMutableNotificationContent에 내장되어 있는 기능활용 -> [Content]
        let content = UNMutableNotificationContent()
        content.title = localNotification.title
        content.body = localNotification.body
        content.sound = .default
        content.badge = UserDefaults
            .standard.value(forKey: UserDefaults.Keys.notificationBadgeCount.rawValue) as? NSNumber
        
        if let badgeNumber = content.badge {
            content.badge = NSNumber(value: Int(truncating: badgeNumber) + 1)
        }
        if content.badge == nil {
            content.badge = 1
        }
        
        UserDefaults.standard.set(content.badge, forKey: UserDefaults.Keys.notificationBadgeCount.rawValue)
        
        if let subtitle = localNotification.subtitle {
            content.subtitle = subtitle
        }
        
        // scheduleType이 time, 즉 trigger가 timeInterval일 경우
        if localNotification.scheduleType == .time {
            print("localNotification, timeInterval")
            guard let timeInterval = localNotification.timeInterval else { return }
            //            // 2. 인터벌, 특정 시간대 등 사용자가 알림 시점을 설정할 수 있도록 함 -> [Trigger]
            //            // 여기서는 UNTimeInterval (인터벌) 형태로 선언
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval,
                                                            repeats: localNotification.repeats)
            let request = UNNotificationRequest(identifier: localNotification.identifier,
                                                content: content,
                                                trigger: trigger)
            print("localNOtification request: ", request)
            try? await notificationCenter.add(request)
            print("finish localNotification schedul")
        } else {
            guard let dateComponet = localNotification.dateComponets else { return }
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponet,
                                                        repeats: localNotification.repeats)
            let request = UNNotificationRequest(identifier: localNotification.identifier,
                                                content: content,
                                                trigger: trigger)
            try? await notificationCenter.add(request)
        }
        
        // 3. 내용(Content) + 사용자 설정(Trigger)을 모아 일괄로 할당받음
        // identifier는 일종의 식별자로, 개별 알림의 임의 id 값을 부여함
       // let request = UNNotificationRequest(identifier: localNotification.identifier,
       // content: content, trigger: trigger)
        
        // 4. notificationCenter, 즉 request(content + trigger) -> center 저장소로 이동!
       // try? await notificationCenter.add(request)
        await getPendingRequests()
    }
    
    // --------- 사용자가 작성하는 알림 정보를 처리하기 위한 함수
    func getPendingRequests() async {
        pendingRequests = await notificationCenter.pendingNotificationRequests()
        
        // 알림을 예약한 갯수(count)를 확인하기 위한 print
        print("Pending: \(pendingRequests.count)")
    }
    
    // ----- 사용자가 작성한 알림을 삭제하는 기능 추가
    func removeRequest(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        // index 기능을 활용, 사용자 알림을 맨 첫번째 기능한 순서대로 제거함
        if let index = pendingRequests.firstIndex(where: {$0.identifier == identifier}) {
            pendingRequests.remove(at: index)
            print("Pending: \(pendingRequests.count)")
        }
        
    }
    
    // ---- 사용자의 모든 푸시 메시지 일괄 삭제 및 스케줄 취소 (로그아웃 할 때 사용)
    func removeAllRequest() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
}
