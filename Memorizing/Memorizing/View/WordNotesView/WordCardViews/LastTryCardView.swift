//
//  LastTryCardView.swift
//  Memorizing
//
//  Created by 이종현 on 2023/01/06.
//

import SwiftUI

struct LastTryCardView: View {
    @Environment(\.dismiss) private var dismiss
    var myWordNote: WordNote
    var word: [Word]
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
        word.count - 1
    }
    @State var isShowingModal: Bool = false
    @State var totalScore: Double = 0
    
    // MARK: 카드 뒤집는데 쓰일 것들
    @State var backDegree = 0.0
    @State var frontDegree = -90.0
    @State var isFlipped = false
    let width: CGFloat = 200
    let height: CGFloat = 250
    let durationAndDelay: CGFloat = 0.3
    
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
                WordCardFrontView(
                    listLength: word.count,
                    currentListLength: $num,
                    currentWord: word[num].wordString,
                    degree: $frontDegree
                )
                WordCardBackView(
                    listLength: word.count,
                    currentListLength: $num,
                    currentWordDef: word[num].wordMeaning,
                    degree: $backDegree
                )
            }
            .onTapGesture {
                flipCard()
            }
            
            LevelCheckForLast(
                isShowingModal: $isShowingModal,
                isFlipped: $isFlipped,
                isDismiss: $isDismiss,
                totalScore: $totalScore,
                lastWordIndex: wordCount,
                num: $num,
                wordNote: myWordNote,
                word: word[num]
            )
            .padding(.top)
            
            Spacer()
            
        }
        .navigationTitle(myWordNote.noteName)
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
        isFlipped = !isFlipped
        if isFlipped {
            withAnimation(.linear(duration: durationAndDelay)) {
                backDegree = 90
            }
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)) {
                frontDegree = 0
            }
        } else {
            withAnimation(.linear(duration: durationAndDelay)) {
                frontDegree = -90
            }
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)) {
                backDegree = 0
            }
        }
    }
    
}

struct LevelCheckForLast: View {
    @Binding var isShowingModal: Bool
    @Binding var isFlipped: Bool
    @Binding var isDismiss: Bool
    @Binding var totalScore: Double
    var lastWordIndex: Int
    @Binding var num: Int
    var wordNote: WordNote
    var word: Word
    
    @EnvironmentObject var authStore: AuthStore
    var body: some View {
        HStack(spacing: 15) {
            // sfsymbols에 얼굴이 다양하지 않아 하나로 통일함
            Button {
                // TODO: 모르겠어요 액션
                authStore.wordsLevelDidChangeDB(wordNote: wordNote, word: word, level: 0)
                if lastWordIndex != num {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                        num += 1
                    }
                    isFlipped = false
                } else {
                    //                    isShowingAlert = true
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
                // TODO: 애매해요 액션
                authStore.wordsLevelDidChangeDB(wordNote: wordNote, word: word, level: 1)
                if lastWordIndex != num {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                        num += 1
                    }
                    isFlipped = false
                    totalScore += 0.25
                } else {
                    //                    isShowingAlert = true
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
                // TODO: 외웠어요 액션
                authStore.wordsLevelDidChangeDB(wordNote: wordNote, word: word, level: 2)
                if lastWordIndex != num {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                        num += 1
                    }
                    isFlipped = false
                    totalScore += 1
                } else {
                    //                    isShowingAlert = true
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
        .sheet(isPresented: $isShowingModal) {
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
