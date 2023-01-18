//
//  SignUpTermsView.swift
//  Memorizing
//
//  Created by 전근섭 on 2023/01/05.
//

import SwiftUI

struct SignUpTermsView: View {
    @Environment(\.dismiss) private var dismiss
    // @Binding var termsAgreed: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Text("MEMOrizing 이용약관")
                .font(.title2)
                .fontWeight(.bold)
                .padding()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("제1장 총칙")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("제 1조 (목적)")
                            .font(.title3)
                            .fontWeight(.bold)
                        HStack {
                            Text("이 약관은 MEMOrizing(이하 ")
                            + Text("\"최우수작\"")
                                .fontWeight(.bold)
                                .font(.title2)
                                .foregroundColor(.blue)
                            + Text("이라 한다.)이 제공하는 단어장 서비스의 이용 조건 및 절차, 이용자와 ")
                            + Text("해커톤 8조").fontWeight(.bold).font(.title2).foregroundColor(.blue)
                            + Text("의 권리, 의무, 책임 사항과 기타 필요한 사항을 규정하기 위한 것입니다. 이 약관이 적용되는 앱의 내용은 다음과 같습니다.")
                        }
                    
                        VStack(alignment: .leading, spacing: 20) {
                        Text("제 2조 (용어의 정의)")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("이 약관에서 사용하는 용어는 다음과 같이 정의합니다.")
                        Text("① MEMOrizing: 멋쟁이 사자처럼 앱스쿨 1기 해커톤 최우수작을 말합니다. 추후 아주 멋진 앱으로 출시되어 많은 이들의 사랑을 받습니다.")
                        Text("② 해커톤 8조: 멋쟁이 사자처럼 앱스쿨 1기 해커톤 최우수팀을 말합니다.")
                        Text("③ 이용자: 이 약관에 따라 MEMOrizing 앱이 제공하는 서비스를 이용하는 사과님들을 말합니다.")
                        Text("④ 가입: 이 약관에 동의하고, MEMOrizing에서 제공하는 신청서 양식에 해당 정보를 기입하여 MEMOrizing 이용 계약을 완료하는 행위를 말합니다.")
                        HStack {
                            Text("⑤ 회원 정보: 필명, 계정(ID), 비밀번호, 전자 우편(이메일, E-mail) 등 ")
                            Text("MEMOrizing의 회원 가입 신청서 양식 등에 기재를 요청하는 회원의 개인 정보를 말합니다.")
                        }
                        Text("⑥ 탈퇴: 탈퇴는 없습니다 ^^ 한번 가입하면 도망은 못가용~!")
                        
                    }
                }
                    .padding(.horizontal, 10)

            }
            
            Button {
                // MARK: signUpView의 termsAgreed .toggle()
                // termsAgreed.toggle()
                dismiss()
            } label: {
                Text("닫기")
            }
        }
    }
}

struct SignUpTermsView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpTermsView()
    }
}
