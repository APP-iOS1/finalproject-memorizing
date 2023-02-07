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
        VStack(alignment: .leading) {
            
            ScrollView(.horizontal, showsIndicators: false){
                HStack {
                    ForEach(Array(zip(reviews.indices, reviews)), id: \.0) { index, review in
                        if index < 5 {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray5)
                                .backgroundStyle(Color.white)
                                .frame(width: 170, height: 110)
                                .overlay {
                                    VStack (spacing: 10) {
                                        // 별점 표시되는 부분
                                        HStack(spacing: 2) {
                                            let scoreInt: Int = Int(review.starScore)
                                            ForEach(0 ... (scoreInt - 1), id: \.self) { _ in
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(Color.iTColor)
                                                    .font(.footnote)
                                            }
                                            
                                            if scoreInt < 5 {
                                                ForEach(0 ... (4 - scoreInt), id: \.self) { _ in
                                                    Image(systemName: "star")
                                                        .foregroundColor(Color.iTColor)
                                                        .font(.footnote)
                                                }
                                            }
                                            Spacer()
                                        }
                                        .padding(.leading, 7)
                                        
                                        // 리뷰 내용 부분
                                        HStack {
                                            Text("\(review.reviewText)")
                                                .font(.caption2)
                                                .lineLimit(2)
                                                .fontWeight(.medium)
                                            
                                            Spacer()
                                        }
                                        .padding(.leading, 7)
                                        .frame(height: 35)
                                        
                                        // 리뷰 작성자
                                        HStack {
                                            Text(review.writer)
                                                .font(.caption2)
                                                .foregroundColor(.gray2)
                                                .fontWeight(.medium)
                                            
                                            Spacer()
                                            
                                            // FIXME: 신고관련 버튼? 링크?
                                            Image(systemName: "light.beacon.max")
                                                .font(.caption2)
                                                .foregroundColor(.gray2)
                                        }
                                        .padding(.leading, 7)
                                    }
                                    .padding(.horizontal, 7)
                                }
                        }
                    }
                    }
                .padding(.horizontal, 5)
                .padding(.vertical, 10)
            }
            
            
            // HStack
            HStack(spacing: 6) {
                Spacer()
                // FIXME: 후기 모두보기 페이지 이동
                NavigationLink(destination: MarketViewSheetReviewsMore(reviews: reviews)) {
                    HStack (spacing: 2){
                        Text("후기 모두보기")
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .font(.caption2)
            .foregroundColor(.gray2)
            .padding(.trailing, 22)
            .padding(.bottom, 2)
            
        }// VStack
        .padding(.leading, 18)
        .padding(.top, 20)
    }
}

// struct MarketViewSheetReviews_Previews: PreviewProvider {
//    static var previews: some View {
//        MarketViewSheetReviews()
//    }
// }
