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
    @State private var wordAddRestrictionToast = false
    @State private var wordAddToast = false
    @State private var showingAlert = false
    @State private var todayDate = Date()
    @State private var isWordCountCheckToggle = false
    
    // 단어장 삭제 Flag - 재혁추가
    @State private var isShownDeleteQuestionAlert: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                VStack(spacing: 5) {
                    
                    // MARK: 단어장 날짜
                    HStack {
                        // FIXME: 날짜 변경
                        Text("2023.01.18")
                            .foregroundColor(.gray2)
                            .font(.caption)
                        
                        Spacer()
                    }
                    
                    HStack(alignment: .top) {
                        // MARK: 단어장 제목
                        Text("\(wordNote.noteName ?? "No name")")
                            .bold()
                            .foregroundColor(Color("MainBlack"))
                            .font(.title2)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        // MARK: 단어장 카테고리
                        Text("\(wordNote.noteCategory ?? "No Categoty")")
                            .foregroundColor(.white)
                            .font(.caption)
                            .bold()
                            .padding(.horizontal, 20)
                            .padding(.vertical, 7)
                            .background(coreDataStore.returnColor(category: wordNote.noteCategory ?? ""))
                            .cornerRadius(20)
                    }
                }
                .padding(.vertical)
                .padding(.bottom)
                .padding(.horizontal, 25)
                .background(Color.gray6)
                
                HStack {
                    Spacer()
                        HStack(spacing: 0) {
                            Text("총 ")
                            Text("\((wordNote.words?.allObjects as? [WordEntity] ?? []).count)개")
                                .foregroundColor(.mainDarkBlue)
                            Text("의 단어")
                        }
                        .font(.callout)
                        .padding(.horizontal, 25)
                }
                .bold()
                .padding(.top, 7)
                
                // MARK: 등록된 단어 밀어서 삭제 리스트 구현
                VStack {
                    if wordNote.words?.count == 0 {
                        VStack {
                            Spacer()
                                .frame(height: UIScreen.main.bounds.height * 0.23)
                            
                            Text("등록된 단어가 없습니다")
                                .padding(.bottom, 5)
                                .font(.headline)
                            HStack(spacing: 0) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.mainBlue)
                                Text("를 눌러 단어를 추가해주세요!")
                            }
                            .font(.footnote)
                            Spacer()
                        }
                        .foregroundColor(Color.gray1)
                        .fontWeight(.medium)
                    } else {
                        List {
                            let words: [WordEntity] = wordNote.words?.allObjects as? [WordEntity] ?? []
                            
                            ForEach(words) { list in
                                AddListRow(word: list)
                            }
                            .onDelete { indexSet in
                                Task {
                                    let word = await myNoteStore.myWordDidDeleteMyNote(note: wordNote, offset: indexSet)
                                    if let word {
                                        coreDataStore.deleteWord(word: word)
                                    }
                                }
                            }
                            
                            // 마지막 요소 밑에 여유공간
                            Rectangle()
                                .frame(height: 100)
                                .foregroundColor(.white)
                                .listRowSeparator(.hidden)
                        }
                        .listStyle(.inset)
                    }
                }
                .padding(.horizontal, 25)
                
                Spacer()
            }
            
            Button {
                if wordNote.words?.count ?? 0 < 50 {
                    isShowingAddView.toggle()
                } else {
                    isWordCountCheckToggle.toggle()
                }
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
            .offset(x: UIScreen.main.bounds.width * 0.36,
                    y: UIScreen.main.bounds.height * 0.33)
            .sheet(isPresented: $isShowingAddView, content: {
                AddWordView(wordNote: wordNote,
                            wordAddRestrictionToast: $wordAddRestrictionToast,
                            wordAddToast: $wordAddToast)
                .AddWordToastMessage(isPresented: $wordAddToast,
                                    message: "암기 항목이 등록되었습니다!",
                                    delay: 1)
            })
            .customAlert(isPresented: $isWordCountCheckToggle,
                         title: "암기장 내용 초과",
                         message: "하나의 암기장에 최대 50개까지만 추가가 가능합니다.",
                         primaryButtonTitle: "확인",
                         primaryAction: {
            },
                         withCancelButton: false,
                         cancelButtonText: "아니요")
        }
        .onAppear {
            print("EditListView onAppear")
        }
        .onDisappear {
            print("EditListView onDisappear")
        }
        .toolbar {
            // MARK: 뒤로가기 버튼
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray2)
                        .fontWeight(.light)
                }
            }
            // MARK: 삭제하기 등 추가 액션 메뉴 버튼
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        isShownDeleteQuestionAlert.toggle()
                    } label: {
                        HStack {
                            Text("암기장 삭제하기")
                            Image(systemName: "trash.fill")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.mainBlack)
                        .rotationEffect(.degrees(-90))
                }
            }
        }
        .navigationTitle("나의 암기장")
        .navigationBarTitleDisplayMode(.inline)
        .customToastMessage(isPresented: $wordAddRestrictionToast,
                            message: "더 이상 등록할 수 없습니다",
                            delay: 0.5)
        // MARK: - 암기장 삭제 - 재혁추가
        .customAlert(isPresented: $isShownDeleteQuestionAlert,
                     title: "나의 암기장 삭제하기",
                     message: "삭제한 암기장은 다시 복구할 수 없습니다.\n삭제하시겠습니까?",
                     primaryButtonTitle: "네",
                     primaryAction: {
            myNoteStore.myNotesDidDeleteDB(wordNote: wordNote)
            coreDataStore.deleteNote(note: wordNote)
        },
                     withCancelButton: true,
                     cancelButtonText: "아니요")
    }
}
