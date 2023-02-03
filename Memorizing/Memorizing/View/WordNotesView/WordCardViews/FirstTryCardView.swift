//
//  FirstTryCardView.swift
//  Memorizing
//
//  Created by 전근섭 on 2023/01/05.
//

import SwiftUI
import AVFoundation

struct FirstTryCardView: View {
    @EnvironmentObject var myNoteStore: MyNoteStore
    @EnvironmentObject var notiManager: NotificationManager
    @EnvironmentObject var coreDataStore: CoreDataStore
    
    @Environment(\.dismiss) private var dismiss
    var myWordNote: NoteEntity
    var words: [WordEntity] {
        myWordNote.words?.allObjects as? [WordEntity] ?? []
    }
    
    @State var isDismiss: Bool = false
    @State var num = 0
    @State var isShowingModal: Bool = false
    @State var totalScore: Double = 0
    @State var isShowingAlert: Bool = false
    // FIXME: 단어장 이름 firebase에서 가져오기...?
    //    @State private var wordListName: String
    // FIXME: 단어장 단어 총 수
    //    @State private var listLength: Int = 0
    // FIXME: 단어장 현재 단어 x번째
    //    @State private var currentListLength: Int
    // FIXME: 현재 단어
    //    @State private var currentWord: String
    // FIXME: 현재 단어 뜻
    //    @State private var currentWordDef: String
    var wordCount: Int {
        words.count - 1
    }
    
    // MARK: 카드 뒤집는데 쓰일 것들
    @State var isFlipped = false
    
    var body: some View {
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
                        currentWord: words[num].wordString ?? "No String"
                    )
                }
            }
            .onTapGesture {
                print("flipcard 실행")
                print(isFlipped)
                flipCard()
            }
            
            LevelCheck(
                isShowingModal: .constant(false),
                isFlipped: $isFlipped,
                isDismiss: $isDismiss,
                totalScore: $totalScore,
                num: $num,
                isShowingAlert: $isShowingAlert,
                lastWordIndex: wordCount,
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
        .customAlert(isPresented: $isShowingAlert,
                     title: "학습을 완료했어요!",
                     message: "모든 단어를 공부했습니다 :)",
                     primaryButtonTitle: "확인",
                     primaryAction: {
                        Task {
                            if notiManager.isNotiAllow {
                                if !notiManager.isGranted {
                                    notiManager.openSetting()
                                } else {
                                    // MARK: - 첫 번째, 학습은 TimeInterval을 통해 10분 후 알려주기
                                    print("set localNotification")
                                    var localNotification = LocalNotification(
                                        identifier: myWordNote.id ?? "No Id",
                                        title: "MEMOrizing 암기 시간",
                                        body: "\(myWordNote.noteName ?? "No Name")" + " 1번째 복습할 시간이에요~!",
                                        timeInterval: 10,
                                        repeats: false
                                    )
                                    localNotification.subtitle = "\(myWordNote.noteName ?? "No Name")"
                                    print("localNotification: ", localNotification)
                                    await notiManager.schedule(localNotification: localNotification)
                                    await myNoteStore.repeatCountWillBePlusOne(
                                        wordNote: myWordNote,
                                        nextStudyDate: Date() + Double(myWordNote.repeatCount * 1000)
                                    )
                                    coreDataStore.plusRepeatCount(note: myWordNote)
                                    await notiManager.getPendingRequests()
                                    for request in notiManager.pendingRequests {
                                        print("request: ", request as Any)
                                    }
                                    isDismiss.toggle()
                                }
                            } else {
                                isDismiss.toggle()
                            }
                        }
                     },
                     withCancelButton: false)
        
    }
    
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

// MARK: 카드 단어 뜻 뷰
struct WordCardMeaningView: View {
    
    // MARK: 단어장 단어 총 수
    var listLength: Int
    // MARK: 단어장 현재 단어 x번째
    @Binding var currentListLength: Int
    // MARK: 현재 단어 뜻
    var currentWordDef: String
    
    var body: some View {
        ZStack {
            Color.white
            
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("Gray4"), lineWidth: 1)
                .foregroundColor(.white)
            
            VStack {
                HStack {
                    // MARK: 현재 단어 순서 / 총 단어 수
                    Text("\(currentListLength + 1) / \(listLength)")
                    
                    Spacer()
                    
                }
                .padding()
                
                Spacer()
                
                // MARK: 현재 단어
                Text("\(currentWordDef)")
                    .foregroundColor(Color("MainBlue"))
                    .padding(.bottom, 70)
                    .font(.largeTitle).bold()
                
                Spacer()
                
            }
        }
        .frame(width: 330, height: 330)
    }
}

// MARK: 카드 단어 뷰
struct WordCardWordView: View {
    
    // MARK: 단어장 단어 총 수
    var listLength: Int
    // MARK: 단어장 현재 단어 x번째
    @Binding var currentListLength: Int
    // MARK: 현재 단어
    var currentWord: String
    
    var body: some View {
        ZStack {
            Color.white
            
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("Gray4"), lineWidth: 1)
                .foregroundColor(.white)
            
            VStack {
                HStack {
                    // MARK: 현재 단어 순서 / 총 단어 수
                    Text("\(currentListLength + 1) / \(listLength)")
                    
                    Spacer()
                    
                }
                .padding()
                
                Spacer()
                
                // MARK: 현재 단어 뜻
                Text("\(currentWord)")
                    .foregroundColor(Color("MainBlack"))
                    .padding(.bottom, 70)
                    .font(.largeTitle).bold()
                
                Spacer()
                
            }
        }
        .frame(width: 330, height: 330)
    }
}

// MARK: 모르, 애매, 외웠 버튼 뷰
struct LevelCheck: View {
    @Binding var isShowingModal: Bool
    @Binding var isFlipped: Bool
    @Binding var isDismiss: Bool
    @Binding var totalScore: Double
    @Binding var num: Int
    @Binding var isShowingAlert: Bool
    
    var lastWordIndex: Int
    var word: WordEntity
    
    @EnvironmentObject var coreDataStore: CoreDataStore
    var body: some View {
        HStack(spacing: 15) {
            // sfsymbols에 얼굴이 다양하지 않아 하나로 통일함
            Button {
                coreDataStore.updateWordLevel(word: word, level: 0)
                if lastWordIndex != num {
                    isFlipped = false
                    num += 1
                    
                } else {
                    isShowingAlert = true
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
                    isFlipped = false
                    totalScore += 0.25
                    num += 1
                } else {
                    isShowingAlert = true
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
                    isFlipped = false
                    num += 1
                    totalScore += 1
                    
                } else {
                    isShowingAlert = true
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
        
    }
}

// struct FirstTryCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            FirstTryCardView(myWordNote: <#WordNote#>, word: <#[Word]#>)
//        }
//    }
// }
