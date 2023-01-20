//
//  MarketViewSheetReviews.swift
//  Memorizing
//
//  Created by 윤현기 on 2023/01/18.
//

import SwiftUI

struct MarketViewSheetReviews: View {
    
    var reviews: [Review] = []

    var body: some View {
            VStack {
                HStack {
                    ForEach(Array(zip(reviews.indices, reviews)), id: \.0) { index, review in
                        if index < 2 {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray5)
                                .backgroundStyle(Color.white)
                                .frame(width: 175, height: 90)
                                .overlay {
                                    VStack {
                                        // 별점 표시되는 부분
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
                                            Spacer()
                                        }
                                        
                                        // 리뷰 내용 부분
                                        HStack {
                                            Text("\(review.reviewText)")
                                                .font(.caption2)
                                                .lineLimit(1)
                                            
                                            Spacer()
                                        }
                                        .padding(.top, 5)
                                        .padding(.bottom, 8)
                                        
                                        // 리뷰 작성자
                                        HStack {
                                            Text(review.writer)
                                                .font(.caption2)
                                                .foregroundColor(.gray3)
                                            
                                            Spacer()
                                            
                                            // FIXME: 신고관련 버튼? 링크?
                                            Image(systemName: "light.beacon.max")
                                                .font(.caption2)
                                                .foregroundColor(.gray3)
                                        }
                                    }
                                    .padding(5)
                                }
                        }
                
                    }
                } // HStack
                HStack(spacing: 2) {
                    Spacer()
                    // FIXME: 후기 더보기 페이지 이동
                    NavigationLink(destination: MarketViewSheetReviewsMore()) {
                        Text("후기 더보기")
                    }
                }
                .font(.caption2)
                .foregroundColor(.gray2)
                .padding(.trailing, 12)
                .padding(.top, 10)
                
            } // VStack
            .padding(10)
    }
}

// struct MarketViewSheetReviews_Previews: PreviewProvider {
//    static var previews: some View {
//        MarketViewSheetReviews()
//    }
// }
