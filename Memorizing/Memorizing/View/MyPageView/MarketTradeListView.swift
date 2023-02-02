//
//  MarketTradeListView.swift
//  Memorizing
//
//  Created by 윤현기 on 2023/02/01.
//

import SwiftUI

struct MarketTradeListView: View {
    @State private var marketTradeToggle: Bool = true
    @State private var isReviewed: Bool = true
    @EnvironmentObject var marketStore: MarketStore
    @EnvironmentObject var myNoteStore: MyNoteStore
    @EnvironmentObject var authStore: AuthStore
    
    var body: some View {
        ScrollView {
            
            // MARK: - 판매내역 / 구매내역 토글
            VStack(spacing: 5) {
                HStack(spacing: 20) {
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
                        VStack {
                            HStack {
                                // TODO: 구매 날짜 추후 수정
                                Text("2023.01.16")
                                    .foregroundColor(.gray1)
                                    .font(.footnote)
                                Spacer()
                            }
                            HStack {
                                Text(note.noteName)
                                Spacer()
                                // TODO: 구매 포인트 추후 수정
                                Text("200P")
                                    .foregroundColor(.mainDarkBlue)
                            }
                            .font(.headline)
                            .padding(.top, 2)
                            .padding(.bottom, 10)
                            
                            HStack {
                                Spacer()
                                
                                if note.reviewDate == nil {
                                    Text("후기 작성하고 ")
                                    + Text("10P ")
                                    + Text("받기!")
                                    Image(systemName: "chevron.right")
                                } else {
                                    Text("후기 작성 완료")
                                }
                            }
                            .font(.caption)
                            .foregroundColor(isReviewed
                                             ? .mainBlue
                                             : .gray3)
                            .fontWeight(.semibold)
                            
                            Divider()
                                .padding(.vertical, 10)
                        }
                        .padding(.horizontal)
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
                                Text("\(marketNote.salesCount)개 판매")
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
                            .padding(.bottom, 10)
                            
                            Divider()
                                .padding(.vertical, 10)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("마켓 거래내역")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            myNoteStore.myNotesWillBeFetchedFromDB()
        }
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
