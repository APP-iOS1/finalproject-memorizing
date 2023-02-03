//
//  MyPageView.swift
//  Memorizing
//
//  Created by 진준호 on 2023/01/05.
//

import SwiftUI

// MARK: 마이페이지 탭에서 가장 메인으로 보여주는 View
struct MyPageView: View {
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var myNoteStore: MyNoteStore
    @EnvironmentObject var notiManager: NotificationManager
    @EnvironmentObject var marketStore: MarketStore
    
    @State private var signOutAlertToggle: Bool = false
//    @State private var isShownNickNameToggle: Bool = false
    @State private var isShowingWeb: Bool = false
    
    var body: some View {
        
        NavigationStack {

            VStack {
    
    // MARK: - 유저 정보
                VStack(alignment: .leading) {
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("안녕하세요")
                            .foregroundColor(.gray2)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Text("\(authStore.user?.nickName ?? "") 님")
                                .font(.title)
                                .fontWeight(.semibold)
                            
                            let email: String = authStore.user?.email ?? ""
                            if email.contains("kakao") {
                                loginLogo(name: "KakaoLogo")
                            } else if email.contains("appleid") {
                                loginLogo(name: "AppleLogo")
                            } else if email.contains("gmail") {
                                loginLogo(name: "GoogleLogo")
                            }
                        }
                        
                    } // 그리팅메세지
                    .padding(.top, -30)
                    
                    HStack(spacing: 15) {
                        
                        VStack(spacing: 5) {
                            Text("내 암기장")
                                .foregroundColor(.gray2)
                            
                            Text("\(myNoteStore.myWordNotes.count)")
                                .bold()
                        }
                        
                        Divider()
                            .frame(height: 30)
                        
                        VStack(spacing: 5) {
                            Text("내 도장")
                                .foregroundColor(.gray2)
                            
                            Text("\(myNoteStore.calculateStamp(myWordNotes: myNoteStore.myWordNotes))")
                                .bold()
                        }
                        
                        Spacer()
                        
                        NavigationLink {
                            // TODO: 내가 작성한 리뷰 페이지로 이동
                            EditUserView()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 100)
                                    .stroke(Color("MainBlue"), lineWidth: 1)
                                    .frame(width: 120, height: 45)
                                Text("내 정보 수정하기")
                                    .foregroundColor(.mainBlack)
                                    .font(.footnote)
                                    .fontWeight(.medium)
                            }
                        }

                    } // 내 암기장개수 . 받은 도장 개수
                    .font(.footnote)
                } // 유저정보
                .padding(.bottom, 10)
                
    // MARK: - 유저 버튼
                VStack {
                    VStack {
                        Divider()
                        
                        NavigationLink {
                            // TODO: 암기장 구매 내역 페이지로 이동
                            MarketTradeListView()
                        } label: {
                            HStack {
                                Text("마켓 거래내역")
                                    .font(.body)
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.title3)
                                    .fontWeight(.light)
                            } // 문의하기
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .foregroundColor(.mainBlack)
                        }
                        .isDetailLink(false)
                    }

                    VStack {
                        Divider()
                        
                        NavigationLink {
                            // 파라미터 추가
                            MyReviewView(wordNote: marketStore.sendWordNote)
                        } label: {
                            HStack {
                                Text("내가 작성한 리뷰")
                                    .font(.body)
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.title3)
                                    .fontWeight(.light)
                            } // 문의하기
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .foregroundColor(.mainBlack)
                        }
                    }
                    
                    VStack {
                        Divider()
                        
                        Button {
                            isShowingWeb.toggle()
                        } label: {
                            HStack {
                                Text("메모라이징 소개")
                                    .font(.body)
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.title3)
                                    .fontWeight(.light)
                            } // 문의하기
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .foregroundColor(.mainBlack)
                        }
                        .sheet(isPresented: $isShowingWeb) {
                            WebView()
                        }

                    }

                    VStack {
                        Divider()
                        
                        // 단점: 카카오톡 로그인 했을때만 가능
                        Button(action: {
                                    let kakaoPlusFriendsURL = URL(string: "http://pf.kakao.com/_hZrWxj/chat")!
                                    UIApplication.shared.open(kakaoPlusFriendsURL)
                                }) {
                                    HStack {
                                        Text("1:1 문의하기")
                                            .font(.body)
                                            .fontWeight(.medium)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.title3)
                                            .fontWeight(.light)
                                    } // 문의하기
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .foregroundColor(.mainBlack)
                                }
                        
                        Button(action: {
                            //공용 구글 이메일을 만들어서 직접 이메일로 보내는것은 어떨까요?
                                    guard let url = URL(string: "https://www.kakaowork.com/?utm_source=google_pc&tum_medium=sa&utm_campaign=kakaowork&utm_term=%EA%B8%B0%EC%97%85%EC%9A%A9%EC%B9%B4%EC%B9%B4%EC%98%A4%ED%86%A1&gclid=Cj0KCQiA2-2eBhClARIsAGLQ2RnWOe4lycDpoECGLUZSy1sh1UAp_rLXxOazNpK6Un04HcfgA7E6cDYaAschEALw_wcB") else { return }
                                    UIApplication.shared.open(url)
                                }, label: {
                                    Text("Open in Kakao Plus Friend")
                                })
                    }
                    
                    VStack {
                        Divider()
                        
                        NavigationLink {
                            InfoPolicy()
                        } label: {
                            HStack {
                                Text("개인정보 처리 방침")
                                    .font(.body)
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.title3)
                                    .fontWeight(.light)
                            } // 문의하기
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .foregroundColor(.mainBlack)
                        }
                    }
                    
                    VStack {
                        Divider()
                        
                        Button {
                            signOutAlertToggle.toggle()
                        } label: {
                            HStack {
                                Text("로그아웃하기")
                                    .font(.body)
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.title3)
                                    .fontWeight(.light)
                            } // 문의하기
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .foregroundColor(.mainBlack)
                            
                        }
                    }
                    
                    Divider()
                    
                    Spacer()
                    
                } // 문의하기, 개인정보 처리 방침
                .frame(maxHeight: .infinity)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Image("Logo")
                            .resizable()
                            .frame(width: 35, height: 22)
                            .padding(.leading, 10)
                    }
                    ToolbarItem(placement: .principal) {
                        Text("마이페이지")
                            .font(.title3.bold())
                            .accessibilityAddTraits(.isHeader)
                    }
                }
            }
            .padding(.horizontal, 30)
        }
        .customAlert(isPresented: $signOutAlertToggle,
                     title: "로그아웃",
                     message: "정말 로그아웃 하시겠습니까?",
                     primaryButtonTitle: "로그아웃",
                     primaryAction: {
            authStore.signOutDidAuth()
            notiManager.removeAllRequest()
            myNoteStore.myWords = []
            myNoteStore.myWordNotes = []
        },
                     withCancelButton: true)
    }
}

struct loginLogo: View {
    let name: String
    var color: Color {
        switch name {
        case "GoogleLogo":
            return .white
        case "KakaoLogo":
            return .kakaoYellow
        default:
            return .black
        }
    }
    
    var body: some View {
        Circle()
            .stroke(name == "GoogleLogo"
                    ? Color.gray4
                    : Color.white)
            .background(Circle().fill(color))
            .frame(width: 27)
            .overlay {
                Image(name)
                    .resizable()
                    .frame(width: name == "AppleLogo" ? 13 : 17,
                           height: 17)
            }
    }
}

struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MyPageView()
                .environmentObject(AuthStore())
                .environmentObject(MyNoteStore())
                .environmentObject(MarketStore())
        }
    }
}
