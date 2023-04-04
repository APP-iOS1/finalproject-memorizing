//
//  StudyingStampView.swift
//  Memorizing
//
//  Created by 김혜지 on 2023/01/20.
//

import SwiftUI

struct StudyingStampView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var myNoteStore: MyNoteStore
    @EnvironmentObject var notiManager: NotificationManager
    @EnvironmentObject var coreDataStore: CoreDataStore
    var wordNote: NoteEntity
    @Binding var isDismiss: Bool
    
    var body: some View {
        VStack {
            
            VStack(alignment: .leading, spacing: 5) {
                Text("복습 완료")
                    .font(.title)
                    .fontWeight(.semibold)
                Text("복습을 마무리했어요!다음 복습때 만나요!")
                    .font(.footnote)
            }
            .frame(width: 320, alignment: .leading)
            .padding(.bottom, 10)
            .padding(.leading, 5)
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("Gray4"), lineWidth: 1)
                    .foregroundColor(.white)
                    .overlay {
                        Image("studyicon")
                            .resizable()
                            .frame(width: 200, height: 200)
                    }
            }
            .frame(width: 330, height: 330)
            .padding(.bottom)
            
            Button {
                Task {
                    // MARK: - Notification -> 버튼을 눌렀을 시, identifier, title, body, timeInterval등을 설정한 후, 알림을 뿌려줌
                    // 여기서, 망각곡선 방식 혹은 값에 따라 알람 주기 (TimeInterval)를 설정함
                    // 첫 번째, repeatCount / 두 번째, 난이도? (Level)?
                        // 알림 설정 권한 확인
                        if (wordNote.repeatCount + 1) < 4 {
                            let newTimeInterval: Double
                            if wordNote.repeatCount + 1 == 2 {
                                newTimeInterval = 3600
                            } else {
                                newTimeInterval = 86400
                            }
                            
                            if notiManager.isNotiAllow { // 알림 추가
                                
                                let localNotification = LocalNotification(
                                    identifier: wordNote.id ?? "No Id",
                                    title: "MEMOrizing 암기 시간",
                                    subtitle: "\(wordNote.noteName ?? "No Name")",
                                    body: "\(wordNote.repeatCount + 1)번째 복습할 시간이에요~!",
                                    timeInterval: newTimeInterval,
                                    repeats: false,
                                    scheduleType: .time
                                )
                                
                                await notiManager.schedule(localNotification: localNotification)
                                await notiManager.getPendingRequests()
                            }
                            
                            await myNoteStore.repeatCountWillBePlusOne(
                                wordNote: wordNote,
                                nextStudyDate: Date() + newTimeInterval,
                                firstTestResult: wordNote.firstTestResult,
                                lastTestResult: wordNote.lastTestResult
                            )
                            wordNote.nextStudyDate = Date() + newTimeInterval
                            
                            coreDataStore.plusRepeatCount(note: wordNote,
                                                          firstTestResult: wordNote.firstTestResult,
                                                          lastTestResult: wordNote.lastTestResult)
                            isDismiss.toggle()
                    } else {
                        isDismiss.toggle()
                    }
                }
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("MainDarkBlue"))
                    .frame(width: 330, height: 50)
                    .overlay {
                        Text("종료 하기")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
            }
            
            HStack {
                
            }
            .frame(width: 320, alignment: .leading)
            .padding(.top, 20)
        }
    }
}
