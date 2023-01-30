//
//  MarketViewSheetReviewsMore.swift
//  Memorizing
//
//  Created by 윤현기 on 2023/01/18.
//

import SwiftUI

// MARK: - 리뷰 더보기 화면
struct MarketViewSheetReviewsMore: View {
    
    @EnvironmentObject var reviewStore: ReviewStore
    var reviews: [Review]
    
    var body: some View {
        VStack {
            HStack {
                Text("후기 \(reviews.count)개")
                    .padding(.leading)
                    .font(.title3)
                    .bold()
                Spacer()
            }
            .padding(.vertical, 20)
            
            ScrollView {
                ForEach(Array(zip(reviews.indices, reviews)), id: \.0) { _, review in
                    VStack(spacing: 7) {
                        HStack(spacing: 0) {
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
                        .font(.subheadline)
                        
                        HStack {
                            Text("\(review.reviewText)")
                                .font(.caption)
                                .padding(.leading, 3)
                            Spacer()
                        }
                        .padding(.bottom, 5)
                        
                        HStack {
                            Text("\(review.writer)")
                                .bold()
                                .foregroundColor(.gray2)
                            Text("2023.01.18")
                                .foregroundColor(.gray3)
                            Spacer()
                            
                            // FIXME: 신고관련 버튼? 링크?
                            Image(systemName: "light.beacon.max")
                                .font(.caption2)
                                .foregroundColor(.gray3)
                        }
                        .padding(.leading, 3)
                        .font(.caption)
                        
                        Divider()
                            .padding(.vertical, 10)
                    }
                    .padding(.horizontal)
                    
                }
                
            }
        }
    }
}

struct MarketViewSheetReviewsMore_Previews: PreviewProvider {
    static var previews: some View {
        MarketViewSheetReviewsMore(reviews: [Review(id: "",
                                                    writer: "",
                                                    reviewText: "",
                                                    createDate: Date.now,
                                                    starScore: 0)])
    }
}
