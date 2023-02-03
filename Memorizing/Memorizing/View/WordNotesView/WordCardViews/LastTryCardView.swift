//
//  LastTryCardView.swift
//  Memorizing
//
//  Created by 이종현 on 2023/01/06.
//

import SwiftUI

struct LastTryCardView: View {
    @Environment(\.dismiss) private var dismiss
    var myWordNote: NoteEntity
    var words: [WordEntity] {
        myWordNote.words?.allObjects as? [WordEntity] ?? []
    }
    @State var isDismiss: Bool = false
    @State var num = 0
    //    // FIXME: 단어장 이름 firebase에서 가져오기...?
    //    @State private var wordListName: String
    //    // FIXME: 단어장 단어 총 수
    //    @State private var listLength: Int = 0
    //    // FIXME: 단어장 현재 단어 x번째
    //    @State private var currentListLength: Int
    //    // FIXME: 현재 단어
    //    @State private var currentWord: String
    //    // FIXME: 현재 단어 뜻
    //    @State private var currentWordDef: String
    var wordCount: Int {
        words.count - 1
    }
    
    @State var totalScore: Double = 0
    
    // MARK: 카드 뒤집는데 쓰일 것들
    @State var isFlipped = false
    
    var body: some View {
        //        if num > wordCount {
        //            GoodJobStampView(wordNote: myWordNote, isDismiss: $isDismiss)
        //        } else {
        VStack {
            ZStack {
                // 진행바
                rectangleProgressView
                    .overlay {
                        overlayView.mask(rectangleProgressView)
                    }
            }
            .padding(.bottom, 30)
            
            // MARK: 카드뷰
            ZStack {
                if isFlipped {
                    WordCardMeaningView(
                        listLength: words.count,
                        currentListLength: $num,
                        currentWordDef: words[num].wordMeaning ?? "No Meaning"
                    )
                } else {
                    WordCardWordView(
                        listLength: words.count,
                        currentListLength: $num,
                        currentWord: words[num].wordString ??  "No String"
                    )
                }
            }
            .onTapGesture {
                print("flipcard 실행")
                print(isFlipped)
                flipCard()
            }
            
            LevelCheckForLast(
                isFlipped: $isFlipped,
                isDismiss: $isDismiss,
                totalScore: $totalScore,
                lastWordIndex: wordCount,
                num: $num,
                wordNote: myWordNote,
                word: words[num]
            )
            .padding(.top)
            
            Spacer()
            
        }
        .navigationTitle(myWordNote.noteName ?? "No Name")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: isDismiss, perform: { _ in
            dismiss()
        })
        .onChange(of: isFlipped, perform: { _ in
            flipCard()
        })
    }
    
    //    }
    
    // MARK: 파란 진행바 뷰
    var overlayView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color("MainBlue"))
                    .frame(width: CGFloat(num) / CGFloat(wordCount) * geometry.size.width)
                    .animation(.easeInOut, value: num)
            }
            
        }
        .allowsHitTesting(false)
        
    }
    
    // MARK: 회색 전체 진행 바
    var rectangleProgressView: some View {
        HStack(spacing: 0) {
            Rectangle()
                .frame(width: 400, height: 3)
                .foregroundColor(Color("Gray4"))
            
        }
    }
    
    // MARK: 카드 뒤집기 함수
    func flipCard () {
        isFlipped.toggle()
    }
}

struct LevelCheckForLast: View {
    @State var isShowingModal: Bool = false
    @Binding var isFlipped: Bool
    @Binding var isDismiss: Bool
    @Binding var totalScore: Double
    var lastWordIndex: Int
    @Binding var num: Int
    var wordNote: NoteEntity
    var word: WordEntity
    
    @EnvironmentObject var myNoteStore: MyNoteStore
    @EnvironmentObject var coreDataStore: CoreDataStore
    
    var body: some View {
        HStack(spacing: 15) {
            // sfsymbols에 얼굴이 다양하지 않아 하나로 통일함
            Button {
                coreDataStore.updateWordLevel(word: word, level: 0)
                if lastWordIndex != num {
                    num += 1
                    isFlipped = false
                } else {
                    isShowingModal = true
                }
                
            } label: {
                VStack {
                    Image(systemName: "face.smiling")
                        .font(.largeTitle)
                        .padding(1)
                    Text("모르겠어요")
                        .font(.headline)
                }
                .modifier(CheckDifficultyButton(backGroundColor: "Gray2"))
            }
            
            Button {
                coreDataStore.updateWordLevel(word: word, level: 1)
                if lastWordIndex != num {
                    num += 1
                    isFlipped = false
                    totalScore += 0.25
                } else {
                    isShowingModal = true
                }
            } label: {
                VStack {
                    Image(systemName: "face.smiling")
                        .font(.largeTitle)
                        .padding(1)
                    Text("애매해요")
                        .font(.headline)
                }
                .modifier(CheckDifficultyButton(backGroundColor: "MainBlue"))
            }
            
            Button {
                coreDataStore.updateWordLevel(word: word, level: 2)
                if lastWordIndex != num {
                    num += 1
                    isFlipped = false
                    totalScore += 1
                } else {
                    isShowingModal = true
                }
            } label: {
                VStack {
                    Image(systemName: "face.smiling")
                        .font(.largeTitle)
                        .padding(1)
                    Text("외웠어요!")
                        .font(.headline)
                }
                .modifier(CheckDifficultyButton(backGroundColor: "MainDarkBlue"))
            }
            
        }
        .fullScreenCover(isPresented: $isShowingModal) {
            if totalScore / Double(lastWordIndex) >= 0.75 {
                GoodJobStampView(wordNote: wordNote, isDismiss: $isDismiss)
            } else {
                TryAgainView(wordNote: wordNote, isDismiss: $isDismiss)
            }
        }
    }
}

// struct LastTryCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        LastTryCardView()
//    }
// }
