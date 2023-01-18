//
//  ButtonModifier.swift
//  Memorizing
//
//  Created by 전근섭 on 2023/01/05.
//

import SwiftUI

// MARK: 로그인, 암기장 만들기 등 메인 버튼 모디파이어
struct CustomButtonStyle: ViewModifier {
    
    var backgroundColor: String
    
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .foregroundColor(.white)
            .frame(width: 300, height: 50)
            .background(Color(backgroundColor))
            .cornerRadius(30)
        
    }
}

// MARK: 회원가입 가능 여부 적용 버튼
struct CheckRightForm: ViewModifier {
    var correctFormToSignup: String
    
    func body(content: Content) -> some View {
        content
            .frame(width: 250, alignment: .leading)
            .multilineTextAlignment(.leading)
            .padding(.top, 5)
//            .padding(.bottom, 15)
            .foregroundColor(Color(correctFormToSignup))
            .font(.caption)
    }
}

// MARK: 모르겠어요, 애매해요, 외웠어요 버튼 모디파이어
struct CheckDifficultyButton: ViewModifier {
    var backGroundColor: String
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .frame(width: 100, height: 100)
            .background(Color(backGroundColor))
            .cornerRadius(20)
    }
}

struct ClearButton: ViewModifier {
    @Binding var text: String
    
    public func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content
            
            if !text.isEmpty {
                Button {
                    self.text = ""
                } label: {
                    Image(systemName: "x.circle.fill")
                        .foregroundColor(Color(UIColor.opaqueSeparator))
                        .padding(.trailing, 7)
                }
                .padding(.trailing, 8)
            }
        }
    }
}
