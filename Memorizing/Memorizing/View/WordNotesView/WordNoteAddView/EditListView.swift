//
//  EditListView.swift
//  Memorizing
//
//  Created by Jae hyuk Yim on 2023/01/20.
//

import SwiftUI

 struct EditListView: View {
    @EnvironmentObject var myNoteStore: MyNoteStore
     @EnvironmentObject var coreDataStore: CoreDataStore
    var wordNote: NoteEntity
    // MARK: - 취소, 등록 시 창을 나가는 dismiss()
    @Environment(\.dismiss) private var dismiss

    @State private var isShowingAddView = false
    @State private var showingAlert = false
    var body: some View {
        VStack {
            VStack(spacing: 15) {
                // MARK: 단어장 카테고리
                HStack {
                    Text("\(wordNote.noteCategory ?? "No Categoty")")
                        .foregroundColor(.white)
                        .bold()
                        .padding(.horizontal, 25)
                        .padding(.vertical, 7)
                        .background(coreDataStore.returnColor(category: wordNote.noteCategory ?? ""))
                        .cornerRadius(20)

                    Spacer()
                }

                // MARK: 단어장 제목
                HStack {
                    Text("\(wordNote.noteName ?? "No name")")
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

                if (wordNote.words?.allObjects as? [WordEntity] ?? []).isEmpty {
                    Text("추가된 단어가 없습니다!")
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundColor(.mainDarkBlue)
                } else {
                    Text("총 ")
                    Text("\((wordNote.words?.allObjects as? [WordEntity] ?? []).count)개")
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
                    ForEach((wordNote.words?.allObjects as? [WordEntity] ?? [])) { list in
                        AddListRow(word: list)
                    }
                    .onDelete { indexSet in
                        // TODO: 서버에서도 삭제되는 메서드 만들어야함 (현재 코데에서만 삭제 중)
                        coreDataStore.deleteWord(note: wordNote, offsets: indexSet)
                    }
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
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray2)
                        .fontWeight(.light)
                }
                
            }
        }
    }

    // MARK: 리스트 순서 수정 함수
//    func moveList(from source: IndexSet, to destination: Int) {
//        word.move(fromOffsets: source, toOffset: destination)
//    }
 }

// struct EditListView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            EditListView(wordNote: MyWordNote(id: "",
//                                             noteName: "이상한 나라의 노트",
//                                             noteCategory: "IT",
//                                             enrollmentUser: "",
//                                             repeatCount: 0,
//                                             firstTestResult: 0,
//                                             lastTestResult: 0,
//                                             updateDate: Date()),
//                        myWords: .constant([Word(id: "",
//                                   wordString: "앨리스는 누구인가?",
//                                   wordMeaning: "이상한 나라에 사는 공주",
//                                   wordLevel: 1)]))
//        }
//    }
// }
