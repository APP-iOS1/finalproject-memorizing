//
// AddListView.swift
// Memorizing
//
// Created by Jae hyuk Yim on 2023/01/06.
//

 import SwiftUI

struct AddListView: View {
    @EnvironmentObject var myNoteStore: MyNoteStore
    @EnvironmentObject var coreDataStore: CoreDataStore
    var wordNote: NoteEntity
    
    // MARK: - 취소, 등록 시 창을 나가는 dismiss()
    @Environment(\.dismiss) private var dismiss
    
    @State private var isShowingAddView = false
    @State private var isToastToggle = false
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
                            Task {
                                let word = await myNoteStore.myWordDidDeleteMyNote(note: wordNote, offset: indexSet)
                                if let word {
                                    coreDataStore.deleteWord(word: word)
                                }
                            }

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
                        AddWordView(wordNote: wordNote,
                                    isToastToggle: $isToastToggle)
                           
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
                AddWordView(wordNote: wordNote,
                            isToastToggle: $isToastToggle)
            })
        }
    }

}
