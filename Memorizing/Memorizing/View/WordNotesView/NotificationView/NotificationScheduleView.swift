//
//  NotificationScheduleView.swift
//  Memorizing
//
//  Created by 진태영 on 2023/01/31.
//

import SwiftUI

struct NotificationScheduleView: View {
    @EnvironmentObject var notiManager: NotificationManager
    @State private var isShownDeleteAlert: Bool = false
    @State private var toBeDeleted: IndexSet?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("💡노트별 알림을 확인해보세요!")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.leading, 20)
                .padding(.horizontal, 5)
            List {
                ForEach(notiManager.pendingRequests, id: \.self) {request in
                    ScheduleCell(notiId: request.identifier)
                        .listRowSeparator(.hidden)
                        .padding(.horizontal, 5)
                        .alert(isPresented: $isShownDeleteAlert) {
                            Alert(
                                title: Text("복습 알림 끄기"),
                                message: Text("이번 회차의 복습 알림을 지우시면 다시 설정할 수 없어요!"),
                                primaryButton: .cancel(Text("안지울래요!")),
                                secondaryButton: .destructive(Text("이번만 지울래요!"), action: {
                                    if let indexSet = toBeDeleted {
                                        for index in indexSet {
                                            let removeItem: UNNotificationRequest = notiManager.pendingRequests[index]
                                            notiManager.removeRequest(withIdentifier: removeItem.identifier)
                                        }
                                    }
                                })
                            )
                        }
                }
                .onDelete { indexSet in
                    self.isShownDeleteAlert.toggle()
                    self.toBeDeleted = indexSet
                }
            }
            .listStyle(.plain)
        } // VStack
        .task {
            await notiManager.getPendingRequests()
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
