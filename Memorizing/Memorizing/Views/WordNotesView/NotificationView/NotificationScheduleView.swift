//
//  NotificationScheduleView.swift
//  Memorizing
//
//  Created by 진태영 on 2023/01/30.

import SwiftUI

struct NotificationScheduleView: View {
    @EnvironmentObject var notiManager: NotificationManager
    @State private var isShownDeleteAlert: Bool = false
    @State private var toBeDeleted: Int?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("💡노트별 알림을 설정해보세요!")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.leading, 20)
                .padding(.horizontal, 5)
                .padding(.top, 10)
            List {
                ForEach(Array($notiManager.pendingRequests.enumerated()), id: \.offset) {index, $request in
                    HStack {
                        ScheduleCell(pendingRequest: $request)
                            .listRowSeparator(.hidden)
                            .padding(.horizontal, 5)
                        Spacer()
                        
                        Button {
                            isShownDeleteAlert.toggle()
                            toBeDeleted = index
                        } label: {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.gray3)
                                .font(.title2)
                        }
                    }
                }
            }
            .listStyle(.plain)
        } // VStack
        .customAlert(isPresented: $isShownDeleteAlert,
                     title: "복습 알림 삭제",
                     message: "이번 회차의 복습 알림을 삭제하시면 다시 설정할 수 없어요!",
                     primaryButtonTitle: "알림 삭제",
                     primaryAction: {
            if let deleteIndex = toBeDeleted {
                let removeItem: UNNotificationRequest = notiManager.pendingRequests[deleteIndex]
                notiManager.removeRequest(withIdentifier: removeItem.identifier)
            }
        },
                     withCancelButton: true,
                     cancelButtonText: "취소")
        .task {
            for noti in notiManager.pendingRequests {
                print("예정된 알림: \(noti.identifier)")
            }
        }
        .navigationTitle("예정 알림")
    } // body
}

struct NotificationScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationScheduleView()
            .environmentObject(NotificationManager())
    }
    
}
