//
//  SignUpView.swift
//  Memorizing
//
//  Created by 진준호 on 2023/01/05.
//

import SwiftUI
import Combine

// struct ClearButton: ViewModifier
// {
//    @Binding var text: String
//
//    public func body(content: Content) -> some View
//    {
//        ZStack(alignment: .trailing)
//        {
//            content
//
//            if !text.isEmpty
//            {
//                Button(action:
//                {
//                    self.text = ""
//                })
//                {
//                    Image(systemName: "delete.left")
//                        .foregroundColor(Color(UIColor.opaqueSeparator))
//                        .padding(.trailing, 7)
//                }
//                .padding(.trailing, 8)
//            }
//        }
//    }
// }

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authStore: AuthStore
    @State private var nickName: String = ""
//    @State private var nickNameOldValue: String = ""
    @State private var signUpEmail: String = ""
    @State private var signUpPassWord: String = ""
    @State private var signUpPassWordCheck: String = ""
    
    @State private var isShownTerms: Bool = false // 약관 모달뷰
    @State private var termsAgreed: Bool = false // 약관 승인
    @State private var isShownAlert: Bool = false
    @State private var signUpProcessing: Bool = false

    var body: some View {
        VStack {
            Spacer()
            
            Section {
                VStack {
                    // MARK: 닉네임
                    TextField(text: $nickName) {
                        Text("닉네임을 입력해 주세요(최대 6자)")
                            .foregroundColor(Color("Gray2"))
                            .font(.subheadline)
                    }
                    .autocapitalization(.none)
                    .textFieldStyle(CustomTextField())
                    .modifier(ClearButton(text: $nickName))
                    .onReceive(Just(nickName)) { _ in limitText(6) }
                    
                    Spacer()
                        .frame(height: 25)
//                        .frame(height: nickName.count == 0 ? 0 : 10)
                    
//                    if 0 < nickName.count && nickName.count < 7 {
//                        Text("올바른 형식의 닉네임입니다")
//                            .modifier(CheckRightForm(textColor: "MainBlue"))
//                    } else if nickName.count == 0 {
//                        Text("")
//                    } else {
//                        Text("닉네임은 최대 6자입니다")
//                            .modifier(CheckRightForm(textColor: "Red"))
//                    }
                    
                }
                
                // MARK: 이메일
                TextField(text: $signUpEmail) {
                    Text("이메일을 입력해 주세요")
                        .foregroundColor(Color("Gray2"))
                        .font(.subheadline)
                }
                .textFieldStyle(CustomTextField())
                .modifier(ClearButton(text: $signUpEmail))
                .padding(.bottom, 25)
                .autocapitalization(.none)

                // MARK: 비밀번호
                VStack {
                    SecureField(text: $signUpPassWord) {
                        Text("비밀번호를 입력해 주세요")
                            .foregroundColor(Color("Gray2"))
                            .font(.subheadline)
                    }
                    .textFieldStyle(CustomTextField())
                    .modifier(ClearButton(text: $signUpPassWord))
                    
//                    Spacer()
//                        .frame(height: 5)
                    
                    if signUpPassWord.count < 6 && !signUpPassWord.isEmpty {
                        Text("6자리 이상 비밀번호를 입력해주세요")
                            .modifier(CheckRightForm(correctFormToSignup: "Red"))
                    } else {
                        Text(signUpPassWord.count >= 6 ? "올바른 형식의 비밀번호입니다" : " ")
                            .modifier(CheckRightForm(correctFormToSignup: "MainBlue"))
                        
                    }
                }// VStack
//                .frame(height: 20)
                
                // MARK: 비밀번호 확인
                VStack {
                    SecureField(text: $signUpPassWordCheck) {
                        Text("비밀번호를 다시 한번 입력해 주세요")
                            .foregroundColor(Color("Gray2"))
                            .font(.subheadline)
                    }
                    .textFieldStyle(CustomTextField())
                    .modifier(ClearButton(text: $signUpPassWordCheck))
                    
//                    Spacer()
                    
                    // 1차 비밀번호 텍스트란에 내용이 있고, 2차 비밀번호 텍스트란에도 내용이 있는데, 1차와 2차가 같지 않은 경우
                    if signUpPassWord
                        != signUpPassWordCheck
                        && !signUpPassWord.isEmpty
                        && !signUpPassWordCheck.isEmpty {
                        Text("비밀번호가 동일하지 않습니다")
                            .modifier(CheckRightForm(correctFormToSignup: "Red"))
                    } else { // 1차 비밀번호 텍스트란에 내용이 있으며 1차와 2차가 같은 경우
                        Text(signUpPassWord
                             == signUpPassWordCheck
                             && !signUpPassWord.isEmpty
                             ? "비밀번호가 동일합니다"
                             : "")
                            .modifier(CheckRightForm(correctFormToSignup: "MainBlue"))
                    }
                }
            } // VStack
            .frame(height: 70)
            
            if signUpProcessing {
                ProgressView()
            }

            Spacer()
            
            HStack {
                
                Button {
                    termsAgreed.toggle()
                } label: {
                    Image(systemName: termsAgreed ? "checkmark.square.fill" : "checkmark.square")
                        .foregroundColor(.gray1)
                        .fontWeight(.light)
                }
                
                Button {
                    isShownTerms.toggle()
                } label: {
                    Text("회원가입 및 이용약관")
                        .foregroundColor(.mainBlue)
                        .font(.caption)
                        .fontWeight(.regular)
                }
                .sheet(isPresented: $isShownTerms) {
                    SignUpTermsView()
                }
                
                Text("에 동의하시겠습니까?(필수)")
                    .foregroundColor(.gray1)
                    .font(.caption)
                    .padding(.leading, -6)
                
            }
            
            Button {
                isShownAlert.toggle()
                signUpProcessing.toggle()
            } label: {
                Text("회원가입 하기")
                    .modifier(nickName.isEmpty
                              || signUpEmail.isEmpty
                              || signUpPassWord.isEmpty
                              || signUpPassWordCheck.isEmpty
                              || signUpPassWord.count < 6
                              || signUpPassWord != signUpPassWordCheck
                              ? CustomButtonStyle(backgroundColor: "Gray4")
                              : CustomButtonStyle(backgroundColor: "MainBlue")
                    )
                    .alert(
                        "",
                        isPresented: $isShownAlert
                    ) {
                        Button {
                            if termsAgreed {
                                Task {
                                    await authStore.signUpDidAuth(email: signUpEmail,
                                                                  password: signUpPassWord,
                                                                  nickName: nickName)
                                    dismiss()
                                }
                            }
                            signUpProcessing.toggle()
                        } label: {
                            Text("OK")
                        }
                    } message: {
                        Text(termsAgreed ? "회원가입이 완료되었습니다." : "약관 동의를 진행해주세요.")
                    }
            }
            .disabled(nickName.isEmpty
                      || signUpEmail.isEmpty
                      || signUpPassWord.isEmpty
                      || signUpPassWordCheck.isEmpty
                      || signUpPassWord.count < 6
                      || signUpPassWord != signUpPassWordCheck)

            Spacer()
            
        }
        .navigationTitle("회원가입하기")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 닉네임 글자수 제한 함수
    func limitText(_ upper: Int) {
        // upper: 제한 글자 수
        if nickName.count > upper {
            nickName = String(nickName.prefix(upper))
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignUpView()
                .environmentObject(AuthStore())
        }
    }
}
