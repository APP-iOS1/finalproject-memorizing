//
//  MyReviewCell.swift
//  Memorizing
//
//  Created by Jae hyuk Yim on 2023/02/01.
//

import SwiftUI

struct MyReviewCell: View {
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var marketStore: MarketStore
    @EnvironmentObject var myNoteStore: MyNoteStore
    @EnvironmentObject var reviewStore: ReviewStore
    
    var reviews: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 2) {
                let scoreInt: Int = Int(reviews.starScore)
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
            VStack {
                Text(reviews.reviewText)
            }
            
            HStack {
                // 단어장 
            }
        }
    }
}

struct MyReviewCell_Previews: PreviewProvider {
    static var previews: some View {
        MyReviewCell(reviews: Review(id: "",
                                     writer: "홍길동",
                                     reviewText: "매우 유익한 단어장이네요!",
                                     createDate: Date(),
                                     starScore: 4.5))
    }
}
