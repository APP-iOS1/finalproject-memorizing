//
//  MarketViewSearchBar.swift
//  Memorizing
//
//  Created by 윤현기 on 2023/01/05.
//

import SwiftUI

struct MarketViewSearchBar: View {
    
    @Binding var searchText: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 30)
            .foregroundColor(.gray8)
            .frame(width: UIScreen.main.bounds.width * 0.9, height: 45)
            .overlay {
                HStack {
                    TextField("내가 원하는 암기장을 검색해보세요!", text: $searchText)
                        .font(.caption)
                        .padding(.leading, 6)
                    
                    Spacer()
                    
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray3)
                }
                .padding(.horizontal, 15)
                
            }
        
    }
}
