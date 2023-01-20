//  MyMemoryNote.swift
//  Memorizing
//
//  Created by 염성필 on 2023/01/05.
//

import SwiftUI

// MARK: - 단어 등록 완료된 뷰
struct MyMemoryNote: View {
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var myNoteStore: MyNoteStore
    
    var myWordNote: MyWordNote
    
    @State private var noteLists: [Word] = []
    @State private var isShowingSheet: Bool = false
    @State private var opacityValue: Double = 0
    //    @State var isAddShowing: Bool = false
    
    // 한 번도 안 하면 -1, 한 번씩 할 때마다 1씩 증가
    @State var progressStep: Int = 0
    
    var body: some View {
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
            
        }
        .fullScreenCover(isPresented: $isShowingSheet) {
            NavigationStack {
                AddListView(wordNote: myWordNote, myWords: $noteLists)
//                if noteLists.isEmpty {
//                    AddListView(wordNote: myWordNote, myWords: $noteLists)
//                } else {
//                    EditListView(wordNote: myWordNote, word: $noteLists)
//                }
            }
        }
        .onAppear {
            if authStore.user != nil {
                myNoteStore.myWordsWillBeFetchedFromDB(wordNote: myWordNote) {
                    noteLists = myNoteStore.myWords
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                opacityValue = 1
            }
        }
    }
}

// MARK: - onAppear 수정자가 있을 경우, 데이터에 따라 화면이 바뀌므로 Preview Crashed가 날 수 밖에 없음
// 따라서, 프리뷰를 보기 위해 .onAppear 수정자 내용을 싹 지워주고 나서 확인할 것
//struct MyMemoryNote_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            MyMemoryNote(myWordNote: MyWordNote(id: "03578E93-5DF4-489C-AF66-1671DD8CCE79",
//                                                noteName: "우리속담 알아보기",
//                                                noteCategory: "기타",
//                                                enrollmentUser: "hKWRjBcFi0NTuR5IjGHSsGMZUaV2",
//                                                repeatCount: 1,
//                                                firstTestResult: 0,
//                                                lastTestResult: 0,
//                                                updateDate: Date()))
//
//        }
//    }
//}
