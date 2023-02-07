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
    @State var count = 0
    @State private var isShowingNotSaveAlert: Bool = false

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
                    WordCardAnswerView(
                        listLength: words.count,
                        currentListLength: $num,
                        currentWordDef: words[num].wordMeaning ?? "No Meaning"
                    )
                } else {
                    WordCardQuestionView(
                        listLength: words.count,
                        currentListLength: $num,
                        currentWord: words[num].wordString ??  "No String"
                    )
                }
            }
            .onTapGesture {
                flipCard()
            }
            
            LevelCheckForLast(
                isFlipped: $isFlipped,
                isDismiss: $isDismiss,
                totalScore: $totalScore,
                lastWordIndex: wordCount,
                num: $num,
                count: $count,
                wordNote: myWordNote,
                word: words[num]
            )
            .padding(.top)
            
            Spacer()
            
        }
        .navigationBarBackButtonHidden(true)
        // MARK: navigationLink destination 커스텀 백 버튼
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }
        }
        .navigationTitle(myWordNote.noteName ?? "No Name")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: isDismiss, perform: { _ in
            dismiss()
        })
        .onChange(of: isFlipped, perform: { _ in
            flipCard()
        })
        // MARK: 뒤로가기 누렀을 때 저장 안된다는 경고창 보여줌
        .customAlert(isPresented: $isShowingNotSaveAlert,
                     title: "학습 중단하기",
                     message: "학습 진행 상황은 저장되지 않습니다.\n중단하시겠어요?",
                     primaryButtonTitle: "네",
                     primaryAction: {
            dismiss()
        },
                     withCancelButton: true,
                     cancelButtonText: "아니요")
    }
    
    //    }
    
    // MARK: 파란 진행바 뷰
    var overlayView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color("MainBlue"))
                    .frame(width: num == 0 ? 0 : CGFloat(num) / CGFloat(wordCount) * geometry.size.width)
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
    
    // MARK: NavigationLink 커스텀 뒤로가기 버튼
    var backButton : some View {
        Button {
            isShowingNotSaveAlert.toggle()
        } label: {
            Image(systemName: "chevron.left")
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
    @Binding var count: Int
    var wordNote: NoteEntity
    var word: WordEntity
    
    @EnvironmentObject var notiManager: NotificationManager
    @EnvironmentObject var myNoteStore: MyNoteStore
    @EnvironmentObject var coreDataStore: CoreDataStore
    
    var body: some View {
        HStack(spacing: 15) {
            // sfsymbols에 얼굴이 다양하지 않아 하나로 통일함
            Button {
                coreDataStore.updateWordLevel(word: word, level: 0)
                if lastWordIndex != num {
                    totalScore += 1
                    count += 1
                    num += 1
                    isFlipped = false
                } else {
                    totalScore += 1
                    count += 1
                    isShowingModal = true
                }
                
                
            } label: {
                VStack {
                    Image("FaceBad")
                        .font(.largeTitle)
                        .padding(1)
                    Text("모르겠어요")
                        .font(.headline)
                }
                .modifier(CheckDifficultyButton(backGroundColor: "Gray3"))
            }
            
            Button {
                coreDataStore.updateWordLevel(word: word, level: 1)
                if lastWordIndex != num {
                    totalScore += 2
                    count += 1
                    num += 1
                    isFlipped = false
                } else {
                    totalScore += 2
                    count += 1
                    isShowingModal = true
                }
            } label: {
                VStack {
                    Image("FaceNormal")
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
                    totalScore += 3
                    count += 1
                    num += 1
                    isFlipped = false
                } else {
                    totalScore += 3
                    count += 1
                    isShowingModal = true
                }
            } label: {
                VStack {
                    Image("FaceGood")
                        .font(.largeTitle)
                        .padding(1)
                    Text("외웠어요!")
                        .font(.headline)
                }
                .modifier(CheckDifficultyButton(backGroundColor: "MainDarkBlue"))
            }
        }
        .fullScreenCover(isPresented: $isShowingModal) {
            let _ = notiManager.removeRequest(withIdentifier: wordNote.id!)
            if totalScore / Double(count * 3) > 0.8 {
                let lastTestResult: Double = totalScore / Double(count * 3)
                GoodJobStampView(lastTestResult: lastTestResult,
                                 wordNote: wordNote,
                                 isDismiss: $isDismiss)
            } else {
                TryAgainView(wordNote: wordNote, isDismiss: $isDismiss)
            }
        }
        // MARK: 이해 불가 (없으면 goodjobstamp가 나오지 않는 버그)
        .onChange(of: count, perform: { newValue in
            //
        })
    }
}

// struct LastTryCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        LastTryCardView()
//    }
// }
