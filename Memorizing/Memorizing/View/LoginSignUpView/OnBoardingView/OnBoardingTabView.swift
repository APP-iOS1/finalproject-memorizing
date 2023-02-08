//
//  OnBoardingTabView.swift
//  Memorizing
//
//  Created by 김혜지 on 2023/01/06.
//

import SwiftUI

struct OnBoardingTabView: View {
    
    @State var currentTab: Int
    
    @Binding var email: String
    @Binding var password: String
    
    var body: some View {
        
        VStack {
            TabView(selection: $currentTab, content: {
                
                ForEach(OnBoardingData.list) { viewData in
                    OnBoardingView(data: viewData, email: $email, password: $password)
                        .tag(viewData.id)
                }

            })
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
    }
}
