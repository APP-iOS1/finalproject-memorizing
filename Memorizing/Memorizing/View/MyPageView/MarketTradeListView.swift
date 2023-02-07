//
//  MarketTradeListView.swift
//  Memorizing
//
//  Created by 윤현기 on 2023/02/01.
//

import SwiftUI

struct MarketTradeListView: View {
    @EnvironmentObject var marketStore: MarketStore
    @EnvironmentObject var myNoteStore: MyNoteStore
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var coreDataStore: CoreDataStore
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var marketTradeToggle: Bool = true
    @State private var isReviewed: Bool = true
    @State private var isAlertOpen: Bool = false
    @State private var isfullScreenCoverOpen: Bool = false
    @State private var marketWordNote: MarketWordNote
        = MarketWordNote(id: "",
                         noteName: "",
                         noteCategory: "",
                         enrollmentUser: "",
                         notePrice: 0,
                         updateDate: Date(),
                         salesCount: 0,
                         starScoreTotal: 0.0,
                         reviewCount: 0)
    
    var body: some View {
        ScrollView {
            // MARK: - 판매내역 / 구매내역 토글
            VStack(spacing: 5) {
                HStack(spacing: 12) {
                    Button {
                        marketTradeToggle = true
                    } label: {
                        Text("구매내역")
                            .font(.title2)
                            .bold()
                            .foregroundColor(marketTradeToggle
                                             ? .mainDarkBlue
                                             : .gray3)
                    }
                    
                    Button {
                        marketTradeToggle = false
                    } label: {
                        Text("판매내역")
                            .font(.title2)
                            .bold()
                            .foregroundColor(marketTradeToggle
                                             ? .gray3
                                             : .mainDarkBlue)
                    }
                    
                    Spacer()
                }
                .padding(.leading)
            }
            .padding(.vertical, 25)
            
            // MARK: - 구매내역 보기
            if marketTradeToggle {
                ForEach(myNoteStore.myWordNotes, id: \.id) { note in
                    if note.enrollmentUser != authStore.user?.id {
                        
                        let noteEntity: NoteEntity
                        = coreDataStore
                            .returnNote(id: note.id,
                                        noteName: note.noteName,
                                        enrollmentUser: note.enrollmentUser,
                                        noteCategory: note.noteCategory,
                                        repeatCount: note.repeatCount,
                                        firstTestResult: note.firstTestResult,
                                        lastTestResult: note.lastTestResult,
                                        updateDate: note.updateDate)
                        
                        VStack {
                            HStack {
                                Text("\(note.marketPurchaseDateFormatter ?? "날짜 정보 표시불가")")
                                    .foregroundColor(.gray1)
                                    .font(.footnote)
                                Spacer()
                            }
                            HStack {
                                Text(note.noteName)
                                Spacer()
                                Text("\(note.notePrice ?? 0)P")
                                    .foregroundColor(.mainDarkBlue)
                            }
                            .font(.headline)
                            .padding(.top, 2)
                            .padding(.bottom, 10)
                            
                            HStack {
                                Spacer()
                                
                                if note.reviewDate == nil {
                                    NavigationLink {
                                        CreateReviewView(wordNote: noteEntity,
                                                         marketPurchaseDate: note.marketPurchaseDate)
                                    } label: {
                                        Text("후기 작성하고 ")
                                        + Text("10P ")
                                        + Text("받기!")
                                        Image(systemName: "chevron.right")
                                    }
                                } else {
                                    Text("후기 작성 완료")
                                }
                            }
                            .font(.caption)
                            .foregroundColor(note.reviewDate == nil
                                             ? .mainBlue
                                             : .gray3)
                            .fontWeight(.semibold)
                            
                            Divider()
                                .padding(.vertical, 10)
                        }
                        .padding(.horizontal, 30)
                    }
                }
            // MARK: - 판매내역 보기
            } else {
                ForEach(marketStore.marketWordNotes, id: \.id) { marketNote in
                    if marketNote.enrollmentUser == authStore.user?.id {
                        VStack {
                            HStack {
                                Text(marketNote.updateDateFormatter)
                                Spacer()
                                if marketNote.salesCount > 0 {
                                    Text("\(marketNote.salesCount)개 판매")
                                } else {
                                    Text("판매 이력이 존재하지 않습니다.")
                                }
                            }
                            .foregroundColor(.gray1)
                            .font(.footnote)
                            
                            HStack {
                                Text(marketNote.noteName)
                                Spacer()
                                Text("\(marketNote.totalSalesAmount)P")
                                    .foregroundColor(.mainDarkBlue)
                            }
                            .font(.headline)
                            .padding(.top, 2)
                            
                            HStack {
                                Text("판매 가격 : \(marketNote.notePrice)P")
                                Spacer()
                                Button {
                                    isAlertOpen = true
                                    marketWordNote = marketNote
                                } label: {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                        Text("판매등록 취소")
                                    }
                                    .foregroundColor(.red)
                                    .bold()
                                }
                            }
                            .foregroundColor(.gray1)
                            .font(.footnote)
                            .padding(.vertical, 10)
                            
                            Divider()
                                .padding(.bottom, 10)
                        }
                        .padding(.horizontal, 30)
                    }
                }
            }
        }
        .navigationTitle("마켓 거래내역")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            myNoteStore.myNotesWillBeFetchedFromDB()
        }
        .onDisappear {
            dismiss()
        }
        .customAlert(isPresented: $isAlertOpen,
                     title: "판매등록 취소",
                     message: "취소하시게되면, 기존에 있던 \n 평점과 리뷰가 사라집니다.",
                     primaryButtonTitle: "확인",
                     primaryAction: {
                        Task {
                            await marketStore.marketNotesWillDeleteDB(marketWordNote: marketWordNote)
                        }
                        isAlertOpen = false
                    },
                     withCancelButton: true,
                     cancelButtonText: "취소")
    }
}

struct MarketTradeListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MarketTradeListView()
                .environmentObject(MyNoteStore())
        }
    }
}
