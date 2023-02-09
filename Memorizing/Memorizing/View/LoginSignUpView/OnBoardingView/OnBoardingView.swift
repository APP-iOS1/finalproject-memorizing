//
//  OnBoardingView.swift
//  Memorizing
//
//  Created by 김혜지 on 2023/01/06.
//

import SwiftUI

struct OnBoardingView: View {
    
    var data: OnBoardingData
    @EnvironmentObject var authStore: AuthStore
    @Binding var email: String
    @Binding var password: String
    
    var body: some View {
        VStack {
            
            Image(data.objectImage)
                .frame(height: 100)
                .padding(.bottom, 80)
            
            Text(data.text)
                .font(.headline)
                .lineSpacing(15)
                .multilineTextAlignment(.center)
                .fontWeight(.medium)
                .foregroundColor(.gray1)
            
            if data.id == 3 {
                Button {
                    Task.init {
                        await authStore.signInDidAuth(email: email, password: password, name: "")
                    }
                } label: {
                    Text("메모라이징 시작하기")
                        .font(.footnote)
                        .bold()
                }
                .modifier(CustomButtonStyle(backgroundColor: "MainBlue"))
                .shadow(radius: 1, x: 1, y: 1)
            }
            
        }
    }
}

struct OnBoardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnBoardingView(data: OnBoardingData.list[1],
                       email: .constant(""),
                       password: .constant(""))
            .environmentObject(AuthStore())
    }
}
