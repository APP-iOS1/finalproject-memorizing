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
    @Environment(\.dismiss) private var dismiss
    
    var wordNote: WordNote
    
    @State private var selectedWord: [String] = []
    @State private var isAlertToggle: Bool = false
    @State private var isCoinCheckToggle: Bool = false
    
    var body: some View {
        ScrollView {
            
            // MARK: - 단어장 정보
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray5)
                .backgroundStyle(Color.gray7)
                .frame(width: 343, height: 116)
                .padding(.top, 30)
                .overlay {
                    VStack {
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
                            
                            Text("\(wordNote.notePrice) P")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.mainBlue)
                        }
                        
                        // 암기장 제목
                        HStack {
                            Text(wordNote.noteName)
                                .foregroundColor(.mainBlack)
                                .bold()
                                .multilineTextAlignment(.leading)
                                .lineLimit(1)
                            
                            Spacer()
                        }
                        .padding(.top)
                        
                    }
                    .padding()
                }
            
            // MARK: - 암기장 구매하기 버튼
            if authStore.myWordNoteIdArray.contains(wordNote.id) {
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
                        print("\(authStore.user?.coin ?? 0)")
                    } else {
                        isAlertToggle.toggle()
                        isCoinCheckToggle = false
                        // iscoinCheckToggle.toggle()
                    }
                }, label: {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.mainBlue)
                        .frame(width: 355, height: 44)
                        .overlay {
                            Text("암기장 구매하기")
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
                                        authStore.userCoinWillCheckDB(marketWordNote: wordNote,
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
            
            // MARK: - 구분선
            Divider()
                .padding()
            
            // MARK: - 단어 미리보기
            HStack {
                Text("Preview")
                    .font(.subheadline)
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
            
        }
        .onAppear {
            marketStore.wordsWillFetchDB(wordNoteId: wordNote.id)
            authStore.notesArrayWillFetchDB()
        }
        .onDisappear {
            authStore.myNotesWillFetchDB()
        }
    }
}

// struct MarketViewSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        MarketViewSheet()
//            .environmentObject(MarketStore())
//    }
// }
