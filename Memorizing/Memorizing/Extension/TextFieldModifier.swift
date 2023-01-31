//
//  TextFieldModifier.swift
//  Memorizing
//
//  Created by 전근섭 on 2023/01/05.
//

import SwiftUI

// FIXME: 이거 왜 텍스트 필드 placeholder에는 적용 안됨...?
struct CustomTextFieldPlaceHolder: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color("Gray2"))
            .font(.subheadline)
     }
}

// MARK: textfield 스타일 모디파이어
struct CustomTextField: TextFieldStyle {
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.vertical, 13)
            .padding(.horizontal, 25)
            .background(Color("Gray5"))
            .cornerRadius(30)
        //            .frame(width: 287, height: 39)
            .frame(width: 300, height: 30)
            .disableAutocorrection(true)
            .textInputAutocapitalization(.never)
            .foregroundColor(Color("Black"))
    }
}
