//
//  MarketViewSheetReviews.swift
//  Memorizing
//
//  Created by 윤현기 on 2023/01/18.
//

import SwiftUI

struct MarketViewSheetReviews: View {
    let score: Double = 4.5
    
    var body: some View {
            VStack {
                HStack {
                    ForEach(0...1, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray5)
                            .backgroundStyle(Color.white)
                            .frame(width: 175, height: 90)
                            .overlay {
                                VStack {
                                    // 별점 표시되는 부분
                                    HStack(spacing: 2) {
                                        let scoreInt: Int = Int(score)
                                        ForEach(0 ... (scoreInt - 1), id: \.self) { _ in
                                            Image(systemName: "star.fill")
                                                .foregroundColor(Color.iTColor)
                                        }
                                        
                                        ForEach(0 ... (4 - scoreInt), id: \.self) { _ in
                                            Image(systemName: "star")
                                                .foregroundColor(Color.iTColor)
                                        }
                                        Spacer()
                                    }
                                    
                                    // 리뷰 내용 부분
                                    HStack {
                                        Text("단어장 구성이 알차고 좋아요!")
                                            .font(.caption2)
                                            .lineLimit(1)
                                        
                                        Spacer()
                                    }
                                    .padding(.top, 5)
                                    .padding(.bottom, 8)
                                    
                                    // 리뷰 작성자
                                    HStack {
                                        Text("혜동이")
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

struct MarketViewSheetReviews_Previews: PreviewProvider {
    static var previews: some View {
        MarketViewSheetReviews()
    }
}
