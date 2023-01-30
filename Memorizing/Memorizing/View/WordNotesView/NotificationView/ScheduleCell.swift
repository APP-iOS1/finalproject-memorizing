//
//  ScheduleCell.swift
//  Memorizing
//
//  Created by 진태영 on 2023/01/30.
//

import SwiftUI

struct ScheduleCell: View {
    @EnvironmentObject var myNoteStore: MyNoteStore
    @State var notiId: String
    @State private var date: Date = Date()
    // @State private var wordNote: MyWordNote?
    @State private var wordNote: MyWordNote? = MyWordNote(
        id: "id",
        noteName: "노트 이름",
        noteCategory: "카테고리",
        enrollmentUser: "작성자",
        repeatCount: 0,
        firstTestResult: 0,
        lastTestResult: 0,
        updateDate: Date(),
        reviewDate: Date()
    )
    @State private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        return dateFormatter
    }()
    @State private var testToggle: Bool = false
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Image(systemName: "exclamationmark.bubble")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.mainBlue)
                   // .padding(.leading, 10)
                
                VStack(alignment: .leading) {
                    Text("\(wordNote?.noteName ?? "NoteName")")
                        .foregroundColor(.black)
                        .font(.headline)
                    
                    VStack(alignment: .leading) {
                        Text("\(wordNote?.repeatCount ?? 99)" + "번째 복습 예정 시간: ")
                        Text("\(dateFormatter.string(from: Date()))")
                    } // HStack
                    .font(.footnote)
                    .fontWeight(.light)
                } // VStack
                .padding(.horizontal, 10)
                Spacer()
                
                Toggle("", isOn: $testToggle)
                    .toggleStyle(SwitchToggleStyle(tint: Color.mainBlue))
                    .frame(width: 50)
                
            } // HStack
            Divider()
        } // VStack
        .onAppear {
            // TODO: - 서버 노티 구현하면 onAppear에 wordNote 대입하는거 검토
            // wordNote = myNoteStore.myWordNotes.first { $0.id == notiId }
        }
            
    } // body
}

struct ScheduleCell_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleCell(notiId: "notiId")
            .environmentObject(MyNoteStore())
        
    }
}
