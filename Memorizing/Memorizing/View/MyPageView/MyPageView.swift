//
//  MyPageView.swift
//  Memorizing
//
//  Created by 진준호 on 2023/01/05.
//

import SwiftUI
import SafariServices
import KakaoSDKTalk

// MARK: 마이페이지 탭에서 가장 메인으로 보여주는 View
struct MyPageView: View {
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var myNoteStore: MyNoteStore
    @EnvironmentObject var notiManager: NotificationManager
    @EnvironmentObject var marketStore: MarketStore
    @State private var signOutAlertToggle: Bool = false
//    @State private var isShownNickNameToggle: Bool = false
    @State private var isShowingWeb: Bool = false
    @State private var isShowingKakaoTalk: Bool = false
    
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
                            
                            switch authStore.user?.signInPlatform {
                            case "kakao": loginLogo(name: "KakaoLogo")
                            case "apple":
                                loginLogo(name: "AppleLogo")
                            default:
                                loginLogo(name: "GoogleLogo")
                            }
                        }
                        
                    } // 그리팅메세지
                    .padding(.top, -30)
                    
                    HStack(spacing: 15) {
                        
                        VStack(spacing: 5) {
                            Text("내 암기장")
                                .foregroundColor(.gray1)
                                .padding(.bottom, 3)
                            
                            Text("\(myNoteStore.myWordNotes.count)")
                                .bold()
                        }
                        .padding(.leading, 8)
                        
                        Divider()
                            .frame(height: 30)
                        
                        VStack(spacing: 5) {
                            Text("내 도장")
                                .foregroundColor(.gray1)
                                .padding(.bottom, 3)
                            
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
                .padding(.bottom, 18)
                
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
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.body)
                                    .fontWeight(.light)
                            } // 문의하기
                            .padding(.horizontal, 8)
                            .padding(.vertical, 12)
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
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.body)
                                    .fontWeight(.light)
                            } // 문의하기
                            .padding(.horizontal, 8)
                            .padding(.vertical, 12)
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
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.body)
                                    .fontWeight(.light)
                            } // 문의하기
                            .padding(.horizontal, 8)
                            .padding(.vertical, 12)
                            .foregroundColor(.mainBlack)
                        }
                        .sheet(isPresented: $isShowingWeb) {
                            WebView()
                        }

                    }

                    VStack {
                        Divider()
                        
                        Button {
                            isShowingKakaoTalk.toggle()
//                            let kakaoPlusFriendsURL = URL(string: "https://pf.kakao.com/_hZrWxj/chat")!
//                            UIApplication.shared.open(kakaoPlusFriendsURL)
                        } label: {
                            HStack {
                                Text("1:1 문의하기")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.body)
                                    .fontWeight(.light)
                            } // 문의하기
                            .padding(.horizontal, 8)
                            .padding(.vertical, 12)
                            .foregroundColor(.mainBlack)
                        }
                        .sheet(isPresented: $isShowingKakaoTalk) {
                            KakaoTalkChannelView()
                        }
                    }
                    
                    VStack {
                        Divider()
                        
                        NavigationLink {
                            InfoPolicy()
                        } label: {
                            HStack {
                                Text("개인정보 처리 방침")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.body)
                                    .fontWeight(.light)
                            } // 문의하기
                            .padding(.horizontal, 8)
                            .padding(.vertical, 12)
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
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.body)
                                    .fontWeight(.light)
                            } // 문의하기
                            .padding(.horizontal, 8)
                            .padding(.vertical, 12)
                            .foregroundColor(.mainBlack)
                            
                        }
                    }
                    
                    Divider()
                    
                    HStack{
                        Text("버전 정보 1.0.0")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(.gray3)
                        Spacer()
                        Text("")
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
                    
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
                     withCancelButton: true,
                     cancelButtonText: "취소")
    }
    
    struct KakaoTalkChannelView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> SFSafariViewController {
            let safariViewController: SFSafariViewController = SFSafariViewController(url: TalkApi.shared.makeUrlForChannelChat(channelPublicId: "_hZrWxj")!)
            print("카카오톡 채널 주소\(String(describing: TalkApi.shared.makeUrlForChannelChat(channelPublicId: "_hZrWxj")))")
            
            safariViewController.modalTransitionStyle = .crossDissolve
            safariViewController.modalPresentationStyle = .overCurrentContext
            
          //  safariViewController.present(safariViewController, animated: true)
            return safariViewController

        }
        
        func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
            
        }
        
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
