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
            .frame(width: 346, height: 45)
            .overlay {
                HStack {
                    TextField("암기장 이름을 입력해보세요!", text: $searchText)
                        .font(.caption)
                    
                    Spacer()
                    
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray3)
                }
                .padding(.horizontal, 15)
                
            }
        
    }
}
