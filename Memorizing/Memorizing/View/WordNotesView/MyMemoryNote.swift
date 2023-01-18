//  MyMemoryNote.swift
//  Memorizing
//
//  Created by 염성필 on 2023/01/05.
//

import SwiftUI

struct MyMemoryNote: View {
    @EnvironmentObject var userStore: UserStore
    var myWordNote: WordNote
    var body: some View {
        
        VStack(spacing: 30) {
            
            //            if userStore.myWords.count == 0 {
            WordRegistrationView(myWordNote: myWordNote)
            //            } else {
            //                WordRegistrationView(myWordNote: myWordNote, isButton : false)
            //            }
            
        }
        //        .onAppear {
        //            userStore.fetchMyWords(wordNote: myWordNote)
        //        }
        
    }
    
    // MARK: - 진행중인 암기만 보기
    var processingWordCheck: some View {
        HStack {
            Spacer()
            HStack {
                // 진행중인 암기 체크하기
                Button {
                    print("진행 중인 암기만 보기")
                } label: {
                    Image(systemName: "checkmark.circle")
                    // 버튼 체크하면 색상 파란색으로 바뀜
                }
                Text("진행 중인 암기만 보기")
                    .font(.subheadline)
            }
            .foregroundColor(.gray3)
        }
        .padding(.trailing, 20)
    }
}

// struct MyMemoryNote_Previews: PreviewProvider {
//    static var previews: some View {
//        MyMemoryNote(myWordNote: <#WordNote#>)
//    }
// }

// MARK: - 단어 등록 완료된 뷰
struct WordRegistrationView: View {
    @EnvironmentObject var userStore: UserStore
    var myWordNote: WordNote
    @State private var noteLists: [Word] = []
    @State private var isShowingSheet: Bool = false
    @State private var opacityValue: Double = 0
//    @State var isAddShowing: Bool = false
    
    // 한 번도 안 하면 -1, 한 번씩 할 때마다 1씩 증가
    @State var progressStep: Int = 0
    
    var body: some View {
        //            if list.isEmpty {
        //                AddWordView(wordNote: myWordNote, list: $list)
        //            } else {
        //                AddListView(wordNote: myWordNote, word: list)
        //            }
        VStack(spacing: 25) {
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray4)
                .foregroundColor(.white)
                .frame(width: 350, height: 140)
                .overlay {
                    HStack {
                        Rectangle()
                            .cornerRadius(10, corners: [.topLeft, .bottomLeft])
                            .frame(width: 16)
                            .foregroundColor(myWordNote.noteColor)
                        
                        VStack(spacing: 5) {
                            HStack(alignment: .top) {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(myWordNote.noteColor, lineWidth: 1)
                                    .frame(width: 50, height: 20)
                                    .overlay {
                                        Text(myWordNote.noteCategory)
                                            .foregroundColor(.black)
                                            .font(.caption)
                                        
                                    }
                                Spacer()
                            }
                            .padding(.horizontal, 15)
                            
                            // 암기할 것 등록하기에서 받아오기
                            HStack {
                                Text(myWordNote.noteName)
                                    .foregroundColor(.mainBlack)
                                    .font(.headline)
                                    .padding(.top, 7)
                                    .padding(.leading, 4)
                                Spacer()
                            }
                            .padding(.horizontal, 15)
                            .padding(.bottom, 10)
                            
                            if noteLists.isEmpty {
                                Text("단어 등록하러 가기")
                                    .font(.footnote)
                                    .frame(width: 290, height: 25)
                                    .foregroundColor(.white)
                                    .background { myWordNote.noteColor }
                                    .cornerRadius(30)
                                    .opacity(opacityValue)
                            } else {
                                // MARK: 얼굴 진행도
                                FaceProgressView(myWordNote: myWordNote)
                                    .opacity(opacityValue)
                            }
                        }
                        .padding(.trailing, 15)
                    }
                }
                .overlay {
                    HStack {
                        Spacer()
                        
                        VStack {
                            Image(systemName: "chevron.forward")
                                .foregroundColor(.gray2)
                                .bold()
                            Spacer()
                        }
                        .padding(.top, 25)
                    }
                    .padding(.trailing, 25)
                }
                .padding(.vertical, 5)
                .onTapGesture(perform: {
                    isShowingSheet.toggle()
                })
                .sheet(isPresented: $isShowingSheet) {
                    if noteLists.isEmpty {
                        AddWordView(wordNote: myWordNote, noteLists: $noteLists)
                    } else {
                        AddListView(wordNote: myWordNote, word: noteLists)
                    }
                }
        }
        .onAppear {
            if userStore.user != nil {
                userStore.myWordsWillFetchDB(wordNote: myWordNote) {
                    noteLists = userStore.myWords
                    
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                opacityValue = 1
            }
        }
    }
}

// MARK: - 단어 등록하러가기 버튼 있는 뷰
struct WordRegistrationCompletionView: View {
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.black, lineWidth: 1)
                .frame(width: 350, height: 120)
                .overlay {
                    HStack {
                        Rectangle()
                            .cornerRadius(10, corners: [.topLeft, .bottomLeft])
                            .frame(width: 16)
                            .foregroundColor(.blue)
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                            // 암기 해야할것에서 컬러 가져오기
                                .stroke(.yellow, lineWidth: 1)
                                .frame(width: 50, height: 30)
                                .overlay {
                                    Text("영어")
                                        .font(.subheadline)
                                    
                                }
                            
                            // 암기할 것 등록하기에서 받아오기
                            VStack(spacing: 12) {
                                NavigationLink {
                                    EmptyView()
                                } label: {
                                    Text("혜지의 감자 목록 100가지 단어장 ")
                                        .font(.title3)
                                }
                                // progressView 들어올 예정
                                
                            }
                        }
                        Spacer()
                    }
                }
        }
    }
}
