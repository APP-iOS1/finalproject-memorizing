//
//  NotificationScheduleView.swift
//  Memorizing
//
//  Created by 진태영 on 2023/01/30.

import SwiftUI

struct NotificationScheduleView: View {
    @EnvironmentObject var myNoteStore: MyNoteStore
    @EnvironmentObject var notiManager: NotificationManager
    @Binding var isShownNotification: Bool
    @State private var isShownDeleteAlert: Bool = false
    @State private var toBeDeleted: IndexSet?

    var body: some View {
        VStack(alignment: .leading) {
            Text("💡노트별 알림을 설정해보세요!")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.leading, 20)
                .padding(.horizontal, 5)
            List {
                ForEach(1..<9) { _ in
                    ScheduleCell(notiId: "")
                        .listRowSeparator(.hidden)
                        .padding(.horizontal, 5)
                }
                
                // TODO: - 서버 노티 구현되면 for문 수정
                /*
               ForEach(notiManager.pendingRequests, id: \.self) {request in
                   ScheduleCell(notiId: request.identifier)
               }
                 */
           }
           .listStyle(.plain)
       } // VStack
       .task {
           // TODO: - 서버 노티 구현되면 노티 큐 입력
           await notiManager.getPendingRequests()
       }
       .navigationTitle("예정 알림 설정")
    } // body
}

struct NotificationScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationScheduleView(isShownNotification: .constant(false))
            .environmentObject(MyNoteStore())
            .environmentObject(NotificationManager())
    }
}
