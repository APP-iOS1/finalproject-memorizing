//
//  AddListView.swift
//  Memorizing
//
//  Created by Jae hyuk Yim on 2023/01/06.
//

import SwiftUI

struct AddListView: View {
    var wordNote: WordNote
    var word: [Word]
    // MARK: - 취소, 등록 시 창을 나가는 dismiss()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray5)
                .backgroundStyle(Color.gray7)
                .frame(width: 343, height: 100)
                .overlay {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(wordNote.noteCategory)
                                .font(.callout)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(wordNote.noteColor, lineWidth: 1)
                                        .frame(width: 45, height: 20)
                                }
                                .padding(.leading, 5)
                            Spacer().frame(height: 3)
                            Text(wordNote.noteName)
                                .font(.title2)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                }
            Divider()
                .frame(width: 400)
            
            HStack(spacing: 0) {
                Spacer()
                if word.isEmpty {
                    Text("추가된 단어가 없습니다!")
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundColor(.mainDarkBlue)
                } else {
                    Text("총 ")
                    Text("\(word.count)개")
                        .foregroundColor(.mainDarkBlue)
                    Text("의 단어")
                }
            }
            .bold()
            .padding(.trailing, 9)
            
            VStack {
                ScrollView(showsIndicators: false) {
                    ForEach(word) { list in
                        VStack(alignment: .center) {
                            AddListRow(word: list)
                        }
                    }
                    
                }
            }
            
        }
        .padding()
    }
}

// struct AddListView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddListView()
//            .environmentObject(UserStore())
//    }
// }
