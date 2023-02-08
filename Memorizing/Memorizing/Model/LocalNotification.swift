//
//  LocalNotificationManager.swift
//  Memorizing
//
//  Created by Jae hyuk Yim on 2023/01/06.
//

import Foundation

// MARK: - 사용자가 알림설정을 할 수 있는 구조를 만들어줌
struct LocalNotification {
    
    // 1. timeInterval 기능을 사용할 경우!
    internal init(identifier: String,
                  title: String,
                  body: String,
                  timeInterval: Double,
                  repeats: Bool) {
        self.identifier = identifier
        self.title = title
        self.body = body
        self.timeInterval = timeInterval
        self.dateComponets = nil
        self.repeats = repeats
        
        self.scheduleType = .time
    }
    
    // 2. dateComponets를 사용하게 될 경우!
    internal init(identifier: String,
                  title: String,
                  body: String,
                  dateComponets: DateComponents,
                  repeats: Bool) {
        self.identifier = identifier
        self.title = title
        self.body = body
        self.timeInterval = nil
        self.dateComponets = dateComponets
        self.repeats = repeats
        self.scheduleType = .calender
    }
    
    // 3. ScheduleType -> 2가지 시간 유형을 만들어줌
    enum ScheduleType {
        case time, calender
    }
    var identifier: String
    var title: String
    var body: String
    var subtitle: String?
    
    var scheduleType: ScheduleType
    // 아래 2개의 속성은, 옵셔널로 처리
    // Interval을 사용하면, dateComponets가 사용되지 않기 때문 (반대로도 동일함)
    var timeInterval: Double?
    var dateComponets: DateComponents?
    
    // TODO: - 캘린더 타입의 store를 하나 생성해서, dateComponets에서 받아오는 데이터를 변환, 저장하도록 한다
    var repeats: Bool
}

// Date Value 모델
struct DateValue: Identifiable {
    var id = UUID().uuidString
    var day: Int
    var date: Date
}
