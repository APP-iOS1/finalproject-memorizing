//
//  ScheduleCell.swift
//  Memorizing
//
//  Created by 진태영 on 2023/01/30.

import SwiftUI

struct ScheduleCell: View {
    @EnvironmentObject var coreDataStore: CoreDataStore
    @Binding var pendingRequest: UNNotificationRequest

    @State private var date: Date = Date()
//    @State private var wordNote: MyWordNote? = MyWordNote(
//        id: "id",
//        noteName: "노트 이름",
//        noteCategory: "카테고리",
//        enrollmentUser: "작성자",
//        repeatCount: 0,
//        firstTestResult: 0,
//        lastTestResult: 0,
//        updateDate: Date(),
//        nextStudyDate: Date()
//    )
    @State private var wordNote: NoteEntity?

    @State private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
        return dateFormatter
    }()
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Image(systemName: "exclamationmark.bubble")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.mainBlue)
                
                VStack(alignment: .leading) {
                    Text("\(wordNote?.noteName ?? "NoteName")")
                        .foregroundColor(.black)
                        .font(.headline)
                    
                    VStack(alignment: .leading) {
                        Text("\(wordNote?.repeatCount ?? 99)" + "번째 복습 예정 시간: ")
                        Text("\(dateFormatter.string(from: wordNote?.nextStudyDate ?? Date()))")
                    } // HStack
                    .font(.footnote)
                    .fontWeight(.light)
                } // VStack
                .padding(.horizontal, 10)
                Spacer()
                
                Text("")
                    .frame(width: 50)
            } // HStack
        } // VStack
        .onAppear {
            wordNote = coreDataStore.notes.first { $0.id == pendingRequest.identifier }
        }
            
    } // body
}

struct ScheduleCell_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleCell(pendingRequest: .constant(UNNotificationRequest(identifier: "", content: UNNotificationContent(), trigger: nil)))
            .environmentObject(MyNoteStore())
            .environmentObject(CoreDataStore())

    }
}
