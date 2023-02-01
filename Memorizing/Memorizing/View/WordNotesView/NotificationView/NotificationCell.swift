//
//  NotificationCell.swift
//  Memorizing
//
//  Created by 진태영 on 2023/01/20.
//

import SwiftUI

struct NotificationCell: View {
    @EnvironmentObject var myNoteStore: MyNoteStore
    @State var notiId: String
    @State private var date: Date = Date()
    @State private var wordNote: MyWordNote?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("id: \(notiId)")
                Text("복습 날짜 들어갈자리")
            Text("\(wordNote?.noteName ?? "NoteName")" + " \(wordNote?.repeatCount ?? 99)" + "번째 복습 알림")
        } // VStack
        .onAppear {
            wordNote = myNoteStore.myWordNotes.first { $0.id == notiId }
            
        }
    } // body
} // struct

struct NotificationCell_Previews: PreviewProvider {
    static var previews: some View {
        NotificationCell(notiId: "noti ID")
            .environmentObject(MyNoteStore())
    }
}
