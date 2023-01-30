//
//  NotificationView.swift
//  Memorizing
//
//  Created by 진태영 on 2023/01/20.
//

import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var myNoteStore: MyNoteStore
    @EnvironmentObject var notiManager: NotificationManager
    @Binding var isShownNotification: Bool
    
    var body: some View {
        NavigationStack {
             VStack(alignment: .leading) {
                 Text("알림")
                     .padding()
                 List {
                    ForEach(notiManager.pendingRequests, id: \.self) {request in
                        NotificationCell(notiId: request.identifier)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let removeItem: UNNotificationRequest = notiManager.pendingRequests[index]
                            notiManager.removeRequest(withIdentifier: removeItem.identifier)
                        }
                    }
                }
                .listStyle(.plain)
                
            } // VStack
            .task {
                await notiManager.getPendingRequests()
            }
            .navigationBarItems(leading: EditButton())
        }
    } // body
} // struct

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView(isShownNotification: .constant(false))
            .environmentObject(MyNoteStore())
            .environmentObject(NotificationManager())
    }
}
