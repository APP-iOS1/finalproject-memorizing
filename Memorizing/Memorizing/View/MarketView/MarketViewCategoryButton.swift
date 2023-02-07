//
//  MarketViewCategoryButton.swift
//  Memorizing
//
//  Created by 윤현기 on 2023/01/05.
//

import SwiftUI

struct MarketViewCategoryButton: View {
    
    @Binding var selectedCategory: String
    let categoryArray: [String]
    
    var body: some View {
        HStack {
            ForEach(Array(zip(categoryArray.indices, categoryArray)), id: \.0) { (index, category) in
                
                RoundedRectangle(cornerRadius: 15)
                    .stroke(selectedCategory == category ? MarketView.colorArray[index] : Color.gray4)
                    // FIXME: 왜 타입추론 에러가...?
//                    .backgroundStyle(selectedCategory == category ? MarketView.colorArray[index] : Color.white)
                    .frame(width: 50, height: 30)
                    .overlay {
                        Button {
                            selectedCategory = category
                            
                        } label: {
                            Text("\(category)")
                                .font(.footnote)
                                .fontWeight(.medium)
                                .foregroundColor(selectedCategory == category
                                                 ? MarketView.colorArray[index]
                                                 : .gray2)
                        }
                    }
            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
    }
}

struct MarketViewCategoryButton_Previews: PreviewProvider {
   static var previews: some View {
       MarketViewCategoryButton(selectedCategory: .constant("전체"),
                                categoryArray: ["전체",
                                                "영어",
                                                "한국사",
                                                "IT",
                                                "경제",
                                                "시사",
                                                "기타"])
   }
}
