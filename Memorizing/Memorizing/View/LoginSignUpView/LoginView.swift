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
            ZStack {
//                LinearGradient(gradient: Gradient(colors: [Color("MainBlue"), Color("MainDarkBlue")]), startPoint: .top, endPoint: .bottom)
//                    .ignoresSafeArea()
                Color("LoginViewBackgroundColor")
                
                VStack(spacing: 35) {
                    
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height * 0.12)
                    
                    Image("LoginTitle")
                    
                    Spacer()
                    
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height * 0.01)
                    
                    VStack(spacing: 10) {
                        // MARK: 카카오 로그인 버튼
                        HStack {
                            Button {
                                Task {
                                    await authStore.signInDidKakaoAuth()
                                }
                            } label: {
                                HStack {
                                    Image("KakaoLogo")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                    
                                    Spacer()
                                    
                                    Text("카카오로 시작하기")
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                }
                                .frame(width: UIScreen.main.bounds.width * 0.6)
                                .modifier(CustomButtonStyle(backgroundColor: "KakaoYellow"))
                            }
                            // MARK: 카카오 로그아웃
//                            Button {
//                                authStore.signOutDidKakao()
//                            } label: {
//                                Text("Logout")
//                            }
                        }
                        
                        // MARK: 애플 로그인
                        HStack {
                            Button {
                                authStore.signInDidAppleAuth()
                                
                            } label: {
                                HStack {
                                    Image("AppleLogo")
                                    
                                    Spacer()
                                    
                                    Text("Apple ID로 시작하기")
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                .frame(width: UIScreen.main.bounds.width * 0.6)
                                .modifier(CustomButtonStyle(backgroundColor: "MainBlack"))
                            }
                        }
                        
                        // MARK: 구글 로그인 버튼
                        HStack {
                            Button {
                                Task {
                                    await authStore.signInDidGoogleAuth()
                                }
                            } label: {
                                HStack {
                                    Image("GoogleLogo")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                    
                                    Spacer()
                                    
                                    Text("Google로 시작하기")
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                }
                                .frame(width: UIScreen.main.bounds.width * 0.6)
                                .font(.subheadline)
                                .frame(width: UIScreen.main.bounds.width * 0.77, height: UIScreen.main.bounds.height * 0.056)
                                .background(Color("MainWhite"))
                                .cornerRadius(30)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.gray5)
                                }
                            }
                        }
                        
                    }
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height * 0.18)
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
