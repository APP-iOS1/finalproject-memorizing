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
    @EnvironmentObject var coreDataStore: CoreDataStore
    @Environment(\.dismiss) private var dismiss
    
    var wordNote: MarketWordNote
    
    @State private var selectedWord: [String] = []
    @State private var isAlertToggle: Bool = false
    @State private var isCoinCheckToggle: Bool = false
    
    @Binding var isToastToggle: Bool
    var body: some View {
        NavigationStack {
            ScrollView {
                
                // MARK: - 단어장 정보
                VStack (spacing: 10){
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName:"xmark")
                                .foregroundColor(.black)
                        }
                    }
                    
                    // 암기장 카테고리
                    HStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(wordNote.noteColor)
                            .frame(width: 50, height: 25)
                            .overlay {
                                Text(wordNote.noteCategory)
                                    .font(.footnote)
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                            }
                        
                        Spacer()
                    }
                    .padding(.top, 10)
                    .padding(.leading, 3)
                    
                    // 암기장 제목
                    HStack {
                        Text(wordNote.noteName)
                            .font(.title2)
                            .foregroundColor(.mainBlack)
                            .fontWeight(.semibold)
                            .padding(.leading, 5)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(.top, 1)
                    
                    // 암기장 마켓등록일, 판매 금액
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color("ITColor"))
                            .font(.footnote)
                        
                        HStack (alignment: .top){
                            // FIXME: 별점 총점 및 후기 총 갯수
                            let reviewCount: Int = wordNote.reviewCount
                            let reviewScore: Double = wordNote.starScoreTotal / Double(reviewCount)
                            let score: String = String(format: "%.1f", reviewScore) // "5.1"

                            if reviewCount == 0 {
                                Text("별점 없음  |")
                                    .font(.caption)
                                    .foregroundColor(Color.gray2)
                            } else {
                                Text("\(score) (\(reviewCount))  |")
                                    .font(.caption)
                                    .foregroundColor(Color.gray2)
                            }
                        
                            // FIXME: 마켓 등록일 관련 데이터 추가 후 수정
                            Text("\(wordNote.updateDateFormatter) 등록")
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
                .padding(.horizontal, 23)

                // MARK: - 암기장 구매하기 버튼
                if marketStore.myWordNoteIdArray.contains(wordNote.id) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray4)
                        .frame(height: 44)
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .overlay {
                            Text("이미 소유하고 있는 암기장 입니다.")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .padding(.bottom, -20)
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
                            .frame(height: 44)
                            .padding(.horizontal, 20)
                            .padding(.top, 4)
                            .overlay {
                                Text("\(wordNote.notePrice)P 로 지식 구매하기!")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            .padding(.bottom, -20)
                    })
                    
//                    .alert(isPresented: $isAlertToggle) {
//                        if isCoinCheckToggle {
//                            return Alert(title: Text("구매하기"),
//                                         message: Text("\(wordNote.noteName)을(를) 구매하시겠습니까?"),
//                                         primaryButton: .destructive(Text("구매하기"),
//                                                                     action: {
//                                marketStore.userCoinWillCheckDB(marketWordNote: wordNote,
//                                                                words: marketStore.words,
//                                                                userCoin: authStore.user?.coin ?? 0)
//
//                                // 코데로 구매한 노트와 워드들이 추가됨.
//                                coreDataStore.addNoteAndWord(note: wordNote, words: marketStore.words)
//                                coreDataStore.getNotes()
//
//                                dismiss()
//
//                                Task {
//                                    await authStore.userInfoWillFetchDB()
//                                    await marketStore.myNotesArrayWillFetchDB()
//                                    await marketStore.filterMyNoteWillFetchDB()
//                                }
//                            }),
//                                         secondaryButton: .cancel(Text("취소")))
//                        } else {
//                            return Alert(title: Text("포인트 부족"),
//                                         message: Text("포인트가 부족합니다"),
//                                         dismissButton: .default(Text("닫기")))
//                        }
//                    }
                }
                
                // MARK: - 암기장 리뷰
                MarketViewSheetReviews(reviews: reviewStore.reviews)
                
                // MARK: - 구분선
                Divider()
                    .frame(height: 3)
                    .overlay { Color.gray5 }
                    .padding(.bottom)
                
                // MARK: - 단어 미리보기
                HStack {
                    Text("미리보기")
                        .foregroundColor(.gray2)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    HStack(spacing: 0) {
                        Text("총 ")
                        Text("\(marketStore.words.count)개")
                            .foregroundColor(.mainDarkBlue)
                        Text("의 단어")
                    }
                    .fontWeight(.semibold)
                }
                .padding(.horizontal, 30)
                .font(.subheadline)
                
                
                // MARK: 5개의 단어만 가져오도록 함
                ForEach(Array(zip(0...4, marketStore.words)), id: \.0) { _, word in
                    
                    if selectedWord.contains(word.wordString) {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray5)
                            .backgroundStyle(Color.gray7)
                            .frame(width: UIScreen.main.bounds.width * 0.9,
                                   height: UIScreen.main.bounds.height * 0.15)
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
                                            .frame(width: UIScreen.main.bounds.width * 0.8,
                                                   height: UIScreen.main.bounds.height * 0.08)
                                        
                                        Text(word.wordMeaning)
                                            .font(.headline)
                                            .foregroundColor(.mainBlue)
                                            .frame(width: UIScreen.main.bounds.width * 0.8,
                                                   height: UIScreen.main.bounds.height * 0.05)
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
                            .frame(width: UIScreen.main.bounds.width * 0.9,
                                   height: UIScreen.main.bounds.height * 0.05)
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
                                            .frame(maxWidth: UIScreen.main.bounds.width * 0.8 * 0.45)
                                            .lineLimit(nil)
                                            
                                        Spacer()
                                        
                                        Text(word.wordMeaning)
                                            .font(.headline)
                                            .foregroundColor(.mainBlue)
                                            .frame(maxWidth: UIScreen.main.bounds.width * 0.8 * 0.45)
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
        .onAppear {
            Task {
                await marketStore.wordsWillFetchDB(wordNoteID: wordNote.id)
                await reviewStore.reviewsWillFetchDB(marketID: wordNote.id)
            }
        }
        .customAlert(isPresented: $isAlertToggle,
                     title: isCoinCheckToggle
                            ? "구매하기"
                            : "포인트 부족",
                     message: isCoinCheckToggle
                              ? "\(wordNote.noteName)을(를) 구매하시겠습니까?"
                              : "구매에 필요한 포인트가 부족합니다",
                     primaryButtonTitle: isCoinCheckToggle
                                         ? "구매하기"
                                         : "확인",
                     primaryAction: {
                        if isCoinCheckToggle {
                            marketStore.userCoinWillCheckDB(marketWordNote: wordNote,
                                                            words: marketStore.words,
                                                            userCoin: authStore.user?.coin ?? 0)
                            
                            // 코데로 구매한 노트와 워드들이 추가됨.
                            coreDataStore.addNoteAndWord(note: wordNote, words: marketStore.words)
                            coreDataStore.getNotes()
                            
                            Task {
                                await authStore.userInfoWillFetchDB()
                                await marketStore.myNotesArrayWillFetchDB()
                                await marketStore.filterMyNoteWillFetchDB()
                                isToastToggle = true
                            }
                        }
            
                        dismiss()
                     },
                     withCancelButton: isCoinCheckToggle,
                     cancelButtonText: "취소")
        
    }
}

// struct MarketViewSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        MarketViewSheet()
//            .environmentObject(MarketStore())
//    }
// }
