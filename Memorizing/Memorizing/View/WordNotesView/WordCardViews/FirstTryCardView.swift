//
//  FirstTryCardView.swift
//  Memorizing
//
//  Created by 전근섭 on 2023/01/05.
//

import SwiftUI
import AVFoundation

struct FirstTryCardView: View {
    @Environment(\.dismiss) private var dismiss
    var myWordNote: WordNote
    @State var word: [Word]
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
        word.count - 1
    }
    
    // MARK: 카드 뒤집는데 쓰일 것들
    @State var backDegree = 0.0
    @State var frontDegree = -90.0
    @State var isFlipped = false
    let width: CGFloat = 200
    let height: CGFloat = 250
    let durationAndDelay: CGFloat = 0.3
    
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
            
            LevelCheck(
                isShowingModal: .constant(false),
                isFlipped: $isFlipped,
                isDismiss: $isDismiss,
                totalScore: $totalScore,
                lastWordIndex: wordCount,
                num: $num,
                isShowingAlert: $isShowingAlert,
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

// MARK: 카드 뒷 뷰
struct WordCardBackView: View {
    
    // MARK: 단어장 단어 총 수
    var listLength: Int
    // MARK: 단어장 현재 단어 x번째
    @Binding var currentListLength: Int
    // MARK: 현재 단어 뜻
    var currentWordDef: String
    // MARK: 카드 뒤집기 각도
    @Binding var degree: Double
    
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
                    
                    // 소리 버튼
                    Button {
                        
                    } label: {
                        Image(systemName: "speaker.wave.2")
                            .foregroundColor(Color("MainBlack"))
                    }
                }
                .padding()
                
                Spacer()
                
                // MARK: 현재 단어
                Text("\(currentWordDef)")
                    .padding(.bottom, 70)
                    .font(.largeTitle).bold()
                
                Spacer()
                
            }
        }
        .frame(width: 330, height: 330)
        .rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
    }
}

// MARK: 카드 앞 뷰
struct WordCardFrontView: View {
    
    // MARK: 단어장 단어 총 수
    var listLength: Int
    // MARK: 단어장 현재 단어 x번째
    @Binding var currentListLength: Int
    // MARK: 현재 단어
    var currentWord: String
    // MARK: 카드 뒤집기 각도
    @Binding var degree: Double
    
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
                    
                    // 소리 버튼
                    Button {
                        // FIXME: 진짜 다해봤는데 안됨
                    } label: {
                        Image(systemName: "speaker.wave.2")
                            .foregroundColor(Color("MainBlack"))
                    }
                }
                .padding()
                
                Spacer()
                
                // MARK: 현재 단어 뜻
                Text("\(currentWord)")
                    .foregroundColor(Color("MainBlue"))
                    .padding(.bottom, 70)
                    .font(.largeTitle).bold()
                
                Spacer()
                
            }
        }
        .frame(width: 330, height: 330)
        .rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
    }
}

// MARK: 모르, 애매, 외웠 버튼 뷰
struct LevelCheck: View {
    @Binding var isShowingModal: Bool
    @Binding var isFlipped: Bool
    @Binding var isDismiss: Bool
    @Binding var totalScore: Double
    var lastWordIndex: Int
    @Binding var num: Int
    @Binding var isShowingAlert: Bool
    var wordNote: WordNote
    var word: Word
    
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var notiManager: NotificationManager
    
    var body: some View {
        HStack(spacing: 15) {
            // sfsymbols에 얼굴이 다양하지 않아 하나로 통일함
            Button {
                // TODO: 모르겠어요 액션
                authStore.wordsLevelDidChangeDB(wordNote: wordNote, word: word, level: 0)
                if lastWordIndex != num {
                    isFlipped = false
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                        num += 1
                    }
                    
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
                // TODO: 애매해요 액션
                authStore.wordsLevelDidChangeDB(wordNote: wordNote, word: word, level: 1)
                if lastWordIndex != num {
                    isFlipped = false
                    totalScore += 0.25
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                        num += 1
                    }
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
                // TODO: 외웠어요 액션
                authStore.wordsLevelDidChangeDB(wordNote: wordNote, word: word, level: 2)
                if lastWordIndex != num {
                    isFlipped = false
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                        num += 1
                    }
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
        .alert(
            "Alert Title",
            isPresented: $isShowingAlert
        ) {
            Button("Ok") {
                Task {
                    await authStore.repeatCountDidPlusOne(wordNote: wordNote)
                    if !notiManager.isGranted {
                        notiManager.openSetting()
                    } else {
                        print("set localNotification")
                        var localNotification = LocalNotification(
                            identifier: UUID().uuidString,
                            title: "MEMOrizing 암기 시간",
                            body: "1번째 복습할 시간이에요~!",
                            timeInterval: 1,
                            repeats: false
                        )
                        localNotification.subtitle = "\(wordNote.noteName)"
                        print("localNotification: ", localNotification)
                        await notiManager.schedule(localNotification: localNotification)
                        await notiManager.getPendingRequests()
                    }
                    isDismiss.toggle()
                }
            }
        } message: {
            Text("모든 단어를 공부했습니다 :)")
        }
        //                .sheet(isPresented: $isShowingModal) {
        //                    if totalScore / Double(lastWordIndex) >= 0.75 {
        //                        GoodJobStampView(wordNote: wordNote, isDismiss: $isDismiss)
        //                    }
        //                        else {
        //                        TryAgainView()
        //                    }
        //                }
    }
}

// struct FirstTryCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            FirstTryCardView(myWordNote: <#WordNote#>, word: <#[Word]#>)
//        }
//    }
// }
