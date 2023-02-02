//
//  MyReviewView.swift
//  Memorizing
//
//  Created by Jae hyuk Yim on 2023/02/01.
//

import SwiftUI

struct MyReviewView: View {
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var marketStore: MarketStore
    @EnvironmentObject var myNoteStore: MyNoteStore
    @EnvironmentObject var reviewStore: ReviewStore
    
    var wordNote: MarketWordNote
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(reviewStore.reviews, id: \.id) { review in
                    if review.id == authStore.user?.id {
                        VStack(alignment: .leading) {
                            HStack {
                                VStack(alignment: .leading, spacing: 10) {
                                    // 평점
                                    HStack(spacing: 2) {
                                        let scoreInt: Int = Int(review.starScore)
                                        ForEach(0 ... (scoreInt - 1), id: \.self) { _ in
                                            Image(systemName: "star.fill")
                                                .foregroundColor(Color.iTColor)
                                        }
                                        
                                        if scoreInt < 5 {
                                            ForEach(0 ... (4 - scoreInt), id: \.self) { _ in
                                                Image(systemName: "star")
                                                    .foregroundColor(Color.iTColor)
                                            }
                                        }
                                    }
                                    // 리뷰글
                                    VStack {
                                        Text(review.reviewText)
                                            .font(.callout)
                                            .fontWeight(.medium)
                                    }
                                    // 단어장 이름 및 게시시간
                                    HStack {
                                        Text(wordNote.noteName)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.gray2)

                                        Text(wordNote.updateDateFormatter)
                                            .font(.subheadline)
                                            .fontWeight(.regular)
                                            .foregroundColor(.gray3)
                                    }
                                }
                                Spacer()
                                // 포인트 획득 Text
                                VStack(alignment: .trailing) {
                                    Text("10P 획득")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.mainDarkBlue)
                                }
                                .font(.headline)
                                .padding(.top, 35)
                                
                            }
                            Divider()
                                .padding(.vertical, 10)
                        }
                    }
                }
            }
        }
        .navigationTitle("내가 작성한 리뷰")
        .navigationBarTitleDisplayMode(.inline)
        .padding()
        // fetch가 되려면, 특정 마켓 Notes에 한번 들어갔다 나와야지만 정상적으로 작동함
        // 왜 그럴까..? 전체 review들을 한거번에 fetch할 수 없나..
//        .onAppear {
//            Task {
//                await reviewStore.reviewsWillFetchDB(marketID: wordNote.id ?? "")
//            }
//        }
    }
}

struct MyReviewView_Previews: PreviewProvider {
    static var previews: some View {
        MyReviewView(wordNote: MarketWordNote(id: "",
                                              noteName: "이상한 나라의 앨리스",
                                              noteCategory: "IT",
                                              enrollmentUser: "",
                                              notePrice: 200,
                                              updateDate: Date(),
                                              salesCount: 0,
                                              starScoreTotal: 4.0,
                                              reviewCount: 0))
            .environmentObject(ReviewStore())
    }
}
