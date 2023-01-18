//
//  AddListView.swift
//  Memorizing
//
//  Created by Jae hyuk Yim on 2023/01/06.
//

import SwiftUI

struct AddListView: View {
    var wordNote: WordNote
    @Binding var word: [Word]
    // MARK: - 취소, 등록 시 창을 나가는 dismiss()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            VStack(spacing: 15) {
                
                // MARK: 단어장 카테고리
                HStack {
                    Text("\(wordNote.noteCategory)")
                        .foregroundColor(.white)
                        .bold()
                        .padding(.horizontal, 25)
                        .padding(.vertical, 7)
                        .background(wordNote.noteColor)
                        .cornerRadius(20)
                    
                    Spacer()
                }
                
                // MARK: 단어장 제목
                HStack {
                    Text("\(wordNote.noteName)")
                        .bold()
                        .foregroundColor(Color("MainBlack"))
                        .font(.title2)
                    
                    Spacer()
                }
                
                // MARK: 단어장 날짜
                HStack {
                    Text("2023.01.18")
                        .foregroundColor(.gray2)
                    
                    Spacer()
                }
                
            }
            
            Divider()
                .frame(width: 400, height: 5)
                .overlay(Color("Gray5"))
            
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
            .padding(.vertical)
            
            // MARK: 등록된 단어 밀어서 삭제 리스트 구현
            VStack {
                List {
                    ForEach(word) { list in
                        AddListRow(word: list)
                    }
                    .onDelete(perform: removeList)
//                    .onMove(perform: moveList)
                }
                .listStyle(.inset)
//                .toolbar {
//                    EditButton()
//                }
            }
            
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text("취소")
                        .foregroundColor(Color("MainBlack"))
                        .font(.title3)
                }

            }
        }
    }
    
    // MARK: 리스트 밀어서 삭제 함수 (일단 리스트 상에서만 삭제됨, 서버에서 삭제 x)
    func removeList(at offsets: IndexSet) {
        word.remove(atOffsets: offsets)
    }
    
    // MARK: 리스트 순서 수정 함수
//    func moveList(from source: IndexSet, to destination: Int) {
//        word.move(fromOffsets: source, toOffset: destination)
//    }
}

// struct AddListView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            AddListView(wordNote: WordNote(id: "1",
//                                           noteName: "퀴즈를 통해 알아보는 시사/경제",
//                                           noteCategory: "경제",
//                                           enrollmentUser: "혜동이",
//                                           repeatCount: 2,
//                                           notePrice: 40),
//                        word: [Word(id: "1",
//                                    wordString: "선거의 4원칙은?",
//                                    wordMeaning: "보통, 평등, 직접, 비밀",
//                                    wordLevel: 2),
//                               Word(id: "2",
//                                    wordString: "3권 분립이란?",
//                                    wordMeaning: "입법, 사법, 행정",
//                                    wordLevel: 3)])
//            .environmentObject(UserStore())
//        }
//    }
// }
