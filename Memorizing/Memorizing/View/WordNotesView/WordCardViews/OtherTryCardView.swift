//
//  OtherTryCardView.swift
//  Memorizing
//
//  Created by 전근섭 on 2023/01/06.
//

import SwiftUI

// MARK: 두번째, 세번째 복습하기 뷰
struct OtherTryCardView: View {
    
    //    // FIXME: 단어장 이름 firebase에서 가져오기...?
    //    @State private var wordListName: String = "혜지의 감자 목록 100가지 단어장"
    //    // FIXME: 단어장 단어 총 수
    //    @State private var listLength: Int = 100
    //    // FIXME: 단어장 현재 단어 x번째
    //    @State private var currentListLength: Int = 30
    //    // FIXME: 현재 단어
    //    @State private var currentWord: String = "정우성"
    //    // FIXME: 현재 단어 뜻
    //    @State private var currentWordDef: String = "현기"
    
    @Environment(\.dismiss) private var dismiss
    var myWordNote: NoteEntity
    var words: [WordEntity] {
        myWordNote.words?.allObjects as? [WordEntity] ?? []
    }
    @State var isDismiss: Bool = false
    @State var num = 0
    @State private var isShowingNotSaveAlert: Bool = false
    
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
                    WordCardAnswerView2(
                        listLength: wordCount,
                        currentListLength: $num,
                        currentWordDef: words[num].wordMeaning ?? "No Meaning"
                    )
                } else {
                    WordCardQuestionView2(
                        listLength: wordCount,
                        currentListLength: $num,
                        currentWord: words[num].wordString ?? "No String"
                    )
                }
            }
            .onTapGesture {
                flipCard()
            }
            
            NextPreviousButton(
                isFlipped: $isFlipped,
                isDismiss: $isDismiss,
                num: $num,
                wordNote: myWordNote,
                lastWordIndex: wordCount
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
                .frame(width: 393, height: 3)
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
        print("flipcard 실행")
        print(isFlipped)
        isFlipped.toggle()
    }
}

// MARK: 카드 단어 뜻 뷰
struct WordCardAnswerView2: View {
    
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
                    Text("\(currentListLength + 1) / \(listLength + 1)")
                    
                    Spacer()
                    
                }
                .padding()
                
                Spacer()
                
                // MARK: 현재 단어
                Text("\(currentWordDef)")
                    .font(.system(size: 30, weight: .bold))
                    .minimumScaleFactor(0.4)
                    .foregroundColor(Color("MainBlue"))
                    .frame(width: UIScreen.main.bounds.width * 0.8,
                           height: UIScreen.main.bounds.width * 0.4)
                    .padding(.bottom, 20)
                    .padding(.horizontal, 20)
                
                Spacer()
                
            }
        }
        .frame(width: 330, height: 330)
    }
}

// MARK: 카드 단어 뷰
struct WordCardQuestionView2: View {
    
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
                    Text("\(currentListLength + 1) / \(listLength + 1)")
                    
                    Spacer()
                    
                }
                .padding()
                
                Spacer()
                
                // MARK: 현재 단어 뜻
                Text("\(currentWord)")
                    .font(.system(size: 30, weight: .bold))
                    .minimumScaleFactor(0.4)
                    .foregroundColor(Color("MainBlack"))
                    .frame(width: UIScreen.main.bounds.width * 0.8,
                           height: UIScreen.main.bounds.width * 0.4)
                    .padding(.bottom, 20)
                    .padding(.horizontal, 20)
                
                Spacer()
                
            }
        }
        .frame(width: 330, height: 330)
    }
}

// MARK: 이전 다음 버튼
struct NextPreviousButton: View {
    @EnvironmentObject var myNoteStore: MyNoteStore
    @EnvironmentObject var notiManager: NotificationManager
    
    @Binding var isFlipped: Bool
    @Binding var isDismiss: Bool
    @Binding var num: Int
    @State private var isShowingStampView: Bool = false
    
    var wordNote: NoteEntity
    var lastWordIndex: Int
    
    var body: some View {
        HStack {
            // TODO: 이전 버튼
            Button {
                if 0 != num {
//                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                        num -= 1
//                    }
                    isFlipped = false
                }
            } label: {
                HStack {
                    Image(systemName: "arrowtriangle.left.fill")
                    Text("이전")
                }
                .foregroundColor(.white)
                .frame(width: 160, height: 50)
                .background(Color("MainDarkBlue"))
                .cornerRadius(15)
            }
            
            Spacer()
            
            // TODO: 다음 버튼
            Button {
                if lastWordIndex != num {
                    num += 1
                    isFlipped = false
                    
                } else {
                    isShowingStampView = true
                }
            } label: {
                HStack {
                    Text("다음")
                    Image(systemName: "arrowtriangle.right.fill")
                }
                .foregroundColor(.white)
                .frame(width: 160, height: 50)
                .background(Color("MainBlue"))
                .cornerRadius(15)
            }
            
        }
        .frame(width: 330)
        .sheet(isPresented: $isShowingStampView) {
            StudyingStampView(wordNote: wordNote, isDismiss: $isDismiss)
        }
    }
    
}

// struct OtherTryCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            OtherTryCardView()
//        }
//    }
// }
