//
//  MarketView.swift
//  Memorizing
//
//  Created by 진준호 on 2023/01/05.
//

import SwiftUI

// MARK: - 마켓 탭에서 가장 메인으로 보여주는 View
struct MarketView: View {
    @EnvironmentObject var marketStore: MarketStore
    @EnvironmentObject var authStore: AuthStore
    /// 검색창 입력 텍스트
    @State private var searchText: String = ""
    @State private var isSheetOpen: Bool = false
    
    @State var time = Timer.publish(every: 0.1, on: .main, in: .tracking).autoconnect()
    
    /// 카테고리 목록
    static let categoryArray: [String] = [
        "전체", "영어", "한국사", "IT", "경제", "시사", "기타"
    ]
    
    static let colorArray: [Color] = [
        .mainDarkBlue, .mainBlue, .historyColor, .iTColor, .economyColor, .knowledgeColor, .etcColor
    ]
    
    @State private var selectedCategory: String  = "전체"
    
    var body: some View {
        
        // MARK: - 검색창
        MarketViewSearchBar(searchText: $searchText)
            .padding(.top, 15)
        
        // MARK: - 카테고리 버튼들
        ScrollView(.horizontal, showsIndicators: false) {
            MarketViewCategoryButton(selectedCategory: $selectedCategory,
                                     categoryArray: MarketView.categoryArray)
        }
        .padding(.leading, 13)
        
        // MARK: - 검색창 하단 구분선
        Divider()
            .frame(height: 5)
            .overlay(Color("Gray5"))
            .padding(.top, -3)
        
        ZStack {
            ScrollView(showsIndicators: false) {
                // MARK: - Grid View
                
                let columns = [
                    GridItem(.flexible(), spacing: 0, alignment: nil),
                    GridItem(.flexible(), spacing: 0, alignment: nil)
                ]
                
                LazyVGrid(
                    columns: columns,
                    spacing: 18,
                    content: {
                        ForEach(marketStore.marketWordNotes) { wordNote in
                            if searchText.isEmpty
                                || wordNote.noteName.contains(searchText) {
                                MarketViewNoteButton(isSheetOpen: $isSheetOpen,
                                                     selectedCategory: $selectedCategory,
                                                     selectedWordNote: wordNote)
                            }
                            // MARK: - Pagination(InfiniteScroll) 구현 코드
//                            if marketStore.marketWordNotes.last!.id == wordNote.id {
//                                GeometryReader { geo in
//                                    MarketViewNoteButton(isSheetOpen: $isSheetOpen,
//                                                         selectedCategory: $selectedCategory,
//                                                         selectedWordNote: wordNote)
//                                    .padding(.leading, 5)
//                                    .onAppear {
//                                        self.time = Timer.publish(every: 0.1, on: .main, in: .tracking).autoconnect()
//                                    }
//                                    .onReceive(self.time) { (_) in
//                                        if geo.frame(in: .global).maxY < UIScreen.main.bounds.height - 80 {
//
//                                            // 나중에 데이터가 많아지고 limit이 20으로 바뀌면 아래 5를 20으로 바꿔야 됨
//                                            if marketStore.snapshotCounter >= 5 {
//                                                Task {
//                                                    await marketStore.marketNotesWillPagingUpdateFetchDB()
//                                                }
//
//                                                print("Update Data...")
//                                            }
//
//                                            self.time.upstream.connect().cancel()
//                                        }
//                                    }
//                                }
//                            } else {
//                                MarketViewNoteButton(isSheetOpen: $isSheetOpen,
//                                                     selectedCategory: $selectedCategory,
//                                                     selectedWordNote: wordNote)
//                            }
                            // MARK: - 여기까지
                        }
                    })
                .padding(.horizontal)
                .padding(.top, 15)
                .padding(.bottom, 120)
            }   // ScrollView end
            .padding(.bottom, 1)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("Logo")
                        .resizable()
                        .frame(width: 35, height: 22)
                        .padding(.leading, 10)
                }
                ToolbarItem(placement: .principal) {
                    Text("암기장 마켓")
                        .font(.title3.bold())
                        .accessibilityAddTraits(.isHeader)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                   
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.mainBlue)
                        .frame(width: 60, height: 30)
                        .overlay {
                            Text("\(authStore.user?.coin ?? 0)P")
                                .foregroundColor(.mainBlue)
                                .font(.subheadline)
                        }
                }
            }
            .fullScreenCover(isPresented: $isSheetOpen) {
                // TODO: 단어장 클릭시 단어 목록 리스트 보여주기
                MarketViewSheet(wordNote: marketStore.sendWordNote)
            }
            
            NavigationLink(destination: MarketViewAddButton()) {
                Circle()
                    .foregroundColor(.mainBlue)
                    .frame(width: 65, height: 65)
                    .overlay {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.title3)
                            .bold()
                    }
                    .shadow(radius: 1, x: 1, y: 1)
            }
            .offset(x: UIScreen.main.bounds.width * 0.36, y: UIScreen.main.bounds.height * 0.25)
        }
//        .onAppear {
//            marketStore.fetchMarketWordNotes()
//        }
    }
}

struct MarketView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MarketView()
                .environmentObject(MarketStore())
                .environmentObject(AuthStore())
        }
    }
}
