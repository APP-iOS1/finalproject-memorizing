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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Array(zip(categoryArray.indices, categoryArray)), id: \.0) { (index, category) in
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(selectedCategory == category ? MarketView.colorArray[index] : Color.gray4)
//                            .frame(width: 50, height: 30)
                            .background(Color.black)
                        
                        
                        Button {
                            selectedCategory = category
                            
                        } label: {
                            Text("\(category)")
                                .font(.footnote)
                                .fontWeight(.medium)
                                .foregroundColor(selectedCategory == category
                                                 ? MarketView.colorArray[index]
                                                 : .gray2)
                                .frame(width: 50, height: 30)
                                .background(Color.gray1)
                        }
                    }
                    
                    .background(Color.red)
                }
                .padding(.vertical, 5)
                .background(Color.green)
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 40)
        .background(Color.blue)
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
