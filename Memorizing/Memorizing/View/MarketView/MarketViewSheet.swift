//
//  MarketViewSheet.swift
//  Memorizing
//
//  Created by 윤현기 on 2023/01/05.
//

import SwiftUI

// MARK: 암기장 구매하기 뷰
struct MarketViewSheet: View {
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var marketStore: MarketStore
    @EnvironmentObject var myNoteStore: MyNoteStore
    @EnvironmentObject var reviewStore: ReviewStore
    @Environment(\.dismiss) private var dismiss
    
    var wordNote: MarketWordNote
    
    @State private var selectedWord: [String] = []
    @State private var isAlertToggle: Bool = false
    @State private var isCoinCheckToggle: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                // MARK: - 단어장 정보
                VStack {
                    HStack {
                        Spacer()
                        Button("취소") {
                            dismiss()
                        }
                        .font(.headline)
                        .foregroundColor(.gray1)
                    }
                    
                    // 암기장 카테고리
                    HStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(wordNote.noteColor)
                            .frame(width: 40, height: 20)
                            .overlay {
                                Text(wordNote.noteCategory)
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            }
                        
                        Spacer()
                    }
                    
                    // 암기장 제목
                    HStack {
                        Text(wordNote.noteName)
                            .foregroundColor(.mainBlack)
                            .font(.title3)
                            .bold()
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    .padding(.vertical, 5)
                    
                    // 암기장 마켓등록일, 판매 금액
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.footnote)
                        
                        HStack {
                            // FIXME: 별점 총점 및 후기 총 갯수
                            Text("\(wordNote.starScoreTotal) (\(wordNote.reviewCount))")
                        
                            // FIXME: 마켓 등록일 관련 데이터 추가 후 수정
                            Text("\(wordNote.updateDate)")
                        }
                        .font(.footnote)
                        .foregroundColor(.gray2)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        Spacer()
                        
                        Text("\(wordNote.notePrice) P")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.mainDarkBlue)
                    }
                }
                .padding(.horizontal, 30)

                // MARK: - 암기장 구매하기 버튼
                if marketStore.myWordNoteIdArray.contains(wordNote.id) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray3)
                        .frame(width: 355, height: 44)
                        .overlay {
                            Text("내 암기장은 구매할 수 없습니다.")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                } else {
                    Button(action: {
                        if authStore.user?.coin ?? 0 >= wordNote.notePrice {
                            isAlertToggle.toggle()
                            isCoinCheckToggle = true
                        } else {
                            isAlertToggle.toggle()
                            isCoinCheckToggle = false
                        }
                    }, label: {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.mainBlue)
                            .frame(width: 355, height: 44)
                            .overlay {
                                Text("\(wordNote.notePrice)P로 지식 구매하기!")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                    })
                    .padding(.top)
                    .alert(isPresented: $isAlertToggle) {
                        if isCoinCheckToggle {
                            return Alert(title: Text("구매하기"),
                                         message: Text("\(wordNote.noteName)을(를) 구매하시겠습니까?"),
                                         primaryButton: .destructive(Text("구매하기"),
                                                                     action: {
                                marketStore.userCoinWillCheckDB(marketWordNote: wordNote,
                                                              words: marketStore.words)
                                dismiss()
                                
                                Task {
                                    await authStore.userInfoWillFetchDB()
                                }
                            }),
                                         secondaryButton: .cancel(Text("취소")))
                        } else {
                            return Alert(title: Text("포인트 부족"),
                                         message: Text("포인트가 부족합니다"),
                                         dismissButton: .default(Text("닫기")))
                        }
                    }
                    
                }
                
                // MARK: - 암기장 리뷰
                MarketViewSheetReviews()
                
                // MARK: - 구분선
                Divider()
                    .frame(width: 400, height: 5)
                    .overlay { Color.gray5 }
                    .padding(.bottom)
                
                // MARK: - 단어 미리보기
                HStack {
                    Text("미리보기")
                        .foregroundColor(.gray3)
                    
                    Spacer()
                    
                    HStack(spacing: 0) {
                        Text("총 ")
                        Text("\(marketStore.words.count)개")
                            .foregroundColor(.mainDarkBlue)
                        Text("의 단어")
                    }
                }
                .padding(.horizontal, 30)
                .font(.subheadline)
                .bold()
                
                // 5개의 단어만 가져오도록 함
                ForEach(Array(zip(0...4, marketStore.words)), id: \.0) { _, word in
                    
                    if selectedWord.contains(word.wordString) {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray5)
                            .backgroundStyle(Color.gray7)
                            .frame(width: 343, height: 100)
                            .overlay {
                                Button {
                                    
                                    if let index = selectedWord.firstIndex(of: word.wordString) {
                                        selectedWord.remove(at: index)
                                    }
                                    
                                } label: {
                                    VStack {
                                        Text(word.wordString)
                                            .font(.headline)
                                            .foregroundColor(.mainBlack)
                                        
                                        Spacer()
                                        
                                        Text(word.wordMeaning)
                                            .font(.headline)
                                            .foregroundColor(.mainBlue)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 15)
                                }
                            }
                            .animation(.spring(), value: selectedWord)
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray5)
                            .backgroundStyle(Color.gray7)
                            .frame(width: 343, height: 53)
                            .overlay {
                                HStack {
                                    Spacer()
                                    RoundedRectangle(cornerRadius: 1)
                                        .backgroundStyle(Color.gray5)
                                        .frame(width: 1, height: 14)
                                    Spacer()
                                }
                            }
                            .overlay {
                                Button {
                                    selectedWord.append(word.wordString)
                                } label: {
                                    HStack {
                                        Text(word.wordString)
                                            .font(.headline)
                                            .foregroundColor(.mainBlack)
                                            .frame(maxWidth: 343/2)
                                            .lineLimit(nil)
                                        Spacer()
                                        
                                        Text(word.wordMeaning)
                                            .font(.headline)
                                            .foregroundColor(.mainBlue)
                                            .frame(maxWidth: 343/2)
                                            .lineLimit(nil)
                                        
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 15)
                                }
                            }
                            .animation(.spring(), value: selectedWord)
                    }
                }
                
                VStack(spacing: 3) {
                    ForEach(0...3, id: \.self) { _ in
                        Circle()
                            .frame(width: 5, height: 5)
                            .foregroundColor(.gray3)
                    }
                }
                .padding(.vertical)
                
                Text("모든 단어는 구매한 후에 확인할 수 있어요")
                    .font(.footnote)
                    .foregroundColor(.gray2)
                    .padding(.bottom)
            } // ScrollView
        } // NavigationStack
        .onDisappear {
            myNoteStore.myNotesWillBeFetchedFromDB()
        }
//        .onAppear {
//
//            Task {
//                reviewStore.reviewsWillFetchDB(marketID: wordNote.id)
//            }
//            marketStore.wordsWillFetchDB(wordNoteID: wordNote.id)
//            authStore.notesArrayWillFetchDB()
        }
        
    }
}

// struct MarketViewSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        MarketViewSheet()
//            .environmentObject(MarketStore())
//    }
// }
