////
////  AddListView.swift
////  Memorizing
////
////  Created by Jae hyuk Yim on 2023/01/06.
////
//
 import SwiftUI

struct AddListView: View {
    @EnvironmentObject var myNoteStore: MyNoteStore
    @EnvironmentObject var coreDataStore: CoreDataStore
    var wordNote: NoteEntity
    
    // MARK: - 취소, 등록 시 창을 나가는 dismiss()
    @Environment(\.dismiss) private var dismiss
    
    @State private var isShowingAddView = false
    @State private var showingAlert = false
    var body: some View {
        
        NavigationStack {
            ZStack {
                VStack {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(coreDataStore.returnColor(category: wordNote.noteCategory ?? ""), lineWidth: 1)
                        .frame(width: 50, height: 20)
                        .overlay {
                            Text(wordNote.noteCategory ?? "No category")
                                .foregroundColor(.black)
                                .font(.caption)
                        }
                        .padding(.top)
                    
                    Text(wordNote.noteName ?? "No Name")
                        .foregroundColor(.mainBlack)
                        .font(.title3)
                        .bold()
                        .lineLimit(1)
                    
                    Divider()
                    
                    HStack(spacing: 0) {
                        Spacer()
                        Text("총 ")
                        Text("\((wordNote.words?.allObjects as? [WordEntity] ?? []).count)개")
                            .foregroundColor(.mainDarkBlue)
                        Text("의 단어")
                    }
                    .font(.headline)
                    
                    Divider()
                    
                    List {
                        ForEach((wordNote.words?.allObjects as? [WordEntity] ?? [])) { word in
                            AddListRow(word: word)
                        }
                        .onDelete { indexSet in
                            // TODO: 서버에서도 같이 삭제해야함.
                            coreDataStore.deleteWord(note: wordNote, offsets: indexSet)
                        }
                    }
                    .listStyle(.inset)
                }
                .navigationTitle("나의 암기장")
                .navigationBarTitleDisplayMode(.inline)
                
                Spacer()
                
                VStack {
                    Button {
                        isShowingAddView.toggle()
                    } label: {
                        Circle()
                            .foregroundColor(.mainBlue)
                            .frame(width: 65, height: 65)
                            .overlay {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                    .bold()
                            }
                            .shadow(radius: 1, x: 1, y: 1)
                    }
                    .offset(x: UIScreen.main.bounds.width * 0.36, y: UIScreen.main.bounds.height * 0.33)
                    .sheet(isPresented: $isShowingAddView, content: {
                        AddWordView(wordNote: wordNote)
                           
                    })
                    
                }
            }
            .padding(.horizontal)
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
            .sheet(isPresented: $isShowingAddView, content: {
                AddWordView(wordNote: wordNote)
                    
            })
        }
    }

}
    // MARK: 리스트 순서 수정 함수
//    func moveList(from source: IndexSet, to destination: Int) {
//        word.move(fromOffsets: source, toOffset: destination)
//    }
// }

// struct AddListView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            AddListView(wordNote: MyWordNote(id: "",
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

// MARK: 주석 처리된 코드들 지저분 해서 밑으로 빼놓음.
/*
 VStack {
 HStack(spacing: 30) {
 HStack {
 Button {
 dismiss()
 } label: {
 //                        Text("뒤로가기")
 //                            .font(.subheadline)
 //                            .fontWeight(.regular)
 //                            .foregroundColor(.mainBlack)
 Image(systemName: "chevron.left")
 .foregroundColor(.mainBlack)
 }
 }
 .frame(width: 70)
 HStack {
 VStack {
 Text("나의 암기장")
 .font(.title3)
 .fontWeight(.bold)
 
 Text(wordNote.noteName ?? "No name")
 .bold()
 .foregroundColor(Color.mainBlue)
 .font(.caption)
 }
 }
 .frame(width: 180)
 HStack {
 Button {
 showingAlert.toggle()
 } label: {
 Text("저장하기")
 .font(.subheadline)
 .fontWeight(.regular)
 .foregroundColor(.mainBlack)
 }
 .alert(isPresented: $showingAlert) {
 Alert(title: Text("암기장을 저장하시겠습니까?"),
 message: Text(""),
 primaryButton: .destructive(Text("취소하기"),
 action: {}),
 secondaryButton: .cancel(Text("저장하기"),
 action: {
 //                            myNoteStore.myWordsWillBeFetchedFromDB(wordNote: wordNote) {
 //                                self.myWords = myNoteStore.myWords
 //                            }
 dismiss()
 }))
 }
 }
 .frame(width: 70)
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
 ForEach(wordNote.words?.allObjects as? [WordEntity] ?? []) { list in
 AddListRow(word: list)
 }
 //                    .onDelete(perform: removeList)
 
 }
 .listRowSeparator(.hidden)
 .listStyle(.inset)
 
 }
 
 }
 .padding()
 */
