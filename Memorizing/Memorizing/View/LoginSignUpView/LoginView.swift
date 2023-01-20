//
//  LoginView.swift
//  Memorizing
//
//  Created by 진준호 on 2023/01/05.
//

import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @EnvironmentObject var authStore: AuthStore
    @State private var loginId: String = ""
    @State private var loginPW: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 35) {
                    
                    Image("MainLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 150)
                        .padding(.top, 100)
                    
                    Spacer()
                    
                    TextField(text: $loginId) {
                        Text("이메일을 입력해 주세요")
                        //                    .modifier(CustomTextFieldPlaceHolder())
                            .foregroundColor(Color("Gray2"))
                            .font(.subheadline)
                    }
                    .textFieldStyle(CustomTextField())
                    .modifier(ClearButton(text: $loginId))
                    .autocapitalization(.none)
                    
                    SecureField(text: $loginPW) {
                        Text("비밀번호를 입력해 주세요")
                            .foregroundColor(Color("Gray2"))
                            .font(.subheadline)
                    }
                    .textFieldStyle(CustomTextField())
                    .modifier(ClearButton(text: $loginPW))
                    
                    HStack {
                        Spacer()
                        
                        NavigationLink {
                            // TODO: 비밀번호 찾기 뷰로 이동
                            FindIdPwView()
                        } label: {
                            Text("아이디 및 비밀번호 찾기")
                                .underline()
                                .foregroundColor(Color("Gray2"))
                                .font(.caption2)
                                .padding(.trailing)
                            
                        }
                    }
                    .padding(.top, -20)
                    .frame(width: 330)
                    
                    Button {
                        Task {
                            print("click Button login")
                            await authStore.signInDidAuth(email: loginId, password: loginPW)
                        }
                    } label: {
                        Text("로그인")
                            .modifier(CustomButtonStyle(backgroundColor: "MainBlue"))
                    }
                    .padding(.top, 30)
                    
                    HStack {
                        Text("메모라이징이 처음이라면?")
                            .foregroundColor(Color("Gray1"))
                        
                        NavigationLink {
                            SignUpView()
                        } label: {
                            Text("회원가입하기")
                                .foregroundColor(Color("MainDarkBlue"))
                        }
                    }
                    .padding(.top, -20)
                    .font(.caption2)
                    
                    Spacer()
                    
                    GoogleSignInButton {
                        Task {
                            await authStore.signInDidGoogleAuth()
                        }
                    }
                    .padding(.horizontal, 50)
                    
                    VStack {
                        HStack {
                            Button {
                                Task {
                                    await authStore.signInDidKakaoAuth()
                                }
                            } label: {
                                Text("Kakao SignIn")
                            }
                            
                            Button {
                                authStore.signOutDidKakao()
                            } label: {
                                Text("Logout")
                            }
                        }
                        HStack {
                            SignInWithAppleButton()
                                .frame(width: 280, height: 45)
                                .onTapGesture {
                                    authStore.signInDidAppleAuth()
                                }
                        }
                    }

                } // vstack
            } // scroll view
        } // navigationstack
    } // body
} // struct

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthStore())
    }
}
